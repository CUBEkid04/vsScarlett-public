package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;

#if sys
import sys.FileSystem;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var isDevelopmentBuild:Bool = false;
	public static var lambda:Bool = false;

	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'gamebanana', 'options'];

	// var optionShit:Array<String> = ['story mode', 'freeplay', 'altmix', 'gamebanana', 'options'];

	// var optionShit:Array<String> = ['story mode', 'freeplay', 'altmix', 'bonus weeks', 'gamebanana', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay', 'altmix', 'options'];
	#end

	var pivotShit:Array<Float> = [];

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	public static var loadedUp:Bool = false;
	var timeAddInto:Float = 0.0;

	var easterEggKeyCombination:Array<FlxKey> = [FlxKey.L, FlxKey.A, FlxKey.M, FlxKey.B, FlxKey.D, FlxKey.A];
	var lastKeysPressed:Array<FlxKey> = [];

	var lambdaLinks:Array<String> = ["https://store.steampowered.com/app/70/HalfLife/", "https://store.steampowered.com/app/546560/HalfLife_Alyx/", "https://store.steampowered.com/app/220/HalfLife_2/", "https://store.steampowered.com/app/380/HalfLife_2_Episode_One/", "https://store.steampowered.com/app/420/HalfLife_2_Episode_Two/"];

	override function create()
	{
		if (lambda)
			optionShit = ['story mode', 'freeplay', 'gamebanana', 'options', 'lambda'];
		if (isDevelopmentBuild)
			optionShit = ['story mode', 'freeplay', 'altmix', 'bonus weeks', 'gamebanana', 'lambda', 'options'];

		PlayState.isAltMix = false; // so B-Side Icons wont replace freeplay icons

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.04; // 0.18
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.04;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160) - 220);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0.0, 0.5);
			menuItem.antialiasing = true;

			pivotShit.push(menuItem.getGraphicMidpoint().y);

			if (!loadedUp)
			{
				menuItem.y += 800;
				FlxTween.tween(menuItem, { y: (60 + (i * 160) - 220) }, 1.0 + timeAddInto, {
					ease: FlxEase.elasticInOut
				});
				timeAddInto += 0.1;
			}
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		/* var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "v" + Application.current.meta.get('version') + " - DEVELOPMENT VERSION, EXPECT UNSTABLE STATES.", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Continuum Bold", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK); // VCR OSD Mono
		versionShit.antialiasing = true; */

		if (isDevelopmentBuild)
		{
			var versionShit:Alphabet = new Alphabet(6, 640, "v" + Application.current.meta.get('version'), true, false, 'alphabet', 0.5);
			versionShit.scrollFactor.set();
			add(versionShit);
			var versionShitB:Alphabet = new Alphabet(6, 600, "Development Build", false, false, 'alphabet', 0.4);
			versionShitB.scrollFactor.set();
			add(versionShitB);
		}
		else
		{
			var versionShit:Alphabet = new Alphabet(6, 680, "v" + Application.current.meta.get('version'), true, false, 'alphabet', 0.5);
			versionShit.scrollFactor.set();
			add(versionShit);
		}

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		loadedUp = true;

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		if (!selectedSomethin)
		{
			// Section taken from an older version of PsychEngine
			var finalKey:FlxKey = FlxG.keys.firstJustPressed();
			if(finalKey != FlxKey.NONE)
			{
				lastKeysPressed.push(finalKey);
				if(lastKeysPressed.length > easterEggKeyCombination.length)
				{
					lastKeysPressed.shift();
				}
				
				if(lastKeysPressed.length == easterEggKeyCombination.length)
				{
					var isDifferent:Bool = false;
					for (i in 0...lastKeysPressed.length)
					{
						if(lastKeysPressed[i] != easterEggKeyCombination[i])
						{
							isDifferent = true;
							break;
						}
					}

					if(!isDifferent)
					{
						trace('Lambda');
						lambda = true;
						FlxG.sound.playMusic(Paths.music('lambda'), 0);
						lastKeysPressed = [];
					}
				}
			}


			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK && !lambda)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'gamebanana')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://gamebanana.com/mods/307460", "&"]);
					#else
					FlxG.openURL('https://gamebanana.com/mods/307460');
					#end
				}
				else if (optionShit[curSelected] == 'lambda')
				{
					var theLambda:Int = Std.random(lambdaLinks.length);

					#if linux
					Sys.command('/usr/bin/xdg-open', [lambdaLinks[theLambda], "&"]);
					#else
					FlxG.openURL(lambdaLinks[theLambda]);
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							
							FlxTween.tween(spr, { x: spr.x - 100 }, 0.3, {
								ease: FlxEase.elasticOut,
								onComplete: function(twn:FlxTween)
								{
									FlxTween.tween(spr, { x: spr.x-500 }, 0.45, {
										ease: FlxEase.expoIn,
										onComplete: function(twn:FlxTween)
										{
											spr.kill();
										}
									});
								}
							});
							
						}
						else
						{
							FlxTween.tween(spr, { x: spr.x + 100 }, 0.3, {
								ease: FlxEase.elasticOut,
								onComplete: function(twn:FlxTween)
								{
									FlxTween.tween(spr, { x: spr.x-100 }, 0.45, {
										ease: FlxEase.expoIn
									});
								}
							});

							spr.color = 0xFFff7fff;

							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										FlxG.switchState(new StoryMenuState());
										trace("Story Menu Selected");
									case 'freeplay':
										FlxG.switchState(new FreeplayState());

										trace("Freeplay Menu Selected");

									case 'altmix':
										FlxG.switchState(new AltMixAlbumState());

										trace("Altmix Menu Selected");

									case 'bonus weeks':
										FlxG.switchState(new BonusWeeksState());

										trace("Bonus Weeks Menu Selected");

									case 'changelog':
										FlxG.switchState(new ChangelogsState());

										trace("Changelog Selected");

									case 'options':
										// FlxTransitionableState.skipNextTransIn = true;
										// FlxTransitionableState.skipNextTransOut = true;
										FlxG.switchState(new ScarlettOptionsState());
										trace("Option Menu Selected");
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		if (!selectedSomethin)
		{
			menuItems.forEach(function(spr:FlxSprite)
			{
				spr.screenCenter(X);
			});
		}
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, pivotShit[curSelected]);
			}

			spr.updateHitbox();
		});
	}
}
