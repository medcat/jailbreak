public Action Command_Warden_FriendlyFire(int client, int a) {
    if(GetClientFromSerial(currentWardenClient) != client) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden");
    } else if(cvWardenFriendlyFire.IntValue != 1) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotAllowed");
    } else if(cvGameFriendlyFire.IntValue == 1) {
        cvGameFriendlyFire.SetInt(false, true, false);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_FriendlyFire_Disabled");
    } else {
        cvGameFriendlyFire.SetInt(true, true, false);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_FriendlyFire_Enabled");
    }

    return Plugin_Handled;
}

public Action Command_Warden_SoftCollisions(int client, int a) {
    if(GetClientFromSerial(currentWardenClient) != client) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden");
    } else if(cvWardenSoftCollisions.IntValue != 1) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotAllowed");
    } else if(cvGameSoftCollisions.IntValue == 1) {
        cvGameSoftCollisions.SetInt(false, true, false);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_SoftCollisions_Disabled");
    } else {
        cvGameSoftCollisions.SetInt(true, true, false);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_SoftCollisions_Enabled");
    }

    return Plugin_Handled;
}

public Action Command_Warden_HardCollisions(int client, int a) {
    if(GetClientFromSerial(currentWardenClient) != client) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden");
    } else if(cvWardenHardCollisions.IntValue != 1) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotAllowed");
    } else if(cvGameNoHardCollisions.IntValue == 1) {
        cvGameNoHardCollisions.SetBool(false, true, true);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_HardCollisions_Enabled");
    } else {
        cvGameNoHardCollisions.SetBool(true, true, false);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_HardCollisions_Disabled");
    }

    return Plugin_Handled;
}
