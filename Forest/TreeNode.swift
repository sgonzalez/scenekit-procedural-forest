//
//  TreeNode.swift
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

/// Represents a branch element in a (plant) tree's, (structure) tree.
struct TreeNode: GeometryGeneratable, Detailable {
	
	/// The branch's length.
	var length: Float
	/// Taper, represented as a scaling factor.
	var taper: Float
	/// The branch's root width.
	var baseWidth: Float
	/// Node children.
	var children: [TreeNode]
	/// X Euler rotation, relative to the parent's coordinate system.
	var relativeAngleX: Float
	/// Y Euler rotation, relative to the parent's coordinate system.
	var relativeAngleY: Float
	
	/// Level of detail.
	var detailLevel: UInt8 = 8
	
	/// This node's corresponding leaf model.
	var leafModel: LeafModel
	
	
	// Calculated properties.
	var cumulativeAngleX: Float = 0
	var cumulativeAngleY: Float = 0
	var rootPosition: SCNVector3 = SCNVector3Zero
	
	init() {
		length = 2
		taper = 0.5
		baseWidth = 0.5
		children = []
		relativeAngleX = 0
		relativeAngleY = 0
		leafModel = ClusterLeafModel()
	}
	
	/// Adds a child to the node.
	mutating func addChild(_ child: inout TreeNode) {
		child.cumulativeAngleX = cumulativeAngleX + relativeAngleX
		child.cumulativeAngleY = cumulativeAngleY + relativeAngleY
		var lengthVector = SCNVector3(x: 0, y: CGFloat(length), z: 0)
		lengthVector.rotateAtOriginWith(pitch: child.cumulativeAngleX, roll: child.cumulativeAngleY)
		child.rootPosition = rootPosition + lengthVector
		children.append(child)
	}
	
	/// Update coordinate systems.
	mutating func propagateTransformationsRecurively() {
		for i in 0 ..< children.count {
			children[i].cumulativeAngleX = cumulativeAngleX + relativeAngleX
			children[i].cumulativeAngleY = cumulativeAngleY + relativeAngleY
			var lengthVector = SCNVector3(x: 0, y: CGFloat(length), z: 0)
			lengthVector.rotateAtOriginWith(pitch: children[i].cumulativeAngleX, roll: children[i].cumulativeAngleY)
			children[i].rootPosition = rootPosition + lengthVector
			
			children[i].propagateTransformationsRecurively()
		}
	}
	
	/// Propagates the leaf model down the tree.
	mutating func setLeafModelRecursively(_ model: LeafModel) {
		leafModel = model
		for i in 0 ..< children.count {
			children[i].setLeafModelRecursively(model)
		}
	}
	
	func distanceFromAnyLeaf() -> UInt8 {
		if children.isEmpty {
			return 0
		} else {
			return children[0].distanceFromAnyLeaf() + 1
		}
	}
	
	
	
	func addGeometryToRawGeometry(geo: inout RawGeometry, forLayer layer: String, at: SCNVector3) {
		var verts: [SCNVector3] = Array()
		var indices: [CInt] = Array()
		var normals: [SCNVector3] = Array()
		var colors: [SCNVector3] = Array()

		if layer == "tree" {
			generateLocalTriangles(verts: &verts, indices: &indices, normals: &normals, colors: &colors)
			
			for i in 0 ..< verts.count {
				verts[i].rotateAtOriginWith(pitch: cumulativeAngleX + relativeAngleX, roll: cumulativeAngleY + relativeAngleY)
				verts[i] += rootPosition
			}
			for i in 0 ..< normals.count {
				normals[i].rotateAtOriginWith(pitch: cumulativeAngleX + relativeAngleX, roll: cumulativeAngleY + relativeAngleY)
			}
			
			translateVertices(verts: &verts, translation: at)
			geo.addGeometry(type: .triangles, verts: verts, indices: indices, normals: normals, colors: colors, at: at)
		} else if layer == "leaf" && leafModel.shouldDrawForNode(self) {
			generateLocalLeaf(verts: &verts, indices: &indices, normals: &normals, colors: &colors)
			
			for i in 0 ..< verts.count {
				verts[i].rotateAtOriginWith(pitch: cumulativeAngleX + relativeAngleX, roll: cumulativeAngleY + relativeAngleY)
				verts[i] += rootPosition
				var lengthVector = SCNVector3(x: 0, y: CGFloat(length), z: 0)
				lengthVector.rotateAtOriginWith(pitch: cumulativeAngleX + relativeAngleX, roll: cumulativeAngleY + relativeAngleY)
				verts[i] += lengthVector
			}
			for i in 0 ..< normals.count {
				normals[i].rotateAtOriginWith(pitch: cumulativeAngleX + relativeAngleX, roll: cumulativeAngleY + relativeAngleY)
			}
			
			translateVertices(verts: &verts, translation: at)
			geo.addGeometry(type: .triangles, verts: verts, indices: indices, normals: normals, colors: colors, at: at)
		}
		
		
		
		for child in children {
			child.addGeometryToRawGeometry(geo: &geo, forLayer: layer, at: at)
		}
	}
	
	func generateTrianglesAtOrigin(verts: inout [SCNVector3], indices: inout [CInt], normals: inout [SCNVector3], colors: inout [SCNVector3], layer: String) {
		generateLocalTriangles(verts: &verts, indices: &indices, normals: &normals, colors: &colors)
		
		for child in children {
			var newVerts: [SCNVector3] = Array()
			var newNormals: [SCNVector3] = Array()
			
			child.generateTrianglesAtOrigin(verts: &newVerts, indices: &indices, normals: &newNormals, colors: &colors, layer: layer)
			
//			for var v in newVerts {
//				v.rotateAtOriginWith(pitch: cumulativeAngleX + relativeAngleX, roll: cumulativeAngleY + relativeAngleY)
//				v += rootPosition
//			}
//			for var n in newNormals {
//				n.rotateAtOriginWith(pitch: cumulativeAngleX + relativeAngleX, roll: cumulativeAngleY + relativeAngleY)
//			}
			
			verts += newVerts
			normals += newNormals
			
		}
	}
	
	
	func generateLocalLeaf(verts: inout [SCNVector3], indices: inout [CInt], normals: inout [SCNVector3], colors: inout [SCNVector3]) {
		leafModel.generateTrianglesAtOrigin(verts: &verts, indices: &indices, normals: &normals, colors: &colors, layer: "leaf")
	}
	
	func generateLocalTriangles(verts: inout [SCNVector3], indices: inout [CInt], normals: inout [SCNVector3], colors: inout [SCNVector3]) {
		for i in 0 ..< detailLevel {
			let angle = Float.pi * 2.0 * Float(i) / Float(detailLevel)
			let x = cos(angle) * baseWidth / 2
			let y = sin(angle) * baseWidth / 2
			
			let angle2 = Float.pi * 2.0 * Float((i+1)%detailLevel) / Float(detailLevel)
			let x2 = cos(angle2) * baseWidth / 2
			let y2 = sin(angle2) * baseWidth / 2
			
			verts.append(SCNVector3(fx: x, fy: 0, fz: y))
			verts.append(SCNVector3(fx: x*taper, fy: length, fz: y*taper))
			verts.append(SCNVector3(fx: x2*taper, fy: length, fz: y2*taper))
			verts.append(SCNVector3(fx: x2, fy: 0, fz: y2))
			
			let normalY = baseWidth*(1-taper)/length
			
			normals.append(SCNVector3(fx: x, fy: normalY, fz: y).normalized)
			normals.append(SCNVector3(fx: x, fy: normalY, fz: y).normalized)
			normals.append(SCNVector3(fx: x2, fy: normalY, fz: y2).normalized)
			normals.append(SCNVector3(fx: x2, fy: normalY, fz: y2).normalized)
			
			colors.append(SCNVector3(x: 0.6, y: 0.3, z: 0))
			colors.append(SCNVector3(x: 0.5, y: 0.5, z: 0))
			colors.append(SCNVector3(x: 0.5, y: 0.5, z: 0))
			colors.append(SCNVector3(x: 0.6, y: 0.3, z: 0))
			
			indices.append(CInt(4*i + 0))
			indices.append(CInt(4*i + 1))
			indices.append(CInt(4*i + 2))
			indices.append(CInt(4*i + 3))
			indices.append(CInt(4*i + 0))
			indices.append(CInt(4*i + 2))
		}
	}
}
