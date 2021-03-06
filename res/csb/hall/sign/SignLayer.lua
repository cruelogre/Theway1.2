--------------------------------------------------------------
-- This file was automatically generated by Cocos Studio.
-- Do not make changes to this file.
-- All changes will be lost.
--------------------------------------------------------------

local luaExtend = require "LuaExtend"

-- using for layout to decrease count of local variables
local layout = nil
local localLuaFile = nil
local innerCSD = nil
local innerProject = nil
local localFrame = nil

local Result = {}
------------------------------------------------------------
-- function call description
-- create function caller should provide a function to 
-- get a callback function in creating scene process.
-- the returned callback function will be registered to 
-- the callback event of the control.
-- the function provider is as below :
-- Callback callBackProvider(luaFileName, node, callbackName)
-- parameter description:
-- luaFileName  : a string, lua file name
-- node         : a Node, event source
-- callbackName : a string, callback function name
-- the return value is a callback function
------------------------------------------------------------
function Result.create(callBackProvider)

local result={}
setmetatable(result, luaExtend)

--Create Layer
local Layer=cc.Node:create()
Layer:setName("Layer")
layout = ccui.LayoutComponent:bindLayoutComponent(Layer)
layout:setSize({width = 1920.0000, height = 1080.0000})

--Create Image_di
local Image_di = ccui.ImageView:create()
Image_di:ignoreContentAdaptWithSize(false)
cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/common/hall_common.plist")
Image_di:loadTexture("setting_bg.png",1)
Image_di:setTouchEnabled(true);
Image_di:setLayoutComponentEnabled(true)
Image_di:setName("Image_di")
Image_di:setTag(37)
Image_di:setCascadeColorEnabled(true)
Image_di:setCascadeOpacityEnabled(true)
Image_di:setPosition(1392.4420, 536.6641)
layout = ccui.LayoutComponent:bindLayoutComponent(Image_di)
layout:setPositionPercentX(0.7252)
layout:setPositionPercentY(0.4969)
layout:setPercentWidth(0.5417)
layout:setPercentHeight(0.9907)
layout:setSize({width = 1040.0000, height = 1070.0000})
layout:setVerticalEdge(3)
layout:setLeftMargin(872.4415)
layout:setRightMargin(7.5585)
layout:setTopMargin(8.3359)
layout:setBottomMargin(1.6641)
layout:setStretchHeightEnabled(true)
Layer:addChild(Image_di)

--Create Image_sign
local Image_sign = ccui.ImageView:create()
Image_sign:ignoreContentAdaptWithSize(false)
cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/sign/sign.plist")
Image_sign:loadTexture("bottom2.png",1)
Image_sign:setScale9Enabled(true)
Image_sign:setCapInsets({x = 15, y = 15, width = 70, height = 70})
Image_sign:setTouchEnabled(true);
Image_sign:setLayoutComponentEnabled(true)
Image_sign:setName("Image_sign")
Image_sign:setTag(16)
Image_sign:setCascadeColorEnabled(true)
Image_sign:setCascadeOpacityEnabled(true)
Image_sign:setAnchorPoint(0.5000, 1.0000)
Image_sign:setPosition(528.5972, 960.0000)
layout = ccui.LayoutComponent:bindLayoutComponent(Image_sign)
layout:setPositionPercentX(0.5083)
layout:setPositionPercentY(0.8972)
layout:setPercentWidth(0.9760)
layout:setPercentHeight(0.5556)
layout:setSize({width = 1015.0000, height = 594.4920})
layout:setVerticalEdge(2)
layout:setLeftMargin(21.0972)
layout:setRightMargin(3.9028)
layout:setTopMargin(110.0000)
layout:setBottomMargin(365.5080)
layout:setStretchHeightEnabled(true)
Image_di:addChild(Image_sign)

--Create Image_week
local Image_week = ccui.ImageView:create()
Image_week:ignoreContentAdaptWithSize(false)
cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/sign/sign.plist")
Image_week:loadTexture("day1.png",1)
Image_week:setScale9Enabled(true)
Image_week:setCapInsets({x = 15, y = 15, width = 106, height = 87})
Image_week:setTouchEnabled(true);
Image_week:setLayoutComponentEnabled(true)
Image_week:setName("Image_week")
Image_week:setTag(17)
Image_week:setCascadeColorEnabled(true)
Image_week:setCascadeOpacityEnabled(true)
Image_week:setPosition(505.5000, 524.9440)
layout = ccui.LayoutComponent:bindLayoutComponent(Image_week)
layout:setPositionPercentX(0.4980)
layout:setPositionPercentY(0.8830)
layout:setPercentWidth(0.9655)
layout:setPercentHeight(0.1177)
layout:setSize({width = 980.0000, height = 70.0000})
layout:setVerticalEdge(2)
layout:setLeftMargin(15.5000)
layout:setRightMargin(19.5000)
layout:setTopMargin(34.5480)
layout:setBottomMargin(489.9440)
Image_sign:addChild(Image_week)

--Create Text_week0
local Text_week0 = ccui.Text:create()
Text_week0:ignoreContentAdaptWithSize(true)
Text_week0:setTextAreaSize({width = 0, height = 0})
Text_week0:setFontName("FZZhengHeiS-B-GB.ttf")
Text_week0:setFontSize(32)
Text_week0:setString([[周日]])
Text_week0:setLayoutComponentEnabled(true)
Text_week0:setName("Text_week0")
Text_week0:setTag(38)
Text_week0:setCascadeColorEnabled(true)
Text_week0:setCascadeOpacityEnabled(true)
Text_week0:setPosition(70.0000, 33.3027)
layout = ccui.LayoutComponent:bindLayoutComponent(Text_week0)
layout:setPositionPercentX(0.0714)
layout:setPositionPercentY(0.4758)
layout:setPercentWidth(0.0653)
layout:setPercentHeight(0.5571)
layout:setSize({width = 64.0000, height = 39.0000})
layout:setLeftMargin(38.0000)
layout:setRightMargin(878.0000)
layout:setTopMargin(17.1973)
layout:setBottomMargin(13.8027)
Image_week:addChild(Text_week0)

--Create Text_week1
local Text_week1 = ccui.Text:create()
Text_week1:ignoreContentAdaptWithSize(true)
Text_week1:setTextAreaSize({width = 0, height = 0})
Text_week1:setFontName("FZZhengHeiS-B-GB.ttf")
Text_week1:setFontSize(32)
Text_week1:setString([[周一]])
Text_week1:setLayoutComponentEnabled(true)
Text_week1:setName("Text_week1")
Text_week1:setTag(39)
Text_week1:setCascadeColorEnabled(true)
Text_week1:setCascadeOpacityEnabled(true)
Text_week1:setPosition(210.0000, 32.8840)
layout = ccui.LayoutComponent:bindLayoutComponent(Text_week1)
layout:setPositionPercentX(0.2143)
layout:setPositionPercentY(0.4698)
layout:setPercentWidth(0.0673)
layout:setPercentHeight(0.5571)
layout:setSize({width = 66.0000, height = 39.0000})
layout:setLeftMargin(177.0000)
layout:setRightMargin(737.0000)
layout:setTopMargin(17.6160)
layout:setBottomMargin(13.3840)
Image_week:addChild(Text_week1)

--Create Text_week2
local Text_week2 = ccui.Text:create()
Text_week2:ignoreContentAdaptWithSize(true)
Text_week2:setTextAreaSize({width = 0, height = 0})
Text_week2:setFontName("FZZhengHeiS-B-GB.ttf")
Text_week2:setFontSize(32)
Text_week2:setString([[周二]])
Text_week2:setLayoutComponentEnabled(true)
Text_week2:setName("Text_week2")
Text_week2:setTag(40)
Text_week2:setCascadeColorEnabled(true)
Text_week2:setCascadeOpacityEnabled(true)
Text_week2:setPosition(350.0000, 34.0001)
layout = ccui.LayoutComponent:bindLayoutComponent(Text_week2)
layout:setPositionPercentX(0.3571)
layout:setPositionPercentY(0.4857)
layout:setPercentWidth(0.0663)
layout:setPercentHeight(0.5571)
layout:setSize({width = 65.0000, height = 39.0000})
layout:setLeftMargin(317.5000)
layout:setRightMargin(597.5000)
layout:setTopMargin(16.4999)
layout:setBottomMargin(14.5001)
Image_week:addChild(Text_week2)

--Create Text_week3
local Text_week3 = ccui.Text:create()
Text_week3:ignoreContentAdaptWithSize(true)
Text_week3:setTextAreaSize({width = 0, height = 0})
Text_week3:setFontName("FZZhengHeiS-B-GB.ttf")
Text_week3:setFontSize(32)
Text_week3:setString([[周三]])
Text_week3:setLayoutComponentEnabled(true)
Text_week3:setName("Text_week3")
Text_week3:setTag(41)
Text_week3:setCascadeColorEnabled(true)
Text_week3:setCascadeOpacityEnabled(true)
Text_week3:setPosition(490.0000, 34.5250)
layout = ccui.LayoutComponent:bindLayoutComponent(Text_week3)
layout:setPositionPercentX(0.5000)
layout:setPositionPercentY(0.4932)
layout:setPercentWidth(0.0673)
layout:setPercentHeight(0.5571)
layout:setSize({width = 66.0000, height = 39.0000})
layout:setLeftMargin(457.0000)
layout:setRightMargin(457.0000)
layout:setTopMargin(15.9750)
layout:setBottomMargin(15.0250)
Image_week:addChild(Text_week3)

--Create Text_week4
local Text_week4 = ccui.Text:create()
Text_week4:ignoreContentAdaptWithSize(true)
Text_week4:setTextAreaSize({width = 0, height = 0})
Text_week4:setFontName("FZZhengHeiS-B-GB.ttf")
Text_week4:setFontSize(32)
Text_week4:setString([[周四]])
Text_week4:setLayoutComponentEnabled(true)
Text_week4:setName("Text_week4")
Text_week4:setTag(44)
Text_week4:setCascadeColorEnabled(true)
Text_week4:setCascadeOpacityEnabled(true)
Text_week4:setPosition(630.0000, 34.0001)
layout = ccui.LayoutComponent:bindLayoutComponent(Text_week4)
layout:setPositionPercentX(0.6429)
layout:setPositionPercentY(0.4857)
layout:setPercentWidth(0.0663)
layout:setPercentHeight(0.5571)
layout:setSize({width = 65.0000, height = 39.0000})
layout:setLeftMargin(597.5000)
layout:setRightMargin(317.5000)
layout:setTopMargin(16.4999)
layout:setBottomMargin(14.5001)
Image_week:addChild(Text_week4)

--Create Text_week5
local Text_week5 = ccui.Text:create()
Text_week5:ignoreContentAdaptWithSize(true)
Text_week5:setTextAreaSize({width = 0, height = 0})
Text_week5:setFontName("FZZhengHeiS-B-GB.ttf")
Text_week5:setFontSize(32)
Text_week5:setString([[周五]])
Text_week5:setLayoutComponentEnabled(true)
Text_week5:setName("Text_week5")
Text_week5:setTag(43)
Text_week5:setCascadeColorEnabled(true)
Text_week5:setCascadeOpacityEnabled(true)
Text_week5:setPosition(770.0000, 34.0001)
layout = ccui.LayoutComponent:bindLayoutComponent(Text_week5)
layout:setPositionPercentX(0.7857)
layout:setPositionPercentY(0.4857)
layout:setPercentWidth(0.0673)
layout:setPercentHeight(0.5571)
layout:setSize({width = 66.0000, height = 39.0000})
layout:setLeftMargin(737.0000)
layout:setRightMargin(177.0000)
layout:setTopMargin(16.4999)
layout:setBottomMargin(14.5001)
Image_week:addChild(Text_week5)

--Create Text_week6
local Text_week6 = ccui.Text:create()
Text_week6:ignoreContentAdaptWithSize(true)
Text_week6:setTextAreaSize({width = 0, height = 0})
Text_week6:setFontName("FZZhengHeiS-B-GB.ttf")
Text_week6:setFontSize(32)
Text_week6:setString([[周六]])
Text_week6:setLayoutComponentEnabled(true)
Text_week6:setName("Text_week6")
Text_week6:setTag(42)
Text_week6:setCascadeColorEnabled(true)
Text_week6:setCascadeOpacityEnabled(true)
Text_week6:setPosition(910.0000, 31.0000)
layout = ccui.LayoutComponent:bindLayoutComponent(Text_week6)
layout:setPositionPercentX(0.9286)
layout:setPositionPercentY(0.4429)
layout:setPercentWidth(0.0673)
layout:setPercentHeight(0.5571)
layout:setSize({width = 66.0000, height = 39.0000})
layout:setLeftMargin(877.0000)
layout:setRightMargin(37.0000)
layout:setTopMargin(19.5000)
layout:setBottomMargin(11.5000)
Image_week:addChild(Text_week6)

--Create ScrollView_1
local ScrollView_1 = ccui.ScrollView:create()
ScrollView_1:setBounceEnabled(true)
ScrollView_1:setInnerContainerSize({width = 990, height = 533})
ScrollView_1:ignoreContentAdaptWithSize(false)
ScrollView_1:setClippingEnabled(true)
ScrollView_1:setBackGroundColorOpacity(97)
ScrollView_1:setLayoutComponentEnabled(true)
ScrollView_1:setName("ScrollView_1")
ScrollView_1:setTag(23)
ScrollView_1:setCascadeColorEnabled(true)
ScrollView_1:setCascadeOpacityEnabled(true)
ScrollView_1:setPosition(20.5000, 56.2723)
layout = ccui.LayoutComponent:bindLayoutComponent(ScrollView_1)
layout:setPositionPercentX(0.0202)
layout:setPositionPercentY(0.0947)
layout:setPercentWidth(0.9754)
layout:setPercentHeight(0.7166)
layout:setSize({width = 990.0000, height = 426.0000})
layout:setVerticalEdge(2)
layout:setLeftMargin(20.5000)
layout:setRightMargin(4.5000)
layout:setTopMargin(112.2197)
layout:setBottomMargin(56.2723)
layout:setStretchHeightEnabled(true)
Image_sign:addChild(ScrollView_1)

--Create Image_title
local Image_title = ccui.ImageView:create()
Image_title:ignoreContentAdaptWithSize(false)
cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/common/hall_common.plist")
Image_title:loadTexture("setting_top.png",1)
Image_title:setScale9Enabled(true)
Image_title:setCapInsets({x = 348, y = 46, width = 359, height = 50})
Image_title:setTouchEnabled(true);
Image_title:setLayoutComponentEnabled(true)
Image_title:setName("Image_title")
Image_title:setTag(14)
Image_title:setCascadeColorEnabled(true)
Image_title:setCascadeOpacityEnabled(true)
Image_title:setPosition(525.0468, 1007.1340)
layout = ccui.LayoutComponent:bindLayoutComponent(Image_title)
layout:setPositionPercentX(0.5049)
layout:setPositionPercentY(0.9412)
layout:setPercentWidth(1.0144)
layout:setPercentHeight(0.1327)
layout:setSize({width = 1055.0000, height = 142.0000})
layout:setVerticalEdge(2)
layout:setLeftMargin(-2.4532)
layout:setRightMargin(-12.5469)
layout:setTopMargin(-8.1338)
layout:setBottomMargin(936.1338)
Image_di:addChild(Image_title)

--Create Text_month
local Text_month = ccui.Text:create()
Text_month:ignoreContentAdaptWithSize(true)
Text_month:setTextAreaSize({width = 0, height = 0})
Text_month:setFontName("FZZhengHeiS-B-GB.ttf")
Text_month:setFontSize(70)
Text_month:setString([[--]])
Text_month:enableOutline({r = 255, g = 0, b = 0, a = 255}, 3)
Text_month:setLayoutComponentEnabled(true)
Text_month:setName("Text_month")
Text_month:setTag(12)
Text_month:setCascadeColorEnabled(true)
Text_month:setCascadeOpacityEnabled(true)
Text_month:setPosition(111.2102, 79.6678)
layout = ccui.LayoutComponent:bindLayoutComponent(Text_month)
layout:setPositionPercentX(0.1054)
layout:setPositionPercentY(0.5610)
layout:setPercentWidth(0.0834)
layout:setPercentHeight(0.6479)
layout:setSize({width = 88.0000, height = 92.0000})
layout:setLeftMargin(67.2102)
layout:setRightMargin(899.7898)
layout:setTopMargin(16.3322)
layout:setBottomMargin(33.6678)
Image_title:addChild(Text_month)

--Create Text_cardCount
local Text_cardCount = ccui.Text:create()
Text_cardCount:ignoreContentAdaptWithSize(true)
Text_cardCount:setTextAreaSize({width = 0, height = 0})
Text_cardCount:setFontName("FZZhengHeiS-B-GB.ttf")
Text_cardCount:setFontSize(34)
Text_cardCount:setString([[当前补签卡： 0个]])
Text_cardCount:setLayoutComponentEnabled(true)
Text_cardCount:setName("Text_cardCount")
Text_cardCount:setTag(13)
Text_cardCount:setCascadeColorEnabled(true)
Text_cardCount:setCascadeOpacityEnabled(true)
Text_cardCount:setPosition(486.4176, 77.7291)
layout = ccui.LayoutComponent:bindLayoutComponent(Text_cardCount)
layout:setPositionPercentX(0.4611)
layout:setPositionPercentY(0.5474)
layout:setPercentWidth(0.2616)
layout:setPercentHeight(0.2958)
layout:setSize({width = 276.0000, height = 42.0000})
layout:setLeftMargin(348.4176)
layout:setRightMargin(430.5824)
layout:setTopMargin(43.2709)
layout:setBottomMargin(56.7291)
Image_title:addChild(Text_cardCount)

--Create Button_sign
local Button_sign = ccui.Button:create()
Button_sign:ignoreContentAdaptWithSize(false)
cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/sign/sign.plist")
Button_sign:loadTextureNormal("replenish btn.png",1)
Button_sign:setTitleFontName("FZZhengHeiS-B-GB.ttf")
Button_sign:setTitleFontSize(50)
Button_sign:setTitleText("补签")
Button_sign:setTitleColor({r = 65, g = 65, b = 70})
Button_sign:setScale9Enabled(true)
Button_sign:setCapInsets({x = 15, y = 11, width = 224, height = 62})
Button_sign:setLayoutComponentEnabled(true)
Button_sign:setName("Button_sign")
Button_sign:setTag(15)
Button_sign:setCascadeColorEnabled(true)
Button_sign:setCascadeOpacityEnabled(true)
Button_sign:setPosition(866.3461, 81.1997)
layout = ccui.LayoutComponent:bindLayoutComponent(Button_sign)
layout:setPositionPercentX(0.8212)
layout:setPositionPercentY(0.5718)
layout:setPercentWidth(0.2502)
layout:setPercentHeight(0.6479)
layout:setSize({width = 264.0000, height = 92.0000})
layout:setLeftMargin(734.3461)
layout:setRightMargin(56.6539)
layout:setTopMargin(14.8003)
layout:setBottomMargin(35.1997)
Image_title:addChild(Button_sign)

--Create Image_gift
local Image_gift = ccui.ImageView:create()
Image_gift:ignoreContentAdaptWithSize(false)
cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/sign/sign.plist")
Image_gift:loadTexture("bottom3.png",1)
Image_gift:setTouchEnabled(true);
Image_gift:setLayoutComponentEnabled(true)
Image_gift:setName("Image_gift")
Image_gift:setTag(19)
Image_gift:setCascadeColorEnabled(true)
Image_gift:setCascadeOpacityEnabled(true)
Image_gift:setPosition(527.0906, 216.9126)
layout = ccui.LayoutComponent:bindLayoutComponent(Image_gift)
layout:setPositionPercentX(0.5068)
layout:setPositionPercentY(0.2027)
layout:setPercentWidth(0.9808)
layout:setPercentHeight(0.3685)
layout:setSize({width = 1020.0000, height = 394.2950})
layout:setVerticalEdge(1)
layout:setLeftMargin(17.0906)
layout:setRightMargin(2.9094)
layout:setTopMargin(655.9399)
layout:setBottomMargin(19.7651)
layout:setStretchHeightEnabled(true)
Image_di:addChild(Image_gift)

--Create Image_3
local Image_3 = ccui.ImageView:create()
Image_3:ignoreContentAdaptWithSize(false)
cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/sign/sign.plist")
Image_3:loadTexture("bottom4.png",1)
Image_3:setLayoutComponentEnabled(true)
Image_3:setName("Image_3")
Image_3:setTag(30)
Image_3:setCascadeColorEnabled(true)
Image_3:setCascadeOpacityEnabled(true)
Image_3:setPosition(501.0880, 48.7278)
layout = ccui.LayoutComponent:bindLayoutComponent(Image_3)
layout:setPositionPercentX(0.4913)
layout:setPositionPercentY(0.1236)
layout:setPercentWidth(0.9667)
layout:setPercentHeight(0.1572)
layout:setSize({width = 986.0000, height = 62.0000})
layout:setVerticalEdge(1)
layout:setLeftMargin(8.0880)
layout:setRightMargin(25.9120)
layout:setTopMargin(314.5672)
layout:setBottomMargin(17.7278)
Image_gift:addChild(Image_3)

--Create Text_desc
local Text_desc = ccui.Text:create()
Text_desc:ignoreContentAdaptWithSize(true)
Text_desc:setTextAreaSize({width = 0, height = 0})
Text_desc:setFontName("FZZhengHeiS-B-GB.ttf")
Text_desc:setFontSize(31)
Text_desc:setString([[连续签到可以得礼包，每月1日清零重置]])
Text_desc:setLayoutComponentEnabled(true)
Text_desc:setName("Text_desc")
Text_desc:setTag(35)
Text_desc:setCascadeColorEnabled(true)
Text_desc:setCascadeOpacityEnabled(true)
Text_desc:setPosition(505.2682, 45.6941)
layout = ccui.LayoutComponent:bindLayoutComponent(Text_desc)
layout:setPositionPercentX(0.4954)
layout:setPositionPercentY(0.1159)
layout:setPercentWidth(0.5353)
layout:setPercentHeight(0.0964)
layout:setSize({width = 546.0000, height = 38.0000})
layout:setVerticalEdge(1)
layout:setLeftMargin(232.2682)
layout:setRightMargin(241.7318)
layout:setTopMargin(329.6009)
layout:setBottomMargin(26.6941)
Image_gift:addChild(Text_desc)

--Create Animation
result['animation'] = ccs.ActionTimeline:create()
  
result['animation']:setDuration(0)
result['animation']:setTimeSpeed(1.0000)
--Create Animation List

result['root'] = Layer
return result;
end

return Result

