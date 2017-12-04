# Jailbreak

This plugin implements the Jailbreak gamemode in Team Fortress 2.  That's it.
Jailbreak is a gamemode that diverges from the typical Team Fortress 2 gameplay
completely - instead of Red vs. Blue, where both teams are constantly engaged
in combat, Jailbreak is instead Prisoners (the Red team) vs. the Guards (the
Blue team).  The prisoners are stripped of all weapons (save their melees), and
they are forced to play various minigames, until the last prisoner is standing -
and the last prisoner is given a "Last Request," where they get to decide between
a few different options (often for the next "day" (or round)) before they are
too killed.  Prisoners can rebel, fighting against the guards, by accessing
the armory - which contains healthpacks and ammo, but is often locked to the
Prisoners by the default door, meaning they have to find different paths into it.
Often, there is ammo around the map as well.

The actual rules and implementation of Jailbreak completely depends on the server
that runs it - have fun with it!  Eventually, I'll include an example of rules
that you can have for your Jailbreak server here.

## ConVars

Jailbreak has quite a few ConVars to control what can happen for every round.
Here are all of the ConVars available for use:

### `sm_jailbreak_round_time`
This is the round time for every day.  If the timer ends before the round has
ended naturally (e.g. everyone is alive), the round ends in a stalemate.
