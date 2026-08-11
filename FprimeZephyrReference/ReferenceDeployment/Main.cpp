// ======================================================================
// \title  Main.cpp
// \brief  Feather M0 RFM69 ground-station entry point
// ======================================================================

#include <FprimeZephyrReference/ReferenceDeployment/Top/ReferenceDeploymentTopology.hpp>
#include <Os/Os.hpp>
#include <zephyr/kernel.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/drivers/spi.h>

namespace {
const struct device* const BRIDGE_UART = DEVICE_DT_GET(DT_NODELABEL(cdc_acm_uart0));
const struct spi_dt_spec RADIO_SPI =
    SPI_DT_SPEC_GET(DT_NODELABEL(rfm69), SPI_WORD_SET(8) | SPI_TRANSFER_MSB | SPI_LOCK_ON);
const struct gpio_dt_spec RADIO_RESET =
    GPIO_DT_SPEC_GET(DT_NODELABEL(rfm69), reset_gpios);
}  // namespace

int main(int argc, char* argv[]) {
    // Allow the USB CDC device to enumerate before topology startup.
    k_sleep(K_MSEC(3000));
    Os::init();

    ReferenceDeployment::TopologyState state{};
    state.bridgeUartDevice = BRIDGE_UART;
    state.bridgeBaudRate = 115200;
    state.radioSpiDevice = RADIO_SPI.bus;
    state.radioSpiConfig = RADIO_SPI.config;
    state.radioReset = RADIO_RESET;

    ReferenceDeployment::setupTopology(state);
    ReferenceDeployment::startRateGroups();
    ReferenceDeployment::teardownTopology(state);
    return 0;
}
