// beamModel = PrecacheModel("materials/sprites/laser.vmt")
// haloModel = PrecacheModel("materials/sprites/halo01.vmt")
// redTeamColor = {0xff, 0x40, 0x40, 0xff};
// blueTeamColor = {0x99, 0xcc, 0xff, 0xff};

void GrantFreeday(int clientIndex) {
    SetEntProp(clientIndex, Prop_Send, "m_bGlowEnabled", 1);
    TF2_AddCondition(clientIndex, TFCond_UberchargedHidden, TFCondDuration_Infinite, 0);
    int client = GetClientSerial(clientIndex);
    float pos[3];
    GetClientAbsOrigin(clientIndex, pos);
    freedayClients[clientIndex][0] = true;
    freedayClients[clientIndex][2] = pos[0];
    freedayClients[clientIndex][3] = pos[1];
    freedayClients[clientIndex][4] = pos[2];
    Handle timer = CreateTimer(GetTickInterval() * 2, Timer_FreedayTrail,
        client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    freedayClients[clientIndex][1] = timer;
    TriggerTimer(timer, true);
}

public Action Timer_FreedayTrail(Handle timer, int client) {
    int color[4] = {0};
    float oldPos[3];
    float newPos[3];

    int clientIndex = GetClientFromSerial(client);
    if(clientIndex < 1) return Plugin_Stop;

    oldPos[0] = freedayClients[clientIndex][2];
    oldPos[1] = freedayClients[clientIndex][3];
    oldPos[2] = freedayClients[clientIndex][4];
    GetClientAbsOrigin(clientIndex, newPos);

    switch(TF2_GetClientTeam(clientIndex)) {
    case TFTeam_Red: color = {0xff, 0x40, 0x40, 0xff};
    case TFTeam_Blue: color = {0x99, 0xcc, 0xff, 0xff};
    default: color = {0xcc, 0xcc, 0xcc, 0xff};
    }


    TE_SetupBeamPoints(oldPos, newPos, beamModel, haloModel, 0, 0, 5.0, 5.0,
        15.0, 5, 0.0, color, 30);
    TE_SendToAll(0.0);

    freedayClients[clientIndex][2] = newPos[0];
    freedayClients[clientIndex][3] = newPos[1];
    freedayClients[clientIndex][4] = newPos[2];
    return Plugin_Continue;
}

void RemoveFreeday(int client) {
    if(freedayClients[client][0]) {
        freedayClients[client][0] = false;
        SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
        char name[MAX_NAME_LENGTH];
        TF2_RemoveCondition(client, TFCond_UberchargedHidden);
        CloseHandle(freedayClients[client][0]);
        GetClientName(client, name, sizeof(name));
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Freeday_Removed",
            LANG_SERVER, name);
    }
}

void InitializeFreeday() {
    for(int i = 0; i < MAXPLAYERS + 1; i++) {
        freedayClients[i][0] = false;
        freedayClients[i][1] = 0;
        freedayClients[i][2] = 0.0;
        freedayClients[i][3] = 0.0;
        freedayClients[i][4] = 0.0;
    }
}

void RemoveAllFreedays() {
    for(int i = 0; i < MAXPLAYERS + 1; i++) {
        if(freedayClients[i][0]) {
            RemoveFreeday(i);
        }
    }
}

public Action Command_Admin_ForceFreeday(int client, int args) {
    if(args != 1) {
        PrintToConsole(client, "Usage: sm_forcefreeday <client>");
        return Plugin_Handled;
    }

    char targetString[MAX_NAME_LENGTH];
    GetCmdArg(1, targetString, sizeof(targetString));
    int target = FindTarget(client, targetString, false);

    if(target < 1) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Admin_ForceFreeday_NotFound",
            client);
    } else if(freedayClients[target][0]) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Admin_ForceFreeday_Already",
            client);
    } else {
        GrantFreeday(target);
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Admin_ForceFreeday_Success",
            client);
        CPrintToChat(target, JAILBREAK_REPLY, "Jailbreak_Admin_ForceFreeday_Given",
            target);
    }

    return Plugin_Handled;
}

public Action Command_Admin_RevokeFreeday(int client, int args) {
    if(args != 1) {
        PrintToConsole(client, "Usage: sm_revokefreeday <client>");
        return Plugin_Handled;
    }

    char targetString[MAX_NAME_LENGTH];
    GetCmdArg(1, targetString, sizeof(targetString));
    int target = FindTarget(client, targetString, false);

    if(target < 1 || freedayClients[target][0] == false) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Admin_RevokeFreeday_NotFound",
            client);
    } else {
        RemoveFreeday(target);
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Admin_RevokeFreeday_Success",
            client);
        CPrintToChat(target, JAILBREAK_REPLY, "Jailbreak_Admin_RevokeFreeday_Taken");
    }

    return Plugin_Handled;
}
