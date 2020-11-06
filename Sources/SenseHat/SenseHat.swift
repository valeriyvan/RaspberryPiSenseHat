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

// TODO: get rid of 128/64/2 magic constants
// TODO: get rid of sleep/usleep

public class SenseHat {

    private var fileDescriptor: Int32
    private var frameBuffer: UnsafeMutableBufferPointer<Rgb565>

    public init?(device: String = "fb1", orientation: Orientation = .up) {
        self.orientation = orientation

        guard device != "__TEST__" else {
            print("SenseHat is in test mode")
            fileDescriptor = -1
            frameBuffer = UnsafeMutableBufferPointer<Rgb565>
                .allocate(capacity: 64)
            frameBuffer.initialize(repeating: .black)
            return
        }

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

        frameBuffer.initialize(repeating: .black)
    }

    deinit {
        if fileDescriptor != -1 { // skip in tests
            if munmap(frameBuffer.baseAddress!, 128) != 0 {
                print("Cannot unmap framebuffer device.")
            }

            if close(fileDescriptor) != 0 {
                print("Cannot close framebuffer device.")
            }
        } else {
            frameBuffer.deallocate()
        }
    }

    public var xIndices: Range<Int> { 0..<8 }
    public var yIndices: Range<Int> { 0..<8 }

    public var orientation: Orientation {
        didSet(oldOrientation) {
            rotate(angle: orientation.rawValue - oldOrientation.rawValue)
        }
    }

    public func set(color: Rgb565) {
        for i in frameBuffer.indices {
            frameBuffer[i] = color
        }
    }

    private func offset(x: Int, y: Int) -> Int {
        precondition(xIndices ~= x && yIndices ~= y)
        switch orientation {
        case .up:
            return y * xIndices.count + x
        case .right:
            return 0
        case .down:
            return 0
        case .left:
            return 0
        }
    }

    subscript(x: Int, y: Int) -> Rgb565 {
        get {
            precondition(xIndices ~= x && yIndices ~= y)
            return frameBuffer[offset(x: x, y: y)]
        }
        set {
            precondition(xIndices ~= x && yIndices ~= y)
            frameBuffer[offset(x: x, y: y)] = newValue
        }
    }

    public func set(x: Int, y: Int, color: Rgb565) {
        precondition(xIndices ~= x && yIndices ~= y)
        frameBuffer[offset(x: x, y: y)] = color
    }

    public func color(x: Int, y: Int) -> Rgb565 {
        precondition(xIndices ~= x && yIndices ~= y)
        return frameBuffer[offset(x: x, y: y)]
    }

    public func data() -> Data {
        precondition(frameBuffer.count == 64)
        return Data(buffer: frameBuffer)
    }

    public func set(data: Data) {
        precondition(data.count == xIndices.count * yIndices.count * MemoryLayout<Rgb565>.stride)
        data.withUnsafeBytes { (bufferPointer: UnsafeRawBufferPointer) -> Void in
            // TODO: should be better way to do this
            let start = bufferPointer.baseAddress!.assumingMemoryBound(to: Rgb565.self)
            let buffer = UnsafeBufferPointer(start: start, count: frameBuffer.count)
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
            // TODO: change this for one of background color
            return Data(count: xIndices.count * yIndices.count * MemoryLayout<Rgb565>.stride)
        }
    }

    private func charData(_ charGenPtr: UnsafeRawBufferPointer, _ i: Int, _ col: Rgb565, _ bgnd: Rgb565) -> Data {
        var data = Data(count: xIndices.count * yIndices.count * MemoryLayout<Rgb565>.stride)
        data.withUnsafeMutableBytes { bufferPointer -> Void in
            for y in yIndices {
                let row = charGenPtr
                    .baseAddress!
                    .advanced(by: i * 8 + y)
                    .assumingMemoryBound(to: UInt8.self)
                    .pointee
                var mask: UInt8 = 1
                for x in xIndices {
                    let c = row & mask == 0 ? bgnd : col
                    bufferPointer
                        .baseAddress!
                        .advanced(by: offset(x: x, y: y) * MemoryLayout<Rgb565>.stride)
                        .storeBytes(of: c, as: Rgb565.self)
                    mask = mask << 1
                }
            }
        }
        return data
    }

    // Shifts frame buffer left adding new raw on the right.
    // TODO: parameter as iterator to avoid array creation?
    public func shiftLeft(addingColomn colomn: [Rgb565]) {
        precondition(colomn.count == yIndices.count)
        for x in xIndices.dropFirst() {
            for y in yIndices {
                let index = offset(x: x, y: y)
                frameBuffer[index - 1] = frameBuffer[index]
            }
        }
        for y in yIndices {
            frameBuffer[offset(x: xIndices.last!, y: y)] = colomn[y]
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
                            .advanced(by: offset(x: x, y: y) * MemoryLayout<Rgb565>.stride)
                            .assumingMemoryBound(to: Rgb565.self)
                            .pointee
                        row.append(c)
                    }
                    return row
                }
                shiftLeft(addingColomn: row)
                usleep(delay)
            }
        }
    }
}

extension SenseHat {
    public enum Orientation: Double {
        case up = 1.5707963267948966 // 𝜋 / 2
        case right = 0.0
        case down = 4.7123889803846897 // 3 * 𝜋 / 2
        case left = 6.2831853071795862 // 𝜋 * 2
    }

    public func rotate(angle: Double) {
        var angle = angle.truncatingRemainder(dividingBy: 2.0 * Double.pi)
        angle = angle < 0.0 ? angle + 2.0 * Double.pi : angle
        // Double.ulpOfOne doesn't work in this case already after 10 full rotations.
        let epsilon = 0.0001
        if fabs(angle - 0.0) < epsilon || fabs(angle - 2.0 * Double.pi) < epsilon {
            // already there
        } else if fabs(angle - Double.pi / 2.0) < epsilon {
            transpose()
            reflectHorizontally()
        } else if fabs(angle - Double.pi) < epsilon {
            reflectHorizontally()
            reflectVertically()
        } else if fabs(angle - 3.0 * Double.pi / 2.0) < epsilon {
            transpose()
            reflectVertically()
        } else {
            fatalError("Rotation to arbitrary angle not implemented.")
        }
    }

    public func transpose() {
        // This in place matrix transpose works only for square matrices
        // https://en.wikipedia.org/wiki/In-place_matrix_transposition#Square_matrices
        precondition(xIndices.count == yIndices.count)
        let N = xIndices.count
        precondition(N > 2)
        for x in 0 ..< N - 1 {
            for y in x + 1 ..< N {
                frameBuffer.swapAt(offset(x: x, y: y), offset(x: y, y: x))
            }
        }
    }

    public func reflectVertically() {
        let N = yIndices.count
        for x in 0 ..< N / 2 {
            for y in yIndices {
                frameBuffer.swapAt(offset(x: x, y: y), offset(x: N - x - 1, y: y))
            }
        }
    }

    public func reflectHorizontally() {
        let N = xIndices.count
        for x in xIndices {
            for y in 0 ..< N / 2 {
                frameBuffer.swapAt(offset(x: x, y: y), offset(x: x, y: N - y - 1))
            }
        }
    }

}

extension SenseHat: CustomDebugStringConvertible {
    public var debugDescription: String {
        var ret = " 01234567\n"
        for y in yIndices {
            ret += String(y)
            for x in xIndices {
                ret += (frameBuffer[offset(x: x, y: y)] == SenseHat.Rgb565.black ? " " : "X")
            }
            ret += String(y) + "\n"
        }
        ret += " 01234567"
        return ret
    }
}

extension SenseHat {

    // Color is represented with `Rgb565` struct.
    // Sense Hat uses two bytes per pixel in frame buffer: red, greed and blue
    // take respectively 5, 6 and 5 bits.
    public struct Rgb565: Equatable {
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
