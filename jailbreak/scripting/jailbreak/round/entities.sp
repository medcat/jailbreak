void JailbreakHandleEntities() {
    RemoveCurrentEntities();
    CreateArenaRules();
}

void RemoveCurrentEntities() {
    Entity_KillAllByClassName("tf_gamerules");
    Entity_KillAllByClassName("game_round_win");
    Entity_KillAllByClassName("team_round_timer");
    Entity_KillAllByClassName("tf_logic_arena");
    // we don't want any of them pesky gamemodes on our turf
    Entity_KillAllByClassName("tf_logic_hybrid_ctf_cp");
    Entity_KillAllByClassName("tf_logic_koth");
    Entity_KillAllByClassName("tf_logic_medieval");
    Entity_KillAllByClassName("tf_logic_multiple_escort");
    Entity_KillAllByClassName("tf_logic_training_mode");
}

void CreateArenaRules() {
    int ale;
    int ent;

    if((ent = FindEntityByClassname(-1, "tf_logic_arena")) != -1) {
        ale = ent;
    } else {
        ale = CreateEntityByName("tf_logic_arena");
        DispatchKeyValueFloat(ale, "CapEnableDelay", 2147483646.0);
        DispatchSpawn(ale);
    }
}
