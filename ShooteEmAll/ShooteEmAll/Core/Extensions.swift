//
//  Extensions.swift
//  ShooteEmAll
//
//  Created by Quidich on 28/11/24.
//
import simd

extension float4x4 {
    var forward: SIMD3<Float> {
            // Extract the forward vector (negative Z direction in RealityKit)
        return -SIMD3<Float>(columns.2.x, columns.2.y, columns.2.z)
    }
}

func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
    return Swift.max(min, Swift.min(max, value))
}

func lerp(_ a: Float, _ b: Float, _ t: Float) -> Float {
    return a + (b - a) * t
}

func clampScalar(_ value: Float, min: Float, max: Float) -> Float {
    return clamp(SIMD2<Float>(value, 0), min: SIMD2<Float>(min, 0), max: SIMD2<Float>(max, 0)).x
}

extension simd_quatf {
        /// Convert quaternion to Euler angles (pitch, yaw, roll)
        /// Convert quaternion to Euler angles (pitch, yaw, roll)
    func toEulerAngles() -> SIMD3<Float> {
        let sinPitch = -2.0 * (self.imag.x * self.imag.z - self.real * self.imag.y)
        let pitch: Float
        if abs(sinPitch) >= 1 {
            pitch = copysign(Float.pi / 2, sinPitch) // Clamp pitch to ±90 degrees
        } else {
            pitch = asin(sinPitch)
        }
        
        let yaw = atan2(2.0 * (self.imag.x * self.imag.y + self.real * self.imag.z),
                        self.real * self.real + self.imag.x * self.imag.x - self.imag.y * self.imag.y - self.imag.z * self.imag.z)
        
        return SIMD3<Float>(pitch, yaw, 0) // Roll is not needed for this case
    }
}

extension Float {
    var radians: Float {
        return self * .pi / 180
    }
}

extension matrix_float4x4 {
    var translation: SIMD3<Float> {
        return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
}
