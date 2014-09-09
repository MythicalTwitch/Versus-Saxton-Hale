// saxtonhale_addon_saxtonhale.sp

#include <saxtonhale>

#define HALE_TITLE "The Easter Bunny"

#define BunnyModel "models/player/saxton_hale/easter_demo.mdl"
#define BunnyModelPrefix "models/player/saxton_hale/easter_demo"
#define EggModel "models/player/saxton_hale/w_easteregg.mdl"
#define EggModelPrefix "models/player/saxton_hale/w_easteregg"
#define ReloadEggModel "models/player/saxton_hale/c_easter_cannonball.mdl"
#define ReloadEggModelPrefix "models/player/saxton_hale/c_easter_cannonball"

stock const String:BunnyWin[][] = {
	"vo/demoman_gibberish01.wav",
	"vo/demoman_gibberish12.wav",
	"vo/demoman_cheers02.wav",
	"vo/demoman_cheers03.wav",
	"vo/demoman_cheers06.wav",
	"vo/demoman_cheers07.wav",
	"vo/demoman_cheers08.wav",
	"vo/taunts/demoman_taunts12.wav"
};
stock const String:BunnyJump[][] = {
	"vo/demoman_gibberish07.wav",
	"vo/demoman_gibberish08.wav",
	"vo/demoman_laughshort01.wav",
	"vo/demoman_positivevocalization04.wav"
};
stock const String:BunnyRage[][] = {
	"vo/demoman_positivevocalization03.wav",
	"vo/demoman_dominationscout05.wav",
	"vo/demoman_cheers02.wav"
};
stock const String:BunnyFail[][] = {
	"vo/demoman_gibberish04.wav",
	"vo/demoman_gibberish10.wav",
	"vo/demoman_jeers03.wav",
	"vo/demoman_jeers06.wav",
	"vo/demoman_jeers07.wav",
	"vo/demoman_jeers08.wav"
};
stock const String:BunnyKill[][] = {
	"vo/demoman_gibberish09.wav",
	"vo/demoman_cheers02.wav",
	"vo/demoman_cheers07.wav",
	"vo/demoman_positivevocalization03.wav"
};
stock const String:BunnySpree[][] = {
	"vo/demoman_gibberish05.wav",
	"vo/demoman_gibberish06.wav",
	"vo/demoman_gibberish09.wav",
	"vo/demoman_gibberish11.wav",
	"vo/demoman_gibberish13.wav",
	"vo/demoman_autodejectedtie01.wav"
};
stock const String:BunnyLast[][] = {
	"vo/taunts/demoman_taunts05.wav",
	"vo/taunts/demoman_taunts04.wav",
	"vo/demoman_specialcompleted07.wav"
};
stock const String:BunnyPain[][] = {
	"vo/demoman_sf12_badmagic01.wav",
	"vo/demoman_sf12_badmagic07.wav",
	"vo/demoman_sf12_badmagic10.wav"
};
stock const String:BunnyStart[][] = {
	"vo/demoman_gibberish03.wav",
	"vo/demoman_gibberish11.wav"
};
stock const String:BunnyRandomVoice[][] = {
	"vo/demoman_positivevocalization03.wav",
	"vo/demoman_jeers08.wav",
	"vo/demoman_gibberish03.wav",
	"vo/demoman_cheers07.wav",
	"vo/demoman_sf12_badmagic01.wav",
	"vo/burp02.wav",
	"vo/burp03.wav",
	"vo/burp04.wav",
	"vo/burp05.wav",
	"vo/burp06.wav",
	"vo/burp07.wav"
};

public Plugin:myinfo =
{
	name = "VSH Easter Bunny Boss Addon",
	author = "SaxtonHale Team",
	description = "The Easter Bunny Boss",
	version = "1.0",
	url = "https://forums.alliedmods.net/showthread.php?t=146884"
}

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
}


public HaleCallback:BossCallback(client) Boss_Start(client);

public Boss_Start(client)
{
}


public AddToDownload()
{
	decl String:s[PLATFORM_MAX_PATH];
	new String:extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
	new String:extensionsb[][] = { ".vtf", ".vmt" };
	decl i;
	for (i = 0; i < sizeof(extensions); i++)
	{
		Format(s, PLATFORM_MAX_PATH, "%s%s", BunnyModelPrefix, extensions[i]);
		if (FileExists(s, true)) AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "%s%s", EggModelPrefix, extensions[i]);
		if (FileExists(s, true)) AddFileToDownloadsTable(s);
	}
	PrecacheModel(BunnyModel, true);
	PrecacheModel(EggModel, true);
//      PrecacheModel(ReloadEggModel, true);
	AddFileToDownloadsTable("materials/models/player/easter_demo/demoman_head_red.vmt");
	AddFileToDownloadsTable("materials/models/player/easter_demo/easter_body.vmt");
	AddFileToDownloadsTable("materials/models/player/easter_demo/easter_body.vtf");
	AddFileToDownloadsTable("materials/models/player/easter_demo/easter_rabbit.vmt");
	AddFileToDownloadsTable("materials/models/player/easter_demo/easter_rabbit.vtf");
	AddFileToDownloadsTable("materials/models/player/easter_demo/easter_rabbit_normal.vtf");
	AddFileToDownloadsTable("materials/models/props_easteregg/c_easteregg.vmt");
	AddFileToDownloadsTable("materials/models/props_easteregg/c_easteregg.vtf");
	AddFileToDownloadsTable("materials/models/props_easteregg/c_easteregg_gold.vmt");
	AddFileToDownloadsTable("materials/models/player/easter_demo/eyeball_r.vmt");

	for (i = 0; i < sizeof(BunnyWin); i++)
	{
		PrecacheSound(BunnyWin[i], true);
	}
	for (i = 0; i < sizeof(BunnyJump); i++)
	{
		PrecacheSound(BunnyJump[i], true);
	}
	for (i = 0; i < sizeof(BunnyRage); i++)
	{
		PrecacheSound(BunnyRage[i], true);
	}
	for (i = 0; i < sizeof(BunnyFail); i++)
	{
		PrecacheSound(BunnyFail[i], true);
	}
	for (i = 0; i < sizeof(BunnyKill); i++)
	{
		PrecacheSound(BunnyKill[i], true);
	}
	for (i = 0; i < sizeof(BunnySpree); i++)
	{
		PrecacheSound(BunnySpree[i], true);
	}
	for (i = 0; i < sizeof(BunnyLast); i++)
	{
		PrecacheSound(BunnyLast[i], true);
	}
	for (i = 0; i < sizeof(BunnyPain); i++)
	{
		PrecacheSound(BunnyPain[i], true);
	}
	for (i = 0; i < sizeof(BunnyStart); i++)
	{
		PrecacheSound(BunnyStart[i], true);
	}
}
