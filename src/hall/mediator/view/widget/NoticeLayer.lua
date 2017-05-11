-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal
-- Date:    2016.09.27
-- Last: 
-- Content:  公告
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local NoticeLayer = class("NoticeLayer",require("app.views.uibase.PopWindowBase"))

function NoticeLayer:ctor(datas)
	NoticeLayer.super.ctor(self)

	self.datas = datas

	wwdump(self.datas)
	
	self:init()
end

function NoticeLayer:init()
	
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)

	self.node = require("csb.hall.match.MatchLayer_content"):create().root
	
	FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)
	self.imgNode = self.node:getChildByName("Image_bg")
	local scrollBg = ccui.Helper:seekWidgetByName(self.imgNode,"Image_content")
	local Image_header = ccui.Helper:seekWidgetByName(self.imgNode,"Image_header")
	local Text_title = ccui.Helper:seekWidgetByName(Image_header,"Text_title")
	FixUIUtils.stretchUI(self.imgNode)
	self.scroll = ccui.Helper:seekWidgetByName(self.imgNode,"ScrollView_content")
	self.title = ccui.Helper:seekWidgetByName(self.imgNode,"Text_title")
	self.size = self.scroll:getContentSize()


	Text_title:setString(i18n:get("str_hall", "hall_notice_title"))

	--self:setInnerContainerSize(cc.size(900,1800))
	self.scroll:setClippingEnabled(true)
	self.scroll:setScrollBarEnabled(false)
	self:popIn(self.imgNode,Pop_Dir.Right)

	-- self.content = self.datas.notices[1].Subject
	self.content = self.datas.Content

--[[
<br/>
<font color = '274e13' size = "42" align='center'> 
更新公告
</font> <br/>
<font color = '082e54' size = "35">
1、经典房<br/>
2、比赛场<br/>
3、商城<br/>
4、消息箱<br/>
5、个人信息<br/>
6、公告<br/>
7、滚报<br/>
7、签到<br/>
通过签到获取到游戏币，就可以去经典、比赛场
</font><br/>
<font color = 'c76114' size = "35" align="right"> 
［蛙蛙游戏掼蛋开发团队］
</font>
]]--

	local richTxt = string.format([[ %s ]], self.content)

	local bgSize = scrollBg:getContentSize()

	local richView = ww.SuperRichText:create(ww.size(bgSize.width * 0.95, bgSize.height))
	richView:setAnchorPoint(0.5, 1)
	richView:ignoreAnchorPointForPosition(false)
	richView:renderHtml(richTxt)
	-- scrollBg:addChild(richView)

	local scrollSize = cc.size(bgSize.width,bgSize.height * 1.2)

	self.scroll:setContentSize(bgSize)
	self.scroll:setPosition(0, 0)
	self.scroll:setInnerContainerSize(scrollSize)
	self.scroll:jumpToTop()

	richView:setPosition(cc.p(scrollSize.width * 0.5, scrollSize.height))
	self.scroll:addChild(richView, 1000)

end

return NoticeLayer