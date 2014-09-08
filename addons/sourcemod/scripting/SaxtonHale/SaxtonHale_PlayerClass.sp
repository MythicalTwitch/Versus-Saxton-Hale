// SaxtonHale_PlayerClass.sp

public Plugin:myinfo=
{
	name="SaxtonHale Engine player class",
	author="El Diablo",
	description="SaxtonHale Core Plugins",
	version="1.0",
	url="http://war3evo.info/"
};

public SaxtonHale_PlayerClass_OnPluginStart()
{
	HookEvent("player_team", Event_PlayerTeam);
}

public bool:SaxtonHale_PlayerClass_InitNatives()
{
	CreateNative("VSH_SetPlayerProp",Native_VSH_SetPlayerProp);
	CreateNative("VSH_GetPlayerProp",Native_VSH_GetPlayerProp);
	return true;
}

public Native_VSH_GetPlayerProp(Handle:plugin,numParams){
	return GetPlayerProp(GetNativeCell(1),VSH_PlayerProp:GetNativeCell(2));
}

public Native_VSH_SetPlayerProp(Handle:plugin,numParams){
	SetPlayerProp(GetNativeCell(1),VSH_PlayerProp:GetNativeCell(2),any:GetNativeCell(3));
}

public Event_PlayerTeam(Handle:event,  const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	SetPlayerProp(client,LastChangeTeamTime,GetEngineTime());
}
