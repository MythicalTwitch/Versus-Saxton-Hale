public FindHealthBar()
{
	g_healthBar = FindEntityByClassname(-1, HEALTHBAR_CLASS);

	if (g_healthBar == -1)
	{
		g_healthBar = CreateEntityByName(HEALTHBAR_CLASS);
		if (g_healthBar != -1)
		{
			DispatchSpawn(g_healthBar);
		}
	}
}

//UpdateBossHealth(iHale)
public UpdateBossHealth()
{
	if (g_healthBar == -1)
	{
		return;
	}

	new percentage;
	if (Hale>0)
	{
		new maxHP = GetEntProp(Hale, Prop_Data, "m_iMaxHealth");
		new HP = GetEntProp(Hale, Prop_Data, "m_iHealth");
		//new HP = iHP;
		//new maxHP = imaxHP;

		if (HP <= 0)
		{
			percentage = 0;
		}
		else
		{
			new Float:fHP = float(HP);
			new Float:fmaxHP = float(maxHP);
			new Float:fHEALTHBAR = float(HEALTHBAR_MAX);

			percentage = RoundToCeil(FloatMul(FloatDiv(fHP,fmaxHP),fHEALTHBAR));
			//percentage = RoundToCeil(float(HP) / (maxHP / 4) * HEALTHBAR_MAX);


			//PrintCenterTextAll("Percentage %d",percentage);

			if(percentage>HEALTHBAR_MAX)
			{
				percentage=HEALTHBAR_MAX;
			}
			//new Float:fHP = float(HP);
			//new Float:fmaxHP = float(maxHP);
			//new Float:fHEALTHBAR = float(HEALTHBAR_MAX);
			//percentage = RoundToCeil(FloatDiv(fHP,FloatMul(FloatDiv(fmaxHP,4.0),fHEALTHBAR)));
		}
	}
	else
	{
		percentage = 0;
	}
	SetEntProp(g_healthBar, Prop_Send, HEALTHBAR_PROPERTY, percentage);
}

public Action:OnGetMaxHealth(client, &maxhealth)
{
	//,HaleHealth, HaleHealthMax
	if (client==Hale)
	{
		//PrintCenterTextAll("BOSS is trying to cheat by grabbing health!");
		new HP = GetEntProp(client, Prop_Data, "m_iHealth");
		if(HP>HaleHealthMax)
		{
			SetEntProp(client, Prop_Data, "m_iHealth", HaleHealth);
		}
		maxhealth=HaleHealthMax;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}


