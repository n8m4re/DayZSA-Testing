class DataBase
{	
	static const string BASE_DIR = "$profile:db";
	static const string ALIVE_DIR = "\\alive\\";
	static const string DEAD_DIR =  "\\dead\\";
	static string GetDate();
	static void CreateDir();
};

static string DataBaseRead(string in1);
static void DataBaseWrite(string in1, string in2);
static void DataBaseDelete(string in1);
