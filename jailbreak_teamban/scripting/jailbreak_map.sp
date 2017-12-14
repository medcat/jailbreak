#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
#include <jailbreak>
#include <smlib/entities>

public Plugin myinfo =
{
    name = "Jailbreak Team Bans",
    author = "Jeremy Rodi <me@medcat.me>",
    description = "Team banning for jailbreak",
    version = "0.2.1",
    url = "https://github.com/medcat/jailbreak"
};

public void OnPluginStart() {
    char path[PLATFORM_MAX_PATH];

    LoadTranslations("jailbreak_teamban.phrases");
}
