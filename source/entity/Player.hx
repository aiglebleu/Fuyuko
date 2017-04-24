package entity;

import flixel.effects.FlxFlicker;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;
import entity.player_states.*;
import addons.FlxFSM;
import flixel.system.FlxSound;
import flixel.math.FlxPoint;
import entity.misc.ILightSource;

class Player extends FlxSprite implements ILightSource
{
    var GRAVITY:Int = 600;
    var fsm:FlxFSM<Player>;
    public var speedFactor:Float = 1;
    public var diffFactor:Float = 1;

    var _heartSound:FlxSound = new FlxSound();
    var _hurtSound:FlxSound = new FlxSound();
    var _healSound:FlxSound = new FlxSound();
    var _cnt:Int = 0;

    public var baseLight:Int = 160;
    public var center:FlxPoint = new FlxPoint();
    
    public function new(?X:Float=0, ?Y:Float=0)
    {
        super(X, Y);

        health = 100;
        solid = true;

        fsm = new FlxFSM<Player>(this);
        fsm.transitions
            .add(Idle, Walk, Conditions.isWalking)
            .add(Idle, Jump, Conditions.isJumping)
            .add(Idle, Crouch, Conditions.isCrouching)
            .add(Idle, Fall, Conditions.isFalling)

            .add(Walk, Idle, Conditions.isNotWalking)
            .add(Walk, Jump, Conditions.isJumping)
            .add(Walk, Push, Conditions.isPushing)
            .add(Walk, Fall, Conditions.isFalling)
            .add(Walk, Run, Conditions.isRunning)

            .add(Run, Idle, Conditions.runToIdle)
            .add(Run, Walk, Conditions.runToWalk)
            .add(Run, Push, Conditions.isPushing)
            .add(Run, Fall, Conditions.isFalling)
            .add(Run, SuperJump, Conditions.isJumping)

            .add(Crouch, SuperJump, Conditions.isJumping)
            .add(Crouch, Reco, Conditions.isNotCrouching)

            .add(Jump, Fall, Conditions.isFallingAfterJump)

            .add(SuperJump, Fall, Conditions.isFallingAfterJump)

            .add(Fall, Reco, Conditions.isGrounded)

            .add(Reco, Idle, Conditions.isDone)
            
            .add(Push, Idle, Conditions.isNotPushing)
            .add(Push, Jump, Conditions.isJumping)
            .add(Push, Fall, Conditions.isFalling)

            .start(Idle);

        acceleration.y = GRAVITY;
        drag.x = 100;

        loadGraphic(AssetPaths.charsheet_fuyuko__png, true, 128, 256);
        scale.set(0.45, 0.45);
        updateHitbox();

        animation.add("push", [for (i in 30...38) i], 6, true);
        animation.add("idle", [for (i in 0...10) i], 6, true);
        animation.add("walk", [for (i in 10...20) i], 12, true);
        animation.add("run", [for (i in 10...20) i], 24, true);
        animation.add("jump", [for (i in 20...25) i], 24, false);
        animation.add("fall", [for (i in 0...3) 24-i], 6, false);
        animation.add("reco", [for (i in 25...30) i], 24, false);
        animation.add("crouch", [for (i in 0...4) 29-i], 24, false);

        FlxG.watch.add(velocity, "x", "VelocityX");
        FlxG.watch.add(velocity, "y", "VelocityY");
        FlxG.watch.add(this, "x");
        FlxG.watch.add(this, "y");
        FlxG.watch.add(this, "health");

        setFacingFlip(FlxObject.RIGHT, false, false);
        setFacingFlip(FlxObject.LEFT, true, false);
    }

    public override function update(elapsed:Float):Void {
        var pressingLeft:Bool = FlxG.keys.pressed.A;
        var pressingRight:Bool = FlxG.keys.pressed.D;

        if (pressingLeft && !pressingRight) {
            velocity.x = -300 * speedFactor;
            facing = FlxObject.LEFT;
        }

        if (pressingRight && !pressingLeft) {
            velocity.x = 300 * speedFactor;
            facing = FlxObject.RIGHT;
        }

        if (velocity.x < -20)
            velocity.x += 20;
        else if (velocity.x > 20)
            velocity.x -= 20;
        else
            velocity.x = 0;

        _cnt++;

        center = getMidpoint(center);
        fsm.update(elapsed);
        super.update(elapsed);
    }

    public override function hurt(damage:Float) {
        if (alive && !FlxFlicker.isFlickering(this)) {
            health -= damage;
            FlxFlicker.flicker(this, 1, 0.1, true);

            felix.FelixSound.playGeneric(AssetPaths.hurt2__ogg, 
                _hurtSound, felix.FelixSave.get_sound_effects(), false);
            
            if (health < 50)
                felix.FelixSound.playGeneric(AssetPaths.heartbeat_fast__ogg, 
                    _heartSound, felix.FelixSave.get_ambient_music());
            else if (health < 80)
                felix.FelixSound.playGeneric(AssetPaths.heartbeat_slow__ogg, 
                    _heartSound, felix.FelixSave.get_ambient_music());

            FlxG.camera.shake(0.005, 0.1);
            if (health <= 0) {
                kill();
            }
        }
    }

    public function heal(damage:Float):Bool {
        if (alive && !FlxFlicker.isFlickering(this)) {
            health += damage;

            felix.FelixSound.playGeneric(AssetPaths.load__ogg, 
                _healSound, felix.FelixSave.get_sound_effects(), false);
            
            if (health < 50)
                felix.FelixSound.playGeneric(AssetPaths.heartbeat_fast__ogg, 
                    _heartSound, felix.FelixSave.get_ambient_music());
            else if (health < 80)
                felix.FelixSound.playGeneric(AssetPaths.heartbeat_slow__ogg, 
                    _heartSound, felix.FelixSave.get_ambient_music());
            return true;
        }
        return false;
    }

    public function getLightRadius():Float {
        return (baseLight + 8 * Math.sin(Math.floor(_cnt / 15))) * (health + 10) / 100 ;
    }
}