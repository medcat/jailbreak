#include <sourcemod>
#include <adminmenu>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
#include <jailbreak>
#include <jailbreak/lastrequest>

public Plugin myinfo =
{
    name = "Jailbreak Last Request Module",
    author = "Jeremy Rodi <me@medcat.me>",
    description = "First day freeday for the jailbreak plugin",
    version = "0.3.0",
    url = "https://github.com/medcat/jailbreak"
};

ArrayList lastRequests = null;
int freedaysNext[MAXPLAYERS+1] = {0};
int freedayGroupRemaining = 0;
int freedayCommandTarget = 0;
Handle forwardLastRequest = null;
Menu lastRequestMenu = null;
LastRequest freedayCommand = null;

#define JAILBREAK_ROUNDTYPE_FREEDAYGROUP 3
#define JAILBREAK_ROUNDTYPE_GUARDMELEEONLY 4
#define JAILBREAK_ROUNDTYPE_CUSTOMREQUEST 5
#define JAILBREAK_ROUNDTYPE_COMMAND 5

public void OnPluginStart() {
    LoadTranslations("core.phrases");
    LoadTranslations("common.phrases");
    LoadTranslations("jailbreak_lastrequest.phrases");
    RegConsoleCmd("sm_jailbreak_warden_lastrequest", Command_Warden_LastRequest, "Grants a last request.");
    RegConsoleCmd("sm_warden_lastrequest", Command_Warden_LastRequest, "Grants a last request.");
    RegConsoleCmd("sm_givelr", Command_Warden_LastRequest, "Grants a last request.");
    forwardLastRequest = CreateGlobalForward("OnJailbreakLastRequest", ET_Hook,
        Param_Cell, Param_Cell);
    CreateNative("Jailbreak_GiveLastRequest", Native_JailbreakGiveLastRequest);
}

public void OnMapStart() {
    LoadLastRequests();
    CreateLastRequestMenu();
    for(int i = 0; i < MAXPLAYERS+1; i++) freedaysNext[i] = 0;
}

public Action OnJailbreakRoundStart(Event _e, int roundType) {
    LogMessage("saw roundtype of %u.", roundType);
    switch(roundType) {
        case JAILBREAK_ROUNDTYPE_FREEDAYGROUP: {
            LogMessage("starting freeday group round!");
            for(int i = 0; i < MAXPLAYERS+1 && freedaysNext[i] != 0; i++) {
                int client = GetClientFromSerial(freedaysNext[i]);
                if(client) Jailbreak_GiveFreeday(client);
                freedaysNext[i] = 0;
            }
        }
        case JAILBREAK_ROUNDTYPE_GUARDMELEEONLY: {
            LogMessage("starting melee only round!");
            for(int i = 1; i < MaxClients; i++)
                if(IsClientInGame(i) && TF2_GetClientTeam(i) == TFTeam_Blue)
                    PermanentlyRemoveWeapons(i);
        }
        case JAILBREAK_ROUNDTYPE_COMMAND: {
            LogMessage("starting command round!");
            int client;
            char command[256];
            if(freedayCommand.GetString("start", command, sizeof(command))) {
                if(freedayCommandTarget && (client = GetClientFromSerial(freedayCommandTarget)))
                    ClientCommand(client, "%s", command);
                else
                    ServerCommand("%s", command);
            }
        }

        default: LogMessage("no action needed.");
    }

    return Plugin_Continue;
}

public Action OnJailbreakRoundEnd(Event _e, int roundType) {
    LogMessage("jailbreak round end - round type %u", roundType);
    if(roundType == JAILBREAK_ROUNDTYPE_COMMAND) {
        LogMessage("triggering round end command!");
        char command[256];
        int client;
        if(freedayCommand.GetString("end", command, sizeof(command))) {
            if(freedayCommandTarget && (client = GetClientFromSerial(freedayCommandTarget)))
                ClientCommand(client, "%s", command);
            else
                ServerCommand("%s", command);
        }
    }

    return Plugin_Continue;
}

// ----------------------------------------------------------------------------
//  Last Request Management
// ----------------------------------------------------------------------------

void LoadLastRequests() {
    ArrayList list = new ArrayList(1);
    KeyValues kvRequests = new KeyValues("Last_Requests");
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "configs/jailbreak/last_requests.cfg");
    if(!kvRequests.ImportFromFile(path)) ThrowError("Could not find last requests file!");
    if(!kvRequests.GotoFirstSubKey()) { delete kvRequests; return; }

    do {
        LastRequest lr = new LastRequest();
        kvRequests.GotoFirstSubKey(false);
        do {
            char keyName[256];
            char lowerKeyName[256];
            kvRequests.GetSectionName(keyName, sizeof(keyName));
            char[] value = new char[1024];
            kvRequests.GetString(NULL_STRING, value, 1024);
            String_ToLower(keyName, lowerKeyName, 256);
            lr.SetString(lowerKeyName, value, true);
        } while(kvRequests.GotoNextKey(false));

        if(ValidateRequest(lr)) list.Push(lr);
        kvRequests.GoBack();
    } while(kvRequests.GotoNextKey());

    delete kvRequests;

    if(lastRequests != null) {
        for(int i = 0; i < lastRequests.Length; i++) {
            Handle request = view_as<Handle>(lastRequests.Get(i));
            request.Close();
        }
    }

    lastRequests = list;
}

bool ValidateRequest(LastRequest request) {
    if(!request.GetString("name", "", 0)) {
        LogError("could not find name for last request");
        return false;
    } else if(!request.GetString("action", "", 0)) {
        LogError("could not find action for last request");
        return false;
    } else if(!request.GetString("description", "", 0)) {
        LogError("could not find action for last request");
        return false;
    } else { return true; }
}

public Action Command_Warden_LastRequest(int client, int args) {
    bool isAdmin = CheckCommandAccess(client, "sm_jailbreak_warden_lastrequest_override",
        ADMFLAG_KICK, true);
    if(!Jailbreak_IsClientWarden(client) && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_LastRequest_NotWarden",
            client);
    } else if(args > 1) {
        PrintToConsole(client, "Usage: sm_givelr [client]");
    } else if(args == 1) {
        char target[MAX_NAME_LENGTH];
        GetCmdArg(1, target, sizeof(target));
        int targetClient = FindTarget(client, target, true, false);

        if(targetClient < 1) {
            CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_LastRequest_NotFound",
                client);
        } else {
            GrantLastRequest(targetClient);
        }
    } else {
        BuildLastRequestSelectMenu().Display(client, MENU_TIME_FOREVER);
    }

    return Plugin_Handled;
}

void CreateLastRequestMenu() {
    Menu menu = new Menu(Menu_LastRequest, MenuAction_DisplayItem);

    for(int i = 0; i < lastRequests.Length; i++) {
        LastRequest map = view_as<LastRequest>(lastRequests.Get(i));
        char name[64];
        char index[16];
        map.GetName(name, sizeof(name));
        IntToString(i, index, sizeof(index));
        menu.AddItem(index, name);
    }

    if(lastRequestMenu) lastRequestMenu.Close();
    lastRequestMenu = menu;
}

public int Menu_LastRequest(Menu menu, MenuAction action, int client, int item) {
    switch(action) {
        case MenuAction_Select: {
            char info[64];
            char authName[64];
            char description[256];
            int index;
            menu.GetItem(item, info, sizeof(info), _, "", 0);
            index = StringToInt(info);
            if(index < 0 || index > lastRequests.Length) {
                LogMessage("invalid index, ignoring...");
                return 0;
            }
            LastRequest request = view_as<LastRequest>(lastRequests.Get(index));
            request.GetDescription(description, sizeof(description));
            String_ToTranslate(client, description, description, sizeof(description));
            CPrintToChatAll(JAILBREAK_TAG ... "%s", description);
            if(Jailbreak_TriggerLastRequest(client, request) != Plugin_Continue) return 0;
            else DispatchLastRequest(client, request);
        }
        case MenuAction_DisplayItem: {
            char display[256];
            char buffer[256];
            menu.GetItem(item, "", 0, _, display, sizeof(display));
            String_ToTranslate(client, display, buffer, sizeof(buffer));
            return RedrawMenuItem(buffer);
        }
        case MenuAction_Display: {
            Panel panel = view_as<Panel>(client);
            char buffer[256];
            Format(buffer, sizeof(buffer), "%T", "Jailbreak_LastRequest_Title", client);
            panel.SetTitle(buffer);
        }
    }

    return 0;
}

void DispatchLastRequest(int client, LastRequest request) {
    char actionName[64];
    request.GetAction(actionName, sizeof(actionName));
    LogMessage("dispatching last request for %s<%L>...", actionName, client);
    if(StrEqual(actionName, "Nothing")) {
        LogMessage("an action of nothing was chosen for a last request.  maybe bug?");
    } else if(StrEqual(actionName, "Freeday_Single")) {
        Jailbreak_SetNextRoundType(JAILBREAK_ROUNDTYPE_FREEDAYGROUP);
        freedaysNext[0] = GetClientSerial(client);
        freedaysNext[1] = 0;
    } else if(StrEqual(actionName, "Freeday_Group")) {
        char intBuf[16];
        Jailbreak_SetNextRoundType(JAILBREAK_ROUNDTYPE_FREEDAYGROUP);
        request.GetString("size", intBuf, 16);
        freedayGroupRemaining = StringToInt(intBuf);
        BuildFreedayGroupMenu().Display(client, MENU_TIME_FOREVER);
    } else if(StrEqual(actionName, "Freeday_All")) {
        Jailbreak_SetNextRoundType(JAILBREAK_ROUNDTYPE_FREEDAY);
    } else if(StrEqual(actionName, "Guard_Melee_Only")) {
        Jailbreak_SetNextRoundType(JAILBREAK_ROUNDTYPE_GUARDMELEEONLY);
    } else if(StrEqual(actionName, "Custom_Request")) {
        Jailbreak_SetNextRoundType(JAILBREAK_ROUNDTYPE_CUSTOMREQUEST);
    } else if(StrEqual(actionName, "Client_Suicide")) {
        ForcePlayerSuicide(client);
    } else if(StrEqual(actionName, "Client_Command")) {
        Jailbreak_SetNextRoundType(JAILBREAK_ROUNDTYPE_COMMAND);
        freedayCommandTarget = GetClientSerial(client);
        freedayCommand = request;
    } else if(StrEqual(actionName, "Server_Command")) {
        LogMessage("SERVER COMD, %u", JAILBREAK_ROUNDTYPE_COMMAND);
        Jailbreak_SetNextRoundType(JAILBREAK_ROUNDTYPE_COMMAND);
        freedayCommandTarget = 0;
        freedayCommand = request;
    } else {
        LogMessage("unknown action given for last request: %s", actionName);
    }
}

Menu BuildLastRequestSelectMenu() {
    Menu freedayGroupMenu = new Menu(Menu_LastRequestSelect);
    AddTargetsToMenu(freedayGroupMenu, 0, true, true);
    return freedayGroupMenu;
}

public int Menu_LastRequestSelect(Menu menu, MenuAction action, int client, int item) {
    if(action == MenuAction_Select) {
        char info[16];
        char display[MAX_NAME_LENGTH];
        int style;
        int target;
        menu.GetItem(item, info, sizeof(info), style, display, sizeof(display));
        target = GetClientOfUserId(StringToInt(info));
        if(target < 1) { LogMessage("invalid target selected (%s, %s, %d)", display, info, target); return 0; }
        GrantLastRequest(target);
        delete menu;
    }

    return 0;
}

// ----------------------------------------------------------------------------
//  FREEDAY HANDLERS
// ----------------------------------------------------------------------------

Menu BuildFreedayGroupMenu() {
    Menu freedayGroupMenu = new Menu(Menu_FreedayGroup);
    AddTargetsToMenu(freedayGroupMenu, 0, true, true);
    return freedayGroupMenu;
}

public int Menu_FreedayGroup(Menu menu, MenuAction action, int client, int item) {
    if(action == MenuAction_Select) {
        char info[16];
        char display[MAX_NAME_LENGTH];
        int style;
        int target;
        menu.GetItem(item, info, sizeof(info), style, display, sizeof(display));
        target = GetClientOfUserId(StringToInt(info));
        if(target < 1) {
            CPrintToChat(client, JAILBREAK_REPLY, "Jailbreak_FreedayGroup_Failed",
                client);
            menu.Display(client, MENU_TIME_FOREVER);
            return 0;
        }

        for(int i = 0; i < MAXPLAYERS + 1; i++) {
            if(freedaysNext[i] != 0) continue;
            if(freedaysNext[i] == target) {
                CPrintToChat(client, JAILBREAK_REPLY, "Jailbreak_FreedayGroup_Already",
                    client);
                menu.Display(client, MENU_TIME_FOREVER);
                return 0;
            }
            freedaysNext[i] = GetClientSerial(target);
            freedaysNext[i + 1] = 0;
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

// ----------------------------------------------------------------------------
//   NATIVES & FORWARDS
// ----------------------------------------------------------------------------

public int Native_JailbreakGiveLastRequest(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    if(!IsClientInGame(client) || !IsPlayerAlive(client))
        ThrowNativeError(101, "Invalid client given (must be alive and in game)!");
    if(!Jailbreak_IsWardenAllowed())
        ThrowNativeError(201, "Unable to grant last request while not in round!");
    GrantLastRequest(client);
    return 0;
}

Action Jailbreak_TriggerLastRequest(int client, LastRequest request) {
    Action result;

    Call_StartForward(forwardLastRequest);
    Call_PushCell(client);
    Call_PushCell(request);
    if(Call_Finish(result) != SP_ERROR_NONE) ThrowError("TriggerLastRequest forward failed!");
    return result;
}

// ----------------------------------------------------------------------------
//   STOCKS
// ----------------------------------------------------------------------------

stock void String_ToLower(const char[] input, char[] output, int size) {
    int i;
    size--;
    for(i = 0; i < size && input[i] != '\0'; i++) output[i] = CharToLower(input[i]);
    output[i] = '\0';
}

stock void String_ToTranslate(int client, const char[] key, char[] keyOut, int size) {
    if(key[0] == '#') {
        int len = strlen(key);
        int i;
        char[] actualKey = new char[len];
        char clientName[64];
        GetClientName(client, clientName, sizeof(clientName));
        for(i = 1; i < len; i++) actualKey[i - 1] = key[i];
        actualKey[i - 1] = 0;
        FormatEx(keyOut, size, "%T", actualKey, client, clientName);
    } else if(key[0] == ' ') {
        strcopy(keyOut, size, key);
        TrimString(keyOut);
    } else  {
        strcopy(keyOut, size, key);
    }
}

stock void GrantLastRequest(int client) {
    lastRequestMenu.Display(client, MENU_TIME_FOREVER);
}

stock void PermanentlyRemoveWeapons(int client) {
    TFClassType clientClass = TF2_GetPlayerClass(client);
    TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
    if(clientClass != TFClass_Spy && clientClass != TFClass_Medic)
        TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
    TF2_RemoveWeaponSlot(client, TFWeaponSlot_Grenade);
    TF2_RemoveWeaponSlot(client, TFWeaponSlot_Building);
    TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
    TF2_RemoveWeaponSlot(client, TFWeaponSlot_Item1);
    TF2_RemoveWeaponSlot(client, TFWeaponSlot_Item2);
    EquipPlayerWeapon(client, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
}
