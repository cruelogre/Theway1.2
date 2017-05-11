#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <io.h>
#include <map>
#include <algorithm>  

typedef std::map<std::string, std::vector<std::string>> MapVecStr;

class NameHelper
{
public:
	NameHelper(const std::string& dir);
	void writeRenameEx();
protected:
	void foreachDir(const std::string& dir);
	void splitStr(std::string str, std::vector<std::string>& vec, std::string s);
protected:
	std::string m_strDir;
	MapVecStr m_mapPath;
};