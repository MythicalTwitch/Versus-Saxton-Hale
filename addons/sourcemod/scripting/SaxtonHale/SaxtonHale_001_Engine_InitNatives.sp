// SaxtonHale_001_Engine_InitNatives.sp

//=============================================================================
// SaxtonHale_InitNatives
//=============================================================================
public bool:SaxtonHale_InitNatives()
{
	new bool:Return_InitNatives=false;

	CreateNative("VSH_IsSaxtonHaleModeMap", Native_IsVSHMap);
	CreateNative("VSH_IsSaxtonHaleModeEnabled", Native_IsEnabled);
	CreateNative("VSH_GetSaxtonHaleUserId", Native_GetHale);
	CreateNative("VSH_GetSaxtonHaleTeam", Native_GetTeam);
	CreateNative("VSH_GetSpecialRoundIndex", Native_GetSpecial);
	CreateNative("VSH_GetSaxtonHaleHealth", Native_GetHealth);
	CreateNative("VSH_GetSaxtonHaleHealthMax", Native_GetHealthMax);
	CreateNative("VSH_GetClientDamage", Native_GetDamage);
	CreateNative("VSH_GetRoundState", Native_GetRoundState);
	CreateNative("VSH_GetNextSaxtonHaleUserId", Native_GetNextSaxtonHaleUserId);
	CreateNative("VSH_IsSpecialEnabled", Native_IsSpecialEnabled);

	Return_InitNatives = SaxtonHale_DamageSystem_InitNatives();

	Return_InitNatives = SaxtonHale_InitNatives();

	Return_InitNatives = SaxtonHale_GlobalVars_InitNatives();

	//Return_InitNatives =

	//Return_InitNatives =

	//Return_InitNatives =

	return Return_InitNatives;
}


