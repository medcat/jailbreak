#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
#include <jailbreak>

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

//#define JAILBREAK_TEAMBAN_DELETE "DELETE FROM tf2jail_blueban_logs WHERE auth = '%s';"
//#define JAILBREAK_TEAMBAN_CREATE "INSERT INTO tf2jail_blueban_logs (auth, admin, start, length, current, active) VALUES ('%s', '%s', %d, %d, 0, 1);"

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
}

public void OnMapStart() {
    for(int i = 0; i < MAXPLAYERS; i++) { spawnTimes[i] = -2; }
    teamBans = new StringMap();
    Database.Connect(OnSqlConnect, "bluebans");
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
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

public Action OnJailbreakRoundEnd(JailbreakRoundType jailbreakRoundType) {
    for(int i = 1; i < MaxClients; i++) {
        if(!IsClientConnected(i) ||!IsClientInGame(i) || IsFakeClient(i) || !IsPlayerAlive(i)) continue;
        UpdateClientTimes(i);
    }

    return Plugin_Continue;
}

public void OnClientDisconnect(int clientId) {
    if(IsFakeClient(clientId)) return;
    UpdateClientTimes(clientId, true);
    spawnTimes[clientId - 1] = -2;
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
    char reason[1024];
    int[] targets = new int[MaxClients];
    char targetName[128];
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

    char adminId[32];
    char adminName[MAX_NAME_LENGTH];
    GetClientAuthId(client, AuthId_Steam2, adminId, sizeof(adminId));
    GetClientName(client, adminName, sizeof(adminName));

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
        char[] query = new char[1024];
        int newTimes[2];
        int currentTimes[2];
        int clientId = targets[i];
        GetClientAuthId(clientId, AuthId_Steam2, authId, sizeof(authId));
        GetClientName(clientId, authName, sizeof(authName));
        Format(query, 1024, JAILBREAK_TEAMBAN_CREATE, GetTime(), authId,
            authName, adminId, adminName, lengthTime, lengthTime, reason);
        LogMessage("sending query %s to server.", query);
        dataStore.Query(OnTeamBanUpdateResult, query);
        newTimes[JAILBREAK_TIMES_LEFT] = lengthTime;
        newTimes[JAILBREAK_TIMES_LENGTH] = lengthTime;

        if(IsPlayerAlive(clientId) && TF2_GetClientTeam(clientId) == TFTeam_Blue) {
            ForcePlayerSuicide(clientId);
        }

        if(teamBans.GetArray(authId, currentTimes, 2)) {
            LogMessage("duplicate team ban for %s found, resolving by picking larger ban...", authId);
            if(Jailbreak_TimesGreater(currentTimes, newTimes)) continue;
            LogMessage("new ban was larger, maintaining.", authId);
        }

        LogMessage("client %s has %d time remaining.", authId, lengthTime);
        teamBans.SetArray(authId, newTimes, 2, true);
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
    GetCmdArg(1, target, sizeof(target));
    int[] targets = new int[MaxClients];
    char targetName[128];

    bool _tx;
    int totalClients = ProcessTargetString(target, client, targets, MaxClients,
        COMMAND_FILTER_NO_BOTS, targetName, sizeof(targetName), _tx);
    if(totalClients < 1) {
        ReplyToTargetError(client, totalClients);
        return Plugin_Handled;
    }

    for(int i = 0; i < totalClients; i++) {
        char authId[32];
        char[] query = new char[1024];
        GetClientAuthId(targets[i], AuthId_Steam2, authId, sizeof(authId));

        Format(query, 1024, JAILBREAK_TEAMBAN_CLEAR, authId);
        dataStore.Query(OnTeamBanUpdateResult, query);
        LogMessage("sending query %s to server.", query);
        teamBans.Remove(authId);
    }

    CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Teamban_SuccessfulUnBan",
        client, targetName);
    return Plugin_Handled;
}
