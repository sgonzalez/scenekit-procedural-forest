//
//  GameViewController.swift
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
import QuartzCore

public class GameViewController: NSViewController {
	
	@IBOutlet public var gameView: SCNView!
	
	var scene: SCNScene!
	
	// Terrain constants.
	let terrainSize = 100
	let terrainScale: Float = 1
	let waterHeight: CGFloat = 3.1
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	/// Configures the scene.
    public func setup() {
        
        // Create a new scene.
        scene = SCNScene()
        
        // Add a camera to the scene.
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
		cameraNode.camera?.zFar = 400
        scene.rootNode.addChildNode(cameraNode)
        
        // Place the camera.
        cameraNode.position = SCNVector3(x: 50, y: 10, z: 70)
		
		// Create a lovely sky.
		scene.background.contents = SkyGenerator.skyboxImages();
		
		// Create and add a light to the scene.
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = .directional
		lightNode.light!.castsShadow = true
		lightNode.light!.shadowColor = NSColor.black
		lightNode.light!.shadowRadius = 1;
		lightNode.transform = SCNMatrix4Rotate(SCNMatrix4Rotate(SCNMatrix4Identity, CGFloat.pi / 4.0, 0, 0, 1), -2*CGFloat.pi / 4.0, 1, 0, 0)
		scene.rootNode.addChildNode(lightNode)

        // Ambient lighting.
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
		
		// Let's generate a world!
		generate()

        // Finish setup.
        gameView!.scene = scene
        gameView!.allowsCameraControl = true
        gameView!.showsStatistics = true
        gameView!.backgroundColor = NSColor.black
		
		// Build UI.
		setupInterfaceElements()
    }
	
	// Hard-coded UI.
	var regenButton: NSButton!
	var titleLabel: NSTextField!
	var subtitleLabel: NSTextField!
	var bodyLabel: NSTextField!
	
	/// Builds the controller's UI.
	func setupInterfaceElements() {
		// Regenerate button.
		regenButton = NSButton(title: "Generate New World", target: self, action: #selector(regen(_:)))
		gameView.addSubview(regenButton)
		regenButton.frame = CGRect(x: 20, y: 60, width: regenButton.bounds.width, height: regenButton.bounds.height)
		
		// Create labels.
		titleLabel = NSTextField(labelWithString: "Procedural World Generation")
		subtitleLabel = NSTextField(labelWithString: "by Santiago Gonzalez")
		bodyLabel = NSTextField(labelWithString: "Generate random terrain from scratch, starting from triangles.\n\nUse two-fingers on your trackpad to move and zoom. Click and drag to rotate.")
		titleLabel.font = NSFont.boldSystemFont(ofSize: 22)
		subtitleLabel.font = NSFont.boldSystemFont(ofSize: 16)
		bodyLabel.font = NSFont.systemFont(ofSize: 14)
		gameView.addSubview(titleLabel)
		gameView.addSubview(subtitleLabel)
		gameView.addSubview(bodyLabel)
		titleLabel.frame = CGRect(x: 20, y: 190, width: titleLabel.bounds.width, height: titleLabel.font!.pointSize * 2)
		subtitleLabel.frame = CGRect(x: 20, y: 165, width: subtitleLabel.bounds.width * 1.5, height: subtitleLabel.font!.pointSize * 2)
		bodyLabel.frame = CGRect(x: 20, y: 90, width: bodyLabel.bounds.width * 1.5, height: bodyLabel.font!.pointSize * 5)
	}
	
	/// Called when the user has pressed the regenerate button.
	@objc func regen(_ sender: AnyObject?) {
		generate()
	}
	
	/// Generates a new world.
	func generate() {
		// Remove previously generated world.
		for nodeToRemove in scene.rootNode.childNodes(passingTest: { node, _ in
			return node.camera == nil && node.light == nil
		}) {
			nodeToRemove.removeFromParentNode()
		}
		
		// A terrain source.
		let perlin = PerlinNoise()
		perlin.zoom = 0.5 * Float(terrainSize) / terrainScale
		perlin.persistence = 0.5
		perlin.octaves = 4
		
		// Create a terrain object.
		let terrain = Terrain(size: terrainSize, heightPalette: "TerrainPalette.png", scale: terrainScale, heightScale: 10)
		terrain.setHeightsUsing { i, j in
			let height = perlin.perlinNoise(x: Float(i), y: Float(j)) * 1.0
			return height
		}
		
		// Create a terrain node.
		let terrainGeo = terrain.geometryFor(layer: "")
		terrainGeo.firstMaterial?.isDoubleSided = true
		let terrainNode = SCNNode(geometry: terrainGeo)
		terrainNode.castsShadow = true
		scene.rootNode.addChildNode(terrainNode)
		
		
		// Add a plane of water.
		let waterGeo = SCNPlane(width: CGFloat(Float(terrainSize)*terrainScale - 1), height: CGFloat(Float(terrainSize)*terrainScale - 1))
		waterGeo.firstMaterial?.diffuse.contents = NSColor(calibratedRed: 0, green: 0, blue: 1, alpha: 0.5)
		waterGeo.firstMaterial?.isDoubleSided = true
		let water = SCNNode(geometry: waterGeo)
		water.position.x = CGFloat(Float(terrainSize)*terrainScale - 1) / 2
		water.position.y = waterHeight
		water.position.z = CGFloat(Float(terrainSize)*terrainScale - 1) / 2
		water.rotation.w = CGFloat.pi / 2.0
		water.rotation.x = -1.0
		scene.rootNode.addChildNode(water)
		
		// Put some nice trees in.
		populateTrees(on: terrain)
		
		// Let's add some grass.
		populateGrass(on: terrain)
	}
	
	/// Adds trees to the world.
	func populateTrees(on terrain: Terrain) {
		// Find valid positions for trees.
		let desiredTrees = 100
		var treePositions = [SCNVector3]()
		var attempts = 0
		while treePositions.count < desiredTrees {
			let x = CGFloat.random(in: 0...(CGFloat(terrainSize)*CGFloat(terrainScale) - 1))
			let y = CGFloat.random(in: 0...(CGFloat(terrainSize)*CGFloat(terrainScale) - 1))
			if terrain.interpolatedHeightAt(x: Float(x), y: Float(y)) > Float(waterHeight) {
				let candidate = SCNVector3(x: x, y: 0, z: y)
				var valid = true
				for position in treePositions {
					if candidate.distance(to: position) < 3 {
						valid = false
					}
				}
				if valid {
					treePositions.append(candidate)
				}
			}
			attempts += 1
			guard attempts <= desiredTrees * 100 else { break }
		}
		
		// Create trees.
		var treeLayerGeo = RawGeometry()
		var leafLayerGeo = RawGeometry()
		for xyz in treePositions {
			let tree = Tree()
			let rootPosition = SCNVector3(x: xyz.x, y: CGFloat(terrain.interpolatedHeightAt(x: Float(xyz.x), y: Float(xyz.z))), z: xyz.z)
			tree.addGeometryToRawGeometry(geo: &treeLayerGeo, forLayer: "tree", at: rootPosition)
			tree.addGeometryToRawGeometry(geo: &leafLayerGeo, forLayer: "leaf", at: rootPosition)
		}
		
		// Add node with tree geometry.
		treeLayerGeo.flattenTrianglesGeometries()
		let treeLayerSCNGeo = treeLayerGeo.generateGeometry()
		let treeLayerNode = SCNNode(geometry: treeLayerSCNGeo)
		treeLayerNode.castsShadow = true
		scene.rootNode.addChildNode(treeLayerNode)
		
		// Add node with leaf geometry.
		leafLayerGeo.flattenTrianglesGeometries()
		let leafLayerSCNGeo = leafLayerGeo.generateGeometry()
		leafLayerSCNGeo.materials.forEach({ $0.isDoubleSided = true })
		let leafLayerNode = SCNNode(geometry: leafLayerSCNGeo)
		leafLayerNode.castsShadow = true
		scene.rootNode.addChildNode(leafLayerNode)
	}
	
	/// Adds grass to the world.
	func populateGrass(on terrain: Terrain) {
		// Find valid positions for grass.
		let desiredGrassInstances = 500
		var grassPositions = [SCNVector3]()
		var attempts = 0
		while grassPositions.count < desiredGrassInstances {
			let x = CGFloat.random(in: 0...(CGFloat(terrainSize)*CGFloat(terrainScale) - 1))
			let y = CGFloat.random(in: 0...(CGFloat(terrainSize)*CGFloat(terrainScale) - 1))
			let lerpHeight = terrain.interpolatedHeightAt(x: Float(x), y: Float(y))
			if lerpHeight > Float(waterHeight) && lerpHeight < Float(waterHeight) * 1.5 {
				let candidate = SCNVector3(x: x, y: 0, z: y)
				var valid = true
				for position in grassPositions {
					if candidate.distance(to: position) < 3 {
						valid = false
					}
				}
				if valid {
					grassPositions.append(candidate)
				}
			}
			attempts += 1
			guard attempts <= desiredGrassInstances * 100 else { break }
		}
		
		// Create grass blades.
		var grassLayerGeo = RawGeometry()
		for xyz in grassPositions {
			let grass = Grass()
			let rootPosition = SCNVector3(x: xyz.x, y: CGFloat(terrain.interpolatedHeightAt(x: Float(xyz.x), y: Float(xyz.z))), z: xyz.z)
			grass.addGeometryToRawGeometry(geo: &grassLayerGeo, forLayer: "grass", at: rootPosition)
		}
		
		// Create a node for the grass.
		let grassLayerSCNGeo = grassLayerGeo.generateGeometry()
		grassLayerSCNGeo.materials.forEach({ $0.isDoubleSided = true })
		let grassLayerNode = SCNNode(geometry: grassLayerSCNGeo)
		scene.rootNode.addChildNode(grassLayerNode)
	}

}
