local prefixFlag = "HALL_SCENE_EVENT_"

cc.exports.HALL_SCENE_EVENTS = {
	MAIN_ENTRY 			= prefixFlag .. "mainEntry";
	NETEVENT_RECMYINFO 			= prefixFlag .. "RECMYINFO"; --收到个人信息消息回调组件
	NETEVENT_RECHALLLIST 		=  prefixFlag.. "RECHALLLIST"; --收到大厅列表房间人数
	NETEVENT_NOTICE 		=  prefixFlag.. "NETEVENT_NOTICE"; --收到大厅公告弹出通知
	NETEVENT_ADVERTRET 		=  prefixFlag.. "NETEVENT_ADVERTRET"; --收到大厅公告弹出通知
}

cc.exports.HALL_ENTERINTENT = {
	ENTER_NETWORK_ERROR = 1, --登录的时候没有网络
	ENTER_LOGINING = 2, --登录的时候正在获取数据
}