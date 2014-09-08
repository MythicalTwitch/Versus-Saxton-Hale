// SaxtonHale_Register_Hale.sp

new Handle:g_hMenuCallerName = INVALID_HANDLE;
new Handle:g_hMenuMenuTitle = INVALID_HANDLE;
new Handle:g_hMenuFwd = INVALID_HANDLE;

public OnPluginStart()
{
	g_hMenuCallerName = CreateArray();
	g_hMenuMenuTitle = CreateArray(256);
	g_hMenuFwd = CreateArray();
}

public bool:SaxtonHale_Register_Hale_InitNatives()
{
	CreateNative("VSH_GetHaleName", Native_VSH_GetHaleName);
	CreateNative("VSH_RegisterHale", Native_VSH_RegisterHale);
	CreateNative("VSH_UnregisterHale", Native_VSH_UnregisterHale);
	return true;
}

stock CallHale(HaleIndex,client)
{
	new Handle:hFwd = GetArrayCell(g_hMenuFwd, iIndex);

	new bool:result;
	Call_StartForward(hFwd);
	Call_PushCell(client);
	Call_Finish(result);
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
	new String:szCallerName[PLATFORM_MAX_PATH], String:szBuffer[256], String:szMenuTitle[256];
	GetPluginFilename(hPlugin, szCallerName, sizeof(szCallerName));

	new Handle:hFwd = CreateForward(ET_Single, Param_Cell, Param_CellByRef);
	if (!AddToForward(hFwd, hPlugin, GetNativeCell(2)))
		ThrowError("Failed to add forward from %s", szCallerName);

	GetNativeString(1, szMenuTitle, 255);

	for(new i = 0; i < GetArraySize(g_hMenuCallerName); i++)
	{
		GetArrayString(g_hMenuMenuTitle, i, szBuffer, sizeof(szBuffer));
		if(StrEqual(szMenuTitle, szBuffer))
		{
			// If the title is the same then change the Values

			//SetArrayCell(Handle:array, index, any:value, block=0, bool:asChar=false);
			//SetArrayString(Handle:array, index, const String:value[]);

			SetArrayString(g_hMenuCallerName,i,szCallerName);
			SetArrayCell(g_hMenuFwd,i,hFwd);

			//DoForwardOnRegisterMenuItem(szMenuTitle);
			//new MenuID = i + MENUID_EXTRA_NUM;
			return MenuID;
		}
	}

	PushArrayString(g_hMenuCallerName, szCallerName);
	PushArrayString(g_hMenuMenuTitle, szMenuTitle);
	PushArrayCell(g_hMenuFwd, hFwd);
	//DoForwardOnRegisterMenuItem(szMenuTitle);
	new MenuID = MENUID_EXTRA_NUM + GetArraySize(g_hMenuCallerName);
	return MenuID;
}

public Native_VSH_UnregisterHale(Handle:hPlugin, iNumParams)
{
	new String:szMenuTitle[256], String:szBuffer[256];

	GetNativeString(1, szMenuTitle, 255);

	for(new i = 0; i < GetArraySize(g_hMenuCallerName); i++)
	{
		GetArrayString(g_hMenuMenuTitle, i, szBuffer, sizeof(szBuffer));
		if(StrEqual(szMenuTitle, szBuffer))
		{
			RemoveFromArray(g_hMenuCallerName,i);
			RemoveFromArray(g_hMenuMenuTitle,i);
			RemoveFromArray(g_hMenuFwd,i);

			return true;
		}
	}
	return false;
}
