cc.exports.FSConst = {
	
	
}
--过滤类型
FSConst.FilterType = {
	Filter_Enter = math.pow(2,0), --进入
	Filter_Resume = math.pow(2,1), --重新可见
	Filter_Pause = math.pow(2,2), --被其他状态机覆盖
	Filter_Exit = math.pow(2,3), -- 退出
}