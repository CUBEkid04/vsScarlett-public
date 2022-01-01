package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class ScarlettOptionsState extends MusicBeatState
{
	var songs:Array<MenuOption> = [];

	var selector:FlxText;
	var curSelected:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	override function create()
	{
		if (FlxG.sound.music != null)
		{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGPink'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();

		generateMenu();

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	public function generateMenu():Void
	{
		remove(grpSongs);
		grpSongs = new FlxTypedGroup<Alphabet>();
		songs.splice(0, songs.length);
		add(grpSongs);

		var optionArray:Array<String> = [];

		var optionEpileptic:String = (ScarlettOptions.getEpileptic()) ? "Active" : "Inactive";
		var optionGhostTap:String = (ScarlettOptions.getGhostTap()) ? "Enabled" : "Disabled";
		var optionRuv:String = (ScarlettOptions.getRuvMode()) ? "Enabled" : "Disabled";
		var optionRatingVisibility:String = (ScarlettOptions.getRatingVisibility()) ? "Visible" : "Hidden";
		var optionAmbience:String = (ScarlettOptions.getAmbience()) ? "Enabled" : "Disabled";
		var optionColorshift:String = (ScarlettOptions.getColorshift()) ? "Enabled" : "Disabled";

		// var optionWarningNotes:String = (ScarlettOptions.getWarningNotes()) ? "Active" : "Inactive";
		// var optionHeatwave:String = (ScarlettOptions.getHeatwave()) ? "Active" : "Inactive";

		optionArray.push('Epileptic Mode $optionEpileptic');
		optionArray.push('Ghost Tapping $optionGhostTap');
		optionArray.push('Ruv Mode $optionRuv');
		optionArray.push('Ratings $optionRatingVisibility');
		optionArray.push('Ambience $optionAmbience');
		optionArray.push('Color Shift $optionColorshift');

		// optionArray.push('Warning Notes $optionWarningNotes');
		// optionArray.push('Heatwave $optionHeatwave');

		for (item in optionArray)
		{
			songs.push(new MenuOption(item));
		}

		var optionBool:Array<Bool> = [
			ScarlettOptions.getEpileptic(),
			ScarlettOptions.getGhostTap(),
			ScarlettOptions.getRuvMode(),
			ScarlettOptions.getRatingVisibility(),
			ScarlettOptions.getAmbience(),
			ScarlettOptions.getColorshift()

			// ScarlettOptions.getWarningNotes(),
			// ScarlettOptions.getHeatwave()
		];

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].theOption, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;

			if (optionBool[i])
			{
				songText.color = 0x33ff33;
			}

			grpSongs.add(songText);
		}
		changeSelection();
		generateInformative();
	}

	private var informativeText:String;
	private var informative:FlxText;
	

	public function generateInformative():Void
	{
		remove(informative);
		informative = new FlxText(0, 0, FlxG.width, informativeText, 32);
		informative.setFormat("Continuum Bold", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		informative.screenCenter();
		informative.y = 600;
		informative.antialiasing = true;
		add(informative);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			switch(curSelected)
			{
				case 0:
					ScarlettOptions.toggleEpileptic();
				case 1:
					ScarlettOptions.toggleGhostTap();
				case 2:
					ScarlettOptions.toggleRuvMode();
				case 3:
					ScarlettOptions.toggleRatingVisibility();
				case 4:
					ScarlettOptions.toggleAmbience();
				case 5:
					ScarlettOptions.toggleColorshift();
			}

			generateMenu();
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		
		switch(curSelected)
		{
			case 0:
				informativeText = "Heavily reduces the amount of crazy VFX\nduring Russian Rundown.\nENABLE THIS IMMEDIATELY IF YOU ARE PRONE TO EPILEPSY!";
			case 1:
				informativeText = "Disables missing when pressing keys.\nProvides a forgiving game.\n(Cannot unlock bonus weeks and high scores aren't saved when active)";
			case 2:
				informativeText = "Makes Girlfriend display her fear animation when\nVelvet hits a note during Russian Rundown.\nUseful for certain OCs afraid of ear piercing screams.";
			case 3:
				informativeText = " \nDetermines note hit rating and combo visibiltiy\n ";
			case 4:
				informativeText = "Plays background noise during songs that use\nan animated and lively backdrop with motion\nAmbience can be enabled for motion and effects.";
			case 5:
				informativeText = "Depending on the environment,\nchanges most backdrop elements and characters\ncolor to reflect the current environment.";

			// case 2:
			// 	informativeText = "Adds additional dangerous 'warning' notes you must hit\notherwise you lose a lot of health or immediately game end.\nAdds an extra layer of challenge to certain songs.";
			// case 3:
			// 	informativeText = "Applies a heatwave distortion in extremely hot areas\nsuch as volcanoes or lavawork facilities";
		}
		generateInformative();

		var bullShit:Int = 0;

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
	}
}