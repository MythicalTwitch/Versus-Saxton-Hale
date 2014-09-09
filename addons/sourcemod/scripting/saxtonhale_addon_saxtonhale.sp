// saxtonhale_addon_saxtonhale.sp

#include <saxtonhale>
#include <tf2_stocks>

#define HALE_TITLE "Saxton Hale"

new Float:KSpreeTimer;
new KSpreeCount = 1;

public Plugin:myinfo =
{
	name = "VSH SaxtonHale Boss Addon",
	author = "SaxtonHale Team",
	description = "The Saxton Hale Boss",
	version = "1.0",
	url = "https://forums.alliedmods.net/showthread.php?t=146884"
}

// TRY AND SORT OUT AND CREATE HALE

// NEED TO FIGURE OUT WHAT NEEDS TO STAY IN ENGINE AND WHAT CAN BE LOADED FOR THE BOSS

#define HaleModel "models/player/saxton_hale/saxton_hale.mdl"

#define HaleModelPrefix "models/player/saxton_hale/saxton_hale"
#define HaleYellName "saxton_hale/saxton_hale_responce_1a.wav"
#define HaleRageSoundB "saxton_hale/saxton_hale_responce_1b.wav"
#define HaleComicArmsFallSound "saxton_hale/saxton_hale_responce_2.wav"
#define HaleLastB "vo/announcer_am_lastmanalive"
#define HaleEnabled QueuePanelH(Handle:0, MenuAction:0, 9001, 0)
#define HaleKSpree "saxton_hale/saxton_hale_responce_3.wav"
#define HaleKSpree2 "saxton_hale/saxton_hale_responce_4.wav"    //this line is broken and unused

#define HaleRoundStart "saxton_hale/saxton_hale_responce_start" //1-5
#define HaleJump "saxton_hale/saxton_hale_responce_jump"            //1-2
#define HaleRageSound "saxton_hale/saxton_hale_responce_rage"           //1-4
#define HaleKillMedic "saxton_hale/saxton_hale_responce_kill_medic.wav"
#define HaleKillSniper1 "saxton_hale/saxton_hale_responce_kill_sniper1.wav"
#define HaleKillSniper2 "saxton_hale/saxton_hale_responce_kill_sniper2.wav"
#define HaleKillSpy1 "saxton_hale/saxton_hale_responce_kill_spy1.wav"
#define HaleKillSpy2 "saxton_hale/saxton_hale_responce_kill_spy2.wav"
#define HaleKillEngie1 "saxton_hale/saxton_hale_responce_kill_eggineer1.wav"
#define HaleKillEngie2 "saxton_hale/saxton_hale_responce_kill_eggineer2.wav"
#define HaleKSpreeNew "saxton_hale/saxton_hale_responce_spree"  //1-5
#define HaleWin "saxton_hale/saxton_hale_responce_win"          //1-2
#define HaleLastMan "saxton_hale/saxton_hale_responce_lastman"  //1-5
//#define HaleLastMan2Fixed "saxton_hale/saxton_hale_responce_lastman2.wav"
#define HaleFail "saxton_hale/saxton_hale_responce_fail"            //1-3
//===1.32 responces===
#define HaleJump132 "saxton_hale/saxton_hale_132_jump_" //1-2
#define HaleStart132 "saxton_hale/saxton_hale_132_start_"   //1-5
#define HaleKillDemo132  "saxton_hale/saxton_hale_132_kill_demo.wav"
#define HaleKillEngie132  "saxton_hale/saxton_hale_132_kill_engie_" //1-2
#define HaleKillHeavy132  "saxton_hale/saxton_hale_132_kill_heavy.wav"
#define HaleKillScout132  "saxton_hale/saxton_hale_132_kill_scout.wav"
#define HaleKillSpy132  "saxton_hale/saxton_hale_132_kill_spie.wav"
#define HaleKillPyro132  "saxton_hale/saxton_hale_132_kill_w_and_m1.wav"
#define HaleSappinMahSentry132  "saxton_hale/saxton_hale_132_kill_toy.wav"
#define HaleKillKSpree132  "saxton_hale/saxton_hale_132_kspree_"    //1-2
#define HaleKillLast132  "saxton_hale/saxton_hale_132_last.wav"
#define HaleStubbed132 "saxton_hale/saxton_hale_132_stub_"  //1-4


new thisHaleID=-1;

public OnPluginStart()
{
	AddNormalSoundHook(HookSound);
}

public OnAllPluginsLoaded()
{
	if(!LibraryExists("saxtonhale")) SetFailState("Unabled to find plugin: SaxtonHale");

	thisHaleID=VSH_RegisterHale(HALE_TITLE, BossCallback);

	PrintToServer("Registered: %s haleid: %d",HALE_TITLE,thisHaleID);
}

public OnPluginEnd()
{
	if(LibraryExists("saxtonhale"))
	{
		VSH_UnregisterHale(HALE_TITLE);
		PrintToServer("UnRegistered: %s haleid: %d",HALE_TITLE,thisHaleID);
		thisHaleID=-1;
	}
}

public OnMapStart()
{
	// Load sounds, materials, model, etc.
	AddToDownload();
	KSpreeTimer = 0.0;
}


public HaleCallback:BossCallback(client) Boss_Start(client);

public Boss_Start(client)
{
}

new numHaleKills;

// ================================================================================
// HookSound
// ================================================================================

/* seems to be only for the specials and not hale
public Action:HookSound(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	if(VSH_GetHaleID()!=thisHaleID) return Plugin_Continue;

	new Hale = GetClientOfUserId(VSH_GetSaxtonHaleUserId());

	if (!VSH_IsSaxtonHaleModeEnabled() || ((entity != Hale) && ((entity <= 0) || !ValidPlayer(Hale) || (entity != GetPlayerWeaponSlot(Hale, 0)))))
		return Plugin_Continue;
	if (StrContains(sample, "saxton_hale", false) != -1)
		return Plugin_Continue;
	return Plugin_Continue;
}*/

// ================================================================================
// VSH_OnEventDeath
// ================================================================================


public VSH_OnEventDeath(victim, attacker, distance, attacker_hpleft)
{
	if(VSH_GetHaleID()!=thisHaleID) return;

	new Hale = GetClientOfUserId(VSH_GetSaxtonHaleUserId());

	new Handle:event = VSHGetVar(SmEvent);

	new deathflags = GetEventInt(event, "death_flags");
	new customkill = GetEventInt(event, "customkill");

	if (attacker == Hale && VSH_GetRoundState() == ROUNDSTATE_START_ROUND_TIMER && (deathflags & TF_DEATHFLAG_DEADRINGER))
	{
		numHaleKills++;
		if (customkill != TF_CUSTOM_BOOTS_STOMP)
		{
			SetEventString(event, "weapon", "fists");
		}
		return 1;
	}

	if (victim == Hale && VSH_GetRoundState() == ROUNDSTATE_START_ROUND_TIMER)
	{
		new String:s[PLATFORM_MAX_PATH];
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleFail, GetRandomInt(1, 3));
		EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		VSH_EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, victim, NULL_VECTOR, NULL_VECTOR, false, 0.0);

		if (VSH_GetSaxtonHaleHealth() < 0)
			VSH_SetSaxtonHaleHealth(0);
		// ForceTeamWin(OtherTeam);
		ForceTeamWin(VSH_GetSaxtonHaleTeam()==2?3:2);
		return 1;
	}

	if (attacker == Hale && VSH_GetRoundState() == ROUNDSTATE_START_ROUND_TIMER)
	{
		numHaleKills++;

		if (customkill != TF_CUSTOM_BOOTS_STOMP) SetEventString(event, "weapon", "fists");
		if (!GetRandomInt(0, 2) && VSH_GetRedAlivePlayers() != 1)
		{
			new String:s[PLATFORM_MAX_PATH];
			strcopy(s, PLATFORM_MAX_PATH, "");
			new TFClassType:playerclass = TF2_GetPlayerClass(victim);
			switch (playerclass)
			{
				case TFClass_Scout:     strcopy(s, PLATFORM_MAX_PATH, HaleKillScout132);
				case TFClass_Pyro:      strcopy(s, PLATFORM_MAX_PATH, HaleKillPyro132);
				case TFClass_DemoMan:   strcopy(s, PLATFORM_MAX_PATH, HaleKillDemo132);
				case TFClass_Heavy:     strcopy(s, PLATFORM_MAX_PATH, HaleKillHeavy132);
				case TFClass_Medic:     strcopy(s, PLATFORM_MAX_PATH, HaleKillMedic);
				case TFClass_Sniper:
				{
					if (GetRandomInt(0, 1)) strcopy(s, PLATFORM_MAX_PATH, HaleKillSniper1);
					else strcopy(s, PLATFORM_MAX_PATH, HaleKillSniper2);
				}
				case TFClass_Spy:
				{
					new see = GetRandomInt(0, 2);
					if (!see) strcopy(s, PLATFORM_MAX_PATH, HaleKillSpy1);
					else if (see == 1) strcopy(s, PLATFORM_MAX_PATH, HaleKillSpy2);
					else strcopy(s, PLATFORM_MAX_PATH, HaleKillSpy132);
				}
				case TFClass_Engineer:
				{
					new see = GetRandomInt(0, 3);
					if (!see) strcopy(s, PLATFORM_MAX_PATH, HaleKillEngie1);
					else if (see == 1) strcopy(s, PLATFORM_MAX_PATH, HaleKillEngie2);
					else Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillEngie132, GetRandomInt(1, 2));
				}
			}
			if (!StrEqual(s, ""))
			{
				VSH_EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				VSH_EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			}
		}

		if (GetGameTime() <= KSpreeTimer)
			KSpreeCount++;
		else
			KSpreeCount = 1;

		if (KSpreeCount == 3 && VSH_GetRedAlivePlayers() != 1)
		{
			new String:s[PLATFORM_MAX_PATH];
			new see = GetRandomInt(0, 7);
			if (!see || see == 1)
				strcopy(s, PLATFORM_MAX_PATH, HaleKSpree);
			else if (see < 5)
				Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKSpreeNew, GetRandomInt(1, 5));
			else
				Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillKSpree132, GetRandomInt(1, 2));

			VSH_EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			VSH_EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);

			KSpreeCount = 0;
		}
		else
			KSpreeTimer = GetGameTime() + 5.0;
	}

	return 1;
}

public AddToDownload()
{
	decl String:s[PLATFORM_MAX_PATH];
	new String:extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
	new String:extensionsb[][] = { ".vtf", ".vmt" };
	decl i;
	for (i = 0; i < sizeof(extensions); i++)
	{
		Format(s, PLATFORM_MAX_PATH, "%s%s", HaleModelPrefix, extensions[i]);
		if (FileExists(s, true)) AddFileToDownloadsTable(s);
	}

	PrecacheModel(HaleModel, true);

	for (i = 0; i < sizeof(extensionsb); i++)
	{
		Format(s, PLATFORM_MAX_PATH, "materials/models/player/saxton_hale/eye%s", extensionsb[i]);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "materials/models/player/saxton_hale/hale_head%s", extensionsb[i]);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "materials/models/player/saxton_hale/hale_body%s", extensionsb[i]);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "materials/models/player/saxton_hale/hale_misc%s", extensionsb[i]);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "materials/models/player/saxton_hale/sniper_red%s", extensionsb[i]);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "materials/models/player/saxton_hale/sniper_lens%s", extensionsb[i]);
		AddFileToDownloadsTable(s);
	}

	AddFileToDownloadsTable("materials/models/player/saxton_hale/sniper_head.vtf");
	AddFileToDownloadsTable("materials/models/player/saxton_hale/sniper_head_red.vmt");
	AddFileToDownloadsTable("materials/models/player/saxton_hale/hale_misc_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/saxton_hale/hale_body_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/saxton_hale/eyeball_l.vmt");
	AddFileToDownloadsTable("materials/models/player/saxton_hale/eyeball_r.vmt");

	//??
	AddFileToDownloadsTable("materials/models/player/saxton_hale/hale_egg.vtf");
	AddFileToDownloadsTable("materials/models/player/saxton_hale/hale_egg.vmt");

	PrecacheSound(HaleComicArmsFallSound, true);

	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleComicArmsFallSound);
	AddFileToDownloadsTable(s);

	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKSpree);
	PrecacheSound(HaleKSpree, true);

	AddFileToDownloadsTable(s);

	PrecacheSound("saxton_hale/9000.wav", true);

	AddFileToDownloadsTable("sound/saxton_hale/9000.wav");

	for (i = 1; i <= 4; i++)
	{
		Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HaleLastB, i);
		PrecacheSound(s, true);
	}

	PrecacheSound(HaleKillMedic, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillMedic);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSniper1, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillSniper1);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSniper2, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillSniper2);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSpy1, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillSpy1);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSpy2, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillSpy2);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillEngie1, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillEngie1);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillEngie2, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillEngie2);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillDemo132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillDemo132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillHeavy132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillHeavy132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillScout132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillScout132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSpy132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillSpy132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillPyro132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillPyro132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleSappinMahSentry132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleSappinMahSentry132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillLast132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillLast132);
	AddFileToDownloadsTable(s);

	for (i = 1; i <= 5; i++)
	{
		if (i <= 2)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleJump, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleWin, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleJump132, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillEngie132, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillKSpree132, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
		}
		if (i <= 3)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleFail, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
		}
		if (i <= 4)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleRageSound, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleStubbed132, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleRoundStart, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKSpreeNew, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleLastMan, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleStart132, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
		AddFileToDownloadsTable(s);
	}
}

// PROTOTYPES:

// Handle the menu system within each boss separately

/*
enum halemenutype
{
	HaleSkillsInfo //, // Shows Skills Information Menu
	//HaleSpendSkills // Shows Skills to level up (future possibility)
}
public Action:OnHalePreMenu(hale,halemenutype:MenuTypeID,copybacktitlestring[256],&totalmenuitems)
{
	if(hale==haleid)
	{
		strcopy(copybacktitlestring, sizeof(copybacktitlestring), "hale menu title");
		totalmenuitems=4;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:OnHaleMenu(haledid,halemenutype:MenuTypeID,copybackstring[256],menuitem)
{
	switch(menuitem)
	{
		case 1:
		{
			strcopy(copybackstring, sizeof(copybackstring), "hale menu item 1");
			return Plugin_Changed;
		}
		case 2:
		{
			strcopy(copybackstring, sizeof(copybackstring), "hale menu item 2");
			return Plugin_Changed;
		}
		case 3:
		{
			strcopy(copybackstring, sizeof(copybackstring), "hale menu item 3");
			return Plugin_Changed;
		}
		case 4:
		{
			strcopy(copybackstring, sizeof(copybackstring), "hale menu item 4");
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

public OnHaleMenuSelection(haleid,halemenutype:MenuTypeID,&selection)
{
	if(selection==1)
	{
		//display menu item 1?
	}
}
*/


