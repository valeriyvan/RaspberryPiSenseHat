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

for _ in 0..<1000 {
    let h = senseHat.ambientHumidity()!
    let str = String(format: "%.1lf", h.H_rH)
    let msg = "Humidity \(str)% rH "
    print(msg)
    senseHat.show(string: msg, secPerChar: 0.5, color: .yellow, background: .black)
    sleep(10)
}
