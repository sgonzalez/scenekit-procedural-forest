//
//  PerlinNoise.swift
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

/// A Perlin noise generator.
/// Loosely inspired by `https://github.com/lachlanhurst/perlin-swift`.
class PerlinNoise {
	
	// Configurable parameters.
	var octaves: Int
	var persistence: Float
	var zoom: Float
	
	static let permutationSize = 256
	
	var permutations: [Int]
	
	init() {
		permutations = (0..<PerlinNoise.permutationSize).map { _ in Int(arc4random() & 0xff) }
		octaves = 1
		persistence = 1.0
		zoom = 1.0
	}
	
	/// Returns the value for the noise function at the given point.
	func smoothNoise(x: Float, y: Float) -> Float {
		let x0 = Int(x > 0 ? x : x - 1)
		let y0 = Int(y > 0 ? y : y - 1)
		let x1 = x0 + 1
		let y1 = y0 + 1
		
		var dx0 = x - Float(x0)
		var dy0 = y - Float(y0)
		let dx1 = x - Float(x1)
		let dy1 = y - Float(y1)
		
		// Calculate gradients.
		var g00 = PerlinNoise.gradient[gradientAt(i: x0, j: y0)]
		var g01 = PerlinNoise.gradient[gradientAt(i: x0, j: y1)]
		var g10 = PerlinNoise.gradient[gradientAt(i: x1, j: y0)]
		var g11 = PerlinNoise.gradient[gradientAt(i: x1, j: y1)]
		
		let b00 = dotProductI(x0: dx0, x1: g00[0], y0: dy0, y1: g00[1])
		let b01 = dotProductI(x0: dx0, x1: g01[0], y0: dy1, y1: g01[1])
		let b10 = dotProductI(x0: dx1, x1: g10[0], y0: dy0, y1: g10[1])
		let b11 = dotProductI(x0: dx1, x1: g11[0], y0: dy1, y1: g11[1])
		
		dx0 = spline(value: dx0)
		dy0 = spline(value: dy0)
		
		// Blerp!
		return blerpBetween(c00: b00, c10: b01, c01: b10, c11: b11, usingX: dy0, usingY: dx0)
		
	}
	
	/// Returns the layered, Perlin noise value for the given point.
	func perlinNoise(x: Float, y: Float) -> Float {
		return (0..<octaves).reduce(0) { prev, octave in
			let frequency = powf(2, Float(octave)) / zoom
			let amplitude = powf(persistence, Float(octave))
			return prev + smoothNoise(x: x * frequency, y: y * frequency) * amplitude
		}
	}
	
	// MARK: - Internals
	
	private func productOf(a: Float, b: Int8) -> Float {
		if b > 0 {
			return a
		} else if b < 0 {
			return -a
		} else {
			return 0
		}
	}
	
	private func dotProductI(x0: Float, x1: Int8, y0: Float, y1: Int8) -> Float {
		return productOf(a: x0, b: x1) + productOf(a: y0, b: y1)
	}
	
	private func spline(value: Float) -> Float {
		return pow(value, 3) * (6 * pow(value, 2) - 15 * value + 10)
	}
	
	/// A lovely cheat-sheet for finite differences.
	private static let gradient: [[Int8]] = [
		[ 1, 1], [ 1, 1], [ 1, 0], [ 0, 1],
		[ 1, 1], [ 1, 1], [ 1, 0], [ 0, 1],
		[ 1,-1], [ 1,-1], [ 1, 0], [ 0, 1],
		[ 1,-1], [ 1,-1], [ 1, 0], [ 0, 1],
		[-1, 1], [-1, 1], [-1, 0], [ 0,-1],
		[-1, 1], [-1, 1], [-1, 0], [ 0,-1],
		[-1,-1], [-1,-1], [-1, 0], [ 0,-1],
		[-1,-1], [-1,-1], [-1, 0], [ 0,-1]
	]
	
	func gradientAt(i: Int, j: Int) -> Int {
		return permutations[(j + permutations[i & 0xff]) & 0xff] & 0x1f // magic.
	}
}
