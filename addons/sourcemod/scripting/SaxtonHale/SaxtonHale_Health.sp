/**
* OnGetMaxHealth:
*
* Helps keep Hale from looking as if he has overheal.
*
*/
public Action:OnGetMaxHealth(client, &maxhealth)
{
	if(VSHRoundState != ROUNDSTATE_START_ROUND_TIMER)
	{
		return Plugin_Continue;
	}
	if (ValidPlayer(client,true) && client==Hale)
	{
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
