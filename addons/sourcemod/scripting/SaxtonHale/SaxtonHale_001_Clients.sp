// War3Source_000_Clients.sp

public bool:OnClientConnect(client,String:rejectmsg[], maxlen)
{
	new bool:Return_OnClientConnect=true;

	//Return_OnClientConnect = War3Source_Engine_Statistics_OnClientConnect();

	return Return_OnClientConnect;
}

public OnClientConnected(client)
{
	//War3Source_Engine_ItemDatabase3_OnClientConnected(client);

}

public OnClientPutInServer(client)
{
	SaxtonHale_DamageSystem_OnClientPutInServer(client);
}

public OnClientDisconnect(client)
{
	SaxtonHale_DamageSystem_OnClientDisconnect(client);
}

public OnClientDisconnect_Post(client)
{
	//War3Source_Engine_Download_Control_OnClientDisconnect_Post(client);
}

//public OnClientPostAdminCheck(client)
//{
//}
