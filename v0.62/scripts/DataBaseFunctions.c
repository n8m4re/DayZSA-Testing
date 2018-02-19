
string DB_BASE_DIR			= "$profile:PlayerStorage";

const string DB_ALIVE_DIR	= "\\alive\\";

const string DB_DEAD_DIR	=  "\\dead\\";

const string DB_FILENAME	= "$FILENAME$";
	 
void DataBaseDelete(string in1, string in2)
{
	string player_alive, player_dead, file_name;

	MakeDirectory(DB_BASE_DIR + DB_DEAD_DIR + in2);

	file_name = DB_FILENAME;

	file_name.Replace(file_name, in1);

	player_alive = DB_BASE_DIR + DB_ALIVE_DIR + in2 + "\\" + file_name;

	player_dead = DB_BASE_DIR + DB_DEAD_DIR + in2 + "\\" + file_name;

	FileHandle file = OpenFile(player_alive, FileMode.READ);

	if (file != 0)  {   
		CloseFile(file);
		CopyFile(player_alive, player_dead); 	
		DeleteFile(player_alive);
	} 
}


void DataBaseWrite(string in1, string in2, string in3)
{	
	string player_alive, file_name;

	file_name = DB_FILENAME;

	file_name.Replace(file_name, in1);

	player_alive = DB_BASE_DIR + DB_ALIVE_DIR + in2 + "\\" + file_name;

	FileHandle file = OpenFile(player_alive, FileMode.WRITE);

	if (file != 0) {
		in3.Replace("<null>", "\'" + "\'");
		FPrint(file, in3);
		CloseFile(file);
	}  else {
		MakeDirectory(DB_BASE_DIR + DB_ALIVE_DIR + in2 );
	}

}


string DataBaseRead(string in1, string in2)
{
	string player_alive, file_content, file_name;

	file_content = "";

	file_name = DB_FILENAME;

	file_name.Replace(file_name, in1);

	player_alive = DB_BASE_DIR + DB_ALIVE_DIR + in2 + "\\" + file_name;

	FileHandle file = OpenFile(player_alive, FileMode.READ);

	if (file != 0)  { 
		FGets(file, file_content);
		CloseFile(file);
	}

	return file_content;
}
