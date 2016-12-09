
static private string DataBase::GetDate()
{
	int year, month, day, hour, minute, second;
	
	GetYearMonthDay(year, month, day);
	
	GetHourMinuteSecond(hour, minute, second);

	string date = itoal(month, 2) + "-" + itoal(day, 2) + "-" + itoal(hour, 2) + itoal(minute, 2);
	
	return date;
}


static void DataBase::CreateDir() 
{
	Print("Database CreateDir");
	
	MakeDirectory(BASE_DIR);

	MakeDirectory(BASE_DIR + ALIVE_DIR);

	MakeDirectory(BASE_DIR + DEAD_DIR);
	
}



static void DataBaseDelete(string in1, string in2)
{
	string player_alive, player_dead, file_name, date;
	
	MakeDirectory(DataBase.BASE_DIR + DataBase.DEAD_DIR + in2);
	
	file_name = "$FILENAME$.sqf";
	
	strrep(file_name, "$FILENAME$", in1);
	
	date = DataBase.GetDate();
	
	player_alive = DataBase.BASE_DIR + DataBase.ALIVE_DIR + in2 + "\\" + file_name;
	
	player_dead = DataBase.BASE_DIR + DataBase.DEAD_DIR + in2 + "\\" + file_name;
	
	FileHandle file = OpenFile(player_alive, FILEMODE_READ);
	
	if (file != 0)  {   
		
		CloseFile(file);

		CopyFile(player_alive, player_dead); 	
		
		DeleteFile(player_alive);
	} 
}



static void DataBaseWrite(string in1, string in2, string in3)
{	
	string player_alive, file_name;

	file_name = "$FILENAME$.sqf";
	
	strrep(file_name, "$FILENAME$", in1);
	
	player_alive = DataBase.BASE_DIR + DataBase.ALIVE_DIR + in2 + "\\" + file_name;
			
	FileHandle file = OpenFile(player_alive, FILEMODE_WRITE);
	

	if (file != 0) {
		
		strrep(in3, "<null>","\"" + "\"");
		
		FPrintln(file, in3);
		
		CloseFile(file);

	}  else {
		
		MakeDirectory(DataBase.BASE_DIR + DataBase.ALIVE_DIR + in2 );
		
	}
	
}



static string DataBaseRead(string in1, string in2)
{
	string player_alive, file_content, file_name;
	
	file_content = "";
	
	file_name = "$FILENAME$.sqf"
	
	strrep(file_name, "$FILENAME$", in1);
	
	player_alive = DataBase.BASE_DIR + DataBase.ALIVE_DIR + in2 + "\\" + file_name;
		
	FileHandle file = OpenFile(player_alive, FILEMODE_READ);
	
	if (file != 0)  {  
	
		FGets(file, file_content);
		
		CloseFile(file);
	}
	
	return file_content;
}





