-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal.yin
-- Date:    2016.09.14
-- Last: 
-- Content:  通用充值委托
-- Modify : 
--     2016-11-21 添加事件上报，计费统计
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local ChargeProxy = class("ChargeProxy",
	require("packages.mvc.Proxy"))

local ChargeArgesUtils = require("app.customCharge.ChargeArgesUtils"):create()

local LuaChargeNativeBridge = require("app.utilities.LuaChargeNativeBridge"):create()

local StoreCfg = require("hall.mediator.cfg.StoreCfg")

local JsonDecorator = import(".JsonDecorator", "app.utilities."):create()

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local Toast = require("app.views.common.Toast")

function ChargeProxy:init()
	self.logTag = "ChargeProxy.lua"
	self._shopChargeModel = require("app.netMsgBean.shopChargeModel"):create(self)

	self.menuInfos = {}
	self.lastRequestMenuInfos = {} --上一次充值请求菜单数据
	self.chooseIndex = 0

	self:registerMsg()
end

function ChargeProxy:registerMsg()
	self:registerMsgId(self._shopChargeModel.MSG_ID.Msg_ResultInfo_Ret, 
		handler(self, self.response))

	--返回通用消息 获取充值订单请求返回
	self:registerRootMsgId(self._shopChargeModel.MSG_ID.Msg_LXCharge_send,
	 handler(self,self.response), GLOBAL_EVENTS.G_EVENT_CHARGE_REQUESTORDERID)

	self:registerMsgId(self._shopChargeModel.MSG_ID.msg_NMESSAGE_SMSCOMMANDRESP, 
		handler(self, self.response))
end

function ChargeProxy:response(msgId, msgTable)

	local dispatchEventId = nil
	local dispatchData = nil

	-- Toast:makeToast("收到消息ID: "..msgId,2.0):show()
	
	if msgId == self._shopChargeModel.MSG_ID.Msg_LXCharge_send then
		-- dispatchEventId
		dump(msgTable, msgId)

		--TODO 调用支付接口
		self:callSDKPay(msgTable)
	
		self:unregisterMsgId(self._shopChargeModel.MSG_ID.Msg_LXCharge_send, StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST)
	elseif msgId == self._shopChargeModel.MSG_ID.Msg_ResultInfo_Ret then
		wwdump(msgTable, self.logTag.."充值消息返回")
		UmengManager:eventCount("ChargeStep2")

		if msgTable.Result == 0 then
			Toast:makeToast(msgTable.Description, 1.0):show()
		elseif msgTable.Result == 19 then
			--TODO 加金币
			local cash = tonumber(msgTable.Money)
			local gameCashFid = 10170998
			updataGoods(gameCashFid, cash, true)
			Toast:makeToast(msgTable.Description, 1.0):show()
		elseif msgTable.Result == 15 then --月首充到账
			--更新玩家数据
			local retData = {}

			local items = msgTable.Items
			for i,v in ipairs(items) do

				local tMagicFID = v.MagicFID
				local tMagicCount = v.MagicCount

				local cellData = {}
				cellData.fid = tMagicFID
				cellData.num = tMagicCount
				table.insert(retData, cellData)

				updataGoods(tMagicFID, tMagicCount, false) --add 额度
			end

			--展示界面			
			local ItemShowView = import(".ItemShowView", "app.views.customwidget."):create(retData):show()

			self:dispatchEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO,1) --刷新
			self:dispatchEvent(COMMON_EVENTS.C_EVENT_FIRSTQUERY) --刷新
			
		else
			--到账通知 TODO 到账页面展示
			local gameCash = msgTable.GameCash
			local Moneytype = msgTable.Moneytype
			-- Toast:makeToast(msgTable.Description, 5.0):show()

			--展示界面
			local retData = {}
			local cellData = {}
			local itemGoldInfo = getGoodsByFlag("GOLD")
			local itemDiamondInfo = getGoodsByFlag("Diamond")

			if Moneytype == wwConfigData.CHARGE_FIRST_MENUID_GOLD then
				--金币
				cellData.fid = itemGoldInfo.fid
				--DataCenter:getUserdataInstance():setUserInfoByKey("GameCash", gameCash)
			elseif Moneytype == wwConfigData.CHARGE_FIRST_MENUID_DIAMOND then
				--钻石
				cellData.fid = itemDiamondInfo.fid
				--DataCenter:getUserdataInstance():setUserInfoByKey("Diamond", gameCash)
			end
			updataGoods(cellData.fid,gameCash,true)
			cellData.num = msgTable.AddGameCash
			table.insert(retData, cellData)

			local ItemShowView = import(".ItemShowView", "app.views.customwidget."):create(retData):show()

			self:dispatchEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO,1) --刷新
		end
	elseif msgId == self._shopChargeModel.MSG_ID.msg_NMESSAGE_SMSCOMMANDRESP then
			wwdump(msgTable, "收到数据短信返回来的消息")
			wwdump(self.menuInfos,"充值菜单的相关信息.....")
			local orderInfoJson = ChargeArgesUtils:getOrderInfoJson(self.menuInfos, self.chooseIndex)
			wwlog(self.logTag,"数据短信menuinfojson=%s",menuinfojson)
			if(msgTable.result ==0) then 
				wwdump(msgTable, "充值返回消息正常！！！")
				local status, resultjson = JsonDecorator:encode(msgTable)
				LuaChargeNativeBridge:callNativenMessage_SMSCommandResp(1,resultjson,orderInfoJson,
											   handler(self, self.chargeReportStateCallBack),
											   handler(self, self.chargeStateCallBack),
											   handler(self, self.payState2Lua))
			elseif(msgTable.result ==1)then
				wwdump(msgTable, "充值菜单不存在！！！")			
			elseif(msgTable.result ==2)then
				wwdump(msgTable, "获取订单号不存在！！！")
			else
				wwdump(msgTable, "其他异常.....")
			end
	end

	-- if dispatchEventId and StoreCfg.innerEventComponent then
	-- 	StoreCfg.innerEventComponent:dispatchEvent({
	-- 				name = dispatchEventId;
	-- 				_userdata = dispatchData;
	-- 			})
	-- end
end

--请求订单信息
--menuInfos 所选支付方式下的二级菜单  index 选中行
function ChargeProxy:requestOrder( menuInfos, index, nowSceneID)

	if type(menuInfos) ~= "table" then
		wwlog(self.logTag,"调用充值的参数为空")
		return
	else
		-- wwdump(menuInfos, "请求订单信息 - " .. index)
	end

	local _nowSceneID = nowSceneID or wwConfigData.CHARGE_STATUE_DEFAULT

	if DEBUG > 0 then
		Toast:makeToast("充值场景ID:".. _nowSceneID, 1.0):show()
	end

	self.menuInfos = menuInfos
	self.chooseIndex = index

	--取集合中具体选中行参数
	local Items = menuInfos.Items[index]
	local MenuTypes = menuInfos.MenuTypes[index]
	local bankIDs = menuInfos.bankIDs[index]

	local chargeSP = Items.SP --充值渠道SP
	local SpServiceID = Items.SPServiceID --业务代码
	local CustemCode = ""--消费码
	local CashTpye = Items.CashTpye

	local chargeType = Items.ChargeType
	local Type = ChargeArgesUtils:getOrderIdRequestTypeByChargeType(chargeType) --Type请求类型 （上报服务器 请求类型 失败传24 成功 29）

	local signedData = ChargeArgesUtils:getSignData(Type, menuInfos, index) --根据type来判断  
	local signature = "" --（TODO 上报服务器 传订单号）
	local Newflag = 1 --新版二级菜单结构
	local StrPram1 = "" --当前充值SDK版本
	local StrPram2 = "" --错误代码 （TODO错误码为 传24 写入错误信息 成功传NULL）
	local TMagicID = MenuTypes.TMagicID --错误代码 （TODO错误码为 传24 写入错误信息 成功传NULL）
	local MoneyFen = Items.Money  --//金额 单位分
	local ItemID = Items.ItemID  --//菜单ID
	local bankID = bankIDs.bankID  --//bankID
	local sceneID = _nowSceneID or bankIDs.sceneID  --//sceneID
	-- local sceneID = bankIDs.sceneID  --//sceneID
	local hallID = bankIDs.hallID  --//hallID

	local paras = {
	    100,
	    1,
	    18,
		DataCenter:getUserdataInstance():getValueByKey("userid"),  --4
		MoneyFen / 100, -- 5 金额元
		ww.IPhoneTool:getInstance():getIMEI(),-- 6 用户伪码  IMEI
		"", -- 7 mdn手机号
		chargeSP, --8 //充值渠道SP
		SpServiceID,	-- 9 业务代码
		CustemCode, -- 10 消费码
		CashTpye, -- 11 金币类型 0蛙币 1蛙豆
		Type,  -- 12 Type请求类型
		signedData,  --13 验证字符串
		signature, --14 签名  
		Newflag, --15 新版二级菜单结构
		chargeSP,--16 充值SP
		0, -- 17 Parameter1
		StrPram1,  -- 18 StrPram1 //当前充值SDK版本
		StrPram2,  --19 StrPram2 //
		wwConfigData.GAME_ID, -- 20 GameID
		TMagicID, -- 21 MagicID
		MoneyFen, -- 22 MoneyFen
		ItemID, -- 23 menuid
		bankID, -- 24 bankID
		sceneID,  -- 25 sceneID
		hallID,  -- 26 hallID
	}
	dump(paras)

	--保留本次充值数据
	self.lastRequestMenuInfos = clone(paras)
	self:sendMsg(self._shopChargeModel.MSG_ID.Msg_LXCharge_send, paras)
end

--上传请求状态
function ChargeProxy:commitChargeStatus(jsonPara)


	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		dump(jsonPara)

	    local parameter1 = jsonPara.parameter1
	    local retType = jsonPara.type
	    local strPram1 = jsonPara.strPram1
	    local strPram2  = jsonPara.strPram2	
	    local signedData  = jsonPara.signedData	

	    -- if DEBUG == 3 then 
	    -- 	Toast:makeToast("提交充值状态 - "..retType, 1.0):show()
	    -- end

		self.lastRequestMenuInfos[12] = retType
		self.lastRequestMenuInfos[13] = signedData
		self.lastRequestMenuInfos[18] = strPram1
		self.lastRequestMenuInfos[19] = strPram2

		self:sendMsg(self._shopChargeModel.MSG_ID.Msg_LXCharge_send, self.lastRequestMenuInfos)
	elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
		or ((cc.PLATFORM_OS_IPAD == targetPlatform))
		or ((cc.PLATFORM_OS_MAC == targetPlatform))  then

		wwlog("ios charge", jsonPara)

		local paraArrs = Split(jsonPara, "&")
		wwdump(paraArrs, "iOS上报分割的参数")

	    -- if DEBUG == 3 then 
	    -- 	Toast:makeToast("提交充值状态 - "..retType, 1.0):show()
	    -- end

		self.lastRequestMenuInfos[12] = tonumber(paraArrs[2])  --Type请求类型 int
		self.lastRequestMenuInfos[13] = paraArrs[4]
		self.lastRequestMenuInfos[18] = paraArrs[3] --StrPram1  string
		self.lastRequestMenuInfos[19] = paraArrs[3] --StrPram1  string
		self.lastRequestMenuInfos[21] = tonumber(paraArrs[2]) --TMagicID  int

		dump(self.lastRequestMenuInfos)

		self:sendMsg(self._shopChargeModel.MSG_ID.Msg_LXCharge_send, self.lastRequestMenuInfos)
	end


end

-- 调用支付接口
function ChargeProxy:callSDKPay(msgTable)
	local orderInfoJson = ChargeArgesUtils:getOrderInfoJson(self.menuInfos, self.chooseIndex)
	wwlog(self.logTag, orderInfoJson)
	LuaChargeNativeBridge:callNativeChargeInfo(msgTable.kReason, 
											   orderInfoJson,
											   handler(self, self.chargeReportStateCallBack),
											   handler(self, self.chargeStateCallBack),
											   handler(self, self.payState2Lua) )
end

-- chargeReportStateCallBack  充值结果接口的数据回调函数
-- ret jsonString
--[[
{
    "userID": 0,
    "money": 5,
    "mdn": "",
    "sp": 8270,
    "spServiceID": 82706006,
    "consumeCode": "",
    "moneyType": 1,
    "type": 24,
    "signedData": "TZZF210189172092",
    "signature": "",
    "newFlag": 1,
    "sp1": 8270,
    "parameter1": 13,
    "strPram1": "",
    "strPram2": "CANCEL",
    "gameID": 0,
    "magicID": 0,
    "moneyFen": 540
}
--]]
function ChargeProxy:chargeReportStateCallBack(jsonString)
	wwlog(self.logTag, "返回值 - "..jsonString)
	--调用状态通知
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		local status, result = JsonDecorator:decode(jsonString)
		self:commitChargeStatus(result)
	elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
		self:commitChargeStatus(jsonString)
	end


	-- if DEBUG == 3 then 
	-- 	Toast:makeToast("SDK 回调 chargeReportStateCallBack",2.0):show()
	-- end

end
-- chargeStateCallBack   充值接口状态回调函数  24
-- isSuccess yes/no 是否充值成功
function ChargeProxy:chargeStateCallBack(isSuccess)
	if isSuccess == "yes" then
		wwlog(self.logTag, "充值 成功")
		-- UmengManager:eventCount("ChargeStep2")
	elseif isSuccess == "no" then
		wwlog(self.logTag, "充值 失败")
	end
end
-- payState2Lua		Andrioid端状态回调到底层C++  29
-- retstr = state, type, description
-- 0 成功  1 失败  2 取消
function ChargeProxy:payState2Lua(retstr)
	wwlog(self.logTag, "payState2Lua "..retstr)

	if not retstr then
		return
	end

	local paraArrs = Split(retstr, "&")
	local chargeState

	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		chargeState = tonumber(paraArrs[1])
	elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
		chargeState = tonumber(paraArrs[5])
	end
	
	if chargeState == 0 then
	elseif chargeState == 1 then
		Toast:makeToast(i18n:get("str_store", "ChargeFailue"), 2.0):show()
		performWithDelay(display.getRunningScene(),function ()
			Toast:makeToast(i18n:get("str_store", "ChargeFailue"), 2.0):show()
		end,0.3)
		UmengManager:eventCount("ChargeStep3")
	elseif chargeState == 2 then
		performWithDelay(display.getRunningScene(),function ()
			Toast:makeToast(i18n:get("str_store", "ChargeCancel"), 2.0):show()
		end,0.3)
		
		UmengManager:eventCount("ChargeStep4")
	end

end

return ChargeProxy