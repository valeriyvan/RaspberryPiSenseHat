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
import Font8x8

public class SenseHat {

    private var fileDescriptor: Int32
    private var frameBuffer: UnsafeMutableBufferPointer<Rgb565>

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
            print("Cannot map framebuffer device.")
            return nil
        }

        let start = fb.assumingMemoryBound(to: Rgb565.self)
        frameBuffer = UnsafeMutableBufferPointer(start: start, count: 64)

        // same as `set(color: .black)` but faster
        memset(frameBuffer.baseAddress!, 0, 128)
    }

    deinit {
        if munmap(frameBuffer.baseAddress!, 128) != 0 {
            print("Cannot unmap framebuffer device.")
        }

        if close(fileDescriptor) != 0 {
            print("Cannot close framebuffer device.")
        }
    }

    public func set(color: Rgb565) {
        for i in frameBuffer.indices {
            frameBuffer[i] = color
        }
    }

    public var xIndices: Range<Int> { 0..<8 }
    public var yIndices: Range<Int> { 0..<8 }

    private func offset(x: Int, y: Int) -> Int {
        precondition(xIndices ~= x && yIndices ~= y)
        return x * yIndices.count + y
    }

    public func set(x: Int, y: Int, color: Rgb565) {
        precondition(xIndices ~= x && yIndices ~= y)
        frameBuffer[x * yIndices.count + y] = color
    }

    public func get(x: Int, y: Int) -> Rgb565 {
        precondition(xIndices ~= x && yIndices ~= y)
        return frameBuffer[x * yIndices.count + y]
    }

    public func getData() -> Data {
        return Data(buffer: frameBuffer)
    }

    public func set(data: Data) {
        precondition(data.count == xIndices.count * yIndices.count * MemoryLayout<Rgb565>.stride)
        data.withUnsafeBytes { (bufferPointer: UnsafeRawBufferPointer) -> Void in
            // TODO: should be better way to do this
            let buffer = UnsafeBufferPointer<Rgb565>(start: bufferPointer.baseAddress!.assumingMemoryBound(to: Rgb565.self), count: frameBuffer.count)
            for i in buffer.indices {
                frameBuffer[i] = buffer[i]
            }
        }
    }

    public func show(character: Character, color c: Rgb565, background b: Rgb565 = .black) {
        set(data: data(character: character, color: c, background: b))
    }

    public func data(character: Character, color c: Rgb565, background b: Rgb565 = .black) -> Data {
        if character.unicodeScalars.count > 1 {
            print("""
                Character \(character) consists of \(character.unicodeScalars.count) unicode scalars.
                Only the first one will be shown.
                """
            )
        }
        let unicodeCodePoint = character.unicodeScalars.first!.value
        switch unicodeCodePoint {
        case 0x0000...0x007F:
            let i = Int(unicodeCodePoint)
            return withUnsafeBytes(of: &font8x8_basic) { charData($0, i, c, b) }
        case 0x00A0...0x00FF:
            let i = Int(unicodeCodePoint) - 0x00A0
            return withUnsafeBytes(of: &font8x8_ext_latin) { charData($0, i, c, b) }
        case 0x2500...0x257F:
            let i = Int(unicodeCodePoint) - 0x2500
            return withUnsafeBytes(of: &font8x8_box) { charData($0, i, c, b) }
        case 0x2580...0x259F:
            let i = Int(unicodeCodePoint) - 0x2580
            return withUnsafeBytes(of: &font8x8_block) { charData($0, i, c, b) }
        case 0x3040...0x309F:
            let i = Int(unicodeCodePoint) - 0x3040
            return withUnsafeBytes(of: &font8x8_hiragana) { charData($0, i, c, b) }
        case 0x0390...0x03C9:
            let i = Int(unicodeCodePoint) - 0x0390
            return withUnsafeBytes(of: &font8x8_greek) { charData($0, i, c, b) }
        case 0xE541...0xE55A:
            let i = Int(unicodeCodePoint) - 0xE541
            return withUnsafeBytes(of: &font8x8_sga) { charData($0, i, c, b) }
        default:
            return Data(count: 64 * 2) // TODO: change this for one of background color
        }
    }

    private func charData(_ charGenPtr: UnsafeRawBufferPointer, _ i: Int, _ col: Rgb565, _ bgnd: Rgb565) -> Data {
        var data = Data(count: 64 * 2)
        data.withUnsafeMutableBytes { bufferPointer -> Void in
            for y in yIndices {
                let raw = charGenPtr
                    .baseAddress!
                    .advanced(by: i * 8 + y)
                    .assumingMemoryBound(to: UInt8.self)
                    .pointee
                var mask: UInt8 = 1
                for x in xIndices {
                    let c = raw & mask == 0 ? bgnd : col
                    bufferPointer
                        .baseAddress!
                        .advanced(by: (y * xIndices.count + x) * 2)
                        .storeBytes(of: c, as: Rgb565.self)
                    mask = mask << 1
                }
            }
        }
        return data
    }

    // Shifts frame buffer left adding new raw on the left.
    // TODO: parameter iterator?
    private func shift(row: [Rgb565]) {
        precondition(row.count == yIndices.count)
        for x in xIndices.dropFirst() {
            for y in yIndices {
                let index = y * xIndices.count + x
                frameBuffer[index - 1] = frameBuffer[index]
            }
        }
        for y in yIndices {
            frameBuffer[y * xIndices.count + xIndices.last!] = row[y]
        }
    }

    public func show(string: String, speed: Double = 0.1, color: Rgb565, background: Rgb565 = .black) {
        let delay: useconds_t = useconds_t(Double(1_000_000) * speed / Double(xIndices.count))
        for c in string {
            let d = data(character: c, color: color, background: background)
            for x in xIndices {
                let row = d.withUnsafeBytes { dPtr -> [Rgb565] in
                    var row = [Rgb565]()
                    row.reserveCapacity(yIndices.count)
                    for y in yIndices {
                        let c = dPtr
                            .baseAddress!
                            .advanced(by: (y * xIndices.count + x) * 2)
                            .assumingMemoryBound(to: Rgb565.self)
                            .pointee
                        row.append(c)
                    }
                    return row
                }
                shift(row: row)
                usleep(delay)
            }
        }
    }
}

extension SenseHat {

    // Color is represented with `Rgb565` struct.
    // Sense Hat uses two bytes per pixel in frame buffer: red, greed and blue
    // take respectively 5, 6 and 5 bits.
    public struct Rgb565 {
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

        // Black
        init() {
            self.init(value: 0)
        }

        init(red: UInt8, green: UInt8, blue: UInt8) {
            value = (UInt16(red) << 11) | ((UInt16(green) & 0b0011_1111) << 5) | (UInt16(blue) & 0b0001_1111)
        }

        public static var red: Rgb565
            { Rgb565(value: 0b1111_1000_0000_0000) }
        public static var green: Rgb565
            { Rgb565(value: 0b0000_0111_1110_0000) }
        public static var blue: Rgb565
            { Rgb565(value: 0b0000_0000_0001_1111) }
        public static var white: Rgb565
            { Rgb565(value: 0b1111_1111_1111_1111) }
        public static var black: Rgb565
            { Rgb565(value: 0b0000_0000_0000_0000) }
        public static var brown: Rgb565
            { Rgb565(value: 0b1001_1011_0010_0110) } // R:0.6, G:0.4, B:0.2
        public static var cyan: Rgb565
            { Rgb565(value: 0b0000_0111_1111_1111) } // R:0.0, G:1.0, B:1.0
        public static var magenta: Rgb565
            { Rgb565(value: 0b1111_1000_0001_1111) } // R:1.0, G:0.0, B:1.0
        public static var yellow: Rgb565
            { Rgb565(value: 0b1111_1111_1110_0000) } // R:1.0, G:1.0, B:0.0
        public static var purple: Rgb565
            { Rgb565(value: 0b1000_0000_0001_0000) } // R:0.5, G:0.0, B:0.5
        public static var orange: Rgb565
            { Rgb565(value: 0b1111_1100_0000_0000) } // R:1.0, G:0.5, B:0.0
        public static var gray: Rgb565
            { Rgb565(value: 0b1000_0100_0001_0000) } // R:0.5, G:0.5, B:0.5
        public static var lightGray: Rgb565
            { Rgb565(value: 0b1010_1101_0101_0101) } // R:2/3, G:2/3, B:2/3
        public static var darkGray: Rgb565
            { Rgb565(value: 0b0101_0010_1010_1010) } // R:1/3, G:1/3, B:1/3
    }

}

// MARK: - Darwin / Xcode Support
#if os(OSX) || os(iOS)
private var O_SYNC: CInt { fatalError("Linux only") }
#endif
