#if !defined _ASSET_hs_sys_
	#define _ASSET_hs_sys_
#endif
//#define FILTERSCRIPT
#define __ENABLE__DEBUGGING__

#if !defined _samp_included
	#include "a_samp"
#endif
#if !defined _INC_y_bit
	#tryinclude "YSI_Data\y_bit"
#endif
#if !defined _INC_y_hooks
	#tryinclude "YSI_Coding\y_hooks"
#endif

#if defined _INC_y_bit
	static BitArray:__PlayerBeingHeadshotted<MAX_PLAYERS>,
#else
	static bool:__PlayerBeingHeadshotted[MAX_PLAYERS] = {false, ...},
#endif
	__HeadshottingWho[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...},
	__name[MAX_PLAYERS][MAX_PLAYER_NAME+1];

#if !defined FILTERSCRIPT
	main()
	#else
	public OnFilterScriptInit()
#endif
{
	print("|==================================================|");
	print("Headshot System by: Connoisseur");
	print("|==================================================|");
	#if defined FILTERSCRIPT
		return 1;
	#endif
}

static __ResetVariables(playerid)
{
	__HeadshottingWho[ __HeadshottingWho[playerid] ] = INVALID_PLAYER_ID;
	__HeadshottingWho[playerid] = INVALID_PLAYER_ID;
	#if defined _INC_y_bit
		Bit_Vet(__PlayerBeingHeadshotted, playerid);
	#else
		__PlayerBeingHeadshotted[playerid] = false;
	#endif

	#if defined __ENABLE__DEBUGGING__
		printf("[HEADSHOT-LOG] Resetting variables for %s.", __name[playerid]);
	#endif
}
#if defined _INC_y_hooks
	hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
#else
	public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
#endif
{
	if(damagedid != INVALID_PLAYER_ID || playerid != INVALID_PLAYER_ID)
	{
		if(bodypart == 9 && weaponid == WEAPON_SNIPER)
		{
			__HeadshottingWho[playerid] = damagedid;
			__HeadshottingWho[damagedid] = playerid;

			#if defined _INC_y_bit
				if(!Bit_Get(__PlayerBeingHeadshotted, playerid)) Bit_Let(__PlayerBeingHeadshotted, damagedid);
			#else
				if(!__PlayerBeingHeadshotted[playerid]) __PlayerBeingHeadshotted[damagedid] = true;
			#endif

			#if defined __ENABLE__DEBUGGING__
				printf("[HEADSHOT-LOG] %s is giving headshot damage to %s.", __name[playerid], __name[damagedid]);
			#endif
		}
	}
	#if !defined _INC_y_hooks
		return 1;
	#else
		return Y_HOOKS_CONTINUE_RETURN_1;
	#endif
}
#if !defined _INC_y_hooks
	#if defined _ALS_OnPlayerGiveDamage
	    #undef OnPlayerGiveDamage
	#else
	    #define _ALS_OnPlayerGiveDamage
	#endif
	#define OnPlayerGiveDamage Test_OnPlayerGiveDamage
	#if defined Test_OnPlayerGiveDamage
	    forward Test_OnPlayerGiveDamage(playerid);
	#endif
#endif

#if defined _INC_y_hooks
	hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
#else
	public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
#endif
{
	if(issuerid != INVALID_PLAYER_ID || playerid != INVALID_PLAYER_ID)
	{
		if(bodypart == 9 && weaponid == WEAPON_SNIPER)
		{
			#if defined _INC_y_bit
				if((__HeadshottingWho[playerid] == issuerid && __HeadshottingWho[issuerid] == playerid) && Bit_Get(__PlayerBeingHeadshotted, playerid))
			#else
				if((__HeadshottingWho[playerid] == issuerid && __HeadshottingWho[issuerid] == playerid) && __PlayerBeingHeadshotted[playerid]) 
			#endif
			{
				SetPlayerHealth(playerid, 0.0);
				GameTextForPlayer(playerid, "~r~You've been headhostted!", 8000, 1);
				__ResetVariables(playerid);
				#if defined __ENABLE__DEBUGGING__
					printf("[HEADSHOT-LOG] %s has been headshotted by %s. (NOTE THAT VARIABLE RESET LOG SHOULD BE DISPLAYED FIRST)", __name[playerid], __name[issuerid]);
				#endif
			}	
		}
	}
	#if !defined _INC_y_hooks
		return 1;
	#else
		return Y_HOOKS_CONTINUE_RETURN_1;
	#endif
}
#if !defined _INC_y_hooks
	#if defined _ALS_OnPlayerTakeDamage
	    #undef OnPlayerTakeDamage
	#else
	    #define _ALS_OnPlayerTakeDamage
	#endif
	#define OnPlayerTakeDamage Test_OnPlayerTakeDamage
	#if defined Test_OnPlayerTakeDamage
	    forward Test_OnPlayerTakeDamage(playerid);
	#endif
#endif

#if defined _INC_y_hooks
	hook OnPlayerConnect(playerid)
#else
	public OnPlayerConnect(playerid)
#endif
{
	GetPlayerName(playerid, __name[playerid], MAX_PLAYER_NAME+1);
	#if !defined _INC_y_hooks
		return 1;
	#else
		return Y_HOOKS_CONTINUE_RETURN_1;
	#endif
}
#if !defined _INC_y_hooks
	#if defined _ALS_OnPlayerConnect
	    #undef OnPlayerConnect
	#else
	    #define _ALS_OnPlayerConnect
	#endif
	#define OnPlayerConnect Test_OnPlayerConnect
	#if defined Test_OnPlayerConnect
	    forward Test_OnPlayerConnect(playerid);
	#endif
#endif

#if defined _INC_y_hooks
	hook OnPlayerDisconnect(playerid, reason)
#else
	public OnPlayerDisconnect(playerid, reason)
#endif
{
	__ResetVariables(playerid);
	__name[playerid][0] = EOS;
	#if !defined _INC_y_hooks
		return 1;
	#else
		return Y_HOOKS_CONTINUE_RETURN_1;
	#endif
}
#if !defined _INC_y_hooks
	#if defined _ALS_OnPlayerDisconnect
	    #undef OnPlayerDisconnect
	#else
	    #define _ALS_OnPlayerDisconnect
	#endif
	#define OnPlayerDisconnect Test_OnPlayerDisconnect
	#if defined Test_OnPlayerDisconnect
	    forward Test_OnPlayerDisconnect(playerid);
	#endif
#endif
