package states.menus;

import flash.text.TextField;
import sys.FileSystem;
import sys.thread.Mutex;
import sys.thread.Thread;
import base.ChartParser;
import base.Conductor;
import base.CoolUtil;
import base.MusicBeat.MusicBeatState;
import base.SongLoader.LegacySong;
import base.SongLoader.Song;
import base.WeekParser;
import dependency.Discord;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.*;
import funkin.Alphabet;
import funkin.ui.HealthIcon;
import lime.utils.Assets;
import openfl.media.Sound;
import states.editors.*;
import states.substates.FreeplaySubstate;

using StringTools;

class FreeplayState extends MusicBeatState
{
	//
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curSongPlaying:Int = -1;
	private static var curDifficulty:Int = 1;

	var presses:Int = 0;

	var scoreText:FlxText;
	var diffText:FlxText;
	var rateText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var songRate:Float = 1;

	var songThread:Thread;
	var threadActive:Bool = true;
	var mutex:Mutex;
	var songToPlay:Sound = null;

	var grpSongs:FlxTypedGroup<Alphabet>;
	var curPlaying:Bool = false;

	var iconArray:Array<HealthIcon> = [];

	var mainColor:FlxColor = FlxColor.WHITE;
	var bg:FlxSprite;
	var scoreBG:FlxSprite;

	var lockedMovement:Bool = false;

	var existingSongs:Array<String> = [];
	var existingDifficulties:Array<Array<String>> = [];

	override function create()
	{
		super.create();

		PlayState.practiceMode = Init.gameModifiers.get('Practice Mode');

		presses = 0;

		mutex = new Mutex();

		// load in all songs that exist in folder
		var folderSongs:Array<String> = CoolUtil.returnAssetsLibrary('songs', 'assets');

		WeekParser.loadJsons(false);

		for (i in 0...WeekParser.weeksList.length)
		{
			// checking week's locked state before anything
			if (checkLock(WeekParser.weeksList[i]))
				continue;

			var baseWeek = WeekParser.loadedWeeks.get(WeekParser.weeksList[i]);

			var songs:Array<String> = [];
			var chars:Array<String> = [];
			var colors:Array<FlxColor> = [];

			if (!baseWeek.hideFreeplay) // no need to add week songs if they are hidden from the freeplay list;
			{
				// push song names and characters;
				for (i in 0...baseWeek.songs.length)
				{
					var baseArray = baseWeek.songs[i];

					songs.push(baseArray.name);
					chars.push(baseArray.character);

					// get out of my head get out of my head get out of my head GET OUT OF MY HEAD
					if (baseArray.colors != null)
						colors.push(FlxColor.fromRGB(baseArray.colors[0], baseArray.colors[1], baseArray.colors[2]));
					else
						colors.push(FlxColor.fromRGB(255, 255, 255));
				}

				addWeek(songs, i, chars, colors);
			}

			// add songs to the existing songs array to avoid duplicates;
			for (j in songs)
				existingSongs.push(j.toLowerCase());
		}

		for (i in folderSongs)
		{
			if (!existingSongs.contains(i.toLowerCase()))
			{
				var icon:String = 'gf';
				var color:FlxColor = FlxColor.WHITE;
				var colorArray:Array<Int> = [255, 255, 255];
				var chartExists:Bool = FileSystem.exists(Paths.songJson(i, i));
				if (chartExists)
				{
					var castSong:LegacySong = Song.loadSong(i, i);
					icon = (castSong != null) ? castSong.player2 : 'gf';

					colorArray = castSong.color;

					if (colorArray != null)
						color = FlxColor.fromRGB(colorArray[0], colorArray[1], colorArray[2]);

					addSong(CoolUtil.spaceToDash(castSong.song), 1, icon, color);
				}
			}
		}

		// LOAD MUSIC
		// ForeverTools.resetMenuMusic();

		#if DISCORD_RPC
		Discord.changePresence('CHOOSING A SONG', 'Freeplay Menu');
		#end

		// LOAD CHARACTERS
		bg = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName.split('-').join(' '), true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 106, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.alignment = CENTER;
		diffText.font = scoreText.font;
		diffText.x = scoreBG.getGraphicMidpoint().x;
		add(diffText);

		rateText = new FlxText(diffText.x, diffText.y + 36, 0, "", 24);
		rateText.alignment = CENTER;
		rateText.font = scoreText.font;
		rateText.x = scoreBG.getGraphicMidpoint().x;
		add(rateText);

		add(scoreText);

		changeSelection();
		changeDiff();
		resetScore(true);
	}

	function checkLock(week:String):Bool
	{
		var weekName = WeekParser.loadedWeeks.get(week);
		return (weekName.locked);
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, songColor:FlxColor)
	{
		var coolDiffs = [];
		for (i in CoolUtil.difficulties)
			if (FileSystem.exists(Paths.songJson(songName, songName + '-' + i))
				|| (FileSystem.exists(Paths.songJson(songName, songName)) && i == "NORMAL"))
				coolDiffs.push(i);

		if (coolDiffs.length > 0)
		{
			songs.push(new SongMetadata(songName, weekNum, songCharacter, songColor));
			existingDifficulties.push(coolDiffs);
		}
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?songColor:Array<FlxColor>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];
		if (songColor == null)
			songColor = [FlxColor.WHITE];

		var num:Array<Int> = [0, 0];
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num[0]], songColor[num[1]]);

			if (songCharacters.length != 1)
				num[0]++;
			if (songColor.length != 1)
				num[1]++;
		}
	}

	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxTween.color(bg, 0.35, bg.color, mainColor);

		var lerpVal = Main.framerateAdjust(0.1);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = FlxG.keys.justPressed.ENTER;
		var shiftP = FlxG.keys.pressed.SHIFT;
		var seven = FlxG.keys.justPressed.SEVEN;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if (shiftP)
			shiftMult = 3;

		if (songs.length > 1)
		{
			if (!lockedMovement)
			{
				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}
	
				/**
				 * Hold Scrolling Code
				 * @author ShadowMario
				**/
	
				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
	
					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
						changeDiff();
					}
				}
	
				if (FlxG.mouse.wheel != 0)
				{
					changeSelection(-shiftMult * FlxG.mouse.wheel);
					changeDiff();
				}
	
				if (controls.BACK || FlxG.mouse.justPressedRight)
				{
					if (presses <= 0)
					{
						if (FlxG.sound.music != null)
							FlxG.sound.music.stop();
						threadActive = false;
						//CoolUtil.difficulties = CoolUtil.baseDifficulties;
						FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
						Main.switchState(this, new MainMenuState());
					}
		
					if (presses > 0)
					{
						FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
						endBullshit();
					}
				}
		
				if (accepted || FlxG.mouse.justPressed)
					loadSong(true, true);
				else if (seven)
				{
					loadSong(false, true);
					PlayState.chartingMode = true;
					PlayState.prevCharter == (shiftP ? 1 : 0);
					Main.switchState(this, (shiftP ? new ChartEditor() : new OriginalChartEditor()));
				}
				/*
				else if (ctrl)
					openSubState(new FreeplaySubstate());
				*/
				else if (controls.RESET && presses < 3 && !shiftP)
				{
					presses++;
					resetScore();
				}
				
				if (controls.UI_LEFT_P && !shiftP)
					changeDiff(-1);
				else if (controls.UI_RIGHT_P && !shiftP)
					changeDiff(1);

				if (controls.UI_LEFT_P && shiftP)
					songRate -= 0.05;
				else if (controls.UI_RIGHT_P && shiftP)
					songRate += 0.05;
		
				if (controls.RESET && shiftP)
					songRate = 1;
			}
		}

		if (songRate <= 0.5)
			songRate = 0.5;
		else if (songRate >= 3)
			songRate = 3;

		// for pitch playback
		FlxG.sound.music.pitch = songRate;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		rateText.text = "RATE: " + songRate + "x";
		rateText.x = FlxG.width - rateText.width;
		repositionHighscore();

		mutex.acquire();
		if (songToPlay != null)
		{
			FlxG.sound.playMusic(songToPlay);

			if (FlxG.sound.music.fadeTween != null)
				FlxG.sound.music.fadeTween.cancel();

			FlxG.sound.music.volume = 0.0;
			FlxG.sound.music.fadeIn(1.0, 0.0, 1.0);

			songToPlay = null;
		}
		mutex.release();
	}

	function loadSong(go:Bool = true, stopThread:Bool = true)
	{
		//Main.isSongTrans = true;

		var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(),
			CoolUtil.difficulties.indexOf(existingDifficulties[curSelected][curDifficulty]));

		if (existingDifficulties[curSelected][curDifficulty] == null)
			return;

		PlayState.SONG = Song.loadSong(poop, songs[curSelected].songName.toLowerCase());
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curDifficulty;

		PlayState.storyWeek = songs[curSelected].week;
		#if DEBUG_TRACES trace('CUR WEEK' + PlayState.storyWeek); #end

		if (stopThread)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			threadActive = false;
		}
		if (go)
		{
			if (songRate < 1)
				PlayState.preventScoring = true; // lmao.
			Conductor.playbackRate = songRate;
			lockedMovement = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxFlicker.flicker(grpSongs.members[curSelected], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				Main.switchState(this, new PlayState());
			});
		}
	}

	var lastDifficulty:String;

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		if (lastDifficulty != null && change != 0)
			while (existingDifficulties[curSelected][curDifficulty] == lastDifficulty)
				curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = existingDifficulties[curSelected].length - 1;
		if (curDifficulty > existingDifficulties[curSelected].length - 1)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		diffText.text = '< ' + existingDifficulties[curSelected][curDifficulty] + ' >';
		lastDifficulty = existingDifficulties[curSelected][curDifficulty];
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		// set up color stuffs
		mainColor = songs[curSelected].songColor;

		// song switching stuffs

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		//

		#if DEBUG_TRACES trace("curSelected: " + curSelected); #end

		changeDiff();

		changeSongPlaying();
	}

	function changeSongPlaying()
	{
		if (songThread == null)
		{
			songThread = Thread.create(function()
			{
				while (true)
				{
					if (!threadActive)
					{
						#if DEBUG_TRACES trace("Killing thread"); #end
						return;
					}

					var index:Null<Int> = Thread.readMessage(false);
					if (index != null)
					{
						if (index == curSelected && index != curSongPlaying)
						{
							#if DEBUG_TRACES trace("Loading index " + index); #end

							var inst:Sound = Paths.songSounds(songs[curSelected].songName, 'Inst');

							if (index == curSelected && threadActive)
							{
								mutex.acquire();
								songToPlay = inst;
								mutex.release();

								curSongPlaying = curSelected;
							}
							#if DEBUG_TRACES
							else
								trace("Nevermind, skipping " + index);
							#end
						}
						#if DEBUG_TRACES
						else
							trace("Skipping " + index);
						#end
					}
				}
			});
		}

		songThread.sendMessage(curSelected);
	}

	var playingSongs:Array<FlxSound> = [];

	function repositionHighscore()
	{
		// Adhere the position of all the things (I'm sorry it was just so ugly before I had to fix it Shubs)
		scoreText.x = FlxG.width - scoreText.width - 5;
		scoreBG.width = scoreText.width + 8;
		scoreBG.x = FlxG.width - scoreBG.width;
		diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);
	}

	function resetScore(noSound:Bool = false)
	{
		if (!noSound)
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);

		if (!noSound && !Init.trueSettings.get('Disable Flashing Lights')) // shut.
			FlxTween.color(bg, 0.50, FlxColor.GRAY, bg.color);

		if (presses < 0 || presses > 3)
			presses = 0;

		if (presses == 2)
		{
			FlxG.sound.music.volume = 0.3;
		}

		if (presses == 3)
		{
			noSound = true;
			FlxG.sound.play(Paths.sound('resetScore_sfx'), 0.4);
			iconArray[curSelected].animation.play('losing');
			Highscore.clearData(songs[curSelected].songName, curDifficulty);
			noSound = false;
			endBullshit();
		}
	}

	function endBullshit()
	{
		new FlxTimer().start(1, function(resetText:FlxTimer)
		{
			presses = 0;
			iconArray[curSelected].animation.play('static');
			FlxG.sound.music.fadeIn(1.0, 0.3, 1.0);
		});

		FlxTween.color(bg, 0.35, bg.color, mainColor);

		changeSelection();
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var songColor:FlxColor = FlxColor.WHITE;

	public function new(song:String, week:Int, songCharacter:String, songColor:FlxColor)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.songColor = songColor;
	}
}
