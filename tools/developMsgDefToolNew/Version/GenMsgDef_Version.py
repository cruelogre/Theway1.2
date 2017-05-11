#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

# 配置模块信息
_fileName = { 'name' : 'versionModel', 'context' : '客户端版本相关' };

# 消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_CheckVersion_send': {
        'comment': '客户端版本检查',
        'msgid' : 0x020107,
        'msgtype': 'write',
        'fields': [
            ('int', 'SP'),
            ('int', 'Operate'),
            ('int', 'HallID'),
            ('int', 'ComHallID'),
            ('string', 'Version'),
            ('string', 'Model'),
            ('int', 'type'),
            ('int', 'DiffPkg'),
        ],
    },
    'Msg_VersionStatus_Ret': {
        'comment': '版本信息',
        'msgid' : 0x020108,
        'msgtype': 'read',
        'fields': [
            ('int', 'VerStatus'),
            ('string', 'DownloadURL'),
            ('string', 'Description'),
            ('int', 'DiffPkg'),
        ],
    },
   
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
