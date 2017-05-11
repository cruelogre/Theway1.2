-------------------------------------------------------------------------
-- Desc:            排行榜
-- Author:        Jackie Liu
-- CreateDate:    2016/10/31 15:08:46
-- Purpose:
-- Copyright (c) Jackie Liu All right reserved.
-------------------------------------------------------------------------
local UIRankState = class("UIRankState", require("packages.statebase.UIState"))
local RankCfg = require("hall.mediator.cfg.RankCfg")
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end

function UIRankState:onLoad(lastStateName, param)
    self:init()
    UIRankState.super.onLoad(self, lastStateName, param)

    UmengManager:eventCount("HallRank")

end

function UIRankState:init()
    -- body
    self._innerEventComponent = { }
    self._innerEventComponent.isBind = false
    self:bindInnerEventComponent()
end

function UIRankState:bindInnerEventComponent()
    -- body
    self:unbindInnerEventComponent()

    cc.bind(self._innerEventComponent, "event")
    self._innerEventComponent.isBind = true
    RankCfg.innerEventComponent = self._innerEventComponent
end

function UIRankState:unbindInnerEventComponent()
    -- body
    if self._innerEventComponent.isBind then
        self._innerEventComponent:removeAllEventListeners()
        cc.unbind(self._innerEventComponent, "event")
        self._innerEventComponent.isBind = false
        RankCfg.innerEventComponent = nil
    end
end

function UIRankState:onStateEnter()
    cclog("UIRankState onStateEnter")

    -- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())

end
function UIRankState:onStateExit()
    cclog("UIRankState onStateExit")
    self:unbindInnerEventComponent()
    -- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

return UIRankState