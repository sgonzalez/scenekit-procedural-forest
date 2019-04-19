//
//  TrianglesGeometryGeneratable.swift
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

/// A reference implementation for triangles generation.
class TrianglesGeometryGeneratable: GeometryGeneratable {
	
	func addGeometryToRawGeometry(geo: inout RawGeometry, forLayer layer: String = "", at: SCNVector3 = SCNVector3Zero) {
		var verts: [SCNVector3] = Array()
		var indices: [CInt] = Array()
		var normals: [SCNVector3] = Array()
		var colors: [SCNVector3] = Array()
		
		generateTrianglesAtOrigin(verts: &verts, indices: &indices, normals: &normals, colors: &colors, layer: layer)
		translateVertices(verts: &verts, translation: at)
		geo.addGeometry(type: .triangles, verts: verts, indices: indices, normals: normals, colors: colors, at: at)
	}
	
	func generateTrianglesAtOrigin(verts: inout [SCNVector3], indices: inout [CInt], normals: inout [SCNVector3], colors: inout [SCNVector3], layer: String = "") {
		
		verts.append(SCNVector3(x: 0, y: 1, z: 0))
		verts.append(SCNVector3(x: 0, y: 0, z: 0))
		verts.append(SCNVector3(x: 1, y: 0, z: 0))
		
		normals.append(SCNVector3(x: 0, y: 0, z: 1))
		normals.append(SCNVector3(x: 0, y: 0, z: 1))
		normals.append(SCNVector3(x: 0, y: 0, z: 1))
		
		colors.append(SCNVector3(x: 1, y: 0, z: 0))
		colors.append(SCNVector3(x: 0, y: 1, z: 0))
		colors.append(SCNVector3(x: 0, y: 0, z: 1))
		
		indices.append(CInt(0))
		indices.append(CInt(1))
		indices.append(CInt(2))
	}
	
}
