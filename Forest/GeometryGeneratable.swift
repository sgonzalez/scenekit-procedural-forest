//
//  GeometryGeneratable.swift
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

/// Implemented by types that can build geometry into a geometry object.
protocol GeometryGeneratable {
	/// Adds new geometry to the provided geometry object, in the given layer, at a point.
	func addGeometryToRawGeometry(geo: inout RawGeometry, forLayer layer: String, at: SCNVector3)
}
