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
    }

    static var allTests = [
        ("testRgb565", testRgb565),
    ]
}
