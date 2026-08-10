#!/usr/bin/env bash
# Flash the Pico 2, then immediately start GDS so it catches the boot

set -euo pipefail

cd /Users/moisesm/JPL26/fprime-zephyr-reference
source fprime-venv/bin/activate

PICO=/dev/tty.usbmodem11102
DICT=build-artifacts/zephyr/fprime-zephyr-deployment/dict/ReferenceDeploymentTopologyDictionary.json

echo "[1/2] Flashing Pico 2..."
openocd -f interface/cmsis-dap.cfg -f target/rp2350.cfg \
  -c 'adapter speed 5000' \
  -c init -c 'reset halt' \
  -c 'flash write_image erase ./build-artifacts/zephyr.hex' \
  -c shutdown

echo "[2/2] Starting GDS (board will reset in 3 seconds)..."
sleep 1

# Start GDS in background
fprime-gds \
  --logs /tmp/gds-logs \
  --dictionary "$DICT" \
  --communication-selection uart \
  --uart-device "$PICO" \
  --uart-baud 115200 \
  --uart-skip-port-check \
  --zmq-transport ipc:///tmp/fprime-server-local-in ipc:///tmp/fprime-server-local-out &

GDS_PID=$!
echo "GDS started (PID $GDS_PID)"
sleep 3

echo "Resetting Pico 2 to run..."
openocd -f interface/cmsis-dap.cfg -f target/rp2350.cfg \
  -c 'adapter speed 5000' \
  -c init -c 'reset run' -c shutdown

echo "---"
echo "GDS is running at http://127.0.0.1:5000/"
echo "Press CTRL-C to stop GDS (PID $GDS_PID)"
wait $GDS_PID
