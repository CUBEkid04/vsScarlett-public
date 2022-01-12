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

	
	public static var epileptic:Bool = false;
	public static var screenShake:Bool = true;
	public static var colorshift:Bool = true;
	public static var downscroll:Bool = false;
	public static var centerscroll:Bool = false;
	public static var ghostTap:Bool = false;
	public static var ratingVisibility:Bool = true;
	public static var noteSplash:Bool = true;
	public static var ambience:Bool = true;
	public static var ruvMode:Bool = false;

	public static var noteScrollMultiplier:Float = 1.0;

	public static function saveSettings()
	{
		FlxG.save.data.permDisableWarning = permDisableWarning;

		FlxG.save.data.epileptic = epileptic;
		FlxG.save.data.screenShake = screenShake;
		FlxG.save.data.colorshift = colorshift;
		FlxG.save.data.downscroll = downscroll;
		FlxG.save.data.centerscroll = centerscroll;
		FlxG.save.data.ghostTap = ghostTap;
		FlxG.save.data.ratingVisibility = ratingVisibility;
		FlxG.save.data.noteSplash = noteSplash;
		FlxG.save.data.ambience = ambience;
		FlxG.save.data.ruvMode = ruvMode;

		FlxG.save.data.noteScrollMultiplier = noteScrollMultiplier;
	}

	public static function loadSettings()
	{
		if (FlxG.save.data.permDisableWarning != null)
			permDisableWarning = FlxG.save.data.permDisableWarning;

		if (FlxG.save.data.epileptic != null)
			epileptic = FlxG.save.data.epileptic;

		if (FlxG.save.data.screenShake != null)
			screenShake = FlxG.save.data.screenShake;

		if (FlxG.save.data.colorshift != null)
			colorshift = FlxG.save.data.colorshift;

		if (FlxG.save.data.downscroll != null)
			downscroll = FlxG.save.data.downscroll;

		if (FlxG.save.data.centerscroll != null)
			centerscroll = FlxG.save.data.centerscroll;

		if (FlxG.save.data.ghostTap != null)
			ghostTap = FlxG.save.data.ghostTap;

		if (FlxG.save.data.ratingVisibility != null)
			ratingVisibility = FlxG.save.data.ratingVisibility;

		if (FlxG.save.data.ambience != null)
			ambience = FlxG.save.data.ambience;

		if (FlxG.save.data.noteSplash != null)
			noteSplash = FlxG.save.data.noteSplash;

		if (FlxG.save.data.ruvMode != null)
			ruvMode = FlxG.save.data.ruvMode;



		if (FlxG.save.data.noteScrollMultiplier != null)
			noteScrollMultiplier = FlxG.save.data.noteScrollMultiplier;
	}



	public static function setKey(whatkey:String, what:Bool):Void
	{
		scarlettOptionsData.set(whatkey, what);
		FlxG.save.data.scarlettOptions = scarlettOptionsData;
		FlxG.save.flush();
	}


	public static function load():Void
	{
		loadSettings();
	}
}
