#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
/*#pragma newdecls required*/
#include <morecolors>

#define JAILBREAK_TAG "{lightgreen}[{olive}Jailbreak{lightgreen}] "
#define JAILBREAK_REPLY "{lightgreen}[{olive}Jailbreak{lightgreen}] %T"
#define INFINITY view_as<float>(0x7F800000)

stock void Log(const char[] str, any:...) {
    char[] buffer = new char[1024];
    int len = VFormat(buffer, 1024, str, 2);
    LogMessage("%s", buffer);
}

enum JailbreakRoundType {
    JailbreakRoundType_Normal,
    JailbreakRoundType_Command,
    JailbreakRoundType_FreedayGroup,
    JailbreakRoundType_FreedayAll,
    JailbreakRoundType_GuardMeleeOnly,
    JailbreakRoundType_CustomLastRequest,
}

#include "jailbreak/plugin.sp"
#include "jailbreak/variables.sp"
#include "jailbreak/hud.sp"
#include "jailbreak/cvar.sp"
#include "jailbreak/round.sp"
#include "jailbreak/commands.sp"

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max) {
    if(late) return APLRes_SilentFailure;
    else return APLRes_Success;
}

public void OnConfigsExecuted() {
    PrepareGameConVars();
}

public void OnPluginStart() {
    LoadTranslations("jailbreak.phrases");
    LoadTranslations("core.phrases");
    LoadTranslations("common.phrases");
    beamModel = PrecacheModel("materials/sprites/laser.vmt");
    haloModel = PrecacheModel("materials/sprites/halo01.vmt");
    wardenDeclareSync = CreateHudSynchronizer();
    roundTimerSync = CreateHudSynchronizer();
    roundType = JailbreakRoundType_Normal;
    nextRoundType = JailbreakRoundType_Normal;
    InitializeCommands();
    InitializeConVars();
    BuildWardenMenu();
    BuildLastRequestMenu();
}

public void OnMapEnd() {
    CloseHandle(wardenMenu);
}

public void OnMapStart() {
    InitializeFreeday();
    RemoveCurrentEntities();
    CreateGameRules();
    CreateRoundWin();
    ModifyArenaRules();
    HookEvent("arena_round_start", Event_RoundStart, EventHookMode_Pre);
    HookEvent("teamplay_round_win", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
}
