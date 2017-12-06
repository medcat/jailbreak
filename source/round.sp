#include "./round/entities.sp"

public void Event_RoundStart(Event event, const char[] eventName, bool dontBroadcast) {
    currentWardenClient = 0;
    PrepareGameConVars();
}

public Action TF2_CalcIsAttackCritical(int client, int _b, char[] _n, bool &result) {
    TFTeam team = TF2_GetClientTeam(client);

    switch(cvCriticals.IntValue) {
    case 1:
        if(team == TFTeam_Red) { result = true; return Plugin_Handled; }
    case 2:
        if(team == TFTeam_Blue) { result = true; return Plugin_Handled; }
    case 3: {
        result = true;
        return Plugin_Handled;
    }
    case 4:
        if(GetClientFromSerial(currentWardenClient) == client) { result = true; return Plugin_Handled; }
    }

    return Plugin_Continue;
}
