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

class AltMixChooserState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	public static var altMixAlbum:String = " ";

	var scoreTextN:Alphabet;
	var diffTextN:Alphabet;
	var diffTextStr:String = "NORMAL";
	var diffTextColor:Int = FlxColor.fromRGB(255, 255, 0);

	override function create()
	{
		var initSonglist = CoolUtil.coolTextFile(Paths.altMixText(altMixAlbum, 'songList'));

		for (i in 0...initSonglist.length)
		{
			songs.push(new SongMetadata(initSonglist[i], 1, 'gf', FlxColor.fromRGB(128, 128, 128)));
		}

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuAltMix'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.screenCenter(X);
			songText.forceX = songText.x;
			grpSongs.add(songText);
		}


		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("contb.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG:FlxSprite = new FlxSprite(0, 642).makeGraphic(Std.int(FlxG.width), 78, 0xFF000000);
		scoreBG.alpha = 0.6;

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;

		add(scoreBG);


		changeSelection();
		MainMenuState.lambda = false;
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;


		remove(scoreTextN);
		var scoreTextN_:Alphabet = new Alphabet(6, 570, "Personal Best: " + lerpScore, false, false, 'alphabetInverted', 0.5);
		scoreTextN = scoreTextN_;
		add(scoreTextN_);

		remove(diffTextN);
		var diffTextN_:Alphabet = new Alphabet(6, 600, diffTextStr, false, false, 'alphabetInverted', 0.5);
		diffTextN = diffTextN_;
		diffTextN.color = diffTextColor;
		diffTextN_.color = diffTextColor;
		add(diffTextN_);


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

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			PlayState.SONG = Song.loadAltFromJson(poop, (songs[curSelected].songName.toLowerCase()), altMixAlbum + '/');
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.isBonusWeek = false;
			PlayState.isAltMix = true;
			PlayState.bonusStringID = " ";
			PlayState.altMixAlbum = altMixAlbum;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName + '-altmix-' + altMixAlbum, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				if (altMixAlbum == "B-Side")
				{
					diffTextStr = "EASIER";
					diffTextColor = FlxColor.fromRGB(249, 207, 81);
				}
				else
				{
					diffTextStr = "EASY";
					diffTextColor = FlxColor.fromRGB(0, 255, 0);
				}
			case 1:
				if (altMixAlbum == "B-Side")
				{
					diffTextStr = 'STANDARD';
					diffTextColor = FlxColor.fromRGB(255, 43, 123);
				}
				else
				{
					diffTextStr = 'NORMAL';
					diffTextColor = FlxColor.fromRGB(255, 255, 0);
				}
				
			case 2:
				if (altMixAlbum == "B-Side")
				{
					diffTextStr = "FLIP";
					diffTextColor = FlxColor.fromRGB(0, 255, 255);
				}
				else
				{
					diffTextStr = "HARD";
					diffTextColor = FlxColor.fromRGB(255, 0, 0);
				}
		}
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName + '-altmix-' + altMixAlbum, curDifficulty);
		// lerpScore = 0;
		#end

		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.instAlt(songs[curSelected].songName, altMixAlbum), 0);
		#end

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