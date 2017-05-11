---------------------------------------------
-- module : 二级界面打开的过滤器（非状态机界面）
-- auther : cruelogre
-- Date:    2016.12.21
-- comment: 
--  		

-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------
local SecondUIFilter = class("SecondUIFilter",require("packages.statebase.FSFilter"))

function SecondUIFilter:ctor(filterId,priority)
	SecondUIFilter.super.ctor(self,filterId,priority)
	self.filterType = bit._or(FSConst.FilterType.Filter_Enter,FSConst.FilterType.Filter_Resume)

end
--设置打开的UI界面数据
--@param uiPath UI的地址
--@param parentNode UI需要附着的父节点
--@param zOrder 层级
--@param createParam 创建时的参数
function SecondUIFilter:setOpenUIData(uiPath,parentNode,zOrder,createParam)
	self.uiPath = uiPath
	self.parentNode = parentNode
	self.zOrder = zOrder
	self.createParam = createParam
end

function SecondUIFilter:doFilter(filterChain,filterType)
	if SecondUIFilter.super.doFilter(self,filterChain,filterType) then
		if self.uiPath then
			self.parentNode = self.parentNode or display.getRunningScene()
			self.zOrder = self.zOrder or ww.centerOrder
			if isLuaNodeValid(self.parentNode) then
				local uilayer = require(tostring(self.uiPath)):create(self.createParam)
				if uilayer then
					self.parentNode:addChild(uilayer,self.zOrder)
					
				end
			end

		end
	end
	return true
end


function SecondUIFilter:finalizer()
	self.uiPath = nil
	self.parentNode = nil
	self.zOrder = nil
end
return SecondUIFilter