from can_cvector.vxlapi cimport xlclass


cdef extern from "Windows.h":
    pass


cdef extern from "vxlapi.h":
    xlclass.XLstringType xlGetErrorString(
        xlclass.XLstatus            err
    ) nogil
    xlclass.XLstatus xlGetSyncTime(
        xlclass.XLportHandle        portHandle, 
        xlclass.XLuint64           *pTime
    ) nogil
    xlclass.XLstatus xlGetChannelTime(
        xlclass.XLportHandle        portHandle, 
        xlclass.XLaccess            accessMask,
        xlclass.XLuint64           *pChannelTime
    ) nogil
    xlclass.XLstatus xlReceive(
        xlclass.XLportHandle        portHandle, 
        unsigned int               *pEventCount, 
        xlclass.XLevent            *pEventList
    ) nogil
    xlclass.XLstatus xlCanReceive(
        xlclass.XLportHandle        portHandle, 
        xlclass.XLcanRxEvent       *pXlCanRxEvt
    ) nogil
    xlclass.XLstatus xlCanTransmit(
        xlclass.XLportHandle        portHandle, 
        xlclass.XLaccess            accessMask,
        unsigned int               *pEventCount,
        void *pEvents
    ) nogil
    xlclass.XLstatus xlCanTransmitEx(
        xlclass.XLportHandle portHandle,
        xlclass.XLaccess            accessMask, 
        unsigned int                msgCnt, 
        unsigned int               *pMsgCntSent, 
        xlclass.XLcanTxEvent       *pXlCanTxEvt
    ) nogil
