// SaxtonHale_GlobalVars.sp

/* see saxtonhale.inc
 *
enum VSHVar
{
	EventArg1, //generic event arguments
	EventArg2,
	EventArg3,
	EventArg4,

	TransClient,//who to translate

	SmEvent, ///usual game events from sm hooked events
}
*/

public bool:SaxtonHale_GlobalVars_InitNatives()
{
	CreateNative("VSHGetVar",NVSHGetVar);
	CreateNative("VSHSetVar",NVSHSetVar);
	return true;
}


public NVSHGetVar(Handle:plugin,numParams){
	return _:VSHVarArr[VSHVar:GetNativeCell(1)];
}
public NVSHSetVar(Handle:plugin,numParams){
	VSHVarArr[VSHVar:GetNativeCell(1)]=GetNativeCell(2);
}

