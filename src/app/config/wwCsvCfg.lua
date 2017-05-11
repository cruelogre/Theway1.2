-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  --读取csv配置
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local function split(str, reps)  
	local resultStrsList = {} 
	string.gsub(str, '[^' .. reps ..']+', function(w) table.insert(resultStrsList, w) end )
	return resultStrsList; 
end 
	
--预先需要解析的配置表
local csvConfig = {
    'config/gameDubbed.csv',
    'config/StatisticalReport.csv',
    'config/umengEvent.csv',
}

local wwCsvCfg = class("wwCsvCfg")
function wwCsvCfg:ctor( ... )
	-- body
	self.csvTable = {}

	--解析
	self:loadCsvCfg()
end


function wwCsvCfg:loadCsvCfg()
    --body
    local function split(str, reps)  
        local resultStrsList = {} 
        string.gsub(str, '[^' .. reps ..']+', function(w) table.insert(resultStrsList, w) end )
        return resultStrsList; 
    end 

    for k,v in pairs(csvConfig) do
		self:loadCsvCfgByName(v)
    end
end

function wwCsvCfg:loadCsvCfgByName(fileName)
    --body
	if self.csvTable.fileName then
		return self.csvTable.fileName
	end
	
    if  cc.FileUtils:getInstance():isFileExist(fileName) and string.sub(fileName,-4,-1) == '.csv' then --存在 且以csv结尾
        local data = cc.FileUtils:getInstance():getStringFromFile(fileName)
        -- 按行划分  
        local lineStr = split(data, '\n\r')
        -- 从第3行开始保存（第一行是注释，第二行是标题，后面的行才是内容）   
        -- 用二维数组保存：arr[ID][属性标题字符串]  
        local titles = split(lineStr[2], ",")
        local arrs = {}  
        for i = 3, #lineStr, 1 do  
            -- 一行中，每一列的内容  
            local content = split(lineStr[i], ",") 
            -- 以标题作为索引，保存每一列的内容，取值的时候这样取：arrs[1].Title  
            arrs[content[1]] = {} 
            for j = 2, #content, 1 do  
                 arrs[content[1]][titles[j]] = content[j] 
            end  
        end
        local keyName = string.sub(fileName,8,-5)
        self.csvTable[keyName] = arrs
        return arrs
    end
end


cc.exports.wwCsvCfg = cc.exports.wwCsvCfg or wwCsvCfg:create()
return cc.exports.wwCsvCfg
