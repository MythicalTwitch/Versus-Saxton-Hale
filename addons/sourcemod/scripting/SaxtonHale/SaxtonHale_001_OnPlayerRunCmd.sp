// SaxtonHale_001_OnPlayerRunCmd.sp
/*
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (Enabled && client == Hale)
	{
		if (Special == VSHSpecial_HHH)
		{
			if (VSHFlags[client] & VSHFLAG_NEEDSTODUCK)
			{
				buttons |= IN_DUCK;
			}
			if (HaleCharge >= 47 && (buttons & IN_ATTACK))
			{
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
		else if (Special == VSHSpecial_Bunny)
		{
			if (GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
			{
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
#if defined MIKU_ON
		else if (Special == VSHSpecial_Miku && VSHSpecial_Miku_Rage && client!= Hale)
		{
			if(ValidPlayer(client,true) && Hale>0){
				new Float:slaveVecs[3];
				new Float:masterVecs[3];
				new Float:chainDistance;
				new masterID=Hale;
				GetClientAbsOrigin(client,slaveVecs);
				if(ValidPlayer(masterID,true)){
					GetClientAbsOrigin(masterID,masterVecs);
				}else{
					//If Hale is no logner alive, stop rage
					VSHSpecial_Miku_Rage=false;
					return Plugin_Continue;
				}

				chainDistance = GetVectorDistance(slaveVecs,masterVecs);
				//Look at Master.//////////////////////////////////////////
				//DP("%i",masterID);
				//masterVecs[2]+=40;
				if(masterID>0 && IsPlayerAlive(masterID)){
					new Float:angleVecs[3];
					new Float:angleToMaster[3];

					SubtractVectors(slaveVecs,masterVecs,angleVecs);
					GetVectorAngles(angleVecs,angleToMaster);

					angleToMaster[1]+=angleOffset[client];
					if(angleToMaster[1] >0){
						angleToMaster[1]= -(180-angleToMaster[1]);
					}else{
						angleToMaster[1]= (180+angleToMaster[1]);
					}
					if(angleToMaster[0] >180){
						angleToMaster[0]-=360;
					}
					angleToMaster[0]=-angleToMaster[0];
					angles=angleToMaster;
				}

				TeleportEntity(client,NULL_VECTOR,angles,NULL_VECTOR);
				////////////////////////////////////////////////////////////
				//DP("%f",chainDistance);
				//DP("%i",enemyID[client]);
				if(ValidPlayer(masterID,true)){
					if(chainDistance >300.0){
						//Too Far away; Cant see master. Teleport to master.
						if(!LOS(client,masterID)){
							TeleportEntity(client,masterVecs,NULL_VECTOR,NULL_VECTOR);
						}
					}
					if(chainDistance >=150.0){
						//If can't see, attempt to move around to get there.
						if(!LOS(client,masterID) && !LOS(masterID,client)){
							if(angleOffset[client]<180.0 && angleOffset[client]>=0.0){
								angleOffset[client]+=1.0;
							}else{
								if(angleOffset[client]==180.0){
									angleOffset[client]=-1.0;
								}
								angleOffset[client]-=1.0;
							}
							//DP("%f",angleOffset[client]);
						}else{
							angleOffset[client]=0.0;
						}
						//Close but getting too far; Run.
						//SetEntDataFloat(client,FindSendPropOffs("CTFPlayer","m_flMaxspeed"),50.0,true);
						vel = moveForward(vel,chainDistance);
						//DP("%f",myMaxSpeed[client]);
					}
					if(chainDistance >=50.0){
						if(GetClientButtons(masterID) & IN_JUMP){
							buttons |= IN_JUMP;
						}
					}
					if(chainDistance <125.0){
						vel = moveBackwards(vel,chainDistance);
						angleOffset[client]=0.0;
					}
				}
			}
		}
#endif
	}
	return Plugin_Continue;
}
*/
