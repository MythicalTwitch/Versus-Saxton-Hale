public EquipSaxton(client)
{
	bEnableSuperDuperJump = false;
	new SaxtonWeapon;
	TF2_RemoveAllWeapons2(client);
	HaleCharge = 0;

	Call_StartForward(OnSetEquipment);
	Call_PushCell(Hale);
	Call_PushCell(HaleRaceID);
	Call_Finish();

	/*
	switch (Special)
	{
#if defined MIKU_ON
		case VSHSpecial_Miku:
		{
			// The Saxy
			SaxtonWeapon = SpawnWeapon(client, "tf_weapon_fists", 423, 100, 5, "68 ; 2.0 ; 2 ; 3.0 ; 259 ; 1.0 ; 326 ; 1.3 ; 252 ; 0.6");
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
		}
#endif
		case VSHSpecial_Bunny:
		{
			SaxtonWeapon = SpawnWeapon(client, "tf_weapon_bottle", 1, 100, 5, "68 ; 2.0 ; 2 ; 3.0 ; 259 ; 1.0 ; 326 ; 1.3 ; 252 ; 0.6");
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
		}
		case VSHSpecial_Vagineer:
		{
			SaxtonWeapon = SpawnWeapon(client, "tf_weapon_wrench", 197, 100, 5, "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 436 ; 1.0");
			SetEntProp(SaxtonWeapon, Prop_Send, "m_iWorldModelIndex", -1);
			SetEntProp(SaxtonWeapon, Prop_Send, "m_nModelIndexOverrides", -1, _, 0);
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
		}
		case VSHSpecial_HHH:
		{
			SaxtonWeapon = SpawnWeapon(client, "tf_weapon_sword", 266, 100, 5, "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 252 ; 0.6 ; 551 ; 1");
			SetEntProp(SaxtonWeapon, Prop_Send, "m_iWorldModelIndex", -1);
			SetEntProp(SaxtonWeapon, Prop_Send, "m_nModelIndexOverrides", -1, _, 0);
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
			HaleCharge = -1000;
		}
		case VSHSpecial_CBS:
		{
			SaxtonWeapon = SpawnWeapon(client, "tf_weapon_club", 171, 100, 5, "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0");
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
			SetEntProp(client, Prop_Send, "m_nBody", 0);
			SetEntProp(SaxtonWeapon, Prop_Send, "m_nModelIndexOverrides", GetEntProp(SaxtonWeapon, Prop_Send, "m_iWorldModelIndex"), _, 0);
		}
		default:
		{
			decl String:attribs[64];
			Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 252 ; 0.6 ; 214 ; %d", GetRandomInt(9999, 99999));
			SaxtonWeapon = SpawnWeapon(client, "tf_weapon_shovel", 5, 100, 4, attribs);
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
		}
	}*/
}

public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	if (!Enabled) return Plugin_Continue;
//  if (client == Hale) return Plugin_Continue;
//  if (hItem != INVALID_HANDLE) return Plugin_Continue;
	switch (iItemDefinitionIndex)
	{
		case 39, 351, 1081: //Megadetonator
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "25 ; 0.5 ; 207 ; 1.33 ; 144 ; 1.0 ; 58 ; 3.2", true);

			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;

				return Plugin_Changed;
			}
		}
		case 40:
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "165 ; 1.0");
			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 648:
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "279 ; 2.0");
			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 224: //Letranger
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "166 ; 15 ; 1 ; 0.8", true);

			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;

				return Plugin_Changed;
			}
		}
		case 225, 574: // YER
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "155 ; 1 ; 160 ; 1", true);

			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;

				return Plugin_Changed;
			}
		}
		case 232, 401: // Bushwacka + Shahanshah
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "236 ; 1");

			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;

				return Plugin_Changed;
			}
		}
		case 356: // Kunai
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "125 ; -60");

			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;

				return Plugin_Changed;
			}
		}
		case 444: // Mantreads
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "58 ; 1.8");
			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 405, 608: // Demo boots have falling stomp damage
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "259 ; 1 ; 252 ; 0.25");

			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;

				return Plugin_Changed;
			}
		}
		case 220:
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "328 ; 1.0", true);
			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 226: // The Battalion's Backup
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "252 ; 0.25"); //125 ; -10

			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;

				return Plugin_Changed;
			}
		}
		case 305, 1079: // Medic Xbow
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "17 ; 0.15 ; 2 ; 1.45"); // ; 266 ; 1.0");
			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 56, 1005, 1092: // Huntsman
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "2 ; 1.5 ; 76 ; 2.0");
			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 38, 457: // Axetinguisher
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "", true);
			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
//      case 132, 266, 482:
//      {
//          new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "202 ; 0.5 ; 125 ; -15", true);
//          if (hItemOverride != INVALID_HANDLE)
//          {
//              hItem = hItemOverride;
//              return Plugin_Changed;
//          }
//      }
		case 43, 239, 1100, 1084: // GRU
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, 239, "107 ; 1.5 ; 1 ; 0.5 ; 128 ; 1 ; 191 ; -7", true);
			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 415:
		{
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "179 ; 1 ; 265 ; 99999.0 ; 178 ; 0.6 ; 2 ; 1.1 ; 3 ; 0.5", true);

			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;

				return Plugin_Changed;
			}
		}
//      case 526:
	}
	if (TF2_GetPlayerClass(client) == TFClass_Soldier && (strncmp(classname, "tf_weapon_rocketlauncher", 24, false) == 0 || strncmp(classname, "tf_weapon_shotgun", 17, false) == 0))
	{
		new Handle:hItemOverride;
		if (iItemDefinitionIndex == 127) hItemOverride = PrepareItemHandle(hItem, _, _, "265 ; 99999.0 ; 179 ; 1.0");
		else hItemOverride = PrepareItemHandle(hItem, _, _, "265 ; 99999.0");
		if (hItemOverride != INVALID_HANDLE)
		{
			hItem = hItemOverride;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}
