//
//  ClusterLeafModel.swift
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

/// A basic cluster of pseudo-leafy triangles, used for deciduous trees.
class ClusterLeafModel: LeafModel {
	
	var distanceFromLeafNode: UInt8 = 0
	var detailLevel: UInt8 = 3
	
	func shouldDrawForNode(_ node: TreeNode) -> Bool {
		return node.children.isEmpty
	}
	
	func generateTrianglesAtOrigin(verts: inout [SCNVector3], indices: inout [CInt], normals: inout [SCNVector3], colors: inout [SCNVector3], layer: String) {
		for i in 0 ..< detailLevel {
			verts.append(SCNVector3(fx: 0, fy: 0, fz: 0))
			verts.append(SCNVector3(fx: 0.3, fy: 0, fz: 0))
			verts.append(SCNVector3(fx: 0.3, fy: 0.3, fz: 0))
			verts.append(SCNVector3(fx: -0.3, fy: 0, fz: 0))
			verts.append(SCNVector3(fx: -0.3, fy: 0.3, fz: 0))
			verts.append(SCNVector3(fx: 0.2, fy: 0.4, fz: 0))
			verts.append(SCNVector3(fx: -0.2, fy: 0.4, fz: 0))
			
			normals.append(SCNVector3(fx: 0, fy: 0, fz: 1))
			normals.append(SCNVector3(fx: 0, fy: 0, fz: 1))
			normals.append(SCNVector3(fx: 0, fy: 0, fz: 1))
			normals.append(SCNVector3(fx: 0, fy: 0, fz: 1))
			normals.append(SCNVector3(fx: 0, fy: 0, fz: 1))
			normals.append(SCNVector3(fx: 0, fy: 0, fz: 1))
			normals.append(SCNVector3(fx: 0, fy: 0, fz: 1))
			
			colors.append(SCNVector3(x: 0.1, y: 0.8, z: 0.3))
			colors.append(SCNVector3(x: 0.2, y: 0.5, z: 0.3))
			colors.append(SCNVector3(x: 0.2, y: 0.5, z: 0.3))
			colors.append(SCNVector3(x: 0.1, y: 0.8, z: 0.3))
			colors.append(SCNVector3(x: 0.2, y: 0.5, z: 0.3))
			colors.append(SCNVector3(x: 0.1, y: 0.8, z: 0.3))
			colors.append(SCNVector3(x: 0.2, y: 0.5, z: 0.3))
			
			indices.append(CInt(7*i + 0))
			indices.append(CInt(7*i + 1))
			indices.append(CInt(7*i + 2))
			indices.append(CInt(7*i + 0))
			indices.append(CInt(7*i + 3))
			indices.append(CInt(7*i + 4))
			indices.append(CInt(7*i + 0))
			indices.append(CInt(7*i + 5))
			indices.append(CInt(7*i + 6))
		}
		
		for i in 0 ..< Int(detailLevel) {
			let randPitch = Float.random(in: (-Float.pi / 4.0)...(Float.pi / 4.0))
			let randRoll = Float.random(in: (-Float.pi / 4.0)...(Float.pi / 4.0))
			let randYaw = Float.random(in: (-Float.pi)...Float.pi)
			
			verts[7*i + 0].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			verts[7*i + 1].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			verts[7*i + 2].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			verts[7*i + 3].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			verts[7*i + 4].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			verts[7*i + 5].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			verts[7*i + 6].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			
			normals[7*i + 0].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			normals[7*i + 1].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			normals[7*i + 2].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			normals[7*i + 3].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			normals[7*i + 4].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			normals[7*i + 5].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
			normals[7*i + 6].rotateAtOriginWith(pitch: randPitch, roll: randRoll, yaw: randYaw)
		}
	}
	
}
