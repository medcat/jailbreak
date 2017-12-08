public Action Command_Warden_Menu(int client, int args) {
    bool isAdmin = CheckCommandAccess(client, "sm_jailbreak_warden_menu",
        ADMFLAG_KICK, false);
    if(!IsCurrentWarden(client) && !isAdmin) {
        CReplyToCommand(client, JAILBREAK_REPLY, "Jailbreak_Warden_NotWarden",
            client);
    }

    wardenMenu.Display(client, MENU_TIME_FOREVER);
}

void BuildWardenMenu() {
    wardenMenu = new Menu(Menu_Warden);
    wardenMenu.SetTitle("%T", "Jailbreak_Warden_Menu_Title", LANG_SERVER);
    char buffer[256];

    if(cvGameFriendlyFire.BoolValue == true)
        FormatEx(buffer, sizeof(buffer), "%T",
            "Jailbreak_Warden_Menu_DisableFriendlyFire", LANG_SERVER);
    else
        FormatEx(buffer, sizeof(buffer), "%T",
            "Jailbreak_Warden_Menu_EnableFriendlyFire", LANG_SERVER);
    wardenMenu.AddItem("sm_jailbreak_warden_friendlyfire", buffer);

    if(cvGameSoftCollisions.BoolValue == true)
        FormatEx(buffer, sizeof(buffer), "%T",
            "Jailbreak_Warden_Menu_DisableSoftCollisions", LANG_SERVER);
    else
        FormatEx(buffer, sizeof(buffer), "%T",
            "Jailbreak_Warden_Menu_EnableSoftCollisions", LANG_SERVER);
    wardenMenu.AddItem("sm_jailbreak_warden_softcollisions", buffer);

    if(cvGameNoHardCollisions.BoolValue == false)
        FormatEx(buffer, sizeof(buffer), "%T",
            "Jailbreak_Warden_Menu_DisableHardCollisions", LANG_SERVER);
    else
        FormatEx(buffer, sizeof(buffer), "%T",
            "Jailbreak_Warden_Menu_EnableHardCollisions", LANG_SERVER);
    wardenMenu.AddItem("sm_jailbreak_warden_hardcollisions", buffer);
}

public int Menu_Warden(Menu menu, MenuAction action, int client, int item) {
    if(action == MenuAction_Select) {
        char info[256];
        char display[256];
        int style;
        menu.GetItem(item, info, sizeof(info), style, display, sizeof(display));
        FakeClientCommand(client, "%s", info);
    }
}
