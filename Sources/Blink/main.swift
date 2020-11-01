#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Foundation
import SenseHat

guard let senseHat = SenseHat() else {
    fatalError("Can't initialise Raspberry Pi Sense Hat")
}

let sequence: [SenseHat.Rgb565] =
    [.red, .green, .blue, .brown, .cyan, .magenta, .purple,
     .yellow, .lightGray, .gray, .darkGray, .white, .black]

print("Set all LEDs with same color")
for color in sequence {
    senseHat.set(color: color)
    usleep (1_000_000 / 10)
}
senseHat.set(color: .black)

print("Set individual LEDs")
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
senseHat.set(color: .black)

print("Set all LEDs with Data")
var data = Data(count: 64 * 2)
data.withUnsafeMutableBytes { (bufferPointer: UnsafeMutableRawBufferPointer) -> Void in
    for x in senseHat.xIndices {
        bufferPointer
            .baseAddress!
            .advanced(by: x * senseHat.xIndices.count * 2)
            .assumingMemoryBound(to: SenseHat.Rgb565.self)
            .assign(repeating: sequence[x], count: senseHat.yIndices.count)
    }
}
senseHat.set(data: data)

print("End")
