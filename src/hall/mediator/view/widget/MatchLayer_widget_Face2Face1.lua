-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.13
-- Last: 
-- Content:  比赛界面添加好友控件 面板
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local MatchLayer_widget_Face2Face1 = class("MatchLayer_widget_Face2Face1",ccui.Layout)
local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)
local MatchCfg = require("hall.mediator.cfg.MatchCfg")
function MatchLayer_widget_Face2Face1:ctor(size)
	self.size = size
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	self:setName("MatchLayer_widget_Face2Face1")
	self:init()
	
end

function MatchLayer_widget_Face2Face1:init()
	print("MatchLayer_widget_Face2Face1:init")
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
	self.panelNumber = require("csb.hall.match.MatchLayer_widget_panelNumber"):create().root
	FixUIUtils.setRootNodewithFIXED(self.panelNumber)
	local panel1 = self.panelNumber:getChildByName("Panel_1")
		
	FixUIUtils.stretchUI(panel1)
	self:addChild(self.panelNumber,1)
	local numberGroup = ccui.Helper:seekWidgetByName(panel1,"Panel_number1")
	
	self.numbers = {} --存储所有数字控件
	self.inputIndex = 1 --当前输入的索引
	
	local len = 4
	for x=1,len do
		local textLabel = ccui.Helper:seekWidgetByName(numberGroup,string.format("Text_%d",x))
		textLabel:setString("")
		table.insert(self.numbers,textLabel)
	end
	local panelGroup = ccui.Helper:seekWidgetByName(panel1,"Panel_number2")
	
	for _,v in pairs(panelGroup:getChildren()) do
		v:addTouchEventListener(handler(self,self.touchListener))
	end
	--ccui.Helper:seekWidgetByName(panel1,"Image_weixin"):addTouchEventListener(handler(self,self.touchListener))
	--ccui.Helper:seekWidgetByName(panel1,"Image_addf"):addTouchEventListener(handler(self,self.touchListener))
end 
--数字输入完毕的回调
function MatchLayer_widget_Face2Face1:bindChangeFun(cbFun)
	
	self._cbFun = cbFun
end

function MatchLayer_widget_Face2Face1:eventComponent()
	
end

function MatchLayer_widget_Face2Face1:onEnter()
	

	
end
--table转换成整数
local function table2Number(t,len)
	local retNum = 0
	
	for x=len,1,-1 do
		if t[x] then
			local i = tonumber(t[x]:getString())
			retNum = retNum+math.pow(10,len- x)*i
			
		end
	end
	
	
	return retNum
end
--table转换成整数table
local function table2Number2(t,len)
	local retNumTable = {}
	
	for x=len,1,-1 do
		if t[x] then
			local i = tonumber(t[x]:getString())
			--retNum = retNum+math.pow(10,len- x)*i
			table.insert(retNumTable,x,i)
		end
	end
	
	return retNumTable
end

function MatchLayer_widget_Face2Face1:addNumber(number)
	if self.inputIndex<= #self.numbers then
		
		self.numbers[self.inputIndex]:setString(tostring(number))
		self.inputIndex = self.inputIndex + 1
		--self.inputIndex = math.min(self.inputIndex,#self.numbers)
		
		if self.inputIndex>#self.numbers then
			--超过啦 发送请求
			print("发送添加好友请求")
			if self._cbFun then
				--清空搜索到的好友信息
				DataCenter:clearData(MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_FACE_ALL)
			
				DataCenter:clearData(MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_FACE)
				--请求服务器
				
				MatchProxy:requestFriend(3,table2Number(self.numbers,4))
				
				MatchCfg.matchSendnumberTime = os.time() --当前发送数字的时间
				MatchCfg.searchSendnumbers = table2Number2(self.numbers,4)
				self._cbFun(MatchCfg.searchSendnumbers)
			end
		end
	else
		
		
	end
end


function MatchLayer_widget_Face2Face1:delete()
	self.inputIndex = self.inputIndex - 1
	self.inputIndex = math.max(self.inputIndex,1)
	self.inputIndex = math.min(self.inputIndex,#self.numbers)
	if self.inputIndex >= 1 then
		self.numbers[self.inputIndex]:setString("")
		
	end
end
function MatchLayer_widget_Face2Face1:clear()
	for x=1,#self.numbers do
		self:delete()
	end
end

function MatchLayer_widget_Face2Face1:touchListener(ref,eventType)
	if not ref then
		return
	end
	local btn = tolua.cast(ref,"ccui.Button")
	if eventType==ccui.TouchEventType.ended then
		if btn then
			btn:setTitleColor(cc.c3b(0x26,0x2f,0x2a))
		end
		local name = ref:getName()
		playSoundEffect("sound/effect/anniu")
		
		if name == "Button_clear" then
			self:clear()
		elseif name == "Button_delete" then
			self:delete()
		elseif isdigit(rsubStringBack(name,"Button_")) then
			local number = tonumber(rsubStringBack(name,"Button_"))
			self:addNumber(number)
		end
	elseif eventType == ccui.TouchEventType.began then
		if btn then
			btn:setTitleColor(cc.c3b(0xf4,0xff,0xe5))
		end
	elseif eventType == ccui.TouchEventType.canceled or
	eventType == ccui.TouchEventType.moved then
		if btn then
			btn:setTitleColor(cc.c3b(0x26,0x2f,0x2a))
		end
	end
	
	
	
end

function MatchLayer_widget_Face2Face1:onExit()
	
	
end


return MatchLayer_widget_Face2Face1