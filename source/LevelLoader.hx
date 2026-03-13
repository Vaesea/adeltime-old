package;

import characters.enemies.as.Rollball;
import characters.enemies.as.Snowmangry;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import objects.solid.Goal;
import objects.solid.Solid;
import states.PlayState;

class LevelLoader extends FlxState
{
    public static var tiledMap:TiledMap;

    public static function loadLevel(state:PlayState, level:String)
    {
        tiledMap = new TiledMap("assets/data/levels/" + level + ".tmx");

        var music = tiledMap.properties.get("Music");
        var levelName = tiledMap.properties.get("Level Name");
        var levelCreator = tiledMap.properties.get("Level Creator");

        Global.levelName = levelName;
        Global.levelCreator = levelCreator;
        Global.currentSong = music;

        // Quickly taken from my other game...
        for (layer in tiledMap.layers)
        {
            if (Std.isOfType(layer, TiledImageLayer))
            {
                var imageLayer:TiledImageLayer = cast layer;
                var path:String = Std.string(imageLayer.imagePath);
                path = StringTools.replace(path, "../", "");
                path = "assets/" + path;

                var image = new FlxBackdrop(path, XY);

                image.offset.x = Std.parseFloat(imageLayer.properties.get("offsetX"));
                image.offset.y = Std.parseFloat(imageLayer.properties.get("offsetY"));

                image.scrollFactor.x = imageLayer.parallaxX;
                image.scrollFactor.y = imageLayer.parallaxY;

                state.add(image);

                trace(path); // This is here so you can see if the path is correct if the image isn't showing. I was gonna remove this but it's been here since another game...
            }
        }

        var mainLayer:TiledTileLayer = cast tiledMap.getLayer("Main");
        
        state.map = new FlxTilemap();
        state.map.loadMapFromArray(mainLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/tiles.png", 32, 32, state.uhoh); // tiled is bad and i have to start at global id 42- nope! 49 now- nope! i have no fucking clue anymore!!!! :3
        state.map.solid = false;

        var backgroundLayer:TiledTileLayer = cast tiledMap.getLayer("Background");
        
        var backgroundMap = new FlxTilemap();
        backgroundMap.loadMapFromArray(backgroundLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/tiles.png", 32, 32, state.uhoh);
        backgroundMap.solid = false;

        state.add(backgroundMap);

        for (solid in getLevelObjects(tiledMap, "Level"))
        {
            switch (solid.type)
            {
                case "goal":
                    var goalSquare = new Goal(solid.x, solid.y, solid.width, solid.height); // Need this because width and height.
                    state.solidThings.add(goalSquare);
                case "checkpoint":
                    state.checkpoint = new FlxPoint(solid.x, solid.y - 32);
            }
        }

        for (object in getLevelObjects(tiledMap, "Enemies"))
        {
            switch (object.type)
            {
                case "snowmangry":
                    state.enemies.add(new Snowmangry(object.x, object.y - 78));
                case "rollball":
                    state.enemies.add(new Rollball(object.x, object.y - 28));
            }
        }

        var adelThing:TiledObject = getLevelObjects(tiledMap, "Player")[0];
        var adelPosition:FlxPoint = new FlxPoint(adelThing.x, adelThing.y);

        if (Global.checkpointReached)
        {
            adelPosition = state.checkpoint;
        }
        else
        {
            adelPosition.set(adelThing.x, adelThing.y);
        }

        state.adel.setPosition(adelPosition.x, adelPosition.y - 58);

        for (solid in getLevelObjects(tiledMap, "Solid"))
        {
            var solidSquare = new Solid(solid.x, solid.y, solid.width, solid.height); // Need this because width and height.
            state.solidThings.add(solidSquare);
        }
    }

    // copied from my other games so also copied from discover haxeflixel
    public static function getLevelObjects(map:TiledMap, layer:String):Array<TiledObject>
    {
        if ((map != null) && (map.getLayer(layer) != null))
        {
            var objLayer:TiledObjectLayer = cast map.getLayer(layer);
            return objLayer.objects;
        }
        else
        {
            trace("Object layer " + layer + " not found! Also credits to Discover Haxeflixel.");
            return [];
        }
    }
}