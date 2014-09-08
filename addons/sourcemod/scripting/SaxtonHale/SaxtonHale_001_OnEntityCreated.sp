// SaxtonHale_001_OnEntityCreated.sp

public OnEntityCreated(entity, const String:classname[])
{
	if (Enabled && VSHRoundState == ROUNDSTATE_START_ROUND_TIMER && strcmp(classname, "tf_projectile_pipe", false) == 0)
		SDKHook(entity, SDKHook_SpawnPost, OnEggBombSpawned);

	DamageSystem_OnEntityCreated(entity, classname);
}
