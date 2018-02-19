#include "MPMissions/dayz_Auto.ChernarusPlus/enScripts/DataBase.c"

void main()
{

	if (g_Game.IsMultiplayer() && g_Game.IsServer())
	{
		GetGame().ExecuteSQF( "call compile preprocessFileLineNumbers \"sqfScripts\\init.sqf\"" );
		
		DB_BASE_DIR = "$profile:PlayerStorage";
		
		new DataBase;
	}
	
}