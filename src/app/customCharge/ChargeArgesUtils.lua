-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal.yin
-- Date:    2016.09.14
-- Last: 
-- Content:  通用充值参数配比
-- 2016-09-18 添加订单信息Json组装
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local ChargeArgesUtils = class("ChargeArgesUtils",
	require("packages.mvc.Proxy"))

local ChargeArgsConfig = require("app.customCharge.ChargeArgsConfig")

local EChargeType = ChargeArgsConfig["EChargeType"]
local EPayOrderType = ChargeArgsConfig["EPayOrderType"]
local BasicConfig = ChargeArgsConfig["BasicConfig"]
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

local JsonDecorator = import(".JsonDecorator", "app.utilities."):create()
local LuaNativeBridge = require("app.utilities.LuaNativeBridge")
-- local json = require('json') 

function ChargeArgesUtils:init()
	self.logTag = "ChargeArgesUtils.lua"
	self._shopChargeModel = require("app.netMsgBean.shopChargeModel"):create(self)
end

--会根据sdk的配置不断添加新的请求类型
function ChargeArgesUtils:getOrderIdRequestTypeByChargeType(chargeType)

	local requestType = EPayOrderType.eOrderTypeUnknow
	if chargeType == EChargeType.FLAG_SMS then --11
		requestType = EPayOrderType.eOrderTypeChinaMobile
	elseif chargeType == EChargeType.FLAG_CHARGE_CARD then
	elseif chargeType == EChargeType.FLAG_DUOKU_YD_CARD then
    elseif chargeType == EChargeType.FLAG_DUOKU_LT_CARD then
    elseif chargeType == EChargeType.FLAG_DUOKU_DX_CARD then
        --充值卡序列号充值   
    elseif chargeType == EChargeType.FLAG_CMCC2 then
        --移动网游平台点数接口
    elseif chargeType == EChargeType.FLAG_HK_THREE then
        --香港短信充值
    elseif chargeType == EChargeType.FLAG_OTHER_SDK then  --12
     
    	--第三方充值判断订单号类型
    	local sdkType = BasicConfig.sdk_charge_tag
    	wwlog("第三方支付类型", "getOrderIdRequestTypeByChargeType==>sdkType:%s", sdkType)
		if sdkType == "54"  then
			requestType = EPayOrderType.eOrderTypeMO9--(当是mo9时设置为mo9 暂时设置为手动改)
		elseif sdkType == "17" then
			requestType = EPayOrderType.eOrderType3G  --请求订单号类型为3gsdk
		elseif sdkType == "53" then
			requestType = EPayOrderType.eOrderTypeBuBuGao--请求订单号类型是步步高vivo
		elseif sdkType == "35" then
			requestType = EPayOrderType.eOrderTypeOppo--请求订单号类型为35 oppo
		elseif sdkType == "36" then
			requestType = EPayOrderType.eOrderTypeLxsdk--请求订单号类型是36   联想网游
		else
			requestType = EPayOrderType.eOrderTypeThrid--请求订单号类型是50
		end        
    elseif chargeType == EChargeType.FLAG_ALIPAY then   --13
        --支付宝充值
        requestType = EPayOrderType.eOrderTypeAliPay
    elseif chargeType == EChargeType.FLAG_MMIAP then    --14
        --MM充值
        requestType = EPayOrderType.eOrderTypeMM
    elseif chargeType == EChargeType.FLAG_CTSMS then    --15
        --电信爱游戏充值
        requestType = EPayOrderType.eOrderTypeCTSMS
    elseif chargeType == EChargeType.FLAG_LTSMS then   --16
        --联通短信充值
        requestType = EPayOrderType.eOrderTypeLTSMS
    elseif chargeType == EChargeType.FLAG_CTSHOP then  --18
        --电信天翼空间充值
        requestType = EPayOrderType.eOrderTypeCTSHOP
    elseif chargeType == EChargeType.FLAG_Google then   --添加google商品号
        requestType = EPayOrderType.eOrderTypeGoogle
    elseif chargeType == EChargeType.FLAG_APP_STORE then    --AppStore充值
        requestType = EPayOrderType.eOrderTypeAppStore
	elseif chargeType == EChargeType.FLAG_LTWSMS then
			requestType=EPayOrderType.eOrderTypeChinaUnicom
	elseif chargeType == EChargeType.FLAG_WX then   --微信支付
			requestType = EPayOrderType.eOrderTypeWinxin
	elseif chargeType == EChargeType.FLAG_YD_GD then
			requestType = EPayOrderType.eOrderTypeYD_GD
	elseif chargeType == EChargeType.FLAG_EGAME then
		requestType = EPayOrderType.eOrderTypeEGa
	elseif chargeType == EChargeType.FLAG_SKYSDK then
		requestType = EPayOrderType.eOrderTypeS
	elseif chargeType == EChargeType.FLAG_HUAWEI then
		requestType = EPayOrderType.eOrderTypeHuaW
		
	elseif chargeType == EChargeType.FLAG_XUNXIAO then
		requestType = EPayOrderType.eOrderTypeXunXi
	elseif chargeType == EChargeType.Flag_TENPAY then
		requestType = EPayOrderType.eOrderTypeTENP
	elseif chargeType == EChargeType.FLAG_UNIONPAY then
		requestType = EPayOrderType.eOrderTypeUnionPay
	elseif chargeType == EChargeType.FLAG_CHANGBA then  --唱吧sdk
		requestType = EPayOrderType.eOrderTypeChang
	elseif chargeType == EChargeType.FLAG_AIBEI then    --三星爱贝sdk
		requestType = EPayOrderType.eOrderTypeAiB
	elseif chargeType == EChargeType.FLAG_QIANBAO then
		requestType = EPayOrderType.eOrderTypeQianB
	elseif chargeType == EChargeType.FLAG_MEIZU then
		requestType = EPayOrderType.eOrderTypeMei
	elseif chargeType == EChargeType.FLAG_IPAYNOW then
		requestType = EPayOrderType.eOrderTypeIpayNow
	elseif chargeType == EChargeType.FLAG_SMSYZM then
		requestType = EPayOrderType.eOrderTypeSmsY
	elseif chargeType == EChargeType.FLAG_QIANBAOSDK then
		requestType = EPayOrderType.eOrderTypeQianBaoS
	elseif chargeType == EChargeType.FLAG_ALIPAY_FREE then
		requestType = EPayOrderType.eOrderTypeAlipayFr
	elseif chargeType == EChargeType.FLAG_LHTB then
		requestType = EPayOrderType.eOrderTypeLh
	elseif chargeType == EChargeType.FLAG_PAPASDK then
		requestType = EPayOrderType.eOrderTypePaPas
	elseif chargeType == EChargeType.FLAG_XIAOMIWEIXIN then
		requestType = EPayOrderType.eOrderTypeXiaoMiWeiX
	elseif chargeType == EChargeType.FLAG_LITIAN then
		requestType = EPayOrderType.eOrderTypeLiTi
	elseif chargeType == EChargeType.FLAG_IQIYI  then
		requestType = EPayOrderType.eOrderTypeIQi
	elseif chargeType == EChargeType.FLAG_ZHUOYI then
		requestType = EPayOrderType.eOrderTypeZhuo
	elseif chargeType == EChargeType.FLAG_LIANXIANGAPI then
		requestType = EPayOrderType.eOrderTypeLianXiangA
	elseif chargeType == EChargeType.FLAG_SMS_NEW then
		requestType = EPayOrderType.eOrderTypeSmsN
	elseif chargeType == EChargeType.FLAG_NUBIA then
		requestType = EPayOrderType.eOrderTypeNub
	elseif chargeType == EChargeType.FLAG_SANXING then
		requestType = EPayOrderType.eOrderTypeSanXi
	elseif chargeType == EChargeType.FLAG_ZHUOYI_WX then
        requestType = EPayOrderType.eOrderTypeZhuoYiWX
    elseif chargeType == EChargeType.FLAG_ZHUOYI_ZFB then
        requestType = EPayOrderType.eOrderTypeZhuoYiZFB
    elseif chargeType == EChargeType.FLAG_KUGOUWY then
    	requestType = EPayOrderType.eOrderTypeKuGouWy
    elseif chargeType == EChargeType.FLAG_ALISDK then
    	requestType = EPayOrderType.eOrderTypeALiSdk
    elseif chargeType == EChargeType.FLAG_SMSDATA then
    	requestType = EPayOrderType.eOrderTypeSmsData
	end

	return requestType
end

function ChargeArgesUtils:getQuotStr( str)
	print("ChargeArgesUtils:getQuotStr..",str)
	return "\""..str .."\""
end

--signData获取
function ChargeArgesUtils:getSignData( cType,  menuInfos, index )
	-- wwdump(menuInfos, index)
	local Items = menuInfos.Items[index]
	local MenuTypes = menuInfos.MenuTypes[index]
	local bankIDs = menuInfos.bankIDs[index]
	local Discounts = menuInfos.Discounts[index]

	local signData = ""
	-- if cType == EPayOrderType. then
	if cType == 48 then
		--将这个48改成
	elseif cType == EPayOrderType.eOrderTypeAliPay then
		signData = "subject=" .. self:getQuotStr(Items.Name)
		.. "&body=" .. self:getQuotStr(Items.Name)
		.. "&total_fee=" .. self:getQuotStr(string.format("%.2f", Items.Money / 100 * Discounts.Discount / 100))
		.. "&notify_url=" .. self:getQuotStr(string.urlencode(Items.MenuData))
	elseif cType == EPayOrderType.eOrderTypeWinxin then
		print("ChargeArgesUtils:getSignData signData= Items.chargeCmd",Items.ChargeCmd)
		print("ChargeArgesUtils:getSignData signData= money",string.format("%.2f", Items.Money / 100 * Discounts.Discount / 100))
		print("ChargeArgesUtils:getSignData signData= Items.name",Items.Name)
		print("ChargeArgesUtils:getSignData signData= Items.menuData",Items.MenuData)
		signData = Items.ChargeCmd
		..","..string.format("%d", Items.Money * Discounts.Discount / 100)
		..","..LuaNativeBridge:create():getIpAddress()
		..","..Items.Name
		..","..Items.MenuData
		--..","..LuaNativeBridge:create():getIpAddress()
		print("输出签名字段", signData) 
		if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
			signData = signData..",1"
	    elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) 
	    	or ((cc.PLATFORM_OS_IPAD == targetPlatform))
	    	or ((cc.PLATFORM_OS_MAC == targetPlatform))  then
	    	signData = signData..",2"
		end
	else
		signData = Items.ChargeCmd
	end
	print("输出签名字段", signData) 
	return signData
end

--返回订单信息Json
function ChargeArgesUtils:getOrderInfoJson(menuInfos, chooseIndex)

	-- wwdump(menuInfos,"ChargeArgesUtils:getOrderInfoJson")

	local Items = menuInfos.Items[chooseIndex]
	local MenuTypes = menuInfos.MenuTypes[chooseIndex]
	local bankIDs = menuInfos.bankIDs[chooseIndex]
	local Confirms = menuInfos.Confirms[chooseIndex]
	local SmsTypes = menuInfos.SmsTypes[chooseIndex]

	local parentMenuID = menuInfos.MneuID

	local chargeData = {
		["selItem"] = 0,
		["menuId"] = parentMenuID,
		["count"] = 1,  --TODO 数量
		["itemId"] = {
	        -- 50251
	    },
		["name"] = {
	        -- "6.8万豆"
	    },
		["hot"] = {
	        -- 0
	    },
		["cashType"] = {
	        -- 13
	    },
		["chargeType"] = {
	        -- 23
	    },
		["toUser"] = {
	        -- 1
	    },
		["chargeCmd"] = {
	        -- "005"
	    },
		["menuData"] = {
	        -- ""
	    },
		["menuFlag"] = {
	        -- 0
	    },
		["money"] = {
	        -- 600
	    },
		["sp"] = {
	        -- 8524
	    },
		["spServiceID"] = {
	        -- 85246006
	    },
		["cash"] = {
	        -- 62000
	    },
		["donateCash"] = {
	        -- 0
	    },
		["menuKey"] = {
	        -- ""
	    },
		["description1"] = {
	        -- ""
	    },
		["description2"] = {
	        -- "您的购买请求[meta fontColor=\"0xff0000\" /]已经提交[meta /]，系统正在处理！[meta fontColor=\"0xff0000\" /]蛙豆到账[meta /]时请留意[meta fontColor=\"0xff0000\" /]提示信息[meta /]！话费不足、卡类限制、超过日限或月限等可能会导致购买失败，有疑问请电询：[meta fontColor=\"0x03ea26\" /]400-680-1212[meta /]"
	    },
		["description3"] = {
	        -- ""
	    },
		["confirm"] = {
	        -- 1
	    },
		["smsType"] = {
	        -- 0
	    },
		["smsOrder"] = {
	        -- ""
	    }
	}

	--插入itemId
	table.insert(chargeData.itemId, Items.ItemID)
	--插入name
	table.insert(chargeData.name, Items.Name)
	--插入Hot
	table.insert(chargeData.hot, Items.Hot)
	--插入CashTpye
	table.insert(chargeData.cashType, Items.CashTpye)
	--插入chargeType
	table.insert(chargeData.chargeType, Items.ChargeType)
	--插入ToUser
	table.insert(chargeData.toUser, Items.ToUser)
	--插入ChargeCmd
	table.insert(chargeData.chargeCmd, Items.ChargeCmd)
	--插入menuData
	table.insert(chargeData.menuData, Items.MenuData)
	--插入menuFlag
	table.insert(chargeData.menuFlag, Items.MenuFlag)
	--插入money
	table.insert(chargeData.money, Items.Money)
	--插入SP
	table.insert(chargeData.sp, Items.SP)
	--插入spServiceID
	table.insert(chargeData.spServiceID, Items.SPServiceID)
	--插入cash
	table.insert(chargeData.cash, Items.Cash)
	--插入donateCash
	table.insert(chargeData.donateCash, Items.DonateCash)
	--插入menuKey
	table.insert(chargeData.menuKey, Items.MenuKey)
	--插入description1
	table.insert(chargeData.description1, Items.Description1)
	--插入description1
	table.insert(chargeData.description2, Items.Description2)	
	--插入description3
	table.insert(chargeData.description3, Items.Description3)
	--插入confirm
	table.insert(chargeData.confirm, Confirms.Confirm)
	--插入SmsTypes
	table.insert(chargeData.smsType, SmsTypes.smsType or "")
	--插入SmsTypes
	table.insert(chargeData.smsOrder, SmsTypes.smsOrder or 0)

	-- wwdump(chargeData)

	local status, result = JsonDecorator:encode(chargeData)
	-- wwlog("Json", result)

	return result
end

return ChargeArgesUtils