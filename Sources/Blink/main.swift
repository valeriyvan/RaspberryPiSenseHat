
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

for color in sequence {
    senseHat.set(color: color)
    usleep (1_000_000 / 10)
}

senseHat.set(color: .black)
for color in sequence {
    for x in senseHat.xIndices {
        for y in senseHat.yIndices {
            senseHat.set(x: x, y: y, color: color)
            usleep (1_000_000 / 1000)
            senseHat.set(x: x, y: y, color: .black)
        }
    }
}
