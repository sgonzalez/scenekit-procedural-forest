//
//  SkyGenerator.swift
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

#if os(macOS)

import Cocoa

/// A skybox generator.
class SkyGenerator {
	
	/// Returns a set of six skybox images.
	static func skyboxImages() -> [NSImage] {
		let size = CGSize(width: 512, height: 512)
	
		// Sides.
		let sideImage = NSImage(size: size)
		sideImage.lockFocus()
		let gradient = NSGradient(starting: NSColor.cyan, ending: NSColor.blue)
		gradient?.draw(in: NSRect(origin: CGPoint.zero, size: size), angle: 90)
		sideImage.unlockFocus()
		
		// Top.
		let topImage = NSImage(size: size)
		topImage.lockFocus()
		NSColor.blue.set()
		NSBezierPath.fill(NSRect(origin: .zero, size: size))
		topImage.unlockFocus()
		
		// Bottom.
		let bottomImage = NSImage(size: size)
		bottomImage.lockFocus()
		NSColor.cyan.set()
		NSBezierPath.fill(NSRect(origin: .zero, size: size))
		bottomImage.unlockFocus()
		
		return [sideImage, sideImage, topImage, bottomImage, sideImage, sideImage]
	}
	
}

#else

import UIKit

/// A skybox generator.
class SkyGenerator {
	
	/// Returns a set of six skybox images.
	static func skyboxImages() -> [UIImage] {
		let size = CGSize(width: 512, height: 512)
		let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		
		// Sides.
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = bounds
		gradientLayer.colors = [UIColor.blue.cgColor, UIColor.cyan.cgColor]
		gradientLayer.locations = [0.0, 0.5]
		UIGraphicsBeginImageContext(size)
		gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
		let sideImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		// Top.
		UIGraphicsBeginImageContext(size)
		UIColor.blue.set()
		let bez = UIBezierPath(rect: bounds)
		bez.fill()
		let topImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		// Bottom.
		UIGraphicsBeginImageContext(size)
		UIColor.cyan.set()
		bez.fill()
		let bottomImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		return [sideImage, sideImage, topImage, bottomImage, sideImage, sideImage]
	}
	
}

#endif
