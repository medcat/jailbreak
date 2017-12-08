ConVar cvRoundTime;
ConVar cvWardenFriendlyFire;
ConVar cvWardenSoftCollisions;
ConVar cvWardenHardCollisions;
ConVar cvCriticals;
ConVar cvBalanceAlgorithm;
ConVar cvBalanceRatio;
ConVar cvGroupFreedayCount;
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

/*int gameRulesEntity = -1;*/
int roundTimeSeconds = 0;
int gameRoundWinEntity = -1;
int teamRoundTimerEntity = -1;
Handle roundTimer = null;
/*int arenaLogicEntity = -1;*/

int currentWardenClient = 0;
Handle wardenDeclareSync = null;
Handle roundTimerSync = null;
Menu wardenMenu = null;
bool wardenAllowed = false;

Menu lastRequestMenu;
KeyValues lastRequests;

int beamModel = -1;
int haloModel = -1;

JailbreakRoundType roundType;
JailbreakRoundType nextRoundType;
int nextFreedays[MAXPLAYERS + 2] = { 0 };
any freedayClients[MAXPLAYERS + 1][5];
char freedayCommand[256];
int freedayCommandTarget = 0;
int freedayGroupRemaining = 0;
