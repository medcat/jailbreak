public Action Command_Warden_FriendlyFire(int client, int a) {
    bool isAdmin = CheckCommandAccess(client, "sm_jailbreak_warden_friendlyfire",
        ADMFLAG_KICK, false);
    if(!IsCurrentWarden(client) && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden",
            client);
    } else if(cvWardenFriendlyFire.BoolValue != true && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotAllowed",
            client);
    } else if(cvGameFriendlyFire.BoolValue == true) {
        cvGameFriendlyFire.SetBool(false, true, true);
        cvGameNoHardCollisions.SetBool(true, true, true);
        cvGameSoftCollisions.SetBool(false, true, true);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_FriendlyFire_Disabled",
            LANG_SERVER);
    } else {
        cvGameFriendlyFire.SetBool(true, true, true);
        cvGameSoftCollisions.SetBool(true, true, true);
        CreateTimer(0.1, Timer_Warden_HardCollisions);

        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_FriendlyFire_Enabled",
            LANG_SERVER);
    }

    return Plugin_Handled;
}

public Action Command_Warden_SoftCollisions(int client, int a) {
    bool isAdmin = CheckCommandAccess(client, "sm_jailbreak_warden_softcollisions",
        ADMFLAG_KICK, false);
    if(!IsCurrentWarden(client) && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden",
            client);
    } else if(cvWardenSoftCollisions.BoolValue != true && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotAllowed",
            client);
    } else if(cvGameSoftCollisions.BoolValue == true) {
        cvGameSoftCollisions.SetBool(false, true, true);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_SoftCollisions_Disabled",
            LANG_SERVER);
    } else {
        cvGameSoftCollisions.SetBool(true, true, true);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_SoftCollisions_Enabled",
            LANG_SERVER);
    }

    return Plugin_Handled;
}

public Action Command_Warden_HardCollisions(int client, int a) {
    bool isAdmin = CheckCommandAccess(client, "sm_jailbreak_warden_hardcollisions",
        ADMFLAG_KICK, false);
    if(!IsCurrentWarden(client) && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden",
            client);
    } else if(cvWardenHardCollisions.BoolValue != true && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotAllowed",
            client);
    } else if(cvGameNoHardCollisions.BoolValue == true) {
        cvGameNoHardCollisions.SetBool(false, true, true);
        cvGameSoftCollisions.SetBool(true, true, true);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_HardCollisions_Enabled",
            client);
    } else {
        cvGameSoftCollisions.SetBool(true, true, true);
        CreateTimer(0.1, Timer_Warden_HardCollisions);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_HardCollisions_Disabled",
            client);
    }

    return Plugin_Handled;
}

public Action Timer_Warden_HardCollisions(Handle timer) {
    cvGameNoHardCollisions.SetBool(false, true, false);
}
