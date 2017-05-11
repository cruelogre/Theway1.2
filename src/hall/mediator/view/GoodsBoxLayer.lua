-------------------------------------------------------------------------
-- Title:        物品箱
-- Author:    Jackie Liu
-- Date:       2016/12/22 15:48:27
-- Desc:
--        水晶的类型和记牌器道具一样，但是在这里不显示水晶
--        道具根据情况，显示使用按钮，比如记牌器显示使用按钮。
-- 20170207  屏蔽展示物品的使用按钮（产品需求）
-- Copyright (c) wawagame Entertainment All right reserved.
-------------------------------------------------------------------------
local GoodsBoxLayer = class("GoodsBoxLayer", require("app.views.uibase.PopWindowBase"), require("packages.mvc.Proxy"))
local TAG = "GoodsBoxLayer.lua"
local hallFSM = FSRegistryManager:runWithFSM(FSMConfig.FSM_HALL)
local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
local csbMainPath = "csb.hall.goodsBox.goods_box_layer"
local csbListItemPath = "csb.hall.goodsBox.goods_item"
local csbListItemShowPath = "csb.hall.goodsBox.goods_item_show"
local GoodsBoxCfg = require("hall.mediator.cfg.GoodsBoxCfg")
local HallCfg = require("hall.mediator.cfg.HallCfg")
local toast = function(str, time) require("app.views.common.Toast"):makeToast(str, time or 2.0):show() end
local getStr = function(flag) return i18n:get("str_goodsbox", flag) end
local getComStr = function(flag) return i18n:get("str_common", flag) end
local userData = DataCenter:getUserdataInstance()
local table, string, math = table, string, math

function GoodsBoxLayer:ctor()
    GoodsBoxLayer.super.ctor(self)

    self._uis = { }
    self._sizeListGoodsBox = nil
    self._listGoodsBox = nil
    -- 迎合产品需求，有些道具不显示使用按钮，有些道具需要使用，并不能通过配置分辨这些，只能穷举。
    self._btn_use_conf =
    {
        -- 显示使用按钮的道具fid
        show = { getFidByFlag("jpq"), 10011107 },
        -- 隐藏使用按钮的道具fid
        hide = { },
        -- 上面没有考虑到的道具fid是显示还是消失使用按钮，false为消失。
        default_show = false,
    }
    -- 物品箱信息,经过了过滤的。
    -- self._goodsBoxInfo = self:_getGoodsBoxData()
    self._goodsBoxInfo = { }
    -- fid为key，物品详细信息
    self._goodsDetailInfo = { }
    -- 详细信息显示面板
    self._tmp_item_show_view = nil
    -- 物品箱刷新listener
    self._listenerRefresh = nil
    -- 获取物品详细信息
    self._listenerGoodsDetail = nil

    self:setDisCallback( function(...)
        -- body
        FSRegistryManager:runWithFSM(FSMConfig.FSM_HALL):trigger("back")
    end )

    local root = require(csbMainPath):create().root:addTo(self)
    local bg = root:getChildByName("bg_com")
    ToolCom.traverseNode(root, nil, self._uis)
    self:_initView()
    FixUIUtils.setRootNodewithFIXED(root)
    FixUIUtils.stretchUI(bg)
    self:popIn(bg, Pop_Dir.Right)

    performFunction( function()
        HallSceneProxy:requestGoodsBoxInfo()
    end , 0.2)
end

-- 初始化界面
function GoodsBoxLayer:_initView()

    display.newSprite("#goodsbox_txt_go_shop.png"):addTo(self._uis.btn_shop:getRendererNormal()):center(self._uis.btn_shop:getRendererNormal())
    self._uis.btn_shop:addClickEventListener(handler(self, self._btnClickCallback))

    -- 物品箱列表
    self._sizeListGoodsBox = { width = self._uis.list_bg:width(), height = self._uis.list_bg:height() }
    self._listGoodsBox = cc.TableView:create(self._sizeListGoodsBox):addTo(self._uis.list_bg)
    self._listGoodsBox:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._listGoodsBox:setDelegate()
    self._listGoodsBox:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._listGoodsBox:registerScriptHandler( function(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._listGoodsBox:registerScriptHandler( function(view) end, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self._listGoodsBox:registerScriptHandler(handler(self, self.tableTouched), cc.TABLECELL_TOUCHED)
    self._listGoodsBox:registerScriptHandler(handler(self, self.tableCellSizeForIdx), cc.TABLECELL_SIZE_FOR_INDEX)
    self._listGoodsBox:registerScriptHandler(handler(self, self.tableCellAtIdx), cc.TABLECELL_SIZE_AT_INDEX)
    self._listGoodsBox:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._listGoodsBox:reloadData()

    self._uis.flag_empty:setVisible(not next(userData:getValueByKey("goodsInfo")))
    self._uis.flag_empty_txt:setVisible(not next(userData:getValueByKey("goodsInfo")))
end

-- 一页能显示下几条
function GoodsBoxLayer:tableCellSizeForIdx()
    return self._sizeListGoodsBox.width, 310
end

-- 一行几个
local ItemNumPerCell = 3
function GoodsBoxLayer:tableCellAtIdx(view, idx)
    local cell = view:dequeueCell()
    local width, height = self:tableCellSizeForIdx(view, idx)
    if not cell then
        cell = cc.TableViewCell:new()
        cell:setContentSize( { width = width, height = height })
    else
        cell:removeAllChildren()
    end
    for tmpIdx = idx * ItemNumPerCell + 1, math.min((idx + 1) * ItemNumPerCell, #self._goodsBoxInfo) do
        self:_createListItem(self._goodsBoxInfo[tmpIdx], tmpIdx):addTo(cell):pos((1 +(tmpIdx - idx * ItemNumPerCell - 1) * 2) * width /(ItemNumPerCell * 2), height / 2)
    end
    return cell
end

function GoodsBoxLayer:numberOfCellsInTableView()
    return #self._goodsBoxInfo > 0 and math.ceil(#self._goodsBoxInfo / ItemNumPerCell) or 0
end

-- 避免连续点击发送多个请求，导致产生多个弹框
function GoodsBoxLayer:tableTouched(tableView, cell)
    playSoundEffect("sound/effect/anniu")
end

local _tmp_offset_touch = 0
function GoodsBoxLayer:_createListItem(info, absIdx)
    local ret = require(csbListItemPath):create().root
    local uis = { }
    ToolCom.traverseNode(ret, nil, uis)
    ToolCom:createGoodsSprite(info.EquipID):addTo(uis.item_node)
    uis.item_name:setString(info.Name)

    if tonumber(info.EquipCount) > 1 then
        uis.num_txt:setString(info.EquipCount)
    else
        uis.num_bg:setVisible(false)
    end

    uis.item_bg:addTouch( function(touch, event)
        return cc.rectContainsPoint(uis.item_bg:rect(), uis.item_bg:convertToNodeSpace(touch:getLocation()))
    end ,
    function(touch, event)
        -- moved
        _tmp_offset_touch = _tmp_offset_touch + cc.pGetLength(touch:getDelta())
    end ,
    function(touch, event)
        -- ended
        if _tmp_offset_touch < 10 then
            self._tmp_item_show_view = require(csbListItemShowPath):create().root:addTo(self._uis.list_bg)
            self._tmp_item_show_view._fid = info.Fid

            local tmpUIs = { }
            self._tmp_item_show_view._uis = tmpUIs
            ToolCom.traverseNode(self._tmp_item_show_view, nil, tmpUIs)
            tmpUIs.num_txt:setString(info.EquipCount)

            if tonumber(info.EquipCount) > 1 then
                tmpUIs.num_txt:setString(info.EquipCount)
            else
                tmpUIs.num_bg:setVisible(false)
            end

            tmpUIs.item_name:setString(info.Name)
            tmpUIs.desc_txt:setString((self._goodsDetailInfo and self._goodsDetailInfo[info.Fid] and self._goodsDetailInfo[info.Fid].introduce) or info.Name)
            tmpUIs.desc_txt:offset(-80, -30)
            --            tmpUIs.desc_txt:setString("记牌器，是一种非常有用的好东西，你千万别错过哦。")
            tmpUIs.desc_txt:setTextAreaSize(cc.size(310, 108))

            ToolCom:createGoodsSprite(info.EquipID):addTo(tmpUIs.item_node)

            tmpUIs.btn_use:addClickEventListener(handler(self, self._btnClickCallback))

            -- 根据_btn_use_conf决定是否显示使用按钮
            local showStatus = nil
            for k, v in pairs(self._btn_use_conf) do
                if type(v) == "table" then
                    for k1, v1 in ipairs(v) do
                        if tonumber(v1) == tonumber(info.Fid) then
                            showStatus =(k == "show")
                            break
                        end
                    end
                end
            end

            -- 20170207 屏蔽使用按钮 （策划需求）
            -- if showStatus == nil then
            --     tmpUIs.btn_use:visible(self._btn_use_conf.default_show)
            -- else
            --     tmpUIs.btn_use:visible(showStatus)
            -- end

            local tmpPos = self._uis.list_bg:convertToNodeSpace(ret:convertToWorldSpace(cc.p(0, 0)))
            if absIdx % ItemNumPerCell == 1 then
                -- 左边
                self._tmp_item_show_view:pos(tmpPos):offsetX(tmpUIs.item_bg:width2() - uis.item_bg:width2())
            else
                -- 右边
                self._tmp_item_show_view:pos(tmpPos):offsetX(uis.item_bg:width2() - tmpUIs.item_bg:width2())
            end
            self._tmp_item_show_view:addTouch( function(touch)
                print("**shit")
                return true
            end , nil, function(touch)
                if not cc.rectContainsPoint(tmpUIs.item_bg:rect(), tmpUIs.item_bg:convertToNodeSpace(touch:getLocation())) then
                    if self._tmp_item_show_view then
                        playSoundEffect("sound/effect/anniu")
                        self._tmp_item_show_view:removeFromParent()
                        self._tmp_item_show_view = nil
                    end
                end
            end )
            if not self._goodsDetailInfo[info.Fid] then
                --  请求详细信息
                ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE):requestGoodsInfoDetail1(info.Fid)
            end
        end
        _tmp_offset_touch = 0
    end , nil, false)
    return ret
end

-- 一个格子最多显示99个。剩下的填充到下一个格子。
function GoodsBoxLayer:_getGoodsBoxData()
    local ret = { }
    -- local goodsInfo = userData:getValueByKey("goodsInfo")
    local goodsInfo = userData:getValueByKey("bagInfo")
    wwdump(goodsInfo, "userData GoodsInfo的信息：")
    local tmpCopyTable = nil
    for k, v in pairs(goodsInfo) do
        if (v.MagicType == 1) or (v.MagicType == 2) then
            -- 道具类型
            if v.Fid == getFidByFlag("shuij") then
                -- 水晶应该是货币，不能是道具，不予显示
            else
                tmpCopyTable = clone(v)
                if tmpCopyTable.EquipCount > 99 then
                    local count = tmpCopyTable.EquipCount - 99
                    tmpCopyTable.EquipCount = 99
                    table.insert(ret, tmpCopyTable)
                    local tmp = nil
                    while count > 0 do
                        tmp = clone(tmpCopyTable)
                        if count >= 99 then
                            count = count - 99
                        else
                            tmp.EquipCount = count
                            count = 0
                        end
                        table.insert(ret, tmp)
                    end
                else
                    table.insert(ret, tmpCopyTable)
                end
            end
        end
    end
    wwdump(ret, "物品箱信息：")
    return ret
end

function GoodsBoxLayer:_btnClickCallback(sender)
    playSoundEffect("sound/effect/anniu")
    local name = sender:getName()
    if name == "btn_use" then
        -- 道具立即使用
        do return end
        -- 使用
        -- 物品箱还有记牌器，立即使用记牌器
        local params = {
            MagicID = self:_getShopConf(getFidByFlag("jpq")).MagicID,
            StoreMagicID = self:_getShopConf(getFidByFlag("jpq")).StoreMagicID,
        }
        wwdump(params, "使用道具请求:参数")
        StoreProxy:requestBuyProp(params, wwConfigData.CHARGE_STORE_PROP_GAME)
    elseif name == "btn_shop" then
        -- 点击商店逛逛
        hallFSM:trigger("store", { parentNode = display.getRunningScene(), zorder = 4, store_openType = 4 })
    end
end

function GoodsBoxLayer:_getShopConf(fid)
    if not userData:getValueByKey("shopConf_inGame") or not(next(userData:getValueByKey("shopConf_inGame"))) then
        wwlog(TAG, "登录时没有成功获取游戏中购买道具配置")
    else
        return userData:getValueByKey("shopConf_inGame")[fid]
    end
end

function GoodsBoxLayer:onEnter()
    wwlog(TAG, "GoodsBoxLayer onEnter")
    GoodsBoxLayer.super.onEnter(self)
    -- 无需注销，退出物品箱时，component的listener会被清空
    local _
    _, self._listenerGoodsDetail = self:_hallEventComponent():addEventListener(HallCfg.InnerEvents.HALL_EVENT_GOODS_DETAIL_INFO, handler(self, self._response))
    _, self._listenerGoodsBoxInfo = self:_hallEventComponent():addEventListener(HallCfg.InnerEvents.HALL_EVENT_GOODS_BOX_INFO, handler(self, self._response))
    -- 物品箱信息刷新
    self._listenerRefresh = WWFacade:addCustomEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, function(event)
        local handleType = unpack(event._userdata)
        if handleType == 1 then
            -- 刷新物品箱
            wwlog(TAG, "收到物品信息更新通知C_REFLASH_PERSONINFO")
            HallSceneProxy:requestGoodsBoxInfo()
        end
    end )
end

function GoodsBoxLayer:onExit()
    wwlog(TAG, "GoodsBoxLayer onExit")
    WWFacade:removeEventListener(self._listenerRefresh)
    self:_hallEventComponent():removeEventListener(self._listenerGoodsDetail)
    self:_hallEventComponent():removeEventListener(self._listenerGoodsBoxInfo)
    GoodsBoxLayer.super.onExit(self)
end

function GoodsBoxLayer:_response(event)
    local name, data = event.name, event._userdata
    if name == HallCfg.InnerEvents.HALL_EVENT_GOODS_DETAIL_INFO then
        wwdump(data, "收到物品消息信息")
        -- 物品详细信息,data.ObjectID：fid
        self._goodsDetailInfo[data.ObjectID] = data
        if self._tmp_item_show_view then
            if assert(self._tmp_item_show_view._fid) == data.ObjectID then
                self._tmp_item_show_view._uis.desc_txt:setString(data.introduce)
            end
        end
    elseif name == HallCfg.InnerEvents.HALL_EVENT_GOODS_BOX_INFO then
        -- 物品箱列表刷新
        wwlog(TAG, "收到物品箱更新消息")
        self._goodsBoxInfo = self:_getGoodsBoxData()
        self._listGoodsBox:reloadData()
        self._uis.flag_empty:setVisible(#self._goodsBoxInfo == 0)
        self._uis.flag_empty_txt:setVisible(#self._goodsBoxInfo == 0)
    end
end

function GoodsBoxLayer:_hallEventComponent()
    return HallCfg.innerEventComponent
end

return GoodsBoxLayer