from typing import Optional, Sequence

from can import Message
from can.interfaces.vector import VectorBus

from can_cvector._abstraction import (
    recv_can,
    recv_canfd,
    send_can_msg_sequence,
    send_can_fd_msg_sequence,
)


class CVectorBus(VectorBus):
    def _recv_can(self) -> Optional[Message]:
        return recv_can(
            self.port_handle.value,
            self._time_offset,
            self.index_to_channel,
            self.handle_can_event,
        )

    def _recv_canfd(self) -> Optional[Message]:
        return recv_canfd(
            self.port_handle.value,
            self._time_offset,
            self.index_to_channel,
            self.handle_canfd_event,
        )

    def _send_can_msg_sequence(self, msgs: Sequence[Message]) -> int:
        return send_can_msg_sequence(
            msgs,
            self.port_handle.value,
            self.mask,
        )

    def _send_can_fd_msg_sequence(self, msgs: Sequence[Message]) -> int:
        return send_can_fd_msg_sequence(
            msgs,
            self.port_handle.value,
            self.mask,
        )
