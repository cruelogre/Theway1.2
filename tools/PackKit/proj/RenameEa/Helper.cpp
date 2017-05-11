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

void NameHelper::writeRename()
{
	for (auto path : m_mapPath)
	{
		std::cout << path.first << std::endl;
		for (auto file : path.second)
		{
			auto pos = file.find_last_of("/");
			if (std::string::npos == pos)
			{
				continue;
			}

			std::string str = file.substr(0, pos + 1);
			std::string ext = file.substr(pos + 1, file.size() - pos - 1);

			std::string ret = "";
			for (auto c : ext)
			{
				if ('_' != c)
				{
					ret.push_back(c);
				}
			}

			str += ret;
			if (0 == rename(file.c_str(), str.c_str()))
			{
				std::cout << file << std::endl;
			}
		}
	}
}
