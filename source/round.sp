public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
    currentWardenClient = 0;

    cvFriendlyFire.SetInt(0, 1, 0);
    cvNoHardCollisions.setInt(1, 1, 0);
    cvSoftCollisions.setInt(0, 1, 0);
}

public Action TF2_CalcIsAttackCritical(int client, int _, char[] _n, bool &result) {
    TFTeam team = TF2_GetClientTeam(client);

    switch(cvCriticals.IntValue) {
    case 1:
        if(team == TFTeam_Red) { result = true; return Plugin_Handled; }
        break;
    case 2:
        if(team == TFTeam_Blue) { result = true; return Plugin_Handled; }
        break;
    case 3:
        result = true;
        return Plugin_Handled;
    case 4:
        if(currentWardenClient == client) { result = true; return Plugin_Handled; }
        break;
    }

    return Plugin_Continue;
}
