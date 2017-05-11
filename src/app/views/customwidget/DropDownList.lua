require "cocos.cocos2d.json"
--下拉列表页面
local DropDownList = class("DropDownList",function()
    return display.newLayer()
end)
local pathflag = ''
--标注*******************的为需要绑定真实数据或修改属性的控件
local UI_POS = 
{
    --*******************
    {n="lbCurText",  t="txt", x=0, y=0, arc={0, 1}, color={255, 255, 255},size=24,txt="请选择" },
    {n="btnSelect",  t="btn", x=0, y=0, arc={0, 1}, od=1, res={"Auction/auction_btn_down_select.png","Auction/auction_btn_down_select.png",""} },
}

local auctionsceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().AUCTION_SCENE)

function DropDownList:ctor(para)
    --背景
    self:onNodeEvent("cleanup", handler(self, self.doCleanup))
    self.uis={}
    self.para = para or {}
    self.para.scrollSize = self.para.scrollSize or {500,104}
    self.selectIdx = self.para.defaultIdx or 0
    self.pScrollView = nil
    self.isListOpen = false

    self:initUI()
    print("DropDownList:ctoraaaaaaaaaaa111")
end

function DropDownList:doCleanup( ... )
   
end

function DropDownList:initUI()
    local textBg = ccui.Scale9Sprite:create("Auction/auction_sp_chat_other_bg.png")
    textBg:setContentSize(cc.size(self.para.scrollSize[1],26))
    textBg:setAnchorPoint(0,1)
    textBg:setPosition(0,0)
    textBg:addTo(self)

    self.uis = GenUiUtil:genUis(UI_POS,self,pathflag)

    -- if(self.uis["back"]) then
    --     self.uis["back"]:addClickEventListener(handler(self, self.back))
    -- end

    if(self.uis["btnSelect"]) then
        self.uis["btnSelect"]:setPosition(self.para.scrollSize[1],0)
        self.uis["btnSelect"]:addClickEventListener(function(event, x, y)
            self:openDownList()
        end)
    end

    --关联真实数据
    self:relateInfo()
end

function DropDownList:relateInfo()
    --当前选中文字
    self:updateCurText()
end

function DropDownList:updateCurText()
    if(self.uis["lbCurText"]) then
        self.uis["lbCurText"]:setString(self:getCurTextByIdx(self.selectIdx))
    end
end

function DropDownList:updateDownList()
    if (self.pScrollView  and tolua.isnull(self.pScrollView))then
        self.pScrollView= nil
    end
    if (self.pScrollView) then
        self.pScrollView:removeFromParentAndCleanup(true)
        self.pScrollView = nil
    end

    local pScrollView = ccui.ListView:create()
    pScrollView:setPosition(0,0)
    pScrollView:setAnchorPoint(0,1)
    pScrollView:setDirection(1)
    pScrollView:setContentSize(self.para.scrollSize[1],self.para.scrollSize[2])
    pScrollView:setBounceEnabled(true)
    pScrollView:setTouchEnabled(true)

    if (self.para.textTb and #self.para.textTb > 0) then
        for i=1,#self.para.textTb do
            local temp=ccui.Layout:create()
            temp:setContentSize(self.para.scrollSize[1], 26)
            temp:setAnchorPoint(0,0)
            temp:setTouchEnabled(true)
            pScrollView:pushBackCustomItem(temp)

            local lbNickName = cc.LabelTTF:create(self:getCurTextByIdx(i),"Arial",24)
            lbNickName:setColor(cc.c3b(0xE8, 0x68, 0x01))
            lbNickName:setAnchorPoint(0,0)
            lbNickName:setPosition(0,1)
            lbNickName:addTo(temp)

            local btn = ccui.Widget:create()
            btn:setContentSize(self.para.scrollSize[1], 26)
            btn:setPosition(0,0)
            btn:addTo(temp,0,i)
            btn:setTouchEnabled(true)
            btn:setSwallowTouches(false)
            btn:addClickEventListener(function(...)
                --print("testbtnteatnvvvvvvooooooooooooooooooo111",btn:getTag())

                self.selectIdx = btn:getTag()
                self:openDownList()
            end)
        end
    end

    pScrollView:addTo(self)

    self.pScrollView = pScrollView
    if self.isListOpen then
        self.pScrollView:setVisible(true)
    else
        self.pScrollView:setVisible(false)
    end
end

function DropDownList:getCurTextByIdx(index)
    local curStr = "请选择"
    if (self.para.textTb and #self.para.textTb > 0) then
        if (#self.para.textTb >= index and index > 0) then
            curStr = self.para.textTb[index]
        end
    end
    return curStr
end

function DropDownList:getCurSelectIdx()
    return self.selectIdx or 1
end

function DropDownList:addText(text,index)
    if (self.para.textTb and #self.para.textTb > 0 and text) then
        if (index and index < #self.para.textTb) then
            table.insert(self.para.textTb, index, text)
        else
            table.insert(self.para.textTb, text)
        end
        self:updateCurText()
        self:updateDownList()
    end
end

function DropDownList:openDownList()
    if not self.isListOpen then
        self.isListOpen = true
        self:updateDownList()
        self.uis["lbCurText"]:setVisible(false)
    else
        if (self.pScrollView  and tolua.isnull(self.pScrollView))then
            self.pScrollView= nil
        end
        if (self.pScrollView) then
            self.pScrollView:removeFromParentAndCleanup(true)
            self.pScrollView = nil
        end
        self.isListOpen = false
        self.uis["lbCurText"]:setVisible(true)
        self:updateCurText()
    end
end

function DropDownList:back()
    -- self:removeFromParentAndCleanup(true)
    -- gotoCppMainScene()
end

return DropDownList
