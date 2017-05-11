-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal
-- Date:    2016.09.10
-- Last: 
-- Content:  d道具列表tableview
-- Modify : 2016-12-11 diyal 修改道具的排序
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local Store_Proplist = class("Store_PropList", function()
    return display.newNode()
end)

local StoreCfg = require("hall.mediator.cfg.StoreCfg")

local StoreProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_StoreProxy)

local Node_store_prop = require("csb.hall.store.Node_store_prop")

local SimpleRichText = require("app.views.uibase.SimpleRichText")

function Store_Proplist:ctor(bgNode, shopType)
	self.tableViewBg = bgNode
	self.shopType = shopType
	self._shopdatas = {}
	
	self:init()
end

function Store_Proplist:init()
	
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)

	self:initView()
end 

function Store_Proplist:initView()

	local tableView = cc.TableView:create(self.tableViewBg:getContentSize())
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

	tableView:setContentSize(cc.size(self.tableViewBg:getContentSize().width, self.tableViewBg:getContentSize().height * 0.8))
	tableView:setPosition(cc.p(10, 1))
	tableView:setDelegate()
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self.tableViewBg:addChild(tableView)
	--registerScriptHandler functions must be before the reloadData funtion
	tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
	tableView:registerScriptHandler(handler(self, self.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
	tableView:registerScriptHandler(handler(self, self.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
	tableView:registerScriptHandler(handler(self, self.tableCellTouched),cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(handler(self, self.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(handler(self, self.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
	tableView:reloadData()

	self._tableView = tableView

end

function Store_Proplist:scrollViewDidScroll(view)
    -- print("scrollViewDidScroll")
end

function Store_Proplist:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function Store_Proplist:tableCellTouched(table,cell)
    -- print("cell touched at index: " .. cell:getIdx())
end

function Store_Proplist:cellSizeForTable(table,idx) 
    return self.tableViewBg:getContentSize().width, self.tableViewBg:getContentSize().height / 2.2
end

--获取行数
function Store_Proplist:getItemRowNum()
	local rowNum

	if self._shopdatas.StoreInfos == nil then
		rowNum = 0
	else
		rowNum = math.ceil(#self._shopdatas.StoreInfos / 3)
	end

	return rowNum
end

function Store_Proplist:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local item = nil
    -- if nil == cell then
        cell = cc.TableViewCell:new()
        cell:setContentSize(self.tableViewBg:getContentSize().width, self.tableViewBg:getContentSize().height / 2.2)

        local nowCell = idx + 1
        local nowLefttCell, nowCenterCell, nowRightCell = (nowCell * 3 -2), (nowCell * 3 - 1), (nowCell * 3)

        if nowLefttCell <= #self._shopdatas.StoreInfos then
	        item = self:createItem(nowLefttCell)
	        cell:addChild(item)
	        item:setPositionX(cell:getContentSize().width * (1/6))
	        item:setPositionY(cell:getContentSize().height/2)
	    end

        if nowCenterCell <= #self._shopdatas.StoreInfos then
        	wwlog("创建中", nowCell.. " - " .. nowCenterCell)
        	--创建右边Item
        	item = self:createItem(nowCenterCell)
        	cell:addChild(item)
        	item:setPositionX(cell:getContentSize().width * (3/6))
        	item:setPositionY(cell:getContentSize().height/2)
        end

        if nowRightCell <= #self._shopdatas.StoreInfos then
        	wwlog("创建右", nowCell.. " - " .. nowRightCell)
        	--创建右边Item
        	item = self:createItem(nowRightCell)
        	cell:addChild(item)
        	item:setPositionX(cell:getContentSize().width * (5/6))
        	item:setPositionY(cell:getContentSize().height/2)
        end
  --   else
  --       item = cell:getChildByName("Node")
		-- item:getChildByName("Image_bg"):setTag(idx)
  --   end

    return cell
end

function Store_Proplist:createItem(index, new)
	local item = Node_store_prop:create().root

	local bg = item:getChildByName("Image_bg")
	bg:setSwallowTouches(false)

	item:setContentSize(bg:getContentSize())

	local cellData = self._shopdatas.StoreInfos[index][1]

	wwdump(cellData, "道具信息")

	local fid = cellData.fid

	local goodInfo = getGoodsByFid(fid)

	local Image_icon = ccui.Helper:seekWidgetByName(bg,"Image_icon")
	Image_icon:setTouchEnabled(true)
	-- Image_icon:loadTexture(goodInfo.src)

	local netSprite = ToolCom:createGoodsSprite(cellData.MagicID)
	-- Image_icon:loadTexture(netSprite:getTexture())
	netSprite:setPosition(Image_icon:getPosition())
	Image_icon:getParent():addChild(netSprite)
	-- Image_icon:setVisible(false)

	local name = ccui.Helper:seekWidgetByName(bg,"Text_content")
	name:setString(cellData.Name .. "x".. (cellData.magicCount))
	local Image_buy = ccui.Helper:seekWidgetByName(bg,"Image_buy")
	-- local Text_buy = ccui.Helper:seekWidgetByName(bg,"Text_buy")
	-- Text_buy:setString(cellData.Money)

	local Image_desc = ccui.Helper:seekWidgetByName(bg,"Image_desc")

	Image_icon:addTouchEventListener(handler(self, self.touchEventListener))
	Image_icon:setTag(index) 

	Image_buy:addTouchEventListener(handler(self, self.bugClick))
	Image_buy:setTag(index) 
	Image_buy:setSwallowTouches(true)

	local richtextStr = string.format(i18n:get("str_store", "showBtnRich1"),
		"common/common_gold_50.png", tonumber(cellData.Money))
	local btnRichtext = SimpleRichText:create(richtextStr,32,cc.c3b(255,255,255))
	btnRichtext:setAnchorPoint(cc.p(0.5,0.5))
	btnRichtext:setPosition(cc.p(Image_buy:getContentSize().width * 0.5,Image_buy:getContentSize().height * 0.5))
	
	Image_buy:addChild(btnRichtext)

	if index == 1 then
		self:firstSwitchNumTip(Image_desc)
		Image_desc:setLocalZOrder(ww.centerOrder)
	else
		Image_desc:setVisible(false)
	end

	return item
end

--第一个商品，展示3秒后淡出
function Store_Proplist:firstSwitchNumTip(node)
	node:runAction(cc.Sequence:create(
		cc.DelayTime:create(StoreCfg.SwitchTipTime),
		cc.FadeOut:create(0.3),
		cc.RemoveSelf:create(true)))
end

function Store_Proplist:numberOfCellsInTableView(table)
   return self:getItemRowNum()
end

function Store_Proplist:touchEventListener(sender, eventType)
	if not sender or self._tableView:isTouchMoved() then
		return
	end
	
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		local cellIndex = sender:getTag()

		--将当前数据中的选择的项目 +1
		local tmpCurSelectIndex = self._shopdatas.IndexInfos[cellIndex].curIndex + 1
		if tmpCurSelectIndex > #self._shopdatas.StoreInfos[cellIndex] then
			tmpCurSelectIndex = 1
		end

		print(tmpCurSelectIndex, self._shopdatas.StoreInfos[cellIndex][tmpCurSelectIndex])
		self._shopdatas.IndexInfos[cellIndex].curIndex = tmpCurSelectIndex

		local cellData = self._shopdatas.StoreInfos[cellIndex][tmpCurSelectIndex]

		wwdump(self._shopdatas.IndexInfos)
		-- wwdump(cellData, tmpCurSelectIndex)

		local Image_buy = ccui.Helper:seekWidgetByName(sender:getParent(),"Image_buy")

		local name = ccui.Helper:seekWidgetByName(sender:getParent(),"Text_content")
		name:setString(cellData.Name .. "x".. (cellData.magicCount))

		Image_buy:removeAllChildren()

		local richtextStr = string.format(i18n:get("str_store", "showBtnRich1"),
			"common/common_gold_50.png", tonumber(cellData.Money))
		local btnRichtext = SimpleRichText:create(richtextStr,32,cc.c3b(255,255,255))
		btnRichtext:setAnchorPoint(cc.p(0.5,0.5))
		btnRichtext:setPosition(cc.p(Image_buy:getContentSize().width * 0.5,Image_buy:getContentSize().height * 0.5))
		
		Image_buy:addChild(btnRichtext)
	end
end

function Store_Proplist:bugClick(sender, eventType)
	local cellIndex = sender:getTag()
	if eventType==ccui.TouchEventType.ended then
		local cellIndex = sender:getTag()
		wwlog("点击购买", cellIndex)

		local curSelectIndex = self._shopdatas.IndexInfos[cellIndex].curIndex
		local cellData = self._shopdatas.StoreInfos[cellIndex][curSelectIndex]

		local Name = cellData.Name
		local Money = cellData.Money
		local Count = cellData.magicCount

		local function dialogOk()
			--调用购买流程
			StoreProxy:requestBuyProp(cellData, wwConfigData.CHARGE_STORE_PROP) 

		end

		local function dialogCance()
		end

		local para = {}
		para.leftBtnlabel = i18n:get("str_common", "comm_cancel")
		para.rightBtnlabel = i18n:get("str_common", "comm_sure")
		para.leftBtnCallback = dialogCance
		para.rightBtnCallback = dialogOk
		para.showclose = false  --是否显示关闭按钮
		para.content = string.format(i18n:get("str_store", "store_prop_confirm"), 
						Money, Name,Count)

		import(".CommonDialog", "app.views.customwidget."):create( para ):show()

		UmengManager:eventCount("PropBuyClick") --点击了购买按钮
	end

end

function Store_Proplist:reflashView(shopdatas)
	if not next(shopdatas) then
		return
	end
	--20170207
	self._shopdatas = clone(shopdatas) or {}
	-- wwdump(self._shopdatas)
	self._shopdatas.IndexInfos = {}

	if self._shopdatas.IndexInfos then
		local tbahead = self._shopdatas.StoreInfos
		self._shopdatas.StoreInfos = reverseTable(tbahead)
	end

	for i,v in ipairs(self._shopdatas.StoreInfos) do
		--点击切换数量业务需求，为每组Item设置一个当前选择的数据索引
		local cell ={}
		cell.curIndex = 1
		table.insert(self._shopdatas.IndexInfos, cell)
	end

	-- wwdump(self._shopdatas.StoreInfos)

	self._tableView:reloadData()
end

return Store_Proplist