package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef DiaBox =
{
	var dia:Array<DiaPage>;
}

typedef DiaPage =
{
	var portraitFrame:Null<String>;
	var speed:Null<Float>;
	var text:Null<String>;
}

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';
	var diaSpeed:Float = 0.05;

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		var hasDialog = false;
		box = new FlxSprite(0, 0).loadGraphic(Paths.image('scarlett/dialogueBox'));
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'paintball':
				hasDialog = true;
			case 'allstar':
				hasDialog = true;
			case 'wet-paint':
				hasDialog = true;
			case 'rendezvous':
				hasDialog = true;
			case 'sawgrinder':
				hasDialog = true;
			case 'russian-rundown':
				hasDialog = true;
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
		portraitLeft = new FlxSprite(1020, 260);
		portraitLeft.frames = Paths.getSparrowAtlas('scarlett/dialogueChar');

		portraitLeft.animation.addByPrefix('bf', 'Dialogue BF', 24, false);
		portraitLeft.animation.addByPrefix('gf', 'Dialogue GF', 24, false);
		portraitLeft.animation.addByPrefix('scarlett', 'Dialogue Scarlet', 24, false);
		portraitLeft.animation.addByPrefix('velvet', 'Dialogue Velvet', 24, false);

		portraitLeft.scrollFactor.set();
		portraitLeft.antialiasing = true;
		add(portraitLeft);

		box.antialiasing = true;
		add(box);

		// box.screenCenter(X);
		// portraitLeft.screenCenter(X);

		// handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
		// add(handSelect);


		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Continuum Bold';
		dropText.color = 0xFFD89494;
		// add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Continuum Bold';
		swagDialogue.color = 0xFF7FFF7F;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/dialogue_mod_char'), 0.6)]; // dialogue_scarlett_char
		swagDialogue.antialiasing = true;
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true, 'alphabetDia', 0.5);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		dropText.text = swagDialogue.text;

		dialogueOpened = true;

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY  && dialogueStarted == true)
		{
			dialogue.playingDia = false;
			remove(dialogue);
				
			FlxG.sound.play(Paths.sound('dialogue/dialogue_mod_click'), 0.8); // dialogue_scarlett_click

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
						FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.alpha -= 1 / 5;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		var theDialog:Alphabet = new Alphabet(68, 412, dialogueList[0], false, true, 'alphabetDia', 0.5, diaSpeed);
		dialogue = theDialog;
		add(theDialog);

		switch (curCharacter)
		{
			case 'gf':
				portraitLeft.visible = true;
				portraitLeft.animation.play('gf');
			case 'bf':
				portraitLeft.visible = true;
				portraitLeft.animation.play('bf');
			case 'scarlett':
				portraitLeft.visible = true;
				portraitLeft.animation.play('scarlett');
			case 'velvet':
				portraitLeft.visible = true;
				portraitLeft.animation.play('velvet');
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();

		var splitNameB:Array<String> = dialogueList[0].split(";");
		diaSpeed = Std.parseFloat(splitNameB[1]);
		dialogueList[0] = dialogueList[0].substr(splitNameB[1].length + 2).trim();
	}
}
