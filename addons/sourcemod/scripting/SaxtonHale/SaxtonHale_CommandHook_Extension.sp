#include <saxtonhale>

public Plugin:myinfo =
{
	name = "SaxtonHale - Engine - Command Hooks",
	author = "SaxtonHale Team",
	description = "Command Hooks for SaxtonHale"
};


//new Handle:Cvar_ChatBlocking;
public Action:VSHSayAllCommandCheckPost(client,String:WholeString[],String:ChatString[])
{
	if(!ValidPlayer(client))
	{
		return Plugin_Continue;
	}
	new Action:returnblocking = Plugin_Continue;

	if(CommandCheck(ChatString,"hale")==VSHChatTrue)
	{
		HalePanel(client);
		returnblocking = Plugin_Continue;
	}
	else if(CommandCheck(ChatString,"hale")==VSHChatBlock)
	{
		HalePanel(client);
		returnblocking = Plugin_Handled;
	}

	else if(CommandCheck(ChatString,"halehp")==VSHChatTrue || CommandCheck(ChatString,"hale_hp")==VSHChatTrue)
	{
		Command_GetHP(client);
		returnblocking = Plugin_Continue;
	}
	else if(CommandCheck(ChatString,"halehp")==VSHChatBlock || CommandCheck(ChatString,"hale_hp")==VSHChatBlock)
	{
		Command_GetHP(client);
		returnblocking = Plugin_Handled;
	}

	else if(CommandCheck(ChatString,"halenext")==VSHChatTrue || CommandCheck(ChatString,"hale_next")==VSHChatTrue)
	{
		QueuePanel(client);
		returnblocking = Plugin_Continue;
	}
	else if(CommandCheck(ChatString,"halenext")==VSHChatBlock || CommandCheck(ChatString,"hale_next")==VSHChatBlock)
	{
		QueuePanel(client);
		returnblocking = Plugin_Handled;
	}

	else if(CommandCheck(ChatString,"halehelp")==VSHChatTrue || CommandCheck(ChatString,"hale_help")==VSHChatTrue)
	{
		HelpPanel(client);
		returnblocking = Plugin_Continue;
	}
	else if(CommandCheck(ChatString,"halehelp")==VSHChatBlock || CommandCheck(ChatString,"hale_help")==VSHChatBlock)
	{
		HelpPanel(client);
		returnblocking = Plugin_Handled;
	}

	else if(CommandCheck(ChatString,"haleclass")==VSHChatTrue || CommandCheck(ChatString,"hale_class")==VSHChatTrue)
	{
		if (client == Hale)
		{
			HintPanel(Hale);
		}
		else
		{
			HelpPanel2(client);
		}
		returnblocking = Plugin_Continue;
	}
	else if(CommandCheck(ChatString,"haleclass")==VSHChatBlock || CommandCheck(ChatString,"hale_class")==VSHChatBlock)
	{
		if (client == Hale)
		{
			HintPanel(Hale);
		}
		else
		{
			HelpPanel2(client);
		}
		returnblocking = Plugin_Handled;
	}

	else if(CommandCheck(ChatString,"haleclassinfotoggle")==VSHChatTrue || CommandCheck(ChatString,"hale_classinfotoggle")==VSHChatTrue)
	{
		ClasshelpinfoSetting(client);
		returnblocking = Plugin_Continue;
	}
	else if(CommandCheck(ChatString,"haleclassinfotoggle")==VSHChatBlock || CommandCheck(ChatString,"hale_classinfotoggle")==VSHChatBlock)
	{
		ClasshelpinfoSetting(client);
		returnblocking = Plugin_Handled;
	}
	else if(CommandCheck(ChatString,"infotoggle")==VSHChatTrue)
	{
		ClasshelpinfoSetting(client);
		returnblocking = Plugin_Continue;
	}
	else if(CommandCheck(ChatString,"infotoggle")==VSHChatBlock)
	{
		ClasshelpinfoSetting(client);
		returnblocking = Plugin_Handled;
	}

	else if(CommandCheck(ChatString,"halenew")==VSHChatTrue || CommandCheck(ChatString,"hale_new")==VSHChatTrue)
	{
		NewPanel(client, maxversion);
		returnblocking = Plugin_Continue;
	}
	else if(CommandCheck(ChatString,"halenew")==VSHChatBlock || CommandCheck(ChatString,"hale_new")==VSHChatBlock)
	{
		NewPanel(client, maxversion);
		returnblocking = Plugin_Handled;
	}

	else if(CommandCheck(ChatString,"halemusic")==VSHChatTrue || CommandCheck(ChatString,"hale_music")==VSHChatTrue)
	{
		MusicTogglePanel(client);
		returnblocking = Plugin_Continue;
	}
	else if(CommandCheck(ChatString,"halemusic")==VSHChatBlock || CommandCheck(ChatString,"hale_music")==VSHChatBlock)
	{
		MusicTogglePanel(client);
		returnblocking = Plugin_Handled;
	}

	else if(CommandCheck(ChatString,"halevoice")==VSHChatTrue || CommandCheck(ChatString,"hale_voice")==VSHChatTrue)
	{
		VoiceTogglePanel(client);
		returnblocking = Plugin_Continue;
	}
	else if(CommandCheck(ChatString,"halevoice")==VSHChatBlock || CommandCheck(ChatString,"hale_voice")==VSHChatBlock)
	{
		VoiceTogglePanel(client);
		returnblocking = Plugin_Handled;
	}
	return returnblocking;
}
