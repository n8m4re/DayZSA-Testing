#include "Scripts/DayZGame.h"
#include "Scripts/DayZGame.c"

#include "Scripts/DataBase/DataBase.h"
#include "Scripts/DataBase/DataBase.c"

CGame CreateGame()
{

	DataBase.CreateDir();
	Print("CreateGame()");
	g_Game = new DayZGame;
	return g_Game;
}
