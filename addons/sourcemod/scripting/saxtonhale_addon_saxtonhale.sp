// saxtonhale_addon_saxtonhale.sp

#include <saxtonhale>

#define HALE_TITLE "Saxton Hale"

public Plugin:myinfo =
{
	name = "VSH SaxtonHale Boss Addon",
	author = "SaxtonHale Team",
	description = "The Saxton Hale Boss",
	version = "1.0",
	url = "https://forums.alliedmods.net/showthread.php?t=146884"
}

new haleid=-1;

public OnAllPluginsLoaded()
{
	if(!LibraryExists("saxtonhale")) SetFailState("Unabled to find plugin: SaxtonHale");

	haleid=VSH_RegisterHale(HALE_TITLE, BossCallback);

	TF2Jail_ChatMessage(0,"Registered: %s haleid: %d",HALE_TITLE,haleid);
}

public OnPluginEnd()
{
	if(LibraryExists("saxtonhale"))
	{
		VSH_UnregisterHale(HALE_TITLE);
		TF2Jail_ChatMessage(0,"UnRegistered: %s haleid: %d",HALE_TITLE,haleid);
		haleid=-1;
	}
}

public HaleCallback:BossCallback(client) Boss_Start(client);

public Boss_Start(client)
{
}

