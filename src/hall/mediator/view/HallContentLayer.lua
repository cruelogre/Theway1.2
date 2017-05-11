-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal.yin
-- Date:    2016.08.15
-- Last: 
-- Content:  大厅中心内容构图
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local HallContentLayer = class("HallContentLayer",
    function()
        return display.newLayer()
    end)
local HallContentLayer_view = import(".HallContentLayer_view", "hall.mediator.view.")

local Toast = require("app.views.common.Toast")

local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
--require("hall.fsm.HallFSRegistry")
local hallFSM = FSRegistryManager:runWithFSM(FSMConfig.FSM_HALL)
local Node_high = require("csb.hall.content.Node_high")
function HallContentLayer:ctor()
	self.logTag = "HallContentLayer.lua"
	self:init()
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
end

function HallContentLayer:createNode(parentNode,nodeLayer,order,pos,animationName)
	if not isLuaNodeValid(parentNode) then
		wwlog(self.logTag,"创建失败，父节点非法"..tostring(nodeLayer))
		return nil
	end
	local nodeBundle = require(nodeLayer):create()
	local node  = nodeBundle.root
	local animation = nodeBundle.animation
	parentNode:addChild(node,order or 0)
	node:setPosition(pos)
	node:runAction(animation)
	animation:play(animationName,true)
	return node
end

function HallContentLayer:seekNodeByName(node,name)
	if not isLuaNodeValid(node) then
		return nil
	end
	if node:getName()==name then
		return node
	end
	for idx, child in pairs(node:getChildren()) do
		
		local res = self:seekNodeByName(child,name)
		if isLuaNodeValid(res) then
			return res
		end
	end

end
function HallContentLayer:init()
	self.uis = {}
	-- --加载布局
	--self.uis = UIFactory:createLayoutNode(HallContentLayer_view.UI_POS,self,pathflag)
	self.uis["btn_hall_normal"] = self:createNode(self,"csb.hall.content.Node_Guandan",2,cc.p(ww.px(666),ww.py(540)),"animation0")
	self.uis["btn_hall_bullfight"] = self:createNode(self,"csb.hall.content.Node_Niuniu",2,cc.p(ww.px(1146),ww.py(540)),"animation0")
	self.uis["btn_hall_high"] = self:createNode(self,"csb.hall.content.Node_Prize",2,cc.p(ww.px(1634),ww.py(665)),"animation0")
	self.uis["btn_hall_personal"] = self:createNode(self,"csb.hall.content.Node_Privicy",2,cc.p(ww.px(1634),ww.py(402)),"animation0")
	
	-- --绑定按钮监听函数
	self:bindBtnListener()

	--广告
	local adview = import(".AdvertWidget", "hall.mediator.view.widget."):create()
	self:addChild(adview)
	
	self:showAction(self:seekNodeByName(self.uis["btn_hall_normal"],"hall_room_title"),
			"#hall_room_guandan_title.png","#title_light_img_eff.png")
	self:showAction(self:seekNodeByName(self.uis["btn_hall_bullfight"],"hall_room_title"),
			"#hall_room_niuniu_title.png","#title_light_img_eff.png")
	-- --动态效果
	-- self.uis["room_hall_high_bg_bg1"]:setBlendFunc({src = 1, dst = 1})
	-- self.uis["room_hall_high_bg_bg2"]:setBlendFunc({src = 1, dst = 1})
	-- self.uis["room_hall_high_bg_bg1"]:runAction(
	-- 	cc.RepeatForever:create(cc.RotateBy:create(5, 360) ))  
	-- self.uis["room_hall_high_bg_bg2"]:runAction(
	-- 	cc.RepeatForever:create(cc.RotateBy:create(5, 360) )) 
end

--播放比赛按钮动画
function HallContentLayer:showAction(sprite,plistName,sparkPlist)
	-- 1.创建模板、ClippingNode(裁剪节点)

	local parent = sprite:getParent()
	local oldPosX,oldPosY = sprite:getPosition()
    local clipper = cc.ClippingNode:create()
	--stencil:setPosition(cc.p(oldPosX,oldPosX))
	local stencil = display.newSprite(plistName)
    clipper:setStencil(stencil)
    --clipper:setInverted(true)
    clipper:setAlphaThreshold(0)

    -- 2.标题和光效
    local spr_title = sprite

    local spark = display.newSprite(sparkPlist)
	

	spark:setBlendFunc({src = 1, dst = 1})
	local sz = spr_title:getContentSize()
	
	local mSize =  stencil:getContentSize()
	--spr_title:removeFromParentAndCleanup(false)
    --clipper:addChild(spr_title)


	spark:setPosition(cc.p(-sz.width,0))
    clipper:addChild(spark)

    clipper:setPosition(cc.p(oldPosX,oldPosY))
    parent:addChild(clipper,10)
	--self.uis["btn_hall_high"]:removeFromParent()
	
    -- 3.光效移动、自动裁剪
 
	local frameRate = 25.0
    local move = cc.MoveTo:create(60.0/frameRate, cc.p(sz.width, 0))
    local delay1 = cc.DelayTime:create(40.0/frameRate)
	local setPs = cc.CallFunc:create(function ()
		spark:setPosition(cc.p(-sz.width,0))
	end)
    local seq = cc.Sequence:create( move,delay1, setPs)
    local repeatAction = cc.RepeatForever:create(seq)
    spark:runAction(repeatAction)

end

function HallContentLayer:onEnter()
	self:refreshContent(1)
	self:refreshContent(2) --掼蛋
	self:refreshContent(3)

	--拉取大厅数据
	HallSceneProxy:getHallDatas()

	if self:getEventComponent() ~=nil then
		local _,handle4 = self:getEventComponent():addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINOK,
		handler(self,self.networkEvent))
		self.handle = handle4
	end
	
end


function HallContentLayer:onExit()
	
	if self:getEventComponent() then
		self:getEventComponent():removeEventListener(self.handle)
	end
	
end
function HallContentLayer:networkEvent(event)
    if event.name == NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINOK then
        -- 登录成功

        HallSceneProxy:getHallDatas()
    end
end
function HallContentLayer:getEventComponent()
    return NetWorkCfg.innerEventComponent
end

function HallContentLayer:refreshContent(param)
	local hallTable = DataCenter:getData(HALL_SCENE_EVENTS.NETEVENT_RECHALLLIST)
	if not hallTable or not next(hallTable) then
		return
	end
	if not hallTable[param] or not next(hallTable[param]) then
		return
	end

	wwdump(hallTable, "大厅数据"..param)

	local freshText = nil
	-- if param == 2 then
	-- 	freshText = self:seekNodeByName(self.uis["btn_hall_normal"],"Text_count")
	-- elseif param == 1 then
	-- 	freshText = self:seekNodeByName(self.uis["btn_hall_high"],"Text_count")
	-- elseif param == 3 then
	-- 	freshText = self:seekNodeByName(self.uis["btn_hall_personal"],"Text_count")
	-- end

	local gameidTable = wwConfigData.GAMELOGICPARA
	local value = hallTable[param].number

	if param == gameidTable.GUANDAN.GAME_ID.."_1" then --掼蛋比赛
		freshText = self:seekNodeByName(self.uis["btn_hall_high"],"Text_count")
	elseif param == gameidTable.GUANDAN.GAME_ID.."_2" then --掼蛋经典
		freshText = self:seekNodeByName(self.uis["btn_hall_normal"],"Text_count")
	elseif param == gameidTable.GUANDAN.GAME_ID.."_3" then --私人房
		freshText = self:seekNodeByName(self.uis["btn_hall_personal"],"Text_count")
	elseif param == gameidTable.BULLFIGHT.GAME_ID.."_2" then --斗牛经典
		freshText = self:seekNodeByName(self.uis["btn_hall_bullfight"],"Text_count")
	end

	if freshText then
		freshText:setString(tonumber(value)..i18n:get('str_hall','hall_people_count'))
		freshText:setFontName("FZZhengHeiS-B-GB.ttf")
	end	

end
function HallContentLayer:bindBtnListener()

    -- 控件key及函数对应表
    local itemKeys = {
        -- 高手房
		["btn_hall_high"] = {"Image_prize",handler(self,self.hignHandler)},
        -- 经典        
        ["btn_hall_normal"] = {"Button_guandan",handler(self,self.normalHandler)},
        ["btn_hall_personal"] = {"Image_privicy",handler(self,self.personalHandler)},-- 私人定制
        ["btn_hall_bullfight"] = {"Button_niuniu",handler(self,self.bullFightHandler)},-- 斗牛
    }

    for k, v in pairs(itemKeys) do
        local btn = self:seekNodeByName(self.uis[k],v[1])
        if btn then
            btn:addTouchEventListener( function(sender, event)
                if event == ccui.TouchEventType.ended then
                    v[2](self)
                end
            end )
        end
    end

end

function HallContentLayer:adHandler()
    wwlog(self.logTag, "点击广告")

end

function HallContentLayer:hignHandler()
    wwlog(self.logTag, "点击高手房")
    playSoundEffect("sound/effect/anniu")
    hallFSM:trigger("match",
    { parentNode = display.getRunningScene(), zorder = 3, crType = 1 })
end

function HallContentLayer:normalHandler()
    wwlog(self.logTag, "点击经典房")
    playSoundEffect("sound/effect/anniu")
    hallFSM:trigger("chooseRoom",
    { parentNode = display.getRunningScene(), zorder = 3, crType = 2 , gameid=wwConfigData.GAME_ID})
end

function HallContentLayer:personalHandler()
    wwlog(self.logTag, "点击私人房")
    playSoundEffect("sound/effect/anniu")
    hallFSM:trigger("siren", { parentNode = display.getRunningScene(), zorder = 3, crType = 3 })
end

function HallContentLayer:bullFightHandler()
    wwlog(self.logTag, "点击牛牛")
    playSoundEffect("sound/effect/anniu")
    
    -- Toast:makeToast(i18n:get("str_hall", "hall_waiting"), 1.0):show()
	require("BullFighting.event.BullFightingEvent")
	-- WWFacade:dispatchCustomEvent(BULLFIGHTING_SCENE_EVENTS.MAIN_ENTRY)  
	hallFSM:trigger("chooseRoom",
	{ parentNode = display.getRunningScene(), zorder = 3, crType = 2 
	, gameid=wwConfigData.GAMELOGICPARA.BULLFIGHT.GAME_ID
	, playType = wwConfigData.GAMELOGICPARA.BULLFIGHT.PLAYTYPE})  
end

return HallContentLayer