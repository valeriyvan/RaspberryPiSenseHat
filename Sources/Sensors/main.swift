/**
 *  SenseHat
 *  Copyright (c) Valeriy Van 2020
 *  MIT license - see LICENSE.md
 */

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import SenseHat

guard let senseHat = SenseHat() else {
    fatalError("Can't initialise Raspberry Pi Sense Hat")
}

print("Started")

for _ in 0..<100 {
    print("Reading humidity sensor")
    if let h = senseHat.humidity() {
        let strH = String(format: "%.1lf", h.H_rH)
        let strT = String(format: "%.1lf", h.T_DegC)
        let msgH = "Humidity \(strH)% rH "
        let msgT = "Temperature \(strT)ºC"
        print(msgH)
        print(msgT)
        senseHat.show(string: msgH, secPerChar: 0.5, color: .yellow, background: .black)
    } else {
        print("Cannot read humidity sensor")
    }
    print("Waiting 1 second\n")
    sleep(1)

    print("Reading pressure sensor")
    if let p = senseHat.pressure() {
        let strP = String(format: "%.1lf", p.P_hPa)
        let strTp = String(format: "%.1lf", p.T_DegC)
        let msgP = "Pressure \(strP) hPa "
        let msgTp = "Temperature \(strTp)ºC"
        print(msgP)
        print(msgTp)
        senseHat.show(string: msgP, secPerChar: 0.5, color: .yellow, background: .black)
    } else {
        print("Cannot read pressure sensor")
    }
    print("Waiting 1 second\n")
    sleep(1)

    print("Reading gyro")
    if let (gx, gy, gz) = senseHat.gyro() {
        let msg = "Gyro gx=\(gx), gy=\(gy), gz=\(gz) "
        print(msg)
        senseHat.show(string: msg, secPerChar: 0.5, color: .yellow, background: .black)
    } else {
        print("Cannot read gyro")
    }
    print("Waiting 1 second\n")
    sleep(1)

    print("Reading accelerometer")
    if let (x, y, z) = senseHat.acce() {
        let msg = "Accelerometer x=\(x), y=\(y), z=\(z) "
        print(msg)
        senseHat.show(string: msg, secPerChar: 0.5, color: .yellow, background: .black)
    } else {
        print("Cannot read gyro")
    }
    print("Waiting 1 second\n")
    sleep(1)
}

print("Ended")
