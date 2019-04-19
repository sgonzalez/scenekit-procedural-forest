//
//  LeafModel.swift
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

/// Implemented by leaves.
protocol LeafModel: TriangleGenerator, Detailable {
	/// The (structure) tree distance from the (plant) leaf to a (tree structure) leaf.
	var distanceFromLeafNode: UInt8 { get set }
	/// Returns whether leaf geometry should be drawn for the given node.
	func shouldDrawForNode(_ node: TreeNode) -> Bool
}
