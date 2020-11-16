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
* ✅ read humidity sensor;
* ✅ snake game;
* ✅ [life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) game;

TODO:
* read accelerometer/gyro/magnitometer sensors;
* release first version;
* add example snippets to this README;
* add cyrillic font 8x8;
* add 3x5 font;
* replace C fonts with Swift ones;
* show arbitarary image on LED matrix;
* show preprocessed video;
* menu to show readings from any of available sensors;
* mode for rotating screen depending on gyro readings;
* emulator of SenseHat LED matrix for Web;
* Kalman filtering for accelerometer/gyro/magnitometer.

Unfortunately Datasheet or Programmer's manual for Raspberry Pi Sense Hat doesn't exist or I have failed to find it. Here are some usefull links:

* Official page on raspberrypi.org [Sense HAT](https://www.raspberrypi.org/products/sense-hat/);
* [Astro Pi: Flight Hardware Tech Specs](https://www.raspberrypi.org/blog/astro-pi-tech-specs/) names all sensors of SenseHat with links on datasheets;
* Official documentation [Documentation for Sense HAT](https://www.raspberrypi.org/documentation/hardware/sense-hat/);
* Official Python module [sense-hat](https://pythonhosted.org/sense-hat/);
* Source of Python module [sense-hat)](https://github.com/astro-pi/python-sense-hat);
* [Getting started with the Sense HAT](https://projects.raspberrypi.org/en/projects/getting-started-with-the-sense-hat);
* Rust library [sensehat-screen](https://docs.rs/sensehat-screen/) where it's expained how RGB is packed in two bytes in so called `Rgb565`;
* Linux [The Frame Buffer Device API](https://www.kernel.org/doc/Documentation/fb/api.txt) used to access pixel buffer;
* Guide to install Swift on Raspberry Pi [buildSwiftOnARM](https://github.com/uraimo/buildSwiftOnARM) used to install prebuilt Swift 5.1.5 TODO: describe what I've done differently.

![Blinking](https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/IMG_3369_480.mov "Blinking")

