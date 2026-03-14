package characters.player;

import characters.enemies.Enemy;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

enum AdelStates
{
    Normal;
    Bomb;
}

class Adel extends FlxSprite
{
    // Movement
    var adelAcceleration = 2000;
    var deceleration = 1600;
    var gravity = 1000; // same as supertux???
    public var minJumpHeight = 512; // public because enemies, same number as supertux???
    public var maxJumpHeight = 576; // public because enemies, same number as, you guessed it, supertux???
    var walkSpeed = 400;
    
    // Health System
    var canTakeDamage = true;
    var invFrames = 1.0; // time it takes to be damaged after being damaged

    // Direction
    public var direction = 1; // public because held enemies

    // Holding Enemies (thanks anatolystev)
    public var heldEnemy:Enemy = null;

    // Self-explanatory
    public var currentState = Normal;

    // Bomb throwing variables (i'm literally just copying code from my game tux platforming (haxe version), why the fuck are these public)
    public var canThrow = true;
    public var throwCooldown = 1.0;

    // Cutscene
    public var inCutscene = false;

    // Invincibility Powerup
    var herringDuration = 14.0;
    public var invincible = false;
    var stars:FlxSprite;

    // Dash move variables
    public var dash = false;
    public var dashSpeed = 800;
    public var dashDistance = 200;
    public var dashPosition:Float = 0;
    public var dashTimer:Float = 0;
    public var dashCooldown:Float = 1;
    public var dashDirection = 1;

    // Spritesheet
    var image = FlxAtlasFrames.fromSparrow("assets/images/characters/player/adel.png", "assets/images/characters/player/adel.xml");

    public function new()
    {
        super();

        // Spritesheet
        frames = image;
        animation.addByPrefix("stand", "stand", false);
        animation.addByPrefix("walk", "walk", 8, true);
        animation.addByPrefix("jump", "jump", 8, false);
        animation.addByPrefix("prepare", "prepare", 8, false); // unused?
        animation.addByPrefix("sit", "sit", 8, false);
        animation.addByPrefix("angry", "angry", 8, false);
        animation.addByPrefix("blink", "blink", 8, false);
        animation.addByPrefix("dash", "dash", 8, false);

        // Hitbox
        setSize(30, 58);
        offset.set(10, 22);

        // Acceleration, deceleration and max velocity
        drag.x = deceleration;
        acceleration.y = gravity;
        maxVelocity.x = walkSpeed;
    }

    override public function update(elapsed:Float)
    {
        if (!inCutscene)
        {
            // Stop Adel from falling off the map through the left
            if (x < 0)
            {
                x = 0;
            }

            // Kill Adel when she falls into the void
            if (y > Global.PS.map.height - height)
            {
                die();
            }

            move();
        }
        
        animate();

        if (dashTimer > 0)
        {
            dashTimer -= elapsed;
        }

        // Put this after everything
        super.update(elapsed);
    }

    // Animate Adel
    function animate()
    {
        if (!dash)
        {
            // If Adel is on the floor and staying where she is, do stand animation
            if (velocity.x == 0 && isTouching(FLOOR))
            {
                animation.play("stand");
            }
        
            // If Adel is on the floor and not staying where she is, do walk animation
            if (velocity.x != 0 && isTouching(FLOOR))
            {
                animation.play("walk");
            }

            // If Adel is not on the floor, do jump animation
            // TODO: Is velocity.y != 0 needed?
            if (velocity.y != 0 && !isTouching(FLOOR))
            {
                animation.play("jump");
            }
        }
        else
        {
            animation.play("dash");
        }
    }

    function move()
    {
        // Speed is 0 at beginning
        acceleration.x = 0;

        // If player presses left keys, walk left
        if (FlxG.keys.anyPressed([LEFT, A]) && !dash)
        {
            flipX = true;
            direction = -1;
            acceleration.x -= adelAcceleration;
        }
        // If player presses right keys, walk right
        else if (FlxG.keys.anyPressed([RIGHT, D]) && !dash)
        {
            flipX = false;
            direction = 1;
            acceleration.x += adelAcceleration;
        }

        // If player pressing jump keys and is on ground, jump
        if (FlxG.keys.anyJustPressed([SPACE, W, UP]) && isTouching(FLOOR) && !dash)
        {
            if (velocity.x == walkSpeed || velocity.x == -walkSpeed)
            {
                velocity.y = -maxJumpHeight;
            }
            else
            {
                velocity.y = -minJumpHeight;
            }

            FlxG.sound.play("assets/sounds/jump.ogg");
        }
        
        // Variable Jump Height
        if (velocity.y < 0 && FlxG.keys.anyJustReleased([SPACE, W, UP]))
        {
            velocity.y -= velocity.y * 0.5;
        }

        // adel dashes!
        if (FlxG.keys.justPressed.SHIFT && !dash && dashTimer <= 0)
        {
            trace("dash"); // remove if it works
            dash = true;
            dashPosition = this.x;
            dashDirection = direction;
            dashTimer = dashCooldown;
        }

        if (dash)
        {
            var currentDistance = Math.abs(this.x - dashPosition);

            if (currentDistance >= dashDistance || isTouching(WALL))
            {
                maxVelocity.x = walkSpeed;
                dash = false;
            }
            else
            {
                maxVelocity.x = dashSpeed;
                velocity.x = dashDirection * dashSpeed;
            }
        }
    }

    public function holdEnemy(enemy:Enemy)
    {
        // If there's already a held enemy, return.
        if (heldEnemy != null)
        {
            return;
        }

        // If there's no held enemy and player is pressing control, pick up enemy.
        if (FlxG.keys.pressed.CONTROL)
        {
            heldEnemy = enemy;
            enemy.pickUp(this);
        }
    }

    public function throwEnemy()
    {
        // If there's no held enemy, return.
        if (heldEnemy == null)
        {
            return;
        }

        // Throw enemy
        heldEnemy.enemyThrow();
        heldEnemy = null;
    }

    public function takeDamage(damageAmount:Int)
    {
        // Shakes the camera, decreases health, plays a sound and does invincibility frames stuff. If Adel's health is 1 and he gets damaged, she dies.
        if (canTakeDamage)
        {
            if (currentState == Bomb)
            {
                currentState = Normal;
                reloadGraphics();
            }

            FlxTween.flicker(this, invFrames, 0.1, {type: ONESHOT});
            Global.PS.camera.shake(0.05, 0.1);
            canTakeDamage = false;
            Global.health -= damageAmount;

            FlxG.sound.play("assets/sounds/adelhurt.ogg");

            new FlxTimer().start(invFrames, function(_) 
            {
                canTakeDamage = true;
            }, 1);

            if (Global.health <= 0)
            {
                die();
            }
        }
    }

    public function heal(healAmount:Int)
    {
        // If Global.health is less than Global.maxHealth, increase health by healAmount.
        if (Global.health < Global.maxHealth)
        {
            Global.health += healAmount;
        }
    }

    // Adel dies, will likely be changed to be a death animation similar to Super Mario Bros.
    public function die()
    {
        FlxG.resetState();
        currentState = Normal;
        reloadGraphics();
        Global.health = Global.maxHealth;
    }

    public function reloadGraphics()
    {
        animation.reset();

        switch(currentState)
        {
            case Normal:
                // Spritesheet
                var fixedMaybeOne = FlxAtlasFrames.fromSparrow("assets/images/characters/player/adel.png", "assets/images/characters/player/adel.xml");
                frames = fixedMaybeOne;
                animation.addByPrefix("stand", "stand", false);
                animation.addByPrefix("walk", "walk", 8, true);
                animation.addByPrefix("jump", "jump", 8, false);
                animation.addByPrefix("prepare", "prepare", 8, false);
                animation.addByPrefix("sit", "sit", 8, false);
                animation.addByPrefix("angry", "angry", 8, false);
                animation.addByPrefix("blink", "blink", 8, false);
                animation.addByPrefix("dash", "dash", 8, false);

                // i genuinely dont know whether this fixed a crash or not (context: game was crashing)
                setSize(30, 58);
                offset.set(10, 22);

            case Bomb:
                // Spritesheet
                var fixedMaybeTwo = FlxAtlasFrames.fromSparrow("assets/images/characters/player/nuclear_adel.png", "assets/images/characters/player/nuclear_adel.xml");
                frames = fixedMaybeTwo;
                animation.addByPrefix("stand", "stand", false);
                animation.addByPrefix("walk", "walk", 8, true);
                animation.addByPrefix("jump", "jump", 8, false);
                animation.addByPrefix("prepare", "prepare", 8, false);
                animation.addByPrefix("sit", "sit", 8, false);
                animation.addByPrefix("angry", "angry", 8, false);
                animation.addByPrefix("blink", "blink", 8, false);
                animation.addByPrefix("dash", "dash", 8, false);

                // i genuinely dont know whether this fixed a crash or not (context: game was crashing)
                setSize(30, 58);
                offset.set(10, 22);
        }
    }

    // what an odd thing to say
    public function bombAdel()
    {
        currentState = Bomb;
        reloadGraphics();
    }
}