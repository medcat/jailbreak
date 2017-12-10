void CreateNatives() {
    CreateNative("Jailbreak_GetWardenMenu", Native_JailbreakGetWardenMenu);
    CreateNative("Jailbreak_GetLastRequestMenu", Native_JailbreakGetLastRequestMenu);
    CreateNative("Jailbreak_GiveFreeday", Native_JailbreakGiveFreeday);
    CreateNative("Jailbreak_RemoveFreeday", Native_JailbreakRemoveFreeday);
    CreateNative("Jailbreak_AddFreeday", Native_JailbreakAddFreeday);
    CreateNative("Jailbreak_IsClientFreeday", Native_JailbreakIsFreeday);
    CreateNative("Jailbreak_GetWarden", Native_JailbreakGetWarden);
    CreateNative("Jailbreak_SetWarden", Native_JailbreakSetWarden);
    CreateNative("Jailbreak_ClearWarden", Native_JailbreakClearWarden);
    CreateNative("Jailbreak_GetRoundType", Native_JailbreakGetRoundType);
    CreateNative("Jailbreak_GetNextRoundType", Native_JailbreakGetNextRoundType);
    CreateNative("Jailbreak_SetNextRoundType", Native_JailbreakSetNextRoundType);
}

public int Native_JailbreakGetWardenMenu(Handle plugin, int numParams) {
    return view_as<int>(wardenMenu);
}

public int Native_JailbreakGetLastRequestMenu(Handle plugin, int numParams) {
    return view_as<int>(lastRequestMenu);
}

public int Native_JailbreakGiveFreeday(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    if(!IsClientInGame(client) || !IsPlayerAlive(client))
        ThrowNativeError(101, "Invalid client given (must be alive and in game)!");
    GrantFreeday(client);
    return true;
}

public int Native_JailbreakRemoveFreeday(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    if(!IsClientInGame(client))
        ThrowNativeError(101, "Invalid client given (must be in game)!");
    RevokeFreeday(client);
    return true;
}

public int Native_JailbreakIsFreeday(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    if(!IsClientInGame(client) || !IsPlayerAlive(client))
        ThrowNativeError(101, "Invalid client given (must be alive and in game)!");
    return freedayClients[client][0];
}

public int Native_JailbreakAddFreeday(Handle plugin, int numParams) {
    int target;
    int client = GetNativeCell(1);
    if(!IsClientInGame(client))
        ThrowNativeError(101, "Invalid client given (must be in game)!");

    target = GetClientSerial(client);

    for(int i = 0; i < MAXPLAYERS + 1; i++) {
        if(nextFreedays[i] != 0) continue;
        if(nextFreedays[i] == target) return false;
        nextFreedays[i] = target;
        nextFreedays[i + 1] = 0;
        break;
    }

    return true;
}

public int Native_JailbreakGetWarden(Handle plugin, int numParams) {
    return GetClientFromSerial(currentWardenClient);
}

public int Native_JailbreakSetWarden(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    if(!IsClientInGame(client) || !IsPlayerAlive(client))
        ThrowNativeError(101, "Invalid client given (must be alive and in game)!");
    else if(!wardenAllowed)
        ThrowNativeError(102, "Wardens cannot be set out-of-round!");
    else if(TF2_GetClientTeam(client) != TFTeam_Blue)
        ThrowNativeError(103, "Wardens must be on blue team!");
    RemoveWarden();
    if(currentWardenClient == 0) MakeClientWarden(client);
    return (currentWardenClient == GetClientSerial(client));
}

public int Native_JailbreakClearWarden(Handle plugin, int numParams) {
    if(!wardenAllowed) return false;
    RemoveWarden();
    return (currentWardenClient == 0);
}

public int Native_JailbreakGetRoundType(Handle plugin, int numParams) {
    return view_as<int>(roundType);
}

public int Native_JailbreakGetNextRoundType(Handle plugin, int numParams) {
    return view_as<int>(nextRoundType);
}

public int Native_JailbreakSetNextRoundType(Handle plugin, int numParams) {
    int rType = GetNativeCell(1);
    if(rType > view_as<int>(JailbreakRoundType_CustomLastRequest) ||
        rType < view_as<int>(JailbreakRoundType_Normal))
        ThrowNativeError(104, "Invalid round type given!");
    nextRoundType = view_as<JailbreakRoundType>(rType);
    return true;
}
