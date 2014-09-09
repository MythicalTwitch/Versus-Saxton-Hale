// SaxtonHale_Cookies.sp

public Load_Cookies()
{
	PointCookie = RegClientCookie("hale_queuepoints1", "Amount of VSH Queue points player has", CookieAccess_Protected);
	MusicCookie = RegClientCookie("hale_music_setting", "HaleMusic setting", CookieAccess_Public);
	VoiceCookie = RegClientCookie("hale_voice_setting", "HaleVoice setting", CookieAccess_Public);
	ClasshelpinfoCookie = RegClientCookie("hale_classinfo", "HaleClassinfo setting", CookieAccess_Public);
}

public bool:SaxtonHale_Cookies_InitNatives()
{
	CreateNative("VSH_EmitSoundToAllExcept",Native_VSH_EmitSoundToAllExcept);
	return true;
}

SetClientSoundOptions(client, excepttype, bool:on)
{
	if (!IsValidClient(client)) return;
	if (IsFakeClient(client)) return;
	if (!AreClientCookiesCached(client)) return;
	new String:strCookie[32];
	if (on) strCookie = "1";
	else strCookie = "0";
	if (excepttype == SOUNDEXCEPT_VOICE) SetClientCookie(client, VoiceCookie, strCookie);
	else SetClientCookie(client, MusicCookie, strCookie);
}

public bool:CheckSoundException(client, excepttype)
{
	if (!IsValidClient(client)) return false;
	if (IsFakeClient(client)) return true;
	if (!AreClientCookiesCached(client)) return true;
	decl String:strCookie[32];
	if (excepttype == SOUNDEXCEPT_VOICE) GetClientCookie(client, VoiceCookie, strCookie, sizeof(strCookie));
	else GetClientCookie(client, MusicCookie, strCookie, sizeof(strCookie));
	if (strCookie[0] == 0) return true;
	else return bool:StringToInt(strCookie);
}

public Native_VSH_EmitSoundToAllExcept(Handle:plugin,numParams)
{
	new exceptiontype = GetNativeCell(1);
	new String:sample[PLATFORM_MAX_PATH];
	GetNativeString(2, sample, sizeof(sample));
	new entity = GetNativeCell(3);
	new channel = GetNativeCell(4);
	new level = GetNativeCell(5);
	new flags = GetNativeCell(6);
	new Float:volume = Float:GetNativeCell(7);
	new pitch = GetNativeCell(8);
	new speakerentity = GetNativeCell(9);
	new Float:origin[3];
	GetNativeArray(10, origin, sizeof(origin));
	new Float:dir[3];
	GetNativeArray(11, dir, sizeof(dir));
	new bool:updatePos = bool:GetNativeCell(12);
	new Float:soundtime = Float:GetNativeCell(13);

	EmitSoundToAllExcept(exceptiontype, sample, entity, channel, level,
					 flags, volume, pitch, speakerentity, origin,
					 dir, updatePos, soundtime);
}

public bool:GetClientClasshelpinfoCookie(client)
{
	if (!IsValidClient(client)) return false;
	if (IsFakeClient(client)) return false;
	if (!AreClientCookiesCached(client)) return true;
	decl String:strCookie[32];
	GetClientCookie(client, ClasshelpinfoCookie, strCookie, sizeof(strCookie));
	if (strCookie[0] == 0) return true;
	else return bool:StringToInt(strCookie);
}

public GetClientQueuePoints(client)
{
	if (!IsValidClient(client)) return 0;
	if (IsFakeClient(client))
	{
		return botqueuepoints;
	}
	if (!AreClientCookiesCached(client)) return 0;
	decl String:strPoints[32];
	GetClientCookie(client, PointCookie, strPoints, sizeof(strPoints));
	return StringToInt(strPoints);
}

public SetClientQueuePoints(client, points)
{
	if (!IsValidClient(client)) return;
	if (IsFakeClient(client)) return;
	if (!AreClientCookiesCached(client)) return;
	decl String:strPoints[32];
	IntToString(points, strPoints, sizeof(strPoints));
	SetClientCookie(client, PointCookie, strPoints);
}

public SetAuthIdQueuePoints(String:authid[], points)
{
	decl String:strPoints[32];
	IntToString(points, strPoints, sizeof(strPoints));
	SetAuthIdCookie(authid, PointCookie, strPoints);
}
