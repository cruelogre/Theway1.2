#include "Helper.h"

NameHelper::NameHelper(const std::string& dir)
:m_strDir(dir)
{
	foreachDir(dir);
}

void NameHelper::foreachDir(const std::string& dir)
{
	struct _finddata_t fileInfo;
	std::string temp = dir;
	auto hFile = _findfirst(temp.append("/*.*").c_str(), &fileInfo);
	if (-1 == hFile)
	{
		return;
	}
	do
	{
		if (strcmp(fileInfo.name, ".") && strcmp(fileInfo.name, ".."))
		{
			if (fileInfo.attrib&_A_SUBDIR)
			{
				temp = dir;
				foreachDir(temp.append(std::string("/") + fileInfo.name));
			}
			else
			{
				temp = dir;
				temp.append(std::string("/") + fileInfo.name);
				m_mapPath[dir].push_back(temp);
			}
		}
	} while (_findnext(hFile, &fileInfo) == 0);

	_findclose(hFile);
}

void NameHelper::writeConst(const std::string& out)
{
	for (auto path : m_mapPath)
	{
		std::string str = path.first;
		auto pos = str.find_last_of("/") + 1;
		str = str.substr(pos, str.size() - pos);
		auto name = "ww_" + str + "_const";
		str = out + + "/" + name + ".h";
		std::fstream of(str, std::ios::out);
		if (of.is_open())
		{
			of << std::endl;
			std::transform(name.begin(), name.end(), name.begin(), ::toupper);
			of << "#ifndef _" << name << "_H_" << std::endl;
			of << "#define _" << name << "_H_" << std::endl;
			for (auto file : path.second)
			{
				auto start = file.find_last_of("/") + 1;
				auto name = file.substr(start, file.size() - start);
				auto end = name.find_last_of(".");
				auto sub = name.substr(0, end);
				std::transform(sub.begin(), sub.end(), sub.begin(), ::toupper);
				std::string s = "static const char* " + sub + " = \"" + name + "\";";
				of << "\/\/" << std::endl << s << std::endl;
			}
			of << std::endl;
			of << "#endif" << std::endl;
			of.close();
		}
	}
}
