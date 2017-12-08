// beamModel = PrecacheModel("materials/sprites/laser.vmt")
// haloModel = PrecacheModel("materials/sprites/halo01.vmt")
// redTeamColor = {0xff, 0x40, 0x40, 0xff};
// blueTeamColor = {0x99, 0xcc, 0xff, 0xff};

void GrantFreeday(int client) {
    /*TF2_AddCondition(client, TFCond_SpawnOutline, TFCondDuration_Infinite, 0);*/
    SetEntProp(client, "m_bGlowEnabled", 1);
    TF2_AddCondition(client, TFCond_UberchargedHidden, TFCondDuration_Infinite, 0);
    client = GetClientSerial(client);
    Handle timer = CreateTimer(2.0 Timer_FreedayTrail, client,
        TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    TriggerTimer(timer, true);
    freedayClients[client] = timer;
}

public Action Timer_FreedayTrail(Handle timer, int client) {
    int color[4] = {0};
    switch(TF2_GetClientTeam(client)) {
    case TFTeam_Red: color = {0xff, 0x40, 0x40, 0xff};
    case TFTeam_Blue: color = {0x99, 0xcc, 0xff, 0xff};
    }
    TE_SetupBeamFollow(GetClientFromSerial(client),
        beamModel, haloModel, 2.0, 5.0, 0.0, 2.0, color);
    TE_SendToAll(0.0);
}

void RemoveFreeday(int client) {
    SetEntProp(client, "m_bGlowEnabled", 0);
    /*TF2_RemoveCondition(client, TFCond_SpawnOutline);*/
    TF2_RemoveCondition(client, TFCond_UberchagedHidden);
    if(freedayClients[client] != null) {
        CloseHandle(freedayClients[client]);
        freedayClients[client] = null;
    }
}

public Action Command_Freeday_ForceFreeday(int client, int args) {
    if(args != 1) {
        PrintToConsole(client, "Usage: sm_forcefreeday <client>");
        return Plugin_Handled;
    }

    char targetString[MAX_NAME_LENGTH];
    GetCmdArg(1, targetString, sizeof(targetString));
    int target = FindTarget(client, targetString, true);

    if(target < 1) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Admin_ForceFreeday_NotFound");
    } else if(freedayClients[client] != null) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Admin_ForceFreeday_Already");
    } else {
        GrantFreeday(client);
    }

    return Plugin_Handled;
}

public Action Command_Freeday_RevokeFreeday(int client, int args) {
    if(args != 1) {
        PrintToConsole(client, "Usage: sm_forcefreeday <client>");
        return Plugin_Handled;
    }

    char targetString[MAX_NAME_LENGTH];
    GetCmdArg(1, targetString, sizeof(targetString));
    int target = FindTarget(client, targetString, true);

    if(target < 1 || freedayClients[client] == null) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Admin_ForceFreeday_NotFound");
    } else {
        RemoveFreeday(client);
    }

    return Plugin_Handled;
}
