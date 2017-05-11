-------------------------------------------------------------------------
-- Desc:    BaseCore
-- Author:  diyal.yin
-- Date:    2015.10.22
-- Last:    
-- Content:  文字国际化
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local i18nUtils = class("i18nUtils")

cc.exports.i18n = i18nUtils or i18nUtils:create() --加到全局表中

--[[
加载文件
@param filename 国际化文件名
@parame lang 语言版本
]]--
function i18nUtils:load(filename, lang)

    --加载国际化文件
	local languageLuaFile = string.format("%s_%s",filename, lang)
	cclog(languageLuaFile)

    --有保护的加载i18n文件
	local ret, languageString = pcall(require,languageLuaFile)
	if ret == false then
		flog('[WaWaLog]/error', 'load string file failed, not default string file exist')
	end

	self.stringTables = languageString

	-- dump(self.stringTables)
end

function i18nUtils:get(module, key)

	if (type(module) ~= 'string') or (type(key) ~= 'string') then
		flog('[WaWaLog]/error', 'params must been string type')
		return
	end

	local returnStr

	--到相应的模块查找相应的Key
	local moduleTable = self.stringTables[module]
	if nil == moduleTable then
		returnStr = ''
	end

	local value = moduleTable[key]
	if nil == value then
		returnStr = ''
	else
		returnStr = value
	end

	return returnStr
end