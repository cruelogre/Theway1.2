-------------------------------------------------------------------------
-- Desc:
-- Author:        Jackie Liu
-- CreateDate:    2016/10/31 15:08:46
-- Purpose:       purpose
-- Copyright (c) Jackie Liu All right reserved.
-------------------------------------------------------------------------
local UISiRenRoomState = class("UISiRenRoomState", require("packages.statebase.UIState"))
local SiRenRoomCfg = require("hall.mediator.cfg.SiRenRoomCfg")
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end

function UISiRenRoomState:onLoad(lastStateName, param)
    self:init()
    UISiRenRoomState.super.onLoad(self, lastStateName, param)

    local Image_bg = ccui.ImageView:create()
    -- Image_bg:ignoreContentAdaptWithSize(false)
    Image_bg:loadTexture("hall/hallbg.jpg", 0):addTo(self.rootNode):setTouchEnabled(true):setName("Image_bg")
    :setCascadeColorEnabled(true):setCascadeOpacityEnabled(true):setPosition(display.center)
    Image_bg:setScaleY(ww.scaleY)
    
    local bgMask = display.newSprite("hall/choose/chooserm_bg_mak.png", display.cx, display.cy, { capInsets = { x = 768, y = 475, width = 403, height = 249 } })
    :setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)):addTo(self.rootNode)
    FixUIUtils.stretchUI(bgMask)
    FixUIUtils.setRootNodewithFIXED(bgMask)

    local topLayer = import(".ChooseRoomLayer_widget_Top", "hall.mediator.view.widget."):create(3):addTo(self.rootNode, self.localZorder+1)
    topLayer:setPosition(cc.p(display.cx, display.top - topLayer:getContentSize().height / 2))
    topLayer:playButtonAnim()
    print("----------display.top------------", display.top)

    import(".HallBottomLayer", "hall.mediator.view."):create():addTo(self.rootNode, self.localZorder+1)

    local panelbg = topLayer:getChildByName("Node"):getChildByName("Panel_bg")
    local title = ccui.Helper:seekWidgetByName(panelbg, "Image_title")
    if title and title ~= panelbg then
        title:ignoreContentAdaptWithSize(true)
        title:setVisible(false)
        display.newSprite("hall/siren/title_siren.png"):addTo(title:getParent()):pos(title:pos())
    end
    local fStart = panelbg:getChildByName("FileNode_fStart")
    if fStart and fStart ~= panelbg then
        fStart:setVisible(false)
        local _broadcastHandles = { }
        local btnHistory = display.newSprite("hall/siren/siren_btn_history.png"):addTo(fStart:getParent()):pos(fStart:pos()):offsetY(20)
        btnHistory:enableClick( function()
            playSoundEffect("sound/effect/anniu")
            local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SiRenRoomProxy)
            local request = require("hall.request.SiRenRoomRequest")
            request.history(proxy)
        end )
        -- 创建房间
        local _, handle = SiRenRoomCfg.innerEventComponent:addEventListener(SiRenRoomCfg.InnerEvents.SIREN_ROOM_HISTORY, function(event)
            local historyInfo = event._userdata
            if #historyInfo > 0 then
                require("hall.mediator.view.widget.siren.SiRen_history"):create(self.rootNode, historyInfo):addTo(self.rootNode, param.zorder+1)
            else
                -- 记录为空
                require("hall.mediator.view.widget.siren.SiRen_no_history"):create(self.rootNode):addTo(self.rootNode, param.zorder+1)
            end
        end )
    end

    UmengManager:eventCount("HallSiren")
end

function UISiRenRoomState:init()
    -- body
    self._innerEventComponent = { }
    self._innerEventComponent.isBind = false
    self:bindInnerEventComponent()
end

function UISiRenRoomState:bindInnerEventComponent()
    -- body
    self:unbindInnerEventComponent()

    cc.bind(self._innerEventComponent, "event")
    self._innerEventComponent.isBind = true
    SiRenRoomCfg.innerEventComponent = self._innerEventComponent
end

function UISiRenRoomState:unbindInnerEventComponent()
    -- body
    if self._innerEventComponent.isBind then
        self._innerEventComponent:removeAllEventListeners()
        cc.unbind(self._innerEventComponent, "event")
        self._innerEventComponent.isBind = false
        SiRenRoomCfg.innerEventComponent = nil
    end
end

function UISiRenRoomState:onStateEnter()
    cclog("UISiRenRoomState onStateEnter")

    -- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())

end
function UISiRenRoomState:onStateExit()
    cclog("UISiRenRoomState onStateExit")
    self:unbindInnerEventComponent()
    -- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

return UISiRenRoomState