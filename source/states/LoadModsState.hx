package states;

import flixel.FlxG;
import flixel.FlxState;
import polymod.Polymod;
import states.MainMenuState;

class LoadModsState extends FlxState
{
    override public function create()
    {
        super.create();
        Polymod.init({modRoot: "./mods/", dirs:["mod"]});
        FlxG.switchState(MainMenuState.new);
    }
}