#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
#include <jailbreak>
#include <smlib/entities>

public Plugin myinfo =
{
    name = "Jailbreak Map Integrations",
    author = "Jeremy Rodi <me@medcat.me>",
    description = "Map integrations for the jailbreak plugin",
    version = "0.2.0",
    url = "https://github.com/medcat/jailbreak"
};

KeyValues mapKeyValue = null;
ConVar cvOpenCellTime = null;
Handle cellOpenTimer = null;
char currentMapName[126];
bool currentMapSupport = false;

#define JAILBREAK_MAP_INITIALIZE "Initialize"
#define JAILBREAK_MAP_CELLS_OPEN "Cells_Open"
#define JAILBREAK_MAP_CELLS_CLOSE "Cells_Close"

public void OnPluginStart() {
    char path[PLATFORM_MAX_PATH];

    LoadTranslations("jailbreak_map.phrases");
    mapKeyValue = new KeyValues("Jailbreak_Maps");
    BuildPath(Path_SM, path, sizeof(path), "configs/jailbreak/maps.cfg");
    if(!mapKeyValue.ImportFromFile(path)) ThrowError("Could not find the maps file!");
    cvOpenCellTime = CreateConVar("sm_jailbreak_open_cells_time", "60", "The time to open cells at, in seconds.", FCVAR_NOTIFY, true, -1.0, true, 60.0 * 30.0);

    RegConsoleCmd("sm_jailbreak_warden_opencells", Command_Warden_OpenCells, "Opens the cell doors.", FCVAR_NONE);
    RegConsoleCmd("sm_warden_opencells", Command_Warden_OpenCells, "Opens the cell doors.", FCVAR_NONE);
    RegConsoleCmd("sm_open", Command_Warden_OpenCells, "Opens the cell doors.", FCVAR_NONE);
    RegConsoleCmd("sm_jailbreak_warden_closecells", Command_Warden_CloseCells, "Closes the cell doors.", FCVAR_NONE);
    RegConsoleCmd("sm_warden_closecells", Command_Warden_CloseCells, "Closes the cell doors.", FCVAR_NONE);
    RegConsoleCmd("sm_close", Command_Warden_CloseCells, "Closes the cell doors.", FCVAR_NONE);
}

bool PositionMapKeyValueToCurrentMap() {
    mapKeyValue.Rewind();
    char sectionName[128];
    bool found = false;

    LogMessage("looking for %s in file...", currentMapName);

    if(!mapKeyValue.GotoFirstSubKey()) {
        LogMessage("maps.cfg seems to be incorrectly formatted, ignoring.");
        return false;
    }

    do {
        mapKeyValue.GetSectionName(sectionName, sizeof(sectionName));
        if(StrEqual(sectionName, currentMapName)) {
            found = true;
            break;
        }
    } while(mapKeyValue.GotoNextKey());

    if(!found) {
        LogMessage("current map is unsupported, ignoring.");
        return false;
    } else if(!mapKeyValue.GotoFirstSubKey()) {
        LogMessage("maps.cfg seems to be incorrectly formatted for %s, ignoring.", currentMapName);
        return false;
    } else {
        LogMessage("map config for %s loaded, ready to roll!", currentMapName);
        return true;
    }
}

void TriggerJailbreakMapEvent(const char[] event) {
    char entityName[256];
    char entityInput[256];
    char sectionName[256];
    bool found;

    LogMessage("triggering %s for %s...", event, currentMapName);
    if(!currentMapSupport) return;
    mapKeyValue.SavePosition();

    do {
        mapKeyValue.GetSectionName(sectionName, sizeof(sectionName));
        if(StrEqual(sectionName, event)) {
            found = true;
            break;
        }
    } while(mapKeyValue.GotoNextKey());

    if(!found) { mapKeyValue.GoBack(); return; }
    if(!mapKeyValue.GotoFirstSubKey()) { mapKeyValue.GoBack(); return; }

    do {
        mapKeyValue.GetString("Name", entityName, sizeof(entityName), "");
        mapKeyValue.GetString("Input", entityInput, sizeof(entityInput), "");
        // Hack: Double the limit to gets none-networked entities too.
        if(entityName[0] == '\0' || entityInput[0] == '\0') continue;
        int realMaxEntities = GetMaxEntities() * 2;
        for (int entity = 0; entity < realMaxEntities; entity++) {
            if (IsValidEntity(entity) && Entity_NameMatches(entity, entityName)) {
                AcceptEntityInput(entity, entityInput);
            }
        }
    } while(mapKeyValue.GotoNextKey());

    mapKeyValue.GoBack();
    mapKeyValue.GoBack();
}

void AddItemsToWardenMenu() {
    Menu wardenMenu = Jailbreak_GetWardenMenu();
    char translatedText[512];

    Format(translatedText, sizeof(translatedText), "%T",
        "Jailbreak_Warden_Menu_OpenCells", LANG_SERVER);
    wardenMenu.AddItem("sm_jailbreak_warden_opencells", translatedText);
    Format(translatedText, sizeof(translatedText), "%T",
        "Jailbreak_Warden_Menu_CloseCells", LANG_SERVER);
    wardenMenu.AddItem("sm_jailbreak_warden_closecells", translatedText);
}

public void OnMapStart() {
    GetCurrentMap(currentMapName, sizeof(currentMapName));
    currentMapSupport = PositionMapKeyValueToCurrentMap();
    if(currentMapSupport) {
        TriggerJailbreakMapEvent(JAILBREAK_MAP_INITIALIZE);
        AddItemsToWardenMenu();
    }
}

public Action Timer_OpenCells(Handle timer) {
    TriggerJailbreakMapEvent(JAILBREAK_MAP_CELLS_OPEN);
    cellOpenTimer = null;
    return Plugin_Stop;
}

public Action OnJailbreakRoundStart(Event event, JailbreakRoundType roundType) {
    float cellTime = cvOpenCellTime.FloatValue;
    if(!currentMapSupport) return Plugin_Continue;
    TriggerJailbreakMapEvent(JAILBREAK_MAP_INITIALIZE);

    if(roundType == JailbreakRoundType_FreedayAll) {
        TriggerJailbreakMapEvent(JAILBREAK_MAP_CELLS_OPEN);
    } else if(cellTime >= 0.0) {
        if(cellTime == 0.0) cellTime = GetTickInterval();
        cellOpenTimer = CreateTimer(cellTime, Timer_OpenCells, 0);
    }

    return Plugin_Continue;
}

public Action Command_Warden_OpenCells(int client, int a) {
    bool isAdmin = CheckCommandAccess(client, "sm_jailbreak_warden_closecells",
        ADMFLAG_KICK, false);
    if(!currentMapSupport) {
        CReplyToCommand(client, "[{silver}Jailbreak{white}] %T",
            "Jailbreak_Map_Incompatible", client);
        return Plugin_Handled;
    } if(!Jailbreak_IsClientWarden(client) && !isAdmin) {
        CReplyToCommand(client, "[{silver}Jailbreak{white}] %T",
            "Jailbreak_Map_NotAllowed", client);
        return Plugin_Handled;
    }

    if(cellOpenTimer != null) { cellOpenTimer.Close(); cellOpenTimer = null; }
    TriggerJailbreakMapEvent(JAILBREAK_MAP_CELLS_OPEN);
    return Plugin_Handled;
}

public Action Command_Warden_CloseCells(int client, int a) {
    bool isAdmin = CheckCommandAccess(client, "sm_jailbreak_warden_closecells",
        ADMFLAG_KICK, false);
    if(!currentMapSupport) {
        CReplyToCommand(client, "[{silver}Jailbreak{white}] %T",
            "Jailbreak_Map_Incompatible", client);
        return Plugin_Handled;
    } if(!Jailbreak_IsClientWarden(client) && !isAdmin) {
        CReplyToCommand(client, "[{silver}Jailbreak{white}] %T",
            "Jailbreak_Map_NotAllowed", client);
        return Plugin_Handled;
    }

    if(cellOpenTimer != null) { cellOpenTimer.Close(); cellOpenTimer = null; }
    TriggerJailbreakMapEvent(JAILBREAK_MAP_CELLS_CLOSE);
    return Plugin_Handled;
}
