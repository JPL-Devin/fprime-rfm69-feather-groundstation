module ComCcsdsConfig {
    #Base ID for the ComCcsds Subtopology, all components are offsets from this base ID
    constant BASE_ID = 0x02000000
    
    module QueueSizes {
        constant comQueue    = 5
        constant aggregator  = 3
    }
    
    module StackSizes {
        constant comQueue   = 2 * 1024 # Must match prj.conf thread stack size
        constant aggregator = 2 * 1024 # Must match prj.conf thread stack size
    }

    module Priorities {
        constant comQueue   = 5
        constant aggregator = 4
    }

    # Queue configuration constants
    module QueueDepths {
        constant events      = 10
        constant tlm         = 10
        constant file        = 1
    }

    module QueuePriorities {
        constant events      = 0
        constant tlm         = 2
        constant file        = 1
    }

    # Buffer management constants — sized for 32 KiB SRAM
    module BuffMgr {
        constant frameAccumulatorSize  = 512
        constant commsBuffSize         = 512
        constant commsFileBuffSize     = 1
        constant commsBuffCount        = 3
        constant commsFileBuffCount    = 1
        constant commsBuffMgrId        = 200
    }
}
