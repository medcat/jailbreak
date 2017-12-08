void InitializeConVars() {
    // 0 <= cvRoundTime <= 30 minutes
    cvRoundTime = CreateConVar("sm_jailbreak_round_time", "600", "The round time, in seconds.", FCVAR_NOTIFY, true, 0.0, true, 60.0 * 30.0);
    cvWardenFriendlyFire = CreateConVar("sm_jailbreak_warden_friendly_fire", "1", "Can the warden set friendly fire?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    cvWardenSoftCollisions = CreateConVar("sm_jailbreak_warden_collisions_soft", "1", "Can the warden set soft collisions?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    cvWardenHardCollisions = CreateConVar("sm_jailbreak_warden_collisions_hard", "1", "Can the warden set hard collisions?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    cvCriticals = CreateConVar("sm_jailbreak_criticals", "2", "Who gets crits? (0 = nobody, 1 = reds, 2 = blues, 3 = all, 4 = warden only)", FCVAR_NOTIFY, true, 0.0, true, 4.0);
    cvBalanceAlgorithm = CreateConVar("sm_jailbreak_balance_algorithm", "1", "The balancing algorithm used. (0 = none, 1 = default)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    cvBalanceRatio = CreateConVar("sm_jailbreak_balance_ratio", "0.5", "The balance ratio, of blues to reds (blues/reds).", FCVAR_NOTIFY, true, 0.0, true, 3.0);
    cvGroupFreedayCount = CreateConVar("sm_jailbreak_group_freeday_count", "3", "The number of freedays for a group freeday.", FCVAR_NOTIFY, true, 0.0, true, 32.0);

    cvGameFriendlyFire = FindConVar("mp_friendlyfire");
    cvGameNoHardCollisions = FindConVar("tf_avoidteammates");
    cvGameSoftCollisions = FindConVar("tf_avoidteammates_pushaway");
    cvGameAutoTeamBalance = FindConVar("mp_autoteambalance");
    cvGameScrambleTeamsAuto = FindConVar("mp_scrambleteams_auto");
    cvGameStalemateEnable = FindConVar("mp_stalemate_enable");
    cvGameTeamsUnbalanceLimit = FindConVar("mp_teams_unbalance_limit");
    cvGameArenaFirstBlood = FindConVar("tf_arena_first_blood");
    cvGameArenaUseQueue = FindConVar("tf_arena_use_queue");
    cvGameArenaTeamSize = FindConVar("tf_arena_override_team_size");
}

void PrepareGameConVars() {
    cvGameFriendlyFire.SetBool(false, true, true);
    cvGameNoHardCollisions.SetBool(true, true, true);
    cvGameSoftCollisions.SetBool(true, true, true);
    cvGameAutoTeamBalance.SetBool(false, true, true);
    cvGameScrambleTeamsAuto.SetBool(false, true, true);
    cvGameStalemateEnable.SetBool(false, true, true);
    cvGameTeamsUnbalanceLimit.SetInt(32, true, true);
    cvGameArenaFirstBlood.SetBool(false, true, true);
    cvGameArenaUseQueue.SetBool(false, true, true);
    cvGameArenaTeamSize.SetInt(MAXPLAYERS, true, true);
}
