#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
#include <jailbreak>
#include <smlib/entities>

public Plugin myinfo =
{
    name = "Jailbreak Team Bans",
    author = "Jeremy Rodi <me@medcat.me>",
    description = "Team banning for jailbreak",
    version = "0.2.1",
    url = "https://github.com/medcat/jailbreak"
};

Database dataStore = null;
StringMap teamBans = null;
int[] spawnTimes = new int[MAXPLAYERS];

#define JAILBREAK_TEAMBAN_LOOKUP "SELECT * FROM sm_jailbreak_teambans WHERE current < length;"
#define JAILBREAK_TEAMBAN_INCREMENT "UPDATE SET current = current + %u WHERE auth = '%s';"
#define JAILBREAK_TEAMBAN_DELETE "DELETE FROM sm_jailbreak_teambans WHERE auth = '%s';"
// sm_jailbreak_teambans: id: Int, auth: String, start: Int, length: Int, current: Int
#define JAILBREAK_TEAMBAN_ID_FIELD 0
#define JAILBREAK_TEAMBAN_AUTH_FIELD 1
#define JAILBREAK_TEAMBAN_START_FIELD 2
#define JAILBREAK_TEAMBAN_LENGTH_FIELD 3
#define JAILBREAK_TEAMBAN_CURRENT_FIELD 4


public void OnPluginStart() {
    LoadTranslations("jailbreak_teamban.phrases");
}

public void OnMapStart() {
    for(int i = 0; i < MAXPLAYERS; i++) { spawnTimes[i] = -1; }
    Database.Connect(OnSqlConnect, "jailbreak");
}

public void OnSqlConnect(Database db, const char[] error, any data) {
    if(db == null) {
        ThrowError("Could not connect to database for reason '%s'!", error);
        return;
    }

    dataStore = db;
    LookupTeamBanList();
}

public Action OnJailbreakRoundEnd(JailbreakRoundType _t) {
    if(dataStore != null && teamBans != null)
        LookupTeamBanList();

    return Plugin_Continue;
}

void LookupTeamBanList() {
    dataStore.Query(OnTeamBanListResult, JAILBREAK_TEAMBAN_LOOKUP, _,
        DBPrio_Low);
}

public void OnTeamBanListResult(Database _db, DBResultSet result, const char[] error, any data) {
    StringMap newTeamBans = new StringMap();
    if(result == null) {
        LogError("While attempting to retrieve team ban list, we encountered an error.");
        LogError("The error was: '%s'", error);
        return;
    }

    while(result.FetchRow()) {
        char authId[64];
        int times[3];
        result.FetchString(JAILBREAK_TEAMBAN_AUTH_FIELD, authId, sizeof(authId));
        times[0] = result.FetchInt(JAILBREAK_TEAMBAN_START_FIELD);
        times[1] = result.FetchInt(JAILBREAK_TEAMBAN_LENGTH_FIELD);
        times[2] = result.FetchInt(JAILBREAK_TEAMBAN_CURRENT_FIELD);

        if(times[2] > times[1]) continue;

        newTeamBans.SetArray(authId, times, 3, true);
    }

    if(teamBans != null) delete teamBans;
    teamBans = newTeamBans;
}

public void OnTeamBanUpdateResult(Database _db, DBResultSet result, const char[] error, any data) {
    if(result == null) {
        LogError("While attempting to update the teamban status of a player, we encountered an error.");
        LogError("The error was: '%s'", error);
    }
}

public void Event_PlayerSpawn(Event event, const char[] _n, bool _db) {
    char authId[64];
    if(teamBans == null) return;
    int clientId = GetClientOfUserId(event.GetInt("userid"));
    GetClientOfUserId(clientId, AuthId_Steam3, authId, sizeof(authId));
    if(!teamBans.GetArray(authId, "", 0)) return;
    if(event.GetInt("team") == view_as<int>(TFTeam_Blue)) {
        TF2_ChangeClientTeam(clientId, TFTeam_Red);
        TF2_RespawnPlayer(clientId);
        spawnTimes[clientId - 1] = GetTime();
    } else {
        spawnTimes[clientId - 1] = GetTime();
    }
}

public void Event_PlayerDeath(Event event, const char [] _n, bool _db) {
    int clientId = GetClientOfUserId(event.GetInt("userid"));
    OnClientDisconnect(clientId);
}

public void OnClientDisconnect(int clientId) {
    char query[128];
    char authId[64];
    int spawnTime, timeDifference;
    if(teamBans == null) return;
    GetClientOfUserId(clientId, AuthId_Steam3, authId, sizeof(authId));
    if(!teamBans.GetArray(authId, "", 0)) return;
    spawnTime = spawnTimes[clientId - 1];
    spawnTimes[clientId - 1] = -1;
    if(spawnTime != -1) return;
    timeDifference = GetTime() - spawnTime;
    FormatEx(query, sizeof(query), JAILBREAK_TEAMBAN_INCREMENT,
        timeDifference, authId);
    dataStore.Query(OnTeamBanUpdateResult, query, _, DBPrio_Normal);
}
