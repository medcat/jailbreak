#if defined _jailbreak_included
	#endinput
#endif
#define _jailbreak_included

#define JAILBREAK_TAG "[{silver}Jailbreak{white}] "
#define JAILBREAK_REPLY "[{silver}Jailbreak{white}] %T"

public SharedPlugin __pl_jailbreak =
{
    name = "jailbreak",
    file = "jailbreak.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_jailbreak_SetNTVOptional() {
    MarkNativeAsOptional("Jailbreak_GetWardenMenu");
    MarkNativeAsOptional("Jailbreak_GetLastRequestMenu");
    MarkNativeAsOptional("Jailbreak_GiveFreeday");
    MarkNativeAsOptional("Jailbreak_RemoveFreeday");
    MarkNativeAsOptional("Jailbreak_AddFreeday");
    MarkNativeAsOptional("Jailbreak_IsClientFreeday");
    MarkNativeAsOptional("Jailbreak_GetWarden");
    MarkNativeAsOptional("Jailbreak_SetWarden");
    MarkNativeAsOptional("Jailbreak_ClearWarden");
    MarkNativeAsOptional("Jailbreak_IsClientWarden");
    MarkNativeAsOptional("Jailbreak_IsWardenAllowed");
    MarkNativeAsOptional("Jailbreak_IsWardenActive");
    MarkNativeAsOptional("Jailbreak_GetRoundType");
    MarkNativeAsOptional("Jailbreak_GetNextRoundType");
    MarkNativeAsOptional("Jailbreak_SetNextRoundType");
    MarkNativeAsOptional("Jailbreak_TriggerMapEvent");
    MarkNativeAsOptional("Jailbreak_TriggerMapEventEx");
}
#endif
/**
 * What type of round the round should be. A normal jailbreak round.  Nothing
 * special about this.
 */
#define JAILBREAK_ROUNDTYPE_NORMAL 0

/**
 * What type of round the round should be. A round where all of the prisoners
 * are allowed a freeday; however, the plugin does not grant freeday to all of
 * the prisoners.
 */
#define JAILBREAK_ROUNDTYPE_FREEDAY 1

/**
 * What type of round the round should be. A round where all of the prisoners
 * are allowed a freeday; however, the plugin does not grant freeday to all of
 * the prisoners.
 */
#define JAILBREAK_ROUNDTYPE_EXTERNAL 2

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
forward Action OnJailbreakRoundStart(Event event, int roundType);

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
forward Action OnJailbreakPreBalance(int roundType);

/**
 * Called after the round ends.  This is triggered at the end of all of the
 * jailbreak plugin logic.  The result of this is passed to the HookEvent that
 * it is tied to, and is mostly ignored.  The roundType parameter here is for
 * the previous round's roundType; for the next round's roundType, check
 * Jailbreak_GetNextRoundType (note that Jailbreak_GetRoundType will *always*
 * return `JAILBREAK_ROUNDTYPE_NORMAL` at this point).
 *
 * @param event				The event that triggered the round end.
 * @param roundType			The old round type.
 * @return					The result is passed directly to the EventHook that
 *        					this event is attached to, and so is likely to do
 *        					nothing.
 */
forward Action OnJailbreakRoundEnd(Event event, int roundType);

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
 * Attempts to clear the current warden.  An attempt to clear the warden
 * out-of-round will fail.  This may be blocked by the
 * `OnJailbreakRemoveWarden` forward.
 *
 * @return					True if warden was cleared successfully, false otherwise.
 */
native bool Jailbreak_ClearWarden();

/**
 * Checks if the given client is the current warden.
 *
 * @return					True if the client is warden, false otherwise.
 */
native bool Jailbreak_IsClientWarden(int client);

/**
 * Checks if warden is allowed.  This mostly means that a client can become
 * warden (or has become warden).
 *
 * @return					True if warden is allowed.
 */
native bool Jailbreak_IsWardenAllowed();

/**
 * Checks if warden is active.  This mostly means that an active client is
 * warden.
 *
 * @return					True if warden is active.
 */
native bool Jailbreak_IsWardenActive();

/**
 * Retrieves the current round type.
 *
 * @return					The round type.
 */
native int Jailbreak_GetRoundType();

/**
 * Retrieves the next round type.
 *
 * @return					The next round type.
 */
native int Jailbreak_GetNextRoundType();

/**
 * Sets the next round type.  The most opportune places to set this are
 * `OnJailbreakRoundEnd` or `OnJailbreakPreBalance`.
 *
 * @param roundType			The new round type.
 * @noreturn
 * @error					If the roundType isn't one of the roundType enum
 *       					values.
 */
native void Jailbreak_SetNextRoundType(int roundType);
