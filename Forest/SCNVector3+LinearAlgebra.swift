//
//  SCNVector3+LinearAlgebra.swift
//  Procedural Forest
//
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//

import Foundation
import SceneKit
import GLKit

extension SCNVector3 {
	
	/// A convenience initializer for `Float`.
	init(fx: Float, fy: Float, fz: Float) {
		self.init()
		self.x = CGFloat(fx)
		self.y = CGFloat(fy)
		self.z = CGFloat(fz)
	}
	
	/// Performs Euler rotations on the vector.
	mutating func rotateAtOriginWith(pitch: Float, roll: Float, yaw: Float = 0) {
		let rot1 = GLKMatrix4RotateX(GLKMatrix4Identity, pitch)
		let rot2 = GLKMatrix4RotateZ(GLKMatrix4Identity, roll)
		let rot3 = GLKMatrix4RotateY(GLKMatrix4Identity, yaw)
		
		var rotatedVec = GLKMatrix4MultiplyVector3(rot1, GLKVector3Make(Float(x), Float(y), Float(z)))
		rotatedVec = GLKMatrix4MultiplyVector3(rot2, rotatedVec)
		rotatedVec = GLKMatrix4MultiplyVector3(rot3, rotatedVec)
		let tmp = SCNVector3FromGLKVector3(rotatedVec)
		
		x = tmp.x
		y = tmp.y
		z = tmp.z
	}
	
	/// Returns the magnitude.
	var length: CGFloat {
		return sqrt(x*x + y*y + z*z)
	}
	
	/// Returns a normalized version of the receiver.
	var normalized: SCNVector3 {
		return self / length
	}
	
	/// Normalizes the receiver.
	mutating func normalize() -> SCNVector3 {
		self = normalized
		return self
	}
	
	/// Returns the distance to the parameter.
	func distance(to vector: SCNVector3) -> CGFloat {
		return (self - vector).length
	}
	
	/// Dot product with the specified vector.
	func dot(_ vector: SCNVector3) -> CGFloat {
		return x * vector.x + y * vector.y + z * vector.z
	}
	
	/// Cross product with the specified vector.
	func cross(vector: SCNVector3) -> SCNVector3 {
		return SCNVector3(x: y * vector.z - z * vector.y, y: z * vector.x - x * vector.z, z: x * vector.y - y * vector.x)
	}
	
	/// Returns the result from projecting onto a specified vector.
	func project(onto projectionVector: SCNVector3) -> SCNVector3 {
		let scale: CGFloat = projectionVector.dot(self) / projectionVector.dot(projectionVector)
		return projectionVector * scale
	}
	
	// MARK: - Operators
	
	static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 { return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z) }
	static func += (left: inout SCNVector3, right: SCNVector3) { left = left + right }
	static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 { return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z) }
	static func -= (left: inout SCNVector3, right: SCNVector3) { left = left - right }
	static func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 { return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z) }
	static func *= (left: inout SCNVector3, right: SCNVector3) { left = left * right }
	static func * (vector: SCNVector3, scalar: CGFloat) -> SCNVector3 { return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar) }
	static func *= (vector: inout SCNVector3, scalar: CGFloat) { vector = vector * scalar }
	static func / (left: SCNVector3, right: SCNVector3) -> SCNVector3 { return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z) }
	static func /= (left: inout SCNVector3, right: SCNVector3) { left = left / right }
	static func / (vector: SCNVector3, scalar: CGFloat) -> SCNVector3 { return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar) }
	static func /= (vector: inout SCNVector3, scalar: CGFloat) { vector = vector / scalar }
}

