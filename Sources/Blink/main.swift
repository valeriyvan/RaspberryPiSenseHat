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

import Foundation
import SenseHat

guard let senseHat = SenseHat() else {
    fatalError("Can't initialise Raspberry Pi Sense Hat")
}

let sequence: [SenseHat.Rgb565] =
    [.red, .green, .blue, .brown, .cyan, .magenta, .purple,
     .yellow, .lightGray, .gray, .darkGray, .white, .black]

print("Show string with animation")
senseHat.show(string: "*** Raspberry Pi Sense Hat ***", speed: 1.0, color: .yellow, background: .black)

print("Set all LEDs with same color")
for color in sequence {
    senseHat.set(color: color)
    usleep (1_000_000 / 10)
}
senseHat.set(color: .black)

print("Set individual LEDs")
var delay: useconds_t = 1_000_000 / 100
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
sleep(1)
senseHat.set(color: .black)

func showChars(range: ClosedRange<Int>) {
    for c in range {
        let c = Character(UnicodeScalar(c)!)
        senseHat.show(character: c, color: .red)
        usleep(1_000_000 / 20)
    }
}

print("Show ascii characters")
senseHat.show(string: "Ascii", speed: 0.1, color: .yellow, background: .black)
showChars(range: 0...127)
print("Show extended latin characters")
senseHat.show(string: "Extended latin", speed: 0.1, color: .yellow, background: .black)
showChars(range: 0x00A0...0x00FF)
print("Show box drawing characters")
senseHat.show(string: "Box drawing", speed: 0.1, color: .yellow, background: .black)
showChars(range: 0x2500...0x257F)
print("Show block elements characters")
senseHat.show(string: "Block elements", speed: 0.1, color: .yellow, background: .black)
showChars(range: 0x2580...0x259F)
print("Show Hiragana characters")
senseHat.show(string: "Hiragana", speed: 0.1, color: .yellow, background: .black)
showChars(range: 0x3040...0x309F)
print("Show greek characters")
senseHat.show(string: "Greek", speed: 0.1, color: .yellow, background: .black)
showChars(range: 0x0390...0x03C9)
print("Show sga characters")
senseHat.show(string: "SGA", speed: 0.1, color: .yellow, background: .black)
showChars(range: 0xE541...0xE55A)

print("Rotating red ^ by 90º counterclockwise 10 full rotations")
senseHat.show(character: Character("^"), color: .red)
var angle = 0.0
for _ in 0..<4*10 {
    angle += Double.pi / 2.0
    senseHat.rotate(angle: angle)
    usleep(1_000_000 / 10)
}

print("Rotating yellow ^ by 90º clockwise 10 full rotations")
senseHat.show(character: Character("^"), color: .yellow)
angle = 0.0
for _ in 0..<4*10 {
    angle -= Double.pi / 2.0
    senseHat.rotate(angle: angle)
    usleep(1_000_000 / 10)
}

print("Rotating blue ^ by 180º counterclockwise 10 full rotations")
senseHat.show(character: Character("^"), color: .blue)
angle = 0.0
for _ in 0..<2*10 {
    angle += Double.pi
    senseHat.rotate(angle: angle)
    usleep(1_000_000 / 10)
}

print("Rotating blue ^ by 270º counterclockwise 10 times")
senseHat.show(character: Character("^"), color: .purple)
angle = 0.0
for _ in 0..<10 {
    angle += 3.0 * Double.pi / 2.0
    senseHat.rotate(angle: angle)
    usleep(1_000_000 / 10)
}

print("End")
