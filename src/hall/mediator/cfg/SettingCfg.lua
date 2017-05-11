-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.20
-- Last: 
-- Content:  设置配置管理
--			包括常量定义 事件分发
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local SettingCfg = {}
SettingCfg.innerEventComponent = nil
--设置中的UI事件
SettingCfg.InnerEvents = {
	SETTING_EVENT_FAQ = "setting_event_faq"; --常见问题数据返回
	SETTING_EVENT_GUANDAN = "setting_event_guandan"; -- 惯蛋数据返回
	SETTING_EVENT_FEEDBACK = "setting_event_feedback"; --反馈
	SETTING_EVENT_PRIVICY = "setting_event_privicy"; -- 隐私政策
	SETTING_EVENT_PROTOCOL = "setting_event_protocol"; -- 服务协议
}
--设置中的常量 本地存储数据的key
SettingCfg.ConstData = {
	SETTING_MUSIC_PERCENT = "setting_music_percent";
	SETTING_SOUND_PERCENT = "setting_sound_percent";
	SETTING_SHAKE_SWITCH = "setting_shake_switch";
	SETTING_SOUNDCARD_SWITCH = "setting_soundcard_switch";
	
	
}
-- 设置中的http 请求的cid
SettingCfg.cids = {
	{5,SettingCfg.InnerEvents.SETTING_EVENT_PRIVICY}, --隐私政策配置
	{8,SettingCfg.InnerEvents.SETTING_EVENT_PROTOCOL}, --服务协议配置
	
	{2,SettingCfg.InnerEvents.SETTING_EVENT_FAQ}, --常见问题配置
	{1,SettingCfg.InnerEvents.SETTING_EVENT_GUANDAN}, --惯蛋配置
}
--设置中的按钮映射
SettingCfg.btnMap = {
	Button_play = {
		umCount = "SetGamePlay",
		layer = "hall.mediator.view.SettingLayer_PlayMode",
	},
	Button_question = {
		umCount = "SetQA",
		layer = "hall.mediator.view.SettingLayer_FeedBack",
	},
	Button_about = {
		umCount = "SetAbout",
		layer = "hall.mediator.view.SettingLayer_About",
	},
}
SettingCfg.openUI = {
	"Button_play","Button_question","Button_about",
}
SettingCfg.maxContentLength = 100 --反馈中文字的最大长度
--通过cid 获取事件的名字
function SettingCfg.getEventByCid(cid)
	local eventName = nil
	for _,v in pairs(SettingCfg.cids) do
		if v[1]==cid then
			eventName = v[2]
			break
		end
	end
	return eventName
end

return SettingCfg