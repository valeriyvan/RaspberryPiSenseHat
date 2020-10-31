# Tinkering with Raspberry Pi Sense Hat with Swift

![Photo](https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/IMG_3366.jpeg "Photo")

In order to acquire some experience in Swift development for Linux, I started tinkering with the Raspberri Pi Sense Hat shield. First half day of tinkering in attempt blinking with LED ended up in finding bug in Swift in `Strideable` implementation. Will contribute soon to Swift validation tests to show bug to community.

This repo can remain in an abandoned semi-working state for quite some time. May or may not sometime turn into Swift package with features similar to this [python library](https://pythonhosted.org/sense-hat/). We will see.

TODO:
* ✅ blink with LED - that what everyone starts from playing with Raspberry Pi
* make Swift package
* get/set individual pixel colors
* get/set all pixels in one shot
* show arbitrary text with/without animation
* show arbitarary image on LED matrix
* show preprocessed video
* read sensors accelerometer/gyro/magnitometer/humidity
* read joystick
* snake game
* menu to show readings from any of available sensors

Unfortunately Datasheet or Programmer's manual for Raspberry Pi Sense Hat doesn't exist or I have failed to find it. Here are some usefull links:

* Official page on raspberrypi.org [Sense HAT](https://www.raspberrypi.org/products/sense-hat/)
* Official documentattion [Documentation for Sense HAT](https://www.raspberrypi.org/documentation/hardware/sense-hat/)
* Official Python module [sense-hat](https://pythonhosted.org/sense-hat/)
* Source of Python module [sense-hat)](https://github.com/astro-pi/python-sense-hat)
* [Getting started with the Sense HAT](https://projects.raspberrypi.org/en/projects/getting-started-with-the-sense-hat)
* Rust library [sensehat-screen](https://docs.rs/sensehat-screen/) where it's expained how RGB is packed int two bytes in so called `Rgb565`
* Linux [The Frame Buffer Device API](https://www.kernel.org/doc/Documentation/fb/api.txt) used to access pixel buffer
* Guide to install Swift on Raspberry Pi [buildSwiftOnARM](https://github.com/uraimo/buildSwiftOnARM) used to install prebuilt Swift 5.1.5 TODO: describe what I've done differently

![Blinking](https://github.com/valeriyvan/RaspberryPiSenseHat/blob/main/images/IMG_3369_480.mov "Blinking")

