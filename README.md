# F´ RFM69 Feather ground station

Resource-constrained F´/Zephyr ground-station firmware for the Adafruit Feather
M0 RFM69HCW. It replaces the Arduino UART-to-radio bridge used with
[`fprime-soak-test-reference`](https://github.com/moisesmata/fprime-soak-test-reference).

The ground station does not interpret flight traffic. It transparently carries
complete CCSDS space packets—including command and file-uplink packets—between
an F´-framed USB CDC stream and native RFM69 packets. The flight deployment is
unchanged.

## Data paths

```text
Uplink:   GDS --F´ frame over USB CDC--> UART driver -> frame accumulator
          -> F´ deframer -> RFM69 manager -> SERCOM4 SPI -> radio (space packet)

Downlink: radio (space packet) -> SERCOM4 SPI -> RFM69 manager -> F´ framer
          -> UART driver --F´ frame over USB CDC--> GDS
```

Everything runs on a single 1 kHz active rate group task: the radio poll first,
then USB receive. There are deliberately no queues; if the radio is busy when
an uplink frame arrives, the frame is dropped. Uplink is therefore best-effort:
confirm commands via downlinked telemetry and resend on loss.

## Radio and timing

| Item | Value |
|---|---|
| Radio | HopeRF RFM69HCW |
| CS / RST / IRQ | D8 (PA06) / D4 (PA08, active high) / D3 (PA09) |
| SPI | SERCOM4, mode 0, MSB first, 1 MHz |
| RF payload | 1–255 bytes, one F´ communication packet per RF packet |
| Default modem profile | 19.2 kb/s, 500 kHz RX bandwidth, 13 dBm |
| Scheduler | 1 kHz active rate group; radio first, USB RX second |

`FW_COM_BUFFER_MAX_SIZE` is 255. The F´ UART frame allocation is 272 bytes to
hold the payload plus framing overhead. For file uplink, keep file data chunks
small enough (about 200 bytes) that the file header and CCSDS packet overhead
stay below the 255-byte RF limit.

## Memory configuration

The ATSAMD21G18A has 32 KiB of RAM, and the stack sizing is deliberate:

- `CONFIG_DYNAMIC_THREAD_STACK_SIZE=4096` and `STACK_SIZE = 4096` in
  `Top/instances.fpp` **must stay in sync**. The FPP constant is what the rate
  group thread actually requests, and it bounds the usable stack depth; the
  Kconfig value sizes the pool slot. One uplink frame nests the entire chain
  (UART receive -> ComStub -> FrameAccumulator -> FprimeDeframer -> radio TX
  staging) on this single stack.
- `CONFIG_MAIN_STACK_SIZE=1536`: topology setup and radio init run on the main
  stack.
- `CONFIG_STACK_SENTINEL=y` turns stack overflows into an immediate fatal
  instead of silent RAM corruption (which historically masqueraded as SPI and
  USB driver failures on this part).

## Setup and build

```sh
git submodule update --init --recursive
python3 -m venv fprime-venv
source fprime-venv/bin/activate
pip install -r lib/fprime/requirements.txt west
west update
pip install -r requirements.txt
west zephyr-export
export ZEPHYR_SDK_INSTALL_DIR="$HOME/zephyr-sdk-0.17.4"

fprime-util generate --force
fprime-util build
```

USB console logging is disabled so binary protocol traffic is never
contaminated. Artifacts are written to `build-fprime-automatic-zephyr/zephyr/`.

## Flash

The SAM-BA bootloader is selected by a double reset. On this host, the verified
command is:

```sh
source fprime-venv/bin/activate
west flash -d build-fprime-automatic-zephyr -r bossac \
  --bossac /Users/moisesm/Library/Arduino15/packages/adafruit/tools/bossac/1.8.0-48-gb176eee/bossac \
  --bossac-port /dev/cu.usbmodem11101 --delay 0
```

After a successful reset, the application enumerates after about three seconds.

## Run the GDS

The Feather exchanges F´ frames whose payload is a CCSDS space packet, so the
GDS needs the framing plugin in `tools/gds_space_packet_fprime.py` (stock GDS
framing does one layer or the other, never nested):

```sh
source fprime-venv/bin/activate
export PYTHONPATH="$PWD/tools:$PYTHONPATH"
export FPRIME_GDS_EXTRA_PLUGINS="gds_space_packet_fprime:SpacePacketFprimeFramerDeframer"

fprime-gds --no-app \
  --dictionary ../fprime-soak-test-reference/build-artifacts/aarch64-linux/FprimeSoakTestReference_FprimeSoakTestReferenceDeployment/dict/FprimeSoakTestReferenceDeploymentTopologyDictionary.json \
  --communication-selection uart \
  --uart-device /dev/cu.usbmodem11101 --uart-baud 115200 \
  --framing-selection space-packet-fprime
```

Use the dictionary produced by the exact flight build. Run only one GDS
instance at a time: multiple instances collide on the shared ZeroMQ IPC
sockets (`/tmp/fprime-server-*`) and silently misroute commands.

If macOS leaves the USB CDC device blocked after a GDS process is interrupted,
unplug/replug or physically reset the Feather before flashing or restarting
the GDS.

## Flight-side HIL launch

```sh
ssh pi@192.168.10.2
cd /home/pi/fprime
setsid nohup ./FprimeSoakTestReference_FprimeSoakTestReferenceDeployment \
  > hil-e2e.log 2>&1 < /dev/null &
```

`setsid` detaches the process so it survives the SSH session. Stop any previous
copy first so two processes do not contend for SPI0 CS1.

Known behavior: if the ground station dies mid-RF-exchange, the flight radio's
transmit path can latch in a failing state (`SendFailed` events throttle after
two, so the console goes quiet). Restarting the flight process re-initializes
its radio. The flight downlinks telemetry only; events are visible in its
console log, not over RF.
