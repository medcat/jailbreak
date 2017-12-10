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
    wardenMenu = new Menu(Menu_Warden, MenuAction_Select | MenuAction_Select |
        MenuAction_Cancel | MenuAction_End | MenuAction_DisplayItem);
    wardenMenu.SetTitle("%T", "Jailbreak_Warden_Menu_Title", LANG_SERVER);
    char buffer[256];

    FormatEx(buffer, sizeof(buffer), "%T",
        "Jailbreak_Warden_Menu_FriendlyFire", LANG_SERVER);
    wardenMenu.AddItem("sm_jailbreak_warden_friendlyfire", buffer);
    FormatEx(buffer, sizeof(buffer), "%T",
        "Jailbreak_Warden_Menu_SoftCollisions", LANG_SERVER);
    wardenMenu.AddItem("sm_jailbreak_warden_softcollisions", buffer);
    FormatEx(buffer, sizeof(buffer), "%T",
        "Jailbreak_Warden_Menu_HardCollisions", LANG_SERVER);
    wardenMenu.AddItem("sm_jailbreak_warden_hardcollisions", buffer);
}

public int Menu_Warden(Menu menu, MenuAction action, int client, int item) {
    char info[256];
    char display[256];
    int style;

    switch(action) {
        case MenuAction_Select: {
            menu.GetItem(item, info, sizeof(info), _, "", 0);
            FakeClientCommand(client, "%s", info);
        }

        case MenuAction_DisplayItem: {
            menu.GetItem(item, info, sizeof(info), style, "", 0);

            if(StrEqual(info, "sm_jailbreak_warden_friendlyfire")) {
                if(cvGameFriendlyFire.BoolValue == true) {
                    Format(display, sizeof(display), "%T",
                        "Jailbreak_Warden_Menu_DisableFriendlyFire", client);
                } else {
                    Format(display, sizeof(display), "%T",
                        "Jailbreak_Warden_Menu_EnableFriendlyFire", client);
                }

                return RedrawMenuItem(display);
            } else if(StrEqual(info, "sm_jailbreak_warden_softcollisions")) {
                if(cvGameSoftCollisions.BoolValue == true) {
                    Format(display, sizeof(display), "%T",
                        "Jailbreak_Warden_Menu_DisableSoftCollisions", client);
                } else {
                    Format(display, sizeof(display), "%T",
                        "Jailbreak_Warden_Menu_EnableSoftCollisions", client);
                }

                return RedrawMenuItem(display);
            } else if(StrEqual(info, "sm_jailbreak_warden_hardcollisions")) {
                if(cvGameNoHardCollisions.BoolValue == false) {
                    Format(display, sizeof(display), "%T",
                        "Jailbreak_Warden_Menu_DisableHardCollisions", client);
                } else {
                    Format(display, sizeof(display), "%T",
                        "Jailbreak_Warden_Menu_EnableHardCollisions", client);
                }

                return RedrawMenuItem(display);
            }
        }
    }

    return 0;
}
