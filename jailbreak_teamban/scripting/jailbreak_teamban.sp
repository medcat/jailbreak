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

#define JAILBREAK_TEAMBAN_LOOKUP "SELECT * FROM sm_jailbreak_teambans WHERE (length = -1 OR current < length) AND auth = '%s' AND active = 1;"
#define JAILBREAK_TEAMBAN_INCREMENT "UPDATE sm_jailbreak_teambans SET current = current + %d WHERE (length = -1 OR current < length) AND auth = '%s' AND active = 1;"
#define JAILBREAK_TEAMBAN_DELETE "DELETE FROM sm_jailbreak_teambans WHERE auth = '%s';"
#define JAILBREAK_TEAMBAN_CREATE "INSERT INTO sm_jailbreak_teambans (auth, admin, start, length, current, active) VALUES ('%s', '%s', %d, %d, 0, 1);"
#define JAILBREAK_TEAMBAN_CLEAR "UPDATE sm_jailbreak_teambans SET active = 0 WHERE (length = -1 OR current < length) AND auth = '%s';"
// sm_jailbreak_teambans: id: Int, auth: String, start: Int, length: Int, current: Int
#define JAILBREAK_TEAMBAN_ID_FIELD 0
#define JAILBREAK_TEAMBAN_AUTH_FIELD 1
#define JAILBREAK_TEAMBAN_START_FIELD 2
#define JAILBREAK_TEAMBAN_LENGTH_FIELD 3
#define JAILBREAK_TEAMBAN_CURRENT_FIELD 4

#define JAILBREAK_TIMES_CURRENT 1
#define JAILBREAK_TIMES_LENGTH 0

stock int Jailbreak_TimesRemaining(int times[2]) {
    return times[JAILBREAK_TIMES_LENGTH] - times[JAILBREAK_TIMES_CURRENT];
}

stock bool Jailbreak_TimesLeft(int times[2]) {
    return (times[JAILBREAK_TIMES_LENGTH] == -1 ||
        times[JAILBREAK_TIMES_LENGTH] > times[JAILBREAK_TIMES_CURRENT]);
}

stock bool Jailbreak_TimesGreater(int a[2], int b[2]) {
    return (a[JAILBREAK_TIMES_LENGTH] == -1 || ((b[JAILBREAK_TIMES_LENGTH] != -1) &&
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
    Database.Connect(OnSqlConnect, "jailbreak");
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
    HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("tf_game_over", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("teamplay_round_win", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("teamplay_game_over", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("teamplay_win_panel", Event_RoundEnd, EventHookMode_PostNoCopy);
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

    StrCat(query, 1024, "SELECT * FROM sm_jailbreak_teambans WHERE (length = -1 OR current < length) AND auth IN (''");
    for(int i = 0; i < MAXPLAYERS; i++) {
        int clientId = i + 1;
        if(spawnTimes[i] == -1 && IsClientInGame(clientId)) {
            GetClientAuthId(clientId, AuthId_Steam3, authId, sizeof(authId));
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
        result.FetchString(JAILBREAK_TEAMBAN_AUTH_FIELD, authId, sizeof(authId));
        LogMessage("found client %s...", authId);

        int times[2];
        int currentTimes[2];
        int lengthTime = result.FetchInt(JAILBREAK_TEAMBAN_LENGTH_FIELD);
        int currentTime = result.FetchInt(JAILBREAK_TEAMBAN_CURRENT_FIELD);
        times[JAILBREAK_TIMES_CURRENT] = currentTime;
        times[JAILBREAK_TIMES_LENGTH] = lengthTime;

        if(teamBans.GetArray(authId, currentTimes, 2)) {
            LogMessage("duplicate team ban for %s found, resolving by picking larger ban...", authId);
            if(Jailbreak_TimesGreater(currentTimes, times)) continue;
            LogMessage("new ban was larger, maintaining.", authId);
        }

        if(Jailbreak_TimesLeft(times)) {
            LogMessage("client %s has %d time remaining.", authId, lengthTime - currentTime);
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
        GetClientAuthId(clientId, AuthId_Steam3, authId, sizeof(authId));
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
    GetClientAuthId(clientId, AuthId_Steam3, authId, sizeof(authId));
    if(!teamBans.GetArray(authId, times, sizeof(times))) return;
    if(!Jailbreak_TimesLeft(times)) {
        teamBans.Remove(authId);
        return;
    }

    if(event.GetInt("team") == view_as<int>(TFTeam_Blue)) {
        TF2_ChangeClientTeam(clientId, TFTeam_Red);
        TF2_RespawnPlayer(clientId);
        spawnTimes[clientId - 1] = GetTime();
    } else {
        spawnTimes[clientId - 1] = GetTime();
    }
}

public void Event_PlayerDeath(Event event, const char[] _n, bool _db) {
    int clientId = GetClientOfUserId(event.GetInt("userid"));
    UpdateClientTimes(clientId);
}

public void Event_RoundEnd(Event event, const char[] _n, bool _db) {
    for(int i = 1; i < MAXPLAYERS; i++) {
        if(IsFakeClient(i) || !IsPlayerAlive(i)) return;
        UpdateClientTimes(i);
    }
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
    GetClientAuthId(clientId, AuthId_Steam3, authId, sizeof(authId));
    if(!teamBans.GetArray(authId, times, sizeof(times))) return;

    int liveTime = GetTime() - spawnTimes[clientId - 1];
    times[JAILBREAK_TIMES_CURRENT] += liveTime;
    LogMessage("found client %L with live time %d", clientId, liveTime);
    if(!Jailbreak_TimesLeft(times) || forceDelete) {
        // teamban is done with.
        teamBans.Remove(authId);
    } else {
        teamBans.SetArray(authId, times, sizeof(times), true);
    }

    if(forceDelete) spawnTimes[clientId - 1] = -2;
    else spawnTimes[clientId - 1] = -1;

    char[] query = new char[1024];
    Format(query, 1024, JAILBREAK_TEAMBAN_INCREMENT, liveTime, authId);
    LogMessage("issuing query for %L: %s", clientId, query);
    dataStore.Query(OnTeamBanUpdateResult, query);
}

public Action Command_Jailbreak_TeamBan(int client, int args) {
    if(args < 2 || args > 3) {
        PrintToConsole(client, "Usage: sm_teamban <clients> <reason> [time]");
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
    int lengthTime = -1;

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
    GetClientAuthId(client, AuthId_Steam3, adminId, sizeof(adminId));

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
        int newTimes[2];
        int currentTimes[2];
        int clientId = targets[i];
        GetClientAuthId(clientId, AuthId_Steam3, authId, sizeof(authId));

        Format(query, 1024, JAILBREAK_TEAMBAN_CREATE, authId, adminId, GetTime(),
            lengthTime);
        LogMessage("sending query %s to server.", query);
        dataStore.Query(OnTeamBanUpdateResult, query);
        newTimes[JAILBREAK_TIMES_LENGTH] = lengthTime;
        newTimes[JAILBREAK_TIMES_CURRENT] = 0;

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
        GetClientAuthId(targets[i], AuthId_Steam3, authId, sizeof(authId));

        Format(query, 1024, JAILBREAK_TEAMBAN_CLEAR, authId);
        dataStore.Query(OnTeamBanUpdateResult, query);
        LogMessage("sending query %s to server.", query);
        teamBans.Remove(authId);
    }

    CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Teamban_SuccessfulUnBan",
        client, targetName);
    return Plugin_Handled;
}
