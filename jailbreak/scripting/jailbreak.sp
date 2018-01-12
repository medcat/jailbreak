#include <sourcemod>
#include <adminmenu>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
#include <smlib/clients>
#include <smlib/entities>
#include <smlib/weapons>
#include <jailbreak>

#pragma newdecls required
#pragma semicolon 1
#define JAILBREAK_TAG "[{silver}Jailbreak{white}] "
#define JAILBREAK_REPLY "[{silver}Jailbreak{white}] %T"
#define INFINITY view_as<float>(0x7F800000)

public Plugin myinfo =
{
    name = "Jailbreak",
    author = "Jeremy Rodi <me@medcat.me>",
    description = "Jailbreak, for Team Fortress 2",
    version = "0.3.0",
    url = "https://github.com/medcat/jailbreak"
};


stock void Log(const char[] str, any ...) {
    char[] buffer = new char[1024];
    VFormat(buffer, 1024, str, 2);
    LogMessage("%s", buffer);
}

#include "jailbreak/variables.sp"
#include "jailbreak/forwards.sp"
#include "jailbreak/natives.sp"
#include "jailbreak/hud.sp"
#include "jailbreak/cvar.sp"
#include "jailbreak/round.sp"
#include "jailbreak/commands.sp"
#include "jailbreak/targets.sp"

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max) {
    CreateForwards();
    CreateNatives();
    RegPluginLibrary("jailbreak");
    return APLRes_Success;
}

public void OnConfigsExecuted() {
    PrepareGameConVars();
}

public void OnPluginStart() {
    LoadTranslations("jailbreak.phrases");
    LoadTranslations("core.phrases");
    LoadTranslations("common.phrases");
    wardenDeclareSync = CreateHudSynchronizer();
    roundType = JAILBREAK_ROUNDTYPE_NORMAL;
    nextRoundType = JAILBREAK_ROUNDTYPE_NORMAL;
    InitializeCommands();
    InitializeConVars();
    AddTargetFilters();
}

public void OnEntityCreated(int entity, const char[] classname) {
    if(StrEqual(classname, "tf_ammo_pack", true)) {
        // this is to prevent reds from spawning ammo packs on death.  I wish
        // there was a way to tell which team this spawned from, allowing
        // blues to drop them, but alas...
        AcceptEntityInput(entity, "Kill");
    }
}

public void OnMapStart() {
    InitializeFreeday();
    BuildWardenMenu();
    JailbreakHandleEntities();
    HookEvent("arena_round_start", Event_RoundStart, EventHookMode_Post);
    HookEvent("arena_win_panel", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
}
