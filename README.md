
# SceneKit Procedural Forest
## by Santiago Gonzalez

This exploratory project is the result of me trying to make a super basic, procedurally generated, 3D world using only Apple's high-level SceneKit framework. You won't find a lick of OpenGL in this repository. That being said, if you were to actually build something like this for a "real project", you would definitely want to use whatever fast graphics API you know and (maybe) love, such as Metal.

![Screenshot](https://github.com/sgonzalez/scenekit-procedural-forest/raw/master/Screenshot.png "Screenshot")

## Features

* Natural trackpad gestures for navigation.
* Heightmapped terrain, generated using Perlin noise.
* Gangly deciduous trees.
* Pine trees.
* Delightfully unrealistic water.
* Grass (i.e., green triangles scattered throughout).
* Lovely graphical artifacts.

## Compiling

Just open the `Forest` project in Xcode and run. This project builds for macOS, though the code should run on iOS / tvOS with minimal changes. You don't need to worry about dependencies, there are none.

## Additional Notes

I have tried my best to have plenty of doc-comments, but some parts of the code will be ugly and/or inefficient, since things were hacked together very quickly. There are some long functions. The code could be more DRY. The geometry protocols, in particular, could be polished / refactored to make more sense.

I love Swift's type system (for the most part (let's not talk about heterogenous lists)), but the amount of `CGFloat` casting I had to do is ridiculous.

Ultimately, this was just a fun proof-of-concept; don't expect Michelangelo-quality code (but don't worry, it's ok for the most part). :)

This project is licensed under GPL-3.0.
