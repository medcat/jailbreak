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

int gameRulesEntity = -1;
int gameRoundWinEntity = -1;
int teamRoundTimerEntity = -1;
int arenaLogicEntity = -1;

int currentWardenClient = 0;
Handle wardenDeclareSync = null;
