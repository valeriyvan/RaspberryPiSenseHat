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

var running = true

let probabilityRabbit = 2
let probabilityMangust = 2

let bodyColor = SenseHat.Rgb565.yellow
let rabbitColor = SenseHat.Rgb565.white
let mangustColor = SenseHat.Rgb565.red

struct Point: Equatable {
    var x, y: Int
}

var body: [Point] = [Point(x: 3, y: 3)] // First element is head
var rabbits: [Point] = []
var mangusts: [Point] = []

enum Direction { case up, right, down, left }
var direction: Direction = .up

let success = senseHat.register(joystickCallback: { button, action in
    guard action == .press else {
        // Ignoring button release and repeat.
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
        if !running {
            // Restarting
            print("Restarting.")
            body = [Point(x: 3, y: 3)]
            rabbits = []
            mangusts = []
            direction = .up
            senseHat.set(color: .black)
            running = true
        }
    }
})

let timer = DispatchSource.makeTimerSource(flags: [], queue: .global(qos: .userInteractive))
timer.schedule(deadline: .now(), repeating: .milliseconds(500), leeway: .milliseconds(100))
timer.setEventHandler(handler: {
    var head = body.first! // There's always head
    guard running else {
        // When stopped, head is blinking
        let headColor = senseHat[head.x, head.y]
        let otherColor: SenseHat.Rgb565 = mangusts.contains(head) ? mangustColor : .black
        senseHat[head.x, head.y] = headColor == bodyColor ? otherColor : bodyColor 
        return
    }
    switch direction {
    case .up:
        head.y -= 1
        head.y = head.y < 0 ? 7 : head.y
    case .right:
        head.x += 1
        head.x = head.x > 7 ? 0 : head.x
    case .down:
        head.y += 1
        head.y = head.y > 7 ? 0 : head.y
    case .left:
        head.x -= 1
        head.x = head.x < 0 ? 7: head.x
    }
    body.insert(head, at: 0)
    senseHat[head.x, head.y] = bodyColor
    guard !mangusts.contains(head) else {
        print("Ate mangust. Stopping.")
        running = false
        return
    }
    guard !body.dropFirst().contains(head) else {
        print("Ate own tail. Stopping.")
        running = false
        return
    }
    if let rabbitIndex = rabbits.firstIndex(of: head) {
        rabbits.remove(at: rabbitIndex)
    } else {
        let tail = body.last!
        body.removeLast()
        senseHat[tail.x, tail.y] = .black
    }
    if Int.random(in: 1...100) <= probabilityRabbit {
        let rabbit = Point(x: Int.random(in: senseHat.indices), y: Int.random(in: senseHat.indices))
        if !body.contains(rabbit) && !rabbits.contains(rabbit) && !mangusts.contains(rabbit) {
            senseHat[rabbit.x, rabbit.y] = rabbitColor
            rabbits.append(rabbit)
        }
    }
    if Int.random(in: 1...100) <= probabilityMangust {
        let mangust = Point(x: Int.random(in: senseHat.indices), y: Int.random(in: senseHat.indices))
        if !body.contains(mangust) && !rabbits.contains(mangust) && !mangusts.contains(mangust) {
            senseHat[mangust.x, mangust.y] = mangustColor
            mangusts.append(mangust)
        }
    }
})
timer.resume()

print("Running...")

sleep(60*60) // TODO: what's better way doing this?

print("The End.")
