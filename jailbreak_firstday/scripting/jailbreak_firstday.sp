#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
#include <jailbreak>

public Plugin myinfo =
{
    name = "Jailbreak First Day Freeday",
    author = "Jeremy Rodi <me@medcat.me>",
    description = "First day freeday for the jailbreak plugin",
    version = "0.3.0",
    url = "https://github.com/medcat/jailbreak"
};

bool firstDay = false;
Handle freedaySync = null;

public void OnPluginStart() {
    LoadTranslations("jailbreak_firstday.phrases");
    LoadTranslations("core.phrases");
    LoadTranslations("common.phrases");
    freedaySync = CreateHudSynchronizer();
    firstDay = true;
}

public void OnMapStart() {
    firstDay = true;
}

public Action OnJailbreakPreBalance(int _c) {
    int currentRoundType = Jailbreak_GetNextRoundType();
    if(currentRoundType == JAILBREAK_ROUNDTYPE_NORMAL && firstDay) {
        Jailbreak_SetNextRoundType(JAILBREAK_ROUNDTYPE_FREEDAY);
        firstDay = false;
        SetHudTextParams(-1.0, 0.25, 5.0, 255, 255, 255, 125, 0, 0.0, 0.0, 0.0);
        for(int i = 1; i <= MaxClients; i++) {
            if(!IsClientConnected(i) || !IsClientInGame(i)) continue;
            ShowSyncHudText(i, freedaySync, "First Day Freeday!");
        }
    }

    return Plugin_Continue;
}
