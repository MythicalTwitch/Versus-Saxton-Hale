// War3Source_Engine_Death_And_Spawn_Events.sp

public Internal_OnVSHEventSpawn(client)
{
}

public Internal_OnVSHEventDeath(victim,attacker,deathrace,distance,attacker_hpleft)
{
}

/*
public War3Source_RoundOverEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	// cs - int winner
	// tf2 - int team
	//new team=GetEventInt(event,"team");
	if(GetEventInt(event,"team")>-1)
	{
		//winner team...
	}
}
*/

DoForward_OnVSH_EventSpawn(client){
		Call_StartForward(g_OnEventSpawn);
		Call_PushCell(client);
		Call_Finish(dummyreturn);
}
DoForward_OnVSH_EventDeath(victim,killer,distance,attacker_hpleft){
		Call_StartForward(g_OnEventDeath);
		Call_PushCell(victim);
		Call_PushCell(killer);
		Call_PushCell(distance);
		Call_PushCell(attacker_hpleft);
		Call_Finish(dummyreturn);
}

public VSH_PlayerSpawnEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	new userid=GetEventInt(event,"userid");
	if(userid>0)
	{
		new client=GetClientOfUserId(userid);
		if(ValidPlayer(client,true))
		{

			//DP("spawn %d",client);

			//bIgnoreTrackGF[client]=false;
			//SetMaxHP_INTERNAL(client,GetClientHealth(client));
			//PrintToChatAll("%d",GetClientHealth(index));

			if(!VSH_GetPlayerProp(client,SpawnedOnce))
			{
				VSH_SetPlayerProp(client,SpawnedOnce,true);
			}
			//forward to all other plugins last
			Internal_OnVSHEventSpawn(client);

			DoForward_OnVSH_EventSpawn(client);

			SetPlayerProp(client,bStatefulSpawn,false); //no longer a "stateful" spawn
		}
	}
}

public Action:VSH_PlayerDeathEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
	new uid_victim = GetEventInt(event, "userid");
	new uid_attacker = GetEventInt(event, "attacker");
	//new uid_entity = GetEventInt(event, "entityid");

	new victimIndex = 0;
	new attackerIndex = 0;

	new victim = GetClientOfUserId(uid_victim);
	new attacker = GetClientOfUserId(uid_attacker);

	new distance=0;
	new attacker_hpleft=0;

	//new String:weapon[32];
	//GetEventString(event, "weapon", weapon, 32);
	//ReplaceString(weapon, 32, "WEAPON_", "");

	if(victim>0&&attacker>0)
	{
		//Get the distance
		new Float:victimLoc[3];
		new Float:attackerLoc[3];
		GetClientAbsOrigin(victim,victimLoc);
		GetClientAbsOrigin(attacker,attackerLoc);
		distance = RoundToNearest(FloatDiv(calcDistance(victimLoc[0],attackerLoc[0], victimLoc[1],attackerLoc[1], victimLoc[2],attackerLoc[2]),12.0));

		attacker_hpleft = GetClientHealth(attacker);

	}


	if(uid_attacker>0){
		attackerIndex=GetClientOfUserId(uid_attacker);
	}

	if(uid_victim>0){
		victimIndex=GetClientOfUserId(uid_victim);
	}

	new bool:deadringereath=false;
	if(uid_victim>0)
	{
		new deathFlags = GetEventInt(event, "death_flags");
		if (deathFlags & 32) //TF_DEATHFLAG_DEADRINGER
		{
			deadringereath=true;
			//PrintToChat(client,"war3 debug: dead ringer kill");

			/*
			new assister=GetClientOfUserId(GetEventInt(event,"assister"));

			if(victimIndex!=attackerIndex&&ValidPlayer(attackerIndex))
			{
				if(GetClientTeam(attackerIndex)!=GetClientTeam(victimIndex))
				{
					//decl String:weapon[64];
					//GetEventString(event,"weapon",weapon,sizeof(weapon));
					//new bool:is_hs,bool:is_melee;
					//is_hs=(GetEventInt(event,"customkill")==1);
					//DP("wep %s",weapon);
					//is_melee=W3IsDamageFromMelee(weapon);
					if(assister>=0)
					{
						// fake death
					}
					// fake death
				}
			}
			*/

		}
	}

	if(victimIndex&&!deadringereath) //forward to all other plugins last
	{
		new Handle:oldevent=W3GetVar(SmEvent);
		//	DP("new event %d",event);
		VSHSetVar(SmEvent,event); //stacking on stack

		//pre death event, internal event
		//W3SetVar(EventArg1,attackerIndex);

		//CreateEvent(OnDeathPre,victimIndex);
		// Create a Event for pre death later?

		Internal_OnVSHEventDeath(victimIndex,attackerIndex,distance,attacker_hpleft);

		DoForward_OnVSH_EventDeath(victimIndex,attackerIndex,distance,attacker_hpleft);

		VSHSetVar(SmEvent,oldevent); //restore on stack , if any

		SetPlayerProp(victimIndex,bStatefulSpawn,true);//next spawn shall be stateful
	}
	return Plugin_Continue;
}

public Float:calcDistance(Float:x1,Float:x2,Float:y1,Float:y2,Float:z1,Float:z2){
	//Distance between two 3d points
	new Float:dx = x1-x2;
	new Float:dy = y1-y2;
	new Float:dz = z1-z2;

	return(SquareRoot(dx*dx + dy*dy + dz*dz));
}

