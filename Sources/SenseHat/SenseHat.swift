
#if os(Linux)
    import Glibc
#else
    import Foundation
    import Darwin.C
#endif

public class SenseHat {

    // Color is represented with `Rgb565` struct.
    // Sense Hat uses two bytes per pixel in frame buffer: red, greed and blue
    // take respectively 5, 6 and 5 bits.
    public struct Rgb565 {
        var value: UInt16
    }

    private var fileDescriptor: Int32
    private var frameBuffer: UnsafeMutableRawPointer

    public init?(device: String = "fb1") {
        // TODO: check for /*RPi-Sense FB"*/
        // No idea why it's on fb1 but not on fb0.
        // No idea also does it depend on cofiguration or hardcoded to fb1.
        // Not idea should be some kind of discovery implemented.

        fileDescriptor = open("/dev/" + device, O_RDWR | O_SYNC)

        guard fileDescriptor > 0 else {
            print("Cannot open framebuffer device.")
            return nil
        }

        guard let fb = mmap(nil, 128, PROT_READ | PROT_WRITE, MAP_SHARED, fileDescriptor, 0) else {
            print("Can't map framebuffer device.")
            return nil
        }

        frameBuffer = fb

        // same as `set(color: .black)` but faster
        memset(frameBuffer, 0, 128)
    }

    deinit {
        if munmap(frameBuffer, 128) != 0 {
            print("Error unmapping framebuffer device.")
        }

        if close(fileDescriptor) != 0 {
            print("Error closing framebuffer device.")
        }
    }

    public func set(color: Rgb565) {
        for i in 0..<128/2 {
            frameBuffer.advanced(by: i*2).storeBytes(of: color, as: Rgb565.self)
        }
    }
}

extension SenseHat.Rgb565 {
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

    init(red: UInt8, green: UInt8, blue: UInt8) {
        value = (UInt16(red) << 11) | ((UInt16(green) & 0b0011_1111) << 5) | (UInt16(blue) & 0b0001_1111)
    }

    public static var red: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b1111_1000_0000_0000) }
    public static var green: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b0000_0111_1110_0000) }
    public static var blue: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b0000_0000_0001_1111) }
    public static var white: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b1111_1111_1111_1111) }
    public static var black: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b0000_0000_0000_0000) }
    public static var brown: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b1001_1011_0010_0110) } // R:0.6, G:0.4, B:0.2
    public static var cyan: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b0000_0111_1111_1111) } // R:0.0, G:1.0, B:1.0
    public static var magenta: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b1111_1000_0001_1111) } // R:1.0, G:0.0, B:1.0
    public static var yellow: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b1111_1111_1110_0000) } // R:1.0, G:1.0, B:0.0
    public static var purple: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b1000_0000_0001_0000) } // R:0.5, G:0.0, B:0.5
    public static var orange: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b1111_1100_0000_0000) } // R:1.0, G:0.5, B:0.0
    public static var gray: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b1000_0100_0001_0000) } // R:0.5, G:0.5, B:0.5
    public static var lightGray: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b1010_1101_0101_0101) } // R:2/3, G:2/3, B:2/3
    public static var darkGray: SenseHat.Rgb565
        { SenseHat.Rgb565(value: 0b0101_0010_1010_1010) } // R:1/3, G:1/3, B:1/3
}

// MARK: - Darwin / Xcode Support
#if os(OSX) || os(iOS)
private var O_SYNC: CInt { fatalError("Linux only") }
#endif
