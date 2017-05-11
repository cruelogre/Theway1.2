local RoomChatCfg = {}

RoomChatCfg.innerEventComponent = nil
RoomChatCfg.InnerEvents = {
	RMCHAT_EVENT_RECIEVED_DATA = "RMCHAT_EVENT_RECIEVED_DATA", --聊天内容返回
	RMCHAT_EVENT_CLOSEUI = "RMCHAT_EVENT_CLOSEUI", --关闭房间聊天UI
}

RoomChatCfg.facialMaxCount = 4 --表情动画每行最大的数量
RoomChatCfg.characterMaxCount = 30 --输入文字最大的输入长度
RoomChatCfg.characterBubbleMaxLen = 30 --气泡动画文字的最大长度

RoomChatCfg.characterDiffTime = 5 --文字动画连续最大间隔时间
RoomChatCfg.characterSer = 3 --文字动画连续最大次数
RoomChatCfg.facialDiffTime = 5 --表情动画连续最大间隔时间
RoomChatCfg.facialSer = 3 --表情动画连续最大次数
--动画类型
RoomChatCfg.animatorType = {
	Facial = 1, --表情
	Character = 2, --文字
}
--动画播放状态
RoomChatCfg.animatorState = {
	Init = 1, --初始化状态
	Playing = 2, --播放状态
	Stoped = 3, --停止状态
}
return RoomChatCfg