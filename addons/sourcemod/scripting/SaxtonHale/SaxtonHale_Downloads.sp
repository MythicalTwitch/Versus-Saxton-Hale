public AddToDownload()
{
	decl String:s[PLATFORM_MAX_PATH];
	new String:extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
	new String:extensionsb[][] = { ".vtf", ".vmt" };
	decl i;
	for (i = 0; i < sizeof(extensions); i++)
	{
		Format(s, PLATFORM_MAX_PATH, "%s%s", HaleModelPrefix, extensions[i]);
		if (FileExists(s, true)) AddFileToDownloadsTable(s);

		if (bSpecials)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%s", VagineerModelPrefix, extensions[i]);
			if (FileExists(s, true)) AddFileToDownloadsTable(s);

			Format(s, PLATFORM_MAX_PATH, "%s%s", HHHModelPrefix, extensions[i]);
			if (FileExists(s, true)) AddFileToDownloadsTable(s);

			Format(s, PLATFORM_MAX_PATH, "%s%s", CBSModelPrefix, extensions[i]);
			if (FileExists(s, true)) AddFileToDownloadsTable(s);

#if defined EASTER_BUNNY_ON
			Format(s, PLATFORM_MAX_PATH, "%s%s", BunnyModelPrefix, extensions[i]);
			if (FileExists(s, true)) AddFileToDownloadsTable(s);
			Format(s, PLATFORM_MAX_PATH, "%s%s", EggModelPrefix, extensions[i]);
			if (FileExists(s, true)) AddFileToDownloadsTable(s);
//          Format(s, PLATFORM_MAX_PATH, "%s%s", ReloadEggModelPrefix, extensions[i]);
//          if (FileExists(s, true)) AddFileToDownloadsTable(s);
#endif
		}
	}
	PrecacheModel(HaleModel, true);
	if (bSpecials)
	{
		PrecacheModel(VagineerModel, true);
		PrecacheModel(HHHModel, true);
		PrecacheModel(CBSModel, true);
#if defined EASTER_BUNNY_ON
		PrecacheModel(BunnyModel, true);
		PrecacheModel(EggModel, true);
//      PrecacheModel(ReloadEggModel, true);
		AddFileToDownloadsTable("materials/models/player/easter_demo/demoman_head_red.vmt");
		AddFileToDownloadsTable("materials/models/player/easter_demo/easter_body.vmt");
		AddFileToDownloadsTable("materials/models/player/easter_demo/easter_body.vtf");
		AddFileToDownloadsTable("materials/models/player/easter_demo/easter_rabbit.vmt");
		AddFileToDownloadsTable("materials/models/player/easter_demo/easter_rabbit.vtf");
		AddFileToDownloadsTable("materials/models/player/easter_demo/easter_rabbit_normal.vtf");
		AddFileToDownloadsTable("materials/models/props_easteregg/c_easteregg.vmt");
		AddFileToDownloadsTable("materials/models/props_easteregg/c_easteregg.vtf");
		AddFileToDownloadsTable("materials/models/props_easteregg/c_easteregg_gold.vmt");
		AddFileToDownloadsTable("materials/models/player/easter_demo/eyeball_r.vmt");
#endif
	}
	for (i = 0; i < sizeof(extensionsb); i++)
	{
		Format(s, PLATFORM_MAX_PATH, "materials/models/player/saxton_hale/eye%s", extensionsb[i]);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "materials/models/player/saxton_hale/hale_head%s", extensionsb[i]);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "materials/models/player/saxton_hale/hale_body%s", extensionsb[i]);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "materials/models/player/saxton_hale/hale_misc%s", extensionsb[i]);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "materials/models/player/saxton_hale/sniper_red%s", extensionsb[i]);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "materials/models/player/saxton_hale/sniper_lens%s", extensionsb[i]);
		AddFileToDownloadsTable(s);
	}
	AddFileToDownloadsTable("materials/models/player/saxton_hale/sniper_head.vtf");
	AddFileToDownloadsTable("materials/models/player/saxton_hale/sniper_head_red.vmt");
	AddFileToDownloadsTable("materials/models/player/saxton_hale/hale_misc_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/saxton_hale/hale_body_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/saxton_hale/eyeball_l.vmt");
	AddFileToDownloadsTable("materials/models/player/saxton_hale/eyeball_r.vmt");
	AddFileToDownloadsTable("materials/models/player/saxton_hale/hale_egg.vtf");
	AddFileToDownloadsTable("materials/models/player/saxton_hale/hale_egg.vmt");
	PrecacheSound(HaleComicArmsFallSound, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleComicArmsFallSound);
	AddFileToDownloadsTable(s);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKSpree);
	PrecacheSound(HaleKSpree, true);
	AddFileToDownloadsTable(s);
	PrecacheSound("saxton_hale/9000.wav", true);
	AddFileToDownloadsTable("sound/saxton_hale/9000.wav");
//  PrecacheSound(HaleTempTheme, true);

	for (i = 1; i <= 4; i++)
	{
		Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HaleLastB, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HHHLaught, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HHHAttack, i);
		PrecacheSound(s, true);
	}
	if (bSpecials)
	{
		PrecacheSound("ui/halloween_boss_summoned_fx.wav", true);
		PrecacheSound("ui/halloween_boss_defeated_fx.wav", true);
		PrecacheSound(VagineerLastA, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerLastA);
		AddFileToDownloadsTable(s);
		PrecacheSound(VagineerStart, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerStart);
		AddFileToDownloadsTable(s);
		PrecacheSound(VagineerRageSound, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerRageSound);
		AddFileToDownloadsTable(s);
		PrecacheSound(VagineerKSpree, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerKSpree);
		AddFileToDownloadsTable(s);
		PrecacheSound(VagineerKSpree2, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerKSpree2);
		AddFileToDownloadsTable(s);
		PrecacheSound(VagineerHit, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerHit);
		AddFileToDownloadsTable(s);
		PrecacheSound(HHHRage, true);
		PrecacheSound(HHHRage2, true);
		PrecacheSound(CBS0, true);
		PrecacheSound(CBS1, true);
		PrecacheSound(HHHTheme, true);
		PrecacheSound(CBSTheme, true);
		AddFileToDownloadsTable("sound/saxton_hale/the_millionaires_holiday.mp3");
		PrecacheSound(CBSJump1, true);
		for (i = 1; i <= 25; i++)
		{
			if (i <= 9)
			{
				Format(s, PLATFORM_MAX_PATH, "%s%02i.wav", CBS2, i);
				PrecacheSound(s, true);
			}
			Format(s, PLATFORM_MAX_PATH, "%s%02i.wav", CBS4, i);
			PrecacheSound(s, true);
		}
	}
	PrecacheSound(HaleKillMedic, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillMedic);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSniper1, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillSniper1);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSniper2, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillSniper2);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSpy1, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillSpy1);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSpy2, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillSpy2);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillEngie1, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillEngie1);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillEngie2, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillEngie2);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillDemo132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillDemo132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillHeavy132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillHeavy132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillScout132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillScout132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillSpy132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillSpy132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillPyro132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillPyro132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleSappinMahSentry132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleSappinMahSentry132);
	AddFileToDownloadsTable(s);
	PrecacheSound(HaleKillLast132, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", HaleKillLast132);
	AddFileToDownloadsTable(s);
	PrecacheSound("vo/announcer_am_capincite01.wav", true);
	PrecacheSound("vo/announcer_am_capincite03.wav", true);
	PrecacheSound("vo/announcer_am_capenabled02.wav", true);
	for (i = 1; i <= 5; i++)
	{
		if (i <= 2)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleJump, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
			if (bSpecials)
			{
				Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, i);
				PrecacheSound(s, true);
				Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
				AddFileToDownloadsTable(s);
				Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, i);
				PrecacheSound(s, true);
				Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
				AddFileToDownloadsTable(s);
				Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, i);
				PrecacheSound(s, true);
				Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
				AddFileToDownloadsTable(s);
			}
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleWin, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleJump132, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillEngie132, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillKSpree132, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
		}
		if (i <= 3)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleFail, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
		}
		if (i <= 4)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleRageSound, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleStubbed132, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleRoundStart, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
		AddFileToDownloadsTable(s);
		if (bSpecials)
		{
			PrecacheSound(VagineerRoundStart, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerRoundStart);
			AddFileToDownloadsTable(s);
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
			AddFileToDownloadsTable(s);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKSpreeNew, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleLastMan, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
		AddFileToDownloadsTable(s);
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleStart132, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
		AddFileToDownloadsTable(s);
	}
	PrecacheSound("vo/engineer_no01.wav", true);
	PrecacheSound("vo/engineer_jeers02.wav", true);
	PrecacheSound("vo/sniper_dominationspy04.wav", true);
	PrecacheSound("vo/halloween_boss/knight_pain01.wav", true);
	PrecacheSound("vo/halloween_boss/knight_pain02.wav", true);
	PrecacheSound("vo/halloween_boss/knight_pain03.wav", true);
	PrecacheSound("vo/halloween_boss/knight_death01.wav", true);
	PrecacheSound("vo/halloween_boss/knight_death02.wav", true);
	//PrecacheSound("weapons/barret_arm_zap.wav", true);
	PrecacheSound("player/doubledonk.wav", true);
	PrecacheSound("misc/halloween/spell_teleport.wav", true);
#if defined EASTER_BUNNY_ON
	for (i = 0; i < sizeof(BunnyWin); i++)
	{
		PrecacheSound(BunnyWin[i], true);
	}
	for (i = 0; i < sizeof(BunnyJump); i++)
	{
		PrecacheSound(BunnyJump[i], true);
	}
	for (i = 0; i < sizeof(BunnyRage); i++)
	{
		PrecacheSound(BunnyRage[i], true);
	}
	for (i = 0; i < sizeof(BunnyFail); i++)
	{
		PrecacheSound(BunnyFail[i], true);
	}
	for (i = 0; i < sizeof(BunnyKill); i++)
	{
		PrecacheSound(BunnyKill[i], true);
	}
	for (i = 0; i < sizeof(BunnySpree); i++)
	{
		PrecacheSound(BunnySpree[i], true);
	}
	for (i = 0; i < sizeof(BunnyLast); i++)
	{
		PrecacheSound(BunnyLast[i], true);
	}
	for (i = 0; i < sizeof(BunnyPain); i++)
	{
		PrecacheSound(BunnyPain[i], true);
	}
	for (i = 0; i < sizeof(BunnyStart); i++)
	{
		PrecacheSound(BunnyStart[i], true);
	}

#endif
}
