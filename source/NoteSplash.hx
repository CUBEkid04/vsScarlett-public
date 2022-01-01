package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

class NoteSplash extends FlxSprite
{
	public function new(xPos:Float,yPos:Float,key:Int = 0)
	{
		super(xPos,yPos);

		frames = Paths.getSparrowAtlas('noteSplashes');

		animation.addByPrefix("splash0", "PurpleSplash", 24, false);
		animation.addByPrefix("splash1", "BlueSplash", 24, false);
		animation.addByPrefix("splash2", "GreenSplash", 24, false);
		animation.addByPrefix("splash3", "RedSplash", 24, false);

        	setupNoteSplash(xPos, yPos, key);
	}

	public function setupNoteSplash(xPos:Float,yPos:Float,key:Int)
	{
		setPosition(xPos, yPos);
        	alpha = 0.6;

		animation.play("splash" + key, true);
		updateHitbox();
		offset.set(0.3 * width, 0.3 * height);
	}

	override public function update(elapsed)
	{
		if (animation.curAnim.finished)
		{
			kill();
		}
		super.update(elapsed);
	}
}
