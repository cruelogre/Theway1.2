import os
import os.path
import time
import shutil
import os
import re
import sys
import string
import ConfigParser
import threading

config = ConfigParser.ConfigParser()
config.read("ddzAuto.conf")

def del_file(path): 
    filelist=[]
    rootdir=path
    filelist=os.listdir(rootdir)
    for f in filelist:
        filepath = os.path.join( rootdir, f )
        if os.path.isfile(filepath):
            os.remove(filepath)
            print filepath+" removed!"
        elif os.path.isdir(filepath):
            shutil.rmtree(filepath,True)
            print "dir "+filepath+" removed!"

def copy_file(src,dst): 
    for file in os.listdir(src):
        src_path = os.path.join(src,file)
        dst_path = os.path.join(dst,file)
        
        if os.path.isfile(src_path):
            if not os.path.exists(dst):
                os.makedirs(dst)
            
            if not os.path.exists(dst_path):
                    shutil.copy(src_path,dst_path)
        
        if os.path.isdir(src_path):
            copy_file(src_path,dst_path);  

def copy_file_handler():
    if copyDebugWin32:
        del_file(targetPath)
        copy_file(resCopyPath, targetPath)
        print("==> Tips: Fuck to copy debugwin32 success!")

def build():

    resCopyPath = config.get("SystemResolution", "runDebugWin32exePath")

    command = resCopyPath
    if os.system(command) != 0:
        raise Exception("Run project fail [ " + resCopyPath + " ] Please check the exe exist! This tool is just for script dev,and must build the exe in win32")  

def XXTEA():

    # command = "cocos luacompile -s ./projects/MyLuaGame/src -d ./projects/MyLuaGame/src -e -k DiyalLuaKey -b MyLuaSign"
    sourceSrc = resCopyPath + "\src"
    targatSrc = _targetScrPath + "\src"

    command = "cocos luacompile -s " + sourceSrc + " -d " + targatSrc + " -e -k " + _xxteaKey + " -b " + _xxteaSign
    print(command)
    if os.system(command) != 0:
        raise Exception("Compile src xxtea success, Now debugwin32 script src is xxtea file")  

#by Jackie刘龙
def createLuaClass(className,dir):
	targetPath = os.path.join(dir,className + '.lua')
	print targetPath
	if not os.path.exists(targetPath):
		lua = []
		lua.append("-----------------------------------------------------------\n")
		lua.append("-- Desc:     " + className + "\n")
		lua.append("-- Author:   Jackie刘龙\n")
		lua.append("-- Date:  	 " + time.strftime( '%Y-%m-%d %H:%M:%S', time.localtime() ) + "\n")
		lua.append("-- Last: 	 \n")
		lua.append("-- Content:  \n")
		lua.append("-- Copyright (c) wawagame Entertainment All right reserved.\n")
		lua.append("---------------------------------------------------------\n\n")
		
		lua.append("local *------* = class(\"*------*\",function()\n")
		lua.append("\treturn \n")
		lua.append("end)\n\n")
		lua.append("function *------*:ctor()\n")
		lua.append("\t\n")
		lua.append("end\n\n")
		lua.append("return " + className)
		
		for i in range(len(lua)):
			lua[i] = lua[i].replace('*------*',className)
		
		fp = open(targetPath,'wt')
		print >>fp, ''.join(lua);
		fp.close()
	else:
		print '[error]:target file already exist!'
		
#by Jackie
def _rescur(tmpDict,dictname,lua,depth):
	if isinstance(tmpDict,dict):
		if depth <= 0:
			lua.append('\t'*depth + "local " + dictname + ' = {\n')
		else:
			lua.append('\t'*depth + dictname + ' = {\n')
		tmp = tmpDict.keys()
		tmp.sort()
		for key in tmp:
			_rescur(tmpDict[key],key,lua,depth + 1)
		if depth <= 0:
			lua.append('\t'*depth + '}\n')
		else:
			lua.append('\t'*depth + '},\n')
	else:
		lua.append('\t'*depth + dictname + ' = ' +"\"" + tmpDict + "\"" + ',\n')
		
#by Jackie	
#resType 1为ui资源，2为lua文件资源
def _createDict(path,tmpPath, root,pathOffset,resType):
	pathList = os.listdir(path)
	for i, item in enumerate(pathList):
		if os.path.isdir(os.path.join(path, item)):
			path = os.path.join(path, item)
			path = path.replace('\\','/')
			root[ item ] = {}
			if tmpPath == "":
				_createDict(path,tmpPath + item, root[item],pathOffset,resType)
			else:
				_createDict(path,tmpPath + "/" + item, root[ item ],pathOffset,resType)
			path = '/'.join(path.split('/')[:-1])
		else:
			dotIndx = item.find('.')
			if dotIndx != -1:
				fileName = item[:dotIndx]
				if tmpPath == "":
					if resType == 1:
						#ui资源，plist文件，只需保留plist配置文件即可
						if root.has_key(fileName) and root[ fileName ][root[ fileName ].find('.'):] == '.plist':
							pass
						else:
							root[ fileName ] = pathOffset + tmpPath + item
					elif resType == 2:
						#lua文件资源
						root[ fileName ] = pathOffset + tmpPath + fileName
					else:
						#其他资源
						root[ fileName ] = pathOffset + tmpPath + item
				else:
					if resType == 1:
						#ui资源，plist文件，只需保留plist配置文件即可
						if root.has_key(fileName) and root[ fileName ][root[ fileName ].find('.'):] == '.plist':
							pass
						else:
							root[ fileName ] = pathOffset + tmpPath + "/" + item
					elif resType == 2:
						#lua文件资源
						root[ fileName ] = pathOffset + tmpPath + "/" + fileName
					else:
						#其他资源
						root[ fileName ] = pathOffset + tmpPath + "/" + item
				if resType == 2:
					#lua文件资源
					root[ fileName ] = root[ fileName ].replace('/','.')
					root[ fileName ] = root[ fileName ].replace('\\','.')
			else:
				raise TypeError('有些资源名没有扩展名:'+item)
				
#by Jackie
def createRes(resDir,luaDir,outDir):
	resDir = os.path.join(resDir,'')
	luaDir = os.path.join(luaDir,'')
	outFile = os.path.join(outDir,'res.lua')
	resDir = resDir.replace('\\','/')
	luaDir = luaDir.replace('\\','/')
	outFile = outFile.replace('\\','/')
	pathOffset = -1
	pathOffset_lua = -1
	
	print resDir
	print luaDir
	
	if resDir.find("scripts/res/") != -1:
		pathOffset = resDir[resDir.find("scripts/res/") + 12:]
	elif resDir.find("scripts/res") != -1:
		pathOffset = resDir[resDir.find("scripts/res") + 11:]
		
	if luaDir.find("scripts/src/") != -1:
		pathOffset_lua = luaDir[luaDir.find("scripts/src/") + 12:]
	elif luaDir.find("scripts/src") != -1:
		pathOffset_lua = luaDir[luaDir.find("scripts/src") + 11:]
	
	if pathOffset != -1 and pathOffset_lua != -1:
		lua = [];root = {};resRoot = "res";rootLua = {};totalRoot = {}
		_createDict(resDir,"", root,pathOffset,1)
		_createDict(luaDir,"", rootLua,pathOffset_lua,2)
		totalRoot['res'] = root
		totalRoot['lua'] = rootLua
		_rescur(totalRoot,resRoot,lua,0)
		lua.append("\nreturn " + resRoot)
		fp = open(outFile,'wt')
		print >>fp, ''.join(lua);
		fp.close()
	else:
		raise TypeError('createRes:invalid arguments')

# -------------- main --------------
# 获取指定的section， 指定的option的值
print("==++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++==")
autherInfoauther = config.get("CopyRight", "auther")
autherInfoemail = config.get("CopyRight", "email")
autherInfotips = config.get("CopyRight", "tips")
print("==> CopyRight : " + autherInfoauther + " " + autherInfoemail + " " + autherInfotips)
print("==++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++==")

resCopyPath = config.get("SystemResolution", "copyPath")
targetPath = config.get("SystemResolution", "targetPath")

#是否CopyTo DebugWin32下面
copyDebugWin32 = config.getboolean("SystemResolution", "copytoDebugWin32")

_xxteaKey = config.get("xxtea", "XXTEAKey")
_xxteaSign = config.get("xxtea", "XXTEASign")
_targetScrPath = config.get("xxtea", "targetScrPath")

# if len(sys.argv) == 2:

if sys.argv[1].startswith('-'):

	option = sys.argv[1][1:]

	#fetch sys.argv[1] 
	if option == 'help':
		print '[WaWagame Script Platform]\n'
		print '[scriptDevTool.py -run]         quickly run the game exe when develop'
		print '[scriptDevTool.py -luacompile]  compile lua file by xxtea. Should set target folder'
		print '[scriptDevTool.py -runasluac]   comple lua file by xxtea and run exe. For release]'
		print '[scriptDevTool.py -createlua e:/test.lua] create a tmplate lua file'
		print '[scriptDevTool.py -createres e:/Resources/scripts/res e:/Resources/scripts/src/ e:] parse e:Resources res files,create a lua table named res in res.lua file under e: by jackie'
	
	elif option == 'copy':
		copy_file_handler()	
	elif option == 'run':
		copy_file_handler()
		build()
	elif option == 'luacompile':
		del_file(_targetScrPath + "\src")
		XXTEA()
		print("Had Use xxtea luacompile, " + _targetScrPath + " folder had been copy encrypt file")
	elif option == 'runasluac':
		del_file(_targetScrPath + "\src")
		XXTEA()
		build()
		print("Had Use xxtea luacompile, " + _targetScrPath + " folder had been copy encrypt file")
	elif option == 'createlua' and sys.argv[2] and sys.argv[3]:
		createLuaClass(sys.argv[2],sys.argv[3])
	elif option == 'createres' and sys.argv[2] and sys.argv[3] and sys.argv[4]:
		createRes(sys.argv[2],sys.argv[3],sys.argv[4])
	else:
		print '[WaWagame Script Platform] commond args is not support' 

print('==> What a fuck that finished at ' + time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time())))





