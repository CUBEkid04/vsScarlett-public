package;

import flixel.FlxG;

class ScarlettOptions
{
	#if (haxe >= "4.0.0")
	public static var scarlettOptionsData:Map<String, Bool> = new Map();
	#else
	public static var scarlettOptionsData:Map<String, Bool> = new Map<String, Bool>();
	#end



	public static var permDisableWarning:Bool = false;

	public static function saveSettings()
	{
		FlxG.save.data.permDisableWarning = permDisableWarning;
	}

	public static function loadSettings()
	{
		if (FlxG.save.data.permDisableWarning != null)
			permDisableWarning = FlxG.save.data.permDisableWarning;
	}



	public static function setKey(whatkey:String, what:Bool):Void
	{
		scarlettOptionsData.set(whatkey, what);
		FlxG.save.data.scarlettOptions = scarlettOptionsData;
		FlxG.save.flush();
	}



	public static function getEpileptic():Bool
	{
		if (!scarlettOptionsData.exists('epileptic'))
			setKey('epileptic', false);

		return scarlettOptionsData.get('epileptic');
	}

	public static function toggleEpileptic():Void
	{
		setKey('epileptic', !scarlettOptionsData.get('epileptic'));
	}



	public static function getColorshift():Bool
	{
		if (!scarlettOptionsData.exists('colorshift'))
			setKey('colorshift', true);

		return scarlettOptionsData.get('colorshift');
	}

	public static function toggleColorshift():Void
	{
		setKey('colorshift', !scarlettOptionsData.get('colorshift'));
	}



	public static function getGhostTap():Bool
	{
		if (!scarlettOptionsData.exists('ghostTap'))
			setKey('ghostTap', false);

		return scarlettOptionsData.get('ghostTap');
	}

	public static function toggleGhostTap():Void
	{
		setKey('ghostTap', !scarlettOptionsData.get('ghostTap'));
	}



	public static function getRatingVisibility():Bool
	{
		if (!scarlettOptionsData.exists('ratingVisibility'))
			setKey('ratingVisibility', true);

		return scarlettOptionsData.get('ratingVisibility');
	}

	public static function toggleRatingVisibility():Void
	{
		setKey('ratingVisibility', !scarlettOptionsData.get('ratingVisibility'));
	}



	public static function getRuvMode():Bool
	{
		if (!scarlettOptionsData.exists('ruvMode'))
			setKey('ruvMode', false);

		return scarlettOptionsData.get('ruvMode');
	}

	public static function toggleRuvMode():Void
	{
		setKey('ruvMode', !scarlettOptionsData.get('ruvMode'));
	}



	public static function getWarningNotes():Bool
	{
		if (!scarlettOptionsData.exists('warningNotes'))
			setKey('warningNotes', true);

		return scarlettOptionsData.get('warningNotes');
	}

	public static function toggleWarningNotes():Void
	{
		setKey('warningNotes', !scarlettOptionsData.get('warningNotes'));
	}



	public static function getHeatwave():Bool
	{
		if (!scarlettOptionsData.exists('heatwave'))
			setKey('heatwave', true);

		return scarlettOptionsData.get('heatwave');
	}

	public static function toggleHeatwave():Void
	{
		setKey('heatwave', !scarlettOptionsData.get('heatwave'));
	}



	public static function getAmbience():Bool
	{
		if (!scarlettOptionsData.exists('ambience'))
			setKey('ambience', true);

		return scarlettOptionsData.get('ambience');
	}

	public static function toggleAmbience():Void
	{
		setKey('ambience', !scarlettOptionsData.get('ambience'));
	}


	public static function load():Void
	{
		if (FlxG.save.data.scarlettOptions != null)
		{
			scarlettOptionsData = FlxG.save.data.scarlettOptions;
		}
		loadSettings();
	}
}
