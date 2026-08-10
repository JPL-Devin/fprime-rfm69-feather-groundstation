// ======================================================================
// \title  ReferenceDeploymentTopology.cpp
// \brief cpp file containing the topology instantiation code
// ======================================================================
#include <FprimeZephyrReference/ReferenceDeployment/Top/ReferenceDeploymentTopologyAc.hpp>
#include <Fw/Types/MallocAllocator.hpp>

using namespace ReferenceDeployment;

constexpr FwSizeType BASE_RATEGROUP_PERIOD_MS = 1; // 1 kHz

constexpr FwSizeType getRateGroupPeriod(const FwSizeType hz) {
    return 1000 / (hz * BASE_RATEGROUP_PERIOD_MS);
}

Svc::RateGroupDriver::DividerSet rateGroupDivisorsSet{
    {
        {getRateGroupPeriod(1), 0}, // 1 Hz
    }
};

Svc::ActiveRateGroup::ContextArray rateGroup1HzContext{{getRateGroupPeriod(1)}};

void configureTopology() {
    rateGroupDriver.configure(rateGroupDivisorsSet);
    rateGroup1Hz.configure(rateGroup1HzContext);
}

namespace ReferenceDeployment {
void setupTopology(const TopologyState& state) {
    initComponents(state);
    setBaseIds();
    connectComponents();
    regCommands();
    configComponents(state);
    configureTopology();
    loadParameters();
    startTasks(state);

    comDriver.configure(state.uartDevice, state.baudRate);
}

void startRateGroups() {
    timer.configure(BASE_RATEGROUP_PERIOD_MS);
    timer.start();
    while (1) {
        timer.cycle();
    }
}

void stopRateGroups() {
    timer.stop();
}

void teardownTopology(const TopologyState& state) {
    stopTasks(state);
    freeThreads(state);
    tearDownComponents(state);
}
};  // namespace ReferenceDeployment
