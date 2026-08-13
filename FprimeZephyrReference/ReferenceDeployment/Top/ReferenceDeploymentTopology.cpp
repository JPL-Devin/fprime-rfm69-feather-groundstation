// ======================================================================
// \title  ReferenceDeploymentTopology.cpp
// \brief  Feather M0 RFM69 ground-station topology configuration
// ======================================================================

#include <FprimeZephyrReference/ReferenceDeployment/Top/ReferenceDeploymentTopologyAc.hpp>
#include <Fw/Types/Assert.hpp>
#include <Fw/Types/MallocAllocator.hpp>
#include <Svc/BufferManager/BufferManagerComponentImpl.hpp>
#include <Svc/FrameAccumulator/FrameDetector/FprimeFrameDetector.hpp>
#include <cstring>

namespace ReferenceDeployment {

namespace {
constexpr FwSizeType BASE_RATE_PERIOD_MS = 1;
constexpr FwSizeType FRAME_ACCUMULATOR_SIZE = 320;
constexpr Fw::Buffer::SizeType UART_FRAGMENT_SIZE = 64;
constexpr Fw::Buffer::SizeType MAX_FPRIME_FRAME_SIZE = 272;

Fw::MallocAllocator allocator;
Svc::FrameDetectors::FprimeFrameDetector fprimeFrameDetector;

Svc::RateGroupDriver::DividerSet rateGroupDivisors{{{1, 0}}};
Svc::ActiveRateGroup::ContextArray rateGroup1KHzContext{{0, 1}};

void configureTopology(const TopologyState& state) {
    rateGroupDriver.configure(rateGroupDivisors);
    rateGroup1KHz.configure(rateGroup1KHzContext);

    // Text events go out SERCOM0 (FTDI) via blocking printk on the caller's
    // thread (the 1 kHz bridge). Printing WARNING_HI RateGroupCycleSlip here
    // feeds a slip storm — keep COMMAND/ACTIVITY for FTDI debug, mute warnings.
    textLogger.setSeverityFilter(Fw::LogSeverity::WARNING_HI, false);
    textLogger.setSeverityFilter(Fw::LogSeverity::WARNING_LO, false);
    textLogger.setSeverityFilter(Fw::LogSeverity::DIAGNOSTIC, false);

    Svc::BufferManagerComponentImpl::BufferBins bins{};
    // Extra UART fragments absorb CDC bursts while the radio holds uplink;
    // extra frame bins cover deframe + pending-TX hold + downlink framer.
    bins.bins[0].bufferSize = UART_FRAGMENT_SIZE;
    bins.bins[0].numBuffers = 4;
    bins.bins[1].bufferSize = MAX_FPRIME_FRAME_SIZE;
    bins.bins[1].numBuffers = 8;
    commsBufferManager.setup(201, 0, allocator, bins);

    frameAccumulator.configure(fprimeFrameDetector, 0, allocator, FRAME_ACCUMULATOR_SIZE);

    radioSpi.configure(state.radioSpiDevice, state.radioSpiConfig);
    FW_ASSERT(radioReset.open(state.radioReset, Zephyr::ZephyrGpioDriver::GpioConfiguration::OUT) ==
              Os::File::Status::OP_OK);
}
}  // namespace

void setupTopology(const TopologyState& state) {
    initComponents(state);
    setBaseIds();
    connectComponents();
    configComponents(state);
    configureTopology(state);
    startTasks(state);

    loadParameters();

    // The bridge ready callback runs the ComStub status chain, so it is
    // announced only after component tasks and radio configuration are ready.
    bridgeUart.configure(state.bridgeUartDevice, state.bridgeBaudRate);
}

void startRateGroups() {
    timer.configure(BASE_RATE_PERIOD_MS);
    timer.start();
    while (true) {
        timer.cycle();
    }
}

void stopRateGroups() {
    timer.stop();
}

void teardownTopology(const TopologyState& state) {
    stopRateGroups();
    stopTasks(state);
    freeThreads(state);
    frameAccumulator.cleanup();
    commsBufferManager.cleanup();
    tearDownComponents(state);
    deinitComponents(state);
}

}  // namespace ReferenceDeployment
