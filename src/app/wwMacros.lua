-----------------------------------------------------------
-- Desc:     地方棋牌
-- Author:   diyal.yin
-- Date:  	 2016/08/13
-- Last: 	
-- Content:  共通定义
--	1、ww.p  ww.px ww.py适配宏
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------------------
local macros = { }

function macros.init()
	print("macros.init")
	assert(ww ~= nil)

	-- 坐标适配
	ww.p = function(x, y)
		local x = x / CC_DESIGN_RESOLUTION.width *(cc.Director:getInstance():getVisibleSize().width)
		local y = y / CC_DESIGN_RESOLUTION.height *(cc.Director:getInstance():getVisibleSize().height)
		return cc.p(x, y)
	end

	ww.size = function(width, height)
		local x = width / CC_DESIGN_RESOLUTION.width *(cc.Director:getInstance():getVisibleSize().width)
		local y = height / CC_DESIGN_RESOLUTION.height *(cc.Director:getInstance():getVisibleSize().height)
		return cc.size(x, y)
	end

	--分别获取x、y的适配坐标方便用GenUiUtil生成界面
	ww.px = function(x)
		return x / CC_DESIGN_RESOLUTION.width *(cc.Director:getInstance():getVisibleSize().width)
	end
	ww.py = function(y)
		return y / CC_DESIGN_RESOLUTION.height *(cc.Director:getInstance():getVisibleSize().height)
	end

	ww.scaleX = cc.Director:getInstance():getVisibleSize().width / CC_DESIGN_RESOLUTION.width
	ww.scaleY = cc.Director:getInstance():getVisibleSize().height / CC_DESIGN_RESOLUTION.height

	ww.topOrder = 10000 --最顶层Order  推送等不受程序逻辑控制的层级
	ww.centerOrder = 1000  --二级弹窗等
	ww.bottomOrder = 100  --普通一级弹窗
	
	ww.TABLECELL_MOVED = 11001 - 21 -- tableview 中触摸移动
	ww.TABLECELL_TOUCHENDED = 11002 - 21 -- tableview 中触摸取消
	ww.TABLECELL_LONGTOUCHED = 11003 - 21 -- tableview 中长按
	
	ww.HeadType = {["Normal"]=11, ["UPLOAD"]=101, ["CHECK"]=102}  --11 默认  101 审核过  102 待审核

end

return macros

