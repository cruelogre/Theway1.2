#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

#配置模块信息
_fileName = { 'name' : 'luaHotModel', 'context' : 'lua热更新模块' };

#消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_LUAhotData_send': {
        'comment': '请求lua更新数据',
        'msgid' : 0x010148,
        'msgtype': 'write', 
        'fields': [
            ('int',                      'hallID'),
            ('short',                     'Op'),
            ('int',                      'Sp'),
            ('string',                      'Version'),
            ('string',                      'Subversion'),
            ('string',                      'LuaModel'),
        ],
    },
                      
       'Msg_LUAhotData_Ret': {
        'comment': '响应lua更新数据',
        'msgid' : 0x010148,
        'msgtype': 'read', 
        'fields': [
            ('int',                      'hallID'),
            ('short',                     'Op'),
            ('int',                      'Sp'),
            ('string',                      'Version'),
            ('string',                      'Subversion'),
            ('string',                      'LuaModel'),
        ],
    },
    
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
