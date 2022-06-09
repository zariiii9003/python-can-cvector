from can_cvector.vxlapi cimport xldefine


cdef extern from "Windows.h":
    ctypedef void*              HANDLE


cdef extern from "vxlapi.h":
    ctypedef short              XLstatus
    ctypedef long               XLportHandle
    ctypedef unsigned char      XLeventTag
    ctypedef unsigned long long XLuint64
    ctypedef unsigned long      XLulong
    ctypedef XLuint64           XLaccess
    ctypedef char*              XLstringType

    cdef struct s_xl_can_msg:
        unsigned int      id
        unsigned short    flags
        unsigned short    dlc
        unsigned char     data[xldefine.MAX_MSG_LEN]

    cdef struct s_xl_chip_state:
        unsigned char busStatus
        unsigned char txErrorCounter
        unsigned char rxErrorCounter

    cdef union s_xl_tag_data:
        s_xl_can_msg                    msg
        s_xl_chip_state                 chipState
    
    cdef struct s_xl_event:
        XLeventTag           tag
        unsigned char        chanIndex
        unsigned short       transId
        unsigned short       portHandle
        unsigned char        flags
        unsigned char        reserved
        XLuint64             timeStamp
        s_xl_tag_data        tagData

    ctypedef s_xl_event XLevent

    ctypedef struct XL_CAN_EV_RX_MSG:
        unsigned int    canId
        unsigned int    msgFlags
        unsigned char   dlc        
        unsigned char   data[xldefine.XL_CAN_MAX_DATA_LEN]
    
    ctypedef struct XL_CAN_EV_CHIP_STATE:
        unsigned char   busStatus
        unsigned char   txErrorCounter
        unsigned char   rxErrorCounter

    ctypedef struct XLcanRxEvent:
        unsigned short       tag
        unsigned short       channelIndex
        XLuint64             timeStampSync
        XL_CAN_EV_RX_MSG     canRxOkMsg     "tagData.canRxOkMsg"
        XL_CAN_EV_RX_MSG     canTxOkMsg     "tagData.canTxOkMsg"
        XL_CAN_EV_CHIP_STATE canChipState   "tagData.canChipState"

    ctypedef struct XL_CAN_TX_MSG:
        unsigned int       canId
        unsigned int       msgFlags
        unsigned char      dlc
        unsigned char      reserved[7]
        unsigned char      data[xldefine.XL_CAN_MAX_DATA_LEN]

    ctypedef struct XLcanTxEvent:
        unsigned short     tag
        unsigned short     transId
        unsigned char      channelIndex
        unsigned char      reserved[3]
        XL_CAN_TX_MSG      canMsg "tagData.canMsg"
