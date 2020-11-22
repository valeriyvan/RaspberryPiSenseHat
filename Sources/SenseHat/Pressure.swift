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

private let I2C_SMBUS_READ: UInt8 =   1
private let I2C_SMBUS_WRITE: UInt8 =  0
private let I2C_SMBUS_BYTE_DATA: Int32 = 2
private let I2C_SLAVE: UInt = 0x703
private let I2C_SMBUS: UInt = 0x720
private let I2C_DEFAULT_PAYLOAD_LENGTH: Int = 32

extension SenseHat {

    public struct Pressure {
        public let P_hPa: Double
        public let T_DegC: Double
    }

    public func pressure(logRawReadings: Bool = false) -> Pressure? {
        let DEV_ID: Int32 = 0x5c
        let DEV_PATH = "/dev/i2c-1"
        let WHO_AM_I: UInt8 = 0x0F
        let CTRL_REG1: UInt8 = 0x20
        let CTRL_REG2: UInt8 = 0x21
        let PRESS_OUT_XL: UInt8 = 0x28
        let PRESS_OUT_L: UInt8 = 0x29
        let PRESS_OUT_H: UInt8 = 0x2A
        let TEMP_OUT_L: UInt8 = 0x2B
        let TEMP_OUT_H: UInt8 = 0x2C

        // Open i2c device.
        let fileDescriptor: Int32 = open(DEV_PATH, O_RDWR)
        guard fileDescriptor >= 0 else {
            print("Error \(errno) openning i2c device.", to: &standardError)
            return nil
        }

        defer {
            if close(fileDescriptor) != 0 {
                print("Error \(errno) closing i2c slave device.", to: &standardError)
            }
        }

        // Configure i2c slave.
        guard ioctl(fileDescriptor, I2C_SLAVE, DEV_ID) != -1 else {
            print("Error \(errno) configuring i2c device as slave.", to: &standardError)
            return nil
        }

        // Check we are who we should be.
        guard i2c_smbus_read_byte_data(fileDescriptor, command: WHO_AM_I) == 0xBD else {
            print("who_am_i error", to: &standardError)
            return nil
        }

        // Power down the device (clean start).
        _ = i2c_smbus_write_byte_data(fileDescriptor, command: CTRL_REG1, value: 0x00)

        // Turn on the pressure sensor analog front end in single shot mode.
        _ = i2c_smbus_write_byte_data(fileDescriptor, command: CTRL_REG1, value: 0x84)

        // Run one-shot measurement (temperature and pressure), the set bit will be reset by the
        // sensor itself after execution (self-clearing bit).
        _ = i2c_smbus_write_byte_data(fileDescriptor, command: CTRL_REG2, value: 0x01)

        // Wait until the measurement is completed.
        // TODO: limit iterations
        var counter = 0
        while true {
            if logRawReadings {
                print("Loop \(counter)")
            }
            counter += 1
            usleep(25_000) // 25 milliseconds
            guard let status = i2c_smbus_read_byte_data(fileDescriptor, command: CTRL_REG2) else {
                if logRawReadings {
                    print("nil returned from i2c_smbus_read_byte_data, continue")
                }
                continue
            }
            guard status != 0 else { break }
            print(status)
            if logRawReadings {
                print("status \(status) != 0, continue")
            }
        }

        // Read the temperature measurement (2 bytes to read).
        let temp_out_l = i2c_smbus_read_byte_data(fileDescriptor, command: TEMP_OUT_L)
        let temp_out_h = i2c_smbus_read_byte_data(fileDescriptor, command: TEMP_OUT_H)
        if logRawReadings {
            print("temp_out_l = \(temp_out_l!), temp_out_h = \(temp_out_h!)")
        }

        // Read the pressure measurement (3 bytes to read)
        let press_out_xl = i2c_smbus_read_byte_data(fileDescriptor, command: PRESS_OUT_XL)
        let press_out_l = i2c_smbus_read_byte_data(fileDescriptor, command: PRESS_OUT_L)
        let press_out_h = i2c_smbus_read_byte_data(fileDescriptor, command: PRESS_OUT_H)

        // Temperature output is signed number despite it isn't clearly stated in sensor datasheet.
        let temp_out = (Int16(temp_out_h!) << 8) | Int16(temp_out_l!)
        if logRawReadings {
            print("temp_out = \(temp_out)")
        }
        let press_out = (Int(press_out_h!) << 16) | (Int(press_out_l!) << 8) | Int(press_out_xl!)
        if logRawReadings {
            print("press_out = \(press_out)")
        }

        // Calculate output values
        let T_DegC = 42.5 + (Double(temp_out) / 480.0)
        if logRawReadings {
            print("T_DegC = \(T_DegC)")
        }
        let P_hPa = Double(press_out) / 4096.0
        if logRawReadings {
            print("P_hPa = \(P_hPa)")
        }

        // Power down the device.
        _ = i2c_smbus_write_byte_data(fileDescriptor, command: CTRL_REG1, value: 0x00)

        return Pressure(P_hPa: P_hPa, T_DegC: T_DegC)
    }

    private struct i2c_smbus_ioctl_data {
        var read_write: UInt8
        var command: UInt8
        var size: Int32
        var data: UnsafeMutablePointer<UInt8>? //union: UInt8, UInt16, [UInt8]33
    }

    private func smbus_ioctl(_ fd: Int32, rw: UInt8, command: UInt8, size: Int32, data: UnsafeMutablePointer<UInt8>?) -> Bool {
        var args = i2c_smbus_ioctl_data(read_write: rw, command: command, size: size, data: data)
        return ioctl(fd, I2C_SMBUS, &args) != -1
    }

    private func i2c_smbus_read_byte_data(_ fd: Int32, command: UInt8) -> UInt8? {
        var data = [UInt8](repeating:0, count: I2C_DEFAULT_PAYLOAD_LENGTH)
        let r = smbus_ioctl(fd, rw: I2C_SMBUS_READ, command: command, size: I2C_SMBUS_BYTE_DATA, data: &data)
        guard r else { return nil }
        return data[0]
    }

    private func i2c_smbus_write_byte_data(_ fd: Int32, command: UInt8, value: UInt8) -> Bool {
        var data = [UInt8](repeating:0, count: I2C_DEFAULT_PAYLOAD_LENGTH)
        data[0] = value
        return smbus_ioctl(fd, rw: I2C_SMBUS_WRITE, command: command, size: I2C_SMBUS_BYTE_DATA, data: &data)
    }

}
