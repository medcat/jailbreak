int currentWardenClient = 0;
Handle wardenDeclareSync = null;

void MakeClientWarden(int client) {
    currentWardenClient = client;
    char name[32];
    GetClientName(client, name, sizeof(name));
    CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_GiveWarden_Success");
    CPrintToChatAll(client, JAILBREAK_REPLY, "Jailbreak_NewWarden", name);
    SetHudTextParams(0.75, -1.0, 5.0, 255, 255, 255, 125, 0, 0, 0, 0);
    ShowSyncHudTextAll(wardenDeclareSync, "%T", "Jailbreak_Hud_NewWarden");
}

void RemoveWarden() {
    currentWardenClient = 0;
    CPrintToChatAll(client, JAILBREAK_REPLY, "Jailbreak_UnWarden_WardenRemoved");
    SetHudTextParams(0.75, -1.0, 5.0, 255, 255, 255, 125, 0, 0, 0, 0);
    ShowSyncHudTextAll(wardenDeclareSync, "%T", "Jailbreak_Hud_NoWarden");
}

public Action Command_GiveWarden(int client, int _) {
    if(client == 0) {
        // why is the console trying to get warden?
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_GiveWarden_Console");
    } else if(GameRules_GetRoundState() != RoundState_RoundRunning) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_GiveWarden_OutOfRound");
    } else if(TF2_GetClientTeam(client) != TFTeam_Blue) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_GiveWarden_MustBlue");
    } else if(currentWardenClient == 0) {
        MakeClientWarden(client);
    } else {
        return Command_CheckWarden(client, _);
    }

    return Plugin_Handled;
}

public Action Command_UnWarden(int client, int _) {
    if(client != currentWardenClient) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_UnWarden_NotWarden");
    } else {
        RemoveWarden();
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_UnWarden_Success");
    }

    return Plugin_Handled;
}

public Action Command_CheckWarden(int client, int _) {
    if(currentWardenClient == 0) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_CheckWarden_None");
    } else {
        char name[32];
        GetClientName(currentWardenClient, name, sizeof(name));
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_CheckWarden_Found");
    }

    return Plugin_Handled;
}

public Action Command_Admin_ForceWarden(int client, int args) {
    if(args != 1) {
        PrintToConsole(client, "Usage: sm_forcewarden <client>");
        return Plugin_Handled;
    }

    char target[32];
    GetCmdArg(1, target, sizeof(target));
    int targetClient = FindTarget(client, target, true, true);

    if(targetClient < 1) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Admin_ForceWarden_NotFound");
    } else {
        MakeClientWarden(targetClient);
    }

    return Plugin_Handled;
}

public Action Command_Admin_RemoveWarden(int client, int args) {
    if(currentWardenClient == 0) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Admin_RemoveWarden_None");
    } else {
        RemoveWarden();
    }

    return Plugin_Handled;
}
