# ======================================================================
# Ground-station overrides for F Prime architecture constants
# ======================================================================

constant ActiveRateGroupOutputPorts = 2
constant PassiveRateGroupOutputPorts = 1
constant RateGroupDriverRateGroupPorts = 1
constant CmdDispatcherComponentCommandPorts = 1
constant CmdDispatcherSequencePorts = 1
constant SeqDispatcherSequencerPorts = 1
constant CmdSplitterPorts = CmdDispatcherSequencePorts
constant StaticMemoryAllocations = 1
constant HealthPingPorts = 1
constant FileDownCompletePorts = 1
constant ComQueueComPorts = 1
constant ComQueueBufferPorts = 1
constant BufferRepeaterOutputPorts = 1
constant DpManagerNumPorts = 1
constant DpWriterNumProcPorts = 1
constant FileNameStringSize = 100
constant FwAssertTextSize = 128
constant AssertFatalAdapterEventFileSize = FileNameStringSize
constant SequenceArgumentsMaxSize = FW_CMD_ARG_BUFFER_MAX_SIZE - sizeof(FwSizeStoreType) - FileNameStringSize - sizeof(U8) - sizeof(FwSizeType)
