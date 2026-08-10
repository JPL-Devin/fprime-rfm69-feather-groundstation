# fprime-rfm69-feather-groundstation

F´ on Zephyr for the Adafruit Feather M0 with RFM69HCW radio.

Based on [fprime-zephyr-reference](https://github.com/fprime-community/fprime-zephyr-reference), targeting `adafruit_feather_m0_basic_proto`.

## Status

Basic Zephyr + F´ deployment **builds** for the Feather M0:

| Region | Used | Size |
|--------|------|------|
| FLASH  | ~114 KiB | 232 KiB code partition |
| RAM    | ~25 KiB | 32 KiB |

The topology is intentionally minimal (rate driver + 1 Hz rate group + UART + time). Full CdhCore/ComCcsds does not fit in 32 KiB SRAM. RFM69 is exposed in device tree and `fprime-sensors` Rfm69 sources are in-tree; the radio manager is not wired into the topology yet.

## Board / radio

| Item | Value |
|------|--------|
| Zephyr board | `adafruit_feather_m0_basic_proto` |
| MCU | ATSAMD21G18A (32 KiB RAM, 256 KiB flash) |
| Radio | HopeRF RFM69HCW on SERCOM4 SPI |
| CS / RST / IRQ | D8 (PA06) / D4 (PA08) / D3 (PA09) |

- Overlay: `boards/adafruit_feather_m0_basic_proto.overlay`
- Binding: `dts/bindings/hoperf,rfm69hcw.yaml`
- DT aliases: `rfm69`, `spi-rfm69`

## Libraries

| Path | Notes |
|------|--------|
| `lib/fprime` | submodule, NASA F´ `devel` |
| `lib/fprime-zephyr` | submodule (local StdAtomic extensions for Cortex-M0+) |
| `lib/fprime-sensors` | Rfm69 sources synced from `../fprime-soak-test-reference/lib/fprime-sensors` |
| `lib/zephyr-workspace` | created by `west update` (gitignored) |

To refresh Rfm69 sources from the soak-test tree:

```sh
rsync -a --delete \
  ../fprime-soak-test-reference/lib/fprime-sensors/fprime-sensors/Rfm69/ \
  lib/fprime-sensors/fprime-sensors/Rfm69/
```

## Setup

```sh
git submodule update --init --recursive
python3 -m venv fprime-venv
source fprime-venv/bin/activate
pip install -r lib/fprime/requirements.txt west
west update
pip install -r requirements.txt   # after zephyr is present
west zephyr-export
export ZEPHYR_SDK_INSTALL_DIR=~/zephyr-sdk-0.17.4   # or your SDK path
```

## Build

```sh
source fprime-venv/bin/activate
export ZEPHYR_SDK_INSTALL_DIR=~/zephyr-sdk-0.17.4
fprime-util generate
fprime-util build
```

Artifacts: `build-fprime-automatic-zephyr/zephyr/zephyr.{elf,bin,hex}`

## Flash

Double-tap reset for the SAM-BA bootloader, then:

```sh
west flash
```
