package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class PhotoWarningState extends MusicBeatState
{
	public static var leftState:Bool = false;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuWarning'));
		add(bg);

		var txtHead:FlxText = new FlxText(0, 0, FlxG.width, "PHOTOSENSITIVITY WARNING", 96);
		txtHead.setFormat("Quincy Caps", 96, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txtHead.screenCenter();
		txtHead.y = 50;
		txtHead.antialiasing = true;
		//add(txtHead);

		var headText:FlxSprite = new FlxSprite(0, 10);
		headText.frames = Paths.getSparrowAtlas('photoWarningScreen/text');
		headText.animation.addByPrefix('idle', "photoSensitivityWarningText", 24);
		headText.animation.play('idle');
		headText.screenCenter(X);
		headText.antialiasing = true;
		add(headText);

		var txtBody:FlxText = new FlxText(0, 0, FlxG.width, 
			"Certain songs in this mod contain an extreme\namount of visual effects and flashing that might\ntrigger seizures if the player is prone to epilepsy.", 32);
		txtBody.setFormat("Continuum Bold", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txtBody.screenCenter();
		txtBody.y -= 75;
		txtBody.antialiasing = true;
		add(txtBody);

		var txtB:FlxText = new FlxText(0, 0, FlxG.width, 
			"If you are prone to epilepsy, go into Options\nand enable the Epileptic Mode.", 32);
		txtB.setFormat("Continuum Bold", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txtB.screenCenter();
		txtB.y = 400;
		txtB.antialiasing = true;
		add(txtB);

		var txtC:FlxText = new FlxText(0, 0, FlxG.width, 
			"Press [ENTER] to dismiss\nPress [Y] to dismiss and enable Epileptic Mode\nPress [X] to never show again", 32);
		txtC.setFormat("Continuum Bold", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txtC.screenCenter();
		txtC.y = 620;
		txtC.x += 330;
		txtC.y -= 90;
		txtC.antialiasing = true;
		add(txtC);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT || FlxG.keys.justPressed.Y || FlxG.keys.justPressed.X)
		{
			if (FlxG.keys.justPressed.X && !leftState)
			{
				ScarlettOptions.permDisableWarning = true;
				ScarlettOptions.saveSettings();
			}
			if (FlxG.keys.justPressed.Y && !leftState)
			{
				ScarlettOptions.epileptic = true;
				ScarlettOptions.saveSettings();
			}
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
