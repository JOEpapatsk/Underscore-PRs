var upperBoppers:FNFSprite;
var bottomBoppers:FNFSprite;
var santa:FNFSprite;

function generateStage()
{
    curStage = 'mall';
    PlayState.defaultCamZoom = 0.80;

    var bg:FNFSprite = new FNFSprite(-1000, -500).loadGraphic(Paths.image('bgWalls', 'stages/' + curStage + '/images'));
    bg.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
    bg.scrollFactor.set(0.2, 0.2);
    bg.active = false;
    bg.setGraphicSize(Std.int(bg.width * 0.8));
    bg.updateHitbox();
    add(bg);

    upperBoppers = new FNFSprite(-240, -90);
    upperBoppers.frames = Paths.getSparrowAtlas('upperBop', 'stages/' + curStage + '/images');
    upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
    upperBoppers.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
    upperBoppers.scrollFactor.set(0.33, 0.33);
    upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
    upperBoppers.updateHitbox();
    add(upperBoppers);

    var bgEscalator:FNFSprite = new FNFSprite(-1100, -600).loadGraphic(Paths.image('bgEscalator', 'stages/' + curStage + '/images'));
    bgEscalator.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
    bgEscalator.scrollFactor.set(0.3, 0.3);
    bgEscalator.active = false;
    bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
    bgEscalator.updateHitbox();
    add(bgEscalator);

    var tree:FNFSprite = new FNFSprite(370, -250).loadGraphic(Paths.image('christmasTree', 'stages/' + curStage + '/images'));
    tree.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
    tree.scrollFactor.set(0.40, 0.40);
    add(tree);

    bottomBoppers = new FNFSprite(-300, 140);
    bottomBoppers.frames = Paths.getSparrowAtlas('bottomBop', 'stages/' + curStage + '/images');
    bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
    bottomBoppers.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
    bottomBoppers.scrollFactor.set(0.9, 0.9);
    bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
    bottomBoppers.updateHitbox();
    add(bottomBoppers);

    var fgSnow:FNFSprite = new FNFSprite(-600, 700).loadGraphic(Paths.image('fgSnow', 'stages/' + curStage + '/images'));
    fgSnow.active = false;
    fgSnow.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
    add(fgSnow);

    santa = new FNFSprite(-840, 150);
    santa.frames = Paths.getSparrowAtlas('santa', 'stages/' + curStage + '/images');
    santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
    santa.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
    add(santa);
}

function repositionPlayers(boyfriend:Character, gf:Character, dad:Character)
{
    boyfriend.x += 200;
	dad.x -= 400;
	dad.y += 20;
}

function updateStage(curBeat:Int, boyfriend:Character, gf:Character, dadOpponent:Character)
{
    upperBoppers.animation.play('bop', true);
    bottomBoppers.animation.play('bop', true);
    santa.animation.play('idle', true);
}