-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.11
-- Last: 
-- Content:  比赛详情界面（共用，通过cid区分）
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local MatchLayer_widget_detail = class("MatchLayer_widget_detail",require("app.views.uibase.PopWindowBase"))

local MatchCfg = require("hall.mediator.cfg.MatchCfg")
local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)
function MatchLayer_widget_detail:ctor(data)
	MatchLayer_widget_detail.super.ctor(self)
	self:init(data)
	
end

function MatchLayer_widget_detail:init(data)
	
--[[	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)--]]
	self.data = data
	
	self.node = require("csb.hall.match.MatchLayer_content"):create().root
	
	FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)
	self.imgNode = self.node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgNode)
	self.scroll = ccui.Helper:seekWidgetByName(self.imgNode,"ScrollView_content")
	self.title = ccui.Helper:seekWidgetByName(self.imgNode,"Text_title")
	self.size = self.scroll:getContentSize()
	--self:setInnerContainerSize(cc.size(900,1800))
	self.scroll:setClippingEnabled(true)
	self.scroll:setScrollBarEnabled(false)
	self:popIn(self.imgNode,Pop_Dir.Right)
end 

--	设置cid，主要用于http请求的时候的唯一标识符 隐私政策，服务协议
function MatchLayer_widget_detail:setCid(cid)
	self.cid = cid
	local titleTag = MatchCfg.getTileByCid(self.cid)
	print("MatchLayer_widget_detail:titleTag ",titleTag)
	if titleTag then
		local titleName = i18n:get('str_match',titleTag)
		if titleName and string.len(titleName)>0 then
			self.title:setString(titleName)
		end
		
	end
	
end
-- 激活控件 主要用于数据网络请求或者缓存中读取更新
function MatchLayer_widget_detail:active()
	--SettingProxy:requestProtocol(self.cid)
end

--设置关闭回调
function MatchLayer_widget_detail:bindCloseCB(closeCB)
	self._closeCB = closeCB
	
	if self._closeCB and type(self._closeCB)=="function" then
		
		self:setDisCallback(function ( ... )
		-- body
			
			self._closeCB()
			self._closeCB = nil
			
			self:removeFromParent()
			
			
		end)
	end
end

function MatchLayer_widget_detail:initView(...)
	local eventName = MatchCfg.getEventByCid(self.cid)
	local contenttable = DataCenter:getData(eventName)
	
	if not contenttable or not contenttable.content then
		return
	end

	self:freshContent(contenttable.content)
	
	
end

--刷新内容
function MatchLayer_widget_detail:freshContent(content)
	self.scroll:removeAllChildren()
	
	local tmpCfg2 = { fontFilePath = "FZZhengHeiS-B-GB.ttf", fontSize = 30, glyphs = "CUSTOM" }



	--添加公告
	wwlog("SuperRichTextDemo:init")
	-- local richTxt = [[
	--     <font color = '000000' align = 'center' size="">【公告】</font><br/>
	--     <font color = '000000'>游戏公告:</font><br/>
	--     <font>  亲爱的玩家：</font><br/>
	--     <font>  由于《第二节互联网大会》召开，快递公司将于12月9日至12月20日期间不再接受快递包裹，影响快递物品（包括：蛙蛙公仔、游戏抱枕），其它礼品不受影响，12月20日后恢复正常！</font><br/>
	--     <font  color = '000000'>1.0.2.2更新公告:</font><br/>
	--     <font>  亲爱的玩家：</font><br/>
	--     <font>  1、降低游戏难度，增加奖励数量</font><br/>
	--     <font>  2、增加多个活动，每天12点准时开始，每轮10分钟</font><br/>
	--     <font>  3、优化游戏性能</font><br/>
	--     <font>  4、修复了一些Bug</font><br/>
	-- ]]

	local richTxt = string.format([[ %s ]], content)
	-- content

	-- richTxt = 
	-- [[
	-- [font color = '274e13' size="42" align="center"] 
	-- 	精英挑战赛
	-- 	[/font][br/]
	-- 	[font color='082e54' size="35"]
	-- 	夺冠时长：约45分钟[br/]
	-- 	初始积分：10000[br/]
	-- 	决赛：3轮3局制，晋级人数见人数内提示[br/]
	-- 	[/font]
	-- ]]

	wwlog(content)

	local richView = ww.SuperRichText:create(self.size)
	richView:setAnchorPoint(0.5, 1)
	richView:ignoreAnchorPointForPosition(false)
	richView:setPosition(cc.p(self.size.width * 0.5, self.size.height * 0.95))
	richView:renderHtml(richTxt)
	
	-- local ttf2 = cc.Label:createWithTTF(tmpCfg2,content, cc.TEXT_ALIGNMENT_LEFT, self.size.width*0.96)
	--contenttable.content, "Helvetica", 30,self.size, cc.TEXT_ALIGNMENT_LEFT
	-- ttf2:setName("text")
	-- ttf2:setColor(cc.c3b(91,97,94))
	-- ttf2:setAnchorPoint(cc.p(0.5,1.0))
	-- ttf2:setPosition(cc.p(self.size.width/2,self.size.height))
	self.scroll:setInnerContainerSize(cc.size(self.size.width,richView:getContentSize().height))
    self.scroll:addChild(richView, 1000)
	self.scroll:jumpToTop()
	
end


function MatchLayer_widget_detail:eventComponent()
	return MatchCfg.innerEventComponent
end

function MatchLayer_widget_detail:onEnter()
	self.super.onEnter(self)
	local eventName = MatchCfg.getEventByCid(self.cid)
	--注册cid响应回调
	if self:eventComponent() then
		local x,handler1 = self:eventComponent():addEventListener(eventName,handler(self,self.initView))
		self.handler1 = handler1
	end

	
	if self.data then
		local data = {}
		data.content = self.data
		local temp = DataCenter:getData(eventName)
		DataCenter:cacheData(eventName,data)
		if self:eventComponent() then
				self:eventComponent():dispatchEvent({
					name = eventName;
					
					msgId = eventName;
					
				})
		else
		self:initView()
		end

	end
	
end

function MatchLayer_widget_detail:onExit()
	self.super.onExit(self)
	--local eventName = MatchCfg.getEventByCid(self.cid)
	if self:eventComponent() then
		self:eventComponent():removeEventListener(self.handler1)
	end
	
	--退出的时候取消cid回调绑定
	--SettingProxy:cancelProtocol(self.cid)
	
end


return MatchLayer_widget_detail