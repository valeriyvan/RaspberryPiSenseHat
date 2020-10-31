#!/usr/bin/swift

// Blinking LEDs to test grounds.

#if os(Linux)
    import Glibc
#else
    import Foundation
    import Darwin.C
#endif

struct Rgb565 {
    var value: UInt16

    var red: UInt8 {
        get {
            UInt8(truncatingIfNeeded: value >> 11)
        }
        set(newValue) {
            value = (value & 0b0000_0111_1111_1111) | (UInt16(newValue) << 11)
        }
    }

    var green: UInt8 {
        get {
            UInt8(truncatingIfNeeded: (value & 0b0000_0111_1110_0000) >> 5)
        }
        set(newValue) {
            value = (value & 0b1111_1000_0001_1111) | ((UInt16(newValue) & 0b0011_1111) << 5)
        }
    }

    var blue: UInt8 {
        get {
            UInt8(truncatingIfNeeded: value) & 0b1_1111
        }
        set(newValue) {
            value = (value & 0b1111_1111_1110_0000) | (UInt16(newValue) & 0b0001_1111)
        }
    }

    init(value: UInt16) {
        self.value = value
    }

    init(red: UInt8, green: UInt8, blue: UInt8) {
        value = (UInt16(red) << 11) | ((UInt16(green) & 0b0011_1111) << 5) | (UInt16(blue) & 0b0001_1111)
    }

    static var red:   Rgb565 { Rgb565(value: 0b1111_1000_0000_0000) }
    static var green: Rgb565 { Rgb565(value: 0b0000_0111_1110_0000) }
    static var blue:  Rgb565 { Rgb565(value: 0b0000_0000_0001_1111) }
    static var white: Rgb565 { Rgb565(value: 0b1111_1111_1111_1111) }
    static var black: Rgb565 { Rgb565(value: 0b0000_0000_0000_0000) }
}

func openFbDev(_ name: String) -> Int32? {
    let fd = open("/dev/" + name, O_RDWR | O_SYNC)
    guard fd > 0 else { return nil }
    return fd
}

// No idea why it's on fb1 but not on fb0.
// No idea also does it depend on cofiguration or hardcoded to fb1.
// Not idea should be some kind of discovery implemented.
guard let fbfd = openFbDev("fb1" /*RPi-Sense FB"*/) else {
    fatalError("Error: cannot open framebuffer device.")
}

guard let fb = mmap(nil, 128, PROT_READ | PROT_WRITE, MAP_SHARED, fbfd, 0) else {
    fatalError("Can't map framebuffer device.")
}

print("Started")

memset(fb, 0x00, 128)
print("Cleaned screen")

print("Started loop")

let sequence: [Rgb565] = [.red, .black, .green, .black, .blue, .black, .white, .black]

for color in sequence {
    for i in 0..<128/2 {
        fb.advanced(by: i*2).storeBytes(of: color, as: Rgb565.self)
    }
    usleep (1_000_000);
}

print("Completed loop")

memset(fb, 0, 128)
print("Cleaned screen")

munmap(fb, 128)
close(fbfd)
print("Completed")

/*
// WTF with `stride(from: 0, to: UInt16.max, by: 100)`???
// The last value generated is 65400, then crash.
// There's some problem with `stride(from:to:by:)`.
// Found out it's a bug in Swift in both `StrideToIterator` and `StrideThroughIterator`.
// Strange no-one have found this before.
// Affraid, this will be extreemly hard to fix without breaking source stability
// or ABI stability or both.
// Hope today to contribute to Swift validation tests showing a problem.
// And then will look for how to fix bug.

for color in stride(from: 0, to: 65535, by: 100) {
    let color = UInt16(color)
    print("color: ", color)
    for i in 0..<128/2 {
        fb.advanced(by: i*2).storeBytes(of: color, as: UInt16.self)
    }
    usleep (1_000_000 / 100);
}
*/

// MARK: - Darwin / Xcode Support
#if os(OSX) || os(iOS)
private var O_SYNC: CInt { fatalError("Linux only") }
#endif
