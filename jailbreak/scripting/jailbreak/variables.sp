ConVar cvRoundTime;
ConVar cvWardenFriendlyFire;
ConVar cvWardenSoftCollisions;
ConVar cvWardenHardCollisions;
ConVar cvCriticals;
ConVar cvBalanceAlgorithm;
ConVar cvBalanceRatio;
/* ConVar cvGroupFreedayCount; */
ConVar cvGameFriendlyFire;
ConVar cvGameNoHardCollisions;
ConVar cvGameSoftCollisions;
ConVar cvGameAutoTeamBalance;
ConVar cvGameScrambleTeamsAuto;
ConVar cvGameStalemateEnable;
ConVar cvGameTeamsUnbalanceLimit;
ConVar cvGameArenaFirstBlood;
ConVar cvGameArenaUseQueue;
ConVar cvGameArenaTeamSize;
ConVar cvGameArenaRoundTime;

/*Handle roundTimer = null;*/

int currentWardenClient = 0;
Handle wardenDeclareSync = null;
Menu wardenMenu = null;
bool wardenAllowed = false;

/* Menu lastRequestMenu; */
/* KeyValues lastRequests; */

int beamModel = -1;
int haloModel = -1;

int roundType;
int nextRoundType;
/* int nextFreedays[MAXPLAYERS + 2] = { 0 }; */
any freedayClients[MAXPLAYERS + 1][5];
/* char freedayCommand[256]; */
/* int freedayCommandTarget = 0; */
/* int freedayGroupRemaining = 0; */

// forwards
Handle forwardRoundStart = null;
Handle forwardPreBalance = null;
Handle forwardRoundEnd = null;
/* Handle forwardLastRequest = null; */
Handle forwardGiveFreeday = null;
Handle forwardRemoveFreeday = null;
Handle forwardGiveWarden = null;
Handle forwardRemoveWarden = null;
