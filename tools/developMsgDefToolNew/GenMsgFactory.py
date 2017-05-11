#!/usr/bin/python
# -*- coding: UTF-8 -*-
import glob, re, os, subprocess, time, sys, ctypes, platform, stat, struct, shutil
import os
import sys

sys.path.append(os.getcwd() + '\\wawasys')


class GenMsgFactory():
    '文件生成底层对象'

    def __init__(self, para_fileName, para_send_type_info_map):
        self._fileName = para_fileName
        self.send_type_info_map = para_send_type_info_map

    def sortParaArrayByMsgID(self):
        self.msg_id_sorted_arr = [];
        for k, v in self.send_type_info_map.items():
            self.msg_id_sorted_arr.append((v['msgid'], k));
        self.msg_id_sorted_arr.sort();

    def switchWriteMethodGetType(self, type_name):
        if type_name == 'char':
            return 'writeChar';

        if type_name == 'string':
            return 'writeLengthAndString';

        if type_name == 'short':
            return 'writeShort';

        if type_name == 'int':
            return 'writeInt';

        if type_name == 'long long':
            return 'writeLongLong';

        if type_name == 'float':
            return 'writeFloat';

        if type_name == 'double':
            return 'writeDouble';

        if type_name == 'bool':
            return 'writeBoolean';

    def switchReadMethodGetType(self, type_name):
        if type_name == 'char':
            return 'readChar';

        if type_name == 'string':
            return 'readLengthAndString';

        if type_name == 'short':
            return 'readShort';

        if type_name == 'int':
            return 'readInt';

        if type_name == 'long long':
            return 'readLongLong';

        if type_name == 'float':
            return 'readFloat';

        if type_name == 'double':
            return 'readDouble';

        if type_name == 'bool':
            return 'readBoolean';

        if type_name == 'icondata':
            return 'readLengthAndData'

        if type_name == 'byteArray':
            return 'readLengthAndData'

            # if type_name == 'loop':
            #     return 'readBoolean';

    def is_build_in_type(self, type_name):
        return self.switchWriteMethodGetType(type_name);

    def is_build_in_read_type(self, type_name):
        return self.switchReadMethodGetType(type_name);

    def generate_lua(self):
        visited = {};
        output = [];

        def headCreate():
            # 文件头生成
            output.append('-------------------------------------------------------------------------\n');
            output.append('-- Desc:    ' + self._fileName['context'] + '\n');
            output.append('-- Author:  协议脚本工具生成文件\n');
            output.append('-- Info:    Version3.0 模块化支持\n');
            output.append('-- 2016/10/22    支持子线程解析Buffer，直接返回table到Lua\n');
            output.append('-- Copyright (c) wawagame Entertainment All right reserved.\n');
            output.append('-------------------------------------------------------------------------\n');

            # class create
            output.append('local ' + self._fileName['name'] + ' = class("' + self._fileName['name'] + '")\n\n');

            # 消息ID
            output.append(self._fileName['name'] + '.' + 'MSG_ID = {\n');
            for msg_id_info in self.msg_id_sorted_arr:
                k = msg_id_info[0];
                v = msg_id_info[1];
                output_enum_name = v;

                type_info = self.send_type_info_map[v];
                comment = type_info['comment'];

                if len(output_enum_name) < 31:
                    output_enum_name = output_enum_name + (31 - len(output_enum_name)) * ' ';
                output.append('    ' + output_enum_name + ' = ' + hex(k) + ', -- ' + str(k) + ', ' + comment + '\n');
            output.append('};\n\n')
            # output.append('--子线程消息解析映射\n');
            # output.append(self._fileName['name'] + '.' + 'MSG_THREAD_MAP = {};\n\n');

        # 处理循环读取
        def loopHandle(field_arr, nSubLoopNum):

            isLoopReadKeyExist = field_arr.has_key('loopReadType')
            isloopCountKeyExist = field_arr.has_key('loopCountKey')
            if isLoopReadKeyExist:
                print(field_arr['loopReadType'])

            loopNum = nSubLoopNum
            countKeyName = 'count';
            countSpace = '';
            countTabRowName = 't_row1';  # 循环列表Row的名称
            countTabRowNameLast = countTabRowName;  # 前一个loop的数据行的key
            if loopNum > 0:
                countKeyName = 'count' + str(loopNum + 1);
                countTabRowName = 't_row' + str(loopNum + 1);
                countTabRowNameLast = 't_row' + str(loopNum);
                for x in range(1, loopNum + 1):
                    print(x)
                    countSpace = countSpace + '    ';

            if isLoopReadKeyExist and field_arr['loopReadType'] == 'char':
                output.append(countSpace + '    local ' + countKeyName + ' = netWWBuffer:readChar()\n');
            else:
                if field_arr['loopReadType'] == 'none':
                    print('none');
                else:
                    output.append(countSpace + '    local ' + countKeyName + ' = netWWBuffer:readShort()\n');
            output.append(countSpace + '    local ' + field_arr['loopTableKey'] + ' = {}\n');
            if isloopCountKeyExist:
                output.append(countSpace + '    '+countTabRowNameLast+'.'+field_arr['loopCountKey'] +' = '+ countKeyName+'\n');

            output.append(countSpace + '    for i=1, ' + countKeyName + ' do\n');
            output.append(countSpace + '        local ' + countTabRowName + ' = {}\n');

            # print(field_arr['loopTableKey']);
            # print(field_arr['fields']);

            field_arr_items = field_arr['fields'];

            for fields in field_arr_items:
                field_type = fields[0];
                field_name = fields[1];
                # print(field_type);
                # print(field_name);

                if field_type == 'loop':  # 嵌套循环
                    loopNum = loopNum + 1;
                    print('loopNum -> ' + str(loopNum))
                    loopHandle(field_name, loopNum);
                else:
                    output.append(
                        countSpace + '        ' + countTabRowName + '.' + field_name + ' = netWWBuffer:' + self.is_build_in_read_type(
                            field_type) + '()\n')

            # 将遍历读取后的内容存入到Table中，作为子集
            output.append(
                countSpace + '        table.insert(' + field_arr['loopTableKey'] + ', ' + countTabRowName + ')\n');
            output.append(countSpace + '    end\n');

            if nSubLoopNum > 0:
                output.append(
                    countSpace + '    ' + countTabRowNameLast + '["' + field_arr['loopTableKey'] + '"] = ' + field_arr[
                        'loopTableKey'] + '\n\n');
            else:
                output.append(countSpace + '    t_result["' + field_arr['loopTableKey'] + '"] = ' + field_arr[
                    'loopTableKey'] + '\n\n');

                # 处理循环读取

#

        def loopHandleThreadInfo(field_arr, nSubLoopNum):

            loopNum = nSubLoopNum

            isLoopReadKeyExist = field_arr.has_key('loopReadType')
            isloopCountKeyExist = field_arr.has_key('loopCountKey')
            output.append('    {"loop",\n');
            
            if isLoopReadKeyExist and isloopCountKeyExist:
                output.append('          {"' + field_arr['loopReadType'] + '","' + field_arr['loopTableKey']+'","' + field_arr['loopCountKey'] + '"},' + '\n');
            elif isLoopReadKeyExist:
                output.append('          {"' + field_arr['loopReadType'] + '","' + field_arr['loopTableKey'] + '"},' + '\n');
            field_arr_items = field_arr['fields'];
            for fields in field_arr_items:
                field_type = fields[0];
                field_name = fields[1];
                # print(field_type);
                # print(field_name);

                if field_type == 'loop':  # 嵌套循环
                    loopNum = loopNum + 1;
                    print('loopNum -> ' + str(loopNum))
                    loopHandleThreadInfo(field_name, loopNum);
                else:
                    output.append('          {"' + field_type + '","' + field_name + '"},' + '\n');

            output.append('    },\n');

        # 写消息
        def output_type(type_name, is_msg, msg_id):
            if type_name in visited:
                return;

            visited[type_name] = True;

            type_info = self.send_type_info_map[type_name];
            msg_fields = type_info['fields'];
            comment = type_info['comment'];

            for field in msg_fields:
                is_vector = False;
                field_type = field[0];
                field_name = field[1];

                if field_type == 'vector':
                    is_vector = True;
                    field_type = field_name;
                    field_name = field[2];

            if is_msg:
                # 注释
                output.append('-- ' + hex(msg_id) + ' = ' + str(msg_id) + ' = ' + type_name + '\n');
                output.append('-- ' + comment + '\n');

                # 内容
                output.append('local ' + type_name + '_write' + ' = function(sendTable)\n\n');
                output.append('    if nil == sendTable then\n');
                output.append('       flog("[Wawagame Error] sendTable must not nil")\n');
                output.append('       return nil\n');
                output.append('    end\n\n');

                output.append('    local nIndex = 0\n');
                output.append('    local autoPlus = function(nNum)\n');
                output.append('       nIndex = nIndex + 1\n');
                output.append('       return nIndex\n');
                output.append('    end\n\n')

            if is_msg:
                output.append('    local wb = ww.WWBuffer:create()\n')

            # 写消息头
            for x in xrange(0, 3):
                output.append('    wb:writeChar(sendTable[autoPlus(nIndex)])\n')

            # 写消息脚本
            for field in msg_fields:

                is_vector = False;
                field_type = field[0];
                field_name = field[1];

                if field_type == 'vector':
                    is_vector = True;
                    field_type = field_name;
                    field_name = field[2];

                output.append('    wb:' + self.is_build_in_type(field_type) + '(sendTable[autoPlus(nIndex)])\n')

            # 封包end
            output.append('\n    return wb\n');
            output.append('end\n\n');

            print('Generate Write function......' + type_name);

        # 读取消息
        def output_read_type(type_name, is_msg, msg_id):
            if type_name in visited:
                return;

            visited[type_name] = True;

            type_info = self.send_type_info_map[type_name];
            msg_fields = type_info['fields'];
            comment = type_info['comment'];

            for field in msg_fields:
                is_vector = False;
                field_type = field[0];
                field_name = field[1];

                if field_type == 'vector':
                    is_vector = True;
                    field_type = field_name;
                    field_name = field[2];

            if is_msg:
                # 注释
                output.append('-- ' + hex(msg_id) + ' = ' + str(msg_id) + ' = ' + type_name + '\n');
                output.append('-- ' + comment + '\n');

                # 内容
                output.append('local ' + type_name + '_read' + ' = function(reciveMsgId, netWWBuffer)\n\n');
                output.append('    if type(netWWBuffer) ~= "userdata" then\n');
                output.append('       flog("[Wawagame Error] This function value netWWBuffer must a userdata")\n');
                output.append('       return\n');
                output.append('    end\n\n');

                output.append('    -- wwlog("Paser msg id -> %d", reciveMsgId)\n');

            if is_msg:
                output.append('    local t_result = {}\n\n');

            # 写消息脚本
            for field in msg_fields:

                is_vector = False;
                field_type = field[0];
                field_name = field[1];

                if field_type == 'loop':
                    loopHandle(field_name, 0);
                    # print(field_name);
                else:
                    output.append('    t_result.' + field_name + ' = netWWBuffer:' + self.is_build_in_read_type(
                        field_type) + '()\n')

            output.append('\n    -- ccdump(t_result) --打印table\n');

            # 封包end
            output.append('\n    return t_result\n');
            output.append('end\n\n');

            print('Generate Read function......' + type_name);

        # 读取消息
        def output_read_thread_type(type_name, is_msg, msg_id):
            if type_name in visited:
                # return;
                print('output_read_thread_type')

            visited[type_name] = True;

            type_info = self.send_type_info_map[type_name];
            msg_fields = type_info['fields'];
            comment = type_info['comment'];

            for field in msg_fields:
                is_vector = False;
                field_type = field[0];
                field_name = field[1];

                if field_type == 'vector':
                    is_vector = True;
                    field_type = field_name;
                    field_name = field[2];

            if is_msg:
                # 注释
                output.append('-- ' + hex(msg_id) + ' = ' + str(msg_id) + ' = ' + type_name + '\n');
                output.append('-- ' + comment + '线程函数解析关系注册\n');

                # 内容
                output.append('local ' + type_name + '_Threadread' + ' = function(reciveMsgId, netWWBuffer)\n\n');

            if is_msg:
                output.append('    local t_reflxTable = {\n\n');

            # 写消息脚本
            for field in msg_fields:

                is_vector = False;
                field_type = field[0];
                field_name = field[1];

                if field_type == 'loop':
                    loopHandleThreadInfo(field_name, 0);
                else:
                    output.append('    {"' + field_type + '","' + field_name + '"},' + '\n');

            # 封包end
            output.append('\n    } \n    --return a table\n');
            # output.append("    table.insert(self.MSG_THREAD_MAP, t_reflxTable)\n\n")
            output.append("   return t_reflxTable\n")

            output.append('end\n\n');

            print('Generate Read function......' + type_name);

        def outoutregistMsg():
            output.append('    --将函数注册到映射表\n');
            for msg_id_info in self.msg_id_sorted_arr:
                k = msg_id_info[0];
                v = msg_id_info[1];

                mType = self.send_type_info_map[v]['msgtype']

                print(k);
                print(v);
                print(mType);

                if mType == 'write':
                    output.append(
                        '    NetWorkBridge:setMsgWriterReflex(self.MSG_ID.' + v + ', ' + v + '_write, target)\n');

                elif mType == 'read':
                    output.append(
                        '    NetWorkBridge:setMsgReadReflex(self.MSG_ID.' + v + ', ' + v + '_read, target)\n');
                    # output.append('    ' + v + '_Threadread()\n'); #插入多线程解析消息头
                    output.append('    WWNetAdapter:bindMsgTable(self.MSG_ID.' + v +','+ v + '_Threadread())\n'); #往底层插入消息解析映射


                print('Generate Register function......' + v);

            output.append('\n');

        # 生成头
        headCreate();

        # ctor函数前半部
        # output.append('function testnetModel:ctor()\n');
        output.append('function ' + self._fileName['name'] + ':ctor(target)\n');

        # 读取消息体,实现具体逻辑
        for msg_id_info in self.msg_id_sorted_arr:
            k = msg_id_info[0];
            v = msg_id_info[1];

            mType = self.send_type_info_map[v]['msgtype'];  # 消息类型

            # print(mType);

            if mType == 'write':
                output_type(v, True, k);
            elif mType == 'read':
                output_read_type(v, True, k);
                # bindMsgThread
                output_read_thread_type(v, True, k);

        # 将函数注册到映射容器
        outoutregistMsg();

        # ctor函数后半部
        output.append('\nend');

        # return
        output.append('\n\nreturn ' + self._fileName['name']);

        return ''.join(output);

    def string_to_file(self, s, file_name):
        # print('Generate netbean success! Save file \'' + file_name + '\'');
        fout = open(file_name, 'w+');
        print >> fout, s;
        fout.close();

        print('-------------------------------------------------------------------------');
        print('-- Generate NetbeanModel success! Save file \'' + file_name + '\'');
        print('-- ' + time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time())));
        print('--');
        print('-- Send mail to me.If you have any question.(670924505@qq.com)');
        print('-- Copyright (c) wawagame Entertainment All right reserved.');
        print('-------------------------------------------------------------------------');

    def genStart(self):
        self.sortParaArrayByMsgID();
        self.string_to_file(self.generate_lua(), self._fileName['name'] + '.lua');
