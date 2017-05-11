-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal.yin
-- Date:    2016.08.13
-- Last:
-- Content:  大厅构图顶部菜单栏
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local HallTopLayer = class("HallTopLayer",
function()
    return display.newLayer()
end , require("packages.mvc.Mediator"))
local HallTopLayer_view = import(".HallTopLayer_view", "hall.mediator.view.")

local Toast = require("app.views.common.Toast")
local Node_Firstcharge = require("csb.hall.content.Node_Firstcharge")
local Node_leftTopBtn = require("csb.hall.content.Node_leftTopBtn")
-- require("hall.fsm.HallFSRegistry")
local hallFSM = FSRegistryManager:runWithFSM(FSMConfig.FSM_HALL)
local SignLayer = import(".SignLayer", "hall.mediator.view.")
local HallCfg = require("hall.mediator.cfg.HallCfg")

function HallTopLayer:ctor()
    self.logTag = "HallTopLayer.lua"
	self.handlers = {}
    self:init()

    self:registerScriptHandler( function(event)
        if event == "enter" then
            self:onEnter()
            self:registerEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, handler(self, self.refreshInfo))
        elseif event == "exit" then
            self:onExit()
            self:unregisterEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO)
        end
    end )
end

function HallTopLayer:init()

    -- 加载布局
    self.uis = UIFactory:createLayoutNode(HallTopLayer_view.UI_POS, self, pathflag)

    self:viewReflash()

    -- 绑定按钮监听函数
    self:bindBtnListener()
    self:runFirstChargeAnim()
    -- self:runAmusementAnim()
end

function HallTopLayer:onEnter()
	if self:eventComponent() then
		local _ = nil
		_,self.handlers[#self.handlers+1] = self:eventComponent():addEventListener(
		HallCfg.InnerEvents.HALL_EVENT_FIRSTCHARGE_STATE,handler(self,self.freshFirstChargeState))
	end
end
function HallTopLayer:onExit()
	if self:eventComponent() then
		for _,v in pairs(self.handlers) do
			self:eventComponent():removeEventListener(v)
		end
	end
end
--刷新首充状态
function HallTopLayer:freshFirstChargeState(event)
	if event.name == HallCfg.InnerEvents.HALL_EVENT_FIRSTCHARGE_STATE then
		if event._userdata and isLuaNodeValid(self.firstChargeNode) then
			self.firstChargeNode:setVisible(tonumber(event._userdata.kResult)==0)
		end
	end
end
-- 播放首充按钮动画
function HallTopLayer:runFirstChargeAnim()

    local chargeBundle = Node_Firstcharge:create()
    local node = chargeBundle.root
    node:getChildByName("Button_charge"):addClickEventListener(handler(self, self.firstChargeHandler))
    node:runAction(chargeBundle.animation)
    chargeBundle.animation:play("animation0", true)
    self.uis["btn_hall_firstcharge"]:getParent():addChild(node)
    node:setPosition(cc.p(self.uis["btn_hall_firstcharge"]:getPositionX(), self.uis["btn_hall_firstcharge"]:getPositionY()))
    node:setLocalZOrder(self.uis["btn_hall_firstcharge"]:getLocalZOrder())
    self.uis["btn_hall_firstcharge"]:removeFromParent()
	self.firstChargeNode = node
	self.firstChargeNode:setVisible(false)
end

-- 播放娱乐场按钮动画
function HallTopLayer:runAmusementAnim()

    local amusementBundle = Node_leftTopBtn:create()
    local node = amusementBundle.root
    node:setScale(0.8)
    node:getChildByName("Button_fStart"):addClickEventListener(handler(self, self.amusementHandler))
    local img = node:getChildByName("Button_fStart"):getChildByName("Image_7")
    img:ignoreContentAdaptWithSize(true)
    img:loadTexture("hall_amusement_label.png", 1)
    node:runAction(amusementBundle.animation)
    amusementBundle.animation:play("animation1", true)
    self.uis["btn_hall_amusement"]:getParent():addChild(node)
    node:setPosition(cc.p(self.uis["btn_hall_amusement"]:getPositionX(), self.uis["btn_hall_amusement"]:getPositionY()))
    node:setLocalZOrder(self.uis["btn_hall_amusement"]:getLocalZOrder())
    self.uis["btn_hall_amusement"]:removeFromParent()
    self.uis["sp_hall_amusement_label"]:removeFromParent()

end

function HallTopLayer:viewReflash()
    -- 矫正顶部标题位置
    self.uis["sp_hall_title_bg"]:setPositionY(display.top - self.uis["sp_hall_title_bg"]:getContentSize().height * 0.5)
    self.uis["sp_hall_title_name"]:setPositionY(self.uis["sp_hall_title_bg"]:getPositionY())
end

-- 红点配置
local _redpoint_config =
{
    -- 更新红点代码：WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "set", true)
    -- 上面的shop就是converter的key值set，true显示红点，false取消红点。
    converter =
    {
        set = "btn_hall_set",
        mail = "btn_hall_mail",
        sign = "btn_hall_sign",
        firstcharge = "btn_hall_firstcharge",
		cardPartner = "btn_hall_amusement",
    },
    -- 有些红点需要作微调，
    offset =
    {
        mail = nil,
    }
}
function HallTopLayer:refreshInfo(event)
    local params = event._userdata
    local handleType = params[1]
    if handleType == 2 then
        -- 红点通知
        local flag, isShow = _redpoint_config.converter[params[2]], params[3]
        if flag then
            local target, redPoint = self.uis[flag], self.uis[flag]._redPoint
            if target then
                if isShow and(not redPoint) then
                    -- 显示红点
                    target._redPoint = display.newSprite("common/red_point.png"):addTo(target):setPosition(target:width()*0.80, target:height()*0.65)
                    if _redpoint_config.offset[params[2]] then
                        target._redPoint:offset(unpack(_redpoint_config.offset[params[2]]))
                    end
                elseif (not isShow) and redPoint then
                    -- 取消红点
                    target._redPoint:removeFromParent()
                    target._redPoint = nil
                end
            else
                wwlog(self.logTag, "invalid red_point_flag::%s", flag or "")
            end
        end
    end
end

function HallTopLayer:bindBtnListener()

    -- 控件key及函数对应表
    local itemKeys = {
        ["btn_hall_set"] = handler(self,self.setHandler),
        ["btn_hall_mail"] = handler(self,self.mailHandler),
        ["btn_hall_sign"] = handler(self,self.signHandler),
        ["btn_hall_firstcharge"] = handler(self,self.firstChargeHandler),
        ["btn_hall_amusement"] = handler(self, self.amusementHandler), --牌友
        ["btn_hall_bag"] = handler(self, self.bagHandler), --背包
    }

    for k, v in pairs(itemKeys) do
        local btn = self.uis[k]
        btn:addTouchEventListener( function(sender, event)
            if event == ccui.TouchEventType.ended then
                v(self,sender,event)
            end
        end )
    end

end

function HallTopLayer:setHandler(view,sender,event)
    wwlog(self.logTag, "进入设置界面")
    playSoundEffect("sound/effect/anniu")
    hallFSM:trigger("setting",
    { parentNode = display.getRunningScene(), zorder = 4 , redPoint = (sender._redPoint ~=nil) })
end

function HallTopLayer:mailHandler()
    wwlog(self.logTag, "进入邮箱界面")
    playSoundEffect("sound/effect/anniu")
    hallFSM:trigger("email",
    { parentNode = display.getRunningScene(), zorder = 4 })
end

function HallTopLayer:signHandler()
    wwlog(self.logTag, "进入签到界面")
    playSoundEffect("sound/effect/anniu")
    hallFSM:trigger("sign",
    { parentNode = display.getRunningScene(), zorder = 4 })
end

function HallTopLayer:firstChargeHandler()
    wwlog(self.logTag, "进入首充界面")
    playSoundEffect("sound/effect/anniu")
	hallFSM:trigger("fcharge",
    { parentNode = display.getRunningScene(), zorder = 4 })
end

function HallTopLayer:amusementHandler()
	wwlog(self.logTag, "进入娱乐场界面")
	playSoundEffect("sound/effect/anniu")
    hallFSM:trigger("cardPartner", { parentNode = display.getRunningScene(), zorder = 4 })
end

function HallTopLayer:bagHandler()
    wwlog(self.logTag, "进入背包界面")
    playSoundEffect("sound/effect/anniu")
    hallFSM:trigger("goodsBox", { parentNode = display.getRunningScene(), zorder = 4 })
end

function HallTopLayer:eventComponent()
	return HallCfg.innerEventComponent
end

return HallTopLayer