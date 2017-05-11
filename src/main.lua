cc.FileUtils:getInstance():setPopupNotify(false)

cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."Resources")
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")
cc.FileUtils:getInstance():addSearchPath("base")
ww.WWConfigManager:getInstance():initConfig("WWPlatform/wwConfig.xml")
require "config"
require "cocos.init"
--监测版本号问题
local function checkVersion()
	local FileUtils = cc.FileUtils:getInstance()
	local hallVersionFile = "hall_version.txt"
	if FileUtils:isFileExist(hallVersionFile) then
		local versionStr = FileUtils:getStringFromFile(hallVersionFile)
		
		--比较版本号
		--retun true 本地版本号比目标版本号小
		--return false 
		local compareVersion =  function(localClientVersion,targetClientVersion)
			if localClientVersion and targetClientVersion then
				
				local localVArr = string.split(localClientVersion,".")
				local targetVArr = string.split(targetClientVersion,".")
				if localVArr and targetVArr and table.nums(localVArr)==table.nums(targetVArr) then
					local isBigger = false
					for i=1,table.nums(targetVArr) do
						if tonumber(targetVArr[i]) > tonumber(localVArr[i]) then
							isBigger = true
							break 
						end
					end
					return isBigger
				end
			else
				return false
			end
			
			return false
		end
		if versionStr then
			local versionArr = string.split(versionStr,"|")
			if versionArr and table.maxn(versionArr)==2 then
				local gameVersion = versionArr[1]
				local subVersion = versionArr[2]
				if gameVersion and subVersion then
					require("app.config.wwConfigData")
					if compareVersion(wwConfigData.GAME_VERSION,gameVersion) or --内置文件比目标文件小
						( wwConfigData.GAME_VERSION == gameVersion and wwConfigData.GAME_SUBVERSION < tonumber(subVersion)) then
							wwConfigData = nil
							wwURLConfig = nil
							package.loaded["app.config.wwConfigData"] = nil
							
							
							cc.FileUtils:getInstance():purgeCachedEntries()
							cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."Resources/src",true)
							cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."Resources/res",true)
					else
						--否则 本地版本大，删除下载的资源文件
						wwlog("内置版本大于下载版本，删除下载版本资源文件")
						if cc.FileUtils:getInstance():isDirectoryExist(cc.FileUtils:getInstance():getWritablePath().."Resources/src") then
							wwlog("删除下载目录Resources/src")
							removeDir(cc.FileUtils:getInstance():getWritablePath().."Resources/src")
						end
						if cc.FileUtils:getInstance():isDirectoryExist(cc.FileUtils:getInstance():getWritablePath().."Resources/res") then
							wwlog("删除下载目录Resources/res")
							removeDir(cc.FileUtils:getInstance():getWritablePath().."Resources/res")
						end
					end
					
				end
			end
		end
	end
	
end

checkVersion()
require "packages.init"
require "app.init"

local function main()
	collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
	wwlog("============================Start Game=======================")
	wwlog("main", "启动游戏 - "..os.date("[%Y-%m-%d %H:%M:%S] ", os.time()))
	
	--字体常用不需要释放
	local text = ccui.Text:create("","FZZhengHeiS-B-GB.ttf",10)
	text:retain()
	--随机种子
	math.randomseed(os.time())  

	--设置不锁屏
	cc.Device:setKeepScreenOn(true)

	--HALL_SCENE_EVENTS
	--LOGIN_SCENE_EVENTS
	i18n:load('app.string', 'zh')
    WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.MAIN_ENTRY)
	
    -- WWFacade:dispatchCustomEvent(MJ_EVENT.MJ_ENTRY)
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
