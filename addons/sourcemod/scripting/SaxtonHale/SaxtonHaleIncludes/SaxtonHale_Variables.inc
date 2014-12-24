new dummyreturn;

new HaleRaceID=-1;

new p_properties[MAXPLAYERS + 1][VSH_PlayerProp];

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
//new los_target;
//new ignoreClient;
#endif

new VSHVarArr[VSHVar];

new Damage[MAXPLAYERS + 1];
new AirDamage[MAXPLAYERS + 1]; // Air Strike
new curHelp[MAXPLAYERS + 1];
new uberTarget[MAXPLAYERS + 1];

new VSHFlags[MAXPLAYERS + 1];
//new Hale = -1;
new HaleHealthMax;
new HaleHealth;
new HaleHealthLast;
new HaleCharge = 0;
new HaleRage;
new NextHale;
new Float:Stabbed;
new Float:Marketed;
new Float:HPTime;
new Float:WeighDownTimer;
new Float:UberRageCount;
new Float:GlowTimer;
new bool:bEnableSuperDuperJump;
new bool:bTenSecStart[2] = {false, false};
new bool:bSpawnTeleOnTriggerHurt = false;
new Handle:hHHHTeleTimer = INVALID_HANDLE;
new HHHClimbCount;
new bool:bNoTaunt = false;

// ========================================================================
// SaxtonHale_Configuration.sp
// ========================================================================
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
new Handle:cvarEndRoundOnReload;

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
new Handle:g_OnEventSpawn;
new Handle:g_OnEventDeath;
new Handle:OnSpecialSelection;
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

//new numHaleKills = 0;    //See if the Hale was boosting his buddies or afk


//=============================
// War3Source_Engine_RaceClass ------------------------------ RACE CLASS
//=============================
new totalRacesLoaded=0;  ///USE raceid=1;raceid<=GetRacesLoaded();raceid++ for looping
///race instance variables
//RACE ID = index of [MAXRACES], raceid 1 is raceName[1][32]

new String:raceName[MAXRACES][32];
new String:raceShortname[MAXRACES][16];
new String:raceShortdesc[MAXRACES][32];
new bool:raceTranslated[MAXRACES];
new bool:ignoreRaceEnd; ///dont do anything on CreateRaceEnd cuz this its already done once

//zeroth skill is NOT  used
new raceSkillCount[MAXRACES];
new String:raceSkillName[MAXRACES][MAXSKILLCOUNT][32];
new String:raceSkillDescription[MAXRACES][MAXSKILLCOUNT][512];
new raceSkillDescReplaceNum[MAXRACES][MAXSKILLCOUNT];
new String:raceSkillDescReplace[MAXRACES][MAXSKILLCOUNT][5][64]; ///MAX 5 params for replacement //64 string length
new bool:skillTranslated[MAXRACES][MAXSKILLCOUNT];

enum SkillRedirect
{
	genericskillid,
}
new bool:SkillRedirected[MAXRACES][MAXSKILLCOUNT];
new SkillRedirectedToSkill[MAXRACES][MAXSKILLCOUNT];

new bool:skillIsUltimate[MAXRACES][MAXSKILLCOUNT];
new skillMaxLevel[MAXRACES][MAXSKILLCOUNT];
//new skillProp[MAXRACES][MAXSKILLCOUNT][W3SkillProp];        // not used anywhere

new MinLevelCvar[MAXRACES];
new AccessFlagCvar[MAXRACES];
new RaceOrderCvar[MAXRACES];
new RaceFlagsCvar[MAXRACES];
new RestrictItemsCvar[MAXRACES];
new RestrictLimitCvar[MAXRACES][2];

new Handle:m_MinimumUltimateLevel;

new bool:racecreationended=true;
new String:creatingraceshortname[16];

new raceCell[MAXRACES][ENUM_RaceObject];

new bool:ReloadRaces_Id[MAXRACES];
new ReloadRaces_Client_Race[MAXPLAYERSCUSTOM];
new String:ReloadRaces_Shortname[MAXRACES][16];
new String:ReloadRaces_longname[MAXRACES][32];


//=============================
// War3Source_Engine_PlayerClass
//=============================
new p_properties[MAXPLAYERSCUSTOM][W3PlayerProp];

