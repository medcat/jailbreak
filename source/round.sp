Handle roundTimer = null;
Handle roundTimerSync = null;
int roundTimeSeconds = 0;

Action Timer_RoundCountDown() {
    roundTimeSeconds += 1;
    int roundTime = cvRoundTime.IntValue;
    int timeLeft = roundTime - roundTimeSeconds;
    int minuteLeft = timeLeft / 60;
    int secondLeft = timeLeft % 60;

    SetHudTextParams(0.25, -1.0, 1.0, 255, 255, 255, 125, 0, 0, 0, 0);
    ShowSyncHudTextAll(roundTimerSync, "%T", "Jailbreak_Hud_Timer",
        minuteLeft, secondLeft);

    if(timeLeft <= 0) {
        for(int i = 1; i <= MaxClients; i++) {
            if(!IsClientConnected(i) || !IsPlayerAlive(i) ||
                TF2_GetClientTeam(i) != TFTeam_Red) continue;
            ForcePlayerSuicide(i);
        }

        return Plugin_Stop;
    }

    return Plugin_Continue;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
    currentWardenClient = 0;
    CreateTimer(GetTickInterval(), Timer_RoundCountDown, 0,
        TIMER_REPEAT);

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
