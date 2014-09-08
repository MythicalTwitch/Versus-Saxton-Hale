// SaxtonHale_CommandHook.sp

public Plugin:myinfo =
{
	name = "SaxtonHale - Engine - Command Hooks",
	author = "SaxtonHale Team",
	description = "Command Hooks for SaxtonHale"
};

new Handle:g_hOnVSHSayCommandCheckPre;
new Handle:g_hOnVSHSayCommandCheckPost;

new Handle:g_hOnVSHTeamCommandCheckPre;
new Handle:g_hOnVSHTeamCommandCheckPost;

new Handle:g_hOnVSHSayAllCommandCheckPre;
new Handle:g_hOnVSHSayAllCommandCheckPost;

public bool:CommandHook_InitForwards()
{
	g_hOnVSHSayCommandCheckPre       = CreateGlobalForward("VSHSayCommandCheckPre", ET_Hook, Param_Cell, Param_String, Param_String);
	g_hOnVSHSayCommandCheckPost        = CreateGlobalForward("VSHSayCommandCheckPost", ET_Hook, Param_Cell, Param_String, Param_String);

	g_hOnVSHTeamCommandCheckPre       = CreateGlobalForward("VSHSayTeamCommandCheckPre", ET_Hook, Param_Cell, Param_String, Param_String);
	g_hOnVSHTeamCommandCheckPost        = CreateGlobalForward("VSHSayTeamCommandCheckPost", ET_Hook, Param_Cell, Param_String, Param_String);

	g_hOnVSHSayAllCommandCheckPre       = CreateGlobalForward("VSHSayAllCommandCheckPre", ET_Hook, Param_Cell, Param_String, Param_String);
	g_hOnVSHSayAllCommandCheckPost        = CreateGlobalForward("VSHSayAllCommandCheckPost", ET_Hook, Param_Cell, Param_String, Param_String);

	return true;
}

stock bool:SaxtonHale_SayAllCommand(client,String:WholeMsg[256],String:ChatMsg[256])
{
	//decl String:arg1[256]; //was 70
	//decl String:msg[256]; //was 70
	//GetCmdArg(1,arg1,sizeof(arg1));
	//TrimString(arg1);
	//GetCmdArgString(msg, sizeof(msg));
	//StripQuotes(msg);

	// remove color tags that a player could type in to
	// add color to your chat (bug fixed)
	//CRemoveTag2(arg1, sizeof(arg1));

	new Action:returnVal = Plugin_Continue;
	Call_StartForward(g_hOnTF2JailSayAllCommandCheckPre);
	Call_PushCell(client);
	// copyback allows changing of client text on pre
	Call_PushStringEx(WholeMsg,sizeof(WholeMsg),SM_PARAM_STRING_COPY,SM_PARAM_COPYBACK);
	Call_PushStringEx(ChatMsg,sizeof(ChatMsg),SM_PARAM_STRING_COPY,SM_PARAM_COPYBACK);
	Call_Finish(_:returnVal);
	if(returnVal != Plugin_Continue)
	{
		return true;
	}

	returnVal = Plugin_Continue;
	Call_StartForward(g_hOnTF2JailSayAllCommandCheckPost);
	Call_PushCell(client);
	Call_PushString(WholeMsg);
	Call_PushString(ChatMsg)
	// May want to copy back in the future?
	// for now, no need
	//Call_PushArrayEx(arg1,sizeof(arg1),SM_PARAM_COPYBACK);
	Call_Finish(_:returnVal);

	if(returnVal != Plugin_Continue)
	{
		return true;
	}

	return false;
}

public Action:SaxtonHale_TeamSayCommand(client,args)
{
	decl String:arg1[256]; //was 70
	decl String:msg[256]; //was 70
	GetCmdArg(1,arg1,sizeof(arg1));
	TrimString(arg1);
	GetCmdArgString(msg, sizeof(msg));
	StripQuotes(msg);
	TrimString(msg);

	// remove color tags that a player could type in to
	// add color to your chat (bug fixed)
	CRemoveTag2(arg1, sizeof(arg1));

	new Action:returnVal = Plugin_Continue;
	Call_StartForward(g_hOnTF2JailSayTeamCommandCheckPre);
	Call_PushCell(client);
	// copyback allows changing of client text on pre
	Call_PushStringEx(msg,sizeof(msg),SM_PARAM_STRING_COPY,SM_PARAM_COPYBACK);
	Call_PushStringEx(arg1,sizeof(arg1),SM_PARAM_STRING_COPY,SM_PARAM_COPYBACK);
	Call_Finish(_:returnVal);
	if(returnVal != Plugin_Continue)
	{
		return Plugin_Handled;
	}

	returnVal = Plugin_Continue;
	Call_StartForward(g_hOnTF2JailSayTeamCommandCheckPost);
	Call_PushCell(client);
	Call_PushString(msg);
	Call_PushString(arg1);
	// May want to copy back in the future?
	// for now, no need
	//Call_PushArrayEx(arg1,sizeof(arg1),SM_PARAM_COPYBACK);
	Call_Finish(_:returnVal);
	if(returnVal != Plugin_Continue)
	{
		return Plugin_Handled;
	}

	if(SaxtonHale_SayAllCommand(client,msg,arg1))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action:SaxtonHale_SayCommand(client,args)
{
	decl String:arg1[256]; //was 70
	decl String:msg[256]; //was 70
	GetCmdArg(1,arg1,sizeof(arg1));
	TrimString(arg1);
	GetCmdArgString(msg, sizeof(msg));
	StripQuotes(msg);
	TrimString(msg);

	// remove color tags that a player could type in to
	// add color to your chat (bug fixed)
	CRemoveTag2(arg1, sizeof(arg1));

	new Action:returnVal = Plugin_Continue;
	Call_StartForward(g_hOnTF2JailSayCommandCheckPre);
	Call_PushCell(client);
	// copyback allows changing of client text on pre
	Call_PushStringEx(msg,sizeof(msg),SM_PARAM_STRING_COPY,SM_PARAM_COPYBACK);
	Call_PushStringEx(arg1,sizeof(arg1),SM_PARAM_STRING_COPY,SM_PARAM_COPYBACK);
	Call_Finish(_:returnVal);
	if(returnVal != Plugin_Continue)
	{
		return Plugin_Handled;
	}

	returnVal = Plugin_Continue;
	Call_StartForward(g_hOnTF2JailSayCommandCheckPost);
	Call_PushCell(client);
	Call_PushString(msg);
	Call_PushString(arg1);
	// May want to copy back in the future?
	// for now, no need
	//Call_PushArrayEx(arg1,sizeof(arg1),SM_PARAM_COPYBACK);
	Call_Finish(_:returnVal);
	if(returnVal != Plugin_Continue)
	{
		return Plugin_Handled;
	}

	if(SaxtonHale_SayAllCommand(client,msg,arg1))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}
