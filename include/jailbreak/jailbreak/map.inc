#if defined _jailbreak_map_included
	#endinput
#endif
#define _jailbreak_map_included

public SharedPlugin __pl_jailbreak_map =
{
    name = "jailbreak_map",
    file = "jailbreak_map.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_jailbreak_map_SetNTVOptional() {
    MarkNativeAsOptional("Jailbreak_TriggerMapEvent");
    MarkNativeAsOptional("Jailbreak_TriggerMapEventEx");
}
#endif

/**
 * Map events.  These are triggered during the lifecycle of the plugin,
 * assuming both the jailbreak_map plugin is loaded and the map is supported.
 */
enum JailbreakMapEvent {
    /**
     * Initialize the map.  This really shouldn't be called by any plugins,
     * as it should only be called once at the beginning of a round.
     */
    JailbreakMapEvent_Initialize,
    /**
     * Opens the cells in the map.
     */
    JailbreakMapEvent_OpenCells,
    /**
     * Closes the cells in the map.
     */
    JailbreakMapEvent_CloseCells,
}

/**
 * Called when a map event is triggered.  This called for all map events,
 * regardless of the origin.  If the return of the forward is anything but
 * `Plugin_Continue`, the default action of performing the event is ignored.
 * Please note that if you call `Jailbreak_TriggerMapEvent` or
 * `Jailbreak_TriggerMapEventEx` from this forward, you may end up with infinite
 * recursion.
 *
 * @param mapEvent			The map event.
 * @return					If the result is `Plugin_Continue`, then the default
 *        					action of triggering the map event occurrs.
 */
forward Action OnJailbreakMapEvent(const char[] mapEvent);


/**
 * Triggers a map event for jailbreak.  This can be used to open or close
 * cells, for plugins that want to open or close them.  This can be used, for
 * example, to implement a last request.  If the map is unsupported, this
 * returns false.
 *
 * @param mapEvent			The map event to trigger.
 * @return					Whether or not the event was triggered.  In the
 *        					case of an unsupported map, this returns false.
 * @error					If the mapEvent isn't one of the MapEvent enum
 *       					values.
 */
native bool Jailbreak_TriggerMapEvent(JailbreakMapEvent mapEvent);

/**
 * Triggers a custom map event for jailbreak.  This can be used to trigger
 * custom defined events.  This shouldn't be used to trigger any of the normal
 * events, but rather events that are defined in the maps.cfg file.
 *
 * @params event			The map event to trigger.
 * @return					Whether or not the event was triggered.  In the
 *        					case of an unsupported map, this returns false.
 */
native bool Jailbreak_TriggerMapEventEx(const char[] event);
