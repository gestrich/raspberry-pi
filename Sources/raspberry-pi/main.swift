import SwiftyGPIO
import Foundation

//Repeat Method
func repeatWithInterval(interval: UInt32, block:@escaping () -> Void ){
    let queue = DispatchQueue.global()
    queue.async {
        block()
        sleep(interval)
        repeatWithInterval(interval: interval, block: block)
    }
}

func mcpReadData(a2dChannel: CUnsignedChar) -> UInt64 {
    print("In MPC read data")
    let spis = SwiftyGPIO.hardwareSPIs(for:.RaspberryPiPlusZero)!
    let spi = spis[0]
    
    var outData = [UInt8]()
    outData.append(1) //  first byte transmitted -> start bit
    outData.append(0b10000000 | ( ((a2dChannel & 7) << 4))); // second byte transmitted -> (SGL/DIF = 1, D2=D1=D0=0)
        
        // Use mask to get ada channel between 0 - 7
        //   00000111
        // & 00000001
        //   00000001
    
        // Move channel to upper 4 bits
        //   00000001
        //<< 4
        //   00010000
    
        // Set leftmost bit to 1 and next 3 bits to ADA channel.
        //   10000000
        // | 00010000
        //   10010000
    outData.append(0); // third byte transmitted....don't care
    
    let inData = spi.sendDataAndRead(outData, frequencyHz: 500_000)
    var a2dVal: UInt64 = 0
    a2dVal = UInt64(inData[1]) << 8 //merge data[1] & data[2] to get result
    a2dVal |=  UInt64(inData[2]);
    return a2dVal
}

func mcpVoltage(outputCode: UInt64, voltageReference: Double) -> Double {
    return Double(outputCode) * voltageReference / 1024.0
}

print("Raspberry Pi Tests Beginning")

var gpOut = GPIO(name: "P17",id: 17)

gpOut.direction = .OUT

//var gpIn = GPIO(name: "P17",id: 17)

//gpIn.direction = .IN

//gpIn.onRaising{
//    gpio in
//    print("Transition to 1, current value:" + String(gpio.value))
//}

var turnOn = false


repeatWithInterval(interval: 3) {
    let currentValue = gpOut.value
    let newValue = (currentValue == 1) ? 0 : 1
    gpOut.value = newValue
    print("Changing the value")
    let voltage = mcpVoltage(outputCode: mcpReadData(a2dChannel: 0), voltageReference: 3.2)
    print("SPI value 0 = \(voltage)")
    
//    let spiVal1 = mcpReadData(a2dChannel: 1)
//    print("SPI value 1 = \(spiVal1)")
//
//    let spiVal2 = mcpReadData(a2dChannel: 2)
//    print("SPI value 2 = \(spiVal2)")
    
}
while true {
    
}
