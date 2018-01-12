#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>

#define JAILBREAK_REPLY "[{silver}Jailbreak{white}] %T"

public Plugin myinfo =
{
    name = "Jailbreak Team Bans",
    author = "Jeremy Rodi <me@medcat.me>",
    description = "Team banning for jailbreak",
    version = "0.3.0",
    url = "https://github.com/medcat/jailbreak"
};

Database dataStore = null;
StringMap teamBans = null;
int spawnTimes[MAXPLAYERS];
Handle forwardTeamBan = null;
Handle forwardTeamBanOffline = null;

#define JAILBREAK_TEAMBAN_LOOKUP "SELECT * FROM tf2jail_blueban_logs WHERE (timeleft > -1) AND offender_steamid = '%s';"
#define JAILBREAK_TEAMBAN_INCREMENT "UPDATE tf2jail_blueban_logs SET timeleft = timeleft - %d WHERE (timeleft > -1) AND offender_steamid = '%s';"
#define JAILBREAK_TEAMBAN_CLEAR "UPDATE tf2jail_blueban_logs SET timeleft = -1 WHERE (timeleft > -1) AND offender_steamid = '%s';"
#define JAILBREAK_TEAMBAN_CREATE "INSERT INTO tf2jail_blueban_logs (timestamp, offender_steamid, offender_name, admin_steamid, admin_name, bantime, timeleft, reason) VALUES (%d, '%s', '%s', '%s', '%s', %d, %d, '%s');"
// tf2jail_blueban_logs: timestamp: Int, offender_steamid: String,
// offender_name: String, admin_steamid: String, admin_name: String,
// bantime: Int, timeleft: Int, reason: String
#define JAILBREAK_TEAMBAN_TIMESTAMP_FIELD 0
#define JAILBREAK_TEAMBAN_OFFENDER_STEAMID_FIELD 1
#define JAILBREAK_TEAMBAN_OFFENDER_NAME_FIELD 2
#define JAILBREAK_TEAMBAN_ADMIN_STEAMID_FIELD 3
#define JAILBREAK_TEAMBAN_ADMIN_NAME_FIELD 4
#define JAILBREAK_TEAMBAN_BANTIME_FIELD 5
#define JAILBREAK_TEAMBAN_TIMELEFT_FIELD 6
#define JAILBREAK_TEAMBAN_REASON_FIELD 7

#define JAILBREAK_TIMES_LEFT 1
#define JAILBREAK_TIMES_LENGTH 0

stock int Jailbreak_TimesRemaining(int times[2]) {
    return times[JAILBREAK_TIMES_LEFT];
}

stock bool Jailbreak_TimesLeft(int times[2]) {
    return (times[JAILBREAK_TIMES_LEFT] == 0 ||
        times[JAILBREAK_TIMES_LEFT] > 0);
}

stock int GetTimeMinutes() {
    return GetTime() / 60;
}

stock bool Jailbreak_TimesGreater(int a[2], int b[2]) {
    return (a[JAILBREAK_TIMES_LEFT] == 0 || ((b[JAILBREAK_TIMES_LEFT] != 0) &&
            Jailbreak_TimesRemaining(a) > Jailbreak_TimesRemaining(b)));
}

public void OnPluginStart() {
    LoadTranslations("common.phrases");
    LoadTranslations("jailbreak_teamban.phrases");

    RegAdminCmd("sm_teamban", Command_Jailbreak_TeamBan, ADMFLAG_BAN,
        "teambans a player.", "sm_teamban");
    RegAdminCmd("sm_unteamban", Command_Jailbreak_UnTeamBan, ADMFLAG_UNBAN,
        "unteambans a player.", "sm_unteamban");
    RegAdminCmd("sm_teamban_offline", Command_Jailbreak_TeamBan_Offline, ADMFLAG_BAN,
        "teambans a player.", "sm_teamban_offline");
    RegAdminCmd("sm_unteamban_offline", Command_Jailbreak_UnTeamBan_Offline, ADMFLAG_UNBAN,
        "unteambans a player.", "sm_unteamban_offline");
    forwardTeamBan = CreateGlobalForward("OnJailbreakTeamBan", ET_Event,
        Param_Cell, Param_Cell, Param_Cell, Param_String);
    forwardTeamBanOffline = CreateGlobalForward("OnJailbreakTeamBanOffline", ET_Event,
        Param_Cell, Param_String, Param_Cell, Param_String);
}

public void OnMapStart() {
    for(int i = 0; i < MAXPLAYERS; i++) { spawnTimes[i] = -2; }
    teamBans = new StringMap();
    Database.Connect(OnSqlConnect, "bluebans");
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
    HookEvent("arena_win_panel", Event_RoundEnd, EventHookMode_PostNoCopy);
}

public void OnMapEnd() {
    if(teamBans != null) { teamBans.Close(); teamBans = null; }
    if(dataStore != null) { dataStore.Close(); dataStore = null; }
}

public void OnSqlConnect(Database db, const char[] error, any data) {
    if(db == null) {
        ThrowError("Could not connect to database for reason '%s'!", error);
        return;
    }

    dataStore = db;
    LoadAllClients();
}

void LoadAllClients() {
    char[] query = new char[1024];
    char authId[32] = "";

    StrCat(query, 1024, "SELECT * FROM tf2jail_blueban_logs WHERE (timeleft > -1) AND offender_steamid IN (''");
    for(int i = 0; i < MAXPLAYERS; i++) {
        int clientId = i + 1;
        if(spawnTimes[i] == -1 && IsClientInGame(clientId)) {
            GetClientAuthId(clientId, AuthId_Steam2, authId, sizeof(authId));
            StrCat(query, 1024, ", '");
            StrCat(query, 1024, authId);
            StrCat(query, 1024, "'");
        }
    }

    StrCat(query, 1024, ")");

    LogMessage("running query \"%s\"", query);
    dataStore.Query(OnTeamBanListResult, query);
}

public void OnTeamBanListResult(Database _db, DBResultSet result, const char[] error, any data) {
    char authId[32];
    if(result == null) {
        ThrowError("Error while attempting to load team bans: %s", error);
        return;
    }

    while(result.FetchRow()) {
        result.FetchString(JAILBREAK_TEAMBAN_OFFENDER_STEAMID_FIELD, authId,
            sizeof(authId));
        LogMessage("found client %s...", authId);

        int times[2];
        int currentTimes[2];
        int leftTime = result.FetchInt(JAILBREAK_TEAMBAN_TIMELEFT_FIELD);
        int lengthTime = result.FetchInt(JAILBREAK_TEAMBAN_BANTIME_FIELD);
        times[JAILBREAK_TIMES_LENGTH] = lengthTime;
        times[JAILBREAK_TIMES_LEFT] = leftTime;

        if(teamBans.GetArray(authId, currentTimes, 2)) {
            LogMessage("duplicate team ban for %s found, resolving by picking larger ban...", authId);
            if(Jailbreak_TimesGreater(currentTimes, times)) continue;
            LogMessage("new ban was larger, maintaining.", authId);
        }

        if(Jailbreak_TimesLeft(times)) {
            LogMessage("client %s has %d time remaining.", authId, leftTime);
            teamBans.SetArray(authId, times, 2, true);
        } else {
            LogMessage("client %s is no longer teambanned.", authId);
            teamBans.Remove(authId);
        }
    }
}

public void OnTeamBanUpdateResult(Database _db, DBResultSet result, const char[] error, any data) {
    if(result == null) {
        LogError("While attempting to update the teamban status of a player, we encountered an error.");
        LogError("The error was: '%s'", error);
    }
}

public void OnClientPutInServer(int clientId) {
    char query[256];
    char authId[32];
    if(IsFakeClient(clientId)) return;
    spawnTimes[clientId - 1] = -1;
    LogMessage("Client connected, marking as active and loading...");
    if(dataStore != null) {
        LogMessage("loading new client from database...");
        GetClientAuthId(clientId, AuthId_Steam2, authId, sizeof(authId));
        Format(query, sizeof(query), JAILBREAK_TEAMBAN_LOOKUP, authId);
        dataStore.Query(OnTeamBanListResult, query);
    }
}

public void OnClientDisconnect(int clientId) {
    if(IsFakeClient(clientId)) return;
    UpdateClientTimes(clientId, true);
    spawnTimes[clientId - 1] = -2;
}

public void Event_PlayerSpawn(Event event, const char[] _n, bool _db) {
    int clientId = GetClientOfUserId(event.GetInt("userid"));
    char authId[32];
    int times[2];

    if(IsFakeClient(clientId)) return;
    if(teamBans == null || dataStore == null) return;
    GetClientAuthId(clientId, AuthId_Steam2, authId, sizeof(authId));
    if(!teamBans.GetArray(authId, times, sizeof(times))) return;
    if(!Jailbreak_TimesLeft(times)) {
        teamBans.Remove(authId);
        return;
    }

    if(event.GetInt("team") == view_as<int>(TFTeam_Blue)) {
        TF2_ChangeClientTeam(clientId, TFTeam_Red);
        TF2_RespawnPlayer(clientId);
        spawnTimes[clientId - 1] = GetTimeMinutes();
    } else {
        spawnTimes[clientId - 1] = GetTimeMinutes();
    }
}

public void Event_PlayerDeath(Event event, const char[] _n, bool _db) {
    int clientId = GetClientOfUserId(event.GetInt("userid"));
    UpdateClientTimes(clientId);
}

public void Event_RoundEnd(Event _e, const char[] _n, bool _db) {
    for(int i = 1; i < MaxClients; i++) {
        if(!IsClientConnected(i) ||!IsClientInGame(i) || IsFakeClient(i) || !IsPlayerAlive(i)) continue;
        UpdateClientTimes(i);
    }
}

void UpdateClientTimes(int clientId, bool forceDelete = false) {
    char authId[32];
    int times[2];
    if(teamBans == null || dataStore == null) return;
    if(spawnTimes[clientId - 1] < 0) return;
    GetClientAuthId(clientId, AuthId_Steam2, authId, sizeof(authId));
    if(!teamBans.GetArray(authId, times, sizeof(times))) return;

    int liveTime = GetTimeMinutes() - spawnTimes[clientId - 1];
    char[] query = new char[1024];
    LogMessage("found client %L with live time %d", clientId, liveTime);

    if(liveTime >= times[JAILBREAK_TIMES_LEFT] || forceDelete) {
        // teamban is done with.
        LogMessage("auto-unbanned client %L.", clientId);
        teamBans.Remove(authId);
        times[JAILBREAK_TIMES_LEFT] = -1;
        Format(query, 1024, JAILBREAK_TEAMBAN_CLEAR, authId);
        LogMessage("issuing query for %L: %s", clientId, query);
        dataStore.Query(OnTeamBanUpdateResult, query);
    } else {
        times[JAILBREAK_TIMES_LEFT] -= liveTime;
        LogMessage("client %L has remaining time %d.", clientId, times[JAILBREAK_TIMES_LEFT]);
        teamBans.SetArray(authId, times, sizeof(times), true);
        Format(query, 1024, JAILBREAK_TEAMBAN_INCREMENT, liveTime, authId);
        LogMessage("issuing query for %L: %s", clientId, query);
        dataStore.Query(OnTeamBanUpdateResult, query);
    }

    if(forceDelete) spawnTimes[clientId - 1] = -2;
    else spawnTimes[clientId - 1] = -1;
}

void TeamBan(int adminId, int clientId, const char[] authId,
    const char[] authName, int length, const char[] reason) {
    char adminName[MAX_NAME_LENGTH];
    char[] query = new char[1024];
    int newTimes[2];
    int currentTimes[2];
    if(clientId != 0) {
        if(Jailbreak_TriggerTeamBan(adminId, clientId, length, reason) != Plugin_Continue) return;
    } else {
        if(Jailbreak_TriggerTeamBanOffline(adminId, authId, length, reason) != Plugin_Continue) return;
    }

    GetClientName(adminId, adminName, sizeof(adminName));
    Format(query, 1024, JAILBREAK_TEAMBAN_CREATE, GetTime(), authId,
        authName, adminId, adminName, length, length, reason);
    LogMessage("sending query '%s' to server.", query);
    dataStore.Query(OnTeamBanUpdateResult, query);
    newTimes[JAILBREAK_TIMES_LEFT] = length;
    newTimes[JAILBREAK_TIMES_LENGTH] = length;

    if(clientId != 0 && IsPlayerAlive(clientId) && TF2_GetClientTeam(clientId) == TFTeam_Blue) {
        ForcePlayerSuicide(clientId);
    }

    if(teamBans.GetArray(authId, currentTimes, 2)) {
        LogMessage("duplicate team ban for %s found, resolving by picking larger ban...", authId);
        if(Jailbreak_TimesGreater(currentTimes, newTimes)) return;
        LogMessage("new ban was larger, maintaining.", authId);
    }

    LogMessage("client %s has %d time remaining.", authId, length);
    teamBans.SetArray(authId, newTimes, 2, true);
}

void UnTeamBan(const char[] authId) {
    char[] query = new char[1024];
    Format(query, 1024, JAILBREAK_TEAMBAN_CLEAR, authId);
    dataStore.Query(OnTeamBanUpdateResult, query);
    LogMessage("sending query '%s' to server.", query);
    teamBans.Remove(authId);
}

public Action Command_Jailbreak_TeamBan(int client, int args) {
    if(args < 2 || args > 3) {
        PrintToConsole(client, "Usage: sm_teamban <clients> [time] <reason>");
        return Plugin_Handled;
    }

    if(teamBans == null || dataStore == null) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Teamban_NotConnected",
            client);
        return Plugin_Handled;
    }

    char target[MAX_NAME_LENGTH];
    char targetName[256];
    char reason[1024];
    int[] targets = new int[MaxClients];
    int lengthTime = 0;
    GetCmdArg(1, target, sizeof(target));

    if(args == 3) {
        char lengthTimeString[32];
        GetCmdArg(2, lengthTimeString, sizeof(lengthTimeString));
        lengthTime = StringToInt(lengthTimeString, 10);
        if(lengthTime < 1) lengthTime = 0;
        GetCmdArg(3, reason, sizeof(reason));
    } else {
        GetCmdArg(2, reason, sizeof(reason));
    }

    bool _tx;
    int totalClients = ProcessTargetString(target, client, targets, MaxClients,
        COMMAND_FILTER_NO_BOTS, targetName, sizeof(targetName), _tx);
    if(totalClients < 1) {
        ReplyToTargetError(client, totalClients);
        return Plugin_Handled;
    }

    for(int i = 0; i < totalClients; i++) {
        char authId[32];
        char authName[MAX_NAME_LENGTH];
        GetClientAuthId(targets[i], AuthId_Steam2, authId, sizeof(authId));
        GetClientName(targets[i], authName, sizeof(authName));
        TeamBan(client, targets[i], authId, authName, lengthTime, reason);
    }

    CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Teamban_SuccessfulBan",
        client, targetName);
    return Plugin_Handled;
}

public Action Command_Jailbreak_UnTeamBan(int client, int args) {
    if(args != 1) {
        PrintToConsole(client, "Usage: sm_unteamban <clients>");
        return Plugin_Handled;
    }

    if(teamBans == null || dataStore == null) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Teamban_NotConnected",
            client);
        return Plugin_Handled;
    }

    char target[MAX_NAME_LENGTH];
    char targetName[256];
    GetCmdArg(1, target, sizeof(target));
    int[] targets = new int[MaxClients];

    bool _tx;
    int totalClients = ProcessTargetString(target, client, targets, MaxClients,
        COMMAND_FILTER_NO_BOTS, targetName, sizeof(targetName), _tx);
    if(totalClients < 1) {
        ReplyToTargetError(client, totalClients);
        return Plugin_Handled;
    }

    for(int i = 0; i < totalClients; i++) {
        char authId[32];
        GetClientAuthId(targets[i], AuthId_Steam2, authId, sizeof(authId));
        UnTeamBan(authId);
    }

    CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Teamban_SuccessfulUnBan",
        client, targetName);
    return Plugin_Handled;
}

public Action Command_Jailbreak_TeamBan_Offline(int client, int args) {
    char authId[32];
    int lengthTime;
    char reason[1024];

    GetCmdArg(1, authId, sizeof(authId));
    if(args == 3) {
        char lengthTimeString[32];
        GetCmdArg(2, lengthTimeString, sizeof(lengthTimeString));
        lengthTime = StringToInt(lengthTimeString, 10);
        if(lengthTime < 1) lengthTime = 0;
        GetCmdArg(3, reason, sizeof(reason));
    } else {
        GetCmdArg(2, reason, sizeof(reason));
    }

    if(StrContains(authId, "STEAM_") == -1) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Teamban_Offline_InvalidSteam");
    } else {
        TeamBan(client, 0, authId, authId, lengthTime, reason);
    }

    return Plugin_Handled;
}

public Action Command_Jailbreak_UnTeamBan_Offline(int client, int args) {
    char authId[32];
    int lengthTime;
    char reason[1024];

    GetCmdArg(1, authId, sizeof(authId));
    if(args == 3) {
        char lengthTimeString[32];
        GetCmdArg(2, lengthTimeString, sizeof(lengthTimeString));
        lengthTime = StringToInt(lengthTimeString, 10);
        if(lengthTime < 1) lengthTime = 0;
        GetCmdArg(3, reason, sizeof(reason));
    } else {
        GetCmdArg(2, reason, sizeof(reason));
    }

    if(StrContains(authId, "STEAM_") == -1) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Teamban_Offline_InvalidSteam");
    } else {
        UnTeamBan(authId);
    }

    return Plugin_Handled;
}

Action Jailbreak_TriggerTeamBan(int admin, int client, int length, const char[] reason) {
    Action result;
    Call_StartForward(forwardTeamBan);
    Call_PushCell(admin);
    Call_PushCell(client);
    Call_PushCell(length);
    Call_PushString(reason);
    if(Call_Finish(result) != SP_ERROR_NONE) ThrowError("TriggerMapEventEx forward failed!");
    return result;
}

Action Jailbreak_TriggerTeamBanOffline(int admin, const char[] authId, int length,
    const char[] reason) {
    Action result;
    Call_StartForward(forwardTeamBanOffline);
    Call_PushCell(admin);
    Call_PushString(authId);
    Call_PushCell(length);
    Call_PushString(reason);
    if(Call_Finish(result) != SP_ERROR_NONE) ThrowError("TriggerMapEventEx forward failed!");
    return result;
}

public int Native_JailbreakTeamBan(Handle plugin, int numParams) {
    int admin = GetNativeCell(1);
    if(!IsClientInGame(admin) || !IsPlayerAlive(admin))
        ThrowNativeError(101, "Invalid admin given (must be alive and in game)!");
    int client = GetNativeCell(2);
    if(!IsClientInGame(client) || !IsPlayerAlive(client))
        ThrowNativeError(101, "Invalid client given (must be alive and in game)!");
    int lengthTime = GetNativeCell(3);
    if(lengthTime < 0)
        ThrowNativeError(301, "Team ban length must be larger than 0!");
    char reason[1024];
    GetNativeString(4, reason, sizeof(reason));
    char authId[32];
    char authName[MAX_NAME_LENGTH];
    GetClientAuthId(client, AuthId_Steam2, authId, sizeof(authId));
    GetClientName(client, authName, sizeof(authName));
    TeamBan(client, client, authId, authName, lengthTime, reason);
    return 0;
}

public int Native_JailbreakTeamBanOffline(Handle plugin, int numParams) {
    int admin = GetNativeCell(1);
    if(!IsClientInGame(admin) || !IsPlayerAlive(admin))
        ThrowNativeError(101, "Invalid admin given (must be alive and in game)!");
    char authId[32];
    GetNativeString(2, authId, sizeof(authId));
    int lengthTime = GetNativeCell(3);
    if(lengthTime < 0)
        ThrowNativeError(301, "Team ban length must be larger than 0!");
    char reason[1024];
    GetNativeString(4, reason, sizeof(reason));
    TeamBan(admin, 0, authId, authId, lengthTime, reason);
    return 0;
}

public int Native_JailbreakUnTeamBan(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    if(!IsClientInGame(client) || !IsPlayerAlive(client))
        ThrowNativeError(101, "Invalid client given (must be alive and in game)!");
    char authId[32];
    GetClientAuthId(client, AuthId_Steam2, authId, sizeof(authId));
    UnTeamBan(authId);
    return 0;
}

public int Native_JailbreakUnTeamBanOffline(Handle plugin, int numParams) {
    char authId[32];
    GetNativeString(1, authId, sizeof(authId));
    UnTeamBan(authId);
    return 0;
}
