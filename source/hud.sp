void ShowSyncHudTextAll(Handle sync, const char[] message, any ...) {
    char[] formatted = decl char[MAX_BUFFER_LENGTH];
    VFormat(formatted, MAX_BUFFER_LENGTH, 3);

    for(int i = 1; i <= MaxClients; i++) {
        if(!IsClientConnected(i)) continue;
        ShowSyncHudText(i, sync, "%s", formatted);
    }
}
