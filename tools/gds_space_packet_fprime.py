"""Nested F prime + CCSDS Space Packet framing plugin for the GDS.

The feather groundstation forwards F prime frames over USB CDC whose payload
is a CCSDS space packet wrapping the actual F prime packet bytes. This chains
the stock GDS SpacePacket and FpFramerDeframer implementations to handle both
layers.
"""

from typing import List, Type

from fprime_gds.common.communication.ccsds.chain import ChainedFramerDeframer
from fprime_gds.common.communication.ccsds.space_packet import SpacePacketFramerDeframer
from fprime_gds.common.communication.framing import FpFramerDeframer, FramerDeframer
from fprime_gds.plugin.definitions import gds_plugin_implementation


class SpacePacketFprimeFramerDeframer(ChainedFramerDeframer):
    """F prime frame carrying a CCSDS space packet as its payload"""

    @classmethod
    def get_composites(cls) -> List[Type[FramerDeframer]]:
        """Composite list, innermost first"""
        return [
            SpacePacketFramerDeframer,
            FpFramerDeframer,
        ]

    @classmethod
    def get_name(cls):
        """Name of this implementation provided to CLI"""
        return "space-packet-fprime"

    @classmethod
    @gds_plugin_implementation
    def register_framing_plugin(cls):
        """Register this class as a framing plugin"""
        return cls
