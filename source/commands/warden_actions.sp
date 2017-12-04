// int currentWardenClient = 0;

public Action Command_Warden_FriendlyFire(int client, int _) {
    if(currentWardenClient != client) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden");
    } else if(cvWardenFriendlyFire.IntValue != 1) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotAllowed");
    } else if(cvFriendlyFire.IntValue == 1) {
        cvFriendlyFire.SetInt(0, 1, 0);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_FriendlyFire_Disabled");
    } else {
        cvFriendlyFire.SetInt(1, 1, 0);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_FriendlyFire_Enabled");
    }

    return Plugin_Handled;
}

public Action Command_Warden_SoftCollisions(int client, int _) {
    if(currentWardenClient != client) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden");
    } else if(cvWardenSoftCollisions.IntValue != 1) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotAllowed");
    } else if(cvSoftCollisions.IntValue == 1) {
        cvSoftCollisions.SetInt(0, 1, 0);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_SoftCollisions_Disabled");
    } else {
        cvSoftCollisions.SetInt(1, 1, 0);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_SoftCollisions_Enabled");
    }

    return Plugin_Handled;
}

public Action Command_Warden_HardCollisions(int client, int _) {
    if(currentWardenClient != client) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden");
    } else if(cvWardenSoftCollisions.IntValue != 1) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotAllowed");
    } else if(cvHardCollisions.IntValue == 1) {
        cvHardCollisions.SetInt(0, 1, 0);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_HardCollisions_Disabled");
    } else {
        cvHardCollisions.SetInt(1, 1, 0);
        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_Warden_HardCollisions_Enabled");
    }

    return Plugin_Handled;
}
