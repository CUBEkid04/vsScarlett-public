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

class ChangelogsState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 2;

	private var grpSongs:FlxTypedGroup<Alphabet>;

	public static var theArrayOfChanges:Array<Dynamic> = [
		['2.0'],
		['The True Antagonist'],
		['Two new weeks',		'Iron Rage and Frost'],
		['Six new songs',			' With the new addition of weeks, \n 3 songs had been added per week.'],
		['Alt-Mix',			' A tougher game mode created as \n a harder challenge for worthy players. '],
		['Preferences',			' Players can now choose preferences \n to fit their gameplay. '],
		[''],
		['1.0'],
		['FULL RELEASE, BABY!'],
		['Two new songs',		' Allstar and Wet Paint, \n to complete Week 1. '],
		['Dialogue and Story',			'Added character dialogue to the Story mode.'],
		['Backdrops',			' Stage Backdrops for Week 1, \n set in an open alley. ']
	];

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

		super.create();
	}

	private var informativeText:String;
	private var informative:FlxText;

	public function generateMenu():Void
	{
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...theArrayOfChanges.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var segText:Alphabet = new Alphabet(0, 70 * i, theArrayOfChanges[i][0], !isSelectable, false);
			segText.isMenuItem = true;
			segText.screenCenter(X);
			segText.targetY = i;
			grpSongs.add(segText);
		}

		informative = new FlxText(0, 0, FlxG.width, " ", 32);
		informative.setFormat("Continuum Bold", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		informative.screenCenter();
		informative.y = 600;
		informative.antialiasing = true;
		add(informative);

		changeSelection();
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
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = theArrayOfChanges.length - 1;
			if (curSelected >= theArrayOfChanges.length)
				curSelected = 0;
		}
		while(unselectableCheck(curSelected));

		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
		}
		informative.text = theArrayOfChanges[curSelected][1];
	}

	private function unselectableCheck(num:Int):Bool
	{
		return theArrayOfChanges[num].length <= 1;
	}
}