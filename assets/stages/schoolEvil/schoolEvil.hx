function generateStage()
{
    curStage = 'schoolEvil';
    PlayState.defaultCamZoom = 1.05;

    var bg:FNFSprite = new FNFSprite(400, 200);
    bg.frames = Paths.getSparrowAtlas('animatedEvilSchool', 'stages/' + curStage + '/images');
    bg.animation.addByPrefix('idle', 'background 2', 24);
    bg.animation.play('idle');
    bg.scrollFactor.set(0.8, 0.9);
    bg.scale.set(6, 6);
    add(bg);
}

function repositionPlayers(boyfriend:Character, gf:Character, dad:Character)
{
	dad.x -= 150;
    dad.y += 50;
    boyfriend.x += 200;
    boyfriend.y += 220;
    gf.x += 180;
    gf.y += 300;
}

function dadPosition(boyfriend:Character, gf:Character, dad:Character, camPos:FlxPoint)
{
	var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
	//add(evilTrail);
}
