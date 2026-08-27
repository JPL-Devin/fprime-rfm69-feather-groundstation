"""Nested F prime + CCSDS Space Packet framing plugin for the GDS.

The RFM69 feather groundstation exchanges F prime frames over USB CDC whose
payload is a CCSDS space packet wrapping the actual F prime packet bytes:

    | 0xDEADBEEF | length | CCSDS header (6B) | F prime packet | CRC32 |

Stock GDS framing handles one layer or the other; this plugin handles both.
"""

from __future__ import annotations

import struct

from fprime_gds.common.communication.framing import FramerDeframer, FpFramerDeframer
from fprime_gds.plugin.definitions import gds_plugin_implementation


class SpacePacketFprimeFramerDeframer(FramerDeframer):
    """F prime frame carrying a CCSDS space packet as its payload"""

    CCSDS_HEADER_SIZE = 6
    SEQUENCE_COUNT_MAXIMUM = 16384  # 2^14
    APID = 0

    def __init__(self):
        self.fprime = FpFramerDeframer()
        self.sequence_count = 0

    def frame(self, data):
        """Wrap data in a CCSDS TC space packet, then an F prime frame"""
        header = struct.pack(
            ">HHH",
            (1 << 12) | self.APID,  # version 0, type TC, no secondary header
            0xC000 | self.sequence_count,  # unsegmented
            len(data) - 1,
        )
        self.sequence_count = (self.sequence_count + 1) % self.SEQUENCE_COUNT_MAXIMUM
        return self.fprime.frame(header + data)

    def deframe(self, data, no_copy=False):
        """Deframe an F prime frame and strip the inner CCSDS header"""
        packet, leftover, discarded = self.fprime.deframe(data, no_copy=no_copy)
        if packet is not None:
            packet = packet[self.CCSDS_HEADER_SIZE :]
        return packet, leftover, discarded

    @classmethod
    def get_name(cls):
        return "space-packet-fprime"

    @classmethod
    @gds_plugin_implementation
    def register_framing_plugin(cls):
        return cls
