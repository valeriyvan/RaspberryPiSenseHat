// This is just initial test to test grounds.
// Blinking all LEDs in matrix with different colors.

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

func openFbDev(_ name: String) -> Int32? {
    let fd = open("/dev/" + name, O_RDWR)
    guard fd > 0 else { return nil }
    return fd
}

// No idea why it's on fb1 but not on fb0.
// No idea also does it depend on cofiguration or hardcoded to fb1.
// Not idea should be some kind of discovery implemented.
guard let fbfd = openFbDev("fb1" /*RPi-Sense FB"*/) else {
    fatalError("Error: cannot open framebuffer device.")
}

guard let fb = mmap(nil, 128, PROT_READ | PROT_WRITE, MAP_SHARED, fbfd, 0) else {
    fatalError("Can't map framebuffer device.")
}

print("Started")

memset(fb, 0x00, 128)
print("Cleaned screen")

print("Started loop")

// WTF with `stride(from: 0, to: UInt16.max, by: 100)`???
// The last value generated is 65400, then crash.
// There's some problem with `stride(from:to:by:)`.
// Found out it's a bug in Swift in both `StrideToIterator` and `StrideThroughIterator`.
// Strange no-one have found this before.
// Affraid, this will be extreemly hard to fix without breaking source stability
// or ABI stability or both.
// Hope today to contribute to Swift validation tests showing a problem.
// And then will look for how to fix bug.

for color in stride(from: 0, to: 65535, by: 100) {
    let color = UInt16(color)
    print("color: ", color)
    for i in 0..<128/2 {
        fb.advanced(by: i*2).storeBytes(of: color, as: UInt16.self)
    }
    usleep (1_000_000 / 100);
}

print("Delay before exiting")
sleep(10);

memset(fb, 0, 128)
print("Cleaned screen")

munmap(fb, 128)
close(fbfd)
print("Completed")
