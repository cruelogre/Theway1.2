-------------------------------------------------------------------------
-- Desc:    地方棋牌 
-- File     AdvertWidget.lua
-- Author:  diyal.yin
-- Date:    2016.08.28
-- Last:    
-- Content:  广告
--	2016-08-28	新建 
--	2017-02-08  广告图不设置默认图，否则加载的时候会闪
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local scheduleTime = 5

local _scheduler = cc.Director:getInstance():getScheduler()

local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
local WWNetSprite = require("app.views.customwidget.WWNetSprite")
local JsonDecorator = import(".JsonDecorator", "app.utilities."):create()

local AdvertWidget = class("AdvertWidget",
    function()
        return display.newLayer()
    end,
    require("packages.mvc.Mediator")
    )

function AdvertWidget:ctor()
	self.logTag = "AdvertWidget.lua"
	self.adMap = {}

	-- local defaultRow = 
	-- {
	-- 	filepath = "hall/ads/hall_ad_default_1.png",
	-- 	adHandleID = "",
	-- }
	-- table.insert(self.adMap, defaultRow)
	self.skipAutoFlg = false

	self.nextIndex = 1

	self:init()
end

function AdvertWidget:init()

	self:onNodeEvent("enter", handler(self, self.onEnter))
	self:onNodeEvent("exit", handler(self, self.onExit))

	-- self:createAdInitPage()
	self.targetNode = display.newNode()
	self:addChild(self.targetNode)

	self:registerEventListener(HALL_SCENE_EVENTS.NETEVENT_ADVERTRET, handler(self, self.onDataRet))
end

--创建Page  pageindex 数据显示索引
function AdvertWidget:createPage( pageindex )

    -- local bg= ccui.Button:create(self.adMap[pageindex].filepath, self.adMap[pageindex].filepath)
	local pageData = self.adMap[pageindex]

	-- wwdump(pageData)

	local para = {}
	para.vt = 1
	para.st = 10001001
	para.uid = DataCenter:getUserdataInstance():getValueByKey("userid")
	para.mst = 1 --TODO

	para.picid = 0

	local bgTmpSprite = cc.Sprite:create("hall/ads/hall_ad_default_1.png")

    -- local bg = WWNetSprite:create("hall/ads/hall_ad_default_1.png", 
    -- 	 ToolCom:getWapUrl(para)..pageData.filepath or "")
    local bg = WWNetSprite:create("", 
    	 ToolCom:getWapUrl(para)..pageData.filepath or "")
    -- wwlog(ToolCom:getWapUrl(para)..pageData.filepath or "")

    self.pagesize = bgTmpSprite:getContentSize()

    local layout = ccui.Layout:create()
    layout:setContentSize(self.pagesize)
    layout:setPosition(0,0)

    layout:addChild(bg, 1, 1)
    bg:setPosition(layout:getContentSize().width * 0.5, layout:getContentSize().height * 0.5)
    layout:setTag(pageindex)

	layout:addTouchEventListener(handler(self,self.touchListerner))

    return layout
end

function AdvertWidget:touchListerner(sender, eventType)
	if not sender then
		return
	end
	
	if eventType==ccui.TouchEventType.ended then

		if not sender then
			return
		end

		local tagNum = sender:getTag()
		wwlog("点击Tag", tagNum)

     	local tableCell = self.adMap[tagNum]
     	self:jumpHandle(tableCell.CtrlParam)
	end
end

function AdvertWidget:runAd()

	if not next(self.adMap) then
		return
	end

	if self.targetNode then
		self.targetNode:removeAllChildren()
	end

	--直接换广告图
	if self.nextIndex > #self.adMap then
		self.nextIndex = 1
	end

	local node = self:createPage(self.nextIndex)
	self.targetNode:addChild(node)

    node:setTouchEnabled(true)
    node:setAnchorPoint(cc.p(0.5,0.5))
    node:setPosition(ww.px(204), ww.py(540))

    node:runAction(cc.Sequence:create(cc.FadeIn:create(1)))

    self.nextIndex = self.nextIndex + 1
end

function AdvertWidget:onEnter()
	--开启自动切换广告
	wwlog("AdvertWidget:onEnter()")
end

function AdvertWidget:onExit()
	wwlog("AdvertWidget:onExit()")
	if self.m_sche then
		_scheduler:unscheduleScriptEntry(self.m_sche)
	end
	self.m_sche = nil
    self:unregisterEventListener(HALL_SCENE_EVENTS.NETEVENT_ADVERTRET)
end

function AdvertWidget:onDataRet(event)
	local params = event._userdata

	local adsTable = params[1].ads
	local adsTableConts = params[1].Counts

	-- wwdump(params)

	--在默认Table后面添加广告信息
	for i,v in ipairs(adsTable) do
		local data = adsTable[i]
		local cell = {}
		cell.adID = data.adID
		cell.name = data.name --
		cell.filepath = data.picParam --
		cell.StartTime = data.StartTime --
		cell.EndTime = data.EndTime --
		cell.CtrlParam = adsTableConts[i].CtrlParam --
		table.insert(self.adMap, cell)
	end

	-- wwdump(self.adMap)

	if self.targetNode then
		self.targetNode:removeAllChildren()
	end

	if self.m_sche then
		_scheduler:unscheduleScriptEntry(self.m_sche)
	end
    self:runAd()
    self.m_sche = _scheduler:scheduleScriptFunc(handler(self, self.runAd), scheduleTime, false)
end

function AdvertWidget:jumpHandle( jumpPara )

	local UIJmperConfig = require("config.UIJmperConfig")

	local ret, argArr = JsonDecorator:decode(jumpPara)

	wwdump(argArr, "argArr解析后参数")

	if UIJmperConfig then
		local CtrlParam = jumpPara.CtrlParam
		local opendata = UIJmperConfig[tonumber(argArr.searchId)]
		dump(opendata, argArr.searchId)

		if opendata then
			self:jumpState(clone(opendata),unpack(argArr.param or {}, 1))
		end
	else
		wwlog(self.logTag,"跳转配置文件读取失败")
	end
end

--跳转至指定的状态机
--@param eventName 跳转到状态机的事件名
--@param stateName 状态机名
--@crType 几个打牌的请求类型 1 经典 2 比赛 3 私人
function AdvertWidget:jumpState(opendata,...)
	--eventName,stateName,crType,externalData

	local jumpParam = { zorder = 3,}
	opendata.param = opendata.param or {}
	if opendata.param then
		table.merge(opendata.param,jumpParam)
	end

	UIStateJumper:JumpUI(opendata,...) 
end
--直接打开界面 (非状态)
function AdvertWidget:openUI(opendata)
	FSRegistryManager:currentFSM():trigger("back")
	--display.getRunningScene():addChild(require(opendata.uipath):create(),ww.centerOrder)
	UIStateJumper:JumpUI(opendata)
end
--打开第三方app
function AdvertWidget:openAPP(opendata)
	wwlog(self.logTag,"打开第三方应用")
	UIStateJumper:JumpUI(opendata)
end

return AdvertWidget