import random

from can.interfaces.vector.canlib import get_channel_configs


def find_serial_of_virtual_channel() -> int:
    vcc_list = get_channel_configs()
    for vcc in vcc_list:
        if vcc.serialNumber in (0, 100):
            return vcc.serialNumber
    raise ValueError("Virtual channel not found")


SERIAL = find_serial_of_virtual_channel()
CAN_CHANNEL = 0
CANFD_CHANNEL = 1


def test_module_import():
    import can_cvector


def test_import():
    from can_cvector import CVectorBus


def test_direct_instantiation():
    from can_cvector import CVectorBus

    bus = CVectorBus(serial=SERIAL, channel=CAN_CHANNEL)
    assert isinstance(bus, CVectorBus)


def test_instantiation_via_python_can():
    from can import Bus

    bus = Bus(interface="cvector", serial=SERIAL, channel=CAN_CHANNEL)

    from can_cvector import CVectorBus

    assert isinstance(bus, CVectorBus)


def test_send_can():
    from can import Bus, Message

    vector_bus = Bus(interface="vector", serial=SERIAL, channel=CAN_CHANNEL)
    cvector_bus = Bus(interface="cvector", serial=SERIAL, channel=CAN_CHANNEL)

    msg_sent = Message(
        arbitration_id=127,
        is_extended_id=False,
        is_rx=False,
        data=[random.randint(0, 255) for _ in range(8)],
        dlc=8,
        channel=CAN_CHANNEL,
    )
    cvector_bus.send(msg_sent)
    msg_recv = vector_bus.recv()

    assert msg_sent.equals(msg_recv, timestamp_delta=None, check_direction=False)

    vector_bus.shutdown()
    cvector_bus.shutdown()


def test_send_canfd():
    from can import Bus, Message

    vector_bus = Bus(interface="vector", serial=SERIAL, channel=CANFD_CHANNEL, fd=True)
    cvector_bus = Bus(
        interface="cvector", serial=SERIAL, channel=CANFD_CHANNEL, fd=True
    )

    msg_sent = Message(
        arbitration_id=127,
        is_extended_id=False,
        is_rx=False,
        data=[random.randint(0, 255) for _ in range(8)],
        dlc=8,
        channel=CANFD_CHANNEL,
        is_fd=True,
    )
    cvector_bus.send(msg_sent)
    msg_recv = vector_bus.recv()

    assert msg_sent.equals(msg_recv, timestamp_delta=None, check_direction=False)

    vector_bus.shutdown()
    cvector_bus.shutdown()


def test_recv_can():
    from can import Bus, Message

    vector_bus = Bus(interface="vector", serial=SERIAL, channel=CAN_CHANNEL)
    cvector_bus = Bus(interface="cvector", serial=SERIAL, channel=CAN_CHANNEL)

    msg_sent = Message(
        arbitration_id=127,
        is_extended_id=False,
        is_rx=False,
        data=[random.randint(0, 255) for _ in range(8)],
        dlc=8,
        channel=CAN_CHANNEL,
    )
    vector_bus.send(msg_sent)
    msg_recv = cvector_bus.recv()

    assert msg_sent.equals(msg_recv, timestamp_delta=None, check_direction=False)

    vector_bus.shutdown()
    cvector_bus.shutdown()


def test_recv_canfd():
    from can import Bus, Message

    vector_bus = Bus(interface="vector", serial=SERIAL, channel=CANFD_CHANNEL, fd=True)
    cvector_bus = Bus(
        interface="cvector", serial=SERIAL, channel=CANFD_CHANNEL, fd=True
    )

    msg_sent = Message(
        arbitration_id=127,
        is_extended_id=False,
        is_rx=False,
        data=[random.randint(0, 255) for _ in range(8)],
        dlc=8,
        channel=CANFD_CHANNEL,
        is_fd=True,
    )
    vector_bus.send(msg_sent)
    msg_recv = cvector_bus.recv()

    assert msg_sent.equals(msg_recv, timestamp_delta=None, check_direction=False)

    vector_bus.shutdown()
    cvector_bus.shutdown()
