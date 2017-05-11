--帮助列表控件
local HelpList = class("HelpList",function()
    return display.newNode()
end)
local pathflag = ''

function HelpList:ctor(para)
    --背景
    self.uis={}
    self.para = para or {}
    self.pScrollClose = nil
    self.pScrollOpen = nil
    self.openIdx = 0

    self:initUI()
end

function HelpList:initUI()
    self:relateInfo()
end

function HelpList:relateInfo()
    self:updateCloseList()
end

function HelpList:updateCloseList()
    --print("HelpList:updateCloseListaaaaaaaaa111")
    if (self.pScrollClose  and tolua.isnull(self.pScrollClose))then
        self.pScrollClose= nil
    end
    if (self.pScrollClose) then
        self.pScrollClose:removeFromParentAndCleanup(true)
        self.pScrollClose = nil
    end

    local pScrollClose = ccui.ListView:create()
    pScrollClose:setPosition(0,0)
    pScrollClose:setAnchorPoint(0,0)
    --pScrollClose:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    --pScrollClose:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    pScrollClose:setDirection(1)
    pScrollClose:setContentSize(display.width,590)
    pScrollClose:setBounceEnabled(true)
    pScrollClose:setTouchEnabled(true)
    pScrollClose:setItemsMargin(15)
    pScrollClose:setClippingType(1)

    local infoList = self.para
    --infoList[2] = clone(infoList[1])
    --infoList[2].endTick = 100
    for i=1,#infoList do
        local oneRecord = infoList[i]

        local temp=ccui.Layout:create()
        local spaceX = 40
        local spaceY = 20
        local cellH = 66
        local titleStr = oneRecord.title
        local lbTemp = cc.LabelTTF:create(titleStr, CFG_SYSTEM_FONT, 24)
        local lbTitle
        if lbTemp:getContentSize().width > 1040 then
            lbTitle = cc.LabelTTF:create(titleStr, CFG_SYSTEM_FONT, 24, cc.size(1040,0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
        else
            lbTitle = cc.LabelTTF:create(titleStr, CFG_SYSTEM_FONT, 24, cc.size(lbTemp:getContentSize().width+2*spaceX,0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
        end
        local textSize = lbTitle:getContentSize()
        if textSize.height+2*spaceY > cellH then
            cellH = textSize.height+2*spaceY
        end

        temp:setContentSize(display.width, cellH)
        temp:setAnchorPoint(0,0)
        temp:setTouchEnabled(true)
        pScrollClose:pushBackCustomItem(temp)

        local infoBg = ccui.Scale9Sprite:create("Auction/auction_frame_bg_rule.png")
        infoBg:setContentSize(cc.size(1120,cellH))
        infoBg:setAnchorPoint(0,1)
        infoBg:setPosition(80,cellH)
        infoBg:addTo(temp)

        --print("HelpList:updateCloseListaaaaaaaaa222",titleStr,spaceX,cellH)

        lbTitle:setColor(cc.c3b(255,255,255))
        lbTitle:setAnchorPoint(0,1)
        lbTitle:setPosition(spaceX,cellH-spaceY)
        -- lbTitle:setAnchorPoint(0,0)
        -- lbTitle:setPosition(spaceX,0)
        lbTitle:addTo(infoBg)

        local openBtn = ww.NewButton:create("setting/problem/+.png","setting/problem/+.png")
        openBtn:setAnchorPoint(1,0.5)
        openBtn:setPosition(1080,cellH/2)
        openBtn:addTo(infoBg)
        openBtn:addClickEventListener(function(event, x, y)
            self.pScrollClose:setVisible(false)
            self.openIdx = i

            self:updateOpenList(i,cellH,self.openListH)
            self.pScrollOpen:refreshView()
            self.pScrollOpen:jumpToPercentVertical(self:calPercentOfIndex(i,cellH,self.openListH))
        end)
        --x
    end
    --pScrollClose:setInnerContainerSize(cc.size(scrollWidth,scrollHeight))

    pScrollClose:addTo(self)

    self.pScrollClose = pScrollClose
end

function HelpList:updateOpenList()
    --print("HelpList:updateOpenListaaaaaaaaa111")
    if (self.pScrollOpen  and tolua.isnull(self.pScrollOpen))then
        self.pScrollOpen= nil
    end
    if (self.pScrollOpen) then
        self.pScrollOpen:removeFromParentAndCleanup(true)
        self.pScrollOpen = nil
    end

    local pScrollOpen = ccui.ListView:create()
    pScrollOpen:setPosition(0,0)
    pScrollOpen:setAnchorPoint(0,0)
    --pScrollOpen:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    --pScrollOpen:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    pScrollOpen:setDirection(1)
    pScrollOpen:setContentSize(display.width,590)
    pScrollOpen:setBounceEnabled(true)
    pScrollOpen:setTouchEnabled(true)
    pScrollOpen:setItemsMargin(15)
    pScrollOpen:setClippingType(1)

    self.openListH = 0
    local infoList = self.para
    --infoList[2] = clone(infoList[1])
    --infoList[2].endTick = 100
    for i=1,#infoList do
        local oneRecord = infoList[i]

        local temp=ccui.Layout:create()
        local spaceX = 40
        local spaceY = 20
        local cellH = 66
        local titleStr = oneRecord.title
        local lbTemp = cc.LabelTTF:create(titleStr, CFG_SYSTEM_FONT, 24)
        local lbTitle
        if lbTemp:getContentSize().width > 1040 then
            lbTitle = cc.LabelTTF:create(titleStr, CFG_SYSTEM_FONT, 24, cc.size(1040,0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
        else
            lbTitle = cc.LabelTTF:create(titleStr, CFG_SYSTEM_FONT, 24, cc.size(lbTemp:getContentSize().width+2*spaceX,0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
        end
        local textSize = lbTitle:getContentSize()
        if textSize.height+2*spaceY > cellH then
            cellH = textSize.height+2*spaceY
        end

        local lbContent
        local answerSize
        --print("HelpList:updateOpenListaaaaaaaaa222",self.openIdx,i,oneRecord.content)
        if self.openIdx == i and oneRecord.content then
            lbContent = cc.LabelTTF:create(oneRecord.content, CFG_SYSTEM_FONT, 24, cc.size(1040,0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
            answerSize = lbContent:getContentSize()
            cellH = cellH + answerSize.height+2*spaceY
        end
        temp:setContentSize(display.width, cellH)
        temp:setAnchorPoint(0,0)
        temp:setTouchEnabled(true)
        pScrollOpen:pushBackCustomItem(temp)

        local infoBg = ccui.Scale9Sprite:create("Auction/auction_frame_bg_rule.png")
        infoBg:setContentSize(cc.size(1120,textSize.height+2*spaceY))
        infoBg:setAnchorPoint(0,1)
        infoBg:setPosition(80,cellH)
        infoBg:addTo(temp)

        lbTitle:setColor(cc.c3b(255,255,255))
        lbTitle:setAnchorPoint(0,1)
        lbTitle:setPosition(spaceX,textSize.height+spaceY)
        lbTitle:addTo(infoBg)

        local openBtn
        if self.openIdx == i then
            openBtn = ww.NewButton:create("setting/problem/x.png","setting/problem/x.png")
        else
            openBtn = ww.NewButton:create("setting/problem/+.png","setting/problem/+.png")
        end
        openBtn:setAnchorPoint(1,1)
        openBtn:setPosition(1080,textSize.height+spaceY+16)
        openBtn:addTo(infoBg)
        openBtn:addClickEventListener(function(event, x, y)
            if self.openIdx == i then
                self.pScrollClose:setVisible(true)
                self.pScrollOpen:setVisible(false)
                self.openIdx = 0
            else
                self.pScrollClose:setVisible(false)
                self.openIdx = i
            
                self:updateOpenList()
                self.pScrollOpen:refreshView()
                self.pScrollOpen:jumpToPercentVertical(self:calPercentOfIndex(i,cellH,self.openListH))
            end
        end)

        if self.openIdx == i and oneRecord.content then
            local contentBg = ccui.Scale9Sprite:create("Auction/auction_frame_bg_rule.png")
            contentBg:setContentSize(cc.size(1120,answerSize.height+2*spaceY))
            contentBg:setAnchorPoint(0,1)
            contentBg:setPosition(80,cellH-(textSize.height+2*spaceY))
            contentBg:addTo(temp)

            print("HelpList:updateCloseListaaaaaaaaa222",titleStr,spaceX,cellH)

            lbContent:setColor(cc.c3b(255,255,255))
            lbContent:setAnchorPoint(0,1)
            lbContent:setPosition(spaceX,cellH-(textSize.height+2*spaceY)-spaceY)
            lbContent:addTo(contentBg)
        end

        self.openListH = self.openListH + cellH + 15
    end
    --pScrollOpen:setInnerContainerSize(cc.size(scrollWidth,scrollHeight))

    pScrollOpen:addTo(self)

    self.pScrollOpen = pScrollOpen
end

function HelpList:calPercentOfIndex(index,cellH,totalH)
    --print("HelpList:calPercentOfIndexaaaaaaaaaaaaaa111",index,cellH,totalH)
    local offsetY = (index-1)*(cellH+15)
    local percent = offsetY/(totalH-590)
    -- if percent > 1 then
    --     percent = 1
    -- end
    percent = percent*100

    --print("HelpList:calPercentOfIndexaaaaaaaaaaaaaa222",percent)
    return percent
end

return HelpList
