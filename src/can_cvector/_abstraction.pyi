from typing import Mapping, Callable, Optional, Sequence

from can import Message
from can.interfaces.vector import xlclass

def recv_can(
    port_handle: int,
    time_offset: float,
    index_to_channel_map: Mapping[int, int],
    handle_can_event_func: Callable[[xlclass.XLevent], None],
) -> Optional[Message]: ...
def recv_canfd(
    port_handle: int,
    time_offset: float,
    index_to_channel_map: Mapping[int, int],
    handle_canfd_event_func: Callable[[xlclass.XLcanRxEvent], None],
) -> Optional[Message]: ...
def send_can_msg_sequence(
    msgs: Sequence[Message],
    port_handle: int,
    access_mask: int,
) -> int: ...
def send_canfd_msg_sequence(
    msgs: Sequence[Message],
    port_handle: int,
    access_mask: int,
) -> int: ...
