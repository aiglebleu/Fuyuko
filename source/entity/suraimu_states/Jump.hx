package entity.suraimu_states;

import flixel.FlxObject;
import entity.monsters.Suraimu;
import addons.FlxFSM;


class Jump extends FlxFSMState<Suraimu>
{
    override public function enter(owner:Suraimu, fsm:FlxFSM<Suraimu>):Void 
    {
        owner.animation.play("jump");
        owner.velocity.y = -350 * owner.rnd.float(0.5, 1.5);
        owner.velocity.x = 150 * felix.FelixSave.get_vitMob() * if (owner.facing == FlxObject.RIGHT) 1 else -1 * owner.rnd.float(0.5, 1.5);
        owner.playJump();
        
    }
    
    override public function update(elapsed:Float, owner:Suraimu, fsm:FlxFSM<Suraimu>):Void 
    {
    }
}