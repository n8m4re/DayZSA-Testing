//Christmas tree spawning
_treePositions = [[7898.91,12574.3],
				//Novo
				[11618.6,14663.1],
				//Cherno 
				[6806.4,2460.3],
				//Electro
				[10499.2,2346.98],
				//Berezino 
				[12829.25,10114.4],
				//Zeleno
				[2745.44,5282.13],
				//Nov.Petrovka
				[3453.25,13050.1],
				//Svetlo
				[13932.719,13227.167],
				//nov.sobor
				[7036.0,7673.4],
				//cherPolana
				[12139.9,13827.4]
				];

{
	_tree = "ChristmasTree" createVehicle _x;
	_tree setPos [ (getPos _tree) select 0, (getPos _tree) select 1, -2.3];

} forEach _treePositions;
