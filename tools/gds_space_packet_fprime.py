"""GDS framing plugin: CCSDS Space Packets carried inside F Prime frames.

The Feather M0 RFM69 ground-station bridge exchanges F Prime frames over its
USB CDC UART and forwards the deframed payload (a raw CCSDS Space Packet) to
and from the radio. The flight side speaks raw Space Packets over RF, so the
GDS must frame uplink as FpFrame(SpacePacket(fprime-packet)) and deframe the
same structure on downlink.

Load with:
    export FPRIME_GDS_EXTRA_PLUGINS="gds_space_packet_fprime:SpacePacketFprimeFramerDeframer"
    fprime-gds ... --framing-selection space-packet-fprime
(with this file's directory on PYTHONPATH)
"""

from typing import List, Type

from fprime_gds.common.communication.framing import FramerDeframer, FpFramerDeframer
from fprime_gds.common.communication.ccsds.chain import ChainedFramerDeframer
from fprime_gds.common.communication.ccsds.space_packet import SpacePacketFramerDeframer
from fprime_gds.plugin.definitions import gds_plugin, gds_plugin_implementation


@gds_plugin(FramerDeframer)
class SpacePacketFprimeFramerDeframer(ChainedFramerDeframer):
    """Space Packet as the data unit, F Prime framing as the outer layer."""

    @classmethod
    def get_composites(cls) -> List[Type[FramerDeframer]]:
        """Innermost FramerDeframer first."""
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
        """Register this framing plugin"""
        return cls
