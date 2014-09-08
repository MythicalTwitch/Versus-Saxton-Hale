// SaxtonHale_001_OnPreThinkPost.sp

/*
Runs every frame for clients

*/
public OnPreThinkPost(client)
{
	if (IsNearSpencer(client) && TF2_IsPlayerInCondition(client, TFCond_Cloaked))
	{
		new Float:cloak = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") - 0.5;

		if (cloak < 0.0)
		{
			cloak = 0.0;
		}

		SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);

		/*if (RoundFloat(GetGameTime()) == GetGameTime())
		{
			CPrintToChdata("%N DISPENSE %f", client, GetGameTime());
		}*/
	}
}
