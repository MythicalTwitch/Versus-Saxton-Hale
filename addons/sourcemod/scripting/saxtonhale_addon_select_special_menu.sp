// saxtonhale_addon_select_special_menu.sp

#include <saxtonhale>
#include <morecolors>

#pragma semicolon 1

#define VERSION "1.0"

public Plugin:myinfo =
{
	name = "VSH Addon Select Special Menu",
	author = "El Diablo",
	description = "Allows a player to choose a hale to become.",
	version = VERSION,
	url = "https://github.com/War3Evo/Versus-Saxton-Hale"
}

new VSHSpecials_id:SpecialChoice[MAXPLAYERS + 1]={VSHSpecial_None,...};

public OnPluginStart()
{
	RegConsoleCmd("sm_hspecial", hale_speical);

	HookEvent("player_spawn", event_player_spawn);
}

public Action:event_player_spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(userid);
	if (!ValidPlayer(client,true)) return Plugin_Continue;
	if(VSH_GetNextSaxtonHaleUserId()==userid)
	{
		CPrintToChat(client, "{olive}[VSH]{default} {yellow}You will be hale next, type !hspecial to choose a special you'd like to be.");
	}
	return Plugin_Continue;
}

public Action:hale_speical(client, args)
{
	if (!ValidPlayer(client))
		return Plugin_Continue;

	CPrintToChat(client, "{olive}[VSH]{default} MENU");

	Show_Hale_Special_Menu(client);

	return Plugin_Continue;
}

Show_Hale_Special_Menu(client)
{
	new Handle:hMenu=CreateMenu(SpecialSelected);
	SetMenuExitButton(hMenu,true);
	SetMenuTitle(hMenu,"[VSH] Select a Special");

	new String:numstr[4];

	for (new i = 0; i < sizeof(SpecialNames); i++)
	{
		if(VSH_IsSpecialEnabled(VSHSpecials_id:i))
		{
			//CPrintToChat(client, "{olive}[VSH]{default} %s ENABLED",SpecialNames[i]);
			IntToString(i,numstr,sizeof(numstr));
			AddMenuItem(hMenu,numstr,SpecialNames[i]);
		}
		//else
		//{
			//CPrintToChat(client, "{olive}[VSH]{default} %s DISABLED",SpecialNames[i]);
		//}
	}
	DisplayMenu(hMenu,client,MENU_TIME_FOREVER);
}

public SpecialSelected(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		decl String:SelectionInfo[4];
		decl String:SelectionDispText[256];
		new SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		new VSHSpecials_id:itemnum=VSHSpecials_id:StringToInt(SelectionInfo);
		SpecialChoice[client]=itemnum;
		CPrintToChat(client, "{olive}[VSH]{default} You Selected %s",SpecialNames[SpecialChoice[client]]);
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:VSH_OnSpecialSelection(&VSHSpecials_id:iSpecial)
{
	new userid = VSH_GetNextSaxtonHaleUserId();

	if(userid>-1)
	{
		new client = GetClientUserId(VSH_GetNextSaxtonHaleUserId());
		if(ValidPlayer(client))
		{
			if(SpecialChoice[client]!=VSHSpecial_None)
			{
				iSpecial=SpecialChoice[client];
			}
		}
	}
}

