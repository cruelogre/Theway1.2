-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal.yin
-- Date:    2016.09.09
-- Last: 
-- Content:  商城代理类
-- Modify : 
--     2016-11-21 添加事件上报，计费统计
--     2016-12-21 修改商城物品购买刷新，区分钻石购买
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local StoreProxy = class("StoreProxy",
	require("packages.mvc.Proxy"))

local StoreCfg = require("hall.mediator.cfg.StoreCfg")
local HallCfg = require("hall.mediator.cfg.HallCfg")
local Toast = require("app.views.common.Toast")

function StoreProxy:init()
	self.logTag = "StoreProxy.lua"
	self._ShopModel = require("hall.model.shopModel"):create(self)
	self._ShopPropModel = require("hall.model.shopPropModel"):create(self)
	self.shopSecondMenus = {} --钻石列表二级数据
	self.shopSecondMenusGolds = {} --金币数据缓存
	self.shopProps = {} --道具商城缓存数据缓存
	self.shopGoldProps = {} --道具金币缓存

	self.LastbuyGoldNum = 0 --钻石购买金币的时候，记录购买的数量，购买成功的时候加上
	self.LastBuyPropType = 0 --道具购买返回的是，金币（0），还是道具（1）
	self.LastBuyPropFid = 0 --委托购买的道具FID

	self.buycellDatas = nil --购买钻石金币的菜单数据缓存
	self.buyUnit = nil --购买单位

	self.buySceneID = wwConfigData.CHARGE_STATUE_DEFAULT --发生支付SceneID

	self.BuyPropData = nil --购买的道具信心

	self:registerMsg()
end

-- 场景ID
function StoreProxy:setChargeSceneID(SceneID)
    self.buySceneID = SceneID
end

function StoreProxy:registerMsg()
    self:registerMsgId(self._ShopModel.MSG_ID.Msg_ShopList_Ret,
    handler(self, self.response))

    self:registerMsgId(self._ShopPropModel.MSG_ID.Msg_StoreMagicList_Ret,
    handler(self, self.response))

    self:registerMsgId(self._ShopPropModel.MSG_ID.Msg_BuyMagicResp_Ret,
    handler(self, self.response))

    assert(NetWorkCfg)
    NetWorkCfg.innerEventComponent:addEventListener(NetWorkCfg.InnerEvents.NETWORK_EVENT_LOGINOK, function()
        -- 登录成功即去获取游戏中购买道具配置。
        self:requestPropListInGame()
    end )
end

function StoreProxy:response(msgId, msgTable)

    local dispatchEventId = nil
    local dispatchData = nil
    if msgId == self._ShopModel.MSG_ID.Msg_ShopList_Ret then

        if (msgTable.MneuID == wwConfigData.CHARGE_FIRST_MENUID_DIAMOND) then
            -- wwdump(msgTable, self.logTag .. " 接受一级菜单 - " .. msgTable.MneuID)
            dispatchEventId = StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST
            DataCenter:cacheData(StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST, msgTable)
            -- 取得默认支付方式的商品信息
            self:requestAllSecondMenus(msgTable.Items, msgTable.MneuID)
        elseif (msgTable.MneuID == wwConfigData.CHARGE_FIRST_MENUID_GOLD) then
            -- wwdump(msgTable, self.logTag .. " 接受一级菜单 - " .. msgTable.MneuID)
            dispatchEventId = StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST_GOLD
            DataCenter:cacheData(StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST_GOLD, msgTable)
            -- 取得默认支付方式的商品信息
            self:requestAllSecondMenus(msgTable.Items, msgTable.MneuID)
        elseif msgTable.MneuID == wwConfigData.CHARGE_FIRST_MENUID_FIRSTCHARGE then
            -- HallCfg.InnerEvents.HALL_EVENT_FIRSTCHARGE_CONTENT
            if HallCfg.innerEventComponent then
                HallCfg.innerEventComponent:dispatchEvent( {
                    name = HallCfg.InnerEvents.HALL_EVENT_FIRSTCHARGE_CONTENT;
                    _userdata = msgTable;
                } )
            end

        else
            -- wwdump(msgTable, self.logTag .. " 接受二级菜单 - " .. msgTable.MneuID, 5)
            dispatchEventId = StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTSECOND

            local menuid = msgTable.MneuID

            if msgTable.Items[1].CashTpye == wwConfigData.CHARGE_FIRST_MENUID_DIAMOND then
                -- 根据支付类型来区分是钻石还是金币
                self.shopSecondMenus[menuid] = msgTable
            elseif msgTable.Items[1].CashTpye == wwConfigData.CHARGE_FIRST_MENUID_GOLD then
                -- wwdump(self.shopSecondMenusGolds[menuid])
                self.shopSecondMenusGolds[menuid] = msgTable
            end

            wwlog(self.logTag, " 收到二级菜单对应的一级菜单ID - " .. msgTable.MneuID)

            LoadingManager:endLoading()
        end


        -- self:unregisterMsgId(self._ShopModel.MSG_ID.Msg_ShopList_Ret, StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST)
    elseif msgId == self._ShopPropModel.MSG_ID.Msg_StoreMagicList_Ret then
        -- wwdump(msgTable, "收到道具列表返回")

        if msgTable.StoreID == wwConfigData.CHARGE_STORE_PROP then
            dispatchEventId = StoreCfg.InnerEvents.STORE_EVENT_PROPLIST
            -- wwdump(msgTable, "", 5)
            self.shopProps = self:doPropListInfo(msgTable)
            -- wwdump(self.shopProps, "", 5)
        elseif msgTable.StoreID == wwConfigData.CHARGE_STORE_GOLD then
            dispatchEventId = StoreCfg.InnerEvents.STORE_EVENT_GOLDPROPLIST
            self.shopGoldProps = self:doPropListInfo(msgTable)
            -- wwdump(self.shopGoldProps.StoreMagicInfos, "收到道具列表返回转换")
        elseif msgTable.StoreID == wwConfigData.CHARGE_STORE_PROP_GAME then
            -- 游戏中道具购买配置，如记牌器，鲜花，拖鞋购买使用。缓存到UserData中。
            local shopConfInGame = { }
            local tmpFid = nil
            for k, v in ipairs(msgTable.Expires) do
                tmpFid = msgTable.fids[k].fid
                shopConfInGame[tmpFid] = shopConfInGame[tmpFid] or { }
                table.merge(shopConfInGame[tmpFid], v)
                table.merge(shopConfInGame[tmpFid], msgTable.StoreMagicInfos[k])
                table.merge(shopConfInGame[tmpFid], msgTable.dayLimits[k])
                table.merge(shopConfInGame[tmpFid], msgTable.fids[k])
                table.merge(shopConfInGame[tmpFid], msgTable.marketMoneys[k])
            end
            DataCenter:getUserdataInstance():setUserInfoByTable( { shopConf_inGame = shopConfInGame })
        end

        self:unregisterMsgId(self._ShopModel.MSG_ID.Msg_StoreMagicList_Ret, StoreCfg.InnerEvents.STORE_EVENT_PROPLIST)
        LoadingManager:endLoading()

    elseif msgId == self._ShopPropModel.MSG_ID.Msg_BuyMagicResp_Ret then
        -- wwdump(msgTable, "收到请求购买道具返回")
        -- dispatchEventId = StoreCfg.InnerEvents.STORE_EVENT_BUYPROP

        -- 道具购买成功
        local result = msgTable.result
        local desc = msgTable.Desc
        local gameCash = msgTable.gameCash

        if result == 0 then
            -- 在游戏对局中会购买记牌器，这时候self.LastbuyGoldNum是空的，所以加了个空判断。
            if self.LastbuyGoldNum then
                local showNums = 1
                if self.LastBuyPropType == 0 then

                    -- Modify start 2016-12-21修改财富刷新，用统一函数
                    -- 钻石购买金币
                    -- DataCenter:getUserdataInstance():setUserInfoByKey("Diamond", gameCash)
                    -- local lastGoldCount = DataCenter:getUserdataInstance():getValueByKey("GameCash")
                    showNums = self.LastbuyGoldNum
                    -- DataCenter:getUserdataInstance():setUserInfoByKey("GameCash", self.LastbuyGoldNum + lastGoldCount)

                    --加金币
                    updataGoods(10170998, self.LastbuyGoldNum)
                    --加钻石
                    updataGoods(20010993, gameCash, true)

                    -- Modify End 2016-12-21修改财富刷新，用统一函数


                    wwlog(self.logTag, "---------- %d, %d", self.LastbuyGoldNum, gameCash)

                    -- wwlog("钻石购买金币：", "lastGoldCount %d  self.LastbuyGoldNum  %d", lastGoldCount, self.LastbuyGoldNum)
                    -- wwlog("刷新后：", DataCenter:getUserdataInstance():getValueByKey("GameCash"))
                    -- 这个地方 如果之前破产了 还要重新请求
                    if DataCenter:getUserdataInstance():getValueByKey("bankrupt") then
                        DataCenter:getUserdataInstance():setUserInfoByKey("bankrupt", false)
                        local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
                        HallSceneProxy:requestIsBankrupt()
                    end

                elseif self.LastBuyPropType == 1 then
                    -- 钻石购买道具
                    DataCenter:getUserdataInstance():setUserInfoByKey("Diamond", gameCash)
                    -- TODO 更新相应的物品数量
                    showNums = self.LastbuyGoldNum

                    wwdump(self.BuyPropData, "购买道具成功")

                    UmengManager:eventCount("PropBuyOk")
                    UmengManager:eventBuy(self.BuyPropData.Name, self.BuyPropData.magicCount,
                    self.BuyPropData.Money / self.BuyPropData.magicCount)

                    -- 刷新物品箱
                    updataGoods(self.LastBuyPropFid, showNums)
                end

                -- 展示界面
                local retData = { }
                local cellData = { }
                -- cellData.fid = self.LastBuyPropFid
                cellData.MagicID = self.BuyPropData.MagicID
                cellData.name = self.BuyPropData.Name
                cellData.num = showNums
                table.insert(retData, cellData)

                wwdump(cellData)

                -- Delete start 2016-12-21修改财富刷新，用统一函数,放到具体的购买物品条件里面

                -- -- 刷新物品箱
                -- updataGoods(self.LastBuyPropFid, showNums)
                -- Delete end 2016-12-21修改财富刷新，用统一函数


                local ItemShowView = import(".ItemShowView", "app.views.customwidget."):create(retData):show()

                self.LastbuyGoldNum = 0
            end
		elseif result == 1 then --用户帐户余额不足
			if self.LastBuyPropType == 0  then --钻石购买金币
				Toast:makeToast(i18n:get("str_store", "prop_buy_tips1"), 3.0):show()
                -- 弹选择界面
                self:dispatchEvent(StoreCfg.InnerEvents.STORE_EVENT_OPENCHARGETYPE)
            elseif self.LastBuyPropType == 1 then
                Toast:makeToast(i18n:get("str_store", "prop_buy_tips2"), 3.0):show()
            end

        else
            Toast:makeToast(desc, 3.0):show()
        end
        -- Toast:makeToast(desc, 3.0):show()
        self:unregisterMsgId(self._ShopModel.MSG_ID.Msg_BuyMagicResp_Ret, StoreCfg.InnerEvents.STORE_EVENT_BUYPROP)
    end

    if dispatchEventId and StoreCfg.innerEventComponent then
        StoreCfg.innerEventComponent:dispatchEvent( {
            name = dispatchEventId;
            _userdata = dispatchData;
        } )
    end
end

-- 根据类型获取全部二级菜单数据map
function StoreProxy:getSecondMenus(ShopType)
    local ret = { }
    if ShopType == StoreCfg.ShopType.STORE_DIAMOND then
        wwlog(self.logTag, "当前获取钻石全部数据")
        ret = self.shopSecondMenus
    elseif ShopType == StoreCfg.ShopType.STORE_GOLD then
        wwlog(self.logTag, "当前获取金币全部数据")
        ret = self.shopSecondMenusGolds
    elseif ShopType == StoreCfg.ShopType.STORE_PROP then
        -- wwdump(self.shopProps, "当前获取物品全部数据", 5)
        ret = self.shopProps
    end
    return ret
end

function StoreProxy:getGoldPropinfos()
    return self.shopGoldProps
end

-- 根据选择的MenuID获得支付类型相关信息
-- chargeTypeInfos 返回支付状态   
function StoreProxy:getChargeTypeByMenuID(menuid, tabTag)
	local chargeTypeInfos = {}
	local menudatas = {}  --对应一级菜单下的二级菜单数据
	local chargeTypeInSecond

	if menuid == 0 then
		chargeTypeInSecond = 0
	else
        if tabTag == StoreCfg.ShopType.STORE_DIAMOND then
            -- wwdump(self.shopSecondMenus)
            if self.shopSecondMenus[menuid]
                and self.shopSecondMenus[menuid].Items[1].ChargeType then
                -- 默认取2级菜单下的第一条的支付类型
                chargeTypeInSecond = self.shopSecondMenus[menuid].Items[1].ChargeType
            end
        elseif tabTag == StoreCfg.ShopType.STORE_GOLD then
            -- wwdump(self.shopSecondMenusGolds[menuid], menuid)
            if self.shopSecondMenusGolds[menuid].Items
                and self.shopSecondMenusGolds[menuid].Items[1].ChargeType then
                -- 默认取2级菜单下的第一条的支付类型
                chargeTypeInSecond = self.shopSecondMenusGolds[menuid].Items[1].ChargeType
            end
        end
    end

    for _, v in pairs(StoreCfg.ShopTypeSrc) do
        if v.cType == chargeTypeInSecond then
            chargeTypeInfos = v
        end
    end

    -- wwdump(chargeTypeInfos, chargeTypeInSecond)

    -- wwdump(chargeTypeInfos)
    return chargeTypeInfos
end

-- 根据支付ID从二级菜单中筛选数据
-- cType 支付类型   shopType 获取商品类型数据
-- 返回值  datas Items数据用来显示在页面
-- 返回值  isThisChargeShow  就是传入的cType类型的数据
-- 返回值  cTypeItemID  cType(约定的字符方式)对应的 一级菜单中的itemID
function StoreProxy:getDatasByChargeType(cType, shopType)
    local isThisChargeShow = false
    local datas = { }
    local cTypeItemID

    wwlog(self.logTag, cType .. "-" .. shopType)

    for k, v in pairs(self:getSecondMenus(shopType)) do
        -- wwdump(v)
        if cType == v.Items[1].ChargeType then
            -- wwdump(v)
            isThisChargeShow = true
            datas = v.Items
            cTypeItemID = v.MneuID
            break
        end
    end

    return datas, isThisChargeShow, cTypeItemID
end

--[[
--请求商品列表
-- menuid 一级菜单请求是获取字符方式
--		  一级菜单获取到后，根据结果获取二级菜单数据
-- 2016-11-21 新增场景ID上报
--]]
function StoreProxy:requestShopList(_menuid, bankid)
    -- TODO 请求商城一级菜单数据

    local chargeSceneID = self.buySceneID or wwConfigData.CHARGE_STATUE_DEFAULT

    if bankid == wwConfigData.CHARGE_BANKID_GOLD then
        chargeSceneID = chargeSceneID .. wwConfigData.CHARGE_STATUE_GOLD_END
    elseif bankid == wwConfigData.CHARGE_BANKID_DIAMOND then
        chargeSceneID = chargeSceneID .. wwConfigData.CHARGE_STATUE_DIAMOND_END
    end

    local paras = {
        100,
        1,
        1,
        DataCenter:getUserdataInstance():getValueByKey("userid"),
        0,-- 请求类型
        _menuid,-- MenuID
        wwConst.OP,-- 11, -- wwConst.OP,
        wwConst.SP,-- 5148, -- wwConst.SP,
        "",-- Account
        "",-- Mid
        1,-- NewFlag
        "960x640",-- IPhoneTool:getMobileModel(), --IconSize
        0,-- Param1
        0,-- Param2
        0,-- Param3
        0,-- Param4
        bankid,-- bankID  1017 金币   9023 钻石  TODO  斗2 1001
        tonumber(chargeSceneID),-- SceneID 初始化，填打开界面的ID
        wwConfigData.GAME_HALL_ID,
    }

    -- wwdump(paras)

    self:sendMsg(self._ShopModel.MSG_ID.Msg_ShopList_send, paras)

end


function StoreProxy:requestFirstChargeInfo()
    local chargeSceneID = self.buySceneID or wwConfigData.CHARGE_STATUE_DEFAULT
    local bankid = wwConfigData.CHARGE_BANKID_DIAMOND
    if bankid == wwConfigData.CHARGE_BANKID_GOLD then
        chargeSceneID = chargeSceneID .. wwConfigData.CHARGE_STATUE_GOLD_END
    elseif bankid == wwConfigData.CHARGE_BANKID_DIAMOND then
        chargeSceneID = chargeSceneID .. wwConfigData.CHARGE_STATUE_DIAMOND_END
    end

    local paras = {
        100,
        1,
        1,
        DataCenter:getUserdataInstance():getValueByKey("userid"),
        6,-- 请求类型
        0,-- MenuID
        wwConst.OP,-- 11, -- wwConst.OP,
        wwConst.SP,-- 5148, -- wwConst.SP,
        "",-- Account
        "",-- Mid
        1,-- NewFlag
        "960X640",-- IPhoneTool:getMobileModel(), --IconSize
        0,-- Param1
        0,-- Param2
        wwConfigData.FIRSTCHARGEFID,-- Param3 首充的FID
        1,-- Param4
        bankid,-- bankID  1017 金币   9023 钻石  TODO  斗2 1001
        tonumber(chargeSceneID),-- SceneID 初始化，填打开界面的ID
        wwConfigData.GAME_HALL_ID,
    }

    wwdump(paras, "首充")

    self:sendMsg(self._ShopModel.MSG_ID.Msg_ShopList_send, paras)
end
-- 请求道具列表
function StoreProxy:requestPropList()
    self:_requestPropList(wwConfigData.CHARGE_STORE_PROP, wwConfigData.CHARGE_BANKID_DIAMOND)
end

-- 游戏对局中道具配置表，如对局中购买记牌器。将缓存到UserData的shopConf_inGame中。
function StoreProxy:requestPropListInGame()
    self:_requestPropList(wwConfigData.CHARGE_STORE_PROP_GAME, wwConfigData.CHARGE_BANKID_DIAMOND)
end

-- storeType:钻石兑换金币、钻石兑换物品、游戏中购买道具
-- bankID:金币BankID、钻石BankID
function StoreProxy:_requestPropList(storeType, bankID)
    local paras = {
        17,
        11,
        1,
        0,-- type
        wwConfigData.GAME_ID,
        storeType,
        1,-- CashType
        bankID
    }
    self:sendMsg(self._ShopPropModel.MSG_ID.Msg_MagicStoreReq_send, paras)

    LoadingManager:startLoading()
end

-- 请求钻石购买金币道具列表
function StoreProxy:requestGoldPropList()
    local paras = {
        17,
        11,
        1,
        0,-- type
        wwConfigData.GAME_ID,
        wwConfigData.CHARGE_STORE_GOLD,-- ObjectID
        1,-- CashType
        wwConfigData.CHARGE_BANKID_DIAMOND,-- bankID
    }
    self:sendMsg(self._ShopPropModel.MSG_ID.Msg_MagicStoreReq_send, paras)
end

-- 请求购买道具
-- cellPara 选择道具的信息
--    4 = {
--         "Description"  = "记牌器"
--         "Introduce"    = "记牌器"
--         "MagicID"      = 8
--         "Money"        = 900
--         "Name"         = "记牌器"
--         "StoreMagicID" = 11
--     }
function StoreProxy:requestBuyProp(cellPara, storeid)
    -- wwdump(cellPara)

    local MagicID = cellPara.MagicID
    local Price = cellPara.Money
    local StoreMagicID = cellPara.StoreMagicID
    local PlayID = cellPara.PlayID
    local GameZoneID = cellPara.GameZoneID
    local PlayType = cellPara.PlayType

    -- if storeid == wwConfigData.CHARGE_STORE_GOLD then
    -- 	Count = 1 --如果是钻石购买金币，则购买数量为1 （类似一个礼包）
    -- 	self.LastbuyGoldNum = cellPara.magicCount  --购买成功后加上金币数量
    -- end
    local Count = cellPara.Count
    -- 如果是钻石购买金币，则购买数量为1 （类似一个礼包）
    self.LastbuyGoldNum = cellPara.magicCount

    if storeid == wwConfigData.CHARGE_STORE_GOLD then
        self.LastBuyPropType = 0
        self.LastBuyPropFid = cellPara.fid
    elseif storeid == wwConfigData.CHARGE_STORE_PROP then
        self.LastBuyPropType = 1
        self.LastBuyPropFid = cellPara.fid
    elseif storeid == wwConfigData.CHARGE_STORE_PROP_GAME then
        -- 游戏中购买道具,影响购买响应的toast提示
        self.LastBuyPropType = 1
        self.LastBuyPropFid = cellPara.fid
    end

    local paras = {
        17,
        3,
        1,
        MagicID,
        Price or 0,
        Count or 1,
        0,-- DestUserID
        wwConfigData.GAME_ID,
        PlayID or 0,-- setPlayID
        "",-- setMid
        wwConfigData.CHARGE_FIRST_MENUID_DIAMOND,-- setCashType
        PlayType or 0,-- setplayType
        storeid,-- wwConfigData.CHARGE_STORE_PROP, --storeid
        GameZoneID or 0,-- 游戏中购买填写 否则0
        wwConfigData.CHARGE_BANKID_DIAMOND,
        0,-- targetGameID
        StoreMagicID or 0,
    }
    -- wwdump(paras)
    self.BuyPropData = cellPara

    self:sendMsg(self._ShopPropModel.MSG_ID.Msg_BuyMagicReq_send, paras)
end

function StoreProxy:requestAllSecondMenus(firstMenus, MneuID)
    wwlog(self.logTag, "MneuID:" .. MneuID)

	local bankid
	if MneuID == wwConfigData.CHARGE_FIRST_MENUID_GOLD then --金币
		bankid = wwConfigData.CHARGE_BANKID_GOLD
	elseif MneuID == wwConfigData.CHARGE_FIRST_MENUID_DIAMOND then --钻石
		bankid = wwConfigData.CHARGE_BANKID_DIAMOND
	end
	for _,v in ipairs(firstMenus) do
		if v.ItemID then
			self:requestShopList(v.ItemID, bankid) --获取某一个支付条件下所有的商品
		end
	end
end

-- 根据缓存读取当前支付选择信息
function StoreProxy:getChooseChargeTypeSrc()

    local defaultChargeKey = ww.WWGameData:getInstance():getIntegerForKey(StoreCfg.ChargeKey, 0)

    local srcCell
    for _, v in ipairs(StoreCfg.ShopTypeSrc) do
        if v.cType == defaultChargeKey then
            srcCell = v
            break
        end
    end

    if srcCell == nil then
        srcCell = StoreCfg.ShopTypeSrc[1]
        ww.WWGameData:getInstance():setIntegerForKey(StoreCfg.ChargeKey, srcCell.cType)
    end

    wwdump(srcCell)

    return srcCell
end

-- 根据CashTpye读取当前支付选择信息
function StoreProxy:getChargeTypeByCashTpye(CashTpye)

    wwlog(self.logTag, "CashTpyeCashTpyeCashTpyeCashTpye" .. CashTpye)

    local srcCell
    for _, v in ipairs(StoreCfg.ShopTypeSrc) do
        if v.cType == CashTpye then
            srcCell = v
            break
        end
    end

    return srcCell
end

-- 将S道具商城协议中的多段信息，拼成一个table
function StoreProxy:doPropListInfo(oriData)
    local retTable = { }

    retTable.GameID = oriData.GameID
    retTable.StoreID = oriData.StoreID

	local newTable = {}
	local keyTable = {}  --记录MagicID
	local indexTable = {}
	newTable.StoreMagicInfos = oriData.StoreMagicInfos

    -- wwdump(oriData, "原价")

    for i, v in ipairs(oriData.StoreMagicInfos) do
        local newCell = v

        -- Expires
        local oriExpireCell = oriData.Expires[i]
        newCell.Expire = oriExpireCell.Expire

        local oridayLimits = oriData.dayLimits[i]
        newCell.buystatus = oridayLimits.buystatus
        newCell.dayLimit = oridayLimits.dayLimit
        newCell.monthLimit = oridayLimits.monthLimit

        local orifids = oriData.fids[i]
        newCell.fid = orifids.fid
        newCell.magicCount = orifids.magicCount

        local orimarketMoneys = oriData.marketMoneys[i]
        newCell.marketMoney = orimarketMoneys.marketMoney

        local keyMagicID = newCell.MagicID

        if keyTable[keyMagicID] then
            table.insert(keyTable[keyMagicID], i)
        else
            local tmpTable = { }
            table.insert(tmpTable, i)
            keyTable[keyMagicID] = tmpTable
        end
    end

    -- wwdump(keyTable)

    retTable.StoreInfos = { }

    for k, v in pairs(keyTable) do
        local Items = { }
        for ii, vv in ipairs(v) do
            -- dump(retTable.StoreInfos.StoreMagicInfos[vv])
            table.insert(Items, newTable.StoreMagicInfos[vv])
        end
        table.insert(retTable.StoreInfos, Items)
    end

    -- wwdump(retTable.StoreInfos)

    return retTable
end

function StoreProxy:requestDiamond()
    self:requestShopList(wwConfigData.CHARGE_FIRST_MENUID_DIAMOND,
    wwConfigData.CHARGE_BANKID_DIAMOND)
    LoadingManager:startLoading()
end

function StoreProxy:requestGold()
    self:requestShopList(wwConfigData.CHARGE_FIRST_MENUID_GOLD,
    wwConfigData.CHARGE_BANKID_GOLD)
    LoadingManager:startLoading()
end

function StoreProxy:getBuycellDatas()
    return self.buycellDatas, self.buyUnit
end

function StoreProxy:setBuycellDatas(cellDatas, buyUnit)
    self.buycellDatas = cellDatas
    self.buyUnit = buyUnit
end

return StoreProxy