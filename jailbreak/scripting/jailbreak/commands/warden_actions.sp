public Action Command_Warden_FriendlyFire(int client, int a) {
    bool isAdmin = CheckCommandAccess(client, "sm_jailbreak_warden_friendlyfire_override",
        ADMFLAG_KICK, false);
    if(!IsCurrentWarden(client) && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden",
            client);
    } else if(cvWardenFriendlyFire.BoolValue != true && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotAllowed",
            client);
    } else if(cvGameFriendlyFire.BoolValue == true) {
        cvGameFriendlyFire.SetBool(false, true, false);
        cvGameNoHardCollisions.SetBool(true, true, false);
        cvGameSoftCollisions.SetBool(false, true, false);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_FriendlyFire_Disabled",
            LANG_SERVER);
    } else {
        cvGameFriendlyFire.SetBool(true, true, false);
        cvGameSoftCollisions.SetBool(true, true, false);
        CreateTimer(0.1, Timer_Warden_HardCollisions);

        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_FriendlyFire_Enabled",
            LANG_SERVER);
    }

    return Plugin_Handled;
}

public Action Command_Warden_SoftCollisions(int client, int a) {
    bool isAdmin = CheckCommandAccess(client, "sm_jailbreak_warden_softcollisions_override",
        ADMFLAG_KICK, true);
    if(!IsCurrentWarden(client) && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden",
            client);
    } else if(cvWardenSoftCollisions.BoolValue != true && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotAllowed",
            client);
    } else if(cvGameSoftCollisions.BoolValue == true) {
        cvGameSoftCollisions.SetBool(false, true, false);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_SoftCollisions_Disabled",
            LANG_SERVER);
    } else {
        cvGameSoftCollisions.SetBool(true, true, false);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_SoftCollisions_Enabled",
            LANG_SERVER);
    }

    return Plugin_Handled;
}

public Action Command_Warden_HardCollisions(int client, int a) {
    bool isAdmin = CheckCommandAccess(client, "sm_jailbreak_warden_hardcollisions_override",
        ADMFLAG_KICK, true);
    if(!IsCurrentWarden(client) && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden",
            client);
    } else if(cvWardenHardCollisions.BoolValue != true && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotAllowed",
            client);
    // IsHardCollisionOn() { return (cvGameNoHardCollisions.BoolValue == false); }
    } else if(cvGameNoHardCollisions.BoolValue == true) {
        cvGameSoftCollisions.SetBool(true, true, false);
        CreateTimer(0.1, Timer_Warden_HardCollisions);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_HardCollisions_Enabled",
            client);
    } else {
        cvGameNoHardCollisions.SetBool(true, true, false);
        cvGameSoftCollisions.SetBool(false, true, false);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_HardCollisions_Disabled",
            client);
    }

    return Plugin_Handled;
}

public Action Timer_Warden_HardCollisions(Handle timer) {
    cvGameNoHardCollisions.SetBool(false, true, false);
}
