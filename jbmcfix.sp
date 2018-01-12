#include <sourcemod>
#include <sdktools>
#include <smlib/entities>

public Plugin myinfo =
{
    name = "Fix Jailbreak Minecraft Daylight",
    author = "Jeremy Rodi <me@medcat.me>",
    description = "Fixes jailbreak minecraft daylight.",
    version = "0.3.0",
    url = "https://github.com/medcat/jailbreak"
};

public void OnMapStart() {
    char mapName[64];
    GetCurrentMap(mapName, sizeof(mapName));
    LogMessage("JBMCFIX MAP: %s", mapName);
    if(strcmp("jb_minecraft_daylight_v6_fix", mapName, false) == 0) {
        LogMessage("FIXING JBMC.");
        HookEvent("arena_round_start", Event_RoundStart, EventHookMode_PostNoCopy);
        RemoveFootball();
    }
}

public void Event_RoundStart(Event _e, const char[] _n, bool _d) {
    RemoveFootball();
}

void RemoveFootball() {
    RemoveEntityByHammerId(2324);
    RemoveEntityByHammerId(2322);
    RemoveEntityByHammerId(764870);
}

void RemoveEntityByHammerId(int id) {
    int entity = Entity_FindByHammerId(id);
    LogMessage("attempting removal of removing entity %d.", entity);
    if(entity != INVALID_ENT_REFERENCE && entity > 0) AcceptEntityInput(entity, "kill");
}
