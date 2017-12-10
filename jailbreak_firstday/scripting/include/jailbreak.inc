#if defined _jailbreak_included
	#endinput
#endif
#define _jailbreak_included

/**
 * What type of round the round should be.  This is used in order to determine
 * how a previous last request should be handled.
 */
enum JailbreakRoundType {
    /**
     * A normal jailbreak round.  Nothing special about this.
     */
    JailbreakRoundType_Normal,
    /**
     * A jailbreak round that is being modified externally by another plugin.
     * The default behavior of the jailbreak plugin is to treat this exactly
     * like a Normal round; this can be used to implement custom Last Requests.
     */
    JailbreakRoundType_External,
    /**
     * A round where a specific command is run at the start of the round.  The
     * source and actual command are kept internally.
     */
    JailbreakRoundType_Command,

    /**
     * A round where one or more prisoners (reds) are given freedays at the
     * start of the round.
     */
    JailbreakRoundType_FreedayGroup,

    /**
     * A round where all of the prisoners are allowed a freeday; however, the
     * plugin does not grant freeday to all of the prisoners.
     */
    JailbreakRoundType_FreedayAll,

    /**
     * A round where the guards are stripped to their melee, and may only use
     * those for the duration of the round.
     */
    JailbreakRoundType_GuardMeleeOnly,

    /**
     * A round where the previous last request was a custom last request.
     */
    JailbreakRoundType_CustomLastRequest,
}

/**
 * Called when a jailbreak round start.  This is called with the round start
 * event that triggered the round start for jailbreak, and the round type.
 * This is called at the end of the RoundStart, and so the game is all ready
 * to go.
 *
 * @param event				The event that triggered the round start.
 * @param roundType			The round type of the new round.
 * @return					The result of this function is passed directly to
 *        					the HookEvent trigger; thus, it is unlikely it
 *        					will do anything with anything but Plugin_Continue.
 */
forward Action OnJailbreakRoundStart(Event event, JailbreakRoundType roundType);

/**
 * Called just before a balance occurs.  The roundType is given for reference.
 * If this returns anything but Plugin_Continue, then the default balance
 * algorithm will be skipped (not recommended except for custom LRs or balance
 * algorithms).  This is called before most (all but the cvar setting) of the
 * round start has completed (this means that SetNextRoundType will affect the
 * round that this is running for, although it will discard the previous round
 * type).
 *
 * @param roundType			The round type of the new round.
 * @return					If the result is anything but Plugin_Continue, the
 *        					default balance algorithm is skipped.
 */
forward Action OnJailbreakPreBalance(JailbreakRoundType roundType);

/**
 * Called when a player selects a last request.  This is mostly used to
 * implement custom LRs.  The names used internally are dependent on the
 * last_requests.cfg file; by default, they are `Freeday_Single`,
 * `Freeday_Group`, `Freeday_All`, `Suicide`, `Guard_Melee_Only`, and
 * `Custom_Request`.
 *
 * @param client			The client that chose the last request.
 * @param name				The name of the choice.  This should be the
 *            				programmatic key used by your plugin to identify
 *            				which last request is chosen.
 * @param description		The menu description for the item that was chosen.
 *                   		Likely safe to ignore.
 * @return					If the result is anything but Plugin_Continue, the
 *        					LR will be treated as handled, and the default code
 *        					will not run.
 */
forward Action OnJailbreakLastRequest(int client, char[] name, char[] description);

/**
 * Called after the round ends.  This is triggered at the end of all of the
 * jailbreak plugin logic.  The result of this is passed to the HookEvent that
 * it is tied to, and is mostly ignored.  The roundType parameter here is for
 * the previous round's roundType; for the next round's roundType, check
 * Jailbreak_GetNextRoundType (note that Jailbreak_GetRoundType will *always*
 * return JailbreakRoundType_Normal at this point).
 *
 * @param roundType			The old round type.
 * @return					The result is passed directly to the EventHook that
 *        					this event is attached to, and so is likely to do
 *        					nothing.
 */
forward Action OnJailbreakRoundEnd(JailbreakRoundType roundType);

/**
 * Called when a player is given a freeday.  If this returns anything but
 * Plugin_Continue, the freeday will not be given.  Please note that calling
 * Jailbreak_GiveFreeday also triggers this forward, and so may cause an
 * infinite loop if you are not careful.  The output of this forward is ignored
 * if the force parameter is true.
 *
 * @param client			The client that is receiving freeday.
 * @param force				Whether or not the output of this forward will be
 *             				ignored.  This is only true in the case of an admin
 *             				granting a freeday.
 * @return					If force and false, and the result is anything but
 *        					Plugin_Continue, then the freeday will not be given.
 */
forward Action OnJailbreakGiveFreeday(int client, bool force);

/**
 * Called when a player looses a freeday.  If this returns anything but
 * Plugin_Continue, the freeday will not be removed.  Please note that calling
 * Jailbreak_RemoveFreeday also triggers this forward, and so may cause an
 * infinite loop if you are not careful.  The output of this forward is ignored
 * if the force parameter is true.
 *
 * @param client			The client that is receiving freeday.
 * @param force				Whether or not the output of this forward will be
 *             				ignored.  This is only true in the case of an admin
 *             				revoking a freeday, or when the player dies, or at
 *             				the end of the round.
 * @return					If force is false, and the result is anything but
 *        					Plugin_Continue, then the freeday will not be removed.
 */
forward Action OnJailbreakRemoveFreeday(int client, bool force);

/**
 * Called when a player is given warden.  Only one player is a warden at a time.
 * If this returns anything but Plugin_Continue, the player will not be made
 * warden; however, if the force parameter is true, the return value of this
 * function is ignored.  Please note that calling Jailbreak_SetWarden in also
 * triggers this forward, and so may cause an infinite loop if you are not
 * careful.
 *
 * @param client			The client that is becoming warden.
 * @param force				Whether or not the output of this forward will be
 *             				ignored.  This is only in the case of an admin
 *             				forcing someone into warden.
 * @return					If force is false, and the result is anything but
 *        					Plugin_Continue, then the warden will not be given.
 */
forward Action OnJailbreakGiveWarden(int client, bool force);

/**
 * Called when a player is removed from warden.  Only one player is a warden at
 * a time.  If this returns anything but Plugin_Continue, the player will not be
 * removed from warden; however, if the force parameter is true, the return
 * value of this function is ignored.  Please note that calling
 * Jailbreak_SetWarden in also triggers this forward, and so may cause an
 * infinite loop if you are not careful.
 *
 * @param client			The client that is being removed from warden.
 * @param force				Whether or not the output of this forward will be
 *             				ignored.  This is only in the case of an admin
 *             				forcing someone out of warden.
 * @return					If force is false, and the result is anything but
 *        					Plugin_Continue, then the warden will not be removed.
 */
forward Action OnJailbreakRemoveWarden(int client, bool force);

/**
 * Retrieves the warden menu used for the sm_jailbreak_wardenmenu command.
 * This is mostly used to add items to that menu.  This handle is valid for the
 * lifetime of the jailbreak plugin.
 *
 * @return					The jailbreak warden menu.
 */
native Menu Jailbreak_GetWardenMenu();

/**
 * Retrieves the last request menu used for the sm_jailbreak_lastrequest
 * command.  This is mostly used to add items to that menu.  This handle is
 * valid for the lifetime of the jailbreak plugin.  The name of the item you
 * add will be passed to `OnJailbreakLastRequest`; It is recommended to prefix
 * your name with `MyPlugin_`, as it shares the same namespace as the keys in
 * the `last_requests.cfg` file.
 *
 * @return					The jailbreak last request menu.
 */
native Menu Jailbreak_GetLastRequestMenu();

/**
 * Attempts to give the specified client a freeday.  This can be blocked by any
 * `OnJailbreakGiveFreeday` forward.
 *
 * @param client			The client to give a freeday to.
 * @noreturn
 * @error					If the client is either not in game, or not alive.
 */
native void Jailbreak_GiveFreeday(int client);

/**
 * Attempts to remove a freeday from the specified client.  This can be blocked
 * by any `OnJailbreakRemoveFreeday` forward.
 *
 * @param client			The client to remove a freeday from.
 * @noreturn
 * @error					If the client is not in game.
 */
native void Jailbreak_RemoveFreeday(int client);

/**
 * Adds a freeday for the next round.  Note that this will do nothing unless the
 * next round type is set to `JailbreakRoundType_FreedayGroup` - see
 * `Jailbreak_SetNextRoundType`.
 *
 * @param client			The client to give a freeday to next round.
 * @return					If the client was added to the list, it returns true;
 *        					however, if the client was already in the list, it
 *        					returns false.
 * @error					If the client is not in game.
 */
native bool Jailbreak_AddFreeday(int client);

/**
 * Checks if the specified client has a freeday.
 *
 * @param client			The client to check a freeday for.
 * @noreturn
 * @error					If the client is either not in game, or not alive.
 */
native bool Jailbreak_IsClientFreeday(int client);

/**
 * Retrieves the current warden, or -1 if there is none.
 *
 * @return					The current warden, or -1 if there is none.
 */
native int Jailbreak_GetWarden();

/**
 * Attempts to set the warden to the specified client.  The client must be in
 * game, alive, and on blue team; and it must be during around.  An attempt to
 * set the warden out-of-round will fail.  This may be blocked by either the
 * `OnJailbreakRemoveWarden` or the `OnJailbreakGiveWarden` forwards, as it
 * triggers both.
 *
 * @param client			The client to make warden.
 * @return					True if warden was set successfully, false otherwise.
 * @error					If the client isn't in game, or isn't alive, or not
 *       					on blue team; or if it is out-of-round.
 */
native bool Jailbreak_SetWarden(int client);

/**
 * Retrieves the current round type.
 *
 * @return					The round type.
 */
native JailbreakRoundType Jailbreak_GetRoundType();

/**
 * Retrieves the next round type.
 *
 * @return					The next round type.
 */
native JailbreakRoundType Jailbreak_GetNextRoundType();

/**
 * Sets the next round type.  The most opportune places to set this are
 * `OnJailbreakRoundEnd` or `OnJailbreakPreBalance`.
 *
 * @param roundType			The new round type.
 * @noreturn
 * @error					If the roundType isn't one of the roundType enum
 *       					values.
 */
native void Jailbreak_SetNextRoundType(JailbreakRoundType roundType);
