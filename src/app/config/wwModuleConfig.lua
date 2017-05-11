cc.exports.ModuleConfig = {
	ModuleId = {};
	ModuleName = {};
	DownloadInfo = {};
}

ModuleConfig.ModuleId = {
	g_LuaGameID = 2003;
	g_ChatGameID = 2004
}
ModuleConfig.ModuleName = {
	g_LuaGameID = "src";
	g_ChatGameID = "chat";
}
ModuleConfig.DownloadInfo = {
	g_LuaGameID = {
		resName = "src.zip";
		storagePath = cc.FileUtils:getInstance():getWritablePath().."src.zip";
		priority = 1;
		downloadId = 2003; 
	};
	g_ChatGameID = {
		resName = "Chat.zip";
		storagePath = cc.FileUtils:getInstance():getWritablePath().."res/Chat.zip";
		priority = 3;
		downloadId = 2004; 
	};
}
