-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.09.15
-- Last:
-- Content:  邮件模块
-- ！！！！！这里有个遗留了一个问题：
-- 领取奖励只刷新了金币和钻石，其他并没有刷新，
-- 后面注意要加上其他物品的同步
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local EmailLayer = class("EmailLayer", require("app.views.uibase.PopWindowBase"))

local MessageProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MessageProxy)

local EmailCfg = require("hall.mediator.cfg.EmailCfg")
local Toast = require("app.views.common.Toast")

local labelConf = {
    style1 = { fontFilePath = "FZZhengHeiS-B-GB.ttf", fontSize = 30, glyphs = "CUSTOM" },
}

function EmailLayer:ctor(...)
    -- body
    -- 消息箱数据，在每个元素中添加了两个字段。“isGetReward”有奖励领取消息的状态保存，“old”消息是否已读取标记保存
    self.emailDatas = nil
    self.super.ctor(self)
    self:init()
    self.logTag = "EmailLayer.lua"
end

function EmailLayer:init(...)
    -- body
    local emailLayerBundle = require("csb.hall.email.EmailLayer"):create()
    if not emailLayerBundle then
        return
    end

    -- 注释为了消除bug:消息列表数量显示52条，改为：显示40条，默认删除最早时间的消息
    --    MessageProxy:requestMessageInfo(1, "", 0, 0)
    MessageProxy:requestMessageInfo(2, "", 1, 40)

    local root = emailLayerBundle["root"]
    root:addTo(self)
    FixUIUtils.setRootNodewithFIXED(root)

    self.imgId = root:getChildByName("Image_17")
    FixUIUtils.stretchUI(self.imgId)

    self.listView = ccui.Helper:seekWidgetByName(self.imgId, "ListView")
    self.listView:setBounceEnabled(true)
    self.textCount = ccui.Helper:seekWidgetByName(self.imgId, "Text_21")
    self.imgNew = ccui.Helper:seekWidgetByName(self.imgId, "Image_20"):setVisible(false)

    self:popIn(self.imgId, Pop_Dir.Right)
    self:setDisCallback( function(...)
        -- body
        -- self:unRegisterListener()
        FSRegistryManager:runWithFSM(FSMConfig.FSM_HALL):trigger("back")
    end )

    -- 邮件节点
    local emailItem = require("csb.hall.email.EmailItem"):create()
    if not emailItem then
        return
    end
    local rootEmailItem = emailItem["root"]
    self.EmailItemNode = rootEmailItem:getChildByName("ImageD")
    self:addChild(rootEmailItem)
    rootEmailItem:setVisible(false)

    -- 查看邮件不带附件节点
    local EmailItemOpen = require("csb.hall.email.EmailItemOpen"):create()
    if not EmailItemOpen then
        return
    end
    local rootEmailItemOpen = EmailItemOpen["root"]
    self.EmailItemOpenNode = rootEmailItemOpen:getChildByName("ImageD")
    self:addChild(rootEmailItemOpen)
    rootEmailItemOpen:setVisible(false)

    -- 查看邮件带附件节点
    local EmailItemOpenFuJian = require("csb.hall.email.EmailItemOpenFuJian"):create()
    if not EmailItemOpenFuJian then
        return
    end
    local rootEmailItemOpenFuJian = EmailItemOpenFuJian["root"]
    self.EmailItemOpenFuJianNode = rootEmailItemOpenFuJian:getChildByName("ImageD")
    self:addChild(rootEmailItemOpenFuJian)
    rootEmailItemOpenFuJian:setVisible(false)


    self.txtMsgBoxTitle = ccui.Helper:seekWidgetByName(self.imgId, "Text_13")

    self.lastSelectIdx = -1
    self.curSelectIdx = -1

    self:registerListener()
end

function EmailLayer:registerListener()
    EmailCfg.innerEventComponent:addEventListener(EmailCfg.InnerEvents.MESSAGE_EVENT_REQMSGLIST, handler(self, self.handleProxy))
    -- 处理消息附件（马上领取奖励）响应
    EmailCfg.innerEventComponent:addEventListener(EmailCfg.InnerEvents.MESSAGE_EVENT_HANDLE_MSG_ATTACHMENT, handler(self, self.handleProxy))
    -- 消息箱新消息数量
    EmailCfg.innerEventComponent:addEventListener(EmailCfg.InnerEvents.MESSAGE_EVENT_NUM_NEW_MSG, handler(self, self.handleProxy))
end

function EmailLayer:handleProxy(event)
    if event.name == EmailCfg.InnerEvents.MESSAGE_EVENT_REQMSGLIST then
        -- 收到消息列表 刷新数据
        local datas = DataCenter:getData(EmailCfg.InnerEvents.MESSAGE_EVENT_REQMSGLIST)
        self:addItem(datas)
        -- 更新消息数量
        self.textCount._totalMsgNum, self.textCount._newMsgNum = #datas.messages, #datas.messages
        -- 未读消息数量
        self:_updateMsgNum()
    elseif event.name == EmailCfg.InnerEvents.MESSAGE_EVENT_HANDLE_MSG_ATTACHMENT then
        local datas = DataCenter:getData(EmailCfg.InnerEvents.MESSAGE_EVENT_HANDLE_MSG_ATTACHMENT)
        if datas.isSucc then
            -- 成功。操作消息附件(马上领取奖励)
            Toast:makeToast(i18n:get("str_mail", "operate_attach_succ"), 2.0):show()
            self.textCount._newMsgNum = self.textCount._newMsgNum - 1
            self:_updateMsgNum()
            for k, v in ipairs(self.emailDatas) do
                if v.MsgID == datas.msgID then
                    -- 领取后的消息改成文本消息
                    v.isGetReward = true
                    self:closeItem(k - 1)
                    self:openItem(k - 1)
                    -- 同步本地缓存数据
                    local cellData = { }
                    for k1, v1 in ipairs(v.rewards) do
                        if v1.ReferType == 1 then
                            -- local name = v1.ReferDesc
                            updataGoods(v1.Refer1, v1.Refer2)
                            cellData[#cellData + 1] = { fid = v1.Refer1, num = v1.Refer2 }
                            --  elseif v1.ReferType == 1 then
                            -- 跳转
                        end
                    end
                    if #cellData > 0 then
                        require("app.views.customwidget.ItemShowView"):create(cellData, true):show()
                        MessageProxy:dispatchEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 1)
                    end
                    break
                end
            end
        else
            -- 失败。
            Toast:makeToast(i18n:get("str_mail", "operate_attach_fail"), 2.0):show()
        end
    elseif event.name == EmailCfg.InnerEvents.MESSAGE_EVENT_NUM_NEW_MSG then
        local datas = DataCenter:getData(EmailCfg.InnerEvents.MESSAGE_EVENT_NUM_NEW_MSG)
        -- 新消息数量
        local num = tonumber(datas.num)
        self.textCount._totalMsgNum, self.textCount._newMsgNum = num, num
        -- 未读消息数量
        self:_updateMsgNum()
    end
end

-- 最开始添加邮件
function EmailLayer:addItem(datas)

    self.emailDatas = datas.messages
    self.Subjects = datas.Subjects

    -- wwdump(self.emailDatas)

    for i = 0, #self.emailDatas - 1 do
        local item = self:createItem(i)
        self.listView:pushBackCustomItem(item)
    end

    -- 没有消息，显示空消息提示
    ccui.Helper:seekWidgetByName(self.imgId, "image_no_msg"):setVisible(#self.emailDatas == 0)
end

function EmailLayer:createItem(idx)
    -- body
    local cellData = self.emailDatas[idx + 1]
    local subjectCellData = self.Subjects[idx + 1]
    -- 是否有附件，已经领取奖励的消息以文本消息显示。
    local haveFujian = cellData.MsgSubType == 11 and(not cellData.isGetReward)
    --    and(#cellData.rewards > 0)
    -- 标题，标题不超过10个多字节字符，20个单字节字符。
    local texTitle = subUtf8Str(subjectCellData.Subject, 20)
    -- 内容，标题不超过15个多字节字符，30个单字节字符。
    local texContent = subUtf8Str(cellData.Content, 30)
    -- 时间
    --    local leftTime = string.format("剩余时间：%d天", 15)
    -- 是否有附件
    local MsgSubType = cellData.MsgSubType
    -- 消息来源渠道：
    -- 1：系统消息
    -- 2: 客服消息
    -- 3：在线客服
    --    cellData.FromWay

    local item = self.EmailItemNode:clone()
    local title = ccui.Helper:seekWidgetByName(item, "title")
    title:setString(texTitle)
    local Image_fujian = ccui.Helper:seekWidgetByName(item, "Image_fujian")
    if haveFujian then
        Image_fujian:setVisible(true)
    else
        Image_fujian:setVisible(false)
    end
    local content = ccui.Helper:seekWidgetByName(item, "content")
    content:setString(texContent)

    --    local time = ccui.Helper:seekWidgetByName(item, "time"):setVisible(false)
    --    time:setString(leftTime)

    -- 时间暂时不要。
    ccui.Helper:seekWidgetByName(item, "Image_leftTime"):setVisible(false)


    item:setName(tostring(idx))
    item.open = false
    item:addClickEventListener(handler(self, self.checkItem))

    return item
end

-- 查看邮件
function EmailLayer:checkItem(ref)
    -- body
    print(ref:getName())
    self.lastSelectIdx = self.curSelectIdx
    self.curSelectIdx = tonumber(ref:getName())

    if self.curSelectIdx == self.lastSelectIdx then
        if ref.open then
            self:closeItem(self.curSelectIdx)
        else
            self:openItem(self.curSelectIdx)
        end
    else
        if self.curSelectIdx >= 0 then
            self:openItem(self.curSelectIdx)
        end

        if self.lastSelectIdx >= 0 then
            self:closeItem(self.lastSelectIdx)
        end
    end
end

function EmailLayer:openItem(idx)
    local cellData = self.emailDatas[idx + 1]
    -- body
    local item = false
    -- 消息ID
    local msgID = cellData.MsgID
    -- 是否有附件，还没有领取。
    local haveFujian = cellData.MsgSubType == 11 and(not cellData.isGetReward)
    --    and(#cellData.rewards > 0)
    -- 标题
    local texTitle = self.Subjects[idx + 1].Subject
    -- 内容
    local texContent = cellData.Content

    -- 领取奖励
    local rewardItems = nil
    if cellData.rewards and #cellData.rewards > 0 then
        rewardItems = { }
        for k, v in ipairs(cellData.rewards) do
            rewardItems[#rewardItems + 1] = {
                fid = v.Refer1,
                count = v.Refer2,
                name = v.ReferDesc
            }
        end
    end

    if haveFujian then
        item = self.EmailItemOpenFuJianNode:clone()
        local title = ccui.Helper:seekWidgetByName(item, "title")
        title.intervalY = item:getContentSize().height - title:getPositionY()
        title:setString(texTitle)
        local fujian = ccui.Helper:seekWidgetByName(item, "fujian")
        fujian.intervalY = fujian:getPositionY() - item:getContentSize().height
        local Image_icon = ccui.Helper:seekWidgetByName(item, "Image_icon")
        Image_icon.intervalY = item:getContentSize().height - Image_icon:getPositionY()
        local Image_open = ccui.Helper:seekWidgetByName(item, "Image_open")
        Image_open.intervalY = Image_open:getPositionY()
        local content = ccui.Helper:seekWidgetByName(item, "content")
        content.upHeight = item:getContentSize().height - content:getPositionY()
        content.downHeight = content:getPositionY() - content:getContentSize().height
        local getBtn = ccui.Helper:seekWidgetByName(item, "get")

        -- 可以领取的奖励物品
        local goodsKuang = ccui.Helper:seekWidgetByName(item, "Image_1"):setVisible(false)
        if rewardItems then
            -- 间距
            local intrvlCell = 130
            local parent = goodsKuang:getParent()
            local x, y = goodsKuang:getPosition()
            for k, v in ipairs(rewardItems) do
                local rewardItem = self:_createItemById(v.fid, v.name, v.count)
                if rewardItem then
                    rewardItem:addTo(parent):setPosition(x + intrvlCell *(k - 1), y)
                end
            end
        end

        getBtn.msgID = msgID
        getBtn:addClickEventListener( function(...)
            -- body
            local params = { ...}
            -- print("领取奖励给服务器发送消息")
            MessageProxy:requestMessageInfo(4, params[1].msgID, 0, 0)
        end )
        local tmpCfg2 = { fontFilePath = "FZZhengHeiS-B-GB.ttf", fontSize = 30, glyphs = "CUSTOM" }
        local ttf2 = cc.Label:createWithTTF(tmpCfg2, texContent, cc.TEXT_ALIGNMENT_LEFT, content:getContentSize().width * 0.96)
        ttf2:setTextColor(content:getTextColor())
        ttf2:setAnchorPoint(cc.p(0, 1.0))
        item:addChild(ttf2)
        item:setContentSize(cc.size(item:getContentSize().width, content.upHeight + content.downHeight + ttf2:getContentSize().height))
        Image_icon:setPosition(cc.p(Image_icon:getPositionX(), item:getContentSize().height - Image_icon.intervalY))
        title:setPosition(cc.p(title:getPositionX(), item:getContentSize().height - title.intervalY))
        ttf2:setPosition(cc.p(content:getPositionX(), item:getContentSize().height - content.upHeight))
        Image_open:setPosition(cc.p(ttf2:getPositionX() + ttf2:getContentSize().width, ttf2:getPositionY() - ttf2:getContentSize().height))
        fujian:setPosition(cc.p(fujian:getPositionX(), item:getContentSize().height + fujian.intervalY))
        Image_open:setPosition(cc.p(Image_open:getPositionX(), Image_open.intervalY))
    else
        item = self.EmailItemOpenNode:clone()
        local title = ccui.Helper:seekWidgetByName(item, "title")
        title.intervalY = item:getContentSize().height - title:getPositionY()
        title:setString(texTitle)
        local Image_icon = ccui.Helper:seekWidgetByName(item, "Image_icon")
        Image_icon.intervalY = item:getContentSize().height - Image_icon:getPositionY()
        local Image_open = ccui.Helper:seekWidgetByName(item, "Image_open")
        local content = ccui.Helper:seekWidgetByName(item, "content")
        content.upHeight = item:getContentSize().height - content:getPositionY()
        content.downHeight = content:getPositionY() - content:getContentSize().height
        local tmpCfg2 = { fontFilePath = "FZZhengHeiS-B-GB.ttf", fontSize = 30, glyphs = "CUSTOM" }
        local ttf2 = cc.Label:createWithTTF(tmpCfg2, texContent, cc.TEXT_ALIGNMENT_LEFT, content:getContentSize().width * 0.96)
        ttf2:setTextColor(content:getTextColor())
        ttf2:setAnchorPoint(cc.p(0, 1.0))
        item:addChild(ttf2)
        item:setContentSize(cc.size(item:getContentSize().width, content.upHeight + content.downHeight + ttf2:getContentSize().height))
        Image_icon:setPosition(cc.p(Image_icon:getPositionX(), item:getContentSize().height - Image_icon.intervalY))
        title:setPosition(cc.p(title:getPositionX(), item:getContentSize().height - title.intervalY))
        ttf2:setPosition(cc.p(content:getPositionX(), item:getContentSize().height - content.upHeight))
        Image_open:setPosition(cc.p(ttf2:getPositionX() + ttf2:getContentSize().width, ttf2:getPositionY() - ttf2:getContentSize().height))
    end

    item:setName(idx)
    item.open = true

    -- old用于统计未读消息
    if not cellData.old then
        cellData.old = true
        -- 只有没附件的消息才能直接发回执。
        if not haveFujian then
            MessageProxy:requestMessageInfo(3, msgID, 0, 0)
            self.textCount._newMsgNum = self.textCount._newMsgNum - 1
            self:_updateMsgNum()
        end
    end

    item:addClickEventListener(handler(self, self.checkItem))

    self.listView:removeItem(idx)
    self.listView:insertCustomItem(item, idx)
    self:setListViewJump()

    -- 更新红点
    WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "mail", self.textCount._newMsgNum > 0)
end

function EmailLayer:closeItem(idx)
    -- body
    local item = self:createItem(idx)

    -- 打开后，一直显示已打开标记
    if self.emailDatas[idx + 1].old then
        local Image_icon = ccui.Helper:seekWidgetByName(item, "Image_icon")
        Image_icon:loadTexture("email_envelopeOpen.png", 1)
    end

    self.listView:removeItem(idx)
    self.listView:insertCustomItem(item, idx)
    self:setListViewJump()
end

function EmailLayer:setListViewJump(...)
    -- body
    local innerPos = self.listView:getInnerContainerPosition()
    local innerSize = self.listView:getInnerContainerSize()
    local listContentSize = self.listView:getContentSize()
    local diffY2 = innerSize.height - listContentSize.height
    if diffY2 == 0 then
        return
    end
    local percent =(diffY2 + innerPos.y) / diffY2 * 100
    self.listView:jumpToPercentVertical(percent)
end

-- 更新消息数量情况
function EmailLayer:_updateMsgNum()
    local leftSide = self.textCount:posX() - self.textCount:width()
    --    self.textCount:setString(string.format("(%d/%d)", self.textCount._newMsgNum, self.textCount._totalMsgNum))
    self.textCount:setString(string.format("(%d/%d)", self.textCount._newMsgNum, 40))
    :setPositionX(leftSide + self.textCount:width())
    self.imgNew:setVisible(self.textCount._newMsgNum > 0):right(self.textCount)
end

function EmailLayer:_createItemById(fid, name, count)
    local info = getGoodsByFid(fid)
    if info and info.src then
        local bgKuang, bgBottom, figure, txtNum = nil, nil, nil
        -- bgKuang = display.newSprite("hall/email/item.png")
        bgKuang = display.newSprite("#email_item.png")
        figure = display.newSprite(info.src):addTo(bgKuang)
        figure:scale(math.min((bgKuang:width() -5) / figure:width(),(bgKuang:height() -5) / figure:height()))
        :center(bgKuang)
        -- bgBottom = display.newSprite("hall/email/bg_bottom.png"):addTo(bgKuang):centerX(bgKuang):innerBottom(bgKuang)
        bgBottom = display.newSprite("#email_bg_bottom.png"):addTo(bgKuang):centerX(bgKuang):innerBottom(bgKuang)
        -- txtNum = cc.Label:createWithTTF(labelConf.style2, string.format("%d", count)):addTo(bgBottom):center(bgBottom)
        txtNum = cc.Label:createWithSystemFont(string.format("%d", count), "", 30):addTo(bgBottom):center(bgBottom)
        return bgKuang
    end
end


return EmailLayer