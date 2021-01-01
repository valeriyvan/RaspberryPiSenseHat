<p align="center" style="padding-bottom:50px;">
	<a href="https://raw.githubusercontent.com/valeriyvan/RaspberryPiSenseHat/main/LICENSE"><img src="http://img.shields.io/badge/License-MIT-blue.svg?style=flat"/></a>
	<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Swift-5.x-orange.svg?style=flat"/></a> 
</p>

# Swift package `SenseHat` for Raspberry Pi Sense Hat

![Photo](https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/IMG_3366.jpeg "Photo")

Features:
* ✅ blink with LED - that what everyone starts from playing with Raspberry Pi;
* ✅ get/set color to individual pixels;
* ✅ set color to all pixels in one shot;
* ✅ get/set all pixels in one shot (to/from Data);
* ✅ show 8x8 characters on LCD matrix (supported ascii, extended latin, box drawings elements, block elements, Hiragana, Greek, sga);
* ✅ show arbitrary text (8x8 font, horizontal scroll);
* ✅ rotating of LED matrix 0º/90º/180º/270º;
* ✅ set orientation of LED matrix 0º/90º/180º/270º and make all get/set primitives respect it;
* ✅ read joystick;
* ✅ read humidity and pressure sensors;
* ✅ snake game;
* ✅ [life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) game;

TODO:
* read accelerometer/gyro/magnitometer sensors;
* release first version;
* add example snippets to this README;
* add conversion of RGB color to Rgb565;
* add cyrillic font 8x8;
* add 3x5 font;
* replace C fonts with Swift ones;
* show arbitarary image on LED matrix;
* show preprocessed video;
* menu to show readings from any of available sensors;
* mode for rotating screen depending on gyro readings;
* emulator of SenseHat LED matrix for Web;
* Kalman filtering for accelerometer/gyro/magnitometer;
* add analog clock demo app.

# Usage

## Instantiating

``` Swift
// Look over all frame buffer devices in `/dev/` for one of Sense Hat. 
// Use default orientation `.up`
guard let senseHat = SenseHat() else {
    fatalError("Can't initialise Raspberry Pi Sense Hat")
}
```
Parameter `orientation` could be used for other orientations" `SenseHat(orientation: .left)`.
Parameter `frameBufferDevice` could be use for specific frame buffer device: `SenseHat(frameBufferDevice: "/dev/fb0")`.
Both parameters could be used:  `SenseHat(frameBufferDevice: "/dev/fb0", orientation: .down)`.

Parameter orientation defines where top of the LED matrix will be. Here are example of the same character `"1"` shown with different orientations:

`.up` | `.left` | `.right` | `.down`
--- | --- | --- | ---
![1 up]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/1up.png) | ![1 left]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/1left.png) | ![1 right]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/1right.png) | ![1 down]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/1down.png)

## Set all LEDs of matrix to specific color 

``` Swift
senseHat.set(color: .red) // sets all LEDs of matrix to red
```

![Red]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/red.png "Red")

``` Swift
senseHat.set(color: .black) // sets all LEDs of matrix to black, literally turns them off
```

![Black]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/black.png "Black")

## Set specific LED of matrix to specific color
``` Swift
senseHat.set(color: .black) // clear
senseHat.set(x: 0, y: 0, color: .white) // set most top left LED to white using function syntax
senseHat[7, 7] = .green // set most bottom right LED to green using subscript syntax
```
![White and green]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/white-green.png "White and green")

Coordinates `x` and `y` should belong to `0..<7` range.

## Show character on LED matrix

``` Swift
senseHat.show(character: Character("A"), color: .blue)
```

![A]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/A.png "A")

``` Swift
senseHat.show(character: Character("π"), color: .yellow, background: .blue)
```

![pi]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/pi.png "pi")

## Show string on LED matrix

``` Swift
senseHat.show(string: "Hello! ", secPerChar: 0.5, color: .yellow, background: .blue)
```

![Hello!]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/hello.gif "Hello!")

``` Swift
senseHat.orientation = .left
senseHat.show(string: "Απόλλων ", secPerChar: 0.5, color: .red, background: .darkGray)
```

![Greek]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/greek.gif "Greek")

``` Swift
senseHat.orientation = .right
senseHat.show(string: "ここからそこまで ", secPerChar: 0.5, color: .white, background: .brown)
```

![Hiragana]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/hiragana.gif "Hiragana")

``` Swift
senseHat.orientation = .down
senseHat.show(string: "Fußgängerübergänge ", secPerChar: 0.5, color: .white, background: .purple)
```

![deutsch]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/deutsch.gif "deutsch")

## Reading humidity sensor

``` Swift
if let h = senseHat.humidity() {
    let strH = String(format: "%.1lf", h.H_rH)
    senseHat.show(string: "Humidity \(strH)% rH ", secPerChar: 0.5, color: .yellow, background: .black)
    let strT = String(format: "%.1lf", h.T_DegC)
    senseHat.show(string: "Temperature \(strT)ºC", secPerChar: 0.5, color: .yellow, background: .black)
} else {
    print("Cannot read humidity sensor")
}
```

![humidity]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/humidity.gif "humidity")

## Reading pressure sensor

``` Swift
if let p = senseHat.pressure() {
    let strP = String(format: "%.1lf", p.P_hPa)
    let strT = String(format: "%.1lf", p.T_DegC)
    senseHat.show(string: "Pressure \(strP) hPa ", secPerChar: 0.5, color: .yellow, background: .black)
    senseHat.show(string: "Temperature \(strT)ºC", secPerChar: 0.5, color: .yellow, background: .black)
} else {
    print("Cannot read pressure sensor")
}
```

![pressure]( https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/pressure.gif "pressure")

# Useful links

Unfortunately Datasheet or Programmer's manual for Raspberry Pi Sense Hat doesn't exist or I have failed to find it. Here are some usefull links:

* Official page on raspberrypi.org [Sense HAT](https://www.raspberrypi.org/products/sense-hat/);
* [Astro Pi: Flight Hardware Tech Specs](https://www.raspberrypi.org/blog/astro-pi-tech-specs/) names all sensors of SenseHat with links on datasheets;
* Official documentation [Documentation for Sense HAT](https://www.raspberrypi.org/documentation/hardware/sense-hat/);
* Official Python module [sense-hat](https://pythonhosted.org/sense-hat/);
* Source of Python module [sense-hat](https://github.com/astro-pi/python-sense-hat);
* [Getting started with the Sense HAT](https://projects.raspberrypi.org/en/projects/getting-started-with-the-sense-hat);
* Rust library [sensehat-screen](https://docs.rs/sensehat-screen/) where it's expained how RGB is packed in two bytes in so called `Rgb565`;
* Linux [The Frame Buffer Device API](https://www.kernel.org/doc/Documentation/fb/api.txt) used to access pixel buffer;
* Guide to install Swift on Raspberry Pi [buildSwiftOnARM](https://github.com/uraimo/buildSwiftOnARM) used to install prebuilt Swift 5.1.5 TODO: describe what I've done differently;
* [3D printing Astro Pi case](https://projects.raspberrypi.org/en/projects/astro-pi-flight-case).

![Blinking](https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/IMG_3369_480.mov "Blinking")

