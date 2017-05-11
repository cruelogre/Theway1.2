-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.25
-- Last: 
-- Content:  商城配置管理
--			包括常量定义 事件分发
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local StoreCfg = {}
StoreCfg.innerEventComponent = nil
StoreCfg.InnerEvents = {
	STORE_EVENT_SHOPLISTFIRST = "STORE_EVENT_SHOPLISTFIRST";
	STORE_EVENT_SHOPLISTFIRST_GOLD = "STORE_EVENT_SHOPLISTFIRST_GOLD";
	STORE_EVENT_SHOPLISTSECOND = "STORE_EVENT_SHOPLISTSECOND";
	STORE_EVENT_PROPLIST = "STORE_EVENT_PROPLIST";
	STORE_EVENT_GOLDPROPLIST = "STORE_EVENT_GOLDPROPLIST";
	STORE_EVENT_BUYPROP = "STORE_EVENT_BUYPROP";  --购买道具成功
	STORE_EVENT_OPENCHARGETYPE = "STORE_EVENT_OPENCHARGETYPE";  --打开支付选择
}

StoreCfg.maxCountEveryRow = 2

StoreCfg.ShopType = {
	STORE_DIAMOND = "Panel_Diamond",
	STORE_GOLD = "Panel_Gold",
	STORE_VIP = "Panel_VIP",
	STORE_PROP = "Panel_Prop",
	STORE_OTHER = "Panel_Other", --外部调用
}

--商城购买图标方式及对应约定的ID
StoreCfg.chargeIconPath = "hall/store/chargeIcon/"
StoreCfg.ShopTypeSrc = {
	{ 
		cType=13, 
		src="store_pay_type_text_alipay.png",
		srcType="store_pay_type_alipay.png", 
		Name="支付宝支付", 
	}, --支付宝
	{ 
		cType=55, 
		src="store_pay_type_text_weixin.png",
		srcType="store_pay_type_weixin.png", 
		Name="微信支付", 
	}, --微信 现在支付
	{ 
		cType=35, 
		src="store_pay_type_text_weixin.png", 
		srcType="store_pay_type_weixin.png", 
		Name="微信支付", 
	}, --微信
	{ 
		cType=27, 
		src="store_pay_type_text_apple.png",
		srcType="store_pay_type_apple.png", 
		Name="苹果支付", 
	}, --苹果
	{ 
		cType=50, 
		src="store_pay_type_text_unionpay.png",
		srcType="store_pay_type_unionpay.png", 
		Name="银联支付", 
	}, --银联
	{ 
		cType=83, 
		src="store_pay_type_text_msg.png",
		srcType="store_pay_type_msg.png", 
		Name="短信支付", 
	}, --短信
	{ 
		cType=23, 
		src="store_pay_type_text_msg.png",
		srcType="store_pay_type_msg.png", 
		Name="短信支付", 
	}, --基地短信支付
	{ 
		cType=32, 
		src="store_pay_type_text_msg.png",
		srcType="store_pay_type_msg.png", 
		Name="华为支付", 
	}, --华为sdk支付
	{ 
		cType=0, 
		src="store_pay_type_text_diamond.png",
		srcType="store_diamond_way.png", 
		Name="钻石支付", 
	}, --默认钻石支付 --默认钻石支付
}

--支付方式缓存的Key
StoreCfg.ChargeKey = "ChargeKey"
StoreCfg.ChargeGoldKey = "ChargeGoldKey"

--道具购买，数量切换提示展示时间
StoreCfg.SwitchTipTime = 10

StoreCfg.SceneID = 0  --有状态机的场景ID存储

return StoreCfg