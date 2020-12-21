/**
 *  SenseHat
 *  Copyright (c) Valeriy Van 2020
 *  MIT license - see LICENSE.md
 */

import XCTest
@testable import SenseHat

final class SenseHatTests: XCTestCase {
    func testRgb565() {
        let red = SenseHat.Rgb565.red
        XCTAssertEqual(red.value, 0b1111_1000_0000_0000)
        XCTAssertEqual(red.red, 0b0001_1111)
        XCTAssertEqual(red.green, 0)
        XCTAssertEqual(red.blue, 0)

        let green = SenseHat.Rgb565.green
        XCTAssertEqual(green.value, 0b0000_0111_1110_0000)
        XCTAssertEqual(green.red, 0)
        XCTAssertEqual(green.green, 0b0011_1111)
        XCTAssertEqual(green.blue, 0)

        let blue = SenseHat.Rgb565.blue
        XCTAssertEqual(blue.value, 0b0000_0000_0001_1111)
        XCTAssertEqual(blue.red, 0)
        XCTAssertEqual(blue.green, 0)
        XCTAssertEqual(blue.blue, 0b0001_1111)

        let white = SenseHat.Rgb565.white
        XCTAssertEqual(white.value, 0xffff)
        XCTAssertEqual(white.red, 0b0001_1111)
        XCTAssertEqual(white.green, 0b0011_1111)
        XCTAssertEqual(white.blue, 0b0001_1111)

        let black = SenseHat.Rgb565.black
        XCTAssertEqual(black.value, 0)
        XCTAssertEqual(black.red, 0)
        XCTAssertEqual(black.green, 0)
        XCTAssertEqual(black.blue, 0)

        let brown = SenseHat.Rgb565.brown
        XCTAssertEqual(brown.value, 0b1001_1011_0010_0110)
        XCTAssertEqual(brown.red, 0b0001_0011) // 0.6
        XCTAssertEqual(brown.red, UInt8(((0.6*Float(0b1_1111)).rounded(.toNearestOrAwayFromZero))))
        XCTAssertEqual(brown.green, 0b0001_1001) // 0.4
        XCTAssertEqual(brown.green, UInt8(((0.4*Float(0b11_1111)).rounded(.toNearestOrAwayFromZero)))) // 0.4
        XCTAssertEqual(brown.blue, 0b0000_0110) // 0.2
        XCTAssertEqual(brown.blue, UInt8(((0.2*Float(0b1_1111)).rounded(.toNearestOrAwayFromZero)))) // 0.2

        let cyan = SenseHat.Rgb565.cyan
        XCTAssertEqual(cyan.value, 0b0000_0111_1111_1111)
        XCTAssertEqual(cyan.red, 0)
        XCTAssertEqual(cyan.green, 0b0011_1111)
        XCTAssertEqual(cyan.blue, 0b0001_1111)

        let magenta = SenseHat.Rgb565.magenta
        XCTAssertEqual(magenta.value, 0b1111_1000_0001_1111)
        XCTAssertEqual(magenta.red, 0b0001_1111)
        XCTAssertEqual(magenta.green, 0)
        XCTAssertEqual(magenta.blue, 0b0001_1111)

        let yellow = SenseHat.Rgb565.yellow
        XCTAssertEqual(yellow.value, 0b1111_1111_1110_0000)
        XCTAssertEqual(yellow.red, 0b0001_1111)
        XCTAssertEqual(yellow.green, 0b0011_1111)
        XCTAssertEqual(yellow.blue, 0)

        let purple = SenseHat.Rgb565.purple
        XCTAssertEqual(purple.value, 0b1000_0000_0001_0000)
        XCTAssertEqual(purple.red, 0b0001_0000)
        XCTAssertEqual(purple.green, 0)
        XCTAssertEqual(purple.blue, 0b0001_0000)

        let orange = SenseHat.Rgb565.orange
        XCTAssertEqual(orange.value, 0b1111_1100_0000_0000)
        XCTAssertEqual(orange.red, 0b0001_1111)
        XCTAssertEqual(orange.green, 0b0010_0000)
        XCTAssertEqual(orange.blue, 0b0000_0000)

        let gray = SenseHat.Rgb565.gray
        XCTAssertEqual(gray.value, 0b1000_0100_0001_0000)
        XCTAssertEqual(gray.red, 0b0001_0000)
        XCTAssertEqual(gray.green, 0b0010_0000)
        XCTAssertEqual(gray.blue, 0b0001_0000)

        let lightGray = SenseHat.Rgb565.lightGray
        XCTAssertEqual(lightGray.value, 0b1010_1101_0101_0101)
        XCTAssertEqual(lightGray.red, 0b0001_0101) // 2/3
        XCTAssertEqual(lightGray.red, UInt8(((2.0/3.0*Float(0b1_1111)).rounded(.toNearestOrAwayFromZero))))
        XCTAssertEqual(lightGray.green, 0b0010_1010) // 2/3
        XCTAssertEqual(lightGray.green, UInt8(((2.0/3.0*Float(0b11_1111)).rounded(.toNearestOrAwayFromZero))))
        XCTAssertEqual(lightGray.blue, 0b0001_0101) // 2/3
        XCTAssertEqual(lightGray.blue, UInt8(((2.0/3.0*Float(0b1_1111)).rounded(.toNearestOrAwayFromZero))))

        let darkGray = SenseHat.Rgb565.darkGray
        XCTAssertEqual(darkGray.value, 0b0101_0010_1010_1010)
        XCTAssertEqual(darkGray.red, 0b0000_1010) // 1/3
        XCTAssertEqual(darkGray.red, UInt8(((1.0/3.0*Float(0b1_1111)).rounded(.toNearestOrAwayFromZero))))
        XCTAssertEqual(darkGray.green, 0b0001_0101) // 1/3
        XCTAssertEqual(darkGray.green, UInt8(((1.0/3.0*Float(0b11_1111)).rounded(.toNearestOrAwayFromZero))))
        XCTAssertEqual(darkGray.blue, 0b0000_1010) // 1/3
        XCTAssertEqual(darkGray.red, UInt8(((1.0/3.0*Float(0b1_1111)).rounded(.toNearestOrAwayFromZero))))

        var veryVeryLightGray = SenseHat.Rgb565()
        veryVeryLightGray.red = 1
        veryVeryLightGray.green = 1
        veryVeryLightGray.blue = 1
        XCTAssertEqual(veryVeryLightGray.value, 0b0000_1000_0010_0001)
        XCTAssertEqual(veryVeryLightGray.red, 1)
        XCTAssertEqual(veryVeryLightGray.green, 1)
        XCTAssertEqual(veryVeryLightGray.blue, 1)

        let veryLightGray = SenseHat.Rgb565(red: 0b11, green: 0b11, blue: 0b11)
        XCTAssertEqual(veryLightGray.value, 0b0001_1000_0110_0011)
        XCTAssertEqual(veryLightGray.red, 0b11)
        XCTAssertEqual(veryLightGray.green, 0b11)
        XCTAssertEqual(veryLightGray.blue, 0b11)
    }

    func testInitializerFails() {
        let senseHat = SenseHat(frameBufferDevice: nil, orientation: .up)
        XCTAssertNil(senseHat)
    }

    func testSetGetPixelColorUp() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        senseHat.set(x: 5, y: 6, color: .red)
        for x in senseHat.indices {
            for y in senseHat.indices {
                if x == 5 && y == 6 {
                    XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .red)
                } else {
                    XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .black)
                }
            }
        }
    }

    func testSetGetPixelColorRight() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .right))
        senseHat.set(x: 5, y: 6, color: .red)
        for x in senseHat.indices {
            for y in senseHat.indices {
                if x == 1 && y == 5 {
                    XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .red)
                } else {
                    XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .black)
                }
            }
        }
    }

    func testSetGetPixelColorDown() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .down))
        senseHat.set(x: 5, y: 6, color: .red)
        for x in senseHat.indices {
            for y in senseHat.indices {
                if x == 2 && y == 1 {
                    XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .red)
                } else {
                    XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .black)
                }
            }
        }
    }

    func testSetGetPixelColorLeft() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .left))
        senseHat.set(x: 5, y: 6, color: .red)
        for x in senseHat.indices {
            for y in senseHat.indices {
                if x == 6 && y == 2 {
                    XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .red)
                } else {
                    XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .black)
                }
            }
        }
    }

    func testSetGetPixelColorSubscript() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        senseHat[5, 6] = .red
        for x in senseHat.indices {
            for y in senseHat.indices {
                if x == 5 && y == 6 {
                    XCTAssertEqual(senseHat[x, y], .red)
                } else {
                    XCTAssertEqual(senseHat[x, y], .black)
                }
            }
        }
    }

    func testSetMatrixColor() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        senseHat.set(color: .yellow)
        for x in senseHat.indices {
            for y in senseHat.indices {
                XCTAssertEqual(senseHat.color(x: x, y: y), .yellow)
            }
        }
    }

    func testSetGetData() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        let dataBefore = senseHat.data()
        senseHat.set(x: 0, y: 0, color: .purple)
        let dataAfter = senseHat.data()
        XCTAssertNotEqual(dataBefore, dataAfter)
        senseHat.set(data: dataBefore)
        let dataAfterReverting = senseHat.data()
        XCTAssertEqual(dataBefore, dataAfterReverting)
    }

    func testShowCharacterUp() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        let unicodePoint: Int = 0x2598 // U+2598 (box top left)
        let char = Character(UnicodeScalar(unicodePoint)!)
        senseHat.show(character: char, color: .purple, background: .darkGray)
        // Check pixels of box top left
        for x in 0..<senseHat.indices.count / 2 {
            for y in 0..<senseHat.indices.count / 2 {
                XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .purple)
            }
        }
        // Check pixels on right of box top left
        for x in senseHat.indices.count / 2 ..< senseHat.indices.count {
            for y in 0..<senseHat.indices.count / 2 {
                XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .darkGray)
            }
        }
        // Check rest of pixels
        for x in senseHat.indices {
            for y in senseHat.indices.count / 2 ..< senseHat.indices.count {
                XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .darkGray)
            }
        }
    }

    func testShowMissingCharacter() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        senseHat.show(character: Character("Ї"), color: .purple, background: .purple)
        for x in senseHat.indices {
            for y in senseHat.indices {
                XCTAssertEqual(senseHat.color(x: x, y: y), .purple)
            }
        }
    }

    func testShowCharacterRight() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .right))
        let unicodePoint: Int = 0x2598 // U+2598 (box top left)
        let char = Character(UnicodeScalar(unicodePoint)!)
        senseHat.show(character: char, color: .purple, background: .darkGray)
        // Check pixels of box top left
        for x in senseHat.indices.count / 2 ..< senseHat.indices.count{
            for y in 0..<senseHat.indices.count / 2 {
                XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .purple)
            }
        }
        // Check pixels on right of box top left
        for x in senseHat.indices.count / 2 ..< senseHat.indices.count {
            for y in senseHat.indices.count / 2 ..< senseHat.indices.count {
                XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .darkGray)
            }
        }
        // Check rest of pixels
        for x in 0 ..< senseHat.indices.count / 2 {
            for y in senseHat.indices {
                XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .darkGray)
            }
        }
    }

    func testShowCharacterDown() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .down))
        let unicodePoint: Int = 0x2598 // U+2598 (box top left)
        let char = Character(UnicodeScalar(unicodePoint)!)
        senseHat.show(character: char, color: .purple, background: .darkGray)
        // Check pixels of box top left
        for x in senseHat.indices.count / 2 ..< senseHat.indices.count {
            for y in senseHat.indices.count / 2 ..< senseHat.indices.count {
                XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .purple)
            }
        }
        // Check pixels on right of box top left
        for x in 0 ..< senseHat.indices.count / 2 {
            for y in senseHat.indices.count / 2 ..< senseHat.indices.count {
                XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .darkGray)
            }
        }
        // Check rest of pixels
        for x in senseHat.indices {
            for y in 0 ..< senseHat.indices.count / 2 {
                XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .darkGray)
            }
        }
    }

    func testShowCharacterLeft() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .left))
        let unicodePoint: Int = 0x2598 // U+2598 (box top left)
        let char = Character(UnicodeScalar(unicodePoint)!)
        senseHat.show(character: char, color: .purple, background: .darkGray)
        // Check pixels of box top left
        for x in 0 ..< senseHat.indices.count / 2 {
            for y in senseHat.indices.count / 2 ..< senseHat.indices.count {
                XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .purple)
            }
        }
        // Check pixels on right of box top left
        for x in 0 ..< senseHat.indices.count / 2 {
            for y in 0 ..< senseHat.indices.count / 2 {
                XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .darkGray)
            }
        }
        // Check rest of pixels
        for x in senseHat.indices.count / 2 ..< senseHat.indices.count {
            for y in senseHat.indices {
                XCTAssertEqual(senseHat.color(absoluteX: x, absoluteY: y), .darkGray)
            }
        }
    }

    func testCharDataUp() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        let unicodePoint: Int = 0x2598 // U+2598 (box top left)
        let char = Character(UnicodeScalar(unicodePoint)!)
        let data = senseHat.data(character: char, color: .yellow, background: .blue)
        data.withUnsafeBytes { buf in
            let count = senseHat.indices.count * senseHat.indices.count
            precondition(count == buf.count / MemoryLayout<SenseHat.Rgb565>.stride)
            let start = buf.baseAddress!.assumingMemoryBound(to: SenseHat.Rgb565.self)
            let bufferPointer = UnsafeBufferPointer<SenseHat.Rgb565>(start: start, count: count)
            // Check pixels of box top left
            for x in 0..<senseHat.indices.count / 2 {
                for y in 0..<senseHat.indices.count / 2 {
                    XCTAssertEqual(bufferPointer[y * senseHat.indices.count + x], .yellow)
                }
            }
            // Check pixels on right of box top left
            for x in senseHat.indices.count / 2 ..< senseHat.indices.count {
                for y in 0..<senseHat.indices.count / 2 {
                    XCTAssertEqual(bufferPointer[y * senseHat.indices.count + x], .blue)
                }
            }
            // Check rest of pixels
            for x in senseHat.indices {
                for y in senseHat.indices.count / 2 ..< senseHat.indices.count {
                    XCTAssertEqual(bufferPointer[y * senseHat.indices.count + x], .blue)
                }
            }
        }
    }

    func testCharDataRight() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .right))
        let unicodePoint: Int = 0x2598 // U+2598 (box top left)
        let char = Character(UnicodeScalar(unicodePoint)!)
        let data = senseHat.data(character: char, color: .yellow, background: .blue)
        data.withUnsafeBytes { buf in
            let count = senseHat.indices.count * senseHat.indices.count
            precondition(count == buf.count / MemoryLayout<SenseHat.Rgb565>.stride)
            let start = buf.baseAddress!.assumingMemoryBound(to: SenseHat.Rgb565.self)
            let bufferPointer = UnsafeBufferPointer<SenseHat.Rgb565>(start: start, count: count)
            // Check pixels of box top left
            for x in senseHat.indices.count / 2 ..< senseHat.indices.count{
                for y in 0..<senseHat.indices.count / 2 {
                    XCTAssertEqual(bufferPointer[y * senseHat.indices.count + x], .yellow)
                }
            }
            // Check pixels on right of box top left
            for x in senseHat.indices.count / 2 ..< senseHat.indices.count {
                for y in senseHat.indices.count / 2 ..< senseHat.indices.count {
                    XCTAssertEqual(bufferPointer[y * senseHat.indices.count + x], .blue)
                }
            }
            // Check rest of pixels
            for x in 0 ..< senseHat.indices.count / 2 {
                for y in senseHat.indices {
                    XCTAssertEqual(bufferPointer[y * senseHat.indices.count + x], .blue)
                }
            }
        }
    }

    func testCharDataDown() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .down))
        let unicodePoint: Int = 0x2598 // U+2598 (box top left)
        let char = Character(UnicodeScalar(unicodePoint)!)
        let data = senseHat.data(character: char, color: .yellow, background: .blue)
        data.withUnsafeBytes { buf in
            let count = senseHat.indices.count * senseHat.indices.count
            precondition(count == buf.count / MemoryLayout<SenseHat.Rgb565>.stride)
            let start = buf.baseAddress!.assumingMemoryBound(to: SenseHat.Rgb565.self)
            let bufferPointer = UnsafeBufferPointer<SenseHat.Rgb565>(start: start, count: count)
            // Check pixels of box top left
            for x in senseHat.indices.count / 2 ..< senseHat.indices.count {
                for y in senseHat.indices.count / 2 ..< senseHat.indices.count {
                    XCTAssertEqual(bufferPointer[y * senseHat.indices.count + x], .yellow)
                }
            }
            // Check pixels on right of box top left
            for x in 0 ..< senseHat.indices.count / 2 {
                for y in senseHat.indices.count / 2 ..< senseHat.indices.count {
                    XCTAssertEqual(bufferPointer[y * senseHat.indices.count + x], .blue)
                }
            }
            // Check rest of pixels
            for x in senseHat.indices {
                for y in 0 ..< senseHat.indices.count / 2 {
                    XCTAssertEqual(bufferPointer[y * senseHat.indices.count + x], .blue)
                }
            }
        }
    }

    func testCharDataLeft() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .left))
        let unicodePoint: Int = 0x2598 // U+2598 (box top left)
        let char = Character(UnicodeScalar(unicodePoint)!)
        let data = senseHat.data(character: char, color: .yellow, background: .blue)
        data.withUnsafeBytes { buf in
            let count = senseHat.indices.count * senseHat.indices.count
            precondition(count == buf.count / MemoryLayout<SenseHat.Rgb565>.stride)
            let start = buf.baseAddress!.assumingMemoryBound(to: SenseHat.Rgb565.self)
            let bufferPointer = UnsafeBufferPointer<SenseHat.Rgb565>(start: start, count: count)
            // Check pixels of box top left
            for x in 0 ..< senseHat.indices.count / 2 {
                for y in senseHat.indices.count / 2 ..< senseHat.indices.count {
                    XCTAssertEqual(bufferPointer[y * senseHat.indices.count + x], .yellow)
                }
            }
            // Check pixels on right of box top left
            for x in 0 ..< senseHat.indices.count / 2 {
                for y in 0 ..< senseHat.indices.count / 2 {
                    XCTAssertEqual(bufferPointer[y * senseHat.indices.count + x], .blue)
                }
            }
            // Check rest of pixels
            for x in senseHat.indices.count / 2 ..< senseHat.indices.count {
                for y in senseHat.indices {
                    XCTAssertEqual(bufferPointer[y * senseHat.indices.count + x], .blue)
                }
            }
        }
    }

    func testCharDataExtLatin() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        let unicodePoint: Int = 0x00A0 // U+00A0 (no break space)
        let char = Character(UnicodeScalar(unicodePoint)!)
        let data = senseHat.data(character: char, color: .white, background: .black)
        data.withUnsafeBytes { buf in
            let count = senseHat.indices.count * senseHat.indices.count
            precondition(count == buf.count / MemoryLayout<SenseHat.Rgb565>.stride)
            let start = buf.baseAddress!.assumingMemoryBound(to: SenseHat.Rgb565.self)
            let bufferPointer = UnsafeBufferPointer<SenseHat.Rgb565>(start: start, count: count)
            for i in 0..<count {
                XCTAssertEqual(bufferPointer[i], .black)
            }
        }
    }

    func testCharDataExtLatin2Scalars() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        let charSmallEAccute = Character("\u{65}\u{301}") // e followed by accute
        let charSmallE = Character("e")
        let dataTestable = senseHat.data(character: charSmallEAccute, color: .white, background: .black)
        let dataSample = senseHat.data(character: charSmallE, color: .white, background: .black)
        XCTAssertEqual(dataTestable, dataSample)
    }

    func testCharDataBox() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        let unicodePoint: Int = 0x2500 // U+2500 (thin horizontal)
        let char = Character(UnicodeScalar(unicodePoint)!)
        let data = senseHat.data(character: char, color: .white, background: .black)
        data.withUnsafeBytes { buf in
            let count = senseHat.indices.count * senseHat.indices.count
            precondition(count == buf.count / MemoryLayout<SenseHat.Rgb565>.stride)
            let start = buf.baseAddress!.assumingMemoryBound(to: SenseHat.Rgb565.self)
            let bufferPointer = UnsafeBufferPointer<SenseHat.Rgb565>(start: start, count: count)
            // Check pixels of box top left
            for x in senseHat.indices {
                for y in senseHat.indices {
                    XCTAssertEqual(bufferPointer[y * senseHat.indices.count + x], y == 4 ? .white : .black)
                }
            }
        }
    }

    func testCharDataHiragana() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        let unicodePoint: Int = 0x3040 // U+3040
        let char = Character(UnicodeScalar(unicodePoint)!)
        let data = senseHat.data(character: char, color: .white, background: .black)
        data.withUnsafeBytes { buf in
            let count = senseHat.indices.count * senseHat.indices.count
            precondition(count == buf.count / MemoryLayout<SenseHat.Rgb565>.stride)
            let start = buf.baseAddress!.assumingMemoryBound(to: SenseHat.Rgb565.self)
            let bufferPointer = UnsafeBufferPointer<SenseHat.Rgb565>(start: start, count: count)
            for i in 0..<count {
                XCTAssertEqual(bufferPointer[i], .black)
            }
        }
    }

    func testCharDataLeftNotEqualRight() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .left))
        let unicodePoint: Int = 0x2598 // U+2598 (box top left)
        let char = Character(UnicodeScalar(unicodePoint)!)
        let dataLeft = senseHat.data(character: char, color: .yellow, background: .blue)
        senseHat.orientation = .right
        let dataRight = senseHat.data(character: char, color: .yellow, background: .blue)
        XCTAssertNotEqual(dataLeft, dataRight)
    }


    func testShiftLeftAllOrientations() throws {
        for orientation in SenseHat.Orientation.allCases {
            let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: orientation))
            let dataBefore = senseHat.data()
            let redColumn = Array(repeating: SenseHat.Rgb565.red, count: 8)
            senseHat.shiftLeft(addingColumn: redColumn)
            for x in senseHat.indices.dropLast() {
                for y in senseHat.indices {
                    XCTAssertEqual(senseHat.color(x: x, y: y), .black)
                }
            }
            for y in senseHat.indices {
                XCTAssertEqual(senseHat.color(x: senseHat.indices.last!, y: y), .red)
            }
            let blackColumn = Array(repeating: SenseHat.Rgb565.black, count: 8)
            for _ in senseHat.indices {
                senseHat.shiftLeft(addingColumn: blackColumn)
            }
            let dataAfter = senseHat.data()
            XCTAssertEqual(dataBefore, dataAfter)
        }
    }

    func testReflectHorizontally() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        senseHat.show(character: Character("/"), color: .blue)
        let sample = senseHat.data()
        senseHat.reflectHorizontally()
        senseHat.reflectHorizontally()
        let twiceFlipped = senseHat.data()
        XCTAssertEqual(sample, twiceFlipped)
    }

    func testReflectVertically() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        senseHat.show(character: Character("P"), color: .blue)
        let sample = senseHat.data()
        senseHat.reflectVertically()
        senseHat.reflectVertically()
        let twiceFlipped = senseHat.data()
        XCTAssertEqual(sample, twiceFlipped)
    }

    func testTranspose() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        senseHat.show(character: Character("8"), color: .blue)
        let sample = senseHat.data()
        senseHat.transpose()
        senseHat.transpose()
        let twiceFlipped = senseHat.data()
        XCTAssertEqual(sample, twiceFlipped)
    }

    func testRotate90() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        senseHat.show(character: Character("8"), color: .blue)
        let sample = senseHat.data()
        // positive angle
        var angle = 0.0
        for _ in 0..<4*10 {
            senseHat.rotate(angle: angle)
            angle += Double.pi / 2.0
        }
        let rotated = senseHat.data()
        XCTAssertEqual(sample, rotated)
        // negative angle
        angle = 0.0
        for _ in 0..<4*10 {
            senseHat.rotate(angle: angle)
            angle -= Double.pi / 2.0
        }
        XCTAssertEqual(sample, rotated)
    }

    func testDebugDescription() throws {
        let senseHat = try XCTUnwrap(SenseHat(frameBufferDevice: "__TEST__", orientation: .up))
        senseHat.set(color: .black)
        let debugDescriptionBlack = senseHat.debugDescription
        print(debugDescription)
        let sampleBlack = """
             01234567
            0        0
            1        1
            2        2
            3        3
            4        4
            5        5
            6        6
            7        7
             01234567
            """
        XCTAssertEqual(sampleBlack, debugDescriptionBlack)

        senseHat.set(color: .white)
        let debugDescriptionWhite = senseHat.debugDescription
        print(debugDescription)
        let sampleWhite = """
             01234567
            0XXXXXXXX0
            1XXXXXXXX1
            2XXXXXXXX2
            3XXXXXXXX3
            4XXXXXXXX4
            5XXXXXXXX5
            6XXXXXXXX6
            7XXXXXXXX7
             01234567
            """
        XCTAssertEqual(sampleWhite, debugDescriptionWhite)
    }

    static var allTests = [
        ("testRgb565", testRgb565),
        ("testInitializerFails", testInitializerFails),
        ("testSetGetPixelColorUp", testSetGetPixelColorUp),
        ("testSetGetPixelColorRight", testSetGetPixelColorRight),
        ("testSetGetPixelColorDown", testSetGetPixelColorDown),
        ("testSetGetPixelColorLeft", testSetGetPixelColorLeft),
        ("testSetGetPixelColorSubscript", testSetGetPixelColorSubscript),
        ("testSetMatrixColor", testSetMatrixColor),
        ("testSetGetData", testSetGetData),
        ("testShowCharacterUp", testShowCharacterUp),
        ("testShowCharacterRight", testShowCharacterRight),
        ("testShowCharacterDown", testShowCharacterDown),
        ("testShowCharacterLeft", testShowCharacterLeft),
        ("testCharDataUp", testCharDataUp),
        ("testCharDataRight", testCharDataRight),
        ("testCharDataDown", testCharDataDown),
        ("testCharDataLeft", testCharDataLeft),
        ("testCharDataExtLatin", testCharDataExtLatin),
        ("testCharDataBox", testCharDataBox),
        ("testCharDataHiragana", testCharDataHiragana),
        ("testCharDataLeftNotEqualRight", testCharDataLeftNotEqualRight),
        ("testShiftLeftAllOrientations", testShiftLeftAllOrientations),
        ("testReflectHorizontally", testReflectHorizontally),
        ("testReflectVertically", testReflectVertically),
        ("testTranspose", testTranspose),
        ("testRotate90", testRotate90),
        ("testDebugDescription", testDebugDescription),
    ]
}

private extension Data {
    var customDebugDescription: String {
        guard count == 128 else {
            return debugDescription
        }
        return withUnsafeBytes { (bufferPointer: UnsafeRawBufferPointer) -> String in
            let start = bufferPointer.baseAddress!.assumingMemoryBound(to: SenseHat.Rgb565.self)
            let buffer = UnsafeBufferPointer(start: start, count: 64)
            var ret = " 01234567\n"
            for y in 0..<8 {
                ret += String(y)
                for x in 0..<8 {
                    let pixel = buffer[y * 8 + x]
                    ret += pixel == SenseHat.Rgb565.black ? " " : "X"
                }
                ret += String(y) + "\n"
            }
            ret += " 01234567"
            return ret
        }
    }
}
