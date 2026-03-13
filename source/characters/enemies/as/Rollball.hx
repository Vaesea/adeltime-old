package characters.enemies.as;

import flixel.graphics.frames.FlxAtlasFrames;

class Rollball extends Enemy
{
    // Spritesheet
    // IF ANYONE WANTS TO WORK ON ART FOR THIS GAME THAT WOULD BE APPRECIATED BECAUSE I DONT KNOW HOW TO ANIMATE, ONLY ART. I JUST USED THE TRANSFORM THING IN FIREALPACA FOR THIS.
    // WHY AM I USING CAPITAL LETTERS
    // WHAT THE FUCK :33333333
    var image = FlxAtlasFrames.fromSparrow("assets/images/characters/enemies/rollball.png", "assets/images/characters/enemies/rollball.xml");

    public function new(x:Float, y:Float)
    {
        super(x, y);

        // Spritesheet
        frames = image;

        // Set flipX to true because I forgot to flip the frames
        flipX = true;

        // Animations
        animation.addByPrefix('walk', 'roll', 12, true);
        animation.addByPrefix('squished', 'dead', 12, false);
        animation.play('walk');

        // Hitbox
        setSize(28, 28);
        offset.set(4, 7);

        // Set walkSpeed to make this little guy faster
        walkSpeed = 180;
    }

    override private function move()
    {
        // Make him move, Enemy.hx handles the rest of what Rollball does.
        velocity.x = direction * walkSpeed;
    }
}