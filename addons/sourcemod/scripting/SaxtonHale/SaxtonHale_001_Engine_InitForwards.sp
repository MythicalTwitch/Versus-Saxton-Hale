// War3Source_000_Engine_InitForwards.sp

//=============================================================================
// War3Source_InitForwards
//=============================================================================
public bool:SaxtonHale_InitForwards()
{
	new bool:Return_InitForwards=false;

	OnSpecialSelection = CreateGlobalForward("VSH_OnSpecialSelection", ET_Hook, Param_CellByRef);
	OnHaleCreated = CreateGlobalForward("VSH_OnHaleCreated", ET_Ignore, Param_Cell);
	OnHaleJump = CreateGlobalForward("VSH_OnDoJump", ET_Hook, Param_CellByRef);
	OnHaleRage = CreateGlobalForward("VSH_OnDoRage", ET_Hook, Param_FloatByRef);
	OnHaleWeighdown = CreateGlobalForward("VSH_OnDoWeighdown", ET_Hook);
	OnMusic = CreateGlobalForward("VSH_OnMusic", ET_Hook, Param_String, Param_FloatByRef);

	Return_InitForwards = CommandHook_InitForwards();

	Return_InitForwards = DamageSystem_InitForwards();

	//Return_InitForwards =

	//Return_InitForwards =

	return Return_InitForwards;
}