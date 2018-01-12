#if defined _jailbreak_blueban_included
	#endinput
#endif
#define _jailbreak_blueban_included

public SharedPlugin __pl_jailbreak_blueban =
{
    name = "jailbreak_blueban",
    file = "jailbreak_blueban.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_jailbreak_blueban_SetNTVOptional() {
    MarkNativeAsOptional("Jailbreak_TeamBan");
    MarkNativeAsOptional("Jailbreak_UnTeamBan");
	MarkNativeAsOptional("Jailbreak_TeamBanOffline");
    MarkNativeAsOptional("Jailbreak_UnTeamBanOffline");
}
#endif

forward Action OnJailbreakTeamBan(int client, int length, const char[] reason);
forward Action OnJailbreakTeamBanOffline(const char[] authId, int length,
    const char[] reason);

native void Jailbreak_TeamBan(int admin, int client, int length,
    const char[] reason);
native void Jailbreak_UnTeamBan(int client);
native void Jailbreak_TeamBanOffline(int admin, const char[] authId, int length,
    const char[] reason);
native void Jailbreak_UnTeamBanOffline(const char[] authId);
