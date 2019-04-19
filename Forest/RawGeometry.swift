//
//  RawGeometry.swift
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

/// A representation of geometry in its most basic form: vertices, normal
/// vectors, and colors.
class RawGeometry {
	/// Vertices.
	var verts: [SCNVector3] = Array()
	/// Normal vectors.
	var normals: [SCNVector3] = Array()
	/// RGB colors.
	var colors: [SCNVector3] = Array()
	
	var elements: [SCNGeometryElement] = Array()
	
	func addGeometry(type: SCNGeometryPrimitiveType,
					 verts: [SCNVector3],
					 indices: [CInt],
					 normals: [SCNVector3],
					 colors: [SCNVector3],
					 at translation: SCNVector3 = SCNVector3Zero) {
		var correctedIndices = [CInt]()
		for index in indices {
			correctedIndices.append(index + CInt(self.verts.count)) // we need to shift indices since self.verts may not be empty
		}
		
		self.verts += verts
		self.normals += normals
		self.colors += colors
		
		let element = SCNGeometryElement(indices: correctedIndices, primitiveType: type)
		self.elements.append(element)
	}
	
	/// Combines `.triangles` geometries together for efficiency.
	func flattenTrianglesGeometries() {
		let newIndices = NSMutableData()
		var countIndices = 0
		for element in elements {
			if element.primitiveType == .triangles {
				newIndices.append(element.data)
				countIndices += element.primitiveCount
			}
		}
		
		elements = elements.filter { $0.primitiveType != .triangles } // remove all Triangles elements
		
		let element = SCNGeometryElement(
			data: newIndices as Data,
			primitiveType: .triangles,
			primitiveCount: countIndices / 3,
			bytesPerIndex: MemoryLayout<CInt>.size
		)
		self.elements.append(element)
	}
	
	func generateGeometry(at: SCNVector3 = SCNVector3Zero) -> SCNGeometry {
		let colorData = Data(bytes: colors, count: MemoryLayout<SCNVector3>.size * colors.count)
		let srcColors = SCNGeometrySource(data: colorData, semantic: .color, vectorCount: colors.count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<CGFloat>.size, dataOffset: 0, dataStride: MemoryLayout<SCNVector3>.size)
		
		let srcNormals = SCNGeometrySource(normals: normals)
		let srcVertices = SCNGeometrySource(vertices: verts)
		
		return SCNGeometry(sources: [srcColors, srcNormals, srcVertices], elements: elements)
	}
}
