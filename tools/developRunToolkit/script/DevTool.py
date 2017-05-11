'''
Created on 2016/8/16

@author: Administrator
'''
import os
import stat
import shutil
from ConfigParser import ConfigParser
from ResolutionDef import ResolutionDef
from optparse import OptionParser
import time

class DevTool(object):
    '''
    classdocs
    '''


    def __init__(self):
        '''
        Constructor
        '''
        self.resolutionResRoot = None
        self.projectResRoot = None
        self.projectSrcRoot = None
        # self.androidassetRoot = None
        self.androidRoot = None
        self.listTagIds = None
        self.resolutionList = {}
        self.chooseTag = None
        self.XXTEAKey = None
        self.XXTEASign = None
        self.apkfile = False
        pass
    def delDir(self,path):
        rootdir=path
        if os.path.isabs(path):
            pass
        else:
            rootdir = os.path.join(os.getcwd(),path)
        if os.path.exists(rootdir):
            print "%s exists" %(rootdir)
        else:
            print "%s not exists" %(rootdir)
        
        filelist=os.listdir(rootdir)
        for f in filelist:
            print "%s" % f
            filepath = os.path.join( rootdir, f )
            if os.path.isfile(filepath):
                os.chmod(filepath, stat.S_IWRITE )
                os.remove(filepath)
                print filepath+" removed!"
            elif os.path.isdir(filepath):
                self.delDir(filepath)
#                 shutil.rmtree(filepath,False)
                print "dir "+filepath+" removed!"
        shutil.rmtree(rootdir,True)
        print "dir "+rootdir+" removed!"
    def copyFile(self,srcPath,destPath):
        for f in os.listdir(srcPath):
            src_path = os.path.join(srcPath,f)
            dst_path = os.path.join(destPath,f)
            if os.path.isfile(src_path):
                if not os.path.exists(destPath):
                    os.makedirs(destPath)
                #if not os.path.exists(dst_path):
                shutil.copy(src_path,dst_path)
                print "copy file from %s to %s" %(src_path,dst_path)
            if os.path.isdir(src_path):
                self.copyFile(src_path,dst_path)
    def copyFileExcept(self,srcPath,destPath,suffix):
        for f in os.listdir(srcPath):
            src_path = os.path.join(srcPath,f)
            dst_path = os.path.join(destPath,f)
            if os.path.splitext(src_path)[1]==suffix:
                continue
            if os.path.isfile(src_path):
                if not os.path.exists(destPath):
                    os.makedirs(destPath)
                #if not os.path.exists(dst_path):
                shutil.copy(src_path,dst_path)
                print "copy file from %s to %s" %(src_path,dst_path)
            if os.path.isdir(src_path):
                self.copyFile(src_path,dst_path)
        pass
    def copyDirExcept(self,srdDir,destDir,suffix):
        for f in os.listdir(srdDir):
            if f==suffix:
                continue
            src_path = os.path.join(srdDir,f)
            dst_path = os.path.join(destDir,f)

            if os.path.isfile(src_path):
                if not os.path.exists(destDir):
                    os.makedirs(destDir)
                #if not os.path.exists(dst_path):
                shutil.copy(src_path,dst_path)
#                 print "copy file from %s to %s" %(src_path,dst_path)
            if os.path.isdir(src_path):
                self.copyDirExcept(src_path,dst_path,suffix)
        pass
    def parseInitFile(self,path):
        if not self.checkFileExist(path):
            return
        cp = ConfigParser()
        cp.read(path)
        resOpts = cp.options("ResourceResolution")
        if "resolutionresroot" in resOpts:
            self.resolutionResRoot = cp.get("ResourceResolution", "resolutionResRoot")
            print self.resolutionResRoot
        if "projectresroot" in resOpts:
            self.projectResRoot = cp.get("ResourceResolution", "projectResRoot")
            print self.projectResRoot
        if "projectbaseroot" in resOpts:
            self.projectbaseroot = cp.get("ResourceResolution", "projectBaseroot")
            print self.projectbaseroot
        if "androidroot" in resOpts:
            self.androidRoot = cp.get("ResourceResolution", "androidRoot")
            print self.androidRoot
        if "projectsrcroot" in resOpts:
            self.projectSrcRoot = cp.get("ResourceResolution", "projectSrcRoot")
            print self.projectSrcRoot
        if "configtablename" in resOpts:
            self.tableName = cp.get("ResourceResolution", "configTableName")
            print self.tableName
        if "configfilename" in resOpts:
            self.tablePath = cp.get("ResourceResolution", "configFileName")
            print self.tablePath
        
        if "restags" in resOpts:
            resTags = cp.get("ResourceResolution", "resTags")
            print(resTags)
            self.listTagIds = resTags.split("|")
        if self.listTagIds != None:
            
            for tag in self.listTagIds:
                if cp.has_section(tag):
                    cp.options(tag)
                    resolutiondef = ResolutionDef()
                    resolutiondef.setTag(tag)
                    if cp.has_option(tag, "width"):
                        resolutiondef.setWdith(int(cp.get(tag, "width")))
                    else:
                        resolutiondef.setWdith(0)
                    if cp.has_option(tag, "height"):
                        resolutiondef.setHeight(int(cp.get(tag, "height")))
                    else:
                        resolutiondef.setHeight(0)
                    if cp.has_option(tag, "title"):
                        resolutiondef.setTitle(cp.get(tag, "title"))
                    else:
                        resolutiondef.setTitle("")
                    self.resolutionList[tag] = resolutiondef
            
        xxOpts = cp.options("xxtea")
        if "XXTEAKey".lower() in xxOpts:
            self.XXTEAKey = cp.get("xxtea", "XXTEAKey")
            print(self.XXTEAKey)
        if "XXTEASign".lower() in xxOpts:
            self.XXTEASign = cp.get("xxtea", "XXTEASign")
            print(self.XXTEASign)
            
    def doWin32Res(self):
        if self.resFiles:
            su = self.getResolution(self.resmode)
            self.copyFile(os.path.join(self.resolutionResRoot,su.getTag()), self.projectResRoot)
            self.createLuaTable(self.tablePath,self.tableName, su.getTitle(),su.getWidth(), su.getHeight(), self.projectResRoot)
        soundpath = os.path.join(self.projectResRoot,"sound")
        if os.path.exists(soundpath):
            self.delDir(soundpath)
        if not os.path.exists(soundpath):
            os.makedirs(soundpath)
        self.copyFile(os.path.join(self.projectResRoot,"../sound_win"), os.path.join(self.projectResRoot,"sound"))
        print("win32 project completed!")
    def doAndroidRes(self,compilelua = True):

#         self.delDir(os.path.abspath('../../../res/sound'))
#         os.makedirs(os.path.abspath('../../../res/sound'))
#         self.copyFile(os.path.abspath('../../../sound'), os.path.abspath('../../../res/sound'))
#         self.resolutionResRoot
        soundpath = os.path.join(self.projectResRoot,"sound")
        if os.path.exists(soundpath):
            self.delDir(soundpath)
        if not os.path.exists(soundpath):
            os.makedirs(soundpath)
        if os.path.exists(os.path.join(self.projectResRoot,"../sound_android")):
            self.copyFile(os.path.join(self.projectResRoot,"../sound_android"), os.path.join(self.projectResRoot,"sound"))
        assetres = os.path.join(self.androidRoot,"assets/res")
        if os.path.exists(assetres):
            self.delDir(assetres)
        assetbase = os.path.join(self.androidRoot,"assets/base")
        if os.path.exists(assetbase):
            self.delDir(assetbase)
        assetsrc = os.path.join(self.androidRoot,"assets/src")
        if os.path.exists(assetsrc):
            self.delDir(assetsrc)
        tempassetres = os.path.join(self.androidRoot,"assets/res_temp")
        if os.path.exists(tempassetres):
            self.delDir(tempassetres)
        tempassetbase = os.path.join(self.androidRoot,"assets/base_temp")
        if os.path.exists(tempassetbase):
            self.delDir(tempassetbase)
        tempassetsrc = os.path.join(self.androidRoot,"assets/src_temp")
        if os.path.exists(tempassetsrc):
            self.delDir(tempassetsrc)
            
        #copy res
        if not self.checkFileExist(self.androidRoot):
            return
        if compilelua:
            
            if self.checkFileExist(self.projectResRoot):
                if not self.checkFileExist(assetres):
                    os.makedirs(assetres)
                if not self.checkFileExist(tempassetres):
                    os.makedirs(tempassetres)
                    
                self.copyFile(self.projectResRoot, tempassetres)
                self.compileLuaFile(tempassetres, assetres)
                self.copyFileExcept(self.projectResRoot, assetres,".lua")
                self.delDir(tempassetres)
            if self.checkFileExist(self.projectbaseroot):
                if not self.checkFileExist(assetbase):
                    os.makedirs(assetbase)
                if not self.checkFileExist(tempassetbase):
                    os.makedirs(tempassetbase)
                self.copyFile(self.projectbaseroot, tempassetbase)
                self.compileLuaFile(tempassetbase, assetbase)
                self.delDir(tempassetbase)            
            if self.checkFileExist(self.projectSrcRoot):
                if not self.checkFileExist(assetsrc):
                    os.makedirs(assetsrc)
                if not self.checkFileExist(tempassetsrc):
                    os.makedirs(tempassetsrc)
                self.copyFile(self.projectSrcRoot, tempassetsrc)
                self.compileLuaFile(tempassetsrc, assetsrc)
                self.delDir(tempassetsrc)
        else:
            self.compileAndroidProject()
#         assetres = os.path.join(self.androidRoot,"assets/res")
#         if not os.path.exists(assetres):
#             os.makedirs(assetres)
#         if self.checkFileExist(self.projectResRoot) and self.checkFileExist(assetres):
#             self.copyFile(self.projectResRoot, assetres)
#         
#         #copy src
#         assetsrc = os.path.join(self.androidRoot,"assets/src")
#         if not os.path.exists(assetsrc):
#             os.makedirs(assetsrc)
#         if self.checkFileExist(self.projectSrcRoot) and  self.checkFileExist(assetsrc):
#             self.copyFile(self.projectSrcRoot, assetsrc)
#             #compile src
#             if not self.debugmode:
#                 
#                 pass
    def delFiles(self,targetDir,suffix,topdown=True): 
        for root, dirs, files in os.walk(targetDir, topdown): 
            for name in files: 
                pathname = os.path.splitext(os.path.join(root, name)) 
                if (pathname[1] == suffix): 
                    os.remove(os.path.join(root, name)) 
                    print(os.path.join(root,name)) 
    def compileAndroidProject(self):
        noapk = "--no-apk"
        build_mode = "release"
        if self.debugmode:
            build_mode = "debug"
        if not self.apkfile:
            noapk = "--no-apk"
            #--no-apk
        if self.coompileScript:
            if self.XXTEAKey !=None and self.XXTEASign !=None:
                command = 'cocos compile -p android -s %s -m %s --lua-encrypt --lua-encrypt-key %s --lua-encrypt-sign %s %s' % (self.androidRoot, build_mode,self.XXTEAKey,self.XXTEASign,noapk)
            else:
                command = 'cocos compile -p android -s %s -m %s %s' % (self.androidRoot, build_mode,noapk)
        else:
            command = 'cocos compile -p android -s %s -m %s --compile-script 0 %s' % (self.androidRoot, build_mode,noapk)
        
        print(command)
        assetDir = os.path.join(self.androidRoot,"assets")
        if not self.checkFileExist(assetDir): 
            os.makedirs(assetDir)
        os.chmod(assetDir, stat.S_IWRITE )
        if os.system(command) != 0:
            raise Exception("Build dynamic library for project [ " + self.androidRoot + " ] fails!")
        print("deal lua script................")
        assetres = os.path.join(self.androidRoot,"assets/res")
        assetbase = os.path.join(self.androidRoot,"assets/base")
        assetsrc = os.path.join(self.androidRoot,"assets/src")
        if self.checkFileExist(assetbase):
            self.delDir(assetbase)
        if not self.checkFileExist(assetbase): 
            os.makedirs(assetbase)
        self.copyDirExcept(self.projectbaseroot, assetbase,".svn")
        self.copyDirExcept(self.projectResRoot, assetres,".svn")
        self.copyDirExcept(self.projectSrcRoot, assetsrc,".svn")
        self.delDir(os.path.join(assetsrc,".svn"))
        self.delDir(os.path.join(assetres,".svn"))
        print("deal lua script ok................")
        
        soundpath = os.path.join(self.projectResRoot,"sound")
        if os.path.exists(soundpath):
            self.delDir(soundpath)
        if not os.path.exists(soundpath):
            os.makedirs(soundpath)
        if not os.path.exists(os.path.join(self.projectResRoot,"../sound_win")): 
            self.copyFile(os.path.join(self.projectResRoot,"../sound_win"), os.path.join(self.projectResRoot,"sound"))
#         self.copyFile(os.path.join(self.projectSrcRoot,"../base"), os.path.join(self.androidRoot,"assets/base"))
        if self.apkfile:
            oldCwd = os.getcwd()
            os.chdir(self.androidRoot)
            os.system("ant deploy")
            os.chdir(oldCwd)
            pass
        print("android project compile completed!")
    def compileLuaFile(self,srcDir,destDir):
        if not self.checkFileExist(srcDir):
            return
        if not self.checkFileExist(destDir):
            os.makedirs(destDir)
        if self.XXTEAKey !=None and self.XXTEASign !=None:
            command = "cocos luacompile -s %s -d %s -e -k %s -b %s"%(srcDir,destDir,self.XXTEAKey,self.XXTEASign)
#             command = "cocos luacompile -s %s -d %s"%(srcDir,destDir)
        else:
            command = "cocos luacompile -s %s -d %s"%(srcDir,destDir)
        if os.system(command) != 0:
            raise Exception("Compile lua file for project [ " + self.androidRoot + " ] fails!")
        
    def createLuaTable(self, tableName, tabledef,title, width, height, dirpath):
        targetPath = os.path.join(dirpath, tableName + '.lua')
        print targetPath
        if os.path.exists(targetPath) and os.path.isfile(targetPath):
            os.remove(targetPath)
        if not os.path.exists(targetPath):
            lua = []
            lua.append("-----------------------------------------------------------\n")
            lua.append("-- Desc:     " + tableName + "\n")
            lua.append("-- Author:   cruelogre\n")
            lua.append("-- Date:       " + time.strftime('%Y-%m-%d %H:%M:%S', time.localtime()) + "\n")
            lua.append("-- Last:      \n")
            lua.append("-- Content:  \n")
            lua.append("-- Copyright (c) wawagame Entertainment All right reserved.\n")
            lua.append("---------------------------------------------------------\n\n")
        
            lua.append("local *------* = {\n")
            lua.append("\ttitle=\"" + str(title) + "\"; \n")
            lua.append("\twidth=" + str(width) + "; \n")
            lua.append("\theight=" + str(height) + "; \n")
            lua.append("}\n")
            lua.append("return *------*")
            for i in range(len(lua)):
                lua[i] = lua[i].replace('*------*', tabledef)
        
                fp = open(targetPath, 'wt')
                print >> fp, ''.join(lua);
                fp.close()
        else:
            print '[error]:target file already exist!'
    def parseArgs(self):
        parser = OptionParser() 
        parser.add_option("-r", "--resource mode", action="store", 
                  dest="resmode", 
                  default="h", 
                  help="set resource mode h/m, h for high quality,m for medium") 
        #--compile-script
        parser.add_option("-c", "--compile script", action="store_true", 
                  dest="coompileScript", 
                  default=False, 
                  help="set debug mode, if set,debug,otherwise release") 
        parser.add_option("-a", "--apk file", action="store_true", 
                  dest="apkfile", 
                  default=False, 
                  help="whether or not export apk file")
        parser.add_option("-f", "--file copy", action="store_true", 
                  dest="resFiles", 
                  default=False, 
                  help="whether or not copy resolution files")
        parser.add_option("-p", "--platform", action="store", 
                  dest="platform", 
                  default="win32", 
                  help="choose platform for operation,avaliable platform:win32,android,ios,default is win32")
        (options, args) = parser.parse_args() 

        self.resmode = options.resmode
        self.debugmode = True
        self.coompileScript = options.coompileScript
        self.apkfile = options.apkfile
        self.resFiles = options.resFiles
        self.platform = options.platform
        print options.resmode
        if self.platform == "win32" or self.platform == "ios":
            self.doWin32Res()
        elif self.platform == "android":
            self.doAndroidRes(False)
    def getResolution(self,mode):
        avaliablemode = {}
        firstRes = self.resolutionList[self.resolutionList.keys()[0]]
        
        for item,resolution in self.resolutionList.items():
            if resolution.getWidth() < firstRes.getWidth():
                avaliablemode["m"] = resolution
                avaliablemode["h"] = firstRes
                break
            elif resolution.getWidth() > firstRes.getWidth():
                avaliablemode["m"] = firstRes
                avaliablemode["h"] = resolution
                break
        retResoulution = None
        if mode.lower() in avaliablemode.keys():
            retResoulution = avaliablemode[mode.lower()]
        else:
            retResoulution = avaliablemode["h"]
        return retResoulution
    def checkFileExist(self,fPath):
        if not os.path.exists(fPath):
            print "file:%s not exists!" %(fPath)
            return False
        else:
            return True
# -----------------------main---------------------------------------
dev = DevTool()
#dev.copyFile("../test","../test2")
dev.parseInitFile("../conf/thewayAuto.ini")
dev.parseArgs()
#dev.doWin32Res()
#dev.doAndroidRes(False)
#dev.compileAndroidProject()
