#include "Scripts/DayZGame.h"
#include "Scripts/DayZGame.c"

#include "Scripts/Custom/DataBase.h"
#include "Scripts/Custom/DataBase.c"


CGame CreateGame()
{
	DbCreateDir();
	Print("CreateGame()");
	g_Game = new DayZGame;
	return g_Game;
}
