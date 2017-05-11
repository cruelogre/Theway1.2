-------------------------------------------------------------------------
-- Title:       排行榜
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local Exchange = class("Exchange", require("app.views.uibase.PopWindowBase"), require("packages.mvc.Mediator"))
local ExchangeCfg = require("hall.mediator.cfg.ExchangeCfg")
local ExchangeProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().ExchangeProxy)
local HallProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
local userData = DataCenter:getUserdataInstance()
local csbMainPath = "csb.hall.exchange.common"
local csbExchangeListPath = "csb.hall.exchange.main"
local getStr = function(flag) return i18n:get("str_exchange", flag) end
local getComStr = function(flag) return i18n:get("str_common", flag) end
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end

function Exchange:ctor()
    self.logTag = "Exchange.lua"
    self.uis = { }
    -- tableView
    self._listView = nil
    -- 兑换列表数据
    self._info = nil
    self._tmpData = { }
    self._listener = nil
    self._listenerCrystalCount = nil

    self.super.ctor(self)
    self:init()
    self:registerScriptHandler( function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end )
    performFunction( function()
        -- 请求兑换列表
        ExchangeProxy:requestExchangeList()
        -- 刷新水晶数量
        HallProxy:requestGoodsCount(getGoodsByFlag("shuij").fid)
    end , 0.20)
end

function Exchange:onEnter()
    self.super.onEnter(self)
    for k, v in pairs(ExchangeCfg.InnerEvents) do
        ExchangeCfg.innerEventComponent:addEventListener(v, handler(self, self._handleProxy))
    end
    self._listenerCrystalCount = WWFacade:addCustomEventListener(COMMON_EVENTS.C_GOODS_COUNT_UPDATE, function(event)
        local fid, count = unpack(event._userdata)
        if fid == getGoodsByFlag("shuij").fid then
            self.uis.crystal_count:setString(ToolCom.splitNumFix(count))
        end
    end )
    self._listener = WWFacade:addCustomEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, function(event)
        local handleType = unpack(event._userdata)
        if handleType == 1 then
            -- 个人数据刷新
            self.uis.crystal_count:setString(ToolCom.splitNumFix(userData:getGoodsAttrByName("shuij", "count") or 0))
        end
    end )
end

function Exchange:onExit()
    -- 注销监听广播的句柄
    if self._listenerCrystalCount then
        WWFacade:removeEventListener(self._listenerCrystalCount)
    end
    self:unregisterEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO)
    if self._listener then
        WWFacade:removeEventListener(self._listener)
    end
    self.super.onExit(self)
end

function Exchange:init()
    local bgCommon = require(csbMainPath):create().root:addTo(self)
    local imgBg = bgCommon:getChildByName("bg_com")
    local titleBg = imgBg:getChildByName("img_top_com")
    local container = imgBg:getChildByName("container")
    require(csbExchangeListPath):create().root:addTo(container)

    self._tmpData.width_list_bg, self._tmpData.height_list_bg = 1020, cc.Director:getInstance():getWinSize().height - titleBg:height() -100
    local listBg = display.newSprite("common/common_bg_2.png", { scale9 = true }):setPreferredSize(cc.size(self._tmpData.width_list_bg, self._tmpData.height_list_bg)):setName("list_bg"):addTo(imgBg)
    listBg:pos(cc.p(imgBg:width2(), listBg:height2())):offsetY(10)

    ToolCom.traverseNode(bgCommon, handler(self, self._initView), self.uis)

    FixUIUtils.setRootNodewithFIXED(bgCommon)
    FixUIUtils.stretchUI(imgBg)

    self:popIn(imgBg, Pop_Dir.Right)

    self:setDisCallback( function(...)
        FSRegistryManager:currentFSM():trigger("back")
    end )
end

function Exchange:_initView(name, node)
    if name == "title_com" then
        -- 标题
        node:setString(getStr("title_1"))
    elseif name == "btn_history" then
        -- 历史记录
        node:addClickEventListener( function(sender)
            playSoundEffect("sound/effect/anniu")
            if self._info then
                ExchangeProxy:requestExchangeHistory(self._info.ExchCenterID)
            end
        end )
    elseif name == "btn_hint" then
        -- 提示
        node:addClickEventListener( function(sender)
            playSoundEffect("sound/effect/anniu")
            local layer = nil
            layer = cc.Layer:create():addTo(self.uis.bg_com)
            layer:addTouch( function(touch, event) return cc.rectContainsPoint(layer:rect(), layer:convertToNodeSpace(touch:getLocation())) end, nil, function(touch, event)
                -- 关闭提示
                playSoundEffect("sound/effect/anniu")
                self.uis.hint_bg:setVisible(false)
                local pos = self.uis.btn_hint:convertToNodeSpace(self.uis.hint_bg:convertToWorldSpace(cc.p(0, 0)))
                self.uis.hint_bg:retain():removeFromParent():addTo(self.uis.btn_hint):pos(pos):release()
                layer:removeFromParent()
            end )
            self.uis.hint_bg:setVisible(true)
            local pos = self.uis.bg_com:convertToNodeSpace(self.uis.hint_bg:convertToWorldSpace(cc.p(0, 0)))
            self.uis.hint_bg:retain():removeFromParent():addTo(self.uis.bg_com):pos(pos):release()
        end )
    elseif name == "crystal_count" then
        node:setString(ToolCom.splitNumFix(userData:getGoodsAttrByName("shuij", "count") or 0))
    end
end

function Exchange:_handleProxy(event)
    local data = event._userdata
    if event.name == ExchangeCfg.InnerEvents.EXCHANGE_EQUIPLIST then
        -- 兑换列表
        self._info = data
        if self._info and self._info.exchangeInfo and #self._info.exchangeInfo > 0 then
            if not self._listView then
                self._listView = cc.TableView:create(cc.size(self._tmpData.width_list_bg, self._tmpData.height_list_bg)):addTo(self.uis.list_bg):offsetX(10)
                self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
                self._listView:setDelegate()
                self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
                self._listView:registerScriptHandler( function(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
                self._listView:registerScriptHandler( function(view) end, cc.SCROLLVIEW_SCRIPT_ZOOM)
                self._listView:registerScriptHandler( function(view, cell) end, cc.TABLECELL_TOUCHED)
                self._listView:registerScriptHandler(handler(self, Exchange.tableCellSizeForIdx), cc.TABLECELL_SIZE_FOR_INDEX)
                self._listView:registerScriptHandler(handler(self, Exchange.tableCellAtIdx), cc.TABLECELL_SIZE_AT_INDEX)
                self._listView:registerScriptHandler(handler(self, Exchange.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
            end
            self._listView:reloadData()
            if self.uis._img_empty then
                self.uis._img_empty:setVisible(false)
            end
        else
            -- 兑换中心为空。
            if self._listView then
                self._listView:setVisible(false)
            end
            if not self.uis._img_empty then
                local imgEmpty = display.newSprite("#store_mm.png"):addTo(self.uis.list_bg):centerX(self.uis.list_bg):innerTop(self.uis.list_bg):offsetY(-150)
                display.newSprite("#exchg_no_item.png"):addTo(imgEmpty):bottom(imgEmpty):centerX(imgEmpty):offsetY(-20)
                self.uis._img_empty = imgEmpty
            else
                self.uis._img_empty:setVisible(true)
            end
        end
    elseif event.name == ExchangeCfg.InnerEvents.EXCHANGE_EQUIPINFO then
        -- 兑换商品详情
        for k, v in ipairs(self._info.exchangeInfo) do
            if v.ExchID == data.ExchID then
                -- 找对兑换ID
                table.merge(data, v)
                require("hall.mediator.view.widget.exchange.Exchange_item"):create(data):addTo(self)
                break
            end
        end
    elseif event.name == ExchangeCfg.InnerEvents.EXCHANGE_MYAWARDLIST then
        -- 历史记录
        require("hall.mediator.view.widget.exchange.Exchange_history"):create(data.info):addTo(self)
    elseif event.name == ExchangeCfg.InnerEvents.ROOT_RET_REQ_EXCHANGE then
        if data.kReasonType == 0 then
            -- 兑换商品成功，刷新水晶
            HallProxy:requestGoodsCount(getGoodsByFlag("shuij").fid)
        end
    end
end

function Exchange:tableCellSizeForIdx(view, idx)
    -- return self._tmpData.width_list_bg, self._tmpData.height_list_bg / 2.3
    return self._tmpData.width_list_bg, 400
end

-- 一行几个
local ITEM_COUNT_LINE = 3
function Exchange:tableCellAtIdx(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren()

    local startIdx = idx * ITEM_COUNT_LINE + 1
    local item, tmp, cellWidth, cellHeight = nil, 1, self:tableCellSizeForIdx(view, idx)
    cell:setContentSize(cc.size(cellWidth, cellHeight))

    while (startIdx <= idx * ITEM_COUNT_LINE + ITEM_COUNT_LINE and startIdx <= #self._info.exchangeInfo) do
        item = self:_createListItem(self._info.exchangeInfo[startIdx]):addTo(cell)
        item:offsetX((tmp - 1) * cellWidth / ITEM_COUNT_LINE):offsetX(12):offsetY(cellHeight / 2 - item:height2())
        tmp = tmp + 1
        startIdx = startIdx + 1
    end

    return cell
end

function Exchange:_createListItem(info)
    local ret = require("csb.hall.exchange.exchange_item"):create().root
    ret:setContentSize(ret:getChildByName("Image_1"):size())
    local tmp_flag_crystal = nil
    ToolCom.traverseNode(ret, function(name, node)
        if name == "item_left" then
            if info.Stock == -1 then
                node:setString(getStr("item_left_much"))
            else
                node:setString(string.format(getStr("item_left"), info.Stock))
            end
        elseif name == "txt_price" then
            node:setString(info.NeedCoupon)
            tmp_flag_crystal:centerX(node:getParent()):offsetX(- node:width2() -5 - 10)
            node:centerX(node:getParent()):offsetX(tmp_flag_crystal:width2() + 5 - 10)
        elseif name == "img_crystal" then
            tmp_flag_crystal = node
        elseif name == "flag_hot" then
            -- 0：普通 1：热 2：折扣 3：新品 4：库存紧张
            node:setVisible(info.State and info.State == 1)
        elseif name == "flag_discount" then
            node:setVisible(info.State and info.State == 2)
        elseif name == "flag_new" then
            node:setVisible(info.State and info.State == 3)
        elseif name == "flag_lack" then
            node:setVisible(info.State and info.State == 4)
        elseif name == "item_count" then
            node:setString(info.Name)
        elseif name == "btn_buy" then
            node._exchange_info = info
            node:addClickEventListener( function(sender)
                playSoundEffect("sound/effect/anniu")
                local need = node._exchange_info.NeedCoupon -(userData:getGoodsAttrByName("shuij", "count") or 0)
                if need > 0 then
                    -- 水晶不足
                    local para = { }
                    para.leftBtnlabel = i18n:get("str_common", "comm_sure")
                    para.leftBtnCallback = nil
                    para.showclose = false
                    -- 是否显示关闭按钮
                    --                    para.content = string.format(getStr("not_enough_crystal"), ToolCom.splitNumFix(need))
                    para.content = string.format(getStr("not_enough_crystal"), need)
                    require("app.views.customwidget.CommonDialog"):create(para):show()
                elseif node._exchange_info.Stock == 0 then
                    -- 库存不足
                    local para = { }
                    para.leftBtnlabel = i18n:get("str_common", "comm_sure")
                    para.leftBtnCallback = nil
                    --                    para.rightBtnlabel = i18n:get("str_common", "comm_sure")
                    --                    para.rightBtnCallback = function() request.releaseRoom(proxy, roomID) end
                    para.showclose = false
                    -- 是否显示关闭按钮
                    para.content = getStr("not_enough_stock")
                    require("app.views.customwidget.CommonDialog"):create(para):show()
                else
                    -- 1、话费　2.其它实物 3.道具 4.现金
                    if sender._exchange_info.ObjectType == 2 or sender._exchange_info.ObjectType == 1 then
                        if sender._exchange_info.ObjectType == 1 and DataCenter:getUserdataInstance():getValueByKey("BindPhone") == "" then
                            -- 兑换话费，当前账号必须绑定手机
                            toast(getStr("request_register_account"))
                        else
                            -- 兑换商品详情。
                            ExchangeProxy:requestExchangeItemDetail(sender._exchange_info.ExchID)
                        end
                    else
                        -- 不支持兑换
                        toast(getStr("invalid_object_type"))
                    end
                end
            end )
        elseif name == "container" then
            -- 物品形象
            --            display.newSprite(getGoodsSrcByFlag("GOLD")):addTo(node)
            ToolCom:createGoodsSprite(info.EquipID):addTo(node)
        elseif name == "Image_2" then
            node:setLocalZOrder(1)
        end
    end )
    return ret
end

function Exchange:numberOfCellsInTableView(view, idx)
    return math.floor((#self._info.exchangeInfo - 1) / 3) + 1
end

return Exchange