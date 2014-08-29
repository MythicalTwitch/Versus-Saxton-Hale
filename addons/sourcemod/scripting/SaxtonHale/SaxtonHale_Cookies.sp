public Load_Cookies()
{
	PointCookie = RegClientCookie("hale_queuepoints1", "Amount of VSH Queue points player has", CookieAccess_Protected);
	MusicCookie = RegClientCookie("hale_music_setting", "HaleMusic setting", CookieAccess_Public);
	VoiceCookie = RegClientCookie("hale_voice_setting", "HaleVoice setting", CookieAccess_Public);
	ClasshelpinfoCookie = RegClientCookie("hale_classinfo", "HaleClassinfo setting", CookieAccess_Public);
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
