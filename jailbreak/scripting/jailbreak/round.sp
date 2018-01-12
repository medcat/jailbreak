#include "jailbreak/round/entities.sp"
#include "jailbreak/round/balance.sp"

void JailbreakTemporarilyRemoveWeapons(int client) {
#pragma newdecls optional
    LOOP_CLIENTWEAPONS(client, weapon, index) {
        if(Weapon_GetPrimaryClip(weapon) != -1)
            SetEntProp(weapon, Prop_Send, "m_iClip1", 0); //Weapon_SetPrimaryClip(weapon, 0);
        if(Weapon_GetSecondaryClip(weapon) != -1)
            SetEntProp(weapon, Prop_Send, "m_iClip2", 0); //Weapon_SetSecondaryClip(weapon, 0);
        Client_SetWeaponPlayerAmmoEx(client, weapon, 0, 0);
    }
#pragma newdecls required

    EquipPlayerWeapon(client, GetPlayerWeaponSlot(client, 2));
    TF2_RemoveWeaponSlot(client, 3);
    TF2_RemoveWeaponSlot(client, 4);
    TF2_RemoveWeaponSlot(client, 5);
    TF2_RemovePlayerDisguise(client);
}

void JailbreakPermanentlyRemoveWeapons(int client) {
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

void JailbreakRemoveWeapons(int client, bool permanent) {
    if(permanent) {
        JailbreakPermanentlyRemoveWeapons(client);
    } else {
        JailbreakTemporarilyRemoveWeapons(client);
    }
}

public Action Event_RoundStartPre(Event event, const char[] eventName, bool dontBroadcast) {
    Log("round start pre!");
    JailbreakHandleEntities();
    PrepareGameConVars();
    currentWardenClient = 0;
    wardenAllowed = false;
}

public Action Event_RoundStart(Event event, const char[] eventName, bool dontBroadcast) {
    if(wardenAllowed) return Plugin_Continue;
    Log("round start!");
    if(Jailbreak_TriggerPreBalance(roundType) == Plugin_Continue) StartJailbreakBalance();
    currentWardenClient = 0;
    wardenAllowed = true;
    roundType = nextRoundType;
    nextRoundType = JAILBREAK_ROUNDTYPE_NORMAL;
    for(int i = 1; i <= MaxClients; i++) {
        if(IsClientInGame(i) && IsPlayerAlive(i) && TF2_GetClientTeam(i) == TFTeam_Red) {
            CreateTimer(0.1, Timer_RemovePlayerWeapons, i);
        }
    }

    return Jailbreak_TriggerRoundStart(event, roundType);
}

public Action Event_RoundEnd(Event event, const char[] eventName, bool dontBroadcast) {
    if(!wardenAllowed) return Plugin_Continue;
    currentWardenClient = 0;
    wardenAllowed = false;
    Log("round ended because of %s!", eventName);
    StopJailbreakBalance();
    RemoveAllFreedays(true);
    int oldRoundType = roundType;
    roundType = JAILBREAK_ROUNDTYPE_NORMAL;
    return Jailbreak_TriggerRoundEnd(event, oldRoundType);
}

public Action Event_PlayerDeath(Event event, const char[] eventName, bool dontBroadcast) {
    Log("saw player death!");
    int userId = event.GetInt("userid");
    int client = GetClientOfUserId(userId);
    if(IsCurrentWarden(client)) {
        RemoveWarden();
    } else if(freedayClients[client][0]) {
        // if, somehow, a freeday dies without loosing their freeday, we need
        // to handle that.  maybe a slay kills them? or they suicide?
        freedayClients[client][0] = false;
        CloseHandle(freedayClients[client][1]);
    }

    return Plugin_Continue;
}

public Action Event_PlayerHurt(Event event, const char[] eventName, bool dontBroadcast) {
    RevokeFreeday(GetClientOfUserId(event.GetInt("attacker")));
    return Plugin_Continue;
}

public Action Event_PlayerSpawn(Event event, const char[] eventName, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if(TF2_GetClientTeam(client) == TFTeam_Red) {
        Log("removing client %L weapons on spawn.", client);
        CreateTimer(0.1, Timer_RemovePlayerWeapons, client);
    } else {
        Log("saw client %L spawn.", client);
    }

    return Plugin_Continue;
}

public Action Timer_RemovePlayerWeapons(Handle _t, any clientAny) {
    int client = view_as<int>(clientAny);
    JailbreakRemoveWeapons(client, false);
    return Plugin_Stop;
}

public void OnClientDisconnect_Post(int client) {
    if(IsCurrentWarden(client)) {
        RemoveWarden();
    } else if(freedayClients[client][0]) {
        freedayClients[client][0] = false;
        CloseHandle(freedayClients[client][1]);
    }
}


public Action TF2_CalcIsAttackCritical(int client, int _b, char[] _n, bool &result) {
    TFTeam team = TF2_GetClientTeam(client);

    switch(cvCriticals.IntValue) {
    case 1:
        if(team == TFTeam_Red) { result = true; return Plugin_Handled; }
    case 2:
        if(team == TFTeam_Blue) { result = true; return Plugin_Handled; }
    case 3: {
        result = true;
        return Plugin_Handled;
    }
    case 4:
        if(GetClientFromSerial(currentWardenClient) == client) { result = true; return Plugin_Handled; }
    }

    return Plugin_Continue;
}
