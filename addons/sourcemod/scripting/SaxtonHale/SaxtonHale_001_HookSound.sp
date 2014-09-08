// SaxtonHale_001_HookSound.sp

public Action:HookSound(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	if (!Enabled || ((entity != Hale) && ((entity <= 0) || !IsValidClient(Hale) || (entity != GetPlayerWeaponSlot(Hale, 0)))))
		return Plugin_Continue;
	if (StrContains(sample, "saxton_hale", false) != -1)
		return Plugin_Continue;
	if (strcmp(sample, "vo/engineer_LaughLong01.wav", false) == 0)
	{
		strcopy(sample, PLATFORM_MAX_PATH, VagineerKSpree);
		return Plugin_Changed;
	}
	if (entity == Hale && Special == VSHSpecial_HHH && strncmp(sample, "vo", 2, false) == 0 && StrContains(sample, "halloween_boss") == -1)
	{
		if (GetRandomInt(0, 100) <= 10)
		{
			Format(sample, PLATFORM_MAX_PATH, "%s0%i.wav", HHHLaught, GetRandomInt(1, 4));
			return Plugin_Changed;
		}
	}
	if (Special != VSHSpecial_CBS && !strncmp(sample, "vo", 2, false) && StrContains(sample, "halloween_boss") == -1)
	{
		if (Special == VSHSpecial_Vagineer)
		{
			if (StrContains(sample, "engineer_moveup", false) != -1)
				Format(sample, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
			else if (StrContains(sample, "engineer_no", false) != -1 || GetRandomInt(0, 9) > 6)
				strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_no01.wav");
			else
				strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_jeers02.wav");
			return Plugin_Changed;
		}
		else if (Special == VSHSpecial_Bunny)
		{
			if (StrContains(sample, "gibberish", false) == -1 && StrContains(sample, "burp", false) == -1 && !GetRandomInt(0, 2))
			{
				//Do sound things
				strcopy(sample, PLATFORM_MAX_PATH, BunnyRandomVoice[GetRandomInt(0, sizeof(BunnyRandomVoice)-1)]);
				return Plugin_Changed;
			}
			return Plugin_Continue;
		}
#if defined MIKU_ON
		else if (Special == VSHSpecial_Miku)
		{
			//if (StrContains(sample, "scout", false) == -1 && !GetRandomInt(0, 2))
			if (StrContains(sample, "scout", false) > -1)
			{
				//if(!GetRandomInt(0, 2))
				//{
				//Do sound things
				strcopy(sample, PLATFORM_MAX_PATH, MikuRandomVoice[GetRandomInt(0, sizeof(MikuRandomVoice)-1)]);
				return Plugin_Changed;
				//}
				//else
				//{
					//return Plugin_Handled;
				//}
			}
			return Plugin_Continue;
		}
#endif
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
