
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

let sequence: [SenseHat.Rgb565] =
    [.red, .green, .blue, .brown, .cyan, .magenta, .purple,
     .yellow, .lightGray, .gray, .darkGray, .white, .black]

print("Set all LEDs")
for color in sequence {
    senseHat.set(color: color)
    usleep (1_000_000 / 10)
}

print("Set individual LEDs")
senseHat.set(color: .black)
var delay: useconds_t = 1_000_000 / 20
for color in sequence {
    for x in senseHat.xIndices {
        for y in senseHat.yIndices {
            senseHat.set(x: x, y: y, color: color)
            usleep(delay)
            delay = delay * 999 / 1000
            senseHat.set(x: x, y: y, color: .black)
        }
    }
}
