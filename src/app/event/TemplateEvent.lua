-- 模块事件列表定义模板


-- 1、定义一个具体模块的事件名称前缀
-- 如Login模块的事件名前缀可以是LOGIN_EVENT_
local prefixTAG = "TEMPLATE_EVENT_"

--2、定义模块的事件列表
cc.exports.TEMPLATE_EVENTS = {
	-- 定义具体的事件
	ENTRY 			= prefixTAG .. "Entry";
	SOME_EVENT 		= prefixTAG .. "SomeEvent";
}

 -- 3、要使用此事件列表的模块只要在使用之前导入即可
 -- <code>
 -- 	import(".TemplateEvent", "app.event.")
 -- </code>