-------------------------------------------------------------------------
-- Title:        私人订制-------历史记录
-- Author:    Jackie Liu
-- Date:       2016/09/13 15:48:27
-- Desc:
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local SiRen_history = class("SiRen_history", require("app.views.uibase.PopWindowBase"))
local TAG = "SiRen_history.lua"
local csbMainPath = "csb.hall.siren.history"
local csbCommonPath = "csb.hall.siren.common"
local SiRenRoomCfg = import("....cfg.SiRenRoomCfg")
local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SiRenRoomProxy)
local request = require("hall.request.SiRenRoomRequest")
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time):show() end
local getStr = function(flag) return i18n:get("str_sirenrm", flag) end
local getComStr = function(flag) return i18n:get("str_common", flag) end
local getWidget = function(node, flag) return ccui.Helper:seekWidgetByName(node, flag) end
local getNode = function(node, ...)
    local ret = nil
    for k, v in ipairs( { ...}) do
        if ret then
            ret = ret:getChildByName(v)
        else
            ret = node:getChildByName(v)
        end
    end
    return ret
end
local userData = DataCenter:getUserdataInstance()
local table = table
local function traverseNode(node, callback, table)
    local name = node:getName()
    table[name] = node
    callback(name, node)
    for idx, child in pairs(node:getChildren()) do
        traverseNode(child, callback, table)
    end
end

function SiRen_history:ctor(sirenlayer, history)
    self.uis = { }
    self._historyInfo = history
    table.walk(self._historyInfo, function(v, k) v._siren_sort_tmp = k end)
    table.sort(self._historyInfo, function(a, b) return a._siren_sort_tmp > b._siren_sort_tmp end)
    table.walk(self._historyInfo, function(v, k) v._siren_sort_tmp = nil end)
    self._sirenlayer = sirenlayer
    self._listView = nil
    self._sizeListView = nil

    SiRen_history.super.ctor(self)
    self:init()
end

function SiRen_history:init()
    local root = require(csbCommonPath):create().root:addTo(self)
    local bg = getNode(root, "bg_com")
    local container = getNode(bg, "container")

    FixUIUtils.setRootNodewithFIXED(root)
    FixUIUtils.stretchUI(bg)
    self:popIn(bg, Pop_Dir.Right)

    traverseNode(root, handler(self, self._initView), self.uis)
end

local cellHeight = 70
function SiRen_history:tableCellSizeForIdx(view, idx)
    return self._sizeListView.width, cellHeight + cellHeight + #self._historyInfo[idx + 1].playerInfo * cellHeight + 20
end

local jiConf = { [2] = "2", [3] = "3", [4] = "4", [5] = "5", [6] = "6", [7] = "7", [8] = "8", [9] = "9", [10] = "10", [11] = "J", [12] = "Q", [13] = "K", [14] = "A", }
local tmp = nil
function SiRen_history:tableCellAtIdx(view, idx)
    local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren()
    local width, height = self:tableCellSizeForIdx(view, idx)
    cell:setContentSize( { width = width, height = height })
    local titleBar = display.newSprite("#siren_history_top_bar.png"):addTo(cell):innerTop(cell):centerX(cell)
    local siren_history_bg = display.newSprite("#siren_history_bg.png", { scale9 = true })
    siren_history_bg:setPreferredSize(cc.size(siren_history_bg:width(), height - 75 - 20)):addTo(cell):bottom(titleBar):centerX(cell)
    local info = self._historyInfo[idx + 1]
    -- 局数/过几
    local strJuShuGuoJi = nil
    -- 对局日期
    local strPlayDate = info.DateStr
    -- 翻倍同花顺
    local strbombFlush = nil
    -- 过几
    if info.Playtype == 1 then
        -- 过几
        strJuShuGuoJi = getStr("guo") .. jiConf[info.PlayData]
    else
        -- 局数
        strJuShuGuoJi = info.PlayData .. getStr("ju")
    end

    -- 同花顺/翻倍
    local bomb, flush = string.match(info.MultipleData, "(%d),(%d)")
    bomb, flush = tonumber(bomb) == 1, tonumber(flush) == 1
    if bomb and flush then
        strbombFlush = getStr("title_fanbei3")
    elseif bomb then
        strbombFlush = getStr("title_fanbei1")
    elseif flush then
        strbombFlush = getStr("title_fanbei2")
    else
        strbombFlush = nil
    end

    local xTable = { (262 + 7) / 2 - 60, (374 + 262) / 2, (374 + 489) / 2, (602 + 489) / 2, (602 + 717) / 2, (717 + 830) / 2, (830 + 985) / 2 }
    local colorTitle, colorDate = cc.c3b(0x7e, 0x6e, 0x44), cc.c3b(0xff, 0xf3, 0x89)
    local offsetTitle = -30
    if strbombFlush then
        cc.Label:createWithTTF(string.format("%s(%s)", strJuShuGuoJi, strbombFlush), "FZZhengHeiS-B-GB.ttf", 32):addTo(titleBar):innerLeft(titleBar):centerY(titleBar):offsetX(20):setColor(colorDate)
    else
        cc.Label:createWithTTF(string.format("%s", strJuShuGuoJi), "FZZhengHeiS-B-GB.ttf", 32):addTo(titleBar):innerLeft(titleBar):centerY(titleBar):offsetX(20):setColor(colorDate)
    end
    cc.Label:createWithTTF(strPlayDate, "FZZhengHeiS-B-GB.ttf", 32):setColor(colorDate):addTo(titleBar):centerY(titleBar):innerRight(titleBar):offsetX(-20)
    -- ju_shu = "局数",
    local jushuNode = cc.Label:createWithTTF(getStr("ju_shu"), "FZZhengHeiS-B-GB.ttf", 32):setColor(colorTitle):addTo(siren_history_bg):posX(xTable[2]):innerTop(siren_history_bg):offsetY(offsetTitle)
    -- win_rate = "胜率",
    local winRateNode = cc.Label:createWithTTF(getStr("win_rate"), "FZZhengHeiS-B-GB.ttf", 32):setColor(colorTitle):addTo(siren_history_bg):posX(xTable[3]):innerTop(siren_history_bg):offsetY(offsetTitle)
    -- tou_you = "头游",
    local touYouNode = cc.Label:createWithTTF(getStr("tou_you"), "FZZhengHeiS-B-GB.ttf", 32):setColor(colorTitle):addTo(siren_history_bg):posX(xTable[4]):innerTop(siren_history_bg):offsetY(offsetTitle)
    -- zha_6 = "6炸",
    local zha6Node = cc.Label:createWithTTF(getStr("zha_6"), "FZZhengHeiS-B-GB.ttf", 32):setColor(colorTitle):addTo(siren_history_bg):posX(xTable[5]):innerTop(siren_history_bg):offsetY(offsetTitle)
    -- flush = "同花顺",
    local flushNode = cc.Label:createWithTTF(getStr("flush"), "FZZhengHeiS-B-GB.ttf", 32):setColor(colorTitle):addTo(siren_history_bg):posX(xTable[6]):innerTop(siren_history_bg):offsetY(offsetTitle)
    -- score = "积分",
    local jifenNode = cc.Label:createWithTTF(getStr("score"), "FZZhengHeiS-B-GB.ttf", 32):setColor(colorTitle):addTo(siren_history_bg):posX(xTable[7]):innerTop(siren_history_bg):offsetY(offsetTitle)
    local _tmp_offset_y = nil
    for k, userInfo in ipairs(info.playerInfo) do
        _tmp_offset_y =(cellHeight - 10) *(k - 0.5) + 30
        if userInfo.Score > 0 then
            -- 积分为正就显示赢的标志
            tmp = display.newSprite("#siren_flag_win.png"):addTo(siren_history_bg):posY(_tmp_offset_y):innerLeft(siren_history_bg):offsetX(5)
        end
        -- 玩家昵称
        -- cc.Label:createWithSystemFont(userInfo.Nickname, "", 32):setColor(colorDate):setAnchorPoint(0.0, 0.5)
        self:_getMaxLenLabel(userInfo.Nickname, 180, { size = 32, color = colorDate }):setAnchorPoint(0.0, 0.5):addTo(siren_history_bg):posX(xTable[1]):posY(_tmp_offset_y)
        -- 对局数
        cc.Label:createWithTTF(userInfo.Play, "FZZhengHeiS-B-GB.ttf", 30):setColor(colorTitle):addTo(siren_history_bg):posX(xTable[2]):posY(_tmp_offset_y)
        -- 胜率
        cc.Label:createWithTTF(userInfo.Winp .. "%", "FZZhengHeiS-B-GB.ttf", 30):setColor(colorTitle):addTo(siren_history_bg):posX(xTable[3]):posY(_tmp_offset_y)
        -- 头游次数
        cc.Label:createWithTTF(userInfo.Rank1, "FZZhengHeiS-B-GB.ttf", 30):setColor(colorTitle):addTo(siren_history_bg):posX(xTable[4]):posY(_tmp_offset_y)
        -- 炸弹数量
        cc.Label:createWithTTF(userInfo.Boom, "FZZhengHeiS-B-GB.ttf", 30):setColor(colorTitle):addTo(siren_history_bg):posX(xTable[5]):posY(_tmp_offset_y)
        -- 同花顺数量
        cc.Label:createWithTTF(userInfo.StrFlush, "FZZhengHeiS-B-GB.ttf", 30):setColor(colorTitle):addTo(siren_history_bg):posX(xTable[6]):posY(_tmp_offset_y)
        -- 积分
        cc.Label:createWithTTF(userInfo.Score, "FZZhengHeiS-B-GB.ttf", 30):setColor(colorTitle):addTo(siren_history_bg):posX(xTable[7]):posY(_tmp_offset_y)
    end
    return cell
end

function SiRen_history:numberOfCellsInTableView(view, idx)
    return #self._historyInfo
end

function SiRen_history:_initView(name, node)
    if name == "title_com" then
        node:setString(getStr("history"))
    elseif name == "history_bg" then
        node:setVisible(true)
        self._sizeListView = node:getContentSize()
        self._listView = cc.TableView:create(self._sizeListView):addTo(node)
        self._listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        -- self._listView:setPosition(cc.p(self.size.width/2,self.size.height/2))
        self._listView:setDelegate()
        self._listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self._listView:registerScriptHandler( function(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
        self._listView:registerScriptHandler( function(view) end, cc.SCROLLVIEW_SCRIPT_ZOOM)
        self._listView:registerScriptHandler( function(view, cell) end, cc.TABLECELL_TOUCHED)
        self._listView:registerScriptHandler(handler(self, SiRen_history.tableCellSizeForIdx), cc.TABLECELL_SIZE_FOR_INDEX)
        self._listView:registerScriptHandler(handler(self, SiRen_history.tableCellAtIdx), cc.TABLECELL_SIZE_AT_INDEX)
        self._listView:registerScriptHandler(handler(self, SiRen_history.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self._listView:reloadData()
    end
end

function SiRen_history:onEnter()
    SiRen_history.super.onEnter(self)
end

function SiRen_history:onExit()
    SiRen_history.super.onExit(self)
end

-- 获取不超过指定长度的Label
local string = string
function SiRen_history:_getMaxLenLabel(str, len, txtConf)
    if str and len then
        local tmpLabels = { }
        local tmpWidth = 0
        travelUtf8Str(str, function(idx, bytes)
            tmp = cc.Label:createWithSystemFont(string.sub(str, idx, idx + bytes - 1), "", txtConf.size)
            if tmpWidth + tmp:width() <= len then
                if txtConf.color then
                    tmp:setColor(txtConf.color)
                end
                tmpLabels[#tmpLabels + 1] = tmp
                if #tmpLabels > 1 then
                    tmp:setAnchorPoint(cc.p(0.0, 0.0)):offsetX(tmpLabels[#tmpLabels - 1]:width()):addTo(tmpLabels[#tmpLabels - 1])
                end
                tmpWidth = tmpWidth + tmp:width()
            end
        end )
        return tmpLabels[1]
    end
end

return SiRen_history