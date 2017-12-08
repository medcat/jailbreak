stock bool IsCurrentWarden() {
    return currentWardenClient != 0 &&
        GetClientFromSerial(currentWardenClient) != 0 &&
        wardenAllowed;
}

void MakeClientWarden(int client) {
    currentWardenClient = GetClientSerial(client);
    char cName[32];
    GetClientName(client, cName, sizeof(cName));
    CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_GiveWarden_Success",
        client);
    CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_NewWarden", LANG_SERVER, cName);
    SetHudTextParams(-1.0, 0.75, 5.0, 255, 255, 255, 125, 0, 0.0, 0.0, 0.0);
    ShowSyncHudTextAll(wardenDeclareSync, "%T", "Jailbreak_Hud_NewWarden",
        LANG_SERVER, cName);
}

void RemoveWarden() {
    currentWardenClient = 0;
    CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_UnWarden_WardenRemoved",
        LANG_SERVER);
    SetHudTextParams(-1.0, 0.75, 5.0, 255, 255, 255, 125, 0, 0.0, 0.0, 0.0);
    ShowSyncHudTextAll(wardenDeclareSync, "%T", "Jailbreak_Hud_NoWarden",
        LANG_SERVER);
}

public Action Command_GiveWarden(int client, int a) {
    if(client == 0) {
        // why is the console trying to get warden?
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_GiveWarden_Console",
            client);
    } else if(TF2_GetClientTeam(client) != TFTeam_Blue) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_GiveWarden_MustBlue",
            client);
    } else if(!IsCurrentWarden()) {
        MakeClientWarden(client);
    } else {
        return Command_CheckWarden(client, 0);
    }

    return Plugin_Handled;
}

public Action Command_UnWarden(int client, int a) {
    if(client != GetClientFromSerial(currentWardenClient) || !wardenAllowed) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_UnWarden_NotWarden",
            client);
    } else {
        RemoveWarden();
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_UnWarden_Success",
            client);
    }

    return Plugin_Handled;
}

public Action Command_CheckWarden(int client, int a) {
    if(!wardenAllowed) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_CheckWarden_OutOfRound",
            client);
    } else if(!IsCurrentWarden()) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_CheckWarden_None",
            client);
    } else {
        char cName[32];
        GetClientName(GetClientFromSerial(currentWardenClient), cName, sizeof(cName));
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_CheckWarden_Found",
            client, cName);
    }

    return Plugin_Handled;
}

public Action Command_Admin_ForceWarden(int client, int args) {
    if(args != 1) {
        PrintToConsole(client, "Usage: sm_forcewarden <client>");
        return Plugin_Handled;
    }

    char target[MAX_NAME_LENGTH];
    GetCmdArg(1, target, sizeof(target));
    int targetClient = FindTarget(client, target, true, true);

    if(targetClient < 1) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Admin_ForceWarden_NotFound",
            client);
    } else if(!wardenAllowed) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Admin_ForceWarden_OutOfRound",
            client);
    } else {
        MakeClientWarden(targetClient);
    }

    return Plugin_Handled;
}

public Action Command_Admin_RemoveWarden(int client, int args) {
    if(!IsCurrentWarden()) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Admin_RemoveWarden_None",
            client);
    } else {
        RemoveWarden();
    }

    return Plugin_Handled;
}
