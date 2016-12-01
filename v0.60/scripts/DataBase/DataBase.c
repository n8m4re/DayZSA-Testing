
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



static void DataBaseDelete(string in1)
{
	string player_alive, player_dead, file_name;
	
	file_name = "$FILENAME$.db";
	
	strrep(file_name, "$FILENAME$", in1);
	
	player_alive = DataBase.BASE_DIR + DataBase.ALIVE_DIR + file_name;
	
	player_dead = DataBase.BASE_DIR + DataBase.DEAD_DIR + DataBase.GetDate() + "_"  + file_name;
	
	FileHandle file = OpenFile(player_alive, FILEMODE_READ);
	
	if (file != 0)  {   
	
		CloseFile(file);
		
		CopyFile(player_alive, player_dead); 	
		
		DeleteFile(player_alive);
		
		// return true;
		
	} 
		
	// return false;
}



static void DataBaseWrite(string in1, string in2)
{	
	string player_alive, file_name;
	
	file_name = "$FILENAME$.db";
	
	strrep(file_name, "$FILENAME$", in1);
	
	player_alive = DataBase.BASE_DIR + DataBase.ALIVE_DIR + file_name;
			
	FileHandle file = OpenFile(player_alive, FILEMODE_WRITE);
	
	if (file != 0) {
		
		strrep(in2, "<null>", "false");
		
		FPrintln(file, in2);
		
		CloseFile(file);

		// return true;
	} 
	
	// return false;
}



static string DataBaseRead(string in1)
{
	string player_alive, file_content, file_name;
	
	file_content = "";
	
	file_name = "$FILENAME$.db"
	
	strrep(file_name, "$FILENAME$", in1);
	
	player_alive = DataBase.BASE_DIR + DataBase.ALIVE_DIR + file_name;
		
	FileHandle file = OpenFile(player_alive, FILEMODE_READ);
	
	if (file != 0)  {  
	
		FGets(file, file_content);
		
		CloseFile(file);
	}
	
	return file_content;
}
