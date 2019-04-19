//
//  Utilities.swift
//  Forest
//
//  Created by Santiago Gonzalez.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Cocoa
import SceneKit

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


func lerpFrom(_ start: Float, to end: Float, using t: Float) -> Float {
	return start + (end - start) * t;
}

func blerpBetween(c00: Float, c10: Float, c01: Float, c11: Float, usingX tx: Float, usingY ty: Float) -> Float {
	return lerpFrom(lerpFrom(c00, to: c10, using: tx), to: lerpFrom(c01, to: c11, using: tx), using: ty);
}


func translateVertices(verts: inout [SCNVector3], translation: SCNVector3) {
	for i in 0 ..< verts.count {
		verts[i] += translation
	}
}

func randomBetween(_ firstNum: Float, and secondNum: Float) -> Float {
	return Float(arc4random()) / Float(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
}
