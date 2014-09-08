// SaxtonHale_DamageSystem.sp

///would you like to see the damage stack print out?
//#define DEBUG
new Handle:FHOnVSH_TakeDmgAllPre;
new Handle:FHOnVSH_TakeDmgAll;

new Handle:g_OnVSHEventPostHurtFH;
new Handle:PyroVSH_ChanceModifierCvar;
new Handle:HeavyVSH_ChanceModifierCvar;

new g_CurDamageType=-99;
new g_CurInflictor=-99; //variables from sdkhooks, natives retrieve them if needed

new Float:g_CurDMGModifierPercent=-99.9;

new g_CurLastActualDamageDealt=-99;

new bool:g_CanSetDamageMod=false; //default false, you may not change damage percent when there is none to change
new bool:g_CanDealDamage=true; //default true, you can initiate damage out of nowhere
//for deal damage only

new dummyresult;

//global
new ownerOffset;

new damagestack=0;

new Float:ChanceModifier[34];

public SaxtonHale_DamageSystem_OnPluginStart()
{
	PyroVSH_ChanceModifierCvar=CreateConVar("jailbreak_pyro_w3chancemod","0.500","Float 0.0 - 1.0");
	HeavyVSH_ChanceModifierCvar=CreateConVar("jailbreak_heavy_w3chancemod","0.666","Float 0.0 - 1.0");

	ownerOffset = FindSendPropInfo("CBaseObject", "m_hBuilder");
}


//cvar handle
new Handle:ChanceModifierSentry;
new Handle:ChanceModifierSentryRocket;

public bool:SaxtonHale_DamageSystem_InitNatives()
{
	CreateNative("VSH_DamageModPercent",Native_VSH_DamageModPercent);

	CreateNative("VSH_GetDamageType",NVSH_GetDamageType);
	CreateNative("VSH_SetDamageType",NVSH_SetDamageType);
	CreateNative("VSH_GetDamageInflictor",NVSH_GetDamageInflictor);

	CreateNative("VSH_GetVSHDamageDealt",Native_VSH_GetVSHDamageDealt);

	CreateNative("VSH_GetDamageStack",NVSH_GetDamageStack);

	CreateNative("VSH_ChanceModifier",Native_VSH_ChanceModifier);
	CreateNative("VSH_IsOwnerSentry",Native_VSH_IsOwnerSentry);

	return true;
}

public bool:DamageSystem_InitForwards()
{
	FHOnVSH_TakeDmgAllPre=CreateGlobalForward("OnVSH_TakeDmgAllPre",ET_Hook,Param_Cell,Param_Cell,Param_Cell,Param_Cell);
	FHOnVSH_TakeDmgAll=CreateGlobalForward("OnVSH_TakeDmgAll",ET_Hook,Param_Cell,Param_Cell,Param_CellByRef);

	g_OnVSHEventPostHurtFH=CreateGlobalForward("OnVSHEventPostHurt",ET_Ignore,Param_Cell,Param_Cell,Param_Cell,Param_String);

	ChanceModifierSentry=CreateConVar("sb_chancemodifier_sentry","","None to use attack rate dependent chance modifier. Set from 0.0 to 1.0 chance modifier for sentry, this will override time dependent chance modifier");
	ChanceModifierSentryRocket=CreateConVar("sb_chancemodifier_sentryrocket","","None to use attack rate dependent chance modifier. Set from 0.0 to 1.0 chance modifier for sentry, this will override time dependent chance modifier");

	return true;
}

public Native_VSH_DamageModPercent(Handle:plugin,numParams)
{
	if(!g_CanSetDamageMod){
		LogError("	");
		ThrowError("You may not set damage mod percent here, use ....Pre forward");
		//VSH_LogError("You may not set damage mod percent here, use ....Pre forward");
		//PrintPluginError(plugin);
	}

	new Float:num=GetNativeCell(1);
	#if defined DEBUG
	PrintToServer("percent change %f",num);
	#endif
	g_CurDMGModifierPercent*=num;

}

public Native_VSH_GetVSHDamageDealt(Handle:plugin,numParams) {
	return g_CurLastActualDamageDealt;
}
public NVSH_SetDamageType(Handle:plugin,numParams){
	g_CurDamageType=GetNativeCell(1);
}
public NVSH_GetDamageType(Handle:plugin,numParams){
	return g_CurDamageType;
}
public NVSH_GetDamageInflictor(Handle:plugin,numParams){
	return g_CurInflictor;
}
public NVSH_GetDamageStack(Handle:plugin,numParams){
	return damagestack;
}

// Damage Engine needs to know about sentries and dispensers and stuff...
public DamageSystem_OnEntityCreated(entity, const String:classname[])
{
	// Errors from this event... gives massive negative values.. should use entity > 0
	// DONT REMOVE entity>0
	if(entity>0 && IsValidEntity(entity))
	{
		SDKHook(entity, SDKHook_OnTakeDamage, SDK_Forwarded_OnTakeDamage);
	}
}

public SaxtonHale_DamageSystem_OnClientPutInServer(client){
	SDKHook(client,SDKHook_OnTakeDamage,SDK_Forwarded_OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePostHook);
}
public SaxtonHale_DamageSystem_OnClientDisconnect(client){
	SDKUnhook(client,SDKHook_OnTakeDamage,SDK_Forwarded_OnTakeDamage);
	SDKUnhook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePostHook);
}

public Native_VSH_IsOwnerSentry(Handle:plugin,numParams)
{
	new client=GetNativeCell(1);
	new bool:UseInternalInflictor=GetNativeCell(2);
	new pSentry;
	if(UseInternalInflictor)
		pSentry=g_CurInflictor;
	else
		pSentry=GetNativeCell(3);

	if(ValidPlayer(client))
	{
		if(IsValidEntity(pSentry)&&TF2_GetPlayerClass(client)==TFClass_Engineer)
		{
			decl String:netclass[32];
			GetEntityNetClass(pSentry, netclass, sizeof(netclass));

			if (strcmp(netclass, "CObjectSentrygun") == 0 || strcmp(netclass, "CObjectTeleporter") == 0 || strcmp(netclass, "CObjectDispenser") == 0)
			{
				if (GetEntDataEnt2(pSentry, ownerOffset) == client)
					return true;
			}
		}
	}
	return false;
}

public Native_VSH_ChanceModifier(Handle:plugin,numParams)
{

	new attacker=GetNativeCell(1);
	if(attacker<=0 || attacker>MaxClients || !IsValidEdict(attacker)){
		return _:1.0;
	}

	new Float:tempChance = GetRandomFloat(0.0,1.0);
	switch (TF2_GetPlayerClass(attacker))
	{
		case TFClass_Heavy:
		{
			if (tempChance <= GetConVarFloat(HeavyVSH_ChanceModifierCvar)) //heavy cvar here, replaces 0.666
				return _:0.0;
		}
		case TFClass_Pyro:
		{
			if (tempChance <= GetConVarFloat(PyroVSH_ChanceModifierCvar)) //pyro cvar here, replaces 0.500
				return _:0.0;
		}
	}
	return _:ChanceModifier[attacker];
}

new VictimCheck=-999;
new AttackerCheck=-999;
new InflictorCheck=-999;
new Float:DamageCheck=-999.9;
new DamageTypeCheck=-999;
new WeaponCheck=-999;
new Float:damageForceCheck[3];
new Float:damagePositionCheck[3];
new damagecustomCheck = -999;

public Action:SDK_Forwarded_OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	// Prevents ghosting of damage
	if(VictimCheck==victim
	&&AttackerCheck==attacker
	&&InflictorCheck==inflictor
	&&DamageCheck==damage
	&&DamageTypeCheck==damagetype
	&&WeaponCheck==weapon
	&&damageForceCheck[0]==damageForce[0]
	&&damageForceCheck[1]==damageForce[1]
	&&damageForceCheck[2]==damageForce[2]
	&&damagePositionCheck[0]==damagePosition[0]
	&&damagePositionCheck[1]==damagePosition[1]
	&&damagePositionCheck[2]==damagePosition[2]
	&&damagecustomCheck==damagecustom
	)
	{
		return Plugin_Continue;
	}
	if(ValidPlayer(victim,true)){
		//store old variables on local stack!

		new old_DamageType= g_CurDamageType;
		new old_Inflictor= g_CurInflictor;
		new Float:old_DamageModifierPercent = g_CurDMGModifierPercent;

		//set these to global
		g_CurDamageType=damagetype;
		g_CurInflictor=inflictor;
		g_CurDMGModifierPercent=1.0;

		//#if defined DEBUG
		//DP2("sdktakedamage %d->%d at damage [%.2f]",attacker,victim,damage);
		//#endif

		damagestack++;

		if(attacker!=inflictor)
		{
			if(inflictor>0 && IsValidEdict(inflictor))
			{
				new String:ent_name[64];
				GetEdictClassname(inflictor,ent_name,64);
						//	DP("ent name %s",ent_name);
				if(StrContains(ent_name,"obj_sentrygun",false)==0	&&!CvarEmpty(ChanceModifierSentry))
				{
					ChanceModifier[attacker]=GetConVarFloat(ChanceModifierSentry);
				}
				else if(StrContains(ent_name,"tf_projectile_sentryrocket",false)==0 &&!CvarEmpty(ChanceModifierSentryRocket))
				{
					ChanceModifier[attacker]=GetConVarFloat(ChanceModifierSentryRocket);
				}
			}
		}
		//	DP("%f",ChanceModifier[attacker]);
		//else it is true damage
		//PrintToChatAll("takedmg %f BULLET %d   lastiswarcraft %d",damage,isBulletDamage,g_CurDamageIsWarcraft);

		new bool:old_CanSetDamageMod=g_CanSetDamageMod;
		new bool:old_CanDealDamage=g_CanDealDamage;
		g_CanSetDamageMod=true;
		g_CanDealDamage=false;
		Call_StartForward(FHOnVSH_TakeDmgAllPre);
		Call_PushCell(victim);
		Call_PushCell(attacker);
		Call_PushCellRef(damage);
		Call_PushCell(damagecustom);
		Call_Finish(dummyresult); //this will be returned to

		g_CanSetDamageMod=false;
		g_CanDealDamage=true;

		if(g_CurDMGModifierPercent>0.001){ //so if damage is already canceled, no point in forwarding the second part , do we dont get: evaded but still recieve warcraft damage proc)

			Call_StartForward(FHOnVSH_TakeDmgAll);
			Call_PushCell(victim);
			Call_PushCell(attacker);
			Call_PushCellRef(damage);
			Call_Finish(dummyresult); //this will be returned to

		}
		g_CanSetDamageMod=old_CanSetDamageMod;
		g_CanDealDamage=old_CanDealDamage;

		//modify final damage
		//DP("Damage before modifier %f %d to %d",damage,attacker,victim);
		damage=damage*g_CurDMGModifierPercent; ////so we calculate the percent

		//nobobdy retrieves our global variables outside of the forward call, restore old stack vars
		g_CurDamageType= old_DamageType;
		g_CurInflictor= old_Inflictor;
		g_CurDMGModifierPercent = old_DamageModifierPercent;

		damagestack--;

		VictimCheck=victim;
		AttackerCheck=attacker;
		InflictorCheck=inflictor;
		DamageCheck=damage;
		DamageTypeCheck=damagetype;
		WeaponCheck=weapon;
		damageForceCheck[0]=damageForce[0];
		damageForceCheck[1]=damageForce[1];
		damageForceCheck[2]=damageForce[2];
		damagePositionCheck[0]=damagePosition[0];
		damagePositionCheck[1]=damagePosition[1];
		damagePositionCheck[2]=damagePosition[2];
		damagecustomCheck=damagecustom;

		//#if defined DEBUG

		//DP2("sdktakedamage %d->%d END dmg [%.2f]",attacker,victim,damage);
		//#endif
	}

	return Plugin_Changed;
}

public OnTakeDamagePostHook(victim, attacker, inflictor, Float:damage, damagetype, weapon, const Float:damageForce[3], const Float:damagePosition[3])
{
		// GHOSTS!!
		if (weapon == -1 && inflictor == -1)
		{
				//VSH_LogError("OnTakeDamagePostHook: Who was pho^H^H^Hweapon?");
				return;
		}

		//Block uber hits (no actual damage)
		if(VSH_IsUbered(victim))
		{
				//DP("ubered but SDK OnTakeDamagePostHook called, damage %f",damage);
				return;
		}

		damagestack++;

		new bool:old_CanDealDamage=g_CanDealDamage;
		g_CanSetDamageMod=true;

		g_CurInflictor = inflictor;

		// sbsource 2.0 uses this:
		//Figure out what really hit us. A weapon? A sentry gun?
		new String:weaponName[64];
		new realWeapon = weapon == -1 ? inflictor : weapon;
		GetEntityClassname(realWeapon, weaponName, sizeof(weaponName));

		//VSH_LogInfo("OnTakeDamagePostHook called with weapon \"%s\"", weaponName);

		Call_StartForward(g_OnVSHEventPostHurtFH);
		Call_PushCell(victim);
		Call_PushCell(attacker);
		Call_PushCell(RoundToFloor(damage));
		Call_PushString(weaponName);
		Call_Finish(dummyreturn);

		g_CanDealDamage=old_CanDealDamage;

		damagestack--;

		g_CurLastActualDamageDealt = RoundToFloor(damage);
}
