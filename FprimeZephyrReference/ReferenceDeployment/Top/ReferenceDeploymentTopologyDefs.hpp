// ======================================================================
// \title  ReferenceDeploymentTopologyDefs.hpp
// \brief  Ground-station topology state and platform definitions
// ======================================================================
#ifndef REFERENCEDEPLOYMENT_REFERENCEDEPLOYMENTTOPOLOGYDEFS_HPP
#define REFERENCEDEPLOYMENT_REFERENCEDEPLOYMENTTOPOLOGYDEFS_HPP

#include "FprimeZephyrReference/ReferenceDeployment/Top/FppConstantsAc.hpp"
#include <zephyr/device.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/drivers/spi.h>

namespace ReferenceDeployment {

struct TopologyState {
    const struct device* bridgeUartDevice;
    U32 bridgeBaudRate;
    const struct device* radioSpiDevice;
    struct spi_config radioSpiConfig;
    struct gpio_dt_spec radioReset;
};

}  // namespace ReferenceDeployment
#endif
