#!/usr/bin/python
# -*- coding: UTF-8 -*-
# from GenMsgFactory import*
import sys
sys.path.append("..")
from GenMsgFactory import*

# 配置模块信息
_fileName = { 'name' : 'userSignInModel', 'context' : '签到模块' };

# 消息配置
# @param  comment  注释
# @param  msgid    消息ID
# @param  msgtype  消息SocketIO操作类型  （write ：发送， read : 接受解析）
# @param  fields   消息元素  （类型 -> 名称   如果类型是loop，则说明有循环）
#      loop中 loopTableKey -> 循环的table Key    fields为循环中的元素                 
send_type_info_map = {
    'Msg_UserSignInReq_send': {
        'comment': '用户签到请求',
        'msgid' : 0x010201,
        'msgtype': 'write',
        'fields': [
            ('short', 'type'),
            ('char', 'DayNo'),
        ],
    },
    'Msg_UserSignInCalendar_Ret': {
        'comment': '用户签到日历',
        'msgid' : 0x010202,
        'msgtype': 'read',
        'fields': [
            ('string', 'CurDate'),
            ('int', 'CardCount'),
            ('loop',   {
                'loopTableKey' :           'signArr',
                'loopReadType' :           'short',
                 'fields': [
            ('char', 'DayIndex'),
            
            ('char', 'Status'),
            ('string', 'DayAward'),
            ('int', 'EventType'),
            ('int', 'EventData'),
            ('string', 'EventDesc'),
            ]}),
              ('loop',   {
                'loopTableKey' :           'awardArr',
                'loopReadType' :           'short',
                 'fields': [
            ('char', 'DayNo'),
            ('char', 'AwardStatus'),
            ('string', 'AwardDesc')
            ]})
            
        ],
    },
   
};

if __name__ == '__main__':
    genFactory = GenMsgFactory(_fileName, send_type_info_map)
    genFactory.genStart()
    os.system("PAUSE");
