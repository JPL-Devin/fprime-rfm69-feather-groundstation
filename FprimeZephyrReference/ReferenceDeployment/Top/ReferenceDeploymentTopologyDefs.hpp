// ======================================================================
// \title  ReferenceDeploymentTopologyDefs.hpp
// \brief required header file containing the required definitions for the topology autocoder
// ======================================================================
#ifndef REFERENCEDEPLOYMENT_REFERENCEDEPLOYMENTTOPOLOGYDEFS_HPP
#define REFERENCEDEPLOYMENT_REFERENCEDEPLOYMENTTOPOLOGYDEFS_HPP

#include "FprimeZephyrReference/ReferenceDeployment/Top/FppConstantsAc.hpp"
#include <zephyr/drivers/uart.h>

// Definitions are placed within a namespace named after the deployment
namespace ReferenceDeployment {

/**
 * \brief required type definition to carry state
 */
struct TopologyState {
    const device* uartDevice; //!< UART device for communication
    U32 baudRate;             //!< Baud rate for UART communication
};

}  // namespace ReferenceDeployment
#endif
