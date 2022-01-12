package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var sustainLengthSprite:Float = 1.0;
	public var isSustainNote:Bool = false;
	public var isSustainEnd:Bool = false;

	public var noteScore:Float = 1;
	public var mania:Int = 0; // stole more from shaggy XD no sue, i cant write another set of notes for a new mod again

	public static var swagWidth:Float;
	public static var noteScale:Float;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var warning:Bool = false;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?isWarning:Bool = false)
	{
		swagWidth = 160 * 0.7;
		noteScale = 0.7;
		sustainLengthSprite = 1.0;
		mania = 0;
		if (PlayState.SONG.mania == 1)
		{
			swagWidth = 100 * 0.7;
			noteScale = 0.5;
			sustainLengthSprite = 1.25;
			mania = 1;
		}

		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		warning = isWarning;

		if (!warning)
		{
					frames = Paths.getSparrowAtlas('NOTE_assets');

					animation.addByPrefix('greenScroll', 'up0');
					animation.addByPrefix('redScroll', 'right0');
					animation.addByPrefix('blueScroll', 'down0');
					animation.addByPrefix('purpleScroll', 'left0');
					animation.addByPrefix('turqScroll', 'kright0');
					animation.addByPrefix('yellowScroll', 'kleft0');
					animation.addByPrefix('whiteScroll', 'space0');

					animation.addByPrefix('purpleholdend', 'left end hold');
					animation.addByPrefix('greenholdend', 'up hold end');
					animation.addByPrefix('redholdend', 'right hold end');
					animation.addByPrefix('blueholdend', 'down hold end');
					animation.addByPrefix('turqholdend', 'kright hold end');
					animation.addByPrefix('yellowholdend', 'kleft hold end');
					animation.addByPrefix('whiteholdend', 'space hold end');

					animation.addByPrefix('purplehold', 'left hold piece');
					animation.addByPrefix('greenhold', 'up hold piece');
					animation.addByPrefix('redhold', 'right hold piece');
					animation.addByPrefix('bluehold', 'down hold piece');
					animation.addByPrefix('turqhold', 'kright hold piece');
					animation.addByPrefix('yellowhold', 'kleft hold piece');
					animation.addByPrefix('whitehold', 'space hold piece');

					setGraphicSize(Std.int(width * noteScale));
					updateHitbox();
					antialiasing = true;
		}
		else
		{
			loadGraphic(Paths.image('NOTE_warning'));
			setGraphicSize(Std.int(width * noteScale));
			updateHitbox();
			antialiasing = true;
		}

		var frameN:Array<String> = ['purple', 'blue', 'green', 'red'];
		if (mania == 1) frameN = ['yellow', 'purple', 'blue', 'white', 'green', 'red', 'turq'];
		
		x += swagWidth * noteData;
		animation.play(frameN[noteData] + 'Scroll');

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			if(ScarlettOptions.downscroll) flipY = true;

			x += width / 2;

			animation.play(frameN[noteData] + 'holdend');
			if (ScarlettOptions.downscroll)
			{
				y += 79;
			}
			switch (noteData)
			{
				case 0:
				//nada
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
					//nada
				}
				if (ScarlettOptions.downscroll)
				{
					y -= 79;
				}
				prevNote.animation.play(frameN[prevNote.noteData] + 'hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed * (0.7 / noteScale);
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
