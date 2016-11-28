
static string GetDate()
{
	int year, month, day, hour, minute, second;
	
	GetYearMonthDay(year, month, day);
	
	GetHourMinuteSecond(hour, minute, second);

	string date = itoal(month, 2) + "-" + itoal(day, 2) + "-" + itoal(hour, 2) + itoal(minute, 2);
	
	return date;
}


static void DbCreateDir() 
{
	MakeDirectory(DB_BASE_DIR);
	
	MakeDirectory(DB_BASE_DIR + DB_ALIVE_DIR);
	
	MakeDirectory(DB_BASE_DIR + DB_DEAD_DIR);
	
	Print("DbCreateDir()");
}



static bool Enf_DbDelete(string in1)
{
	string player_alive, player_dead, file_name;
	
	file_name = "$FILENAME$.db";
	
	strrep(file_name, "$FILENAME$", in1);
	
	player_alive = DB_BASE_DIR + DB_ALIVE_DIR + file_name;
	
	player_dead = DB_BASE_DIR + DB_DEAD_DIR + GetDate() + "_"  + file_name;
	
	FileHandle file = OpenFile(player_alive, FILEMODE_READ);
	
	if (file != 0)  {   
	
		CloseFile(file);
		
		CopyFile(player_alive, player_dead); 	
		
		DeleteFile(player_alive);
		
		return true;
		
	} 
		
	return false;
}



static bool Enf_DbWrite(string in1, string in2)
{	
	string player_alive, file_name;
	
	file_name = "$FILENAME$.db";
	
	strrep(file_name, "$FILENAME$", in1);
	
	player_alive = DB_BASE_DIR + DB_ALIVE_DIR + file_name;
			
	FileHandle file = OpenFile(player_alive, FILEMODE_WRITE);
	
	if (file != 0) {
		
		FPrintln(file, in2);
		
		CloseFile(file);
		
		return true;
	} 
	
	return false;
}



static string Enf_DbRead(string in1)
{
	string player_alive, file_content, file_name;
	
	file_content = "";
	
	file_name = "$FILENAME$.db"
	
	strrep(file_name, "$FILENAME$", in1);
	
	player_alive = DB_BASE_DIR + DB_ALIVE_DIR + file_name;
		
	FileHandle file = OpenFile(player_alive, FILEMODE_READ);
	
	if (file != 0)  {  
	
		FGets(file, file_content);
		
		CloseFile(file);
		
		strrep(file_content, "<null>", "false");
		
		return file_content;	
	}
	
	
	return "";
}


