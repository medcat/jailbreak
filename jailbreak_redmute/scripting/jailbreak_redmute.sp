#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
#include <jailbreak>

public Plugin myinfo =
{
    name = "Jailbreak Red Mute",
    author = "Jeremy Rodi <me@medcat.me>",
    description = "Mutes all reds at the start of the round, and unmutes at the end.",
    version = "0.3.0",
    url = "https://github.com/medcat/jailbreak"
};

int clientWasMuted[MAXPLAYERS + 1];
bool roundActive = false;

public void OnPluginStart() {
    LoadTranslations("core.phrases");
    LoadTranslations("common.phrases");

}

public Action OnJailbreakRoundStart(Event _e, JailbreakRoundType _jb) {
    roundActive = true;
    for(int i = 1; i < MaxClients; i++) {
        clientWasMuted[i] = 0;
        if(IsPlayerShouldBeMuted(i)) MuteClient(i);
    }
}

public void OnClientPostAdminCheck(int client) {
    clientWasMuted[client] = 0;
    if(IsPlayerShouldBeMuted(client)) MuteClient(client);
}

public Action Event_PlayerDeath(Event event, const char[] _en, bool _db) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if(IsPlayerShouldBeMuted(client)) MuteClient(client);
    else if(clientWasMuted[client] == 1) UnMuteClient(client);
    return Plugin_Continue;
}

public Action Event_PlayerSpawn(Event event, const char[] eventName, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if(IsPlayerShouldBeMuted(client)) MuteClient(client);
    else if(clientWasMuted[client] == 1) UnMuteClient(client);
    return Plugin_Continue;
}

public Action OnJailbreakRoundEnd(JailbreakRoundType _jb) {
    for(int i = 1; i < MaxClients; i++) {
        if(clientWasMuted[i] == 1) UnMuteClient(i);
    }
    roundActive = true;
}

public void BaseComm_OnClientMute(int client, bool muteState) {
    if(roundActive && muteState) {
        clientWasMuted[client] = 2;
    } else if(!muteState && IsPlayerShouldBeMuted(client)) {
        MuteClient(client);
    }
}

void MuteClient(int client) {
    if(IsPlayerMuted(client)) {
        clientWasMuted[client] = 2;
    } else {
        clientWasMuted[client] = 1;
        SetPlayerMuted(client, true);
    }
}

void UnMuteClient(int client) {
    if(clientWasMuted[client] == 2) return;
    if(!IsPlayerMuted(client)) return;
    clientWasMuted[client] = 0;
    SetPlayerMuted(client, false);
}

bool IsPlayerMuted(int client) {
    return !!(GetClientListeningFlags(client) & VOICE_MUTED);
}

void SetPlayerMuted(int client, bool mute) {
    LogMessage("SetPlayerMuted(%L, %u)", client, mute);
    if(mute) {
        SetClientListeningFlags(client, GetClientListeningFlags(client) | VOICE_MUTED);
    } else {
        SetClientListeningFlags(client, GetClientListeningFlags(client) & ~VOICE_MUTED);
    }
}

bool IsPlayerShouldBeMuted(int client) {
    return (roundActive && IsClientInGame(client) &&
        TF2_GetClientTeam(client) != TFTeam_Blue && !IsPlayerAlive(client) &&
        !IsPlayerReserve(client));
}

bool IsPlayerReserve(int client) {
    return CheckCommandAccess(client, "sm_jailbreak_skip_mute",
        ADMFLAG_RESERVATION | ADMFLAG_GENERIC, true);
}
