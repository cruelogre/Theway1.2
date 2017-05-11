
-- 0 - disable debug info,  关掉日志
-- 1 - less debug info,  追踪日志 PopupError uploadError
-- 2 - verbose debug info   wwlog  
-- 3 - wwdump
DEBUG = 3

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = true

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = true

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 1920,
    height = 1080,
    autoscale = "FIXED_WIDTH",
    callback = function(framesize)
		-- local ratio = framesize.width / framesize.height
		local retScale = {autoscale = "FIXED_WIDTH"} 
   --      if ratio <= 1.34 then
   --          -- iPad 768*1024(1536*2048) is 4:3 screen
			-- retScale = {autoscale = "FIXED_WIDTH"} 
   --      end
		
		if cc.FileUtils:getInstance():isFileExist("resConfig.lua") 
			or cc.FileUtils:getInstance():isFileExist("resConfig.luac") then 
			local ressolution = require "resConfig"
			--adaptation
				--local ressolution = CC_RESOLUTION_RATIO.resType[CC_RESOLUTION_RATIO.gameResType]
				dump(ressolution)
				if ressolution.width and CC_DESIGN_RESOLUTION.width and retScale.autoscale=="FIXED_WIDTH" then
				cc.Director:getInstance():setContentScaleFactor(ressolution.width/CC_DESIGN_RESOLUTION.width)
				elseif ressolution.height and CC_DESIGN_RESOLUTION.height and retScale.autoscale=="FIXED_HEIGHT" then
				cc.Director:getInstance():setContentScaleFactor(ressolution.height/CC_DESIGN_RESOLUTION.height)
				end
				
			
			
		end
		
        
		if retScale then
			return retScale
		end
    end
}

-- 脚本Log处理配置
_logConfigParam = {
    username = 'diyal',
    httpPost = 'POST',
    UploadCacheNum = 5,         -- 缓存错误Log个数（近N次有提交过则不再提交）
    logServerAdress = 'http://192.168.10.204:8080/xGame/LogUpload.action',
    -----------------------------------------------------------------------
    writeLog = true,              --写log文件
    UploadLog = true,             -- 上传Log
    dialogLog = true,             --客户端提示出错信息
    OpenWWdump = true,            --wwdump 写日志性能较低，配置关闭，DEBUG 为1以下自动不显示
    logfileName = 'wawagame.log', --文件在可写目录
    playCardLogfileName = 'wawagameplay.log', --文件在可写目录
    logfileSize = 1024 * 20,      --log文件大小
    -----------------------------------------------------------------------
}