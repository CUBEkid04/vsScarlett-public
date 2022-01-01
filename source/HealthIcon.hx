package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		antialiasing = true;
		animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('bf-dirty', [0, 1], 0, false, isPlayer);
		animation.add('bf-car', [0, 1], 0, false, isPlayer);
		animation.add('bf-christmas', [0, 1], 0, false, isPlayer);
		animation.add('bf-christmas-w3', [0, 1], 0, false, isPlayer);
		animation.add('bf-old', [3, 4], 0, false, isPlayer);
		animation.add('gf', [2], 0, false, isPlayer);
		animation.add('bf-gf', [0, 1], 0, false, isPlayer); // [5]
		animation.add('bf-gf-w7', [0, 1], 0, false, isPlayer); // [5]
		animation.add('bf-gf-christmas', [0, 1], 0, false, isPlayer);
		animation.add('scarlett', [6, 7], 0, false, isPlayer);
		animation.add('velvet', [8, 9], 0, false, isPlayer);
		animation.add('velvet-rage', [8, 9], 0, false, isPlayer);

		animation.add('bf-gf-duet', [5], 0, false, isPlayer);

		animation.add('girlfriend', [2], 0, false, isPlayer);
		animation.add('ziona', [56, 57], 0, false, isPlayer);

		animation.play(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
