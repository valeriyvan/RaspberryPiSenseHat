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

var head = (x: 0, y: 0)

enum Direction { case up, right, down, left }
var direction: Direction = .up

let success = senseHat.register(joystickCallback: { button, action in
    print("Joystick button: \(button), action: \(action)")
    guard action == .press else {
        // ignoring button release and repeat
        return
    }
    switch button {
    case .up:
        direction = .up
    case .right:
        direction = .right
    case .down:
        direction = .down
    case .left:
        direction = .left
    case .enter:
        print("The end")
        // TODO: how this might be done without `exit()`?
        exit(0)
    }
})

let timer = DispatchSource.makeTimerSource(flags: [], queue: .global(qos: .userInteractive))
timer.schedule(deadline: .now(), repeating: .milliseconds(100), leeway: .milliseconds(10))
timer.setEventHandler(handler: {
    switch direction {
    case .up:
        var y = head.y - 1
        y = y < 0 ? 7 : y
        head = (head.x, y)
    case .right:
        var x = head.x + 1
        x = x > 7 ? 0: x
        head = (x: x, y: head.y)
    case .down:
        var y = head.y + 1
        y = y > 7 ? 0 : y
        head = (head.x, y)
    case .left:
        var x = head.x - 1
        x = x < 0 ? 7: x
        head = (x: x, y: head.y)
    }
    senseHat.set(color: .black)
    senseHat.set(x: head.x, y: head.y, color: .green)
})
timer.resume()

print("Running...")
sleep(10000) // TODO: what's better way doing this?
