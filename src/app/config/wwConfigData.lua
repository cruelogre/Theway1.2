local targetPlatform = cc.Application:getInstance():getTargetPlatform()

cc.exports.wwConfigData = {
    --CLIENTNAME = "小新掼蛋";
    USER_TYPE = 1;
    GAME_LANGUAGE = 1;
    USER_SEX = 1;
    GAME_REGION = 1;
   -- OP = 11;
  --  SP = 6600;-- 6666 6000
	GAME_MODEL = function ()
		if (cc.PLATFORM_OS_IPHONE == targetPlatform) 
		or ((cc.PLATFORM_OS_IPAD == targetPlatform))
		or ((cc.PLATFORM_OS_MAC == targetPlatform)) then
			return "IPHONE"
		else
			return "ADVGA"
		end
	
	end,
    GAMELOGICPARA = {
        GUANDAN = {GAME_ID = 1017}, --掼蛋
        BULLFIGHT = {GAME_ID = 1019, PLAYTYPE=8}, --斗牛 随机庄家玩法
    };

   -- GAME_MODEL = "ADVGA";
    GAME_REGION = 1;
    GAME_MODULE_ID = 1017;
	SYSTEM_USERID = 1001, --系统蛙号 用在反馈里边
    GAME_ID = 1017;
	GAME_HALL_ID = 3041313;
	--CATEGORY_ID = "guandan"; --帮助信息分类ID
	GAME_VERSION = "1.2.0"; --客户端当前大版本
	GAME_SUBVERSION = 9, --客户端当前小版本号
    REQUEST_IPS = {
        -- "183.62.101.251", --外网地址  对应52
      --  "183.62.101.250", --外网地址  对应53
        "192.168.10.53",
        -- "192.168.10.52",
--[[		"139.199.12.79",
		"139.199.170.173",
		"139.199.161.200",
		"123.207.17.238",--]]
        -- "183.62.101.249",
--[[		"120.132.183.18",	
        "cmnet.wawagame.cn"--]]
    };
    REQUEST_PORTS = {
        5310,80,29999,65310
    };
    -- NEW_SOCKET_URL = "http://gs.wawagame.cn:5320/handler/requestAddress";
    NEW_SOCKET_URL = "",
    HTTP_IP = "192.168.10.91";-- 获取条款的IP api.wawagame.cn    192.168.10.93
                              -- 充值
    CHARGE_FIRST_MENUID_GOLD = 26;-- 金币
    CHARGE_FIRST_MENUID_DIAMOND = 27;-- 钻石
	CHARGE_FIRST_MENUID_FIRSTCHARGE = 0; --首充
    CHARGE_BANKID_GOLD = 1017;-- 金币BankID
    CHARGE_BANKID_GOLD_BULLFIGHT = 1019;-- 斗牛 BankID
    CHARGE_BANKID_DIAMOND = 9203;-- 钻石BankID
    CHARGE_STORE_GOLD = 1025;-- 钻石兑换金币StoreID
    CHARGE_STORE_PROP = 1026;-- 钻石兑换物品StoreID
    CHARGE_STORE_PROP_GAME = 1027;-- 游戏中购买道具，包含直接使用，单个
    AUTO_CONTINUE_GAME = false;-- 自动续局

    LUA_GAMEID = 2000;-- 热更中的lua 脚本模块
    LUA_HOTUPDATE = 9999;-- 热更模块定义  热更所有文件 差分
    LUA_WHOLE_PACKAGE = 10000;-- 整包更新定义
                              -- 定义的module名字
    SCENE_ID =
    {
        -- 大厅场景ID
        HALL = 110,
        GAME = 210,
    };
    CHARGE_STATUE_DEFAULT = 999999;-- 计费统计上报Default，代表无效意义,通用于所有游戏
    CHARGE_STATUE_GOLD_END = "002";-- 计费统计上报默认后缀 金币
    CHARGE_STATUE_DIAMOND_END = "001";-- 计费统计上报默认后缀 钻石
    FIRSTCHARGEFID = 20020006;  -- 首充FID
}

-- URL配置
cc.exports.wwURLConfig =
{
    -- live800
    LIVE800_URL = "http://api.wawagame.cn:9565/help/client.jsp?pingtai=WW&lang=1&ui=live800";
    -- 平台URL
    PLATFORM_URL_TEST = "http://192.168.10.91:8585/gamesrc/getsrc.jsp";
    PLATFORM_URL = "http://dl.wawagame.cn:8585/gamesrc/getsrc.jsp";

    -- 上传头像
    PLATFORM_UPLOAD_URL_TEST = "http://192.168.10.91:9565/upload/upload_icon.jsp";
    PLATFORM_UPLOAD_URL = "http://api.wawagame.cn:9565/upload/upload_icon.jsp";

    -- 下载头像
    PLATFORM_DOWNLOAD_URL_TEST = "http://192.168.10.91:8585/gamesrc/getsrc.jsp";
    PLATFORM_DOWNLOAD_URL = "http://dl.wawagame.cn:8585/gamesrc/getsrc.jsp";

    -- 百度定位API
    PLATFORM_BAIDULOCATION_URL = "http://api.map.baidu.com/location/ip";
    LOCATION_AK = "ws692plZhue7jWzeVnC4CqRXENLa3Bhx";-- android
    LOCATION_AK_IOS = "bhPlvMNqFkMrbsG8ovTsfMlK4ROwcKcL";-- ios
    LOCATION_MCODE_PART1 = "67:87:12:08:10:DA:FE:5F:A4:87:25:1F:C7:65:4E:DE:AB:C7:0C:4C";
    LOCATION_MCODE_PART2 = "com.wawagame.xxguandan";

    -- 分享下载中心
    SHARE_DOWNLOAD_URL = "http://guandan.wawagame.cn";
    --私人房分享地址
    SHARE_SIREN_DOWNLOAD_URL = "http://weix.wawagame.cn/activity/gdshare";


    LUA_HOTUPDATE_URL_TEST = "http://192.168.10.91:9565/common/luapatchapi.jsp";

    LUA_HOTUPDATE_URL = "http://api.wawagame.cn:9565/common/luapatchapi.jsp";
	
	--win32 下整包更新的地址
	LUA_PACKAGE_WIN_URL ="http://192.168.11.200/svn/Columbus/WWLocal_Codes/Trunk/Theway/simulator/win32";
	LUA_PACKAGE_ANDROID_URL ="http://guandan.wawagame.cn/";
	
	--活动地址
	ACTIVITY_URL_TEST = "http://192.168.10.91:8587/reg/login.do";
	ACTIVITY_URL = "http://atvt.wawagame.cn:8587/reg/login.do";
}