#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

# 配置模块信息
_fileName = { 'name' : 'userIssueNotifyModel', 'context' : '用户数据发放模块' };

# 消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
   
    'Msg_IssueNotify_Ret': {
        'comment': '用户物品发放',
        'msgid' : 0x010137,
        'msgtype': 'read',
        'fields': [
            ('int', 'userId'),
            ('string', 'gameCash'),
            ('int', 'issueType'),
            ('string', 'notifyMsg'),
            ('loop',   {
                'loopTableKey' :           'signArr',
                'loopReadType' :           'short',
                 'fields': [
            ('string', 'magicName'),
            
            ('int', 'magicId'),
            ('int', 'magicCount'),
            ('string', 'magicUnit'),
            ('int', 'magicFid'),
            ('short', 'magicFunType'),
            ]}),
            ('char', 'result'),
            ('int', 'magicIssueId'),
        ],
    },
    'Msg_ResultInfo_Ret': {
        'comment': '操作反馈消息',
        'msgid' : 0x010108,
        'msgtype': 'read',
        'fields': [
            ('int', 'UserID'),
            ('char', 'Type'),
            ('char', 'Result'),
            ('string', 'Description'),
            ('int', 'Parameter'),
            ('string', 'Parameter2'),
            ('string', 'Parameter3'),
            ('string', 'Parameter4'),
        ],
    },
    'Msg_RequestInfo_Send': {
        'comment': '用户信息请求',
        'msgid' : 0x010101,
        'msgtype': 'write',
        'fields': [
            ('int', 'ObjectID'),
            ('char', 'Type'),
            ('int', 'Parameter1'),
            ('int', 'Parameter2'),
            ('string', 'StrParam'),
            
        ],
    },
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
