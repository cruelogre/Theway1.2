-----------------------------------------------------------
-- Desc:     地方棋牌
-- Author:   diyal.yin
-- Date:     2016/08/25
-- Last:    
-- Content:  Dialog对话框
-- 2016/08/25    常规对话框（取消、确认）
-- 2016/08/31    添加关闭按钮,配置设置
-- Copyright (c) wawagame Entertainment All right reserved.
---------------------------------------------------------

--[[
    local para = {}
    para.leftBtnlabel = "取消"
    para.rightBtnlabel = "确认"
	para.leftStayOnClick = true -- 是否点击了不关闭  默认点击了就关闭
	para.rightStayOnClick = true
    para.leftBtnCallback = handler(self, self.activityHandler)
    para.rightBtnCallback = handler(self, self.taskHandler)
    para.showclose = true  --是否显示关闭按钮
    para.content = "这是一个公用对话框，只需要创建然后调用show函数即可，如果不传按钮文字，就默认是否，需要传递回调函数，如果不传，默认关闭"
    para.singleName = "MatchDialog" --单一对话框Key
    local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
--]]

local CommonDialog = class("CommonDialog",function()
    return display.newLayer()
end)
local pathflag = ''
--标注*******************的为需要绑定真实数据或修改属性的控件
local UI_POS = 
{
    {n="bgColor",  t="color", x=0, y=0},
    {
        n = "bg",
        t = "sp",
        res="common/common_frame222.png", 
        size = { ww.px(860), ww.py(480) },
        x=ww.px(960), y=ww.py(540),
    },
    {
        n="btn_left", 
        t="btn", 
        x=ww.px(754), y=ww.py(416), 
        od=1,
        tg = 3,
        res={"common/common_btn_green.png","",""}, 
        TitleText = "取消",
        TitleFontSize = 46,
        TitleColor=ConvertHex2RGBTab('253d0c'),
    },
    {
        n="btn_right", 
        t="btn", 
        x=ww.px(1156), y=ww.py(416), 
        od=1,
        tg = 3,
        res={"common/common_btn_yellow.png","",""},
        TitleText = "确认",
        TitleFontSize = 46,
        TitleColor=ConvertHex2RGBTab('891e0f'),
    },
    {
        n="btn_close", 
        t="btn", 
        x=ww.px(860 * 0.98), y=ww.py(480 * 0.98), 
        od=1,
        tg = 3,
        parent="bg",
        res={"common/common_btn_back_1.png","",""},
    },
}

local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

function CommonDialog:ctor(para)
    --背景
    self.uis={}
    self.para = para or {}

    self:initUI()
end

function CommonDialog:initUI()
    self.uis = UIFactory:createLayoutNode(UI_POS,self,pathflag)

    self.m_pListener = cc.EventListenerTouchOneByOne:create()
    self.m_pListener:setSwallowTouches(true)
    self.m_pListener:registerScriptHandler( function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_pListener, self)

    local contenxtWidth = self.uis["bg"]:getContentSize().width * 0.8
    local contenxtHeight = self.uis["bg"]:getContentSize().height * 0.5

    --文字显示控件
    local content = self.para.content or ""
    local lbContent = cc.LabelTTF:create(content,"FZZhengHeiS-B-GB.ttf",42,
        cc.size(contenxtWidth, contenxtHeight),
        cc.TEXT_ALIGNMENT_CENTER,
        cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    lbContent:setColor(ConvertHex2RGBTab("4e4228"))
    lbContent:setPosition(ww.p(960, 592))
    lbContent:addTo(self)

    local visibleCount = 0
    if self.para.leftBtnlabel then
        visibleCount = visibleCount + 1
        self.uis["btn_left"]:setTitleText(self.para.leftBtnlabel)
        self.uis["btn_left"]:setTitleFontName("FZZhengHeiS-B-GB.ttf")
    else
        self.uis["btn_left"]:setVisible(false)
    end

    if self.para.rightBtnlabel then
        visibleCount = visibleCount + 1
        self.uis["btn_right"]:setTitleText(self.para.rightBtnlabel)
        self.uis["btn_right"]:setTitleFontName("FZZhengHeiS-B-GB.ttf")
    else
        self.uis["btn_right"]:setVisible(false)
    end

    --只有一个就居中
    if visibleCount == 1 then
        local pos = cc.p((self.uis["btn_left"]:getPositionX() + self.uis["btn_right"]:getPositionX())/2,self.uis["btn_left"]:getPositionY())
        if self.para.leftBtnlabel then
            self.uis["btn_left"]:setPosition(pos)
        elseif self.para.rightBtnlabel then
            self.uis["btn_right"]:setPosition(pos)
        end
    end

    if (self.uis["btn_left"]) then
        if self.para.leftBtnlabel then
            self.uis["btn_left"]:addClickEventListener(
                function()
					playSoundEffect("sound/effect/anniu")
                    if self.para.leftBtnCallback then
                        --有些情况需要点击按钮不马上关闭弹框
                        if self.para.leftBtnCallback() then return end
                    end
					if not self.para.leftStayOnClick then
						self:close()
					end
                    
                end)
        else
            self.uis["btn_left"]:addClickEventListener(handler(self, self.close))
        end
    end    

    if (self.uis["btn_right"]) then
        if self.para.rightBtnCallback then
            self.uis["btn_right"]:addClickEventListener(
                function()
					playSoundEffect("sound/effect/anniu")
                    if self.para.rightBtnCallback then
                        --有些情况需要点击按钮不马上关闭弹框
                        if self.para.rightBtnCallback() then return end
                    end
                    if not self.para.rightStayOnClick then
						self:close()
					end
                end)
        else
            self.uis["btn_right"]:addClickEventListener(handler(self, self.close))
        end
    end

    --默认隐藏关闭按钮
    if not self.para.showclose then
        self.uis["btn_close"]:setVisible(false)
    else
        self:setShowCloseBtn()
    end

    local function keyboardPressed(keyCode, event) 
        
        if keyCode == cc.KeyCode.KEY_BACK then 
			playSoundEffect("sound/effect/anniu")
            event:stopPropagation()
			if self.para.keyBackClose or self.para.keyBackClose == nil then
                if not CommonDialog.close then
				    return
			    end
                self:close()
            end
        end  
     
    end  
 
    self.listener2 = cc.EventListenerKeyboard:create()  
    self.listener2:registerScriptHandler(keyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)  
  
    eventDispatcher:addEventListenerWithFixedPriority(self.listener2, KEYBOARD_EVENTS.KETBOARD_POPDIALOG)

    self:registerScriptHandler(handler(self,self.onNodeEvent))
end

--onEnter onExit
function CommonDialog:onNodeEvent( event )
    -- body
    if event == "enter" then
    elseif event == "exit" then
        if self.listener2 and eventDispatcher then
            eventDispatcher:removeEventListener(self.listener2)
        end
        self.listener2 = nil
    end
end

function CommonDialog:close()
    if self.listener2 and eventDispatcher then
        eventDispatcher:removeEventListener(self.listener2)
    end
    self.listener2 = nil
    self:removeFromParent(true)
end

function CommonDialog:show()
    
    if self.para.singleName then
        --存在相同类型的节点时候
        display.getRunningScene():removeChildByName(self.para.singleName)
        self:setName(self.para.singleName)
    end
    return self:addTo(display.getRunningScene(),ww.topOrder)
end

function CommonDialog:setShowCloseBtn()
    self.uis["btn_close"]:addClickEventListener(handler(self, self.close))
end

return CommonDialog
