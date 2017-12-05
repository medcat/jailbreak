// So we're going to assume that by having this plugin enabled, they want this
// plugin to run.  So we are not going to check that the map works, or anything.

// The round time.  This defaults to 10 minutes.  Values are in seconds.
ConVar cvRoundTime;
// Can the warden enable friendly fire?
ConVar cvWardenFriendlyFire;
// Can the warden enable soft collisions?
ConVar cvWardenSoftCollisions;
// Can the warden enable hard collisions?
ConVar cvWardenHardCollisions;
// Who gets crits? (0 = nobody, 1 = reds, 2 = blues, 3 = all, 4 = warden only)
ConVar cvCriticals;

// External convars!
// Friendly fire?
ConVar cvFriendlyFire;
// Hard collisions?
ConVar cvNoHardCollisions;
// Soft collisions?
ConVar cvSoftCollisions;

stock void InitializeConVars() {
    // 0 <= cvRoundTime <= 30 minutes
    cvRoundTime = CreateConVar("sm_jailbreak_round_time", "600", "The round time, in seconds.", FCVAR_NOTIFY, true, 0, true, 60 * 30);
    cvWardenFriendlyFire = CreateConVar("sm_jailbreak_warden_friendly_fire", "1", "Can the warden set friendly fire?", FCVAR_NOTIFY, true, 0, true, 1);
    cvWardenSoftCollisions = CreateConVar("sm_jailbreak_warden_collisions_soft", "1", "Can the warden set soft collisions?", FCVAR_NOTIFY, true, 0, true, 1);
    cvWardenHardCollisions = CreateConVar("sm_jailbreak_warden_collisions_hard", "1", "Can the warden set hard collisions?", FCVAR_NOTIFY, true,  0, true, 1);
    cvCriticals = CreateConVar("sm_jailbreak_criticals", "2", "Who gets crits? (0 = nobody, 1 = reds, 2 = blues, 3 = all, 4 = warden only)", FCVAR_NOTIFY, true, 0, true, 4);

    cvFriendlyFire = FindConVar("mp_friendlyfire");
    cvNoHardCollisions = FindConVar("tf_avoidteammates");
    cvSoftCollisions = FindConVar("tf_avoidteammates_pushaway");
}
