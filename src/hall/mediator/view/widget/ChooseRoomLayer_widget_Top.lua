local ChooseRoomLayer_widget_Top = class("ChooseRoomLayer_widget_Top",function ()
	return display.newLayer()
end)

local TopLayer = require("csb.hall.choose.ChooseRoomTop")
local ChooseRoomProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_CHOORSERM)
local ChooseRoomCfg = require("hall.mediator.cfg.ChooseRoomCfg")
import(".WhippedEggEvent", "WhippedEgg.event.")
local BankruptLayer = require("app.views.customwidget.BankruptLayer")
local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
--@param gType 游戏类型  1=比赛场，2=经典场，3=私人定制场
function ChooseRoomLayer_widget_Top:ctor(gType, gameid)
	self.gType = gType and gType or 2 --默认经典场
	if gameid and isdigit(gameid) then
		self.gameid = gameid
	else
		self.gameid = wwConfigData.GAMELOGICPARA.GUANDAN.GAME_ID
	end
	--self.gameid = gameid or 0 --默认经典场
	self.enterActions = {}--进入时的动作
	self.hasEnter = false
	self.handlers = {}
	self:init()
	
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
end

function ChooseRoomLayer_widget_Top:init()
	self.logTag = "ChooseRoomLayer_widget_Top.lua"
	print(self:getPositionY())
	local topNode =  TopLayer:create()
	local node = topNode.root
	--self.nodeAnim = topNode.animation
	--node:runAction(self.nodeAnim)
	--FixUIUtils.stretchUI(node)
	--FixUIUtils.setRootNodewithFIXED(node)
	
	self.imgId = node:getChildByName("Panel_bg")
	--FixUIUtils.stretchUI(self.imgId)
	self.startNode = self.imgId:getChildByName("FileNode_fStart")
	self:addChild(node)
	if self:eventComponent() then
		local _ = nil
		_,self.handlers[#self.handlers+1] = self:eventComponent()
			:addEventListener(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST,handler(self,self.perforActions))
		
	end
--根据GameID替换成相应的Title
	local Image_header = self.imgId:getChildByName("Image_header")
	local Image_title = Image_header:getChildByName("Image_title")
	Image_title:ignoreContentAdaptWithSize(true)
	if self.gameid == wwConfigData.GAME_ID then --掼蛋
		Image_title:loadTexture("hall/choose/chooserm_top_title_guandan.png")
	elseif self.gameid == wwConfigData.GAMELOGICPARA.BULLFIGHT.GAME_ID then --斗牛
		Image_title:loadTexture("hall/choose/chooserm_top_title_bullfight.png")
	end

	
end

function ChooseRoomLayer_widget_Top:getContentSize()
	return self.imgId:getContentSize() or cc.size(0,0)
end
function ChooseRoomLayer_widget_Top:onEnter()
	ccui.Helper:seekWidgetByName(self.imgId,"Button_back"):addTouchEventListener(handler(self,self.touchListener))
	--ccui.Helper:seekWidgetByName(self.imgId,"Button_fStart"):addTouchEventListener(handler(self,self.touchListener))
	self.startNode:getChildByName("Button_fStart"):addTouchEventListener(handler(self,self.touchListener))
	
	
end

function ChooseRoomLayer_widget_Top:perforActions(event)
	if event then
		if not event.userTag and not DataCenter:getData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST) then
			return
		end
		
		local data = DataCenter:getData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST)[event.userTag and event.userTag or 2]
		if not data then
			return
		end
		self.hasEnter = true
	end
	
	print("perform actions 2")
	--依次执行
	if self.enterActions then
		for i,v in ipairs(self.enterActions) do
			if self[v.action] then
				self[v.action](self,v.arg)
			end
		end
		removeAll(self.enterActions)
	end
end
function ChooseRoomLayer_widget_Top:onExit()
	removeAll(self.enterActions)
	self.hasEnter = false
	if self:eventComponent() then
		for _,v in ipairs(self.handlers) do
			self:eventComponent():removeEventListener(v)
		end
	end
end
--设置进入的动作
--@param 进入后需要调用的方法
function ChooseRoomLayer_widget_Top:setEnterAction(action,...)

	if self[action] then
		self.enterActions = self.enterActions or {}
		table.insert(self.enterActions,{action = action,arg = ...})
		if self.hasEnter then
			print("perform actions")
			self:perforActions()
		end
	end
end

function ChooseRoomLayer_widget_Top:performClick()
	if isLuaNodeValid(self.startNode) then
		self:touchListener(self.startNode:getChildByName("Button_fStart"),ccui.TouchEventType.ended)
	end
end
--获取能进入的最小的房间
--@param myCash 我的金币
function ChooseRoomLayer_widget_Top:getMinEnterRoomData(tempGameZone)
	local gamezone = {}
	copyTable(tempGameZone,gamezone)
	table.sort(gamezone,function (ga,gb)
		return ga.FortuneMin < gb.FortuneMin --顺序
	end)
	return gamezone[1]
end


--播放按钮的动画特效
function ChooseRoomLayer_widget_Top:playButtonAnim()
	self.startNode.animation:play("animation0",true)
end
function ChooseRoomLayer_widget_Top:touchListener(pSender,eventType)
	if not pSender then
		return
	end
	
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		local name = pSender:getName()
		if name=="Button_back" then
		
			FSRegistryManager:runWithFSM(FSMConfig.FSM_HALL):trigger("back")
		
		elseif name == "Button_fStart" then
			print("fast start")
			local myCash = tonumber(DataCenter:getUserdataInstance():getValueByKey('GameCash'))
			local allData = DataCenter:getData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST)
			print("myCash",myCash)
			if not allData or not allData[self.gType] or not next(allData[self.gType].looptab1) then
				--
				print("房间数据还未获取到")
				return
			end

			UmengManager:eventCount("ClassicStart") 

			local tempGameZone = allData[self.gType].looptab1
			local gamezone = {}
			copyTable(tempGameZone,gamezone)
			table.sort(gamezone,function (ga,gb)
				return ga.FortuneMin > gb.FortuneMin
			end)
			local enterGamedata = nil
			local maxFor = 0
			for _,gamedata in pairs(gamezone) do
				maxFor = gamedata.FortuneMax
				
				if myCash >= gamedata.FortuneMin and (maxFor <= 0 and true or myCash<=maxFor) then
					enterGamedata = gamedata
					break
				end
			end
			if enterGamedata then
				wwlog(self.logTag,"发送进入游戏大厅事件")
				if self.gameid == wwConfigData.GAME_ID then --掼蛋
					ChooseRoomProxy:requestEnterGame(enterGamedata.GameZoneID)
					FSRegistryManager:clearFSM()
					local gameType = Game_Type.ClassicalPromotion
					if enterGamedata.PlayType == Play_Type.PromotionGame then
						gameType = Game_Type.ClassicalPromotion
					elseif enterGamedata.PlayType == Play_Type.RandomGame then
						gameType = Game_Type.ClassicalRandomGame
					elseif enterGamedata.PlayType == Play_Type.RcircleGame then
						gameType = Game_Type.ClassicalRcircleGame
					end
					WWFacade:dispatchCustomEvent(WHIPPEDEGG_SCENE_EVENTS.MAIN_ENTRY,gameType,enterGamedata.GameZoneID,enterGamedata.fortuneBase)
				elseif self.gameid == wwConfigData.GAMELOGICPARA.BULLFIGHT.GAME_ID then --斗牛
					WWFacade:dispatchCustomEvent(BULLFIGHTING_SCENE_EVENTS.MAIN_ENTRY, gameType, enterGamedata.GameZoneID, enterGamedata.fortuneBase)
				else
					self.clickItem = false
					wwlog(self.logTag,"异常了，异常了，gameid不对"..tostring(self.gameid))
				end
	
				
			else
				--破产了
				print("没钱了，连最低场都不能进")
				enterGamedata = self:getMinEnterRoomData(tempGameZone)
				local para = {}	
				para.money = enterGamedata.FortuneMin - myCash
				para.layerType = 2  --界面类型  2 破产
				para.sceneTag = 1 --在哪个场景
				para.upCloseOnClick = true
				para.upCallback = function ()
					--购买金币  打开商城
					print("购买金币")
					self.clickItem = false

					local sIDKey 
					if para.layerType == 1 then --金币不足
						sIDKey = "GoldEnough"
					elseif para.layerType == 2 then --破产 then --破产
						sIDKey = "Bankrupt"
					end
					
					FSRegistryManager:currentFSM():trigger("store", 
					{parentNode=display.getRunningScene(), zorder=4,store_openType=2, sceneIDKey = sIDKey})
						
				end --上面按钮响应
				para.downCloseOnClick = false --下边的按钮点击不自动关闭
				para.downCallback = function ()
					
					if para.layerType==2 then
						print("领取救济金")
						HallSceneProxy:requestBankruptAward()
					else
						print("去低倍场次")
						
						
					end
					self.clickItem = false
				end --下面按钮响应
				
				local bankrupt = BankruptLayer:create(para)
				bankrupt:show(3)
			end
			
		end
	end
	
	
	
end
function ChooseRoomLayer_widget_Top:eventComponent()
	return ChooseRoomCfg.innerEventComponent
end


return ChooseRoomLayer_widget_Top