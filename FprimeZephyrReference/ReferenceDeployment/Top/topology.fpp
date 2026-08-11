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
    instance commsBufferManager
    instance frameAccumulator
    instance bridgeDeframer
    instance bridgeFramer
    instance bridgeComStub
    instance rfm69Manager

    param connections instance nullPrmDb
    time connections instance chronoTime

    connections RateGroups {
      timer.CycleOut -> rateGroupDriver.CycleIn
      rateGroupDriver.CycleOut[Ports_RateGroups.rateGroup1KHz] -> rateGroup1KHz.CycleIn

      # Service RF first, then UART. All bridging runs on this one thread;
      # packets are dropped rather than queued when the radio is busy.
      rateGroup1KHz.RateGroupMemberOut[0] -> rfm69Manager.run
      rateGroup1KHz.RateGroupMemberOut[1] -> bridgeUart.schedIn
    }

    connections Hardware {
      rfm69Manager.spiWriteRead -> radioSpi.SpiWriteRead
      rfm69Manager.resetGpio -> radioReset.gpioWrite
    }

    connections BufferManagement {
      bridgeUart.allocate -> commsBufferManager.bufferGetCallee
      bridgeUart.deallocate -> commsBufferManager.bufferSendIn
      frameAccumulator.bufferAllocate -> commsBufferManager.bufferGetCallee
      frameAccumulator.bufferDeallocate -> commsBufferManager.bufferSendIn
      bridgeFramer.bufferAllocate -> commsBufferManager.bufferGetCallee
      bridgeFramer.bufferDeallocate -> commsBufferManager.bufferSendIn
      rfm69Manager.allocate -> commsBufferManager.bufferGetCallee
      rfm69Manager.deallocate -> commsBufferManager.bufferSendIn
    }

    connections FlightUplink {
      # USB CDC byte stream -> complete F Prime frames -> raw packets to RF.
      bridgeUart.$recv -> bridgeComStub.drvReceiveIn
      bridgeComStub.drvReceiveReturnOut -> bridgeUart.recvReturnIn
      bridgeUart.ready -> bridgeComStub.drvConnected

      bridgeComStub.dataOut -> frameAccumulator.dataIn
      frameAccumulator.dataReturnOut -> bridgeComStub.dataReturnIn
      frameAccumulator.dataOut -> bridgeDeframer.dataIn
      bridgeDeframer.dataReturnOut -> frameAccumulator.dataReturnIn

      # Direct handoff: the manager stages one packet or drops it immediately.
      bridgeDeframer.dataOut -> rfm69Manager.dataIn
      rfm69Manager.dataReturnOut -> bridgeDeframer.dataReturnIn
    }

    connections FlightDownlink {
      # Raw RF packet -> F Prime frame -> USB CDC, all on the rate-group task.
      rfm69Manager.dataOut -> bridgeFramer.dataIn
      bridgeFramer.dataReturnOut -> rfm69Manager.dataReturnIn
      bridgeFramer.dataOut -> bridgeComStub.dataIn
      bridgeComStub.dataReturnOut -> bridgeFramer.dataReturnIn
      # ComStub's status output is unguarded and must stay connected; the
      # framer forwards status only if its own output is connected (it is not).
      bridgeComStub.comStatusOut -> bridgeFramer.comStatusIn

      bridgeComStub.drvSendOut -> bridgeUart.$send
    }
  }
}
