require('LuaXml')
require('stringTest')
local dirutil = require 'pl.dir'
local pathutil = require 'pl.path'
--local path = "eff_bonus_1"
function parseFile(path,fname)
print("parse file:"..path..".xml")
-- load XML data from file "test.xml" into local table xfile
local xfile = xml.load(string.format("%s.xml",path))
-- search for substatement having the tag "scene"
local root = xfile:find("root")
-- if this substatement is found
local plists = root[1]
local animations = root[2]
if root ~= nil then
  --  print it to screen
 -- print(root)

  --  print  tag, attribute id and first substatement
end
storeTable = {}
if plists~=nil then
	local pt = {}
	
	local len = table.maxn(plists)
	
	for i=1,len do
		local p = plists[i]
		
		table.insert(pt,p[1])
	end
	storeTable["plists"] = pt
	--table.insert(storeTable,"plists",pt)
end

if animations~=nil then
	local animsT = {}
	local animsLen = table.maxn(animations)
	for j=1,animsLen do
		local anim = animations[j]
		local animT = {}
		local animLen = table.maxn(anim)
		for jj=1,animLen do
			local gotkey = false
			for key,value in pairs(animT) do
				if key==anim[jj][0] then
					gotkey = true
				end
			end
			if gotkey then
				
				if type(animT[anim[jj][0]])=="string" then
					
					local tempTable = {animT[anim[jj][0]],anim[jj][1]}
					animT[anim[jj][0]] = tempTable
				else
					table.insert(animT[anim[jj][0]],anim[jj][1])
				end
			else
				animT[anim[jj][0]] = anim[jj][1]
			end
			
		end
		
		
		table.insert(animsT,animT)
	end
	storeTable["animations"] = animsT
end


function writePlist(t,file,plists)
	file:write("\tplists={\n") 
	local len  = table.maxn(plists)
	for key,value in ipairs(plists) do
		file:write("\t\t")
		file:write("\"")
		file:write(value)
		file:write("\"")
		if key~=len then
			file:write(",\n")
		end
	end
	file:write("\t")
	file:write("\n\t};")
end
function writeAnimations(t,file,animations)
	file:write("\n\tanimations={\n")
	local len  = table.maxn(animations)
	for key,value in ipairs(animations) do
		file:write("\t{\n")
		for k1,v1 in pairs(value) do
			file:write("\t\t")
			file:write(k1)
			file:write("=")
			if type(v1)=="string" then
				file:write("\"")
				file:write(v1)
				file:write("\"")
				file:write(";\n")
			elseif type(v1)=="table" then
				file:write("{\n\t\t\t")
				local v1len = table.maxn(v1)
				for k2,v2 in ipairs(v1) do
					file:write("\"")
					file:write(v2)
					file:write("\"")
					if k2~=v1len then
						file:write(",\n\t\t\t")
					end
				end
				file:write("\n\t\t\t};\n")
			end
			
		end
		file:write("\n\t}")
		if len~=key then
		file:write(",\n")
		end
		file:write("\n\t}")
	end
end
function wirteTable(t,file)
	file:write("local ")
	file:write(fname)
	file:write("={\n")
	for key,value in pairs(t) do
		if key=="plists" then
			writePlist(t,file,value)
		elseif key=="animations" then
			writeAnimations(t,file,value)
		end
		
		
	end
	file:write("\n}\n")
	file:write("return ")
	file:write(fname)
	
end
local file = io.open(string.format("%s.lua",path),"w")
wirteTable(storeTable,file)
file:close()
print(string.format("write lua table file:%s.lua",path))
end
--parseFile(path)

function iteratePath(path)
	print("parse directory"..path)
	for root,dirs,files in dirutil.walk(path) do
		if dirs~=nil and table.maxn(dirs) >=0 then
			for i,v in ipairs(dirs) do
				iteratePath(root.."\\"..v)
			end
		end
		for i,v in ipairs(files) do
			if string.find(v,".xml")~=nil then
				local p = string.sub(v,0,string.len(v)-4)
				parseFile(root.."\\"..p,p)
			end
			
		end
	end
end
if table.maxn(arg) >0 then
	for i,v in ipairs(arg) do
	
		if pathutil.exists(v) then
		
			if pathutil.isfile(v) and string.find(v,".xml")~=nil then
				local p = string.sub(v,0,string.len(v)-4)
			
				parseFile(p,rsubStringBack(p,"\\"))
			elseif pathutil.isdir(v) then
				iteratePath(v)
			end
		else
			print("file or directory not valid:"..v)
		end
	end
else
	print("file or directory empty!")
end


print("---\nREADY.")