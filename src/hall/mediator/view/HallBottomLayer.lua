-------------------------------------------------------------------------
-- Desc:
-- Author:  diyal.yin
-- Date:    2016.08.13
-- Last:
-- Content:  大厅底部
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local HallBottomLayer = class("HallBottomLayer",
function()
    return display.newLayer()
end ,
require("packages.mvc.Mediator")
)
local HallBottomLayer_view = import(".HallBottomLayer_view", "hall.mediator.view.")

local Toast = require("app.views.common.Toast")

local hallFSM = FSRegistryManager:runWithFSM(FSMConfig.FSM_HALL)

local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local LuaNativeBridge = require("app.utilities.LuaNativeBridge")
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

function HallBottomLayer:ctor()
    self.logTag = "HallBottomLayer.lua"
    self:init()

    self:registerScriptHandler( function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end )
end

function HallBottomLayer:onEnter()
    self:registerEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, handler(self, self.refreshInfo))
end


function HallBottomLayer:onExit()
    self:unregisterEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO)
end

function HallBottomLayer:init()

    -- 加载布局
    self.uis = UIFactory:createLayoutNode(HallBottomLayer_view.UI_POS, self, pathflag)

    -- 绑定按钮监听
    self:bindBtnListener()

    -- 设置值
    self:valueHandle()

    -- local iconFile = DataCenter:getUserdataInstance():getHeadIcon()
    -- local param = {
    -- 	headFile=iconFile,
    -- 	maskFile="#hall_bottom_role.png",
    -- 	headType=1,
    -- 	radius=87.5,
    -- 	-- headIconType = ww.WWGameData:getInstance():getIntegerForKey("IconID",0),
    -- 	-- userID = ww.WWGameData:getInstance():getIntegerForKey("userid",0)
    -- }

    -- local sp = WWHeadSprite:create(param)
    -- sp:setPosition(self.uis["btn_hall_bottom_role"]:getContentSize().width * 0.5,
    -- 	self.uis["btn_hall_bottom_role"]:getContentSize().height * 0.5)
    -- self.uis["btn_hall_bottom_role"]:addChild(sp,100,1)
end

--确认隐私政策
function HallBottomLayer:AppConfirm(callback)

    local isConfirm = ww.WWGameData:getInstance():getStringForKey("YSZH_ORM_RANK_KEY", "")

    wwlog(self.logTag, isConfirm)

    if isConfirm == "" then
        --隐私政策
        if (cc.PLATFORM_OS_IPHONE == targetPlatform) 
        or ((cc.PLATFORM_OS_IPAD == targetPlatform))
        or ((cc.PLATFORM_OS_MAC == targetPlatform)) then
            local yszcStr = require("res.config.PrivacyPolicy")
            
            LuaNativeBridge:showAlterViewWithText(i18n:get("str_setting", "setting_privicy"), yszcStr.getYSZC())

            local function eventCustomListener1(event)
                wwlog(self.logTag, "用户同意")
                ww.WWGameData:getInstance():setStringForKey("YSZH_ORM_RANK_KEY", "true")
                callback()     
            end

            local function eventCustomListener2(event)
                wwlog(self.logTag, "用户取消")

                if self.listener1 and eventDispatcher then
                    eventDispatcher:removeEventListener(self.listener1)
                    self.listener1 = nil
                end
                if self.listener2 and eventDispatcher then
                    eventDispatcher:removeEventListener(self.listener2)
                    self.listener2 = nil
                end
            end
            self.listener1 = cc.EventListenerCustom:create(COMMON_EVENTS.G_EVENT_YSZC_SUCCESS, eventCustomListener1)
            self.listener2 = cc.EventListenerCustom:create(COMMON_EVENTS.G_EVENT_YSZC_EXIT, eventCustomListener2)
            eventDispatcher:addEventListenerWithFixedPriority(self.listener1, 1)
            eventDispatcher:addEventListenerWithFixedPriority(self.listener2, 1)
        end
    else
        callback()     
    end
end

function HallBottomLayer:bindBtnListener()

    -- 控件key及函数对应表
    local itemKeys = {
        -- 金币
        ["btn_hall_gold"] = handler(self,self.goldHandler),
        -- 钻石
        ["btn_hall_diamond"] = handler(self,self.diamondHandler),
        -- 商店
        ["btn_hall_shop"] = handler(self,self.shopHandler),
        -- 活动
        ["btn_hall_activity"] = handler(self,self.activityHandler),
        -- 任务
        ["btn_hall_task"] = handler(self,self.taskHandler),
        -- 兑换
        ["btn_hall_exchange"] = handler(self,self.exchangeHandler),
        -- 排行
        ["btn_hall_rank"] = handler(self,self.rankHandler),
        ["btn_hall_bottom_role"] = handler(self,self.headHandler)-- 个人信息
    }

    for k, v in pairs(itemKeys) do
        local btn = self.uis[k]
        btn:addTouchEventListener( function(sender, event)
            if event == ccui.TouchEventType.ended then
                v(self)
            end
        end )
    end

end

function HallBottomLayer:valueHandle()
    wwlog(self.logTag, "设置个人信息")

    local gGoldNum, gDiamondNum
    local goldstr = DataCenter:getUserdataInstance():getValueByKey("GameCash") or "0"
    local diamondstr = DataCenter:getUserdataInstance():getValueByKey("Diamond") or "0"
    wwlog(self.logTag, "大厅底部金币 %s ", goldstr)
    gGoldNum = ToolCom.splitNumFix(tonumber(goldstr))
    wwlog(self.logTag, "大厅底部金币 %s ", gGoldNum)
    gDiamondNum = ToolCom.splitNumFix(tonumber(diamondstr))


    -- 用户名称
    self.uis["txt_username"]:setString(DataCenter:getUserdataInstance():getValueByKey("nickname") or "")

    -- wwlog("setGameCash", DataCenter:getUserdataInstance():getValueByKey("GameCash"))
    -- 金币
    self.uis["txt_gold"]:setString(gGoldNum)
    self.uis["txt_gold"]:setFontName("FZZhengHeiS-B-GB.ttf")

    -- 钻石
    self.uis["txt_diamond"]:setString(gDiamondNum)
    self.uis["txt_diamond"]:setFontName("FZZhengHeiS-B-GB.ttf")

    self.uis["txt_username"]:setString(DataCenter:getUserdataInstance():getValueByKey("nickname"))
    -- self.uis["txt_username"]:setFontName("FZZhengHeiS-B-GB.ttf")

    if self.uis["btn_hall_bottom_role"]:getChildByTag(1) then
        self.uis["btn_hall_bottom_role"]:getChildByTag(1):removeFromParent()
    end

    if self.uis["btn_hall_bottom_role"]:getChildByTag(1) then
        self.uis["btn_hall_bottom_role"]:getChildByTag(1):removeFromParent()
        wwdump(param, "大厅旧头像删除")
    end

    local iconFile = DataCenter:getUserdataInstance():getHeadIcon()
    local param = {
        headFile = iconFile,
        maskFile = "guandan/head_mask.png",
        frameFile = "common/common_userheader_frame_hall.png",
        headType = 1,
        radius = 87.5 - 7,
        headIconType = DataCenter:getUserdataInstance():getValueByKey("IconID"),
        userID = DataCenter:getUserdataInstance():getValueByKey("userid")
    }

    wwdump(param, "大厅头像显示参数")

    local sp = WWHeadSprite:create(param)
    sp:setPosition(self.uis["btn_hall_bottom_role"]:getContentSize().width * 0.5,
    self.uis["btn_hall_bottom_role"]:getContentSize().height * 0.5)
    self.uis["btn_hall_bottom_role"]:addChild(sp, 100, 1)


end

-- 红点配置
local _redpoint_config =
{
    -- 更新红点代码：WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "shop", true)
    -- 上面的shop就是converter的key值shop，true显示红点，false取消红点。
    converter =
    {
        shop = "btn_hall_shop",
        act = "btn_hall_activity",
        task = "btn_hall_task",
        exchange = "btn_hall_exchange",
        rank = "btn_hall_rank",
        role = "btn_hall_bottom_role"
    },
    -- 有些红点需要作微调，nil就不需要
    offset =
    {
        shop = nil,
        act = nil,
        task = nil,
        exchange = nil,
        rank = nil,
        role = nil
    }
}
--[[
handleType 为消息处理类型
--]]
function HallBottomLayer:refreshInfo(event)
    local params = event._userdata
    local handleType = params[1]
    if handleType == 1 then
        -- 刷新个人信息区域
        wwlog(self.logTag, "更新HallBottomLayer信息")
        self:valueHandle()
    elseif handleType == 2 then
        -- 红点通知z
        local flag, isShow = _redpoint_config.converter[params[2]], params[3]
        if flag then
            local target, redPoint = self.uis[flag], self.uis[flag]._redPoint
            if target then
                if isShow and(not redPoint) then
                    -- 显示红点
                    target._redPoint = display.newSprite("common/red_point.png"):addTo(target):setPosition(target:width() * 0.80, target:height() * 0.85)
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

function HallBottomLayer:shopHandler()
    wwlog(self.logTag, "进入商城界面")
    playSoundEffect("sound/effect/anniu")

    hallFSM:trigger("store",
    { parentNode = display.getRunningScene(), zorder = 4 })
    -- { parentNode = display.getRunningScene(), zorder = 4, sceneIDKey = "Shop" })

end

function HallBottomLayer:activityHandler()
    wwlog(self.logTag, "进入活动界面")
    playSoundEffect("sound/effect/anniu")
    -- Toast:makeToast(i18n:get("str_hall", "hall_waiting"), 1.0):show()
    hallFSM:trigger("activity", { parentNode = display.getRunningScene(), zorder = 4, openType = 1 })
end

function HallBottomLayer:taskHandler()
    wwlog(self.logTag, "进入任务界面")
    playSoundEffect("sound/effect/anniu")
    -- Toast:makeToast(i18n:get("str_hall", "hall_waiting"), 1.0):show()
    hallFSM:trigger("task", { parentNode = display.getRunningScene(), zorder = 4, openType = 2 })
end

function HallBottomLayer:exchangeHandler()
    wwlog(self.logTag, "进入兑换界面")
    playSoundEffect("sound/effect/anniu")
    hallFSM:trigger("exchange", { parentNode = display.getRunningScene(), zorder = 4 })
end

function HallBottomLayer:rankHandler()
    wwlog(self.logTag, "进入排行榜界面666666")
    local function callback( ... )
        playSoundEffect("sound/effect/anniu")
        hallFSM:trigger("rank", { parentNode = display.getRunningScene(), zorder = 4 })
    end

    if (cc.PLATFORM_OS_IPHONE == targetPlatform) 
    or ((cc.PLATFORM_OS_IPAD == targetPlatform))
    or ((cc.PLATFORM_OS_MAC == targetPlatform)) then
        self:AppConfirm(callback)
    else
        callback()
    end
end

function HallBottomLayer:headHandler()
    wwlog(self.logTag, "点击头像")
    playSoundEffect("sound/effect/anniu")
    hallFSM:trigger("userinfo",
    { parentNode = display.getRunningScene(), zorder = 4 })
end

function HallBottomLayer:goldHandler()
    wwlog(self.logTag, "点击金币")
    playSoundEffect("sound/effect/anniu")
    hallFSM:trigger("store",
    { parentNode = display.getRunningScene(), zorder = 4, store_openType = 2, sceneIDKey = "Hall" })
end

function HallBottomLayer:diamondHandler()
    wwlog(self.logTag, "点击钻石")
    playSoundEffect("sound/effect/anniu")
    hallFSM:trigger("store",
    { parentNode = display.getRunningScene(), zorder = 4, store_openType = 1, sceneIDKey = "Hall" })
end

return HallBottomLayer