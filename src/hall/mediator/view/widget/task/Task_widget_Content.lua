-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.22
-- Last: 
-- Content:  任务页面控件
-- Modify:	
--		2016/12/1	修改新建item动画时机 初次新建的才有动画，后边的不要了
--		2017/1/4	修改背景框显示条件，任务达成并且未领取时显示
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local Task_widget_Content = class("Task_widget_Content",function ()
	return ccui.Layout:create()
end)


local NodeTaskItem = require("csb.hall.dailyTask.NodeTaskItem")
local NodeTaskEmpty = require("csb.hall.dailyTask.NodeTaskEmpty")
local TaskCfg = import(".TaskCfg","hall.mediator.cfg.")
local HallCfg = import(".HallCfg","hall.mediator.cfg.")

local Toast = require("app.views.common.Toast")

require("hall.data.TaskManager")
require("hall.data.TaskFactory")

local TaskProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_TaskProxy)

local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)

function Task_widget_Content:ctor(canAnim,size)
	print("Task_widget_Content init.....")
	self.size = size --显示尺寸
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	self.taskData = {}
	self.handlers = {}
	self.hallHandlers = {}
	self.taskCount = 0
	self.canAnim = canAnim --创建的时候是否允许动画
	self.scrollTime = 0 --滚动次数
	
	self.offsetPos = nil
	self:init()
	
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
end


function Task_widget_Content:init()
	
	
	
	self.tableView = cc.TableView:create(cc.size(self.size.width,self.size.height))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setPosition(cc.p(0,0))
    self.tableView:setDelegate()
    self:addChild(self.tableView,1)
	self.tableView:setVerticalFillOrder(0) --竖直方向 填充顺序 从上到下
    self.tableView:registerScriptHandler(handler(self,Task_widget_Content.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(handler(self,Task_widget_Content.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(handler(self,Task_widget_Content.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(handler(self,Task_widget_Content.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self,Task_widget_Content.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(handler(self,Task_widget_Content.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self.tableView:registerScriptHandler(handler(self,Task_widget_Content.scrollViewWillRecycle),cc.TABLECELL_WILL_RECYCLE)
	--TABLECELL_WILL_RECYCLE
	if self.canAnim then
		self.tableView:setTouchEnabled(false)	
	end
	
end

function Task_widget_Content:onEnter()
	
	print("Task_widget_Content:onEnter")
	--TaskCfg.InnerEvents.TASK_EVENT_TASKLIST
	if self:eventComponent() then
		local _ = nil
		_,self.handlers[#self.handlers+1] = self:eventComponent():addEventListener(TaskCfg.InnerEvents.TASK_EVENT_TASKLIST,handler(self,self.setTaskData))
		
	end
	if self:hallEventComponent() then
		local _ = nil
		_,self.hallHandlers[#self.hallHandlers+1] = self:hallEventComponent():
			addEventListener(HallCfg.InnerEvents.HALL_EVENT_EQUIPMENT_NUMBER,handler(self,self.setMagicIds))
		_,self.hallHandlers[#self.hallHandlers+1] = self:hallEventComponent():
			addEventListener(TaskCfg.InnerEvents.TASK_EVENT_SHAREMESSAGE,handler(self,self.active))
	end
	TaskProxy:requestTaskList()
	LoadingManager:startLoading(1.4,LOADING_MODE.MODE_TOUCH_CLOSE)
end


function Task_widget_Content:onExit()
	
	print("Task_widget_Content:onExit")
	if self:eventComponent() then
		for _,v in pairs(self.handlers) do
			self:eventComponent():removeEventListener(v)
		end
		
	end
	if self:hallEventComponent() then
		for _,v in pairs(self.hallHandlers) do
			self:hallEventComponent():removeEventListener(v)
		end
		
	end
	removeAll(self.handlers)
	removeAll(self.hallHandlers)
	if self.taskTempData then
		removeAll(self.taskTempData)
	end
	if self.taskTempData then
		removeAll(self.taskData)
	end
	
	self.taskCount = 0
	
end

function Task_widget_Content:active()
	
end
--物品ID 消息通知
function Task_widget_Content:setMagicIds(event)
	if event.name == HallCfg.InnerEvents.HALL_EVENT_EQUIPMENT_NUMBER then
		if not self.taskTempData then
			return
		end
		local taskMsg = self:containsMagicId(event._userdata.magicID)
		if event._userdata and taskMsg then
			taskMsg.taskAwards = {}
			--table.merge(event._userdata.goodsInfo[1],{magicCount = 100})
			--table.merge(taskMsg.taskAwards,event._userdata.goodsInfo)
			copyTable(event._userdata.goodsInfo,taskMsg.taskAwards)
			
		end
		--wwdump(self.taskData)
		
		if self:magicsComplete() then
			--对task进行排序
			local tempData = clone(self.taskTempData)
			--wwdump(tempData,"刷新任务1",4)
		
			self.taskData = TaskCfg.sort(self.taskTempData)
			removeAll(tempData)
			self.taskCount = table.maxn(self.taskData)
			--wwdump(self.taskData,"刷新任务2",4)
			if isLuaNodeValid(self.tableView) then
				self.tableView:reloadData()
		
				if self.offsetPos then
					self.tableView:setContentOffset(self.offsetPos)
					self.tableView:setTouchEnabled(true)
				end
				LoadingManager:endLoading()
				self.tableView:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
					self.tableView:setTouchEnabled(true)
				end)))
			end
		end
	end
	
end
--判断所有物品是否都存在了
function Task_widget_Content:magicsComplete()
	local allGot = true
	for _,v in pairs(self.taskTempData) do
		if not v.taskAwards then
			allGot = false
			break
		end
	end
	return allGot
end

--是否包含道具
function Task_widget_Content:containsMagicId(mid)
	local taskMsg = nil
	for _,v in pairs(self.taskTempData) do
		if v.MagicID==mid and not v.taskAwards then
			taskMsg = v
			break
		end
	end
	return taskMsg
end

--设置数据
function Task_widget_Content:setTaskData(event)
	
	if event.name==TaskCfg.InnerEvents.TASK_EVENT_TASKLIST then
		local taskDatas = DataCenter:getData(TaskCfg.InnerEvents.TASK_EVENT_TASKLIST)
		if taskDatas and taskDatas.TaskList then
			local temp = {}
			copyTable(taskDatas.TaskList,temp)
			self.taskTempData = temp
			if self.taskTempData then
				
			end
		end
		
	end
	--wwdump(self.taskTempData,"任务消息")
	self.taskCount = table.maxn(self.taskTempData)
	
	if self.taskCount==0 then
		LoadingManager:endLoading()
		local emptyNode = NodeTaskEmpty:create().root
		emptyNode:setName("emptyNode")
		emptyNode:setPosition(cc.p(self.size.width/2,self.size.height/2))
		self:addChild(emptyNode,2)
	else
		self:removeChildByName("emptyNode")
	end
	
	for _,v in pairs(self.taskTempData) do
		--self.taskData.MagicID
		--在通过物品ID 去取道具包
		if not v.taskAwards then
			HallSceneProxy:requestGoodsBox(5,v.MagicID)
		end
	end

end

function Task_widget_Content:scrollViewWillRecycle(view)
	self.canAnim = false
end
function Task_widget_Content:numberOfCellsInTableView(view)
	
	return self.taskCount
end

function Task_widget_Content:scrollViewDidScroll(view)
	if self.canAnim then
		self.scrollTime = self.scrollTime +1
		if self.scrollTime > 1 then
			self.canAnim = false
			self.scrollTime = 0
		end
	end
end

function Task_widget_Content:scrollViewDidZoom(view)
	
end
function Task_widget_Content:tableCellTouched(view,cell)
	print("Task_widget_Content tableCellTouched...",cell:getIdx())
	
end
function Task_widget_Content:cellSizeForTable(view,idx)

	return 827.00,220

end
function Task_widget_Content:createTaskNode(view,cell,idx)
	
	local taskNode = NodeTaskItem:create().root
	--signNode:setAnchorPoint(0.5,0.5)
	local btnGo = taskNode:getChildByName("Image_bg"):getChildByName("Button_go")
	btnGo:setSwallowTouches(false)
	btnGo:addTouchEventListener(handler(self,Task_widget_Content.touchEventListener))
	taskNode:setPositionX((0.5)*self.size.width)
	taskNode:setPositionY(0)
	taskNode:setName("taskNode")
	taskNode:setTag(idx)
	--Image_icon
	--taskNode:getChildByName("Image_bg"):getChildByName("Image_icon"):setVisible(false)
	if self.canAnim then
		taskNode:setPositionX(self.size.width*2)
		taskNode:runAction(cc.EaseSineOut:create(cc.MoveTo:create(0.09*(idx+1),cc.p((0.5)*self.size.width,0))))
	end

	
	--
	
	return taskNode
end


function Task_widget_Content:tableCellAtIndex(view,idx)
	
    local cell = view:dequeueCell()
	local titem = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
		titem = self:createTaskNode(view,cell,idx)		
		cell:addChild(titem)
	else
		titem = cell:getChildByName("taskNode")
    end
	cell:setTag(idx)
	titem:setTag(idx)
	local imgBg = titem:getChildByName("Image_bg")
	local frame = titem:getChildByName("Image_frame")
	
	local btnGo = ccui.Helper:seekWidgetByName(imgBg,"Button_go")
	--frame:setVisible(true)
	local textCount = ccui.Helper:seekWidgetByName(imgBg,"Text_count")
	local textDesc = ccui.Helper:seekWidgetByName(imgBg,"Text_desc")
	local textProgress = ccui.Helper:seekWidgetByName(imgBg,"Text_progress")
	local data = self.taskData[idx+1]
	btnGo:setTag(idx)
	
	local imgIcon = ccui.Helper:seekWidgetByName(imgBg,"Image_icon")
	imgIcon:setVisible(false)
	textCount:setVisible(false)
	--imgBg:removeChildByName("Image_icon_1")
	if data.taskAwards and next(data.taskAwards) then
		--目前只显示1个
		local taskaward = data.taskAwards[1]
		textCount:setVisible(true)
		textCount:setString(string.format("x%s",ToolCom.splitNumFix(tonumber(taskaward.magicCount))))
		local goodsrc = getGoodsSrcByFid(taskaward.FID)
		if goodsrc and cc.FileUtils:getInstance():isFileExist(goodsrc) then
			imgIcon:setVisible(true)
			imgIcon:loadTexture(goodsrc)
		end
	end
	
	self:updateButton(btnGo,data.Status) 
	self:updateFrame(frame,data.Status)
	--textCount:setString(string.format("x%d",data.count))
	textDesc:setString(data.Name) --任务名称
	self:updateProgress(textProgress,data.Status,data.FinishCount,data.TargetValue)
	--wwdump(data,"idx")
	--wwlog("idx",idx)
	
	if data.Status~=2 then
		local task = nil
		if not TaskManager:checkTask(data.TaskID) then
			--data.TaskType  任务类型 	1：社交任务		2：牌局任务
			local taskType = (data.TaskType==1 and TaskCfg.TaskType.TASK_SHARE or TaskCfg.TaskType.TASK_PLAYCARD)
			local task = TaskFactory:createTask(taskType)
			TaskManager:addTask(data.TaskID,task)
			--print("任务创建成功")
		else
			task = TaskManager:getTask(data.TaskID)
			--print("获取已经创建的任务")
		end
		--data.FID  任务功能ID  10170001  微信分享  10170002  经典场对局	10170003  经典场赢局
		task:init({taskId = data.TaskID,fid = data.FID,awards = data.taskAwards })
		
		
	elseif data.Status == 2 then
		TaskManager:removeTask(data.TaskID)
		
	end

	
    return cell
end
--修改背景显示以及状态
--任务状态：0：未完成	1：已完成 (待领奖)	2：已领取奖励
function Task_widget_Content:updateFrame(frame,status)
	frame:setVisible(status==1)
end
--修改按钮显示以及状态
--任务状态：0：未完成	1：已完成 (待领奖)	2：已领取奖励
function Task_widget_Content:updateButton(btnGo,status)
	btnGo:setBright(status~=2)
	if status==0 then
		btnGo:loadTextureNormal("dailyTask_btn_1.png",1)
		btnGo:setTitleText(i18n:get('str_dailytask','btn_go'))
	elseif status == 1 then
		btnGo:loadTextureNormal("dailyTask_btn_2.png",1)
		btnGo:setTitleText(i18n:get('str_dailytask','btn_get'))
	elseif status == 2 then
		btnGo:setTitleText(i18n:get('str_dailytask','btn_over'))
	end
end
--修改进度
--任务状态：0：未完成	1：已完成 (待领奖)	2：已领取奖励
--@param textProgress 进度显示控件
--@param status 任务状态 
--@param FinishCount 已经完成的目标数量
--@param TargetValue 完成任务的目标值
function Task_widget_Content:updateProgress(textProgress,status,finishCount,targetValue)
	--TargetValue  FinishCount
	textProgress:setString(string.format("%d/%d",finishCount,targetValue))
	
	if status==2 then
		textProgress:setTextColor({r = 0x3e, g = 0x32, b = 0x1c})
	else
		if finishCount<=targetValue then
			textProgress:setTextColor({r = 0x9e, g = 0x23, b = 0x11})
		else
			textProgress:setTextColor({r = 0x3e, g = 0x32, b = 0x1c})
		end
		
	end
	
end
function Task_widget_Content:touchEventListener(ref,eventType)
	if not ref or self.tableView:isTouchMoved() or not ref:isBright() then
		return
	end

	--print("eventType",eventType)
	if eventType==ccui.TouchEventType.ended then
	
		playSoundEffect("sound/effect/anniu")
		
		if ref:getName()=="Button_go" then
			self.offsetPos = self.tableView:getContentOffset()
			local data = self.taskData[ref:getTag()+1]
			if data.Status==0 then
				TaskManager:changeTaskState(data.TaskID,TaskCfg.TaskState.TASK_TODO)
			elseif data.Status == 1 then
				TaskManager:changeTaskState(data.TaskID,TaskCfg.TaskState.TASK_DONE)
				self:updateButton(ref,2) 
			end
			
--[[		TaskManager:changeTaskState(ref:getTag(),TaskCfg.TaskState.TASK_PROGRESS)
			TaskManager:changeTaskState(ref:getTag(),TaskCfg.TaskState.TASK_DONE)
			TaskManager:changeTaskState(ref:getTag(),TaskCfg.TaskState.TASK_FINISHED)--]]
		end
		
	end
	

end

function Task_widget_Content:eventComponent()
	return TaskCfg.innerEventComponent
end

function Task_widget_Content:hallEventComponent()
	return HallCfg.innerEventComponent
end


return Task_widget_Content