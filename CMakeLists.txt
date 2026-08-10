####
# This sets up the build system for the 'fprime-rfm69-feather-groundstation' project,
# including components and deployments. In addition, it imports the core F Prime components.
####

cmake_minimum_required(VERSION 3.24.2)
# Only enable Zephyr package when not testing. F Prime unit tests run on Linux typically.
if (NOT BUILD_TESTING)
    find_package(Zephyr HINTS "${CMAKE_CURRENT_LIST_DIR}/lib/zephyr-workspace")
endif()
project(fprime-rfm69-feather-groundstation C CXX)

# Put in an option to force the device back into programable state for automated testing
option(FPRIME_CI_FAILSAFE_ENABLED "Cycle count before a forced reset to programable state" OFF)
if (FPRIME_CI_FAILSAFE_ENABLED)
    set(FPRIME_CI_FAILSAFE_CYCLE_COUNT 6000 CACHE STRING "Cycles before a forced reset")
    add_compile_definitions(FPRIME_CI_FAILSAFE_CYCLE_COUNT=${FPRIME_CI_FAILSAFE_CYCLE_COUNT})
endif()

###
# F' Core Setup
# This includes all of the F prime core components, and imports the make-system.
###
include("${CMAKE_CURRENT_LIST_DIR}/lib/fprime/cmake/FPrime.cmake")
# NOTE: register custom targets between these two lines
fprime_setup_included_code()

# This includes project-wide objects
add_fprime_subdirectory("${CMAKE_CURRENT_LIST_DIR}/FprimeZephyrReference")

# ---------------------------------------------------------------------------
# Exclude unused F´ / library targets from the default Zephyr image.
# ATSAMD21G18A is tightly memory-constrained; Atmel's PORT macro also
# conflicts with Svc::FileDownlink's CallerSource::PORT enumerator.
# ---------------------------------------------------------------------------
set(_FEATHER_EXCLUDE_TARGETS
    Svc_FatalHandler
    fprime-zephyr_Drv_LoRa
    fprime-sensors_Rfm69_Components_Rfm69Manager
    fprime-sensors_Rfm69_Components_Rfm69Sim
    fprime-sensors_Rfm69_Subtopology
    fprime-sensors_Rfm69_Subtopology_Rfm69Config
    # File / DP / CCSDS stacks (not in the minimal topology; PORT macro clash)
    Svc_FileDownlink
    Svc_FileUplink
    Svc_FileManager
    Svc_FileDispatcher
    Svc_FileWorker
    Svc_BufferLogger
    Svc_DpCatalog
    Svc_DpWriter
    Svc_DpManager
    Svc_DpCompressProc
    Svc_ComLogger
    Svc_CmdSequencer
    Svc_FpySequencer
    Svc_ActiveTextLogger
    Svc_BufferAccumulator
    Svc_BufferRepeater
    Svc_ComRetry
    Svc_ComSplitter
    Svc_CmdSplitter
    Svc_Health
    Svc_TlmPacketizer
    Svc_AssertFatalAdapter
    Svc_EventManager
    Svc_CmdDispatcher
    Svc_Version
    Svc_ComQueue
    Svc_ComAggregator
    Svc_ComStub
    Svc_BufferManager
    Svc_FrameAccumulator
    Svc_FprimeRouter
    Svc_FprimeFramer
    Svc_FprimeDeframer
    Svc_PassiveConsoleTextLogger
    Svc_Ccsds_ApidManager
    Svc_Ccsds_SpacePacketDeframer
    Svc_Ccsds_SpacePacketFramer
    Svc_Ccsds_TcDeframer
    Svc_Ccsds_TmFramer
    Svc_Ccsds_CfdpManager
    Svc_Subtopologies_CdhCore
    Svc_Subtopologies_ComCcsds
    Svc_Subtopologies_DataProducts
    Svc_Subtopologies_FileHandling
)
foreach(_tgt IN LISTS _FEATHER_EXCLUDE_TARGETS)
    if (TARGET ${_tgt})
        set_target_properties(${_tgt} PROPERTIES EXCLUDE_FROM_ALL TRUE)
    endif()
endforeach()
