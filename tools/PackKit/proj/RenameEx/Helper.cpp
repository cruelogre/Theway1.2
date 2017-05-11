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

void NameHelper::splitStr(std::string str, std::vector<std::string>& vec, std::string s)
{
	int pos = str.find_first_of(s);
	while (std::string::npos != pos)
	{
		std::string pre = str.substr(0, pos);
		vec.push_back(pre);
		str = str.substr(pos + 1, str.size() - pos - 1);
		pos = str.find_first_of(s);
	}
	vec.push_back(str);
}

void NameHelper::writeRenameEx()
{
	auto pos0 = m_strDir.size();
	for (auto path : m_mapPath)
	{
		for (auto file : path.second)
		{
			auto pos1 = file.find_last_of(".");
			std::string ext = file.substr(pos1, file.size() - pos1);
			std::string sub = file.substr(pos0 + 1, pos1 - pos0 - 1);

			std::vector<std::string> v;
			splitStr(sub, v, "/");
			std::string str0 = "/";
			std::string str1 = "";
			for (int i = 0; i < (int)v.size(); i++)
			{
				if (i < v.size() - 1) str0 += v[i] + "/";
				str1 += v[i];
				if(i < v.size() - 1) str1 += "_";
			}

			auto final = m_strDir + str0 + str1 + ext;
			if (0 == rename(file.c_str(), final.c_str()))
			{
				std::cout << file << std::endl;
			}
		}
	}
}
