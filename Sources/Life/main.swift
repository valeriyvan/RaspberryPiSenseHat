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
    fatalError("Cannot initialise Raspberry Pi Sense Hat.")
}

struct Point {
    var x,y: Int
}

var cells = [[Bool]](repeating: [Bool](repeating: true, count: 8), count: 8)

func restart() -> Void {
    print("Restarting.")
    for x in cells.indices {
        for y in cells[x].indices {
            cells[x][y] = Bool.random()
        }
    }

    for x in cells.indices {
        for y in cells[x].indices {
            senseHat[x, y] = cells[x][y] ? .red : .black
        }
    }
}

restart()

// swift 5.1 crashes compiling following function.
// If it happens for you, comment out following lines.
// In this case you have to restart game presssing Ctrl-c and relaunching Life.

func callback(button: SenseHat.JoystickButton, action: SenseHat.JoystickButtonAction) -> Void {
    if button == SenseHat.JoystickButton.enter && action == SenseHat.JoystickButtonAction.press {
        restart()
    }
}
let success = senseHat.register(joystickCallback: callback)
guard success else {
    fatalError("Cannot set Joystick.")
}

let timer = DispatchSource.makeTimerSource(flags: [], queue: .global(qos: .userInteractive))
timer.schedule(deadline: .now(), repeating: .milliseconds(300), leeway: .milliseconds(100))
timer.setEventHandler {
    for y in cells.indices {
        for x in cells[y].indices {
            let cell = cells[y][x]
            var liveCount = 0
            for dy in [-1, 0, 1] {
                for dx in [-1, 0, 1] {
                    if dy == 0 && dx == 0 { continue }
                    guard 0..<8 ~= (y + dy) && 0..<8 ~= (x + dx) else { continue }
                    liveCount += cells[y + dy][x + dx] ? 1 : 0
                }
            }

            if !cell && liveCount == 3 {
                cells[y][x] = true
                senseHat[y,x] = .red
            }

            if liveCount <= 1 || liveCount >= 4 {
                cells[y][x] = false
                senseHat[y,x] = .black
            }
        }
    }
}
timer.resume()

print("Running...")

sleep(60*60) // TODO: what's better way doing this?

print("The End.")
