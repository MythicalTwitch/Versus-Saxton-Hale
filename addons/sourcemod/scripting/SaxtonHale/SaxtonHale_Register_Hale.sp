// SaxtonHale_Register_Hale.sp

new Handle:g_hHaleName = INVALID_HANDLE;
new Handle:g_hHaleShortName = INVALID_HANDLE;

new HalesLoaded=0;

public SaxtonHale_Register_Hale_OnPluginStart()
{
	g_hHaleName = CreateArray(ByteCountToCells(32));
	g_hHaleShortName = CreateArray(ByteCountToCells(16));
}

public bool:SaxtonHale_Register_Hale_InitNatives()
{
	CreateNative("VSH_GetHaleID", Native_VSH_GetHaleID);
	CreateNative("VSH_GetHaleName", Native_VSH_GetHaleName);
	CreateNative("VSH_RegisterHale", Native_VSH_RegisterHale);
	CreateNative("VSH_UnregisterHale", Native_VSH_UnregisterHale);
	return true;
}

stock GetHalesLoaded()
{
	return GetArraySize(szName);
}

public Native_VSH_GetHaleID(Handle:hPlugin, iNumParams)
{
	return HaleRaceID;
}

public Native_VSH_GetHaleName(Handle:hPlugin, iNumParams)
{
	new String:szMenuTitle[256];
	new itemindex = GetNativeCell(1);
	new bufsize=GetNativeCell(3);
	GetArrayString(g_hMenuMenuTitle,itemindex,szMenuTitle,sizeof(szMenuTitle));
	SetNativeString(2, szMenuTitle, bufsize);
}

public Native_VSH_RegisterHale(Handle:hPlugin, iNumParams)
{
	decl String:szBuffer[32], String:szShortName[16], String:szName[32];

	GetNativeString(1, STRING(szName));
	GetNativeString(2, STRING(szShortName));

	for(new i = 0; i < GetArraySize(szName); i++)
	{
		HalesLoaded++;

		GetArrayString(g_hHaleName, i, szBuffer, sizeof(szBuffer));
		if(StrEqual(szName, szBuffer))
		{
			SetArrayString(g_hHaleName,i,szName);
			SetArrayString(g_hHaleShortName,i,szShortName);

			return i;
		}
	}

	PushArrayString(g_hHaleName, szName);
	PushArrayString(g_hHaleShortName, szShortName);

	HalesLoaded++;

	return GetArraySize(g_hMenuCallerName);
}

public Native_VSH_UnregisterHale(Handle:hPlugin, iNumParams)
{
	new String:szName[32], String:szBuffer[32];

	GetNativeString(1, STRING(szName));

	for(new i = 0; i < GetArraySize(g_hHaleName); i++)
	{
		GetArrayString(g_hHaleName, i, szBuffer, sizeof(szBuffer));
		if(StrEqual(szName, szBuffer))
		{
			RemoveFromArray(g_hHaleName,i);
			RemoveFromArray(g_hHaleShortName,i);

			return true;
		}
	}
	return false;
}
