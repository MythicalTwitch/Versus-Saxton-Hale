//#include "JailBreakIncs/JailBreak_Interface"

public Plugin:myinfo=
{
	name="SaxtonHale Addon RULES",
	author="El Diablo",
	description="SaxtonHale RULES Plugin",
	version="1.0",
	url="http://war3evo.info/"
};

new RuleNumber[MAXPLAYERS + 1]={0,...};

public OnPluginStart()
{
	RegConsoleCmd("sm_rules", cmd_rules);
}

public OnClientConnected(client)
{
	RuleNumber[client]=0;
}

public OnClientDisconnect(client)
{
	RuleNumber[client]=0;
}

new const String:Rules[][] = {
	"[Rule 1] No Spamming Voice/Text chat.",
	"[Rule 2] Disrespect/Harassment will NOT be tolerated.",
	"[Rule 3] Trading is NOT allowed over Voice/Text chat.",
	"[Rule 4] Hale must be actively fighting reds.",
	"[Rule 5] No Ghosting (Unless they're delaying the round being the last one alive while hiding).",
	"[Rule 6] No Exploiting map bugs (getting into a place where hale can't get into).",
	"[Rule 7] If you're the last Red standing, you may NOT hide and delay the round. Scouts must\nbe trying to kill the Hale, NOT running around delaying the round. Exception to the rule is\nthe Engineer Class Being with his sentry."
};
	//for (i = 0; i < sizeof(Rules); i++)
	//{
		//Format(s, PLATFORM_MAX_PATH, "sound/%s", Rules[i]);
	//}


ShowMenuItemsinfo(client)
{
	new Handle:helpMenu=CreateMenu(ShowMenuItemsinfoSelected);
	SetMenuExitButton(helpMenu,true);
	SetMenuTitle(helpMenu,"SaxtonHale RULES");
	//decl String:str[PLATFORM_MAX_PATH];
	decl String:numstr[4];

	IntToString(RuleNumber[client],numstr,sizeof(numstr));

	AddMenuItem(helpMenu,numstr,Rules[RuleNumber[client]],ITEMDRAW_DISABLED);
	AddMenuItem(helpMenu,"888","Previous");
	AddMenuItem(helpMenu,"999","Next");

	DisplayMenu(helpMenu,client,60);
}

public ShowMenuItemsinfoSelected(Handle:menu,MenuAction:action,client,selection)
{
	if(action==MenuAction_Select)
	{
		decl String:SelectionInfo[4];
		decl String:SelectionDispText[256];
		new SelectionStyle;
		GetMenuItem(menu,selection,SelectionInfo,sizeof(SelectionInfo),SelectionStyle, SelectionDispText,sizeof(SelectionDispText));
		new itemnum=StringToInt(SelectionInfo);
		if(itemnum==999)
		{
			RuleNumber[client]++;
			if(RuleNumber[client]>=sizeof(Rules))
			{
				RuleNumber[client]=0;
			}
			ShowMenuItemsinfo(client);
		} else if(itemnum==888)
		{
			RuleNumber[client]--;
			if(RuleNumber[client]<0)
			{
				RuleNumber[client]=sizeof(Rules)-1;
			}
			ShowMenuItemsinfo(client);
		}
	}
	if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:cmd_rules(client,args)
{
	ShowMenuItemsinfo(client);
}
