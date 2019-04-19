//
//  Grass.swift
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

import SceneKit

/// A grassy outcropping.
class Grass: TriangleGenerator, GeometryGeneratable {
	
	/// The number of grass blades in this clump.
	static let bladeCount: Int = 1
	
	func generateTrianglesAtOrigin(verts: inout [SCNVector3], indices: inout [CInt], normals: inout [SCNVector3], colors: inout [SCNVector3], layer: String) {
		for i in 0 ..< Grass.bladeCount {
			verts.append(SCNVector3(fx: 0, fy: 0, fz: 0))
			verts.append(SCNVector3(fx: 0.1, fy: 0, fz: 0))
			verts.append(SCNVector3(fx: 0.1, fy: 0.5, fz: 0))
			
			normals.append(SCNVector3(fx: 0, fy: 0, fz: 1))
			normals.append(SCNVector3(fx: 0, fy: 0, fz: 1))
			normals.append(SCNVector3(fx: 0, fy: 0, fz: 1))
			
			colors.append(SCNVector3(x: 0.8, y: 0.8, z: 0.3))
			colors.append(SCNVector3(x: 0.5, y: 0.5, z: 0.3))
			colors.append(SCNVector3(x: 0.5, y: 0.5, z: 0.3))
			
			indices.append(CInt(7*i + 0))
			indices.append(CInt(7*i + 1))
			indices.append(CInt(7*i + 2))
		}
		
		for i in 0 ..< Grass.bladeCount {
			let randPitch = Float.random(in: (-Float.pi / 4.0)...(Float.pi / 4.0))
			let randRoll = Float.random(in: (-Float.pi / 4.0)...(Float.pi / 4.0))
			let randYaw = Float.random(in: (-Float.pi)...Float.pi)
			
			verts[7*i + 0].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			verts[7*i + 1].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			verts[7*i + 2].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			
			normals[7*i + 0].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			normals[7*i + 1].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			normals[7*i + 2].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
		}
	}
	
	
	func addGeometryToRawGeometry(geo: inout RawGeometry, forLayer layer: String, at: SCNVector3) {
		var verts: [SCNVector3] = Array()
		var indices: [CInt] = Array()
		var normals: [SCNVector3] = Array()
		var colors: [SCNVector3] = Array()
		
		generateTrianglesAtOrigin(verts: &verts, indices: &indices, normals: &normals, colors: &colors, layer: layer)
		
		translateVertices(verts: &verts, translation: at)
		
		geo.addGeometry(type: .triangles, verts: verts, indices: indices, normals: normals, colors: colors, at: at)
	}
	
}
