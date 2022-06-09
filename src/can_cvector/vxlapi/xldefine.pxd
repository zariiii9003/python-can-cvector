cdef extern from "Windows.h":
    pass


cdef extern from "vxlapi.h":
    cdef const int XL_SUCCESS
    cdef const int XL_ERR_QUEUE_IS_EMPTY

    # interface version for our events
    cdef const int XL_INTERFACE_VERSION_V2
    cdef const int XL_INTERFACE_VERSION_V3
    cdef const int XL_INTERFACE_VERSION_V4

    # defines for xlGetDriverConfig structures
    cdef const int XL_MAX_LENGTH
    cdef const int XL_CONFIG_MAX_CHANNELS
    cdef const int XL_MAX_NAME_LENGTH

    # Bus types
    cdef const int XL_BUS_TYPE_CAN
    cdef const int XL_BUS_COMPATIBLE_CAN

    cdef const int XL_INVALID_PORTHANDLE

    # XL_CHIP_STATE 
    cdef const int XL_CHIPSTAT_BUSOFF
    cdef const int XL_CHIPSTAT_ERROR_PASSIVE
    cdef const int XL_CHIPSTAT_ERROR_WARNING
    cdef const int XL_CHIPSTAT_ERROR_ACTIVE

    cdef const int MAX_MSG_LEN
    cdef const int XL_CAN_EXT_MSG_ID
    cdef const int XL_CAN_MSG_FLAG_REMOTE_FRAME
    cdef const int XL_CAN_MSG_FLAG_ERROR_FRAME
    cdef const int XL_CAN_MSG_FLAG_TX_COMPLETED

    cdef const int XL_CAN_MAX_DATA_LEN
    cdef const int XL_CANFD_RX_EVENT_HEADER_SIZE
    cdef const int XL_CANFD_MAX_EVENT_SIZE
    
    cdef const int XL_CAN_RXMSG_FLAG_EDL
    cdef const int XL_CAN_RXMSG_FLAG_BRS
    cdef const int XL_CAN_RXMSG_FLAG_ESI
    cdef const int XL_CAN_RXMSG_FLAG_RTR
    cdef const int XL_CAN_RXMSG_FLAG_EF
    cdef const int XL_CAN_RXMSG_FLAG_ARB_LOST
    cdef const int XL_CAN_RXMSG_FLAG_WAKEUP
    cdef const int XL_CAN_RXMSG_FLAG_TE

    cdef const int XL_CAN_TXMSG_FLAG_EDL
    cdef const int XL_CAN_TXMSG_FLAG_BRS
    cdef const int XL_CAN_TXMSG_FLAG_RTR
    cdef const int XL_CAN_TXMSG_FLAG_HIGHPRIO
    cdef const int XL_CAN_TXMSG_FLAG_WAKEUP

    cdef const unsigned short XL_CAN_EV_TAG_RX_OK
    cdef const unsigned short XL_CAN_EV_TAG_TX_OK
    cdef const unsigned short XL_CAN_EV_TAG_TX_MSG
    cdef const unsigned short XL_CAN_EV_TAG_CHIP_STATE

    ctypedef enum e_XLevent_type:
        XL_RECEIVE_MSG,
        XL_CHIP_STATE,
        XL_TIMER,
        XL_TRANSMIT_MSG,
        XL_APPLICATION_NOTIFICATION
