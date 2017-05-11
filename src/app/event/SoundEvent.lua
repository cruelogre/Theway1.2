local prefixFlag = "SOUND_EVENT_"

--[[
	游戏中与声音、音效、静音相关的事件定义
--]]
cc.exports.SOUND_EVENTS = {
	-- dispatch by user
	--[[
		播放背景音乐
		@param1[必填] - audioId 参见SoundRegistry.lua中的关联数组
		@param2[选填] - loop 默认为false
	--]]
	PLAY_BACKGROUND 			= prefixFlag .. "PlayBackground";

	--[[
		暂停背景音乐播放
		@param1[必填] - audioId 参见SoundRegistry.lua中的关联数组
	--]]
	PAUSE_BACKGROUND			= prefixFlag .. "PauseBackground";

	--[[
		恢复背景音乐播放
		@param1[必填] - audioId 参见SoundRegistry.lua中的关联数组
	--]]
	RESUME_BACKGROUND			= prefixFlag .. "ResumeBackground";

	--[[
		停止背景音乐播放
		@param1[必填] - audioId 参见SoundRegistry.lua中的关联数组
	--]]
	STOP_BACKGROUND				= prefixFlag .. "StopBackground";

	--[[
		播放音效
		@param1[必填] - audioId 参见SoundRegistry.lua中的关联数组
		@param2[选填] - loop 默认为false
	--]]
	PLAY_EFFECT					= prefixFlag .. "PlayEffect";

	--[[
		暂停音效播放
		@param1[必填] - audioId 参见SoundRegistry.lua中的关联数组
	--]]
	PAUSE_EFFECT				= prefixFlag .. "PauseEffect";

	--[[
		恢复音效播放
		@param1[必填] - audioId 参见SoundRegistry.lua中的关联数组
	--]]
	RESUME_EFFECT				= prefixFlag .. "ResumeEffect";

	--[[
		停止音效播放
		@param1[必填] - audioId 参见SoundRegistry.lua中的关联数组
	--]]
	STOP_EFFECT					= prefixFlag .. "StopEffect";

	--[[
		改变当前背景音乐音量
		@param1[必填] - 取值范围[0.0 - 1.0]
	--]]
	CHANGE_BACKGROUND_VOLUME 	= prefixFlag .. "ChangeBackgroundVolume";

	--[[
		改变当前音效音量
		@param1[必填] - 取值范围[0.0 - 1.0]
	--]]
	CHANGE_EFFECT_VOLUME		= prefixFlag .. "ChangeEffectVolume";

	--[[
		改变当前静音状态
		@param1[选填] -- 如果不传递此参数，默认开启静音 
	--]]
	CHANGE_SILENCE				= prefixFlag .. "ChangeSilence";


	-- dispatch by SoundProxy(用户不要派发下列消息)
	--[[
		背景音乐音量改变事件，
		@result1 - event._userdata[1]为当前的背景音乐音量值，取值范围[0.0 - 1.0]
	--]]
	BACKGROUND_VOLUME_CHANGED	= prefixFlag .. "BackgroundVolumeChanged";

	--[[
		音效音量改变事件
		@result1 - event._userdata[1]为当前的音量值，取值范围[0.0 - 1.0]
	--]]
	EFFECT_VOLUME_CHANGED		= prefixFlag .. "EffectVolumeChanged";

	--[[
		静音状态改变事件
		@result1 - event._userdata[1]为当前静音状态,boolean
	--]]
	SILENCE_CHANGED				= prefixFlag .. "Silence_Changed";
}