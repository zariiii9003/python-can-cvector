import typing

from can import Message
from can.interfaces.vector import xlclass as ctypes_xlclass
from can.interfaces.vector.exceptions import VectorOperationError

from can_cvector.vxlapi cimport xldefine, xlclass, xldriver

from libc.stdlib cimport malloc, free
from libc.string cimport memset, memcpy
from cpython.bytes cimport PyBytes_FromStringAndSize
from cpython.bytearray cimport (
    PyByteArray_FromStringAndSize,
    PyByteArray_AsString,
    PyByteArray_GET_SIZE,
)
from cpython.int cimport PyInt_AsUnsignedLongLongMask


cdef unsigned char[16] DLC_2_LEN = [0, 1, 2, 3, 4, 5, 6, 7, 8, 12, 16, 20, 24, 32, 48, 64]

cdef unsigned char len_2_dlc(unsigned short _len):
    if _len < 8:
        return _len

    for i in range(16):
        if DLC_2_LEN[i] >= _len:
            return i
    
    return 15

def recv_can(
        xlclass.XLportHandle port_handle,
        double time_offset,
        index_to_channel_map,
        handle_can_event_func,
) -> typing.Optional[Message]:
    cdef unsigned int EventCount = 1
    cdef xlclass.XLevent xl_event
    cdef xlclass.XLstatus xl_status = xldriver.xlReceive(port_handle, &EventCount, &xl_event)
    cdef xlclass.XLstringType error_string

    if xl_status == xldefine.XL_ERR_QUEUE_IS_EMPTY:
        return None

    if xl_status != xldefine.XL_SUCCESS:
        error_string = xldriver.xlGetErrorString(xl_status)
        raise VectorOperationError(xl_status, error_string, "xlReceive")

    if xl_event.tag != xldefine.e_XLevent_type.XL_RECEIVE_MSG:
        handle_can_event_func(
            ctypes_xlclass.XLevent.from_buffer_copy(
                PyBytes_FromStringAndSize(<char*> &xl_event, sizeof(xlclass.XLevent))
            )
        )
        return None

    cdef double timestamp = xl_event.timeStamp * 1e-9 + time_offset
    cdef unsigned int arbitration_id = xl_event.tagData.msg.id & 0x1FFFFFFF
    cdef bint is_extended_id = xl_event.tagData.msg.id & xldefine.XL_CAN_EXT_MSG_ID
    cdef bint is_remote_frame = xl_event.tagData.msg.flags & xldefine.XL_CAN_MSG_FLAG_REMOTE_FRAME
    cdef bint is_error_frame = xl_event.tagData.msg.flags & xldefine.XL_CAN_MSG_FLAG_ERROR_FRAME
    cdef bint is_rx = xl_event.tagData.msg.flags & xldefine.XL_CAN_MSG_FLAG_TX_COMPLETED
    cdef bint is_fd = 0
    cdef bint bitrate_switch = 0
    cdef bint error_state_indicator = 0
    cdef unsigned short dlc = xl_event.tagData.msg.dlc
    cdef char* data = <char*>xl_event.tagData.msg.data
    cdef int channel = index_to_channel_map[xl_event.chanIndex]

    msg = object.__new__(Message)
    msg.timestamp=timestamp
    msg.arbitration_id=arbitration_id
    msg.is_extended_id=is_extended_id
    msg.is_remote_frame=is_remote_frame
    msg.is_error_frame=is_error_frame
    msg.is_rx=is_rx
    msg.is_fd=is_fd
    msg.bitrate_switch = bitrate_switch
    msg.error_state_indicator = error_state_indicator
    msg.dlc=dlc
    msg.data=PyByteArray_FromStringAndSize(data, dlc)
    msg.channel=channel
    return msg


def recv_canfd(
        xlclass.XLportHandle port_handle,
        double time_offset,
        index_to_channel_map,
        handle_canfd_event_func,
) -> typing.Optional[Message]:
    cdef xlclass.XLcanRxEvent xl_can_rx_event
    cdef xlclass.XLstatus xl_status = xldriver.xlCanReceive(port_handle, &xl_can_rx_event)

    if xl_status == xldefine.XL_ERR_QUEUE_IS_EMPTY:
        return None

    if xl_status != xldefine.XL_SUCCESS:
        error_string = xldriver.xlGetErrorString(xl_status)
        raise VectorOperationError(xl_status, error_string, "xlCanReceive")

    cdef unsigned short tag = xl_can_rx_event.tag
    cdef xlclass.XL_CAN_EV_RX_MSG* data_struct = NULL
    cdef char* xl_can_rx_event_bytes = <char*> &xl_can_rx_event

    cdef bint is_rx
    if tag == xldefine.XL_CAN_EV_TAG_RX_OK:
        is_rx = 1
        data_struct = &xl_can_rx_event.canRxOkMsg
    elif tag == xldefine.XL_CAN_EV_TAG_TX_OK:
        is_rx = 0
        data_struct = &xl_can_rx_event.canTxOkMsg
    else:
        handle_canfd_event_func(
            ctypes_xlclass.XLcanRxEvent.from_buffer_copy(
                PyBytes_FromStringAndSize(<char*> &xl_can_rx_event, sizeof(xlclass.XLcanRxEvent))
            )
        )
        return 
    
    cdef double timestamp = xl_can_rx_event.timeStampSync * 1e-9 + time_offset
    cdef unsigned int arbitration_id = data_struct.canId & 0x1FFFFFFF
    cdef bint is_extended_id = data_struct.canId & xldefine.XL_CAN_EXT_MSG_ID
    cdef bint is_remote_frame = data_struct.msgFlags & xldefine.XL_CAN_RXMSG_FLAG_RTR
    cdef bint is_error_frame = data_struct.msgFlags & xldefine.XL_CAN_RXMSG_FLAG_EF
    cdef bint is_fd = 1
    cdef bint bitrate_switch = xl_can_rx_event.canRxOkMsg.msgFlags & xldefine.XL_CAN_RXMSG_FLAG_BRS
    cdef bint error_state_indicator = xl_can_rx_event.canRxOkMsg.msgFlags & xldefine.XL_CAN_RXMSG_FLAG_ESI
    cdef unsigned short dlc = DLC_2_LEN[data_struct.dlc]
    cdef char* data = <char*>data_struct.data
    cdef int channel = index_to_channel_map[xl_can_rx_event.channelIndex]

    msg = object.__new__(Message)
    msg.timestamp=timestamp
    msg.arbitration_id=arbitration_id
    msg.is_extended_id=is_extended_id
    msg.is_remote_frame=is_remote_frame
    msg.is_error_frame=is_error_frame
    msg.is_rx=is_rx
    msg.is_fd=is_fd
    msg.bitrate_switch = bitrate_switch
    msg.error_state_indicator = error_state_indicator
    msg.dlc=dlc
    msg.data=PyByteArray_FromStringAndSize(data, dlc)
    msg.channel=channel
    return msg


def send_can_msg_sequence(
    msgs,
    xlclass.XLportHandle port_handle,
    xlclass.XLaccess access_mask,
) -> int:
    cdef unsigned int eventCount = len(msgs)
    cdef xlclass.XLevent* pEvents = <xlclass.XLevent*> malloc(eventCount * sizeof(xlclass.XLevent))
    if not pEvents:
        raise MemoryError("malloc failed")
    memset(pEvents, 0, eventCount * sizeof(xlclass.XLevent))

    cdef xlclass.XLaccess mask = access_mask
    if eventCount == 1 and msgs[0].channel != None:
        mask = PyInt_AsUnsignedLongLongMask(msgs[0].channel)
    
    cdef unsigned int i
    for i in range(eventCount):
        pEvents[i].tag = xldefine.e_XLevent_type.XL_TRANSMIT_MSG

        pEvents[i].tagData.msg.id = msgs[i].arbitration_id
        if msgs[i].is_extended_id:
            pEvents[i].tagData.msg.id |= xldefine.XL_CAN_EXT_MSG_ID

        pEvents[i].tagData.msg.flags = 0
        if msgs[i].is_remote_frame:
            pEvents[i].tagData.msg.flags |= xldefine.XL_CAN_MSG_FLAG_REMOTE_FRAME
        
        pEvents[i].tagData.msg.dlc = msgs[i].dlc
        memcpy(pEvents[i].tagData.msg.data, PyByteArray_AsString(msgs[i].data), PyByteArray_GET_SIZE(msgs[i].data))

    cdef xlclass.XLstatus xl_status = xldriver.xlCanTransmit( port_handle, mask, &eventCount, pEvents)

    free(pEvents)

    if xl_status != xldefine.XL_SUCCESS:
        error_string = xldriver.xlGetErrorString(xl_status)
        raise VectorOperationError(xl_status, error_string, "xlCanTransmit")

    return eventCount


def send_can_fd_msg_sequence(
    msgs,
    xlclass.XLportHandle port_handle,
    xlclass.XLaccess access_mask,
) -> int:
    cdef unsigned int msgCnt = len(msgs)
    cdef unsigned int msgCntSent = 0
    cdef xlclass.XLaccess mask = access_mask
    cdef xlclass.XL_CAN_TX_MSG* xl_can_tx_msg = NULL
    cdef unsigned int i = 0
    cdef xlclass.XLstatus xl_status = xldefine.XL_SUCCESS

    cdef xlclass.XLcanTxEvent* pXlCanTxEvt = <xlclass.XLcanTxEvent*> malloc(msgCnt * sizeof(xlclass.XLcanTxEvent))
    if not pXlCanTxEvt:
        raise MemoryError("malloc failed")

    try:
        memset(pXlCanTxEvt, 0, msgCnt * sizeof(xlclass.XLcanTxEvent))

        if msgCnt == 1 and msgs[0].channel != None:
            mask = PyInt_AsUnsignedLongLongMask(msgs[0].channel)

        for i in range(msgCnt):
            pXlCanTxEvt[i].tag = xldefine.XL_CAN_EV_TAG_TX_MSG
            pXlCanTxEvt[i].transId = 0xFFFF

            xl_can_tx_msg = <xlclass.XL_CAN_TX_MSG*> &pXlCanTxEvt[i].canMsg
            xl_can_tx_msg.canId = msgs[i].arbitration_id
            if msgs[i].is_extended_id:
                xl_can_tx_msg.canId |= xldefine.XL_CAN_EXT_MSG_ID

            xl_can_tx_msg.msgFlags = 0
            if msgs[i].is_fd:
                xl_can_tx_msg.msgFlags |= xldefine.XL_CAN_TXMSG_FLAG_EDL
            if msgs[i].bitrate_switch:
                xl_can_tx_msg.msgFlags |= xldefine.XL_CAN_TXMSG_FLAG_BRS
            if msgs[i].is_remote_frame:
                xl_can_tx_msg.msgFlags |= xldefine.XL_CAN_TXMSG_FLAG_RTR

            xl_can_tx_msg.dlc = len_2_dlc(msgs[i].dlc)
            memcpy(xl_can_tx_msg.data, PyByteArray_AsString(msgs[i].data), PyByteArray_GET_SIZE(msgs[i].data))

        xl_status = xldriver.xlCanTransmitEx(port_handle, mask, msgCnt, &msgCntSent, pXlCanTxEvt)

        if xl_status != xldefine.XL_SUCCESS:
            error_string = xldriver.xlGetErrorString(xl_status)
            raise VectorOperationError(xl_status, error_string, "xlCanTransmitEx")

        return msgCntSent

    finally:
        free(pXlCanTxEvt)