package characters.enemies.as;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

class Empeguin extends Enemy
{
    // Spritesheet
    // IF ANYONE WANTS TO WORK ON ART FOR THIS GAME THAT WOULD BE APPRECIATED BECAUSE I DONT KNOW HOW TO ANIMATE, ONLY ART. I JUST USED THE TRANSFORM THING IN FIREALPACA FOR THIS.
    // WHY AM I USING CAPITAL LETTERS
    // WHAT THE FUCK :33333333
    var image = FlxAtlasFrames.fromSparrow("assets/images/characters/enemies/empeguin.png", "assets/images/characters/enemies/empeguin.xml");
    var busy = false;
    var rollBallJump = 256;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        // Spritesheet
        frames = image;

        // Set flipX to true because I forgot to flip the frames
        flipX = true;

        // Animations
        animation.addByPrefix('stand', 'stand', 14, true);
        animation.addByPrefix('throw', 'throw', 14, false);
        animation.addByPrefix('squished', 'fall', 14, false);
        animation.play('stand');

        // Hitbox
        setSize(48, 84);
        offset.set(18, 12);
    }

    override private function move()
    {
        // holy shit just look at the amount of timers
        if (isOnScreen())
        {
            new FlxTimer().start(0.25, function(_)
            {
                if (!busy)
                {
                    busy = true;
                    animation.play("throw");
                    var rollBall:Rollball = new Rollball(this.x, this.y + 42);
                    rollBall.direction = this.direction;
                    rollBall.flipX = this.flipX;
                    rollBall.velocity.y = -rollBallJump;
                    Global.PS.enemies.add(rollBall);
                    new FlxTimer().start(0.2, function(_)
                    {
                        animation.play("stand");
                        new FlxTimer().start(4.8, function(_)
                        {
                            busy = false;
                        }, 1);
                    }, 1);
                }
            }, 1);
        }
    }
}