class DataBase 
{
	
	string base = DB_BASE_DIR;
		
	string alive = DB_BASE_DIR + DB_ALIVE_DIR;
		
	string dead = DB_BASE_DIR + DB_DEAD_DIR;
	

	// constructor
	void DataBase()
	{
		 CreateDir();
	}
	
	// destructor
	void ~DataBase()
	{
	}
	
	void CreateDir()
	{

		FileHandle basedir = OpenFile(base, FileMode.READ);
		
		FileHandle alivedir = OpenFile(alive, FileMode.READ);
		
		FileHandle deaddir = OpenFile(dead, FileMode.READ);
			
	
			if (basedir == 0) {
				MakeDirectory(base);
			}
			
			if (alivedir == 0) {
				MakeDirectory(alive);
			}
			
			if (deaddir == 0) {
				MakeDirectory(dead);
			}
	}
	
}	 

	
	