-------------------------------------------------------------------------
-- Desc:          ¶Ò»»ÖÐÐÄ
-- Author:        Jackie Liu
-- CreateDate:    2016/10/27 18:11:50
-- Purpose:
-- Copyright (c) Jackie Liu All right reserved.
-------------------------------------------------------------------------
local UIExchangeState = class("UIExchangeState", require("packages.statebase.UIState"))
local ExchangeCfg = require("hall.mediator.cfg.ExchangeCfg")
function UIExchangeState:onLoad(lastStateName, param)
    self:init()
    UIExchangeState.super.onLoad(self, lastStateName, param)

    UmengManager:eventCount("HallExchange")
end


function UIExchangeState:init()
    -- body
    self._innerEventComponent = { }
    self._innerEventComponent.isBind = false
    self:bindInnerEventComponent()
end

function UIExchangeState:bindInnerEventComponent()
    -- body
    self:unbindInnerEventComponent()

    cc.bind(self._innerEventComponent, "event")
    self._innerEventComponent.isBind = true
    ExchangeCfg.innerEventComponent = self._innerEventComponent
end

function UIExchangeState:unbindInnerEventComponent()
    -- body
    if self._innerEventComponent.isBind then
        cc.unbind(self._innerEventComponent, "event")
        self._innerEventComponent.isBind = false
        ExchangeCfg.innerEventComponent = nil
    end
end

function UIExchangeState:onStateEnter()
    cclog("UIExchangeState onStateEnter")
    -- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())

end
function UIExchangeState:onStateExit()
    cclog("UIExchangeState onStateExit")
    self:unbindInnerEventComponent()
    -- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

return UIExchangeState