var phillyTrain:FNFSprite;
var trainSound:FlxSound;
var windowLight:FNFSprite;
var phillyCityLightColors:Array<Int>;
var trainFrameTiming:Float = 0;
var trainCars:Int = 8;
var trainCooldown:Int = 0;
var curLight:Int = 0;
var startedMoving:Bool = false;
var trainMoving:Bool = false;
var trainFinishing:Bool = false;

function generateStage()
{
	curStage = 'philly';
	PlayState.defaultCamZoom = 1.05;

	var bg:FNFSprite = new FNFSprite(-100, 0);
	bg.loadGraphic(Paths.image('sky', 'stages/' + curStage + '/images'));
	bg.scrollFactor.set(0.1, 0.1);
	add(bg);

	var city:FNFSprite = new FNFSprite(-10).loadGraphic(Paths.image('city', 'stages/' + curStage + '/images'));
	city.scrollFactor.set(0.3, 0.3);
	city.setGraphicSize(Std.int(city.width * 0.85));
	city.updateHitbox();
	add(city);

	phillyCityLightColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];

	windowLight = new FNFSprite(city.x).loadGraphic(Paths.image('win', 'stages/' + curStage + '/images'));
	windowLight.scrollFactor.set(0.3, 0.3);
	windowLight.setGraphicSize(Std.int(windowLight.width * 0.85));
	windowLight.updateHitbox();
	windowLight.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
	windowLight.alpha = 0;
	add(windowLight);

	var streetBehind:FNFSprite = new FNFSprite(-40, 50).loadGraphic(Paths.image('behindTrain', 'stages/' + curStage + '/images'));
	add(streetBehind);

	phillyTrain = new FNFSprite(2000, 360).loadGraphic(Paths.image('train', 'stages/' + curStage + '/images'));
	add(phillyTrain);

	trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
	FlxG.sound.list.add(trainSound);

	var street:FNFSprite = new FNFSprite(-40, streetBehind.y).loadGraphic(Paths.image('street', 'stages/' + curStage + '/images'));
	add(street);
}

function trainStart()
{
	trainMoving = true;
	if (!trainSound.playing)
		trainSound.play(true);
}

function updateTrainPos(gf:Character)
{
	if (trainSound.time >= 4700)
	{
		startedMoving = true;
		gf.playAnim('hairBlow');
	}

	if (startedMoving)
	{
		phillyTrain.x -= 400;

		if (phillyTrain.x < -2000 && !trainFinishing)
		{
			phillyTrain.x = -1150;
			trainCars -= 1;

			if (trainCars <= 0)
				trainFinishing = true;
		}

		if (phillyTrain.x < -4000 && trainFinishing)
			trainReset(gf);
	}
}

function trainReset(gf:Character)
{
	gf.playAnim('hairFall');
	phillyTrain.x = FlxG.width + 200;
	trainMoving = false;
	trainCars = 8;
	trainFinishing = false;
	startedMoving = false;
}

function updateStage(curBeat:Int, boyfriend:Character, gf:Character, dadOpponent:Character)
{
	if (!trainMoving)
		trainCooldown += 1;

	if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
	{
		trainCooldown = FlxG.random.int(-4, 0);
		trainStart();
	}

	if (curBeat % 4 == 0)
	{
		curLight = FlxG.random.int(0, phillyCityLightColors.length - 1, [curLight]);
		windowLight.color = phillyCityLightColors[curLight];
		windowLight.alpha = 1;
	}
}

function updateStageConst(elapsed:Float, boyfriend:Character, gf:Character, dadOpponent:Character)
{
	windowLight.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

	if (trainMoving)
	{
		trainFrameTiming += elapsed;

		if (trainFrameTiming >= 1 / 24)
		{
			updateTrainPos(gf);
			trainFrameTiming = 0;
		}
	}
}