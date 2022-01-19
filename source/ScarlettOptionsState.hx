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
	var options:Array<Array<String>> = [
		['PREFERENCES', "Header"],
		['Epileptic Mode', "Selectable", "Heavily reduces the amount of crazy VFX\nin certain songs.\nENABLE THIS IMMEDIATELY IF YOU ARE PRONE TO EPILEPSY!", "Bool"],
		['Screenshake', "Selectable", "Makes the screen shake around sometimes.\nPlayers who get motionsick easily should disable this.\n ", "Bool"],
		['Color Shift', "Selectable", "Depending on the environment,\nchanges most backdrop elements and characters\ncolor to reflect the current environment.", "Bool"],
		['Downscroll', "Selectable", " \nInverts the strum scroll so notes scroll downward instead of upward\n ", "Bool"],
		['Center Scroll', "Selectable", " \nCenters player strums and hides enemy strums\n ", "Bool"],
		['Ghost Tapping', "Selectable", "Disables missing when pressing keys.\nProvides a forgiving game.\n(High scores aren't saved when active)", "Bool"],
		['Ratings Visibility', "Selectable", " \nDetermines note hit rating and combo visibiltiy\n ", "Bool"],
		['Note Splashes', "Selectable", " \nDetermines note splash visibiltiy\n ", "Bool"],
		['Ambience', "Selectable", "Plays background noise during songs that use\nan animated and lively backdrop with motion\nAmbience can be enabled for motion and effects.", "Bool"],
		['Ruv Mode', "Selectable", "Makes Girlfriend display her fear animation when\nVelvet hits a note during Russian Rundown.\nUseful for certain OCs afraid of ear piercing screams.", "Bool"]
	];

	var selector:FlxText;
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<OptionCheckBox> = [];

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

		generateMenu();

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	public function generateMenu():Void
	{
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			if (options[i][1] == "Header")
			{
				var optionText:Alphabet = new Alphabet(0, 70 * i, options[i][0], true, false);
				optionText.isMenuItem = true;
				optionText.screenCenter(X);
				optionText.forceX = optionText.x;
				optionText.targetY = i;
				grpOptions.add(optionText);

				var icon:OptionCheckBox = new OptionCheckBox(false);
				icon.sprTracker = optionText;
				icon.visible = false;
				iconArray.push(icon);
				add(icon);
			}
			else
			{
				var optionText:Alphabet = new Alphabet(0, 70 * i, options[i][0], false, false);
				optionText.isMenuItem = true;
				optionText.x += 300;
				optionText.forceX = 300;
				optionText.targetY = i;
				grpOptions.add(optionText);

				var icon:OptionCheckBox = new OptionCheckBox(false);
				icon.sprTracker = optionText;
				if (options[i][3] != "Bool")
				{
					icon.visible = false;
				}
				iconArray.push(icon);
				add(icon);
			}
			
			if (options[i][1] != "Header")
				if(curSelected == -1) curSelected = i;
		}

		changeSelection();
		reloadValues();
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

		if(accepted)
		{
			switch(options[curSelected][0])
			{
				case 'Epileptic Mode':
					ScarlettOptions.epileptic = !ScarlettOptions.epileptic;
				case 'Screenshake':
					ScarlettOptions.screenShake = !ScarlettOptions.screenShake;
				case 'Color Shift':
					ScarlettOptions.colorshift = !ScarlettOptions.colorshift;
				case 'Downscroll':
					ScarlettOptions.downscroll = !ScarlettOptions.downscroll;
				case 'Center Scroll':
					ScarlettOptions.centerscroll = !ScarlettOptions.centerscroll;
				case 'Ghost Tapping':
					ScarlettOptions.ghostTap = !ScarlettOptions.ghostTap;
				case 'Ratings Visibility':
					ScarlettOptions.ratingVisibility = !ScarlettOptions.ratingVisibility;
				case 'Note Splashes':
					ScarlettOptions.noteSplash = !ScarlettOptions.noteSplash;
				case 'Ambience':
					ScarlettOptions.ambience = !ScarlettOptions.ambience;
				case 'Ruv Mode':
					ScarlettOptions.ruvMode = !ScarlettOptions.ruvMode;
			}
			FlxG.sound.play(Paths.sound('scrollMenu'));
			ScarlettOptions.saveSettings();
			reloadValues();
		}
	}

	function reloadValues()
	{
		for (i in 0...iconArray.length)
		{
			var checkbox:OptionCheckBox = iconArray[i];
			if(checkbox != null)
			{
				var daValue:Bool = false;
				switch(options[i][0])
				{
					case 'Epileptic Mode':
						daValue = ScarlettOptions.epileptic;
					case 'Screenshake':
						daValue = ScarlettOptions.screenShake;
					case 'Color Shift':
						daValue = ScarlettOptions.colorshift;
					case 'Downscroll':
						daValue = ScarlettOptions.downscroll;
					case 'Center Scroll':
						daValue = ScarlettOptions.centerscroll;
					case 'Ghost Tapping':
						daValue = ScarlettOptions.ghostTap;
					case 'Ratings Visibility':
						daValue = ScarlettOptions.ratingVisibility;
					case 'Note Splashes':
						daValue = ScarlettOptions.noteSplash;
					case 'Ambience':
						daValue = ScarlettOptions.ambience;
					case 'Ruv Mode':
						daValue = ScarlettOptions.ruvMode;
				}
				checkbox.daValue = daValue;
			}
		}
	}

	private function unselectableCheck(num:Int):Bool {
		return options[num][1] == "Header";
	}

	private function changeChoice(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		if (options[curSelected][1] == "Header")
			changeChoice(change);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		changeChoice(change);

		informativeText = options[curSelected][2];
		generateInformative();

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}