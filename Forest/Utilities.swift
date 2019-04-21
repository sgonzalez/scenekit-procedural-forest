//
//  Utilities.swift
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

import Cocoa
import SceneKit

/// Returns an array of colors from the 1D image with the specified name.
func colorsFromPalette(named palletName: String) -> [NSColor] {
	var loadedColors = [NSColor()]
	guard let image = NSImage(named: palletName) else { return loadedColors }
	guard let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!) else { return loadedColors }
	for x in 0 ..< Int(bitmap.size.width) {
		if let color = bitmap.colorAt(x: x, y: 0) {
			if let convertedColor = color.usingColorSpace(.genericRGB) {
				loadedColors.append(convertedColor)
			}
		}
		
	}
	return loadedColors
}

/// Linear interpolation.
func lerpFrom(_ start: Float, to end: Float, using t: Float) -> Float {
	return start + (end - start) * t;
}

/// Bilinear interpolation.
func blerpBetween(c00: Float, c10: Float, c01: Float, c11: Float, usingX tx: Float, usingY ty: Float) -> Float {
	return lerpFrom(lerpFrom(c00, to: c10, using: tx), to: lerpFrom(c01, to: c11, using: tx), using: ty);
}


/// Adds the translation vector to every vector in the array.
func translateVertices(verts: inout [SCNVector3], translation: SCNVector3) {
	for i in 0 ..< verts.count {
		verts[i] += translation
	}
}
