
void createDir() {
	
	string _dbfile;
	
	_dbfile = DB_FILE;
	
	strrep(_dbfile, "$_file", "test");
				
	if (!FileExist(_dbfile)) {
		
			MakeDirectory("$profile:db");
			
			FileHandle file = OpenFile(_dbfile, FILEMODE_WRITE);
	
			if (file != 0) {
				FPrint(file, "THIS IS A TEST!");
				CloseFile(file);
			}
	}
}


void Enf_DbDelete(string in1)
{
	
	string _dbfile;
	
	_dbfile = DB_FILE;
	
	strrep(_dbfile, "$_file", in1);
			
	FileHandle file  = DeleteFile(_dbfile);

}


void Enf_DbWrite(string in1, string in2)
{
	createDir();
	
	string _dbfile;
	
	_dbfile = DB_FILE;
	
	strrep(_dbfile, "$_file", in1);
		
	FileHandle file = OpenFile(_dbfile, FILEMODE_WRITE);
	
	if (file != 0) {
		
		strrep(in2, "<null>", "[]");
		
		FPrintln(file, in2);
		
		CloseFile(file);
	}

}




string Enf_DbRead(string in1)
{
	
	string _dbfile = DB_FILE;
	
	strrep(_dbfile, "$_file", in1);
	
	FileHandle file_index = OpenFile(_dbfile, FILEMODE_READ);

	string line_content;

	FGets( file_index,  line_content );

	CloseFile(file_index);
	
	return line_content;
	
}



