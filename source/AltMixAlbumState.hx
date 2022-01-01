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

class AltMixAlbumState extends MusicBeatState
{
	var songs:Array<AltMixAlbumMetadata> = [];

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

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGGreen'));
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

		var albumArray:Array<String> = [];

		var initAlbumlist = CoolUtil.coolTextFile(Paths.chosenPathTXT('altMix/albumList'));

		for (i in 0...initAlbumlist.length)
		{
			albumArray.push(initAlbumlist[i]);
		}

		for (item in albumArray)
		{
			songs.push(new AltMixAlbumMetadata(item));
		}

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].albumName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;

			grpSongs.add(songText);
		}
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

		if (accepted)
		{
			AltMixChooserState.altMixAlbum = songs[curSelected].albumName;
			trace("Album:" + songs[curSelected].albumName);
			FlxG.switchState(new AltMixChooserState());
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