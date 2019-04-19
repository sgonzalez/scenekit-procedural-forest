//
//  NeedleSkirtLeafModel.swift
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

/// A needle skirt, intended to emulate vertical slices of pine tree needles.
class NeedleSkirtLeafModel: LeafModel {
	/// The skirt's length.
	var length: Float
	/// Skirt taper, represented as a scaling coefficient.
	var taper: Float
	/// The skirt's base width.
	var baseWidth: Float
	
	var distanceFromLeafNode: UInt8 = 0
	var detailLevel: UInt8 = 8
	
	init() {
		length = 0.5
		taper = 0.1
		baseWidth = 1
	}
	
	func shouldDrawForNode(_ node: TreeNode) -> Bool {
		distanceFromLeafNode = node.distanceFromAnyLeaf()
		baseWidth = 0.5 * Float(distanceFromLeafNode + 1)
		return true
	}
	
	func generateTrianglesAtOrigin(verts: inout [SCNVector3], indices: inout [CInt], normals: inout [SCNVector3], colors: inout [SCNVector3], layer: String) {
		let angleOffset = Float.random(in: 0...(Float.pi / 4.0))
		for i in 0 ..< detailLevel {
			let angle = angleOffset + Float.pi * 2.0 * Float(i) / Float(detailLevel)
			let x = cos(angle) * baseWidth / 2
			let y = sin(angle) * baseWidth / 2
			
			let angle2 = angleOffset + Float.pi * 2.0 * Float((i+1)%detailLevel) / Float(detailLevel)
			let x2 = cos(angle2) * baseWidth / 2
			let y2 = sin(angle2) * baseWidth / 2
			
			verts.append(SCNVector3(fx: x, fy: -length, fz: y))
			verts.append(SCNVector3(fx: x*taper, fy: 0, fz: y*taper))
			verts.append(SCNVector3(fx: x2*taper, fy: 0, fz: y2*taper))
			verts.append(SCNVector3(fx: x2, fy: -length, fz: y2))
			
			let normalY = baseWidth*(1-taper)/length
			
			normals.append(SCNVector3(fx: x, fy: normalY, fz: y).normalized)
			normals.append(SCNVector3(fx: x, fy: normalY, fz: y).normalized)
			normals.append(SCNVector3(fx: x2, fy: normalY, fz: y2).normalized)
			normals.append(SCNVector3(fx: x2, fy: normalY, fz: y2).normalized)
			
			colors.append(SCNVector3(x: 0.1, y: 0.5, z: 0.3))
			colors.append(SCNVector3(x: 0.2, y: 0.3, z: 0.3))
			colors.append(SCNVector3(x: 0.1, y: 0.5, z: 0.3))
			colors.append(SCNVector3(x: 0.2, y: 0.3, z: 0.3))
			
			indices.append(CInt(4*i + 0))
			indices.append(CInt(4*i + 1))
			indices.append(CInt(4*i + 2))
			indices.append(CInt(4*i + 3))
			indices.append(CInt(4*i + 0))
			indices.append(CInt(4*i + 2))
		}
	}
	
}
