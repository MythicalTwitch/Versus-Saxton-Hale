#if defined _steamtools_included
new bool:steamtools = false;
#endif
new OtherTeam = 2;
new HaleTeam = 3;
new VSHRoundState = ROUNDSTATE_INVALID;
new playing;
new healthcheckused;
new RedAlivePlayers;
new RoundCount;
new Special;
new Incoming;

#if defined MIKU_ON
new bool:VSHSpecial_Miku_Rage=false;
new Float:angleOffset[MAXPLAYERS+1];
new los_target;
new ignoreClient;
#endif

new Damage[MAXPLAYERS + 1];
new AirDamage[MAXPLAYERS + 1]; // Air Strike
new curHelp[MAXPLAYERS + 1];
new uberTarget[MAXPLAYERS + 1];

new VSHFlags[MAXPLAYERS + 1];
new Hale = -1;
new HaleHealthMax;
new HaleHealth;
new HaleHealthLast;
new HaleCharge = 0;
new HaleRage;
new NextHale;
new Float:Stabbed;
new Float:Marketed;
new Float:HPTime;
new Float:KSpreeTimer;
new Float:WeighDownTimer;
new KSpreeCount = 1;
new Float:UberRageCount;
new Float:GlowTimer;
new bool:bEnableSuperDuperJump;
new bool:bTenSecStart[2] = {false, false};
new bool:bSpawnTeleOnTriggerHurt = false;
new Handle:hHHHTeleTimer = INVALID_HANDLE;
new HHHClimbCount;
new bool:bNoTaunt = false;
new Handle:cvarVersion;
new Handle:cvarHaleSpeed;
new Handle:cvarPointDelay;
new Handle:cvarRageDMG;
new Handle:cvarRageDist;
new Handle:cvarAnnounce;
new Handle:cvarSpecials;
new Handle:cvarEnabled;
new Handle:cvarAliveToEnable;
new Handle:cvarPointType;
new Handle:cvarCrits;
new Handle:cvarRageSentry;
new Handle:cvarFirstRound;
new Handle:cvarDemoShieldCrits;
new Handle:cvarDisplayHaleHP;
//new Handle:cvarCircuitStun;
new Handle:cvarForceSpecToHale;
new Handle:cvarEnableEurekaEffect;
new Handle:cvarForceHaleTeam;
new Handle:PointCookie;
new Handle:MusicCookie;
new Handle:VoiceCookie;
new Handle:ClasshelpinfoCookie;
new Handle:doorchecktimer;
new Handle:jumpHUD;
new Handle:rageHUD;
new Handle:healthHUD;
new bool:Enabled = false;
new bool:Enabled2 = false;
new Float:HaleSpeed = 340.0;
new PointDelay = 6;
new RageDMG = 3500;
new Float:RageDist = 800.0;
new Float:Announce = 120.0;
new bSpecials = true;
new AliveToEnable = 5;
new PointType = 0;
new bool:haleCrits = false;
new bool:bDemoShieldCrits = false;
new bool:bAlwaysShowHealth = true;
new bool:newRageSentry = true;
//new Float:circuitStun = 0.0;
new Handle:MusicTimer;
new TeamRoundCounter;
new botqueuepoints = 0;
new String:currentmap[99];
new bool:checkdoors = false;
new bool:PointReady;
new tf_arena_use_queue;
new mp_teams_unbalance_limit;
new tf_arena_first_blood;
new mp_forcecamera;
new Float:tf_scout_hype_pep_max;
new defaulttakedamagetype;

new bool:g_bClientRJFlag[MAXPLAYERS+1] = { false, ... };

// HANDLES FOR FOWARDS:
new Handle:OnHaleCreated;
new Handle:OnHaleJump;
new Handle:OnHaleRage;
new Handle:OnHaleWeighdown;
new Handle:OnMusic;

//new Handle:hEquipWearable;
new Handle:hSetAmmoVelocity;


/*new Handle:OnIsVSHMap;
new Handle:OnIsEnabled;
new Handle:OnGetHale;
new Handle:OnGetTeam;
new Handle:OnGetSpecial;
new Handle:OnGetHealth;
new Handle:OnGetHealthMax;
new Handle:OnGetDamage;
new Handle:OnGetRoundState;*/

//new bool:ACH_Enabled;

new numHaleKills = 0;    //See if the Hale was boosting his buddies or afk

