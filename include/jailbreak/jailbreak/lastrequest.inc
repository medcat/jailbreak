#if defined _jailbreak_lastrequest_included
	#endinput
#endif
#define _jailbreak_lastrequest_included

public SharedPlugin __pl_jailbreak_lastrequest =
{
    name = "jailbreak_lastrequest",
    file = "jailbreak_lastrequest.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_jailbreak_lastrequest_SetNTVOptional() {
	MarkNativeAsOptional("Jailbreak_GiveLastRequest");
}
#endif

methodmap LastRequest < StringMap {
    public LastRequest() {
        return view_as<LastRequest>(new StringMap());
    }

    public void GetName(char[] name, int len) {
        GetTrieString(this, "name", name, len);
    }

    public void SetName(char[] name) {
        SetTrieString(this, "name", name, true);
    }

    public void GetAction(char[] action, int len) {
        GetTrieString(this, "action", action, len);
    }

    public void SetAction(char[] action) {
        SetTrieString(this, "action", action);
    }

    public void GetDescription(char[] desc, int len) {
        GetTrieString(this, "description", desc, len)
    }

    public void SetDescription(char[] desc) {
        SetTrieString(this, "description", desc);
    }
}

/**
 * Called when a player selects a last request.  This is mostly used to
 * implement custom LRs.  The names used internally are dependent on the
 * last_requests.cfg file; by default, they are `Freeday_Single`,
 * `Freeday_Group`, `Freeday_All`, `Suicide`, `Guard_Melee_Only`, and
 * `Custom_Request`.
 *
 * @param client			The client that chose the last request.
 * @return					If the result is anything but Plugin_Continue, the
 *        					LR will be treated as handled, and the default code
 *        					will not run.
 */
forward Action OnJailbreakLastRequest(int client, LastRequest request);

/**
 * Gives the client a last request.  This must be done within a round, and
 * the client must be alive.
 *
 * @param client			The client that receives the last request.
 * @noreturn
 */
native void Jailbreak_GiveLastRequest(int client);
