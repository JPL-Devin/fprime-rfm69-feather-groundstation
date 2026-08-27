// ======================================================================
// \title  Main.cpp
// \brief  Feather M0 RFM69 ground-station entry point
// ======================================================================

#include <FprimeZephyrReference/ReferenceDeployment/Top/ReferenceDeploymentTopology.hpp>
#include <Os/Os.hpp>
#include <zephyr/kernel.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/drivers/spi.h>
#include <zephyr/drivers/uart.h>
#include <zephyr/sys/reboot.h>

namespace {
const struct device* const BRIDGE_UART = DEVICE_DT_GET(DT_NODELABEL(cdc_acm_uart0));

// UF2 bootloader double-tap magic, written to the last word of SRAM
constexpr uint32_t DBL_TAP_MAGIC = 0xf01669ef;
constexpr uintptr_t DBL_TAP_ADDR =
    CONFIG_SRAM_BASE_ADDRESS + (CONFIG_SRAM_SIZE * 1024) - 4;

K_THREAD_STACK_DEFINE(bootloaderWatchStack, 512);
struct k_thread bootloaderWatchThread;

// Arduino-style 1200-baud touch: reboot into the UF2 bootloader when the
// host opens the CDC ACM port at 1200 baud
void bootloaderWatch(void*, void*, void*) {
    while (true) {
        uint32_t baud = 0;
        if (uart_line_ctrl_get(BRIDGE_UART, UART_LINE_CTRL_BAUD_RATE, &baud) == 0 &&
            baud == 1200) {
            *reinterpret_cast<volatile uint32_t*>(DBL_TAP_ADDR) = DBL_TAP_MAGIC;
            sys_reboot(SYS_REBOOT_COLD);
        }
        k_sleep(K_MSEC(250));
    }
}
// No SPI_LOCK_ON: the radio is the only device on this bus, and the Zephyr
// driver tracks the lock owner by config pointer, which deadlocks when the
// F Prime SPI driver passes per-call copies of the configuration.
const struct spi_dt_spec RADIO_SPI =
    SPI_DT_SPEC_GET(DT_NODELABEL(rfm69), SPI_WORD_SET(8) | SPI_TRANSFER_MSB);
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

    k_thread_create(&bootloaderWatchThread, bootloaderWatchStack,
                    K_THREAD_STACK_SIZEOF(bootloaderWatchStack), bootloaderWatch,
                    nullptr, nullptr, nullptr, K_LOWEST_APPLICATION_THREAD_PRIO, 0,
                    K_NO_WAIT);

    ReferenceDeployment::setupTopology(state);
    // FTDI/SERCOM0 console liveness marker (Pi /dev/ttyUSB0). Keep watching
    // that capture while debugging — GDS does not show ground text events.
    printk("[GS] topology ready; text events on SERCOM0 @ 115200\n");
    ReferenceDeployment::startRateGroups();
    ReferenceDeployment::teardownTopology(state);
    return 0;
}
