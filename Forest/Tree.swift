//
//  Tree.swift
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

/// A single tree (the plant kind).
class Tree: GeometryGeneratable {
	
	/// The tree's (plant) tree's (structure) root.
	var rootNode = TreeNode()
	
	init() {
		if arc4random() % 2 == 0 {
			rootNode.length = Float.random(in: 1.7...2.3)
			generateRandomChildrenForParent(&rootNode, branchDivergence: Float.pi / 4.0)
			rootNode.propagateTransformationsRecurively()
			rootNode.setLeafModelRecursively(ClusterLeafModel())
		} else {
			rootNode.length = Float.random(in: 0.7...1)
			generateRandomChildrenForParent(&rootNode, depth: 4, branching: 0)
			rootNode.propagateTransformationsRecurively()
			rootNode.setLeafModelRecursively(NeedleSkirtLeafModel())
		}
	}
	
	func generateRandomChildrenForParent(_ parent: inout TreeNode, depth: Int = 2, branching: Int = 2, branchDivergence: Float = 0) {
		if depth == 0 {
			return
		}
		for _ in 0...branching {
			var child = TreeNode()
			child.length = Float.random(in: (parent.length * 0.65)...(parent.length * 0.8))
			child.baseWidth = parent.baseWidth * parent.taper * 0.9
			child.taper = 0.5
			child.relativeAngleX = Float.random(in: (-branchDivergence)...branchDivergence)
			child.relativeAngleY = Float.random(in: (-branchDivergence)...branchDivergence)
			
			generateRandomChildrenForParent(&child, depth: depth - 1, branching: branching, branchDivergence: branchDivergence)
			
			parent.addChild(&child)
			
		}
	}
	
	func addGeometryToRawGeometry(geo: inout RawGeometry, forLayer layer: String, at: SCNVector3) {
		rootNode.addGeometryToRawGeometry(geo: &geo, forLayer: layer, at: at)
	}
	
}
