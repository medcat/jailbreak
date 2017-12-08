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

        roundTimer = null;
        return Plugin_Stop;
    } else {
        SetHudTextParams(-1.0, 0.10, 5.0, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
        ShowSyncHudTextAll(roundTimerSync, "%T", "Jailbreak_Hud_Timer",
            LANG_SERVER, minuteLeft, secondLeft);
    }

    return Plugin_Continue;
}

void JailbreakRemoveWeapons(int client, bool permanent) {
    TFClassType clientClass = TF2_GetPlayerClass(client);
    TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
    if(clientClass != TFClass_Spy && clientClass != TFClass_Medic)
        TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
    TF2_RemoveWeaponSlot(client, TFWeaponSlot_Grenade);
    TF2_RemoveWeaponSlot(client, TFWeaponSlot_Building);
    TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
    TF2_RemoveWeaponSlot(client, TFWeaponSlot_Item1);
    TF2_RemoveWeaponSlot(client, TFWeaponSlot_Item2);
    EquipPlayerWeapon(client, GetPlayerWeaponSlot(client, 2));
}

void JailbreakRoundHandleRoundType() {
    switch(roundType) {
    case JailbreakRoundType_Normal, JailbreakRoundType_CustomLastRequest: return;
    case JailbreakRoundType_Command: {
        if(freedayCommandTarget == 0)
            ServerCommand("%s", freedayCommand);
        else {
            int client;
            if((client = GetClientFromSerial(freedayCommandTarget)) > 0)
                ClientCommand(client, "%s", freedayCommand);
        }
    }
    case JailbreakRoundType_FreedayGroup: {
        char clientName[MAX_NAME_LENGTH];
        for(int i = 0; i <= MAXPLAYERS; i++) {
            Log("freeday_group: %u, %u", i, nextFreedays[i]);
            if(nextFreedays[i] == 0) { nextFreedays[0] = 0; return; }
            int client = GetClientFromSerial(nextFreedays[i]);
            Log("freeday_group: %L", client);
            if(client <= 0 || TF2_GetClientTeam(client) == TFTeam_Blue) continue;
            Log("freeday_group (proper): %L", client);
            GetClientName(client, clientName, sizeof(clientName));
            CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Freeday_Given", LANG_SERVER, clientName);
            GrantFreeday(client);
        }

        nextFreedays[0] = 0;
    }
    case JailbreakRoundType_FreedayAll:
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Freeday_GivenAll", LANG_SERVER);
    case JailbreakRoundType_GuardMeleeOnly:
        for(int i = 1; i <= MaxClients; i++) {
            if(IsClientInGame(i) && TF2_GetClientTeam(i) == TFTeam_Blue)
                JailbreakRemoveWeapons(i, true);
        }
    }
}

public Action Event_RoundStart(Event event, const char[] eventName, bool dontBroadcast) {
    currentWardenClient = 0;
    wardenAllowed = true;
    roundTimeSeconds = 0;
    Log("round start!");
    PrepareGameConVars();
    StartJailbreakBalance();
    roundTimer = CreateTimer(1.0, Timer_RoundCountDown, 0, TIMER_REPEAT);
    roundType = nextRoundType;
    nextRoundType = JailbreakRoundType_Normal;
    for(int i = 1; i <= MaxClients; i++) {
        if(IsClientInGame(i) && TF2_GetClientTeam(i) == TFTeam_Red)
            JailbreakRemoveWeapons(i, false);
    }
    JailbreakRoundHandleRoundType();
    return Plugin_Continue;
}

public Action Event_RoundEnd(Event event, const char[] eventName, bool dontBroadcast) {
    Log("round ended because of %s", eventName);
    StopJailbreakBalance();
    RemoveAllFreedays();
    if(roundTimer != null) delete roundTimer;
    Log("round end!");
    wardenAllowed = false;
    roundType = JailbreakRoundType_Normal;
    return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, const char[] eventName, bool dontBroadcast) {
    int userId = event.GetInt("userid");
    int client = GetClientOfUserId(userId);
    if(IsCurrentWarden(client)) {
        RemoveWarden();
    } else if(freedayClients[client][0]) {
        // if, somehow, a freeday dies without loosing their freeday, we need
        // to handle that.  maybe a slay kills them? or they suicide?
        freedayClients[client][0] = false;
        KillTimer(freedayClients[client][1], false);
    }

    return Plugin_Continue;
}

public Action Event_PlayerHurt(Event event, const char[] eventName, bool dontBroadcast) {
    int userId = event.GetInt("attacker");
    int client = GetClientOfUserId(userId);
    Log("saw player damage from %L, removing freeday...", client);
    RemoveFreeday(client);
    return Plugin_Continue;
}

public void OnClientDisconnect_Post(int client) {
    if(IsCurrentWarden(client)) {
        RemoveWarden();
    } else if(freedayClients[client][0]) {
        freedayClients[client][0] = false;
        KillTimer(freedayClients[client][1], false);
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
