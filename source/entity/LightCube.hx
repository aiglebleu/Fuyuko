package entity;

import flixel.FlxSprite;

class LightCube extends FlxSprite {
    public override function new(X:Float, Y:Float) {
        super(X, Y);
        loadGraphic(AssetPaths.lightCube__png, false, 128, 128);
        acceleration.y = 1200;
    }
    public override function update(elapsed:Float) {
        super.update(elapsed);
    }
}