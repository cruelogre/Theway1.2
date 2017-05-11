local prefixFlag = "COMMON_EVENT_"
local prefixFlag2 = "COMMON_TAG_"
--[[
	游戏中与场景切换相关事件的定义
--]]
cc.exports.COMMON_EVENTS = {

	--[[
		刷新个人信息区域事件
		先修改UserData信息，然后派发这个事件，只是通知有修改
	--]]
	C_REFLASH_PERSONINFO 	= prefixFlag .. "REFLASH_PERSONINFO";

	--[[
		监听事件
		从android、ios相册或者拍照获取到的图片，选择裁剪成功，通知UI线程更新
	--]]
	C_REFLASH_HEAD_NATIVE 	=  "reflashHeadIcon";  --刷新头像，head控件
	C_ONAVATARCROP 	=  "onAvatarCrop"; --裁剪成功
	C_UPLOAD_HEAD_SUCCESS 	=  "onUploadSuccess"; --上传成功
	C_UPLOAD_HEAD_FAIL 	=  "onUploadFailure"; --上传失败
    --道具物品数量更新广播，参数依次是fid和count，userdata里的数量已是最新的。
    C_GOODS_COUNT_UPDATE = prefixFlag.."C_GOODS_COUNT_UPDATE",
	C_CHANGE_NETWORK_STATE 	=  "onNetStateChange"; --改变网络连接状态
	--[[
	--	iOS隐私政策操作事件
	--]]
	G_EVENT_YSZC_SUCCESS						= "AGREE_WITH_YSZC";
	G_EVENT_YSZC_EXIT						= "AGREE_WITH_YSZC_EXIT";
	
	--[[
		公告
	--]]
	C_EVENT_NOTICE 	= prefixFlag .. "C_EVENT_NOTICE";
	--[[
		有人邀请我
	--]]
	C_EVENT_INVITE 	= prefixFlag .. "C_EVENT_INVITE";
	--[[
		游戏中的数据
	--]]
	C_EVENT_GAMEDATA = prefixFlag .. "C_EVENT_GAMEDATA";
	--[[
		用户领取破产回调
	--]]
	C_EVENT_BANKRUPT = prefixFlag .. "C_EVENT_BANKRUPT";
	--[[
		首充通知查询接口回调
	--]]
	C_EVENT_FIRSTQUERY = prefixFlag .. "C_EVENT_FIRSTQUERY";
}

-- 全局事件列表，用于lua端与C++进行事件通信的事件列表信息
cc.exports.GLOBAL_EVENTS = {
	--[[
	--	用户登陆成功事件
	--]]
	G_EVENT_LOGIN_SUCCESS						= "EVENT_LOGIN_TO_HALL_SUCCESS";


	------------------ 充值 start ----------------------
	--[[
	--	充值订单请求返回事件
	--]]
	G_EVENT_CHARGE_REQUESTORDERID				= "EVENT_CHARGE_REQUESTORDERID";
	------------------ 充值 end -----------------------
}


cc.exports.COMMON_TAG = {
	C_NETSPRITE_DOWNLOAD 	= prefixFlag2 .. "C_NET_DOWNLOAD"; --缓存下载图片key到内存中
	C_NETSPRITE_FAILED 	= prefixFlag2 .. "C_NETSPRITE_FAILED"; --缓存下载失败的图片
	
	C_RECENTSIGN_DAY = prefixFlag2 .. "C_RECENTSIGN_DAY"; --保存最近签到的日期
	
	C_CURRENT_VERSION = prefixFlag2.."C_CURRENT_VERSION"; --保存最近版本信息
	
	C_LOGIN_MESSAGE = prefixFlag2.."C_LOGIN_MESSAGE"; --保存用户登录消息
}