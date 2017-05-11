-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.09.15
-- Last:
-- Content:  跑马灯
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local Noticecroll = class("Noticecroll", cc.Node)
local SimpleRichText = require("app.views.uibase.SimpleRichText")

-- 滚动的消息
local msgScroll = {
    { content = string.format("合理安排时间，享受健康生活，《%s》祝您游戏愉快~",wwConst.CLIENTNAME), repeatCount = - 1 },
    -- {content = "大金空调，全场倒贴，无底线大甩卖！！！！", repeatCount = 4},
    -- {content = "你说啥？？？？！！！！", repeatCount = 4},
}

function cc.exports.addMsgScroll(content, repeatCount, msgType)
    local msg = { }
    msg.content = content
    msg.repeatCount = repeatCount or 1

    table.insert(msgScroll, msg)
end

function Noticecroll:ctor(...)
    -- body
    self:init()
end

function Noticecroll:init(...)
    -- body
    local NoticecrollBundle = require("csb.hall.noticeScroll.Noticecroll"):create()
    if not NoticecrollBundle then
        return
    end

    self.noticecrollRoot = NoticecrollBundle["root"]
    self:setPosition(cc.p(screenSize.width / 2, screenSize.height * 0.835))
    self.noticecrollRoot:addTo(self)
    self.Panel = self.noticecrollRoot:getChildByName("Panel_2")
    self.Panel:setVisible(false)
    self._scheduleHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.movePix), 0, false)
    self:detection()
    self:onNodeEvent("exit", function()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduleHandle)
    end )
end

-- 检测是否有消息播放
function Noticecroll:detection(...)
    -- body
    self.curMsg = false
    if #msgScroll > 0 then
        self.curMsg = msgScroll[1]
        if not self.Panel:isVisible() then
            self.Panel:setVisible(true)
            self.contentText = SimpleRichText:create(self.curMsg.content, 30, cc.c3b(255, 255, 255))
            self.contentText:setAnchorPoint(cc.p(0, 0.5))
            self.contentText:setPosition(cc.p(self.Panel:getContentSize().width + 20, self.Panel:getContentSize().height / 2))
            self.Panel:removeAllChildren()
            self.Panel:addChild(self.contentText)
            self.canReduction = true
        end
    end
end

function Noticecroll:movePix(...)
    -- body
    self:detection()
    if self.contentText then
        local posX = self.contentText:getPositionX()
        if (posX <=(self.Panel:getContentSize().width - self.contentText:getContentSize().width) / 2) and self.canReduction then
            self.canReduction = false
            self.curMsg.repeatCount = self.curMsg.repeatCount - 1
            if self.curMsg.repeatCount <= 0 then
                table.remove(msgScroll, 1)
            end
        elseif posX <= -(self.contentText:getContentSize().width + 20) then
            self.Panel:setVisible(false)
            self:detection()
            return
        end
        self.contentText:setPosition(cc.p(posX - 1, self.contentText:getPositionY()))
    end
end


return Noticecroll