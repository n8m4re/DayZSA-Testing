#include "Scripts/DayZGame.h"
#include "Scripts/DayZGame.c"

#include "Scripts/DataBase.h"
#include "Scripts/DataBase.c"


CGame CreateGame()
{
	
	createDir();
	Print("CreateGame()");
	g_Game = new DayZGame;
	return g_Game;
}
