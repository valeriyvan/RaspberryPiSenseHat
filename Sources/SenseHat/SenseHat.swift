/**
 *  SenseHat
 *  Copyright (c) Valeriy Van 2020
 *  MIT license - see LICENSE.md
 */

#if os(Linux)
    import Glibc
#elseif os(OSX) || os(iOS)
    import Darwin.C
#endif

import Foundation
import Font8x8

// TODO: get rid of 128/64/2 magic constants
// TODO: get rid of sleep/usleep

// MARK: SenseHat

public class SenseHat {

    private var fileDescriptor: Int32
    private var frameBufferPointer: UnsafeMutableBufferPointer<Rgb565>

//    private var joystickCallback: JoystickCallback?
//    private var joystickCallbackDispatchQueue: DispatchQueue?
//    private var joystickTimer: DispatchSourceTimer?
    private var joystickFileDescriptor: Int32 = -1
    private let sync: ((UnsafeMutableBufferPointer<Rgb565>)->Void)?

    /// Creates `SenseHat` object representing Raspberry Pi Sense Hat shield.
    /// Tries to open frame buffer file on location `/dev/XXX` where `XXX` is
    /// provided with parameter `frameBuffer`. Result of initializer is `nil`
    /// if openning frame buffer file fails.
    ///
    /// It doesn't make sense to create several instances of `SenseHat` class
    /// openning same frame buffer file. Result of doing this undefined.
    ///
    /// - Parameters:
    ///   - frameBufferDevice: Name of frame buffer device file. Usually it's
    ///  `"/dev/fb0"` or `"/dev/fb1"` depending on setup. Use `nil` to discover
    ///  Sense Hat's frame buffer device but its name `"RPi-Sense FB"`.
    ///   - orientation: Default orientation of LED matrix.
    public init?(frameBufferDevice: String? = nil, orientation: Orientation = .up, sync: ((UnsafeMutableBufferPointer<Rgb565>)->Void)? = nil) {
        self.orientation = orientation
        self.sync = sync

        guard let testDevice = frameBufferDevice, testDevice != "__TEST__" else {
            print("SenseHat is in test mode")
            fileDescriptor = -1
            frameBufferPointer = UnsafeMutableBufferPointer<Rgb565>
                .allocate(capacity: 64)
            frameBufferPointer.initialize(repeating: .black)
            return
        }

        guard let device = SenseHat.frameBufferDevice() else {
            print("Cannot discover frame buffer device with name RPi-Sense FB")
            return nil
        }

        fileDescriptor = open(device, O_RDWR | O_SYNC)
        guard fileDescriptor >= 0 else {
            print("Error \(errno) openning framebuffer device.")
            return nil
        }

        guard let fb = mmap(nil, 128, PROT_READ | PROT_WRITE, MAP_SHARED, fileDescriptor, 0) else {
            print("Cannot map framebuffer device.")
            return nil
        }

        let start = fb.assumingMemoryBound(to: Rgb565.self)
        frameBufferPointer = UnsafeMutableBufferPointer(start: start, count: 64)

        frameBufferPointer.initialize(repeating: .black)
    }

    deinit {
        if fileDescriptor != -1 { // skip in tests
            if munmap(frameBufferPointer.baseAddress!, 128) != 0 {
                print("Cannot unmap framebuffer device.")
            }

            if close(fileDescriptor) != 0 {
                print("Error \(errno) closing framebuffer device.")
            }
        } else {
            frameBufferPointer.deallocate()
        }

//        joystickTimer?.suspend()
//        joystickTimer = nil
//        joystickCallback = nil
//        joystickCallbackDispatchQueue = nil
        if joystickFileDescriptor != -1 {
            if close(joystickFileDescriptor) != 0 {
                print("Error \(errno) closing joystick device file")
            }
        }

    }

    public var indices: Range<Int> { 0..<8 }

    private static func frameBufferDevice() -> String? {
        #if os(Linux)
        // FileManager isn't available in WASM.
        // Doesn't make any sense in browser anyway.
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
        let directoryEnumerator = FileManager.default.enumerator(at: URL(string: "/sys/class/graphics/")!, includingPropertiesForKeys: Array(resourceKeys), options: [.skipsSubdirectoryDescendants], errorHandler: nil)!
        for case let fileURL as URL in directoryEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                  let isDirectory = resourceValues.isDirectory,
                  let device = resourceValues.name
                else {
                    continue
            }
            guard !isDirectory else { continue }
            guard device.hasPrefix("fb") else { continue }
            let name = fileURL.appendingPathComponent("name")
            guard let deviceName = try? String(contentsOf: name),
                  deviceName.trimmingCharacters(in: .whitespacesAndNewlines) == "RPi-Sense FB"
                else { continue }
            return "/dev/" + device
        }
        #endif
        return nil
    }

    // Changes default orientation of LED matrix. Current display of LED matrix
    // is rotated according to new orientation.
    public var orientation: Orientation {
        didSet(oldOrientation) {
            rotate(angle: orientation.rawValue - oldOrientation.rawValue)
        }
    }

    /// Sets all LEDs of matrix to color `color`.
    ///
    /// - Parameter color: Color
    public func set(color: Rgb565) {
        for i in frameBufferPointer.indices {
            frameBufferPointer[i] = color
        }
        sync?(frameBufferPointer)
    }

    /// Returns offset of `Rgb565` value in frame buffer of pixel with
    /// coordinates `x` and `y` with respect of `orientation` property.
    ///
    /// - Parameters:
    ///   - x: Coordinate x in range `xIndices`.
    ///   - y: Coordinate y in range `yIndices`.
    private func offset(x: Int, y: Int) -> Int {
        return offset(x: x, y: y, orientation: orientation)
    }

    private func offset(x: Int, y: Int, orientation: Orientation) -> Int {
        precondition(indices ~= x && indices ~= y)
        switch orientation {
        case .up:
            return y * indices.count + x
        case .right:
            return x * indices.count + indices.count - y - 1
        case .down:
            return (indices.count - y - 1) * indices.count + (indices.count - x - 1)
        case .left:
            return (indices.count  - x - 1) * indices.count + y
        }
    }

    /// Accesses pixel with coordinates `x` and `y` allowing set or get its color.
    /// Coordinates respect `orientation` property.
    ///
    /// - Parameters:
    ///   - x: Coordinate x.
    ///   - y: Coordinate y.
    /// - Precondition: `x` and `y` belong to range `0..<8`.
    public subscript(x: Int, y: Int) -> Rgb565 {
        get {
            precondition(indices ~= x && indices ~= y)
            return frameBufferPointer[offset(x: x, y: y)]
        }
        set {
            precondition(indices ~= x && indices ~= y)
            frameBufferPointer[offset(x: x, y: y)] = newValue
            sync?(frameBufferPointer)
        }
    }

    /// Sets pixel with coordinates `x` and `y` to a new color `color`.
    /// Coordinates respect `orientation` property.
    ///
    /// - Parameters:
    ///   - x: Coordinate x.
    ///   - y: Coordinate y.
    ///   - color: Color.
    /// - Precondition: `x` and `y` belong to range `0..<8`.
    public func set(x: Int, y: Int, color: Rgb565) {
        precondition(indices ~= x && indices ~= y)
        frameBufferPointer[offset(x: x, y: y)] = color
        sync?(frameBufferPointer)
    }

    /// Returns color of pixel with coordinates `x` and `y`.
    /// Coordinates respect `orientation` property.
    ///
    /// - Parameters:
    ///   - x: Coordinate x.
    ///   - y: Coordinate y.
    /// - Returns: Color.
    /// - Precondition: `x` and `y` belong to range `0..<8`.
    public func color(x: Int, y: Int) -> Rgb565 {
        precondition(indices ~= x && indices ~= y)
        return frameBufferPointer[offset(x: x, y: y)]
    }

    /// Returns color of pixel with coordinates `x` and `y`, disregarding
    /// `orientation` property.
    ///
    /// - Parameters:
    ///   - x: Coordinate x.
    ///   - y: Coordinate y.
    /// - Returns: Color.
    /// - Precondition: `x` and `y` belong to range `0..<8`.
    public func color(absoluteX x: Int, absoluteY y: Int) -> Rgb565 {
        return frameBufferPointer[offset(x: x, y: y, orientation: .up)]
    }

    /// Returns opaque instance of `Data` struct representing colors of all
    /// pixels of LED matrix.
    ///
    /// Returns: Instance of `Data` struct.
    public func data() -> Data {
        precondition(frameBufferPointer.count == indices.count * indices.count)
        return Data(buffer: frameBufferPointer)
    }

    /// Sets all LEDs of matrix to colors according to state when `Data` was read
    /// with call of `data()` method. `orientation` when reading and setting data
    /// should match.
    ///
    /// - Parameter data: Instance of `Data` struct returned from `data()` method.
    public func set(data: Data) {
        precondition(data.count == indices.count * indices.count * MemoryLayout<Rgb565>.stride)
        data.withUnsafeBytes { (bufferPointer: UnsafeRawBufferPointer) -> Void in
            // TODO: should be better way to do this
            let start = bufferPointer.baseAddress!.assumingMemoryBound(to: Rgb565.self)
            let buffer = UnsafeBufferPointer(start: start, count: frameBufferPointer.count)
            for i in buffer.indices {
                frameBufferPointer[i] = buffer[i]
            }
        }
        sync?(frameBufferPointer)
    }

    /// Draws `character` on LED matrix using `color` and `background` as foreground
    /// and backround with respect of `orientation` property.
    ///
    /// - Parameters:
    ///   - character: `Character` to be shown on matrix.
    ///   - color: Boreground color.
    ///   - background: Background color.
    public func show(character: Character, color c: Rgb565, background b: Rgb565 = .black) {
        set(data: data(character: character, color: c, background: b))
    }

    /// Returns `Data` struct representing `character` drawn with `color` and
    /// `background` as foreground and background. Returned value is opaque,
    /// respects `orientation` and could be used as parameter in a call
    /// of `set(data:)` method.
    ///
    /// - Parameters:
    ///   - character: `Character` to be shown on matrix.
    ///   - color: Boreground color.
    ///   - background: Background color.
    /// - Returns: Instance of `Data` struct.
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
            let background =
                [Rgb565](repeating: b, count: indices.count * indices.count)
                    .withUnsafeBytes {
                        Data($0)
                    }
            return background
        }
    }

    private func charData(_ charGenPtr: UnsafeRawBufferPointer, _ i: Int, _ col: Rgb565, _ bgnd: Rgb565) -> Data {
        var data = Data(count: indices.count * indices.count * MemoryLayout<Rgb565>.stride)
        data.withUnsafeMutableBytes { bufferPointer -> Void in
            for y in indices {
                let row = charGenPtr
                    .baseAddress!
                    .advanced(by: i * 8 + y)
                    .assumingMemoryBound(to: UInt8.self)
                    .pointee
                var mask: UInt8 = 1
                for x in indices {
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

    /// Shifts frame buffer left adding new column on the right.
    /// TODO: parameter as iterator to avoid array creation?
    ///
    /// - Parameter column: Colors of column of LEDs which should appear on the right.
    /// - Precondition: `column` should have exact 8 elements.
    public func shiftLeft(addingColumn column: [Rgb565]) {
        precondition(column.count == indices.count)
        for x in indices.dropFirst() {
            for y in indices {
                let indexFrom = offset(x: x, y: y)
                let indexTo = offset(x: x - 1, y: y)
                frameBufferPointer[indexTo] = frameBufferPointer[indexFrom]
            }
        }
        for y in indices {
            frameBufferPointer[offset(x: indices.last!, y: y)] = column[y]
        }
        let frameBufferCopy = UnsafeMutableBufferPointer<Rgb565>.allocate(capacity: 8*8)
        _ = frameBufferCopy.initialize(from: frameBufferPointer)
        sync?(frameBufferCopy)
        frameBufferCopy.deallocate()
    }

    /// Shows `string` in LED matrix with animation from right to left with
    /// respect of `orientation`. Each character takes `secPerChar` seconds from
    /// appearing from right edge and before disappearing on left.
    ///
    /// - Parameters:
    ///   - string: String.
    ///   - secPerChar: Time for one character to slide from one edge of matric
    ///     to another.
    ///   - color: Forground color of string.
    ///   - background: Background color of string.
    ///   - usleep: function for delaying execution. Workaround for WASM where
    ///     both usleep and sleep have runtime error.
    public func show(string: String, secPerChar temp: Double = 0.1, color: Rgb565, background: Rgb565 = .black, usleep _sleep: ((useconds_t)->Void) = standardUsleep) {
        let delay: useconds_t = useconds_t(Double(1_000_000) * temp / Double(indices.count))
        print(delay)
        for c in string {
            let d = data(character: c, color: color, background: background)
            for x in indices {
                let row = d.withUnsafeBytes { dPtr -> [Rgb565] in
                    var row = [Rgb565]()
                    row.reserveCapacity(indices.count)
                    for y in indices {
                        let c = dPtr
                            .baseAddress!
                            .advanced(by: offset(x: x, y: y) * MemoryLayout<Rgb565>.stride)
                            .assumingMemoryBound(to: Rgb565.self)
                            .pointee
                        row.append(c)
                    }
                    return row
                }
                shiftLeft(addingColumn: row)
                _sleep(delay)
            }
        }
    }

    public func iterateColumns(string: String, color: Rgb565, background: Rgb565 = .black) -> ()->Bool {
        let it = ColumnsIterator(
            string: string,
            charGenerator: { [unowned self] c in
                var data = self.data(character: c, color: color, background: background)
                switch self.orientation {
                case .up:
                    ()
                case .right:
                    fatalError("Rotation \(self.orientation) is not implemented yet")
                case .down:
                    fatalError("Rotation \(self.orientation) is not implemented yet")
                case .left:
                    data.rotate(angle: -Double.pi / 2.0, elementSize: MemoryLayout<Rgb565>.stride)
                }
                return data
            },
            xCount: indices.count,
            yCount: indices.count
        )
        return { [weak self] in
            guard let strongSelf = self else { return false }
            guard let column = it.next() else { return false }
            strongSelf.shiftLeft(addingColumn: column)
            return true
        }
    }
}

// Public to make it testable
public class ColumnsIterator: IteratorProtocol {
    private let string: String
    private var stringIterator: String.Iterator
    private var x = 0
    private var charData: Data? // Pixel data of character string[index]
    private let charGenerator: (Character) -> Data
    private let xCount: Int
    private let yCount: Int
    private var completed = false

    init(string: String, charGenerator: @escaping (Character) -> Data, xCount: Int, yCount: Int) {
        self.string = string
        self.stringIterator = string.makeIterator()
        self.charGenerator = charGenerator
        self.xCount = xCount
        self.yCount = yCount
    }

    public func next() -> [SenseHat.Rgb565]? {
        guard !completed else { return nil }
        if charData == nil {
            guard let char = stringIterator.next() else { return nil }
            assert(x == 0)
            charData = charGenerator(char)
        }
        defer {
            if x == xCount - 1 {
                x = 0
                if let char = stringIterator.next() {
                    charData = charGenerator(char)
                } else {
                    charData = nil
                    completed = true
                }
            } else {
                x += 1
            }
        }
        return charData!.withUnsafeBytes { dPtr -> [SenseHat.Rgb565] in
            var row = [SenseHat.Rgb565]()
            row.reserveCapacity(yCount)
            for y in 0..<yCount {
                let c = dPtr
                    .baseAddress!
                    .advanced(by: (y * xCount + x) * MemoryLayout<SenseHat.Rgb565>.stride)
                    .assumingMemoryBound(to: SenseHat.Rgb565.self)
                    .pointee
                row.append(c)
            }
            return row
        }
    }
}

// MARK: Joystick

extension SenseHat {
    public enum JoystickButtonAction: Int32 {
        case press = 1, release = 0, `repeat` = 2
    }

    public enum JoystickButton: UInt16 {
        case up = 103, right = 106, down = 108, left = 105, enter = 28
    }

    public typealias JoystickCallback = (JoystickButton, JoystickButtonAction) -> Void

    // Registers callback for joystick actions.
    //
    /// - Parameters:
    ///   - device: Name of device file.
    ///   - joystickCallback: Callback function.
    ///   - joystickCallbackDispatchQueue: Dispatch queue for callback.
    /// - Returns: True if openning joystick device succeeded, false otherwise.
    ///
    /// TODO: implement device file lookup
//    public func register(device: String = "event0", joystickCallback: @escaping JoystickCallback, joystickCallbackDispatchQueue: DispatchQueue = .global(qos: .background)) -> Bool {
//        self.joystickCallback = joystickCallback
//        self.joystickCallbackDispatchQueue = joystickCallbackDispatchQueue
//        let device = "/dev/input/" + device
//        joystickFileDescriptor = open(device, O_RDONLY | O_NONBLOCK | O_SYNC)
//        guard joystickFileDescriptor > 0 else {
//            print("Cannot open \(device)")
//            return false
//        }
//        startPollingJoystickDeviceFile()
//        return true
//    }

//    private func startPollingJoystickDeviceFile() {
//        let timer = DispatchSource.makeTimerSource(flags: [], queue: .global(qos: .userInteractive))
//        timer.schedule(deadline: .now(), repeating: .milliseconds(10), leeway: .milliseconds(10)) // TODO: parametrize
//        timer.setEventHandler(handler: { [weak self] in
//            guard let strongSelf = self else { return }
//            strongSelf.pollJoystickDeviceFile()
//        })
//        joystickTimer = timer
//        timer.resume()
//    }

    // Could be found, e.g. here https://github.com/spotify/linux/blob/master/include/linux/input.h
    private struct input_type {
        let time: timeval
        let type: UInt16
        let code: UInt16
        let value: Int32
        init() {
            time = timeval()
            type = 0
            code = 0
            value = 0
        }
    }

//    private func pollJoystickDeviceFile() {
//        var pfd = pollfd(fd: joystickFileDescriptor, events: Int16(truncatingIfNeeded:POLLIN), revents: 0)
//        let ready = poll(&pfd, 1, -1 /* timeout in ms TODO: this should correspond with timer somehow */)
//        guard ready > -1 else {
//            print("Joystick device file is not ready")
//            return
//        }
//
//        guard pfd.events > 0 else { /* returned events */
//            print("No events read from Joystick device file")
//            return
//        }
//        let inputSize = MemoryLayout<input_type>.stride // TODO: does it make sense?
//        var inputArray = [Int8](repeating: 0, count: inputSize)
//        let readSize = read(pfd.fd, &inputArray, inputSize)
//        guard readSize == MemoryLayout<input_type>.stride else {
//            print("\(readSize) bytes read from Joystick device file")
//            return
//        }
//        let input = inputArray.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> input_type in
//            ptr.baseAddress!.assumingMemoryBound(to: input_type.self).pointee
//        }
//        guard input.type == 1 else {
//            print("Expected to have type 1 read from Joystick device file, have \(input.type). Input is ignored.")
//            return
//        }
//        guard let button = JoystickButton(rawValue: input.code), let action = JoystickButtonAction(rawValue: input.value) else {
//            print("Unexpected code and/or type read from Joystick device file \(input)")
//            return
//        }
//        joystickCallbackDispatchQueue?.async { [weak self] in
//            self?.joystickCallback?(button, action)
//        }
//    }

    /// Unregisters joystick callback registered earlier.
//    public func unregisterJoystickCallback() {
//        joystickTimer?.suspend()
//        joystickTimer = nil
//        joystickCallback = nil
//        joystickCallbackDispatchQueue = nil
//        if joystickFileDescriptor != -1 {
//            if close(joystickFileDescriptor) != 0 {
//                print("Error \(errno) closing joystick device file")
//            }
//            joystickFileDescriptor = -1
//        }
//    }

}

// MARK: Rotation

extension SenseHat {
    public enum Orientation: Double, CaseIterable {
        case up = 1.5707963267948966 // 𝜋 / 2
        case right = 0.0
        case down = 4.7123889803846897 // 3 * 𝜋 / 2
        case left = 6.2831853071795862 // 2 * 𝜋
    }

    /// Rotates LED matrix to angle `angle`.
    /// At the moment only angles 0, 𝜋 / 2, 3 * 𝜋 / 2 and 2 * 𝜋 are supported.
    ///
    /// - Parameter angle: Angle of rotation in radians.
    public func rotate(angle: Double) {
        var angle = angle.truncatingRemainder(dividingBy: 2.0 * Double.pi)
        angle = angle < 0.0 ? angle + 2.0 * Double.pi : angle
        // `Double.ulpOfOne` doesn't work in this case already after 10 full rotations.
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

    /// Transposes LED matrix horizontally with respect of `orientation`.
    public func transpose() {
        // This in place matrix transpose works only for square matrices.
        // https://en.wikipedia.org/wiki/In-place_matrix_transposition#Square_matrices
        precondition(indices.count == indices.count)
        let N = indices.count
        precondition(N > 2)
        for x in 0 ..< N - 1 {
            for y in x + 1 ..< N {
                frameBufferPointer.swapAt(offset(x: x, y: y), offset(x: y, y: x))
            }
        }
    }

    /// Reflects LED matrix vertically with respect of `orientation`.
    public func reflectVertically() {
        let N = indices.count
        for x in 0 ..< N / 2 {
            for y in indices {
                frameBufferPointer.swapAt(offset(x: x, y: y), offset(x: N - x - 1, y: y))
            }
        }
    }

    /// Reflects LED matrix horizontally with respect of `orientation`.
    public func reflectHorizontally() {
        let N = indices.count
        for x in indices {
            for y in 0 ..< N / 2 {
                frameBufferPointer.swapAt(offset(x: x, y: y), offset(x: x, y: N - y - 1))
            }
        }
    }

}

extension Data {

    /// Looks on buffer like on matrix with C layout and rotates this matrix to angle `angle`.
    /// At the moment only angles 0, 𝜋 / 2, 3 * 𝜋 / 2 and 2 * 𝜋 are supported.
    ///
    /// - Parameter angle: Angle of rotation in radians.
    mutating func rotate(angle: Double, elementSize: Int) {
        precondition(elementSize > 0)
        var angle = angle.truncatingRemainder(dividingBy: 2.0 * Double.pi)
        angle = angle < 0.0 ? angle + 2.0 * Double.pi : angle
        // `Double.ulpOfOne` doesn't work in this case already after 10 full rotations.
        let epsilon = 0.0001
        if fabs(angle - 0.0) < epsilon || fabs(angle - 2.0 * Double.pi) < epsilon {
            // already there
        } else if fabs(angle - Double.pi / 2.0) < epsilon {
            transpose(elementSize: elementSize)
            reflectHorizontally(elementSize: elementSize)
        } else if fabs(angle - Double.pi) < epsilon {
            reflectHorizontally(elementSize: elementSize)
            reflectVertically(elementSize: elementSize)
        } else if fabs(angle - 3.0 * Double.pi / 2.0) < epsilon {
            transpose(elementSize: elementSize)
            reflectVertically(elementSize: elementSize)
        } else {
            fatalError("Rotation to arbitrary angle not implemented.")
        }
    }

    mutating func swapAt(_ a: Int, _ b: Int, elementSize: Int) {
        precondition(elementSize > 0)
        precondition(count >= 2)
        let validRange = 0 ..< count / elementSize
        precondition( validRange ~= a && validRange ~= b)
        guard a != b else { return }
        for offset in 0..<elementSize {
            let bb = self[b * elementSize + offset]
            self[b * elementSize + offset] = self[a * elementSize + offset]
            self[a * elementSize + offset] = bb
        }
    }

    /// Looks on buffer like on matrix with C layout and transposes this matrix.
    mutating func transpose(elementSize: Int) {
        precondition(count % elementSize == 0)
        // This in place matrix transpose works only for square matrices.
        // https://en.wikipedia.org/wiki/In-place_matrix_transposition#Square_matrices
        let N = Int(Double(count / elementSize).squareRoot())
        precondition(N * N == count / elementSize)
        precondition(N > 2)
        for x in 0 ..< N - 1 {
            for y in x + 1 ..< N {
                swapAt(y * N + x, x * N + y, elementSize: elementSize)
            }
        }
    }

    /// Looks on buffer like on matrix with C layout and reflects this matrix vertically.
    mutating func reflectVertically(elementSize: Int) {
        let N = Int(Double(count).squareRoot())
        precondition(N > 2)
        precondition(N * N == count)
        for x in 0 ..< N / 2 {
            for y in 0 ..< N {
                swapAt(y * N + x, y * N + N - x - 1, elementSize: elementSize)
            }
        }
    }

    /// Looks on buffer like on matrix with C layout and reflects this matrix horizontally.
    mutating func reflectHorizontally(elementSize: Int) {
        let N = Int(Double(count).squareRoot())
        precondition(N > 2)
        precondition(N * N == count)
        for x in 0 ..< N {
            for y in 0 ..< N / 2 {
                swapAt(y * N + x, (N - y - 1) * N + x, elementSize: elementSize)
            }
        }
    }

}

extension UnsafeMutableBufferPointer {

    /// Looks on buffer like on matrix with C layout and transposes this matrix.
    public func transpose() {
        // This in place matrix transpose works only for square matrices.
        // https://en.wikipedia.org/wiki/In-place_matrix_transposition#Square_matrices
        let N = Int(Double(count).squareRoot())
        precondition(N * N == count)
        precondition(N > 2)
        for x in 0 ..< N - 1 {
            for y in x + 1 ..< N {
                swapAt(y * N + x, x * N + y)
            }
        }
    }

    /// Looks on buffer like on matrix with C layout and reflects this matrix vertically.
    public func reflectVertically() {
        let N = Int(Double(count).squareRoot())
        precondition(N > 2)
        precondition(N * N == count)
        for x in 0 ..< N / 2 {
            for y in 0 ..< N {
                swapAt(y * N + x, y * N + N - x - 1)
            }
        }
    }

    /// Looks on buffer like on matrix with C layout and reflects this matrix horizontally.
    public func reflectHorizontally() {
        let N = Int(Double(count).squareRoot())
        precondition(N > 2)
        precondition(N * N == count)
        for x in 0 ..< N {
            for y in 0 ..< N / 2 {
                swapAt(y * N + x, (N - y - 1) * N + x)
            }
        }
    }

}

// MARK: CustomDebugStringConvertible

extension SenseHat: CustomDebugStringConvertible {

    /// Returns string representing LED matrix where not black pixels represented
    /// with "X" and black - with space. Native matrix orientation is assumed
    /// here, which is `.up`.
    public var debugDescription: String {
        var ret = " 01234567\n"
        for y in indices {
            ret += String(y)
            for x in indices {
                let pixel = frameBufferPointer[offset(x: x, y: y, orientation: .up)]
                ret += pixel == SenseHat.Rgb565.black ? " " : "X"
            }
            ret += String(y) + "\n"
        }
        ret += " 01234567"
        return ret
    }

}

// MARK: Rgb565

extension SenseHat {

    // Color is represented with `Rgb565` struct.
    // Sense Hat uses two bytes per pixel in frame buffer: red, greed and blue
    // take respectively 5, 6 and 5 bits.
    public struct Rgb565: Equatable {
        public var value: UInt16

        // Red component of color.
        public var red: UInt8 {
            get {
                UInt8(truncatingIfNeeded: value >> 11)
            }
            set(newValue) {
                value = (value & 0b0000_0111_1111_1111) | (UInt16(newValue) << 11)
            }
        }

        // Green component of color.
        public var green: UInt8 {
            get {
                UInt8(truncatingIfNeeded: (value & 0b0000_0111_1110_0000) >> 5)
            }
            set(newValue) {
                value = (value & 0b1111_1000_0001_1111) | ((UInt16(newValue) & 0b0011_1111) << 5)
            }
        }

        // Blue component of color.
        public var blue: UInt8 {
            get {
                UInt8(truncatingIfNeeded: value) & 0b1_1111
            }
            set(newValue) {
                value = (value & 0b1111_1111_1110_0000) | (UInt16(newValue) & 0b0001_1111)
            }
        }

        public init(value: UInt16) {
            self.value = value
        }

        // Black
        public init() {
            self.init(value: 0)
        }

        public init(red: UInt8, green: UInt8, blue: UInt8) {
            value = (UInt16(red) << 11) | ((UInt16(green) & 0b0011_1111) << 5) | (UInt16(blue) & 0b0001_1111)
        }

        public var rgbHexString: String {
            String(format: "%02X%02X%02X",
                   UInt8(Double(red) / Double(0b11111) * Double(0xFF)),
                   UInt8(Double(green) / Double(0b111111) * Double(0xFF)),
                   UInt8(Double(blue) / Double(0b11111) * Double(0xFF))
            )
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

// MARK: Darwin / Xcode Support
//#if os(OSX) || os(iOS)
private var O_SYNC: CInt {0} //{ fatalError("Linux only") }
//#endif

// Wrapper over standard usleep function
public func standardUsleep(_ delay: useconds_t) {
    usleep(delay)
}
