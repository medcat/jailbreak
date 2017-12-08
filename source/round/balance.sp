void StartJailbreakBalance() {
    JailbreakAutoBalance();
}

void JailbreakAutoBalance() {
    int algorithm = cvBalanceAlgorithm.IntValue;
    Log("beginning jailbreak balance algorithm...");
    if(algorithm == 0) return;
    else if(algorithm == 1) JailbreakBalanceDefault();
    Log("jailbreak balance algorithm complete!");
}

void StopJailbreakBalance() {
}

stock void JailbreakBalanceMove(int client) {
    TF2_ChangeClientTeam(client, TFTeam_Red);
    TF2_RespawnPlayer(client);
    Event event = CreateEvent("teamplay_teambalanced_player", true);
    event.SetInt("player", client);
    event.SetInt("team", view_as<int>(TFTeam_Red));
    event.Fire(false);
}

stock void JailbreakNotifyBalance() {
    Event event = CreateEvent("teamplay_alert", true);
    event.SetInt("alert_type", 2);
    event.Fire(false);
}

// balances based on score - ping.  If a user is given the
// `sm_jailbreak_balance_override` override, it will skip the autobalance.
// PLEASE KEEP IN MIND that using this override can cause blue team to exceed
// the given ratio.
void JailbreakBalanceDefault() {
    int[] clients = new int[MaxClients];
    int clientsLength = 0;
    int moved = 0;
    float ratio = cvBalanceRatio.FloatValue;

    Log("checking player ratio...");
    if((float(GetTeamClientCount(view_as<int>(TFTeam_Blue))) /
        float(GetTeamClientCount(view_as<int>(TFTeam_Red)))) <= ratio) { return; }
    Log("player ratio undesirable, beginning balance...");
    JailbreakNotifyBalance();

    for(int i = 1; i <= MaxClients; i++) {
        if(IsClientInGame(i) && TF2_GetClientTeam(i) == TFTeam_Blue &&
            !CheckCommandAccess(i, "sm_jailbreak_balance_override", ADMFLAG_ROOT, false)) {
            Log("marking player %L as movable.", i);
            clients[clientsLength++] = i;
        }
    }

    SortCustom1D(clients, clientsLength, Sort_JailbreakBalanceDefault);
    while((float(GetTeamClientCount(view_as<int>(TFTeam_Blue))) /
        float(GetTeamClientCount(view_as<int>(TFTeam_Red)))) > ratio &&
        moved < clientsLength) {
        Log("moving player %L.", clients[moved]);
        int move = clients[moved++];
        JailbreakBalanceMove(move);
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
