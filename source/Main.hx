package;

import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import base.debug.*;
import base.debug.Overlay.Console;
import dependency.Discord;
import dependency.FNFTransition;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.UncaughtErrorEvent;
import states.*;

// Here we actually import the states and metadata, and just the metadata.
// It's nice to have modularity so that we don't have ALL elements loaded at the same time.
// at least that's how I think it works. I could be stupid!
class Main extends Sprite
{
	public static var defaultFramerate = 120;

	// transition image, enabled when transitioning to a song (currently disabled by default;
	public static var isSongTrans:Bool;

	public static var initialState:Class<FlxState> = TitleState; // specify the state where the game should start at;

	public static var foreverVersion:String = '0.3.1'; // current forever engine version;
	public static var underscoreVersion:String = '0.2.2-git'; // current forever engine underscore version;

	public static var commitHash:Null<String>; // commit hash, for github builds;
	public static var showCommitHash:Bool = true; // whether to actually show the commit hash;

	public static var overlay:Overlay;
	public static var console:Console;

	// calls a function to set the game up
	public function new()
	{
		super();

		commitHash = getGitCommitHash();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		FlxTransitionableState.skipNextTransIn = true;

		addChild(new FlxGame(0, 0, Init, 1, 120, 120, true));

		// begin the discord rich presence
		#if DISCORD_RPC
		Discord.initializeRPC();
		Discord.changePresence('');
		#end

		overlay = new Overlay(0, 0);
		addChild(overlay);

		console = new Console();
		addChild(console);
	}

	public static function framerateAdjust(input:Float)
	{
		return input * (60 / FlxG.drawFramerate);
	}

	/*
		This is used to switch "rooms," to put it basically. Imagine you are in the main menu, and press the freeplay button.
		That would change the game's main class to freeplay, as it is the active class at the moment.
	 */
	public static function switchState(curState:FlxState, target:FlxState)
	{
		// Custom made Trans in
		if (!FlxTransitionableState.skipNextTransIn)
		{
			curState.openSubState(new FNFTransition(0.35, false));
			FNFTransition.finishCallback = function()
			{
				isSongTrans = false;
				FlxG.switchState(target);
			};
			return #if DEBUG_TRACES trace('changed state') #end;
		}
		else
		{
			FlxTransitionableState.skipNextTransIn = false;
			FlxTransitionableState.skipNextTransOut = false;
		}
		FlxTransitionableState.skipNextTransIn = false;
		// load the state
		FlxG.switchState(target);
	}

	public static function updateFramerate(newFramerate:Int)
	{
		// flixel will literally throw errors at me if I dont separate the orders
		if (newFramerate > FlxG.updateFramerate)
		{
			FlxG.updateFramerate = newFramerate;
			FlxG.drawFramerate = newFramerate;
		}
		else
		{
			FlxG.drawFramerate = newFramerate;
			FlxG.updateFramerate = newFramerate;
		}
	}

	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = "crash/" + "FE_" + dateNow + ".txt";

		errMsg = "Friday Night Funkin' v" + Lib.application.meta["version"] + "\n";
		errMsg += "Forever Engine Underscore v" + Main.underscoreVersion + (showCommitHash ? '${commitHash}' : '') + "\n";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: "
			+ e.error
			+
			"\nPlease report this error to the GitHub page: https://github.com/BeastlyGhost/Forever-Engine-Underscore
			\n>Crash Handler written by: sqirra-rng\n";

		try // to make the game not crash if it can't save the crash file
		{
			if (!FileSystem.exists("crash"))
				FileSystem.createDirectory("crash");

			File.saveContent(path, errMsg + "\n");
		}

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		Discord.shutdownRPC();
		Sys.exit(1);
	}

	public static function getGitCommitHash()
	{
		var process = new sys.io.Process('git', ['rev-parse', 'HEAD']);

		var commitHash:String;

		try // read the output of the process
		{
			commitHash = process.stdout.readLine();
		}
		catch (e) // leave it as blank in the event of an error
		{
			commitHash = '';
		}
		var trimmedCommitHash:String = commitHash.substr(0, 7);

		// Generates a string expression
		return ' (' + trimmedCommitHash + ')';
	}
}
