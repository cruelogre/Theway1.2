-- initialize list for app package
function cc.exports.init_registry(ctlReg, mdrReg, pxyReg)
	-- body
	cc.exports.ControllerRegistry = cc.exports.ControllerRegistry or {}
	table.merge(cc.exports.ControllerRegistry, require(ctlReg))

	cc.exports.MediatorRegistry = cc.exports.MediatorRegistry or {}
	table.merge(cc.exports.MediatorRegistry, require(mdrReg))

	cc.exports.ProxyRegistry = cc.exports.ProxyRegistry or {}
	table.merge(cc.exports.ProxyRegistry, require(pxyReg))
end

-- initialize WWFacade global variable

require("app.wwMacros"):init()

require "app.utilities.init"

require "app.config.wwCsvCfg"

-- require "app.views.init"
require "app.data.init"
--sqlite
require "app.dataorm.WWSQLiteManager"

--全局事件定义
require "app.event.CommonEvent"

require "app.managers.WWFacade"

-- initialize app package registries
cc.exports.init_registry(
	"app.managers.ControllerRegistry",
	"app.managers.MediatorRegistry", 
	"app.managers.ProxyRegistry")

-- project initialize
require("app.appRegistry")
--[[if cc.FileUtils:getInstance():isFileExist("login/init.lua") then 
	require "login.init"
end 
if cc.FileUtils:getInstance():isFileExist("hall/init.lua") then 
	require "hall.init"
end

if cc.FileUtils:getInstance():isFileExist("WhippedEgg/init.lua") then 
	require "WhippedEgg.init"
end--]]

-- initialize ProxyMgr global variable
require "app.managers.ProxyManager"

-- initialize Mediator global variable
require "app.managers.MediatorManager"

-- initialize ControllerMgr global variable
require "app.managers.ControllerManager"

-- register components for game
-- require "app.components.init"

require("app.hotupdate.SilentUpdateQueue")