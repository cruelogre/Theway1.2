---------------------------------------------
-- module : 大厅模块处理类
-- auther : cruelogre
-- Date:    2016.11.3
-- comment: 
--  		1. 每个模块ID mGameModuleID
--			2.实现 startExecute 进入模块
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------

local SettingModuleHandler = class("SettingModuleHandler",require("app.hotupdate.ModuleBaseHandler"))

local moduleId = 9999 --大厅的模块ID
function SettingModuleHandler:ctor(iID,priority)
	SettingModuleHandler.super.ctor(self,iID,priority)
	self.mGameModuleID = moduleId --模块的ID
	
end

--监测更新  默认不需要
--@return true 不需要更新
--@return false 需要更新
function SettingModuleHandler:intercept()
	self:initUpgradeMgr()
	wwlog(self.logTag,"设置拦截器开始拦截...")
--[[	if self:isGameModuleResExisted() then
		self:startExecute()
		return true
	else 
		self:stopEnter() 
	end--]]
	--弹出更新界面
	return false --需要更新
end



--这里是一个空的实现 进入
function SettingModuleHandler:startExecute()
	SettingModuleHandler.super.startExecute(self)
end
function SettingModuleHandler:isGameModuleResExisted()
	return SettingModuleHandler.super.isGameModuleResExisted(self)
end

--更新模块资源
function SettingModuleHandler:stopEnter()
	
	SettingModuleHandler.super.stopEnter(self)
end

return SettingModuleHandler