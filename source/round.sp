#include "source/round/entities.sp"
#include "source/round/balance.sp"

Action Timer_RoundCountDown(Handle _t) {
    roundTimeSeconds += 1;
    int roundTime = cvRoundTime.IntValue;
    int timeLeft = roundTime - roundTimeSeconds;
    int minuteLeft = timeLeft / 60;
    int secondLeft = timeLeft % 60;

    SetHudTextParams(-1.0, 0.10, 5.0, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
    ShowSyncHudTextAll(roundTimerSync, "%T", "Jailbreak_Hud_Timer",
        LANG_SERVER, minuteLeft, secondLeft);

    if(timeLeft <= 0) {
        for(int i = 1; i <= MaxClients; i++) {
            if(!IsClientConnected(i) || !IsPlayerAlive(i) ||
                TF2_GetClientTeam(i) != TFTeam_Red) continue;
            ForcePlayerSuicide(i);
        }

        return Plugin_Stop;
    } else {
        SetHudTextParams(-1.0, 0.10, 5.0, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
        ShowSyncHudTextAll(roundTimerSync, "%T", "Jailbreak_Hud_Timer",
            LANG_SERVER, minuteLeft, secondLeft);
    }

    return Plugin_Continue;
}

public Action Event_RoundStart(Event event, const char[] eventName, bool dontBroadcast) {
    currentWardenClient = 0;
    wardenAllowed = true;
    roundTimeSeconds = 0;
    Log("round start!");
    PrepareGameConVars();
    StartJailbreakBalance();
    roundTimer = CreateTimer(1.0, Timer_RoundCountDown, 0, TIMER_REPEAT);
    return Plugin_Continue;
}

public Action Event_RoundEnd(Event event, const char[] eventName, bool dontBroadcast) {
    Log("round ended because of %s", eventName);
    StopJailbreakBalance();
    RemoveAllFreedays();
    CloseHandle(roundTimer);
    Log("round end!");
    wardenAllowed = false;
    return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, const char[] eventName, bool dontBroadcast) {
    int userId = event.GetInt("userid");
    int client = GetClientOfUserId(userId);
    if(IsCurrentWarden() && GetClientFromSerial(currentWardenClient) == client) {
        RemoveWarden();
    } else if(freedayClients[client][0]) {
        // if, somehow, a freeday dies without loosing their freeday, we need
        // to handle that.  maybe a slay kills them? or they suicide?
        freedayClients[client][0] = false;
        CloseHandle(freedayClients[client][1]);
    }

    return Plugin_Continue;
}

public Action Event_PlayerHurt(Event event, const char[] eventName, bool dontBroadcast) {
    int userId = event.GetInt("userid");
    int client = GetClientOfUserId(userId);
    RemoveFreeday(client);
}

public void OnClientDisconnect_Post(int client) {
    if(IsCurrentWarden() && GetClientFromSerial(currentWardenClient) == client) {
        RemoveWarden();
    } else if(freedayClients[client][0]) {
        freedayClients[client][0] = false;
        CloseHandle(freedayClients[client][1]);
    }
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
