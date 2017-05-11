-------------------------------------------------------------------------
-- Title:        兑换中心历史记录
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local ExchangeHistory = class("ExchangeHistory", require("app.views.uibase.PopWindowBase"), require("packages.mvc.Mediator"))
local ExchangeCfg = require("hall.mediator.cfg.ExchangeCfg")
local ExchangeProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().ExchangeProxy)
local Toast = require("app.views.common.Toast")
local userData = DataCenter:getUserdataInstance()
local csbMainPath = "csb.hall.exchange.common"
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end
local getChild = function(node, name) return ccui.Helper:seekWidgetByName(node, name) end
local getStr = function(flag) return i18n:get("str_exchange", flag) end
local getComStr = function(flag) return i18n:get("str_common", flag) end

function ExchangeHistory:ctor(info)
    self.uis = { }
    self._info = info
    self._tmpData = { }
    self.super.ctor(self)
    self.logTag = "Exchange_history.lua"
    self:init()
end

function ExchangeHistory:init()
    local bgCommon = require(csbMainPath):create().root:addTo(self)
    local imgBg = bgCommon:getChildByName("bg_com")
    local titleBg = imgBg:getChildByName("img_top_com")
    local container = imgBg:getChildByName("container")

    self._tmpData.width_list_bg, self._tmpData.height_list_bg = 1020, cc.Director:getInstance():getWinSize().height - titleBg:height() -100
    local listBg = display.newSprite("common/common_bg_2.png", { scale9 = true }):setPreferredSize(cc.size(self._tmpData.width_list_bg, self._tmpData.height_list_bg)):setName("list_bg"):addTo(imgBg)
    listBg:pos(cc.p(imgBg:width2(), listBg:height2())):offsetY(10)

    local bottomInfoBg = display.newSprite("#exchg_bottom_bg.png"):addTo(listBg, 1):centerX(listBg):innerBottom(listBg):offsetY(10)
    local flag_gift = display.newSprite("#exchg_flag_gift.png"):addTo(bottomInfoBg):center(bottomInfoBg):offsetY(-3)
    local tmpOffset = 5
    local flag_txt = cc.Label:createWithTTF(getStr("reward_send_delay"), "FZZhengHeiS-B-GB.ttf", 32):addTo(bottomInfoBg):setColor(cc.c3b(0xda, 0xc9, 0x85)):center(bottomInfoBg):offsetX(flag_gift:width2() + tmpOffset):offsetY(-4)
    flag_gift:offsetX(- flag_txt:width2() - tmpOffset)

    local txtColor, txtSize = cc.c3b(0xff, 0xf3, 0x89), 32
    local titleBg = display.newSprite("#exchg_history_top_bar.png"):addTo(imgBg):top(listBg):centerX(listBg):offsetY(5)
    local date = cc.Label:createWithTTF(getStr("title_exchange_date"), "FZZhengHeiS-B-GB.ttf", txtSize):setColor(txtColor):addTo(titleBg):pos(297 / 2, 31.5)
    local name = cc.Label:createWithTTF(getStr("title_exchange_name"), "FZZhengHeiS-B-GB.ttf", txtSize):setColor(txtColor):addTo(titleBg):pos((297 + 610) / 2, 31.5)
    local cost = cc.Label:createWithTTF(getStr("title_exchange_cost"), "FZZhengHeiS-B-GB.ttf", txtSize):setColor(txtColor):addTo(titleBg):pos((794 + 610) / 2, 31.5)
    local state = cc.Label:createWithTTF(getStr("title_exchange_state"), "FZZhengHeiS-B-GB.ttf", txtSize):setColor(txtColor):addTo(titleBg):pos((794 + 985) / 2, 31.5)

    ToolCom.traverseNode(bgCommon, handler(self, self._initView), self.uis)

    FixUIUtils.setRootNodewithFIXED(bgCommon)
    FixUIUtils.stretchUI(imgBg)

    self:popIn(imgBg, Pop_Dir.Right)

    ToolCom.traverseNode(bgCommon, handler(self, self._initView), self.uis)

    if self._info and #self._info > 0 then
        self._listView = cc.TableView:create(cc.size(self._tmpData.width_list_bg, self._tmpData.height_list_bg)):addTo(self.uis.list_bg)
        self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self._listView:setDelegate()
        self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self._listView:registerScriptHandler( function(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
        self._listView:registerScriptHandler( function(view) end, cc.SCROLLVIEW_SCRIPT_ZOOM)
        self._listView:registerScriptHandler(handler(self, self.tableTouched), cc.TABLECELL_TOUCHED)
        self._listView:registerScriptHandler(handler(self, self.tableCellSizeForIdx), cc.TABLECELL_SIZE_FOR_INDEX)
        self._listView:registerScriptHandler(handler(self, self.tableCellAtIdx), cc.TABLECELL_SIZE_AT_INDEX)
        self._listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self._listView:reloadData()
    else
        -- 为空
        local imgEmpty = display.newSprite("#store_mm.png"):addTo(self.uis.list_bg):centerX(self.uis.list_bg):innerTop(self.uis.list_bg):offsetY(-150)
        display.newSprite("#exchg_no_history.png"):addTo(imgEmpty):bottom(imgEmpty):centerX(imgEmpty):offsetY(-20)
        self.uis.img_empty = imgEmpty
    end
end

function ExchangeHistory:tableCellSizeForIdx(view, idx)
    return self._tmpData.width_list_bg, 90
end

local tmpDataCell, tmpTxt, tmpColor = nil, nil, nil
local txtColor_1, txtColor_2 = cc.c3b(0x7d, 0x6e, 0x43), cc.c3b(0xef, 0x42, 0x40)
function ExchangeHistory:tableCellAtIdx(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
        local cellWidth, cellHeight = self:tableCellSizeForIdx(view, idx)
        cell:setContentSize(cc.size(cellWidth, cellHeight))
    end
    cell:removeAllChildren()

    tmpDataCell = self._info[idx + 1]
    local cellbg = display.newSprite("#exchg_list_item_bg.png"):addTo(cell):center(cell)
    local date = cc.Label:createWithTTF(string.match(tmpDataCell.ExchangeTime, "%w+年%w+月%w+日"), "FZZhengHeiS-B-GB.ttf", 28):setColor(txtColor_1):addTo(cellbg):pos(297 / 2, 39)
    local name = cc.Label:createWithTTF(tmpDataCell.EquipName, "FZZhengHeiS-B-GB.ttf", 28):setColor(txtColor_1):addTo(cellbg):pos((297 + 610) / 2, 39)
    local cost = cc.Label:createWithTTF(tmpDataCell.Price, "FZZhengHeiS-B-GB.ttf", 28):setColor(txtColor_1):addTo(cellbg):pos((794 + 610) / 2, 39)
    -- 1：完成兑换（已收货）
    -- 2：发货中
    -- 3：兑换提交中（待发货）
    -- 4：等待兑换
    -- 5：兑换失败
    if tmpDataCell.Flag == 1 then
        tmpTxt = getStr("finish_exchange")
        tmpColor = cc.c3b(0x44, 0x89, 0x63)
    elseif tmpDataCell.Flag == 2 then
        tmpTxt = getStr("sending")
        tmpColor = cc.c3b(0xff, 0xa3, 0x13)
    elseif tmpDataCell.Flag == 3 then
        tmpTxt = getStr("committing")
        tmpColor = cc.c3b(0x1c, 0x8d, 0xc8)
    elseif tmpDataCell.Flag == 4 then
        tmpTxt = getStr("waiting_exchange")
        tmpColor = cc.c3b(0x7d, 0x6e, 0x43)
    elseif tmpDataCell.Flag == 5 then
        tmpTxt = getStr("fail_to_exchange")
        tmpColor = cc.c3b(0xef, 0x42, 0x40)
    end
    local state = cc.Label:createWithTTF(tmpTxt, "FZZhengHeiS-B-GB.ttf", 28):setColor(tmpColor):addTo(cellbg):pos((794 + 985) / 2, 39)
    return cell
end

function ExchangeHistory:numberOfCellsInTableView(view, idx)
    return #self._info
end

function ExchangeHistory:tableTouched(view, cell)
    playSoundEffect("sound/effect/anniu")
    local info = self._info[cell:getIdx() + 1]
    --    info.ObjectType = 2
    if info.ObjectType == 2 or info.ObjectType == 1 then
        --实物和话费类型道具。
        require("hall.mediator.view.widget.exchange.Exchange_item"):create(info, true):addTo(self)
    else
        toast("暂不支持该类型道具")
    end
end

function ExchangeHistory:_initView(name, node)
    if name == "title_com" then
        -- 标题
        node:setString(getStr("title_3"))
    end
end

return ExchangeHistory