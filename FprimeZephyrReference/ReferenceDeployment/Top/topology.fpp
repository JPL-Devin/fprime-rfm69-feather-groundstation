module ReferenceDeployment {

  enum Ports_RateGroups {
    rateGroup1KHz
  }

  topology ReferenceDeployment {
    instance chronoTime
    instance rateGroup1KHz
    instance rateGroupDriver
    instance timer
    instance bridgeUart
    instance radioSpi
    instance radioReset
    instance nullPrmDb
    instance textLogger
    instance commsBufferManager
    instance frameAccumulator
    instance bridgeDeframer
    instance bridgeFramer
    instance bridgeComStub
    instance rfm69Manager

    param connections instance nullPrmDb
    time connections instance chronoTime
    text event connections instance textLogger

    connections RateGroups {
      timer.CycleOut -> rateGroupDriver.CycleIn
      rateGroupDriver.CycleOut[Ports_RateGroups.rateGroup1KHz] -> rateGroup1KHz.CycleIn

      # Service RF first, then UART. All bridging runs on this one thread.
      # Without ComQueue, Rfm69Manager holds up to two uplink frames when the
      # radio is busy/holdoff and retries from run(); UART TX is staged and
      # drained across schedIn ticks so radio polling is not blocked.
      rateGroup1KHz.RateGroupMemberOut[0] -> rfm69Manager.run
      rateGroup1KHz.RateGroupMemberOut[1] -> bridgeUart.schedIn
    }

    connections Hardware {
   
    }

    connections BufferManagement {

    }

    connections FlightUplink {
      rfm69Manager.spiWriteRead -> radioSpi.SpiWriteRead
      rfm69Manager.resetGpio -> radioReset.gpioWrite

      bridgeUart.allocate -> commsBufferManager.bufferGetCallee
      bridgeUart.deallocate -> commsBufferManager.bufferSendIn
      frameAccumulator.bufferAllocate -> commsBufferManager.bufferGetCallee
      frameAccumulator.bufferDeallocate -> commsBufferManager.bufferSendIn
      bridgeFramer.bufferAllocate -> commsBufferManager.bufferGetCallee
      bridgeFramer.bufferDeallocate -> commsBufferManager.bufferSendIn
      rfm69Manager.allocate -> commsBufferManager.bufferGetCallee
      rfm69Manager.deallocate -> commsBufferManager.bufferSendIn     


      # USB CDC byte stream -> complete F Prime frames -> raw packets to RF.
      bridgeUart.$recv -> bridgeComStub.drvReceiveIn
      bridgeComStub.drvReceiveReturnOut -> bridgeUart.recvReturnIn
      bridgeUart.ready -> bridgeComStub.drvConnected

      bridgeComStub.dataOut -> frameAccumulator.dataIn
      frameAccumulator.dataReturnOut -> bridgeComStub.dataReturnIn
      frameAccumulator.dataOut -> bridgeDeframer.dataIn
      bridgeDeframer.dataReturnOut -> frameAccumulator.dataReturnIn

      bridgeDeframer.dataOut -> rfm69Manager.dataIn
      rfm69Manager.dataReturnOut -> bridgeDeframer.dataReturnIn

      # Raw RF packet -> F Prime frame -> USB CDC, all on the rate-group task.
      rfm69Manager.dataOut -> bridgeFramer.dataIn
      bridgeFramer.dataReturnOut -> rfm69Manager.dataReturnIn
      bridgeFramer.dataOut -> bridgeComStub.dataIn
      bridgeComStub.dataReturnOut -> bridgeFramer.dataReturnIn
      bridgeComStub.comStatusOut -> bridgeFramer.comStatusIn

      bridgeComStub.drvSendOut -> bridgeUart.$send
    }

    connections FlightDownlink {

    }
  }
}
