local dirutil = require 'pl.dir'
local pathutil = require 'pl.path'
local insert1 = [[local luaExtend = require "LuaExtend"]]
local tempNodeString = [[local tempNode = {}]]
local tempNode = [[tempNode]]
local repleaceds = {[[ScaleTimeline]],[[RotationSkewTimeline]],[[AlphaTimeline]],[[PositionTimeline]],[[FileDataTimeline]]}

if table.maxn(arg) >0 then
	for _,v in ipairs(arg) do
		print(i,v)
		if pathutil.exists(v) and pathutil.isfile(v) then
			local file1 = io.open(v, "r");
			assert(file1)
			local data = file1:read("*a"); -- 读取所有内容
			file1:close()
			print(type(data))
			if type(data)=="string" then
				--local luaExtend = require "LuaExtend"
				
				
				local index = string.find(data,insert1)
				
				if index then
					local x1 = string.len(insert1)+index
					data = string.gsub(data,insert1,insert1..'\n'..tempNodeString..'\n')
					--print(string.sub(data,index,index+100))
					for _,repleaced in ipairs(repleaceds) do
						 local index2 = string.find(data,repleaced)
						if index2 then
							data = string.gsub(data,repleaced,tempNode..'.'..repleaced)
							data = string.gsub(data,'local '..tempNode..'.'..repleaced,tempNode..'.'..repleaced)
							print("处理节点"..repleaced.."完成")
						end
					end
				end
				print(index)
				file = io.open(v, "w");
				assert(file)
				file:write(data)
				file:close()
				print("文件修改成功",v)
			end
		else
			print("输入的文件不存在",v)
		end
	end
else
	print("输入的文件不能为空！")
end

