-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.12.24
-- Last: 
-- Content:  大厅状态跳转功能
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UIStateJumper = class("UIStateJumper")
local JumpFilter = require("packages.statebase.filter.JumpFilter")
local CorFilter = require("packages.statebase.filter.CorFilter")
local ActivityCfg = import(".ActivityCfg","hall.mediator.cfg.")

function UIStateJumper:ctor()
	self.logTag = self.__cname..".lua"
end

function UIStateJumper:JumpUI(opendata,...)
	if opendata then
		if tonumber(opendata.uopenType) == ActivityCfg.openType.STATEUI then
			self:jumpState(opendata,...)
		elseif tonumber(opendata.uopenType) == ActivityCfg.openType.SECONDUI then
			self:openCustomUI(opendata,...)
		elseif tonumber(opendata.uopenType) == ActivityCfg.openType.THIRDAPP then
			self:openAPP(opendata,...)
		else
			wwlog(self.logTag,"跳转UI失败......未识别的打开类型"..tonumber(opendata.uopenType))
		end
	else
		wwlog(self.logTag,"跳转UI失败......opendata 为nil")
	end
end

--跳转状态
--@param jumpdata 跳转的数据封装 table类型
--	    jumpdata.param 状态机trigger的参数
--		jumpdata.stateName 跳转至状态名
--		jumpdata.eventName 触发的事件名称
function UIStateJumper:jumpState(jumpdata,...)
	wwlog(self.logTag,"跳转状态......")
	if not jumpdata then
		wwlog(self.logTag,"跳转为空 error!")
		return
	end
	local externalData = {...}
	if jumpdata.param and externalData then
		local dataLen = #externalData
		for index = 1,dataLen do
			for i,v in pairs(jumpdata.param) do
				if v=="%"..index.."%" then
					jumpdata.param[i] = externalData[index]
					break
				end
			end
			
		end
	end
	dump(jumpdata,"跳转状态数据")
	if not jumpdata.stateName then
		wwlog(self.logTag,"配置状态名字为空  error!")
		return
	end
	if not jumpdata.eventName then
		wwlog(self.logTag,"配置事件名字为空  error!")
		return
	end
	
	local jumpFilter = JumpFilter:create(1,bit._or(FSConst.FilterType.Filter_Enter,FSConst.FilterType.Filter_Resume),1)
	jumpFilter:setJumpData(jumpdata.eventName, jumpdata.param)
	FSRegistryManager:currentFSM():addFilter("UIRoot",jumpFilter)
	
	--如果这个state就在堆栈中
	local cor = CorFilter:create(2,FSConst.FilterType.Filter_Resume,1)
	cor:setCorData(function ()
		wwlog( self.logTag,"删除过滤器")
		FSRegistryManager:currentFSM():removeFilter("UIRoot",1)
		
	end)
	FSRegistryManager:currentFSM():addFilter(jumpdata.stateName,jumpFilter)
	
	local curStateName = FSRegistryManager:currentFSM():currentState().mStateName
	if curStateName=="UIRoot" then
		FSRegistryManager:currentFSM():doFilter(FSConst.FilterType.Filter_Enter)
	else
		while curStateName~="UIRoot" and curStateName~=jumpdata.stateName do
			wwlog( self.logTag,"back返回")
			FSRegistryManager:currentFSM():trigger("back")
			curStateName = FSRegistryManager:currentFSM():currentState().mStateName
		end
	end

end


function UIStateJumper:openCustomUI(jumpdata)
	
	-- display.getRunningScene():addChild(require(opendata.uipath):create(),ww.centerOrder)
	display.getRunningScene():addChild(require(jumpdata.uipath):create(),ww.centerOrder)
	
end

function UIStateJumper:openAPP(jumpdata)

end
cc.exports.UIStateJumper = cc.exports.UIStateJumper or UIStateJumper:create()
return UIStateJumper