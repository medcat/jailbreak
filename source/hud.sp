stock void ShowSyncHudTextAll(Handle sync, const char[] message, any ...) {
    char[] formatted = new char[256 * 4];
    VFormat(formatted, 256 * 4, message, 3);

    for(int i = 1; i <= MaxClients; i++) {
        if(!IsClientConnected(i) || !IsClientInGame(i)) continue;
        ShowSyncHudText(i, sync, "%s", formatted);
    }
}
