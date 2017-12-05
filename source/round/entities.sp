int gameRulesEntity = -1;
int gameRoundWinEntity = -1;
int teamRoundTimerEntity = -1;
int arenaLogicEntity = -1;

stock void RemoveCurrentEntities() {
    int ent = -1;
    /*for(ent = -1; (ent = FindEntityByClassname(ent, "tf_gamerules")) != -1;) AcceptEntityInput(ent, "Kill");*/
    /*for(ent = -1; (ent = FindEntityByClassname(ent, "game_round_win")) != -1;) AcceptEntityInput(ent, "Kill");*/
    for(ent = -1; (ent = FindEntityByClassname(ent, "team_round_timer")) != -1;) AcceptEntityInput(ent, "Kill");
}

stock void CreateGameRules() {
    int gre = -1;
    int ent = -1;

    if((ent = FindEntityByClassname(-1, "tf_gamerules")) != -1) {
        gre = ent;
    } else {
        gre = CreateEntityByName("tf_gamerules");
        DispatchSpawn(gre);
    }

    gameRulesEntity = EntIndexToEntRef(gre);
}

stock void CreateRoundWin() {
    int grw = -1;
    int ent = -1;

    if((ent = FindEntityByClassname(-1, "game_round_win")) != -1) {
        grw = ent;
    } else {
        grw = CreateEntityByName("game_round_win");
        DispatchSpawn(grw);
    }

    gameRoundWinEntity = EntIndexToEntRef(grw);
}

stock void CreateRoundTimer() {
    int trt = CreateEntityByName("team_round_timer");
    DispatchKeyValueFloat(trt, "timer_length", cvRoundTime.FloatValue);
    HookSingleEntityOutput(trt, "OnFinished", Event_RoundTimerComplete, false);
    cvRoundTime.AddChangeHook(Event_RoundTimeChanged);
    DispatchSpawn(trt);
    teamRoundTimerEntity = EntIndexToEntRef(trt);
}

stock void ModifyArenaRules() {
    arenaLogicEntity = EntIndexToEntRef(FindEntityByClassname(-1, "tf_logic_arena"));
}

public void Event_RoundTimeChanged(ConVar roundTime, const char[] _o, const char[] _n) {
    if(teamRoundTimerEntity != -1) {
        SetVariantInt(roundTime.IntValue);
        AcceptEntityInput(teamRoundTimerEntity, "SetTime");
    }
}

public void Event_RoundTimerComplete(const char[] _o, int _c, int _a, float _d) {
    SetVariantInt(TFTeam_Blue);
    AcceptEntityInput(gameRoundWinEntity, "SetTeam");
    AcceptEntityInput(gameRoundWinEntity, "RoundWin");
}
