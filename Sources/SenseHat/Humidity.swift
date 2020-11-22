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

    public struct Humidity {
        public let H_rH: Double
        public let T_DegC: Double
    }

    public func humidity() -> Humidity? {
        let DEV_PATH = "/dev/i2c-1"
        let DEV_ID: CInt = 0x5F
        let WHO_AM_I: UInt8 = 0x0F

        let CTRL_REG1: UInt8 = 0x20
        let CTRL_REG2: UInt8 = 0x21

        let T0_OUT_L: UInt8 = 0x3C
        let T0_OUT_H: UInt8 = 0x3D
        let T1_OUT_L: UInt8 = 0x3E
        let T1_OUT_H: UInt8 = 0x3F
        let T0_degC_x8: UInt8 = 0x32
        let T1_degC_x8: UInt8 = 0x33
        let T1_T0_MSB: UInt8 = 0x35

        let TEMP_OUT_L: UInt8 = 0x2A
        let TEMP_OUT_H: UInt8 = 0x2B

        let H0_T0_OUT_L: UInt8 = 0x36
        let H0_T0_OUT_H: UInt8 = 0x37
        let H1_T0_OUT_L: UInt8 = 0x3A
        let H1_T0_OUT_H: UInt8 = 0x3B
        let H0_rH_x2: UInt8 = 0x30
        let H1_rH_x2: UInt8 = 0x31

        let H_T_OUT_L: UInt8 = 0x28
        let H_T_OUT_H: UInt8 = 0x29

        // Open i2c device.
        let fileDescriptor: CInt = open(DEV_PATH, O_RDWR)
        guard fileDescriptor >= 0 else {
            print("Error \(errno) openning i2c device.")
            return nil
        }

        defer {
            if close(fileDescriptor) != 0 {
                print("Error \(errno) closing i2c slave device.")
            }
        }

        // Configure i2c slave.
        guard ioctl(fileDescriptor, I2C_SLAVE, DEV_ID) != -1 else {
            print("Error \(errno) configuring i2c device as slave.")
            return nil
        }

        // Check we are who we should be.
        guard i2c_smbus_read_byte_data(fileDescriptor, command: WHO_AM_I) == 0xBC else {
            print("who_am_i error")
            return nil
        }

        // Power down the device (clean start).
        _ = i2c_smbus_write_byte_data(fileDescriptor, command: CTRL_REG1, value: 0x00)

        // Turn on the humidity sensor analog front end in single shot mode.
        _ = i2c_smbus_write_byte_data(fileDescriptor, command: CTRL_REG1, value: 0x84)

        // Run one-shot measurement (temperature and humidity).
        // The set bit will be reset by the sensor itself after execution (self-clearing bit).
        _ = i2c_smbus_write_byte_data(fileDescriptor, command: CTRL_REG2, value: 0x01)

        // Wait until the measurement is completed.
        // TODO: limit iterations
        var counter = 0
        while true {
            print("Loop \(counter)")
            counter += 1
            usleep(25_000) // 25 milliseconds
            guard let status = i2c_smbus_read_byte_data(fileDescriptor, command: CTRL_REG2) else {
                print("nil, continue")
                continue }
            guard status != 0 else { break }
            print(status)
            print("status != 0, continue")
        }

        // Read calibration temperature LSB (ADC) data (temperature calibration
        // x-data for two points)
        let t0_out_l = i2c_smbus_read_byte_data(fileDescriptor, command: T0_OUT_L)
        let t0_out_h = i2c_smbus_read_byte_data(fileDescriptor, command: T0_OUT_H)
        let t1_out_l = i2c_smbus_read_byte_data(fileDescriptor, command: T1_OUT_L)
        let t1_out_h = i2c_smbus_read_byte_data(fileDescriptor, command: T1_OUT_H)

        // Read calibration temperature (°C) data (temperature calibration
        // y-data for two points).
        let t0_degC_x8 = i2c_smbus_read_byte_data(fileDescriptor, command: T0_degC_x8)
        let t1_degC_x8 = i2c_smbus_read_byte_data(fileDescriptor, command: T1_degC_x8)
        let t1_t0_msb = i2c_smbus_read_byte_data(fileDescriptor, command: T1_T0_MSB)

        // Read calibration relative humidity LSB (ADC) data (humidity calibration
        // x-data for two points).
        let h0_out_l = i2c_smbus_read_byte_data(fileDescriptor, command: H0_T0_OUT_L)
        let h0_out_h = i2c_smbus_read_byte_data(fileDescriptor, command: H0_T0_OUT_H)
        let h1_out_l = i2c_smbus_read_byte_data(fileDescriptor, command: H1_T0_OUT_L)
        let h1_out_h = i2c_smbus_read_byte_data(fileDescriptor, command: H1_T0_OUT_H)

        // Read relative humidity (% rH) data (humidity calibration y-data for two points).
        let h0_rh_x2 = i2c_smbus_read_byte_data(fileDescriptor, command: H0_rH_x2)
        let h1_rh_x2 = i2c_smbus_read_byte_data(fileDescriptor, command: H1_rH_x2)

        // Make 16 bit values (bit shift) (temperature calibration x-values).
        let T0_OUT = Int16(t0_out_h!) << 8 | Int16(t0_out_l!)
        let T1_OUT = Int16(t1_out_h!) << 8 | Int16(t1_out_l!)

        // Make 16 bit values (bit shift) (humidity calibration x-values).
        let H0_T0_OUT = Int16(h0_out_h!) << 8 | Int16(h0_out_l!)
        let H1_T0_OUT = Int16(h1_out_h!) << 8 | Int16(h1_out_l!)

        // Make 16 and 10 bit values (bit mask and bit shift).
        let T0_DegC_x8 = Int16(t1_t0_msb! & 3) << 8 | Int16(t0_degC_x8!)
        let T1_DegC_x8 = Int16((t1_t0_msb! & 12) >> 2) << 8 | Int16(t1_degC_x8!)

        // Calculate calibration values (temperature calibration y-values).
        let T0_DegC = Double(T0_DegC_x8) / 8.0
        let T1_DegC = Double(T1_DegC_x8) / 8.0

        // Humidity calibration values (humidity calibration y-values).
        let H0_rH = Double(h0_rh_x2!) / 2.0
        let H1_rH = Double(h1_rh_x2!) / 2.0

        // Solve the linear equation 'y = mx + c' to give the
        //calibration straight line graphs for temperature and humidity.
        let t_gradient_m = (T1_DegC - T0_DegC) / Double(T1_OUT - T0_OUT)
        let t_intercept_c = T1_DegC - (t_gradient_m * Double(T1_OUT))

        let h_gradient_m = (H1_rH - H0_rH) / Double(H1_T0_OUT - H0_T0_OUT)
        let h_intercept_c = H1_rH - (h_gradient_m * Double(H1_T0_OUT))

        // Read the ambient temperature measurement (2 bytes to read).
        let t_out_l = i2c_smbus_read_byte_data(fileDescriptor, command: TEMP_OUT_L)
        let t_out_h = i2c_smbus_read_byte_data(fileDescriptor, command: TEMP_OUT_H)

        // Make 16 bit value.
        let T_OUT = Int16(t_out_h!) << 8 | Int16(t_out_l!)

        // Read the ambient humidity measurement (2 bytes to read)
        let h_t_out_l = i2c_smbus_read_byte_data(fileDescriptor, command: H_T_OUT_L)
        let h_t_out_h = i2c_smbus_read_byte_data(fileDescriptor, command: H_T_OUT_H)

        // Make 16 bit value.
        let H_T_OUT = Int16(h_t_out_h!) << 8 | Int16(h_t_out_l!)

        // Calculate ambient temperature.
        let T_DegC = (t_gradient_m * Double(T_OUT)) + t_intercept_c;

        // Calculate ambient humidity.
        let H_rH = (h_gradient_m * Double(H_T_OUT)) + h_intercept_c;

        // Power down the device.
        _ = i2c_smbus_write_byte_data(fileDescriptor, command: CTRL_REG1, value: 0x00)

        return Humidity(H_rH: H_rH, T_DegC: T_DegC)
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
