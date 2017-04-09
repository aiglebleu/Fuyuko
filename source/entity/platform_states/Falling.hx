package entity.platform_states;

import flixel.FlxObject;
import flixel.FlxG;
import addons.FlxFSM;

class Falling extends FlxFSMState<Platform>
{
    override public function enter(owner:Platform, fsm:FlxFSM<Platform>):Void 
    {
        owner.velocity.y = 600;
    }

    override public function update(elapsed:Float, owner:Platform, fsm:FlxFSM<Platform>):Void 
    {
    }

    override public function exit(owner:Platform):Void {
        owner.velocity.y = 0;
    }

}