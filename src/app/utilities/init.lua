-- 全局工具类
require "app.utilities.WWNodeEx"
cc.exports.ToolCom = require 'app.utilities.ToolCom'
cc.exports.hotRequire = function(moduleName)
    if true then
        if package.loaded[moduleName] then
            package.loaded[moduleName] = nil
        end
    end
    return require(moduleName)
end

--@param clearModules 需要清除的模块
cc.exports.reStartGame = function (clearModules)
	local oldModules = {}
	
	require("app.config.wwLuaConfig")

	requireExport()
	clearccExports()
	setNilExports()
	
	copyTable(package.loaded,oldModules)
	for k,v in pairs(oldModules) do
		for _,m_module in ipairs(clearModules) do
			if (string.len(k)>=string.len(m_module) and 
				string.sub(k,1,string.len(m_module))==m_module) then
					
					if k~="app.utilities.init" or k~="app.config.wwLuaConfig" then --自己的不要重新加载了
					print(k)
						package.loaded[k] = nil
					end
					
			end
		end
		
	end

	cc.FileUtils:getInstance():purgeCachedEntries()
	--到这儿肯定是有资源更新的情况下，把这两个路径设置成顶级搜索路径
	cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."Resources/src",true)
	cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."Resources/res",true)
	require "config"
	require "cocos.init"
	require "packages.init"
	require "app.init"
	--清空缓存
	require "app.utilities.WWNodeEx"
	require "app.utilities.UIFactory" 
	require "app.utilities.wwutils"
	require "app.utilities.ToolAnim"
	require "app.utilities.ToolCom"
	require "app.utilities.PublicApi"
	require "app.utilities.ToolMd5"
	--字体常用不需要释放
	local text = ccui.Text:create("","FZZhengHeiS-B-GB.ttf",10)
	text:retain()
	--随机种子
	math.randomseed(os.time())  
	--设置不锁屏
	cc.Device:setKeepScreenOn(true)
	i18n:load('app.string', 'zh')
	ww.WWMsgManager:getInstance():logout() --退出登录 重新走登录流程
	ww.UpgradeAssetsMgrContainer:getInstance():release()
	WWFacade:dispatchCustomEvent(LOGIN_SCENE_EVENTS.MAIN_ENTRY)
end

--UI工厂
require "app.utilities.UIFactory" 
require "app.utilities.wwutils"
require "app.utilities.ToolAnim"
require "app.utilities.ToolCom"
require "app.utilities.PublicApi"
require "app.utilities.ToolMd5"

require "app.utilities.UmengManager"