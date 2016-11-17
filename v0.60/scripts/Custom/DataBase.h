const string DB_BASE_DIR = "$profile:db";

const string DB_ALIVE_DIR = "\\alive\\";

const string DB_DEAD_DIR =  "\\dead\\";


bool Enf_DbWrite(string in1, string in2);

void Enf_DbCreateDir();

bool Enf_DbDelete(string in1);

string Enf_DbRead(string in1);

