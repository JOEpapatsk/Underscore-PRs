package states;

import base.*;
import base.MusicBeat.MusicBeatState;
import dependency.Discord;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.Alphabet;
import lime.app.Application;
import openfl.Assets;
import states.menus.*;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var credGroup:FlxGroup;
	var textGroup:FlxGroup;

	var curWacky:Array<String> = [];

	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var bg:FlxSprite;

	override public function create():Void
	{
		controls.setKeyboardScheme(None, false);
		curWacky = FlxG.random.getObject(getIntroTextShit());
		super.create();

		if (!initialized)
		{
			#if DISCORD_RPC
			Discord.changePresence('TITLE SCREEN', 'Main Menu');
			#end

			#if GAME_UPDATER
			ForeverTools.checkUpdates();
			#end
		}

		startIntro();
	}

	var titleText:FlxSprite;
	var gameLogo:FlxSprite;
	var gfDance:FlxSprite;
	var blackScreen:FlxSprite;
	var ngSpr:FlxSprite;

	var danceLeft:Bool = false;
	var initLogowidth:Float = 0;
	var newLogoScale:Float = 0;

	function startIntro()
	{
		if (!initialized)
		{
			ForeverTools.resetMenuMusic(true);
		}

		persistentUpdate = true;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		/*
		bg.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		bg.setGraphicSize(Std.int(bg.width * 0.6));
		bg.updateHitbox();
		*/
		add(bg);

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('menus/base/title/gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		add(gfDance);

		gameLogo = new FlxSprite(0, 50);
		gameLogo.loadGraphic(Paths.image('menus/base/title/logo'));
		gameLogo.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		initLogowidth = gameLogo.width;
		newLogoScale = gameLogo.scale.x;
		add(gameLogo);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('menus/base/title/titleEnter');
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}

		if (animFrames.length > 0)
		{
			newTitle = true;

			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', !Init.trueSettings.get('Disable Flashing Lights') ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else
		{
			newTitle = false;

			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		titleText.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		textGroup = new FlxGroup();

		add(credGroup);

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('menus/base/title/newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = !Init.trueSettings.get('Disable Antialiasing');

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var swagGoodArray:Array<Array<String>> = [['no idea what psych engine is', 'vine boom sfx']];
		if (Assets.exists(Paths.txt('introText')))
		{
			var fullText:String = Assets.getText(Paths.txt('introText'));
			var firstArray:Array<String> = fullText.split('\n');

			for (i in firstArray)
				swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		gameLogo.scale.x = FlxMath.lerp(newLogoScale, gameLogo.scale.x, 0.95);
		gameLogo.scale.y = FlxMath.lerp(newLogoScale, gameLogo.scale.y, 0.95);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (newTitle)
		{
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2)
				titleTimer -= 2;
		}

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;
		}

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;

				timer = FlxEase.quadInOut(timer);

				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}

			if (FlxG.keys.justPressed.ESCAPE && !pressedEnter)
				Sys.exit(0);

			if (pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				titleText.animation.play('press');

				if (!Init.trueSettings.get('Disable Flashing Lights'))
					FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				gameLogo.setGraphicSize(Std.int(initLogowidth * 1.15));

				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					if (ForeverTools.mustUpdate && !OutdatedState.leftState)
						Main.switchState(this, new OutdatedState());
					else
						Main.switchState(this, new MainMenuState());
				});
			}
		}

		// hi game, please stop crashing its kinda annoyin, thanks!
		if (pressedEnter && !skippedIntro && initialized)
			skipIntro();

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (gameLogo != null && !transitioning)
		{
			gameLogo.scale.set(1.05, 1.05);
			FlxTween.tween(gameLogo, {'scale.x': 0.90, 'scale.y': 0.90}, 0.5, {ease: FlxEase.bounceIn});
		}

		if (gfDance != null)
		{
			danceLeft = !danceLeft;
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		switch (curBeat)
		{
			case 16:
				skipIntro();
		}
	}

	override function stepHit()
	{
		super.stepHit();
		
		if (!skippedIntro)
		{
			switch (curStep)
			{
				case 4:
					#if FOREVER_ENGINE_WATERMARKS
					createCoolText(['Yoshubs', 'Neolixn', 'Gedehari', 'Tsuraran', 'FlopDoodle', '']);
					#else
					createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
					#end
				case 12:
					addMoreText('PRESENT');
				case 16:
					deleteCoolText();
				case 20:
					#if FOREVER_ENGINE_WATERMARKS
					createCoolText(['Not associated', 'with']);
					#else
					createCoolText(['In association', 'with']);
					#end
				case 28:
					addMoreText('newgrounds');
					ngSpr.visible = true;
				case 32:
					deleteCoolText();
					ngSpr.visible = false;
				case 36:
					createCoolText([curWacky[0]]);
				case 44:
					addMoreText(curWacky[1]);
					if (curWacky[1] == 'vine boom sfx')
						FlxG.sound.play(Paths.sound('psych'));
				case 48:
					deleteCoolText();
				case 52:
					addMoreText("Friday");
				case 56:
					addMoreText('Night');
				case 60:
					addMoreText("Funkin");
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 2.5);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
