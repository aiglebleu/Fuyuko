package felix;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

class FelixButton extends FlxButton {
    public function new (X:Float, Y:Float, ?text:Null<String>, ?onClick:Null<Void -> Void>, ?fontSize:Null<Int>) {
        super(X, Y, text, onClick);

        var font = 28;
        if (fontSize != null)
            font = fontSize;

        scale.add(2, 2);
        updateHitbox();

        label.setFormat(AssetPaths.FantasqueSansMono_Regular__ttf, font, FlxColor.WHITE, CENTER);
        label.setBorderStyle(OUTLINE, FlxColor.BLUE, 1);
        label.wordWrap = false;
        label.autoSize = true;

        var center:FlxPoint = new FlxPoint(width / 2 - label.width / 2, height / 2 - label.height / 2);
        labelOffsets = [ center, center, center ];

        setSounds();
    }

    public function setSounds():Void {
        onOver.sound = FlxG.sound.load(AssetPaths.sharp_echo__ogg, felix.FelixSound.getUiVolume() * 0.01);
        onUp.sound = FlxG.sound.load(AssetPaths.load__ogg, felix.FelixSound.getUiVolume() * 0.01);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (onOver.sound != null)
            onOver.sound.volume = felix.FelixSound.getUiVolume() * 0.01;
        if (onUp.sound != null)
            onUp.sound.volume = felix.FelixSound.getUiVolume() * 0.01;
    }
}