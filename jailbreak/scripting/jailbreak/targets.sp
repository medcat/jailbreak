void AddTargetFilters() {
    AddMultiTargetFilter("@warden", Target_Warden, "the warden", false);
    AddMultiTargetFilter("@!warden", Target_NotWarden, "everyone", false);
    AddMultiTargetFilter("@freedays", Target_Freeday, "the freedays", false);
    AddMultiTargetFilter("@!freedays", Target_NotFreeday,
        "all but the freedays", false);
}

public bool Target_Warden(const char[] pattern, Handle clients) {
    if(IsWardenActive())
        PushArrayCell(clients, GetClientFromSerial(currentWardenClient));
    return true;
}

public bool Target_NotWarden(const char[] pattern, Handle clients) {
    for(int i = 0; i < MaxClients; i++) {
        if(!IsCurrentWarden(i))
            PushArrayCell(clients, i);
    }

    return true;
}

public bool Target_Freeday(const char[] pattern, Handle clients) {
    for(int i = 0; i < MAXPLAYERS + 1; i++) {
        if(IsPlayerAlive(i) && freedayClients[i][0])
            PushArrayCell(clients, i);
    }
}

public bool Target_NotFreeday(const char[] pattern, Handle clients) {
    for(int i = 0; i < MAXPLAYERS + 1; i++) {
        if(!(IsPlayerAlive(i) && freedayClients[i][0]))
            PushArrayCell(clients, i);
    }
}
