-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.20
-- Last: 
-- Content:  设置界面中子控件基类
--			继承自Layout，一个初始化尺寸的控件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local SettingLayer_widget_base = class("SettingLayer_widget_base",function ()
	return ccui.Layout:create()
end)
local SettingCfg = require("hall.mediator.cfg.SettingCfg")
local SettingProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SETTING)
function SettingLayer_widget_base:ctor(size)
	self.size = size
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	
	
end
--	设置cid，主要用于http请求的时候的唯一标识符 隐私政策，服务协议
function SettingLayer_widget_base:setCid(cid)
	self.cid = cid
end
-- 激活控件 主要用于数据网络请求或者缓存中读取更新
function SettingLayer_widget_base:active()
	SettingProxy:requestProtocol(self.cid)
end



return SettingLayer_widget_base