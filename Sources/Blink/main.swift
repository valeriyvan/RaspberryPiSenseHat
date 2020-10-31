
#if os(Linux)
    import Glibc
#else
    import Foundation
    import Darwin.C
#endif

import SenseHat

guard let senseHat = SenseHat() else {
    fatalError("Can't initialise Raspberry Pi Sense Hat")
}

let sequence: [SenseHat.Rgb565] = [.red, .black, .green, .black, .blue, .black, .white, .black]

for color in sequence {
    senseHat.set(color: color)
    sleep (1)
}
