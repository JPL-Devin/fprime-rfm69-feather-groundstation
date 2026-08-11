# ======================================================================
# Ground-station overrides for F Prime framework constants
# ======================================================================

constant FW_OBJ_SIMPLE_REG_BUFF_SIZE = 64
constant FW_QUEUE_NAME_BUFFER_SIZE = 40
constant FW_TASK_NAME_BUFFER_SIZE = 40
constant FW_COM_BUFFER_MAX_SIZE = 255
constant FW_SM_SIGNAL_BUFFER_MAX_SIZE = 64
constant FW_CMD_ARG_BUFFER_MAX_SIZE = FW_COM_BUFFER_MAX_SIZE - sizeof(FwOpcodeType) - sizeof(FwPacketDescriptorType)
constant FW_CMD_STRING_MAX_SIZE = 40
constant FW_LOG_BUFFER_MAX_SIZE = FW_COM_BUFFER_MAX_SIZE - sizeof(FwEventIdType) - sizeof(FwPacketDescriptorType)
constant FW_LOG_STRING_MAX_SIZE = 120
constant FW_TLM_BUFFER_MAX_SIZE = FW_COM_BUFFER_MAX_SIZE - sizeof(FwChanIdType) - sizeof(FwPacketDescriptorType)
constant FW_STATEMENT_ARG_BUFFER_MAX_SIZE = FW_CMD_ARG_BUFFER_MAX_SIZE
constant FW_TLM_STRING_MAX_SIZE = 40
constant FW_PARAM_BUFFER_MAX_SIZE = FW_COM_BUFFER_MAX_SIZE - sizeof(FwPrmIdType) - sizeof(FwPacketDescriptorType)
constant FW_PARAM_STRING_MAX_SIZE = 40
constant FW_FILE_BUFFER_MAX_SIZE = FW_COM_BUFFER_MAX_SIZE
constant FW_INTERNAL_INTERFACE_STRING_MAX_SIZE = 128
constant FW_LOG_TEXT_BUFFER_SIZE = 128
constant FW_FIXED_LENGTH_STRING_SIZE = 128
constant FW_OBJ_SIMPLE_REG_ENTRIES = 40
constant FW_QUEUE_SIMPLE_QUEUE_ENTRIES = 10
constant FW_ASSERT_COUNT_MAX = 10
constant FW_CONTEXT_DONT_CARE = 0xFF
dictionary constant FW_SERIALIZE_TRUE_VALUE = 0xFF
dictionary constant FW_SERIALIZE_FALSE_VALUE = 0x00
