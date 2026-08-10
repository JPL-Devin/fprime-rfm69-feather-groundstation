module CdhCoreConfig {
    #Base ID for the CdhCore Subtopology, all components are offsets from this base ID
    constant BASE_ID = 0x01000000
    
    module QueueSizes {
        constant cmdDisp     = 5
        constant events      = 10
        constant tlmSend     = 5
        constant $health     = 5
    }
    

    module StackSizes {
        constant cmdDisp     = 2 * 1024 # Must match prj.conf thread stack size
        constant events      = 2 * 1024 # Must match prj.conf thread stack size
        constant tlmSend     = 2 * 1024 # Must match prj.conf thread stack size
    }

    module Priorities {
        constant cmdDisp     = 10
        constant $health     = 11
        constant events      = 12
        constant tlmSend     = 13

    }
}
