package entity;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import scene.levels.JsonEntity;
import flixel.effects.FlxFlicker;
import flixel.FlxObject;
import flixel.FlxG;
import entity.player_states.*;
import addons.FlxFSM;
import flixel.system.FlxSound;
import flixel.math.FlxPoint;

class Player extends Entity
{
    var GRAVITY:Int = 600;
    var fsm:FlxFSM<Player>;
    public var speedFactor:Float = 1;
    public var diffFactor:Float = 1;

    var _heartSound:FlxSound = new FlxSound();
    var _hurtSound:FlxSound = new FlxSound();
    var _healSound:FlxSound = new FlxSound();

    public var center:FlxPoint = new FlxPoint();
    public var action:String = "";
    
    public function new(json:JsonEntity, player:Player, level:FlxTilemap, entities:FlxTypedGroup<Entity>)
    {
        super(json, player, level, entities);

        felix.FelixSound.register(_heartSound);
        felix.FelixSound.register(_hurtSound);
        felix.FelixSound.register(_healSound);

        health = 100;
        solid = true;

        fsm = new FlxFSM<Player>(this);
        fsm.transitions
            .add(Idle, Walk, Conditions.isWalking)
            .add(Idle, Jump, Conditions.isJumping)
            .add(Idle, Crouch, Conditions.isCrouching)
            .add(Idle, Fall, Conditions.isFalling)
            .add(Idle, Shooting, Conditions.isShooting)

            .add(Walk, Idle, Conditions.isNotWalking)
            .add(Walk, Jump, Conditions.isJumping)
            .add(Walk, Push, Conditions.isPushing)
            .add(Walk, Fall, Conditions.isFalling)
            .add(Walk, Run, Conditions.isRunning)
            .add(Walk, Shooting, Conditions.isShooting)

            .add(Run, Idle, Conditions.runToIdle)
            .add(Run, Walk, Conditions.runToWalk)
            .add(Run, Push, Conditions.isPushing)
            .add(Run, Fall, Conditions.isFalling)
            .add(Run, SuperJump, Conditions.isJumping)
            .add(Run, Shooting, Conditions.isShooting)

            .add(Crouch, SuperJump, Conditions.isJumping)
            .add(Crouch, Reco, Conditions.isNotCrouching)
            .add(Crouch, Shooting, Conditions.isShooting)

            .add(Jump, Fall, Conditions.isFallingAfterJump)
            .add(Jump, Shooting, Conditions.isShooting)

            .add(SuperJump, Fall, Conditions.isFallingAfterJump)
            .add(SuperJump, Shooting, Conditions.isShooting)

            .add(Fall, Reco, Conditions.isGrounded)
            .add(Fall, Shooting, Conditions.isShooting)

            .add(Reco, Idle, Conditions.isDone)
            
            .add(Push, Idle, Conditions.isNotPushing)
            .add(Push, Jump, Conditions.isJumping)
            .add(Push, Fall, Conditions.isFalling)
            .add(Push, Shooting, Conditions.isShooting)

            .add(Shooting, Idle, Conditions.isDone)

            .start(Idle);

        acceleration.y = GRAVITY;
        drag.x = 100;

        loadGraphic(AssetPaths.charsheet_fuyuko__png, true, 128, 256);
        rescale();

        animation.add("push", [for (i in 30...38) i], 6, true);
        animation.add("shoot", [for (i in 30...38) i], 24, false);
        animation.add("idle", [for (i in 0...10) i], 6, true);
        animation.add("walk", [for (i in 10...20) i], 12, true);
        animation.add("run", [for (i in 10...20) i], 24, true);
        animation.add("jump", [for (i in 20...25) i], 24, false);
        animation.add("fall", [for (i in 0...3) 24-i], 6, false);
        animation.add("reco", [for (i in 25...30) i], 24, false);
        animation.add("crouch", [for (i in 0...4) 29-i], 24, false);

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

        facing = switch ([pressingLeft, pressingRight, animation.name == "shoot"]) {
            case [_, _, true]: if (FlxG.mouse.x > x) FlxObject.RIGHT else FlxObject.LEFT;
            case [true, false, false]: FlxObject.LEFT;
            case [false, true, false]: FlxObject.RIGHT;
            case _: facing;
        }

        if (velocity.x < -20)
            velocity.x += 20;
        else if (velocity.x > 20)
            velocity.x -= 20;
        else
            velocity.x = 0;

        if (health <= 50) {
            var percent = (50 - health) / 50; // 0 to 1
            FlxG.camera.shake(percent * 0.0025, 0.1);
        }

        center = getMidpoint(center);
        fsm.update(elapsed);
        super.update(elapsed);
    }

    public override function hurt(damage:Float) {
        if (alive && !FlxFlicker.isFlickering(this)) {
            action = "spawnCorruptedLightBall";
            decrease_life(damage, true);
        }
    }

    public function decrease_life(damage:Float, checked:Bool = false) {
        if (checked || (alive && !FlxFlicker.isFlickering(this))) {
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

            felix.FelixSound.playGeneric(AssetPaths.heal__ogg, 
                _healSound, felix.FelixSave.get_sound_effects(), false, false);
            
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
}