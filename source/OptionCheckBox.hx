package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class OptionCheckBox extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var daValue(default, set):Bool;

	public function new(checked = false)
	{
		super();
		loadGraphic(Paths.image('checkbox'), true, 100, 100);

		antialiasing = true;
		animation.add('checked', [1], 0, false, false);
		animation.add('static', [0], 0, false, false);

		set_daValue(checked);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x - 100, sprTracker.y + 35);
	}

	private function set_daValue(value:Bool):Bool
	{
		if(value)
		{
			if(animation.curAnim.name != 'checked')
			{
				animation.play('checked', true);
			}
		}
		else
		{
			animation.play("static");
		}
		return value;
	}
}
