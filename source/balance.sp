void StartJailbreakBalance() {
    int algorithm = cvBalanceAlgorithm.IntValue;
    if(algorithm == 0) return;
    else if(algorithm == 1) JailbreakBalanceDefault();

    HookEvent("player_spawn", Event_PlayerSpawnBalance, EventHookMode_Pre);
}

void StopJailbreakBalance() {
    UnhookEvent("player_spawn", Event_PlayerSpawnBalance, EventHookMode_Pre);
}

public Action Event_PlayerSpawnBalance(Event event, const char[] _n, bool db) {
    if(event.GetInt("team") != view_as<int>(TFTeam_Blue)) {
        return Plugin_Continue;
    } else if((float(GetTeamClientCount(view_as<int>(TFTeam_Blue))) + 1.0 /
        float(GetTeamClientCount(view_as<int>(TFTeam_Red)))) < cvBalanceRatio.FloatValue) {
        return Plugin_Continue;
    }

    TF2_ChangeClientTeam(GetClientOfUserId(event.GetInt("userid")), TFTeam_Red);
    return Plugin_Handled;
}

// balances based on score - ping.  If a user is given the
// `sm_jailbreak_balance_override` override, it will skip the autobalance.
// PLEASE KEEP IN MIND that using this override can cause blue team to exceed
// the given ratio.
void JailbreakBalanceDefault() {
    int clients[MaxClients] = { 0 };
    int clientslen = 0;
    int moved = 0;
    int red_size = GetTeamClientCount(TFTeam_Red);
    int blu_size = GetTeamClientCount(TFTeam_Blue);
    float ratio = cvBalanceRatio.FloatValue;

    if((float(blu_size) / float(red_size)) < ratio) return;

    for(int i = 1; i <= MaxClients; i++) {
        if(IsClientInGame(i) && TF2_GetClientTeam(i) == TFTeam_Blue &&
            CheckCommandAccess(i, "sm_jailbreak_balance_override", ADMIN_ROOT, false)) {
            clients[clientslen++] = i;
        }
    }

    SortCustom1D(clients, client_length, Sort_JailbreakBalanceDefault);
    while((float(GetTeamClientCount(TFTeam_Blue)) / float(GetTeamClientCount(TFTeam_Red))) >= ratio &&
        moved < clientslen) {

        int move = clients[moved++];
        TF2_ChangeClientTeam(move, TFTeam_Red);
        TF2_RespawnPlayer(move);
    }
}

public int Sort_JailbreakBalanceDefault(int firstindex, int secondindex, const int[] array, Handle _h) {
    int first = array[firstindex];
    int second = array[secondindex];
    int entity = GetPlayerResourceEntity();
    int first_ping = GetEntProp(entity, Prop_Send, "m_iPing", 4, first);
    int first_score = GetEntProp(entity, Prop_Send, "m_iScore", 4, first);
    int second_ping = GetEntProp(entity, Prop_Send, "m_iPing", 4, second);
    int second_score = GetEntProp(entity, Prop_Send, "m_iScore", 4, second);

    int first_value = first_score - first_ping;
    int second_value = second_score - second_ping;

    // return first_value - second_value; // for ascending order
    return second_value - first_value; // for descending order
}
