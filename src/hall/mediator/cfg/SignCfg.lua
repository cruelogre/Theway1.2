-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.20
-- Last: 
-- Content:  签到配置管理
--			包括常量定义 事件分发
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local SignCfg = {}
SignCfg.innerEventComponent = nil
SignCfg.InnerEvents = {
	--刷新签到日历
	SIGN_EVENT_CALENDAR = "SIGN_EVENT_CALENDAR";
	SIGN_EVENT_ISSUENOTIFY = "SIGN_EVENT_ISSUENOTIFY";
}


SignCfg.maxCountEveryRow = 7 --一行最大的数量
--月份中文
SignCfg.monthTextArr = {"1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"}

SignCfg.SignState = {
	SIGN_LAST_MONTH = 1, --上个月的
	SIGN_CHECKED = 2, --已签
	SIGN_MISS_CHECKED = 3, --漏签
	SIGN_UNCHECKED = 4, --未签 (将来的)
	SIGN_CURRENT = 5, --当前
}
SignCfg.RequestType =  {
	SIGN_REQUEST_TODAY = 1,--当天签到
	SIGN_REQUEST_COMPENSATE = 2, --补签
	SIGN_REQUEST_ROW_AWARD = 3, --连续签到
}
SignCfg.frameRate = 24 --帧率

SignCfg.assistTable = {0,5,3,1}
--Zeller公式，是一个计算星期的公式，随便给一个日期，就能用这个公式推算出是星期几
--y+[y/4]+[c/4]-2c+[26(m+1）/10]+d-1
--@param year 年
--@param m 月 m大于等于3，小于等于14，即在蔡勒公式中，某年的1、2月要看作上一年的13、14月来计算
--@param d 日
function SignCfg.getFirstDayInWeek(year,m,d)
	if m>=1 and m<=2 then
		m = m + 12
		year = year - 1
	end
	local y = year%100 --年（后两位数）
	local c = math.floor(year/100) --世纪（年份前两位数）
	local part1 = y+math.floor(y/4)+math.floor(c/4)-2*c+math.floor(26*(m+1)/10)+d-1
	local firstDayInWeek = part1%7
	return firstDayInWeek
end
return SignCfg