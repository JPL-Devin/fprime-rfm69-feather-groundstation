module ReferenceDeployment {

  module Default {
    constant QUEUE_SIZE = 2
    # Must not exceed CONFIG_DYNAMIC_THREAD_STACK_SIZE (the pool stack size);
    # this requested size is what bounds the usable stack depth.
    constant STACK_SIZE = 4096
  }

  # The only active component: the 1 kHz rate group task runs the radio poll
  # and the complete uplink/downlink bridging chains.
  # Zephyr priorities are inverted: lower is higher.
  instance rateGroup1KHz: Svc.ActiveRateGroup base id 0x20001000 \
    queue size Default.QUEUE_SIZE \
    stack size Default.STACK_SIZE \
    priority 4

  # Passive scheduling/platform components
  instance chronoTime: Zephyr.ZephyrTime base id 0x20010000
  instance rateGroupDriver: Svc.RateGroupDriver base id 0x20011000
  instance timer: Zephyr.ZephyrRateDriver base id 0x20012000
  instance bridgeUart: Zephyr.ZephyrUartDriver base id 0x20013000
  instance radioSpi: Zephyr.ZephyrSpiDriver base id 0x20015000
  instance radioReset: Zephyr.ZephyrGpioDriver base id 0x20016000
  instance nullPrmDb: Components.NullPrmDb base id 0x20017000

  # Text events to Zephyr console (SERCOM0 / FTDI)
  instance textLogger: Svc.PassiveTextLogger base id 0x20018000

  # Communication components
  instance commsBufferManager: Svc.BufferManager base id 0x20020000
  instance frameAccumulator: Svc.FrameAccumulator base id 0x20021000
  instance bridgeDeframer: Svc.FprimeDeframer base id 0x20022000
  instance bridgeFramer: Svc.FprimeFramer base id 0x20023000
  instance bridgeComStub: Svc.ComStub base id 0x20025000
  instance rfm69Manager: Rfm69.Rfm69Manager base id 0x20027000
}
