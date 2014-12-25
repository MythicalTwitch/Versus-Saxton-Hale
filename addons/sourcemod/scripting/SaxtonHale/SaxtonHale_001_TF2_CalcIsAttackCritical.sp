// SaxtonHale_001_TF2_CalcIsAttackCritical.sp
/*
public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	if (!IsValidClient(client, false) || !Enabled) return Plugin_Continue;

	// HHH can climb walls
	if (IsValidEntity(weapon) && Special == VSHSpecial_HHH && client == Hale && HHHClimbCount <= 9 && VSHRoundState > ROUNDSTATE_EVENT_ROUND_START)
	{
		new index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");

		if (index == 266 && StrEqual(weaponname, "tf_weapon_sword", false))
		{
			SickleClimbWalls(client, weapon);
			WeighDownTimer = 0.0;
			HHHClimbCount++;
		}
	}

	if (client == Hale)
	{
		if (VSHRoundState != ROUNDSTATE_START_ROUND_TIMER) return Plugin_Continue;
		if (TF2_IsPlayerCritBuffed(client)) return Plugin_Continue;
		if (!haleCrits)
		{
			result = false;
			return Plugin_Changed;
		}
	}
	else if (IsValidEntity(weapon))
	{
		new index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		if (index == 232 && StrEqual(weaponname, "tf_weapon_club", false))
		{
			SickleClimbWalls(client, weapon);
		}
	}
	return Plugin_Continue;
}
*/
