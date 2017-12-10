stock void GrantLastRequest(int client) {
    lastRequestMenu.Display(client, MENU_TIME_FOREVER);
}

public Action Command_Warden_LastRequest(int client, int args) {
    bool isAdmin = CheckCommandAccess(client, "sm_jailbreak_warden_lastrequest",
        ADMFLAG_KICK, false);
    if(!IsCurrentWarden(client) && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden",
            client);
    }

    if(args != 1) {
        PrintToConsole(client, "Usage: sm_givelr <client>");
        return Plugin_Handled;
    }

    char target[MAX_NAME_LENGTH];
    GetCmdArg(1, target, sizeof(target));
    int targetClient = FindTarget(client, target, true, true);

    if(targetClient < 1) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_LastRequest_NotFound",
            client);
    } else {
        GrantLastRequest(targetClient);
    }

    return Plugin_Handled;

}

void BuildLastRequestMenu() {
    lastRequestMenu = new Menu(Menu_LastRequest);
    lastRequests = new KeyValues("Last_Requests");
    char path[PLATFORM_MAX_PATH];
    char sectionName[64];
    char translateKey[64];
    char itemName[64];

    lastRequestMenu.SetTitle("%T", "Jailbreak_LastRequest_Title", LANG_SERVER);
    BuildPath(Path_SM, path, sizeof(path), "configs/jailbreak/last_requests.cfg");
    if(!lastRequests.ImportFromFile(path)) ThrowError("Could not find last requests file!");
    if(!lastRequests.GotoFirstSubKey()) { delete lastRequests; return; }

    do {
        lastRequests.GetSectionName(sectionName, sizeof(sectionName));

        Format(translateKey, sizeof(translateKey), "Jailbreak_LastRequest_%s",
            sectionName);
        Format(itemName, sizeof(itemName), "%T", translateKey, LANG_SERVER);
        lastRequestMenu.AddItem(sectionName, itemName);
    } while(lastRequests.GotoNextKey());

    lastRequests.Rewind();
}

Menu BuildFreedayGroupMenu() {
    Menu freedayGroupMenu = new Menu(Menu_FreedayGroup);
    char playerName[MAX_NAME_LENGTH];
    char playerIndex[16];

    for(int i = 1; i <= MaxClients; i++) {
        if(!IsClientInGame(i)) continue;
        IntToString(GetClientSerial(i), playerIndex, sizeof(playerIndex));
        GetClientName(i, playerName, sizeof(playerName));
        freedayGroupMenu.AddItem(playerIndex, playerName);
    }

    return freedayGroupMenu;
}

public int Menu_LastRequest(Menu menu, MenuAction action, int client, int item) {
    if(action == MenuAction_Select) {
        char info[64];
        char display[64];
        char actionName[64];
        char translateKey[64];
        char sectionName[64];
        int style;
        menu.GetItem(item, info, sizeof(info), style, display, sizeof(display));

        if(Jailbreak_TriggerLastRequest(client, info, display) != Plugin_Continue) return 0;

        Log("item found: '%s'", info);
        if(!lastRequests.GotoFirstSubKey()) { lastRequests.Rewind(); return 0; }
        Log("going to item in file...");
        lastRequests.GetSectionName(sectionName, sizeof(sectionName));
        Log("'%s' vs '%s'", sectionName, info);
        while(!StrEqual(sectionName, info)) {
            if(!lastRequests.GotoNextKey()) { lastRequests.Rewind(); return 0; }
            lastRequests.GetSectionName(sectionName, sizeof(sectionName));
            Log("'%s' vs '%s'", sectionName, info);
        }
        Log("item found in file...");
        lastRequests.GetString("Action", actionName, sizeof(actionName), "Nothing");
        lastRequests.Rewind();
        Log("action found: %s", actionName);
        Format(translateKey, sizeof(translateKey), "Jailbreak_LastRequest_%s_Select",
            info, sizeof(info));

        GetClientName(client, display, sizeof(display));
        CPrintToChatAll(JAILBREAK_REPLY, translateKey, LANG_SERVER, display);
        Log("dispatching last request...");
        DispatchLastRequest(client, actionName);
    }

    return 0;
}

public int Menu_FreedayGroup(Menu menu, MenuAction action, int client, int item) {
    if(action == MenuAction_Select) {
        char info[16];
        char display[MAX_NAME_LENGTH];
        int style;
        int target;
        menu.GetItem(item, info, sizeof(info), style, display, sizeof(display));
        target = StringToInt(info);
        if(target <= 1) {
            CPrintToChat(client, JAILBREAK_REPLY, "Jailbreak_FreedayGroup_Failed");
            menu.Display(client, MENU_TIME_FOREVER);
            return 0;
        }

        target = GetClientSerial(target);

        for(int i = 0; i < MAXPLAYERS + 1; i++) {
            if(nextFreedays[i] != 0) continue;
            if(nextFreedays[i] == target) {
                CPrintToChat(client, JAILBREAK_REPLY, "Jailbreak_FreedayGroup_Already");
                menu.Display(client, MENU_TIME_FOREVER);
                return 0;
            }
            nextFreedays[i] = target;
            nextFreedays[i + 1] = 0;
            break;
        }


        CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_FreedayGroup_Gifted",
            LANG_SERVER, display);
        if(--freedayGroupRemaining > 0) {
            menu.Display(client, MENU_TIME_FOREVER);
        } else {
            delete menu;
            CPrintToChatAll(JAILBREAK_REPLY, "Jailbreak_FreedayGroup_Done",
                LANG_SERVER);
        }
    }

    return view_as<int>(Plugin_Stop);
}

void DispatchLastRequest(int client, char[] actionName) {
    if(StrEqual(actionName, "Nothing")) {
        Log("an action of nothing was chosen for a last request.  maybe bug?");
    } else if(StrEqual(actionName, "Freeday_Single")) {
        nextRoundType = JailbreakRoundType_FreedayGroup;
        nextFreedays[0] = GetClientSerial(client);
        nextFreedays[1] = 0;
    } else if(StrEqual(actionName, "Freeday_Group")) {
        nextRoundType = JailbreakRoundType_FreedayGroup;
        freedayGroupRemaining = cvGroupFreedayCount.IntValue;
        BuildFreedayGroupMenu().Display(client, MENU_TIME_FOREVER);
    } else if(StrEqual(actionName, "Freeday_All")) {
        nextRoundType = JailbreakRoundType_FreedayAll;
    } else if(StrEqual(actionName, "Guard_Melee_Only")) {
        nextRoundType = JailbreakRoundType_GuardMeleeOnly;
    } else if(StrEqual(actionName, "Custom_Request")) {
        nextRoundType = JailbreakRoundType_CustomLastRequest;
    } else if(StrEqual(actionName, "Client_Suicide")) {
        ForcePlayerSuicide(client);
    } else if(StrEqual(actionName, "Client_Command_Immediate")) {
        char action[128];
        lastRequests.GetString("Command", action, sizeof(action), "wait");
        ClientCommand(client, "%s", actionName);
    } else if(StrEqual(actionName, "Client_Command_Next")) {
        nextRoundType = JailbreakRoundType_Command;
        freedayCommandTarget = GetClientSerial(client);
        lastRequests.GetString("Command", freedayCommand, sizeof(freedayCommand), "wait");
    } else if(StrEqual(actionName, "Server_Command_Immediate")) {
        char action[128];
        lastRequests.GetString("Command", action, sizeof(action), "wait");
        ServerCommand("%s", action);
    } else if(StrEqual(actionName, "Server_Command_Next")) {
        nextRoundType = JailbreakRoundType_Command;
        freedayCommandTarget = 0;
        lastRequests.GetString("Command", freedayCommand, sizeof(freedayCommand), "wait");
    } else {
        Log("unknown action given for last request: %s", actionName);
    }
}
