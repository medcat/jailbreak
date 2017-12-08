ConVar cvRoundTime;
ConVar cvWardenFriendlyFire;
ConVar cvWardenSoftCollisions;
ConVar cvWardenHardCollisions;
ConVar cvCriticals;
ConVar cvBalanceAlgorithm;
ConVar cvBalanceRatio;
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
bool wardenAllowed = false;

any freedayClients[MAXPLAYERS + 1][5];
int beamModel = -1;
int haloModel = -1;
