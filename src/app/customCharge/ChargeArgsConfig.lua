local ChargeArgsConfig = { }

ChargeArgsConfig["BasicConfig"] =
{
	sdk_charge_tag = "53", --第三方sdk标示
}

--充值类型
ChargeArgsConfig["EChargeType"] = 
{
    FLAG_WAP 					= 2,		--wap类
    FLAG_CHARGE_CARD 			= 3,		--充值卡类充值
    FLAG_HK_THREE 				= 4,		--HK
    FLAG_WAP_BROWER 			= 5,		--内置浏览器
    FLAG_CMCC 					= 777,		--移动网游平台点数接口
    FLAG_OTHER 					= 8,		--移动网游平台点数接口
    FLAG_CMCC2 					= 9,		--移动网游平台点数接口
    FLAG_QUERY 					= 1700,		--内置的金币查询
    FLAG_SMS 					= 11,		--短信类充值
    FLAG_Google 				= 19,		--Google充值
    FLAG_OTHER_SDK 				= 12,		--第三方充值
    FLAG_SMSII 					= 21,		--短信II类充值
    FLAG_ALIPAY 				= 13,		--支付宝充值
    FLAG_MMIAP 					= 14,		--MM充值
    FLAG_CTSMS 					= 15,		--电信爱游戏充值
    FLAG_LTSMS 					= 16,		--联通充值
    FLAG_LTLINK					= 17,		--?
    FLAG_CTSHOP					= 18,		--电信天翼空间充值
    FLAG_LTWSMS					= 29,		--联通沃短信
    FLAG_DUOKU_YD_CARD			= 61,		--多酷移动卡充值
    FLAG_DUOKU_LT_CARD			= 62,		--多酷联通卡充值
    FLAG_DUOKU_DX_CARD			= 63,		--多酷电信卡充值
    FLAG_FB_SDK					= 1800,		--FaceBook
    FLAG_WX						= 35,		--微信
    FLAG_MY_CARD_IN_GAME		= 422,		--MyCard In game
    FLAG_MY_CARD_BILLING		= 423,		--MyCard Billing
    FLAG_MY_CARD_POINT			= 424,		--MyCard Point
    FLAG_APP_STORE				= 27,		--AppStore
    FLAG_YD_GD					= 23,		-- 移动基地SDK
    FLAG_EGAME					= 36, 		-- 电信爱游戏SDK
    FLAG_SKYSDK                 = 26,       --斯凯充值
    FLAG_HUAWEI                 = 32,       --充值类型是华为
    FLAG_XUNXIAO                = 44,       --迅销sdk
    Flag_TENPAY                 = 48,       --QQ钱包，财付通
    FLAG_SIKAI                  = 24,       --裸短，斯凯的一种类型
    FLAG_UNIONPAY               = 50,       --银联sdk充值
    FLAG_CHANGBA                = 51,       --唱吧sdk充值
    FLAG_AIBEI                  = 52,       --爱贝sdk充值
    FLAG_QIANBAO                = 53,       --钱宝sdk充值
    FLAG_MEIZU                  = 54,       --魅族sdk充值
    FLAG_IPAYNOW                = 55,       --现在支付sdk
    FLAG_SMSYZM                 = 56,       --带验证码的短信类
    FLAG_QIANBAOSDK             = 59,       --钱宝sdk充值
    FLAG_ALIPAY_FREE            = 65,       --支付宝免密sdk的充值类型
    FLAG_LHTB                   = 66,       --联通汇宝理财sdk
    FLAG_PAPASDK                = 67,       --啪啪sdk充值
    FLAG_XIAOMIWEIXIN           = 68, 		--小米微信sdk
    FLAG_LITIAN                 = 69,       --力天sdk
    FLAG_IQIYI                  = 71,       --爱奇艺sdk
    FLAG_ZHUOYI                 = 72,       --卓易sdk
    FLAG_ZHUOYI_WX              = 73,       --卓易sdk微信
    FLAG_LIANXIANGAPI           = 74,       --联想api
    FLAG_ZHUOYI_ZFB             = 75,       --卓易sdk支付宝
    FLAG_SMS_NEW                = 76,       --新的短信类型
    FLAG_NUBIA                  = 78,       --努比亚sdk
    FLAG_SANXING                = 79,       --三星sdk
    FLAG_KUGOUWY                = 80,       --酷狗网游sdk
    FLAG_ALISDK                 = 81,       --阿里sdk
    FLAG_SMSDATA                = 83,       --数据短信
}

--OrderType
ChargeArgsConfig["EPayOrderType"] = 
{
    eOrderTypeUnknow			= -1,
    eOrderTypeAppStore			= 39,   -- appStore商店
    eOrderTypeAliPay			= 5,    -- 支付宝
    eOrderTypeChinaMobile		= 23,   -- 移动短信充值请求短信充值指令（短信充值(含订单号)指令,订单ID）.
    eOrderTypeChinaMobileSDK	= 27,	-- 移动SDK充值订单号
    eOrderTypeNetDrogen			= 43,   -- 91SDK获取订单号
    eOrderTypeAisi				= 46,   -- 爱思SDK请求订单号
    eOrderTypeWinxin			= 47,   -- 微信SDK请求订单号
    eOrderTypeChinaUnicom		= 48,   -- 联通沃商店
    eOrderTypeMM				= 15,   -- MM
    eOrderTypeCTSMS				= 8,    -- 电信爱游戏充值
    eOrderTypeLTSMS				= 11,   -- 联通短信充值
    eOrderTypeCTSHOP			= 22,   -- 电信天翼空间充值
    eOrderTypeGoogle			= 0,    -- 谷歌
	eOrderTypeYD_GD				= 27,	-- 移动基地
	eOrderTypeEGame				= 51,	-- 电信爱游戏SDK
	eOrderTypeMO9               = 54,   -- mo9计费
	eOrderTypeThrid             = 50,   --第三方充值类型，订单号为50的
	eOrderTypeSky               = 37,   --斯凯sdk请求订单号
	eOrderType3G                = 17,   --3Gsdk请求订单号
	eOrderTypeHuaWei            = 42,   --华为sdk请求订单号
	eOrderTypeBuBuGao           = 53,   --步步高请求订单号
	eOrderTypeOppo              = 35,   --oppo请求订单号
	eOrderTypeLxsdk             = 36,   --联想网游请求订单号
	eOrderTypeXunXiao           = 55,   --迅销请求订单号
	eOrderTypeTENPAY            = 56,   --财付通请求订单号
	eOrderTypeUnionPay          = 57,   --银联请求订单号
	eOrderTypeChangBa           = 58,   --唱吧请求订单号
	eOrderTypeAiBei             = 59,   --爱贝请求订单号
	eOrderTypeQianBao           = 60,   --钱宝请求订单号
	eOrderTypeMeiZu             = 61,   --魅族请求订单号
	eOrderTypeIpayNow           = 62,   --现在支付请求订单号
	eOrderTypeSmsYZM            = 63,   --带验证码请求订单号
	eOrderTypeQianBaoSdk        = 64,   --钱宝sdk请求订单号
	eOrderTypeAlipayFree        = 67,   --支付宝免密请求订单号
	eOrderTypeLhtb              = 65,   --联汇通宝sdk请求订单号
	eOrderTypePaPasdk           = 66,   --啪啪sdk请求订单号
	eOrderTypeXiaoMiWeiXin      = 68,   --小米微信sdk请求订单号
	eOrderTypeLiTian            = 69,   --力天sdk请求订单号
	eOrderTypeIQiYi             = 70,   --爱奇艺sdk请求订单号
	eOrderTypeZhuoYi            = 71,   --卓易sdk请求订单号
	eOrderTypeZhuoYiWX          = 72,   --卓易sdk微信请求订单号
    eOrderTypeZhuoYiZFB         = 74,   --卓易sdk支付宝请求订单号
	eOrderTypeLianXiangApi      = 73,   --联想api请求订单号
	eOrderTypeSmsNew            = 75,   --新的短信类型请求订单号
	eOrderTypeNubia             = 76,   --努比亚sdk请求订单号
	eOrderTypeSanXing           = 77,   --三星请求订单号
	eOrderTypeKuGouWy           = 78,   --酷狗网游sdk请求订单号
	eOrderTypeALiSdk            = 79,   --阿里sdk请求订单号
    eOrderTypeSmsData           = 81,   --数据短信请求订单号   
}

return ChargeArgsConfig