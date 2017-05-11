local path = require 'pl.path'
local dir = require 'pl.dir'
for root,dirs,files in dir.walk("E:\\TestWork\\LuaXml\\pl") do
	print(root)
	for i,f in ipairs(files) do
		print(f)
	end
end