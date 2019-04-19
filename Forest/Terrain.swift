//
//  Terrain.swift
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

import Cocoa
import SceneKit

/// A height-mapped terrain.
class Terrain {
	/// The terrain's heights (2D data mapped down to 1D).
	var points: [Float]
	/// The terrain's resolution.
	let size: Int
	/// The terrain's scale.
	let scale: Float
	/// A vertical scaling factor.
	let heightScale: Float
	/// Color palette for varying heights.
	let heightPalette: [NSColor]
	
	/// Creates a new terrain.
	init(size: Int, heightPalette paletteFile: String, scale: Float, heightScale: Float) {
		self.size = size
		self.scale = scale
		self.heightScale = heightScale
		self.points = [Float](repeating: 0, count: size*size)
		self.heightPalette = colorsFromPalette(named: paletteFile)
	}
	
	/// Sets the heightmap value at a point.
	func set(x: Int, y: Int, height value: Float) {
		points[y * size + x] = value
	}
	
	/// Recalculates the heightmap using the provided closure.
	func setHeightsUsing(closure: (Int, Int) -> Float) {
		for i in 0 ..< size*size {
			let x = i / size
			let y = i % size
			set(x: x, y: y, height: closure(x, y))
		}
	}
	
	/// Returns the heightmap value at a point.
	func heightAt(x: Int, y: Int) -> Float {
		return points[Int(Float(y)/scale) * size + Int(Float(x)/scale)]
	}
	
	/// Returns the heightmap value at a point, while checking bounds and
	/// falling back to a default value.
	func getHeightSafely(x: Int, y: Int, safeDefault: Float) -> Float {
		if x >= 0 && y >= 0 && x < size && y < size {
			return heightAt(x: x, y: y)
		} else {
			return safeDefault
		}
	}
	
	/// Returns the interpolated height for an off-heightmap point.
	func interpolatedHeightAt(x: Float, y: Float) -> Float {
		if x >= 0 && y >= 0 && x/scale < Float(size) && y/scale < Float(size) {
			// Get the heights of the vertices surrounding the specified coordinates.
			let corner00 = heightAt(x: Int(floor(x/scale)), y: Int(floor(y/scale)))
			let corner01 = heightAt(x: Int(floor(x/scale)), y: Int(ceil(y/scale)))
			let corner10 = heightAt(x: Int(ceil(x/scale)), y: Int(floor(y/scale)))
			let corner11 = heightAt(x: Int(ceil(x/scale)), y: Int(ceil(y/scale)))
			
			// Perform bilinear interpolation.
			return blerpBetween(c00: corner00, c10: corner10, c01: corner01, c11: corner11, usingX: x/scale - floor(x/scale), usingY: y/scale - floor(y/scale)) * heightScale
		} else {
			return 0
		}
	}
	
	func geometryFor(layer: String, at: SCNVector3 = SCNVector3Zero) -> SCNGeometry {
		var verts: [SCNVector3] = Array()
		var indices: [CInt] = Array()
		var normals: [SCNVector3] = Array()
		var colors: [SCNVector3] = Array()
		
		generateTrianglesAtOrigin(verts: &verts, indices: &indices, normals: &normals, colors: &colors)
		
		let colorData = Data(bytes: colors, count: MemoryLayout<SCNVector3>.size * colors.count)
		let srcColors = SCNGeometrySource(data: colorData, semantic: .color, vectorCount: colors.count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<CGFloat>.size, dataOffset: 0, dataStride: MemoryLayout<SCNVector3>.size)
		
		let srcNormals = SCNGeometrySource(normals: normals)
		let srcVertices = SCNGeometrySource(vertices: verts)
		
		let ele = SCNGeometryElement(
			indices: indices,
			primitiveType: .triangleStrip
		)
		
		debugPrint((indices.count, verts.count, indices.count, normals.count, colors.count, colorData.count))
		debugPrint((MemoryLayout<SCNVector3>.size, srcVertices.data.count))
		
		return SCNGeometry(sources: [srcVertices, srcNormals, srcColors], elements: [ele])
	}
	
	
	
	func generateTrianglesAtOrigin(verts: inout [SCNVector3], indices: inout [CInt], normals: inout [SCNVector3], colors: inout [SCNVector3]) {
		for j in 0 ..< size-1 {
			for i in 0 ..< size {
				let isEvenRow = j % 2 == 0
				let iAlternating = isEvenRow ? size - i - 1 : i // swap direction of i each row
				
				let height = heightAt(x: i, y: j)
				let nextHeightJ = getHeightSafely(x: i, y: j+1, safeDefault: height)
				
				verts.append(SCNVector3(x: CGFloat(i)*CGFloat(scale), y: CGFloat(height*heightScale), z: CGFloat(j)*CGFloat(scale)))
				verts.append(SCNVector3(x: CGFloat(i)*CGFloat(scale), y: CGFloat(nextHeightJ*heightScale), z: CGFloat(j+1)*CGFloat(scale)))
				
				normals.append(normalVectorAt(x: i+1, y: j))
				normals.append(normalVectorAt(x: i, y: j+1))
				normals.append(normalVectorAt(x: i, y: j))
				normals.append(normalVectorAt(x: i+1, y: j+1))
				
				colors.append(colorVectorFor(normalizedHeight: height))
				colors.append(colorVectorFor(normalizedHeight: height))
				colors.append(colorVectorFor(normalizedHeight: nextHeightJ))
				colors.append(colorVectorFor(normalizedHeight: nextHeightJ))
				
				if isEvenRow {
					indices.append(CInt(2*(j*size + iAlternating)+1))
					indices.append(CInt(2*(j*size + iAlternating)))
				} else {
					indices.append(CInt(2*(j*size + iAlternating)))
					indices.append(CInt(2*(j*size + iAlternating)+1))
				}
				
			}
		}
	}
	
	/// Returns the normal vector for the given point on the terrain.
	private func normalVectorAt(x: Int, y: Int) -> SCNVector3 {
		let h = getHeightSafely(x: x, y: y, safeDefault: 0)
		let hL = getHeightSafely(x: x - 1, y: y, safeDefault: h)
		let hR = getHeightSafely(x: x + 1, y: y, safeDefault: h)
		let hD = getHeightSafely(x: x, y: y + 1, safeDefault: h)
		let hU = getHeightSafely(x: x, y: y - 1, safeDefault: h)
		
		var normal = SCNVector3()
		normal.x = CGFloat(hL - hR)
		normal.y = 2.0
		normal.z = CGFloat(hD - hU)
		return normal.normalized
	}
	
	/// Returns the color vector for the specified height.
	private func colorVectorFor(normalizedHeight height: Float) -> SCNVector3 {
		var r: CGFloat = 1.0
		var g: CGFloat = 1.0
		var b: CGFloat = 1.0
		var a: CGFloat = 1.0
		
		let colorIndex: Int = max(min(Int(1.5 * height * 255), heightPalette.count-1), 1)
		let color = heightPalette[colorIndex]
		color.getRed(&r, green: &g, blue: &b, alpha: &a)
		
		return SCNVector3(x: r, y: g, z: b)
	}
}

