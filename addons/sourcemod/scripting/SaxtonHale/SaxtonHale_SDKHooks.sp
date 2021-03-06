
public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	//PrintToChatAll("OnTakeDamage client %d attacker %d inflictor %d damagetype %d",client,attacker,inflictor,damagetype);

	if (!Enabled || !IsValidEdict(attacker) || ((attacker <= 0) && (client == Hale)) || TF2_IsPlayerInCondition(client, TFCond_Ubercharged))
		return Plugin_Continue;
	if (VSHRoundState == ROUNDSTATE_EVENT_ROUND_START && (client == Hale || (client != attacker && attacker != Hale)))
	{
		damage *= 0.0;
		return Plugin_Changed;
	}
	decl Float:Pos[3];
	GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", Pos);
	if ((attacker == Hale) && IsValidClient(client) && (client != Hale) && !TF2_IsPlayerInCondition(client, TFCond_Bonked) && !TF2_IsPlayerInCondition(client, TFCond_Ubercharged))
	{
		if (TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed))
		{
			ScaleVector(damageForce, 9.0);
			damage *= 0.3;
			return Plugin_Changed;
		}
		if (TF2_IsPlayerInCondition(client, TFCond_DefenseBuffMmmph))
		{
			damage *= 9;
			TF2_AddCondition(client, TFCond_Bonked, 0.1);
			return Plugin_Changed;
		}
		if (TF2_IsPlayerInCondition(client, TFCond_CritMmmph))
		{
			damage *= 0.25;

			return Plugin_Changed;
		}
		new ent = -1;
		while ((ent = FindEntityByClassname2(ent, "tf_wearable_demoshield")) != -1)
		{
			if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(ent, Prop_Send, "m_bDisguiseWearable"))
			{
				//AcceptEntityInput(ent, "Kill");
				TF2_RemoveWearable(client, ent);
				EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, Pos, NULL_VECTOR, false, 0.0);
				EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, Pos, NULL_VECTOR, false, 0.0);
				EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, Pos, NULL_VECTOR, false, 0.0);
				EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, Pos, NULL_VECTOR, false, 0.0);
				TF2_AddCondition(client, TFCond_Bonked, 0.1);
				return Plugin_Continue;
			}
		}
		if (TF2_GetPlayerClass(client) == TFClass_Spy)  //eggs probably do melee damage to spies, then? That's not ideal, but eh.
		{
			if (GetEntProp(client, Prop_Send, "m_bFeignDeathReady") && !TF2_IsPlayerInCondition(client, TFCond_Cloaked))
			{
				if (damagetype & DMG_CRIT) damagetype &= ~DMG_CRIT;
				damage = 620.0;
				return Plugin_Changed;
			}
			if (TF2_IsPlayerInCondition(client, TFCond_Cloaked) && TF2_IsPlayerInCondition(client, TFCond_DeadRingered))
			{
				if (damagetype & DMG_CRIT) damagetype &= ~DMG_CRIT;
				damage = 850.0;
				return Plugin_Changed;
			}
			if (TF2_IsPlayerInCondition(client, TFCond_Cloaked) && TF2_IsPlayerInCondition(client, TFCond_DeadRingered))
			{
				if (damagetype & DMG_CRIT) damagetype &= ~DMG_CRIT;
				damage = 850.0;
				return Plugin_Changed;
			}

//          return Plugin_Changed;
		}
		new buffweapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		new buffindex = (IsValidEntity(buffweapon) && buffweapon > MaxClients ? GetEntProp(buffweapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
		if (buffindex == 226)
		{
			CreateTimer(0.25, Timer_CheckBuffRage, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
		if (damage <= 160.0
		&& !(Special == VSHSpecial_CBS && inflictor != attacker)
		&& (Special != VSHSpecial_Bunny || weapon == -1 || weapon == GetPlayerWeaponSlot(Hale, TFWeaponSlot_Melee))
		&& (Special != VSHSpecial_Miku))
		{
			damage *= 3;
			return Plugin_Changed;
		}
	}
	else if (attacker != Hale && client == Hale)
	{
		if (attacker <= MaxClients)
		{
			new wepindex = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
			if (inflictor == attacker || inflictor == weapon)
			{
				new iFlags = GetEntityFlags(Hale);
				new bChanged = false;

#if defined _tf2attributes_included
				if (!(damagetype & DMG_BLAST) && (iFlags & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING))    //If Hale is ducking on the ground, it's harder to knock him back
				{
					TF2Attrib_SetByName(Hale, "damage force reduction", 0.0);
					//damagetype |= DMG_PREVENT_PHYSICS_FORCE;
					bChanged = true;
				}
				else
				{
					TF2Attrib_RemoveByName(Hale, "damage force reduction");
				}
#else
				// Does not protect against sentries or FaN, but does against miniguns and rockets
				if ((iFlags & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING))
				{
					damagetype |= DMG_PREVENT_PHYSICS_FORCE;
					bChanged = true;
				}
#endif

				if (damagecustom == TF_CUSTOM_BOOTS_STOMP)
				{
					damage = 1024.0;

					return Plugin_Changed;
				}
				if (damagecustom == TF_CUSTOM_TELEFRAG) //if (!IsValidEntity(weapon) && (damagetype & DMG_CRUSH) == DMG_CRUSH && damage == 1000.0)    //THIS IS A TELEFRAG
				{
					if (!IsPlayerAlive(attacker))
					{
						damage = 1.0;
						return Plugin_Changed;
					}

					damage = 9001.0; //(HaleHealth > 9001 ? 15.0:float(GetEntProp(Hale, Prop_Send, "m_iHealth")) + 90.0);

					new teleowner = FindTeleOwner(attacker);

					if (IsValidClient(teleowner) && teleowner != attacker)
					{
						Damage[teleowner] += 5401; //RoundFloat(9001.0 * 3 / 5);
						PrintCenterText(teleowner, "TELEFRAG ASSIST! Nice job setting up!");
					}

					PrintCenterText(attacker, "TELEFRAG! You are a pro.");
					PrintCenterText(client, "TELEFRAG! Be careful around quantum tunneling devices!");
					return Plugin_Changed;
				}
				switch (wepindex)
				{
					case 593:       //Third Degree
					{
						new healers[MAXPLAYERS];
						new healercount = 0;
						for (new i = 1; i <= MaxClients; i++)
						{
							if (IsValidClient(i) && IsPlayerAlive(i) && (GetHealingTarget(i) == attacker))
							{
								healers[healercount] = i;
								healercount++;
							}
						}
						for (new i = 0; i < healercount; i++)
						{
							if (IsValidClient(healers[i]) && IsPlayerAlive(healers[i]))
							{
								new medigun = GetPlayerWeaponSlot(healers[i], TFWeaponSlot_Secondary);
								if (IsValidEntity(medigun))
								{
									new String:s[64];
									GetEdictClassname(medigun, s, sizeof(s));
									if (strcmp(s, "tf_weapon_medigun", false) == 0)
									{
										new Float:uber = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel") + (0.1 / healercount);
										new Float:max = 1.0;
										if (GetEntProp(medigun, Prop_Send, "m_bChargeRelease")) max = 1.5;
										if (uber > max) uber = max;
										SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", uber);
									}
								}
							}
						}
					}
					case 14, 201, 230, 402, 526, 664, 752, 792, 801, 851, 881, 890, 899, 908, 957, 966, 1098:
					{
						switch (wepindex)   //cleaner to read than if wepindex == || wepindex == || etc
						{
							case 14, 201, 664, 792, 801, 851, 881, 890, 899, 908, 957, 966:
							{
								if (VSHRoundState != ROUNDSTATE_ROUND_END)
								{
									new Float:chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
									new Float:time = (GlowTimer > 10 ? 1.0 : 2.0);
									time += (GlowTimer > 10 ? (GlowTimer > 20 ? 1 : 2) : 4)*(chargelevel/100);
									SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
									GlowTimer += RoundToCeil(time);
									if (GlowTimer > 30.0) GlowTimer = 30.0;
								}
							}
						}
						if (wepindex == 752 && VSHRoundState != ROUNDSTATE_ROUND_END)
						{
							new Float:chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
							new Float:add = 10 + (chargelevel / 10);
							if (TF2_IsPlayerInCondition(attacker, TFCond:46)) add /= 3;
							new Float:rage = GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
							SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage + add > 100) ? 100.0 : rage + add);
						}
						if (!(damagetype & DMG_CRIT))
						{
							new bool:ministatus = (TF2_IsPlayerInCondition(attacker, TFCond_CritCola) || TF2_IsPlayerInCondition(attacker, TFCond_Buffed) || TF2_IsPlayerInCondition(attacker, TFCond_CritHype));

							damage *= (ministatus) ? 2.222222 : 3.0;

							if (wepindex == 230)
							{
								HaleRage -= RoundFloat(damage/2.0);
								if (HaleRage < 0) HaleRage = 0;
							}

							return Plugin_Changed;
						}
						else if (wepindex == 230)
						{
							HaleRage -= RoundFloat(damage*3.0/2.0);
							if (HaleRage < 0) HaleRage = 0;
						}
					}
					case 355:
					{
						new Float:rage = 0.05*RageDMG;
						HaleRage -= RoundToFloor(rage);
						if (HaleRage < 0)
							HaleRage = 0;
					}
					case 132, 266, 482, 1082: IncrementHeadCount(attacker);
					case 416:   // Chdata's Market Gardener backstab
					{
						if (GetRJFlag(attacker))
						{
							// Can't get stuck in HHH in midair and mg him multiple times.
							//if ((GetEntProp(client, Prop_Send, "m_iStunFlags") & TF_STUNFLAGS_GHOSTSCARE | TF_STUNFLAG_NOSOUNDOREFFECT) && Special == VSHSpecial_HHH) return Plugin_Continue;

							damage = (Pow(float(HaleHealthMax), (0.74074)) + 512.0 - (Marketed/128*float(HaleHealthMax)) )/3.0;    //divide by 3 because this is basedamage and lolcrits (0.714286)) + 1024.0)
							damagetype |= DMG_CRIT;

							if (Marketed < 5) Marketed++;

							PrintCenterText(attacker, "You market gardened him!");
							PrintCenterText(client, "You were just market gardened!");

							EmitSoundToClient(client, "player/doubledonk.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.6, 100, _, Pos, NULL_VECTOR, false, 0.0);
							EmitSoundToClient(attacker, "player/doubledonk.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.6, 100, _, Pos, NULL_VECTOR, false, 0.0);

							return Plugin_Changed;
						}
					}
					case 317: SpawnSmallHealthPackAt(client, GetClientTeam(attacker));
					case 214:
					{
						new health = GetClientHealth(attacker);
						new max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
						new newhealth = health+25;
						if (health < max+50)
						{
							if (newhealth > max+50) newhealth = max+50;
							SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
							//SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
						}
						if (TF2_IsPlayerInCondition(attacker, TFCond_OnFire)) TF2_RemoveCondition(attacker, TFCond_OnFire);
					}
					case 594: // Phlog
					{
						if (!TF2_IsPlayerInCondition(attacker, TFCond_CritMmmph))
						{
							damage /= 2.0;
							return Plugin_Changed;
						}
					}
					case 357:
					{
						SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
						if (GetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy") < 1)
							SetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
						new health = GetClientHealth(attacker);
						new max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
						new newhealth = health+35;
						if (health < max+25)
						{
							if (newhealth > max+25) newhealth = max+25;
							SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
							//SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
						}
						if (TF2_IsPlayerInCondition(attacker, TFCond_OnFire)) TF2_RemoveCondition(attacker, TFCond_OnFire);
					}
					case 61, 1006:  //Ambassador does 2.5x damage on headshot
					{
						if (damagecustom == TF_CUSTOM_HEADSHOT)
						{
							damage = 85.0;
							return Plugin_Changed;
						}
					}
					case 525, 595:
					{
						new iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");

						if (iCrits > 0) //If a revenge crit was used, give a damage bonus
						{
							damage = 85.0;
							return Plugin_Changed;
						}
					}
					/*case 528:
					{
						if (circuitStun > 0.0)
						{
							TF2_StunPlayer(client, circuitStun, 0.0, TF_STUNFLAGS_SMALLBONK|TF_STUNFLAG_NOSOUNDOREFFECT, attacker);
							EmitSoundToAll("weapons/barret_arm_zap.wav", client);
							EmitSoundToClient(client, "weapons/barret_arm_zap.wav");
						}
					}*/
					case 656:
					{
						CreateTimer(0.1, Timer_StopTickle, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
						if (TF2_IsPlayerInCondition(attacker, TFCond_Dazed)) TF2_RemoveCondition(attacker, TFCond_Dazed);
					}
				}
				//VoiDeD's Caber-backstab code. To be added with a few special modifications in 1.40+
				//Except maybe not because it's semi op.
/*              if ( IsValidEdict( weapon ) && GetEdictClassname( weapon, wepclassname, sizeof( wepclassname ) ) && strcmp( wepclassname, "tf_weapon_stickbomb", false ) == 0 )
				{
					// make caber do backstab damage on explosion

					new bool:isDetonated = GetEntProp( weapon, Prop_Send, "m_iDetonated" ) == 1;

					if ( !isDetonated )
					{
						new Float:changedamage = HaleHealthMax * 0.07;

						Damage[attacker] += RoundFloat(changedamage);

						damage = changedamage;

						HaleHealth -= RoundFloat(changedamage);
						HaleRage += RoundFloat(changedamage);

						if (HaleRage > RageDMG)
							HaleRage = RageDMG;
					}
				}*/
				static bool:foundDmgCustom = false;
				static bool:dmgCustomInOTD = false;
				if (!foundDmgCustom)
				{
					dmgCustomInOTD = (GetFeatureStatus(FeatureType_Capability, "SDKHook_DmgCustomInOTD") == FeatureStatus_Available);
					foundDmgCustom = true;
				}
				new bool:bIsBackstab = false;
				if (dmgCustomInOTD) // new way to check backstabs
				{
					if (damagecustom == TF_CUSTOM_BACKSTAB)
					{
						bIsBackstab = true;
					}
				}
				else if (weapon != 4095 && IsValidEdict(weapon) && weapon == GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee) && damage > 1000.0)  //lousy way of checking backstabs
				{
					decl String:wepclassname[32];
					if (GetEdictClassname(weapon, wepclassname, sizeof(wepclassname)) && strcmp(wepclassname, "tf_weapon_knife", false) == 0)   //more robust knife check
					{
						bIsBackstab = true;
					}
				}
				if (bIsBackstab)
				{
					/*
					 Rebalanced backstab formula.
					 By: Chdata

					 Stronger against low HP Hale.
					 Weaker against high HP Hale (but still good).

					*/
					new Float:changedamage = ( (Pow(float(HaleHealthMax)*0.0014, 2.0) + 899.0) - (float(HaleHealthMax)*(Stabbed/100)) );
					//new iChangeDamage = RoundFloat(changedamage);

					damage = changedamage/3;            // You can level "damage dealt" with backstabs
					damagetype |= DMG_CRIT;

					/*Damage[attacker] += iChangeDamage;
					if (HaleHealth > iChangeDamage) damage = 0.0;
					else damage = changedamage;
					HaleHealth -= iChangeDamage;
					HaleRage += iChangeDamage;
					if (HaleRage > RageDMG)
						HaleRage = RageDMG;*/
					EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, Pos, NULL_VECTOR, false, 0.0);
					EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, Pos, NULL_VECTOR, false, 0.0);
					EmitSoundToClient(client, "player/crit_received3.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, _, NULL_VECTOR, false, 0.0);
					EmitSoundToClient(attacker, "player/crit_received3.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 0.7, 100, _, _, NULL_VECTOR, false, 0.0);
					SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 2.0);
					SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime() + 2.0);
					SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", GetGameTime() + 2.0);
					new vm = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
					if (vm > MaxClients && IsValidEntity(vm) && TF2_GetPlayerClass(attacker) == TFClass_Spy)
					{
						new melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
						new anim = 15;
						switch (melee)
						{
							case 727: anim = 41;
							case 4, 194, 665, 794, 803, 883, 892, 901, 910: anim = 10;
							case 638: anim = 31;
						}
						SetEntProp(vm, Prop_Send, "m_nSequence", anim);
					}
					PrintCenterText(attacker, "You backstabbed him!");
					PrintCenterText(client, "You were just backstabbed!");
					/*new Handle:stabevent = CreateEvent("player_hurt", true);
					SetEventInt(stabevent, "userid", GetClientUserId(client));
					SetEventInt(stabevent, "health", HaleHealth);
					SetEventInt(stabevent, "attacker", GetClientUserId(attacker));
					SetEventInt(stabevent, "damageamount", iChangeDamage);
					SetEventInt(stabevent, "custom", TF_CUSTOM_BACKSTAB);
					SetEventBool(stabevent, "crit", true);
					SetEventBool(stabevent, "minicrit", false);
					SetEventBool(stabevent, "allseecrit", true);
					SetEventInt(stabevent, "weaponid", TF_WEAPON_KNIFE);
					FireEvent(stabevent);*/
					new pistol = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary);

					if (pistol == 525) //Diamondback gives 3 crits on backstab
					{
						new iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
						SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", iCrits+2);
					}

					/*if (wepindex == 225 || wepindex == 574)
					{
						CreateTimer(0.3, Timer_DisguiseBackstab, GetClientUserId(attacker));
					}*/

					if (wepindex == 356)
					{
						new health = GetClientHealth(attacker) + 180;

						if (health > 270) health = 270;

						SetEntProp(attacker, Prop_Data, "m_iHealth", health);
						//SetEntProp(attacker, Prop_Send, "m_iHealth", health);
					}
					if (wepindex == 461)    //Big Earner gives full cloak on backstab
					{
						SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", 100.0);
					}
					decl String:s[PLATFORM_MAX_PATH];
					switch (Special)
					{
						case VSHSpecial_Hale:
						{
							Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleStubbed132, GetRandomInt(1, 4));
							EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
							EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
						}
						case VSHSpecial_Vagineer:
						{
							EmitSoundToAll("vo/engineer_positivevocalization01.wav", _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
							EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, "vo/engineer_positivevocalization01.wav", _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
						}
						case VSHSpecial_HHH:
						{
							Format(s, PLATFORM_MAX_PATH, "vo/halloween_boss/knight_pain0%d.wav", GetRandomInt(1, 3));
							EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
							EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
						}
						case VSHSpecial_Bunny:
						{
							strcopy(s, PLATFORM_MAX_PATH, BunnyPain[GetRandomInt(0, sizeof(BunnyPain)-1)]);
							EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
							EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
						}
#if defined MIKU_ON
						case VSHSpecial_Miku:
						{
							strcopy(s, PLATFORM_MAX_PATH, MikuPain[GetRandomInt(0, sizeof(MikuPain)-1)]);
							EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
							EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
						}
#endif
					}
					if (Stabbed < 4)
						Stabbed++;
					/*new healers[MAXPLAYERS]; // Medic assist unnecessary due to being handled in player_hurt now.
					new healercount = 0;
					for (new i = 1; i <= MaxClients; i++)
					{
						if (IsValidClient(i) && IsPlayerAlive(i) && (GetHealingTarget(i) == attacker))
						{
							healers[healercount] = i;
							healercount++;
						}
					}
					for (new i = 0; i < healercount; i++)
					{
						if (IsValidClient(healers[i]) && IsPlayerAlive(healers[i]))
						{
							if (uberTarget[healers[i]] == attacker)
								Damage[healers[i]] += iChangeDamage;
							else
								Damage[healers[i]] += RoundFloat(changedamage/(healercount+1));
						}
					}*/
					return Plugin_Changed;
				}

				if (bChanged)
				{
					return Plugin_Changed;
				}
			}
			if (TF2_GetPlayerClass(attacker) == TFClass_Scout)
			{
				if (wepindex == 45 || ((wepindex == 209 || wepindex == 294 || wepindex == 23 || wepindex == 160 || wepindex == 449) && (TF2_IsPlayerCritBuffed(client) || TF2_IsPlayerInCondition(client, TFCond_CritCola) || TF2_IsPlayerInCondition(client, TFCond_Buffed) || TF2_IsPlayerInCondition(client, TFCond_CritHype))))
				{
					ScaleVector(damageForce, 0.38);
					return Plugin_Changed;
				}
			}
		}
		else
		{
			decl String:s[64];
			if (GetEdictClassname(attacker, s, sizeof(s)) && strcmp(s, "trigger_hurt", false) == 0) // && damage >= 250)
			{
				if (bSpawnTeleOnTriggerHurt)
				{
					// Teleport the boss back to one of the spawns.
					// And during the first 30 seconds, he can only teleport to his own spawn.
					TeleportToSpawn(Hale, (bTenSecStart[1]) ? HaleTeam : 0);
				}
				else if (damage >= 250.0)
				{
					if (HaleCharge >= 0)
					{
						bEnableSuperDuperJump = true;
					}
					else if (Special == VSHSpecial_HHH)
					{
						TeleportToSpawn(Hale, (bTenSecStart[1]) ? HaleTeam : 0);
					}
				}

				new Float:flMaxDmg = float(HaleHealthMax) * 0.05;
				if (flMaxDmg > 500.0)
				{
					flMaxDmg = 500.0;
				}

				if (damage > flMaxDmg)
				{
					damage = flMaxDmg;
				}
				HaleHealth -= RoundFloat(damage);
				HaleRage += RoundFloat(damage);
				if (HaleHealth <= 0) damage *= 5;
				if (HaleRage > RageDMG)
					HaleRage = RageDMG;
				return Plugin_Changed;
			}
		}
	}
	else if (attacker == 0 && client != Hale && IsValidClient(client, false) && (damagetype & DMG_FALL) && (TF2_GetPlayerClass(client) == TFClass_Soldier || TF2_GetPlayerClass(client) == TFClass_DemoMan))
	{
		new item = GetPlayerWeaponSlot(client, (TF2_GetPlayerClass(client) == TFClass_DemoMan ? TFWeaponSlot_Primary:TFWeaponSlot_Secondary));

		if (item <= 0 || !IsValidEntity(item))
		{
			damage /= 10.0;

			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}


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
/*
public Action:SDK_Forwarded_TraceAttack(victim, &attacker, &inflictor, &Float:damage, &damagetype, &ammotype, hitbox, hitgroup)
{
	PrintToChatAll("SDK_Forwarded_TraceAttack victim %d attacker %d inflictor %d damagetype %d",attacker,attacker,inflictor,damagetype);
	if(IsValidClient(attacker) || IsValidClient(inflictor))
	{
		PrintToChatAll("attacker %d",attacker);
		PrintToChatAll("victim %d",victim);
		PrintToChatAll("inflictor %d",inflictor);
		PrintToChatAll("damagetype %d",damagetype);
		PrintToChatAll("hitbox %d",hitbox);
		PrintToChatAll("hitgroup %d",hitgroup);
		if (TF2_GetPlayerClass(attacker) == TFClass_Spy)
		{
			PrintToChatAll("TFClass_Spy");
			new String:spyweapon[64];
			PrintToChatAll("IsValidClient(attacker)");
			GetClientWeapon( attacker, spyweapon , 64);
			if(StrEqual(spyweapon, "tf_weapon_knife") && (damagetype==135270528||damagetype==134221952))
			{
				PrintToChatAll("damage before %.2f",damage);
				PrintToChatAll("tf_weapon_knife");
				damage = FloatMul(float(GetClientHealth(victim)),0.05);
				PrintToChatAll("damage after %.2f",damage);
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}
*/
