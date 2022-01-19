package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

import openfl.filters.BitmapFilter;

import openfl.Lib;

using StringTools;

class PlayState extends MusicBeatState
{
	var filters:Array<BitmapFilter> = [];
	var camfilters:Array<BitmapFilter> = [];

	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new ChromaticAberration());
	public static var chromaticAberrationTwo:ShaderFilter = new ShaderFilter(new ChromaticAberration());

	public function setChrome(chromeOffset:Float):Void
	{
		chromaticAberration.shader.data.rOffset.value = [chromeOffset];
		chromaticAberration.shader.data.gOffset.value = [0.0];
		chromaticAberration.shader.data.bOffset.value = [chromeOffset * -1];
	}

	public function setChromeTwo(chromeOffset:Float):Void
	{
		chromaticAberrationTwo.shader.data.rOffset.value = [chromeOffset];
		chromaticAberrationTwo.shader.data.gOffset.value = [0.0];
		chromaticAberrationTwo.shader.data.bOffset.value = [chromeOffset * -1];
	}

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var mania:Int = 0; // OBSOLETE
	public static var keyAmmo:Array<Int> = [4, 7];

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camOverlay:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueB:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	// Scarlett
	var songStarted:Bool = true;

	// Settings
	var useDownscroll:Bool = true; // Makes the Arrows scroll downward, inverts UI Y
	var ruvMode:Bool = true; // Makes Girlfriend display her scared animation when Enraged Velvet hits a note, mainly during Russian Rundown.
	var velvetChromeAb:Bool = true; // Alongside the screenshake, display a Chromatic Abberation color separation effect.
	var screenShift:Bool = true; // Alongside the screenshake, shift the window whenever Velvet hits a note

	var hudYMultiplier = 1;
	var hudYOffset = 0;
	

	// More Variables
	public static var isBonusWeek:Bool = false;
	public static var isAltMix:Bool = false;
	public static var bonusStringID:String = " ";
	public static var altMixAlbum:String = " ";

	private var splashGroup:FlxTypedGroup<NoteSplash>;


	var usesColorShift:Bool = false;
	var colorShift_R:Int = 255;
	var colorShift_G:Int = 255;
	var colorShift_B:Int = 255;
	var colorShiftSecond_R:Int = 255;
	var colorShiftSecond_G:Int = 255;
	var colorShiftSecond_B:Int = 255;

	// Week 1
	var flashy:FlxSprite;
	var alleyScud:FlxSprite;
	var rain:FlxSprite;

	// Week 2

	var rundownWiggle:WiggleEffect = new WiggleEffect();

	// Tower portions are 76px in width each, 12 portions.
	var fragmentationSpritePortionA:FlxSprite;
	var fragmentationSpritePortionB:FlxSprite;
	var fragmentationSpritePortionC:FlxSprite;
	var fragmentationSpritePortionD:FlxSprite;
	var fragmentationSpritePortionE:FlxSprite;
	var fragmentationSpritePortionF:FlxSprite;

	var fragmentationSpritePortionG:FlxSprite;
	var fragmentationSpritePortionH:FlxSprite;
	var fragmentationSpritePortionI:FlxSprite;
	var fragmentationSpritePortionJ:FlxSprite;
	var fragmentationSpritePortionK:FlxSprite;
	var fragmentationSpritePortionL:FlxSprite;

	private var camFollowCutscene:FlxObject;

	// Distortion
	var heatwaveWarpOne:WiggleEffect = new WiggleEffect();
	var heatwaveWarpTwo:WiggleEffect = new WiggleEffect();
	var glitchDistortion:FlxGlitchEffect = new FlxGlitchEffect();
	var distortionOne:Bool = false;
	var distortionTwo:Bool = false;

	var velvetScreamTime:Int = 60;

	// warning and shooting shit i used from FNF HD lol
	var shootingBeat_RussianRundown:Array<Int> = [16,24,32,40,136,140,142]; // OBSOLETE

	var scoreScaleTween:FlxTween;
	var healthbarTween:FlxTween;
	var targetHBTweenX:Float = 0.0;
	var targetHBTweenXB:Float = 0.0;
	private var oldHealth:Float = 1;
	var maxCombo:Int = 0;
	var missCount:Int = 0;

	function PrecacheDeathFrames()
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}

		var daChar = PlayState.SONG.player1;
		switch (daChar)
		{
			case 'bf-gf':
				daBf = 'bf-gf';
			case 'bf-gf-w7':
				daBf = 'bf-gf-w7-dead';
			case 'bf-gf-christmas':
				daBf = 'bf-gf-w7-dead';
			default:
				daBf = 'bf';
		}

		if (PlayState.SONG.song == 'Russian-Rundown')
		{
			var funniChar = PlayState.SONG.player1;
			switch (funniChar)
			{
				case 'ziona':
					daBf = 'ziona-nuked-dead';
				default:
					daBf = 'bf-nuked-dead';
			}
		}

		var bfPrecache:Boyfriend = new Boyfriend(99999, 99999, daBf); // Spawn this thing WAY out of bounds
		bfPrecache.scrollFactor.set();
		add(bfPrecache);
	}

	// Fragmentation Collapse Code
	// SEGMENT WIDTH MUST BE WHOLE FOR THIS TO WORK PROPERLY
	function generateFragmentationPortions(framesX:Int = -200, framesY:Int = -200, spriteWidth:Int = 912, spriteHeight:Int = 808, spritePath:String = 'nukedPlant/nukedTowers', scrollX:Float = 0.2, scrollY:Float = 0.2):Void
	{
		CoolUtil.precacheSound('fragmentate');
		CoolUtil.precacheSound('fragmentate-long');

		fragmentationSpritePortionA = new FlxSprite(framesX, framesY).loadGraphic(Paths.image(spritePath), true, Std.int(spriteWidth / 12), spriteHeight);
		fragmentationSpritePortionA.animation.add('static', [0], 0, false);
		fragmentationSpritePortionA.animation.play('static');
		fragmentationSpritePortionA.scrollFactor.set(scrollX, scrollY);
		fragmentationSpritePortionA.antialiasing = true;
		add(fragmentationSpritePortionA);

		fragmentationSpritePortionB = new FlxSprite((framesX + Std.int(spriteWidth / 12)), framesY).loadGraphic(Paths.image(spritePath), true, Std.int(spriteWidth / 12), spriteHeight);
		fragmentationSpritePortionB.animation.add('static', [1], 0, false);
		fragmentationSpritePortionB.animation.play('static');
		fragmentationSpritePortionB.scrollFactor.set(scrollX, scrollY);
		fragmentationSpritePortionB.antialiasing = true;
		add(fragmentationSpritePortionB);

		fragmentationSpritePortionC = new FlxSprite((framesX + (Std.int(spriteWidth / 12) * 2)), framesY).loadGraphic(Paths.image(spritePath), true, Std.int(spriteWidth / 12), spriteHeight);
		fragmentationSpritePortionC.animation.add('static', [2], 0, false);
		fragmentationSpritePortionC.animation.play('static');
		fragmentationSpritePortionC.scrollFactor.set(scrollX, scrollY);
		fragmentationSpritePortionC.antialiasing = true;
		add(fragmentationSpritePortionC);

		fragmentationSpritePortionD = new FlxSprite((framesX + (Std.int(spriteWidth / 12) * 3)), framesY).loadGraphic(Paths.image(spritePath), true, Std.int(spriteWidth / 12), spriteHeight);
		fragmentationSpritePortionD.animation.add('static', [3], 0, false);
		fragmentationSpritePortionD.animation.play('static');
		fragmentationSpritePortionD.scrollFactor.set(scrollX, scrollY);
		fragmentationSpritePortionD.antialiasing = true;
		add(fragmentationSpritePortionD);

		fragmentationSpritePortionE = new FlxSprite((framesX + (Std.int(spriteWidth / 12) * 4)), framesY).loadGraphic(Paths.image(spritePath), true, Std.int(spriteWidth / 12), spriteHeight);
		fragmentationSpritePortionE.animation.add('static', [4], 0, false);
		fragmentationSpritePortionE.animation.play('static');
		fragmentationSpritePortionE.scrollFactor.set(scrollX, scrollY);
		fragmentationSpritePortionE.antialiasing = true;
		add(fragmentationSpritePortionE);

		fragmentationSpritePortionF = new FlxSprite((framesX + (Std.int(spriteWidth / 12) * 5)), framesY).loadGraphic(Paths.image(spritePath), true, Std.int(spriteWidth / 12), spriteHeight);
		fragmentationSpritePortionF.animation.add('static', [5], 0, false);
		fragmentationSpritePortionF.animation.play('static');
		fragmentationSpritePortionF.scrollFactor.set(scrollX, scrollY);
		fragmentationSpritePortionF.antialiasing = true;
		add(fragmentationSpritePortionF);

		fragmentationSpritePortionG = new FlxSprite((framesX + (Std.int(spriteWidth / 12) * 6)), framesY).loadGraphic(Paths.image(spritePath), true, Std.int(spriteWidth / 12), spriteHeight);
		fragmentationSpritePortionG.animation.add('static', [6], 0, false);
		fragmentationSpritePortionG.animation.play('static');
		fragmentationSpritePortionG.scrollFactor.set(scrollX, scrollY);
		fragmentationSpritePortionG.antialiasing = true;
		add(fragmentationSpritePortionG);

		fragmentationSpritePortionH = new FlxSprite((framesX + (Std.int(spriteWidth / 12) * 7)), framesY).loadGraphic(Paths.image(spritePath), true, Std.int(spriteWidth / 12), spriteHeight);
		fragmentationSpritePortionH.animation.add('static', [7], 0, false);
		fragmentationSpritePortionH.animation.play('static');
		fragmentationSpritePortionH.scrollFactor.set(scrollX, scrollY);
		fragmentationSpritePortionH.antialiasing = true;
		add(fragmentationSpritePortionH);

		fragmentationSpritePortionI = new FlxSprite((framesX + (Std.int(spriteWidth / 12) * 8)), framesY).loadGraphic(Paths.image(spritePath), true, Std.int(spriteWidth / 12), spriteHeight);
		fragmentationSpritePortionI.animation.add('static', [8], 0, false);
		fragmentationSpritePortionI.animation.play('static');
		fragmentationSpritePortionI.scrollFactor.set(scrollX, scrollY);
		fragmentationSpritePortionI.antialiasing = true;
		add(fragmentationSpritePortionI);

		fragmentationSpritePortionJ = new FlxSprite((framesX + (Std.int(spriteWidth / 12) * 9)), framesY).loadGraphic(Paths.image(spritePath), true, Std.int(spriteWidth / 12), spriteHeight);
		fragmentationSpritePortionJ.animation.add('static', [9], 0, false);
		fragmentationSpritePortionJ.animation.play('static');
		fragmentationSpritePortionJ.scrollFactor.set(scrollX, scrollY);
		fragmentationSpritePortionJ.antialiasing = true;
		add(fragmentationSpritePortionJ);

		fragmentationSpritePortionK = new FlxSprite((framesX + (Std.int(spriteWidth / 12) * 10)), framesY).loadGraphic(Paths.image(spritePath), true, Std.int(spriteWidth / 12), spriteHeight);
		fragmentationSpritePortionK.animation.add('static', [10], 0, false);
		fragmentationSpritePortionK.animation.play('static');
		fragmentationSpritePortionK.scrollFactor.set(scrollX, scrollY);
		fragmentationSpritePortionK.antialiasing = true;
		add(fragmentationSpritePortionK);

		fragmentationSpritePortionL = new FlxSprite((framesX + (Std.int(spriteWidth / 12) * 11)), framesY).loadGraphic(Paths.image(spritePath), true, Std.int(spriteWidth / 12), spriteHeight);
		fragmentationSpritePortionL.animation.add('static', [11], 0, false);
		fragmentationSpritePortionL.animation.play('static');
		fragmentationSpritePortionL.scrollFactor.set(scrollX, scrollY);
		fragmentationSpritePortionL.antialiasing = true;
		add(fragmentationSpritePortionL);
	}

	function removeFragmentationPortions():Void
	{
		remove(fragmentationSpritePortionA);
		remove(fragmentationSpritePortionB);
		remove(fragmentationSpritePortionC);
		remove(fragmentationSpritePortionD);
		remove(fragmentationSpritePortionE);
		remove(fragmentationSpritePortionF);
		remove(fragmentationSpritePortionG);
		remove(fragmentationSpritePortionH);
		remove(fragmentationSpritePortionI);
		remove(fragmentationSpritePortionJ);
		remove(fragmentationSpritePortionK);
		remove(fragmentationSpritePortionL);
	}

	var collapseOneShot:Bool = false;

	function fragmentateLoop(?longOneShot:Bool = false):Void
	{
		if (!collapseOneShot)
		{
			if (ScarlettOptions.ambience)
			{
				var fragmentateSoundFile:String = 'fragmentate';
				if (longOneShot)
					fragmentateSoundFile = 'fragmentate-long';

				FlxG.sound.play(Paths.sound(fragmentateSoundFile));
			}
			collapseOneShot = true;
		}

		fragmentationSpritePortionA.velocity.y += 2.5;
		fragmentationSpritePortionB.velocity.y += 1.5;
		fragmentationSpritePortionC.velocity.y += 2;
		fragmentationSpritePortionD.velocity.y += 2.5;
		fragmentationSpritePortionE.velocity.y += 1.5;
		fragmentationSpritePortionF.velocity.y += 2;
		fragmentationSpritePortionG.velocity.y += 2.5;
		fragmentationSpritePortionH.velocity.y += 1.5;
		fragmentationSpritePortionI.velocity.y += 2;
		fragmentationSpritePortionJ.velocity.y += 1.5;
		fragmentationSpritePortionK.velocity.y += 2.5;
		fragmentationSpritePortionL.velocity.y += 1.5;
	}

	function AssignColorshiftColors(isSecondary:Bool = false, contents:String) // [Format] R:G:B
	{
		trace(Assets.getText(contents).trim());

		var splitTemp:Array<String> = Assets.getText(contents).trim().split(":");

		trace(splitTemp);

		if (isSecondary)
		{
			colorShiftSecond_R = Std.parseInt(splitTemp[0]);
			colorShiftSecond_G = Std.parseInt(splitTemp[1]);
			colorShiftSecond_B = Std.parseInt(splitTemp[2]);
		}
		else
		{
			colorShift_R = Std.parseInt(splitTemp[0]);
			colorShift_G = Std.parseInt(splitTemp[1]);
			colorShift_B = Std.parseInt(splitTemp[2]);
		}
	}

	var nukedSkyCrackA:FlxSprite;
	var nukedSkyCrackB:FlxSprite;
	var nukedSkyCrackC:FlxSprite;
	var nukedSkyCrackD:FlxSprite;

	var animateBF:Bool = true;
	var animateGF:Bool = true;
	var animateDad:Bool = true;

	function StorySongTransition(songName:String)
	{
		if (songName.toLowerCase() == 'sawgrinder')
		{
			inCutscene = true;
			canPause = false;

			animateBF = false;
			animateGF = false;
			animateDad = false;

			nukedSkyCrackD = new FlxSprite(0,0).loadGraphic(Paths.image('nukedPlant/skyCrack_flareOver'));
			nukedSkyCrackD.alpha = 0;
			nukedSkyCrackD.scrollFactor.set();
			nukedSkyCrackD.blend = BlendMode.ADD;
			add(nukedSkyCrackD);
			nukedSkyCrackD.scale.set(0.5, 0.5);
			nukedSkyCrackD.updateHitbox();
			nukedSkyCrackD.visible = false;
			nukedSkyCrackD.x = 0;
			nukedSkyCrackD.y = 0;
			
			camZooming = false;

			camFollowCutscene = new FlxObject(0, 0, 1, 1);
			camFollowCutscene.setPosition(dad.getMidpoint().x + 20, dad.getMidpoint().y - 80);

			camFollowCutscene.y = dad.getMidpoint().y - 80;
			camFollowCutscene.x = dad.getMidpoint().x + 20;

			FlxG.camera.follow(camFollowCutscene, LOCKON, 0.04);
			FlxG.camera.zoom = defaultCamZoom;



			FlxTween.tween(FlxG.camera, { zoom: 1.35 }, 2, { ease: FlxEase.quadInOut });
			FlxTween.tween(camHUD, {alpha: 0}, 1.5);

			dad.playAnim('enrage', true);
			FlxG.sound.play(Paths.sound('post-skyBreak'));

			new FlxTimer().start(1.0, function(tmr:FlxTimer) {
				nukedSkyCrackA.visible = true;
				if (ScarlettOptions.screenShake)
					FlxG.camera.shake(0.01, 0.05);
			});

			new FlxTimer().start(2.05, function(tmr:FlxTimer) {
				nukedSkyCrackB.visible = true;
				nukedSkyCrackC.visible = true;
				FlxTween.tween(nukedSkyCrackC, {alpha: 1}, 0.15);
				if (ScarlettOptions.screenShake)
					FlxG.camera.shake(0.02, 0.5);
			});

			new FlxTimer().start(2.2, function(tmr:FlxTimer) {
				nukedSkyCrackD.visible = true;
				FlxTween.tween(nukedSkyCrackD, {alpha: 1}, 0.15);
			});

			new FlxTimer().start(2.35, function(tmr:FlxTimer) {
				var flasher:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
				flasher.scrollFactor.set();
				add(flasher);
				flasher.alpha = 0;
				FlxTween.tween(flasher, {alpha: 1}, 0.2);
			});

			new FlxTimer().start(8.5, function(tmr:FlxTimer) {

				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}
	}

	var doofExternal:DialogueBox;

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOverlay = new FlxCamera();
		camOverlay.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOverlay);

		FlxCamera.defaultCameras = [camGame];


		hudYMultiplier = (ScarlettOptions.downscroll) ? -1 : 1;
		hudYOffset = (ScarlettOptions.downscroll) ? 720 : 0;


		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		splashGroup = new FlxTypedGroup<NoteSplash>();
		if (ScarlettOptions.ScarlettOptions.noteSplash)
		{
			var initialSplash = new NoteSplash(100, 100, 0);
			initialSplash.alpha = 0.0;
			splashGroup.add(initialSplash);
		}

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		mania = SONG.mania;

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
			case 'paintball':
				inCutscene = true;
				dialogue = CoolUtil.coolTextFile(Paths.txt('paintball/dialogue'));
			case 'allstar':
				inCutscene = true;
				dialogue = CoolUtil.coolTextFile(Paths.txt('allstar/dialogue'));
			case 'wet-paint':
				inCutscene = true;
				dialogue = CoolUtil.coolTextFile(Paths.txt('wet-paint/dialogue'));
			case 'rendezvous':
				inCutscene = true;
				dialogue = CoolUtil.coolTextFile(Paths.txt('rendezvous/dialogue_a'));
				dialogueB = CoolUtil.coolTextFile(Paths.txt('rendezvous/dialogue_b'));
			case 'sawgrinder':
				inCutscene = true;
				dialogue = CoolUtil.coolTextFile(Paths.txt('sawgrinder/dialogue'));
			case 'russian-rundown':
				inCutscene = true;
				dialogue = CoolUtil.coolTextFile(Paths.txt('russian-rundown/dialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';

			case 'velvet-rage':
				iconRPC = 'velvet';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			if (isBonusWeek)
			{
				detailsText = "Story Mode: Bonus " + bonusStringID;
			}
			else
			{
				detailsText = "Story Mode: Week " + storyWeek;
			}
		}
		else if (isAltMix)
		{
			detailsText = "Alt-Mix: " + AltMixChooserState.altMixAlbum;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		switch (SONG.song.toLowerCase())
		{
			case 'paintball' | 'allstar' | 'wet-paint':
			{
				curStage = 'alley';

				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
				bg.scrollFactor.set(0.1, 0.1);
				bg.antialiasing = true;
				add(bg);

				if (SONG.song.toLowerCase() == 'wet-paint')
				{
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('scarlett/backdrops/alley/cloudySky'));
					bg.scrollFactor.set(0.1, 0.1);
					bg.antialiasing = true;
					add(bg);

					var alleyFarClouds:FlxSprite = new FlxSprite(-800, -100).loadGraphic(Paths.image('scarlett/backdrops/alley/cloudFar'));
					alleyFarClouds.scrollFactor.set(0.125, 0.125);
					alleyFarClouds.antialiasing = true;

					alleyScud = new FlxSprite(-600, -225).loadGraphic(Paths.image('scarlett/backdrops/alley/scud'));
					alleyScud.scrollFactor.set(0.15, 0.15);
					alleyScud.antialiasing = true;

		                  	var alleyMidClouds:FlxSprite = new FlxSprite(-800, -225).loadGraphic(Paths.image('scarlett/backdrops/alley/cloudMid'));
					alleyMidClouds.scrollFactor.set(0.15, 0.15);
					alleyMidClouds.antialiasing = true;

					var alleyCloseClouds:FlxSprite = new FlxSprite(-800, -300).loadGraphic(Paths.image('scarlett/backdrops/alley/cloudClose'));
					alleyCloseClouds.scrollFactor.set(0.175, 0.175);
					alleyCloseClouds.antialiasing = true;

					add(alleyFarClouds);
					add(alleyScud);
					add(alleyMidClouds);
					add(alleyCloseClouds);
				}

				if (SONG.song.toLowerCase() == 'allstar')
				{
					var clouds:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('scarlett/backdrops/alley/cloudsFuzzy'));
					clouds.scrollFactor.set(0.1, 0.1);
					clouds.antialiasing = true;
					add(clouds);

					var sun:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('scarlett/backdrops/alley/sunThroughClouds'));
					sun.scrollFactor.set(0.06, 0.06);
					sun.antialiasing = true;
					add(sun);
				}

				flashy = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
				flashy.scrollFactor.set();
				add(flashy);
				flashy.alpha = 0;

				var backAlley:FlxSprite = new FlxSprite(-610, -120).loadGraphic(Paths.image('scarlett/backdrops/alley/backAlley'));
				backAlley.scrollFactor.set(0.75, 0.75);
				backAlley.setGraphicSize(Std.int(backAlley.width * 0.85));
				backAlley.updateHitbox();
				backAlley.antialiasing = true;
				add(backAlley);

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				var street:FlxSprite = new FlxSprite(-640, 50).loadGraphic(Paths.image('scarlett/backdrops/alley/frontAlley'));
				street.antialiasing = true;
				add(street);
			}
			case 'rendezvous' | 'sawgrinder' | 'russian-rundown':
			{
				curStage = 'nukedPlant';

				if (SONG.song.toLowerCase() == 'sawgrinder' && isStoryMode)
				{
					CoolUtil.precacheSound('post-skyBreak');
					var precacheA:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('nukedPlant/skyCrack'));
					add(precacheA);
					var precacheB:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('nukedPlant/skyCrack_'));
					add(precacheB);
					var precacheC:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('nukedPlant/skyCrack_flares'));
					add(precacheC);
					var precacheD:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('nukedPlant/skyCrack_flareOver'));
					add(precacheD);
				}

				if (SONG.song.toLowerCase() == 'russian-rundown')
				{
					if (isAltMix)
					{
						var bg:FlxSprite = new FlxSprite(-660,-200).loadGraphic(Paths.image('nukedPlant/nukedSkyNormal'));
						bg.scrollFactor.set(0.05, 0.05);
						bg.antialiasing = true;
						add(bg);
					}
					else
					{
						var bg:FlxSprite = new FlxSprite(-1280,-200).loadGraphic(Paths.image('nukedPlant/nukedSkyHell'));
						bg.scrollFactor.set(0.05, 0.05);
						bg.antialiasing = true;
						add(bg);

						rundownWiggle.effectType = WiggleEffectType.FLAG;
						rundownWiggle.waveAmplitude = 0.07;
						rundownWiggle.waveFrequency = 4;
						rundownWiggle.waveSpeed = 0.5;

						bg.shader = rundownWiggle.shader;

						var eclipse:FlxSprite = new FlxSprite(740, -80).loadGraphic(Paths.image('nukedPlant/nukedEclipse'));
						eclipse.antialiasing = true;
						eclipse.scrollFactor.set(0.0, 0.0);
						eclipse.blend = BlendMode.ADD;
						add(eclipse);

						var clouds:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('nukedPlant/nukedSkyHellClouds'));
						clouds.antialiasing = true;
						clouds.scrollFactor.set(0.0, 0.0);
						add(clouds);
					}

					generateFragmentationPortions(-200, -200, 912, 808, 'nukedPlant/nukedTowers', 0.2, 0.2);
					// showCoolingTowerPortions();
				}
				else
				{
					var bg:FlxSprite = new FlxSprite(-660,-200).loadGraphic(Paths.image('nukedPlant/nukedSkyNormal'));
					bg.scrollFactor.set(0.05, 0.05);
					bg.antialiasing = true;
					add(bg);

					if (SONG.song.toLowerCase() == 'sawgrinder' && isStoryMode)
					{
						nukedSkyCrackA = new FlxSprite(0,0).loadGraphic(Paths.image('nukedPlant/skyCrack'));
						nukedSkyCrackA.scrollFactor.set();
						nukedSkyCrackA.blend = BlendMode.ADD;
						add(nukedSkyCrackA);
						nukedSkyCrackA.scale.set(0.5, 0.5);
						nukedSkyCrackA.updateHitbox();
						nukedSkyCrackA.visible = false;
						nukedSkyCrackA.x = 0;
						nukedSkyCrackA.y = 0;

						nukedSkyCrackB = new FlxSprite(0,0).loadGraphic(Paths.image('nukedPlant/skyCrack_'));
						nukedSkyCrackB.scrollFactor.set();
						nukedSkyCrackB.blend = BlendMode.ADD;
						add(nukedSkyCrackB);
						nukedSkyCrackB.scale.set(0.5, 0.5);
						nukedSkyCrackB.updateHitbox();
						nukedSkyCrackB.visible = false;
						nukedSkyCrackB.x = 0;
						nukedSkyCrackB.y = 0;

						nukedSkyCrackC = new FlxSprite(0,0).loadGraphic(Paths.image('nukedPlant/skyCrack_flares'));
						nukedSkyCrackC.scrollFactor.set();
						nukedSkyCrackC.alpha = 0;
						nukedSkyCrackC.blend = BlendMode.ADD;
						add(nukedSkyCrackC);
						nukedSkyCrackC.scale.set(0.5, 0.5);
						nukedSkyCrackC.updateHitbox();
						nukedSkyCrackC.visible = false;
						nukedSkyCrackC.x = 0;
						nukedSkyCrackC.y = 0;
					}

					var nukedTowers:FlxSprite = new FlxSprite(-200, -200).loadGraphic(Paths.image('nukedPlant/nukedTowers'));
					nukedTowers.scrollFactor.set(0.2, 0.2);
					nukedTowers.antialiasing = true;
					add(nukedTowers);
				}

				var nukedPipe:FlxSprite = new FlxSprite(720, -950).loadGraphic(Paths.image('nukedPlant/nukedPipe'));
				nukedPipe.scrollFactor.set(0.35, 0.35);
				nukedPipe.antialiasing = true;
				add(nukedPipe);

				var nukedBuilding:FlxSprite = new FlxSprite(370, 20).loadGraphic(Paths.image('nukedPlant/nukedBuilding'));
				nukedBuilding.scrollFactor.set(0.45, 0.45);
				nukedBuilding.antialiasing = true;
				add(nukedBuilding);

				var fg:FlxSprite = new FlxSprite(-460, -100).loadGraphic(Paths.image('nukedPlant/nukedForeground'));
				fg.antialiasing = true;
				add(fg);

				if (ScarlettOptions.colorshift)
				{
					if (SONG.song.toLowerCase() == 'russian-rundown' && !isAltMix)
					{
						usesColorShift = true;
						AssignColorshiftColors(false, Paths.txt('russian-rundown/hellSkyColors'));
						AssignColorshiftColors(true, Paths.txt('russian-rundown/hellSkyColors_'));

						nukedPipe.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
						nukedBuilding.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
						fg.color = FlxColor.fromRGB(colorShift_R, colorShift_G, colorShift_B);
						
						fragmentationSpritePortionA.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
						fragmentationSpritePortionB.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
						fragmentationSpritePortionC.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
						fragmentationSpritePortionD.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
						fragmentationSpritePortionE.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
						fragmentationSpritePortionF.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
						fragmentationSpritePortionG.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
						fragmentationSpritePortionH.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
						fragmentationSpritePortionI.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
						fragmentationSpritePortionJ.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
						fragmentationSpritePortionK.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
						fragmentationSpritePortionL.color = FlxColor.fromRGB(colorShiftSecond_R, colorShiftSecond_G, colorShiftSecond_B);
					}
				}
			}


                        case 'spookeez' | 'monster' | 'south': 
                        {
                                curStage = 'spooky';
	                          halloweenLevel = true;

		                  var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	                          halloweenBG = new FlxSprite(-200, -100);
		                  halloweenBG.frames = hallowTex;
	                          halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	                          halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	                          halloweenBG.animation.play('idle');
	                          halloweenBG.antialiasing = true;
	                          add(halloweenBG);

		                  isHalloween = true;
		          }
		          case 'pico' | 'blammed' | 'philly': 
                        {
		                  curStage = 'philly';

		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);
		                  phillyCityLights = new FlxTypedGroup<FlxSprite>();
		                  add(phillyCityLights);

		                  for (i in 0...5)
		                  {
		                          var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
		                          light.scrollFactor.set(0.3, 0.3);
		                          light.visible = false;
		                          light.setGraphicSize(Std.int(light.width * 0.85));
		                          light.updateHitbox();
		                          light.antialiasing = true;
		                          phillyCityLights.add(light);
		                  }

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

	                          phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	                          add(street);
		          }
		          case 'milf' | 'satin-panties' | 'high':
		          {
		                  curStage = 'limo';
		                  defaultCamZoom = 0.90;

		                  var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		                  skyBG.scrollFactor.set(0.1, 0.1);
		                  add(skyBG);

		                  var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		                  bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
		                  bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		                  bgLimo.animation.play('drive');
		                  bgLimo.scrollFactor.set(0.4, 0.4);
		                  add(bgLimo);

		                  grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		                  add(grpLimoDancers);

		                  for (i in 0...5)
		                  {
		                          var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		                          dancer.scrollFactor.set(0.4, 0.4);
		                          grpLimoDancers.add(dancer);
		                  }

		                  var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		                  overlayShit.alpha = 0.5;
		                  // add(overlayShit);

		                  // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		                  // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		                  // overlayShit.shader = shaderBullshit;

		                  var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

		                  limo = new FlxSprite(-120, 550);
		                  limo.frames = limoTex;
		                  limo.animation.addByPrefix('drive', "Limo stage", 24);
		                  limo.animation.play('drive');
		                  limo.antialiasing = true;

		                  fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
		                  // add(limo);
		          }
		          case 'cocoa' | 'eggnog':
		          {
	                          curStage = 'mall';

		                  defaultCamZoom = 0.80;

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  upperBoppers = new FlxSprite(-240, -90);
		                  upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		                  upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		                  upperBoppers.antialiasing = true;
		                  upperBoppers.scrollFactor.set(0.33, 0.33);
		                  upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		                  upperBoppers.updateHitbox();
		                  add(upperBoppers);

		                  var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		                  bgEscalator.antialiasing = true;
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		                  tree.antialiasing = true;
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);

		                  bottomBoppers = new FlxSprite(-300, 140);
		                  bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		                  bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		                  bottomBoppers.antialiasing = true;
	                          bottomBoppers.scrollFactor.set(0.9, 0.9);
	                          bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		                  bottomBoppers.updateHitbox();
		                  add(bottomBoppers);

		                  var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		                  fgSnow.active = false;
		                  fgSnow.antialiasing = true;
		                  add(fgSnow);

		                  santa = new FlxSprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		                  santa.antialiasing = true;
		                  add(santa);
		          }
		          case 'winter-horrorland':
		          {
		                  curStage = 'mallEvil';
		                  var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		                  evilTree.antialiasing = true;
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	                          evilSnow.antialiasing = true;
		                  add(evilSnow);
                        }
		          case 'senpai' | 'roses':
		          {
		                  curStage = 'school';

		                  // defaultCamZoom = 0.9;

		                  var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.6, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		                  treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		                  treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		                  treeLeaves.animation.play('leaves');
		                  treeLeaves.scrollFactor.set(0.85, 0.85);
		                  add(treeLeaves);

		                  var widShit = Std.int(bgSky.width * 6);

		                  bgSky.setGraphicSize(widShit);
		                  bgSchool.setGraphicSize(widShit);
		                  bgStreet.setGraphicSize(widShit);
		                  bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		                  fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		                  treeLeaves.setGraphicSize(widShit);

		                  fgTrees.updateHitbox();
		                  bgSky.updateHitbox();
		                  bgSchool.updateHitbox();
		                  bgStreet.updateHitbox();
		                  bgTrees.updateHitbox();
		                  treeLeaves.updateHitbox();

		                  bgGirls = new BackgroundGirls(-100, 190);
		                  bgGirls.scrollFactor.set(0.9, 0.9);

		                  if (SONG.song.toLowerCase() == 'roses')
	                          {
		                          bgGirls.getScared();
		                  }

		                  bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
		                  bgGirls.updateHitbox();
		                  add(bgGirls);
		          }
		          case 'thorns':
		          {
		                  curStage = 'schoolEvil';

		                  var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		                  var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		                  var posX = 400;
	                          var posY = 200;

		                  var bg:FlxSprite = new FlxSprite(posX, posY);
		                  bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		                  bg.animation.addByPrefix('idle', 'background 2', 24);
		                  bg.animation.play('idle');
		                  bg.scrollFactor.set(0.8, 0.9);
		                  bg.scale.set(6, 6);
		                  add(bg);

		                  /* 
		                           var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
		                           bg.scale.set(6, 6);
		                           // bg.setGraphicSize(Std.int(bg.width * 6));
		                           // bg.updateHitbox();
		                           add(bg);

		                           var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
		                           fg.scale.set(6, 6);
		                           // fg.setGraphicSize(Std.int(fg.width * 6));
		                           // fg.updateHitbox();
		                           add(fg);

		                           wiggleShit.effectType = WiggleEffectType.DREAMY;
		                           wiggleShit.waveAmplitude = 0.01;
		                           wiggleShit.waveFrequency = 60;
		                           wiggleShit.waveSpeed = 0.8;
		                    */

		                  // bg.shader = wiggleShit.shader;
		                  // fg.shader = wiggleShit.shader;

		                  /* 
		                            var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
		                            var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

		                            // Using scale since setGraphicSize() doesnt work???
		                            waveSprite.scale.set(6, 6);
		                            waveSpriteFG.scale.set(6, 6);
		                            waveSprite.setPosition(posX, posY);
		                            waveSpriteFG.setPosition(posX, posY);

		                            waveSprite.scrollFactor.set(0.7, 0.8);
		                            waveSpriteFG.scrollFactor.set(0.9, 0.8);

		                            // waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		                            // waveSprite.updateHitbox();
		                            // waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
		                            // waveSpriteFG.updateHitbox();

		                            add(waveSprite);
		                            add(waveSpriteFG);
		                    */
		          }
		          default:
		          {
		                  defaultCamZoom = 0.9;
		                  curStage = 'stage';
		                  var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.9, 0.9);
		                  bg.active = false;
		                  add(bg);

		                  var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		                  stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		                  stageFront.updateHitbox();
		                  stageFront.antialiasing = true;
		                  stageFront.scrollFactor.set(0.9, 0.9);
		                  stageFront.active = false;
		                  add(stageFront);

		                  var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		                  stageCurtains.updateHitbox();
		                  stageCurtains.antialiasing = true;
		                  stageCurtains.scrollFactor.set(1.3, 1.3);
		                  stageCurtains.active = false;

		                  add(stageCurtains);
		          }
              }

		if (SONG.visuals_chromatics > 0.0)
		{
			var chromosomes:Float = SONG.visuals_chromatics / 5000;
			setChromeTwo(chromosomes);
		}
		else
		{
			setChromeTwo(0);
		}

		/* if (ScarlettOptions.getHeatwave())
		{
			heatwaveWarpOne = new WiggleEffect();
			heatwaveWarpOne.effectType = WiggleEffectType.DREAMY;
			heatwaveWarpOne.waveAmplitude = .004;
			heatwaveWarpOne.waveFrequency = 50;
			heatwaveWarpOne.waveSpeed = 1.5;

			heatwaveWarpTwo = new WiggleEffect();
			heatwaveWarpTwo.effectType = WiggleEffectType.FLAG;
			heatwaveWarpTwo.waveAmplitude = 0.012;
			heatwaveWarpTwo.waveFrequency = 1;
			heatwaveWarpTwo.waveSpeed = 1;

			distortionOne = true;
			distortionTwo = true; 

			var effect = heatwaveWarpOne;
			var effectTwo = heatwaveWarpTwo;
			FlxG.camera.setFilters( [new ShaderFilter(cast effect.shader), new ShaderFilter(cast effectTwo.shader)]);
		} */


		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil' | 'glacier':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		if (SONG.girlfriend != null)
			gfVersion = SONG.girlfriend;

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		if (curStage == 'glacier')
			gf.x -= 140;

		gf.visible = !SONG.hideGirlfriend;

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'scarlett':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;



			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);
		PrecacheDeathFrames();

		switch (SONG.player1)
		{
			case 'girlfriend':
				boyfriend.y -= 200;
		}

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		if (SONG.song.toLowerCase() == 'russian-rundown')
		{
			var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
			add(evilTrail);
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		if (ScarlettOptions.colorshift && usesColorShift) // Colorshift gets primary colors
		{
			gf.color = FlxColor.fromRGB(colorShift_R, colorShift_G, colorShift_B);
			dad.color = FlxColor.fromRGB(colorShift_R, colorShift_G, colorShift_B);
			boyfriend.color = FlxColor.fromRGB(colorShift_R, colorShift_G, colorShift_B);
		}

		if (SONG.song.toLowerCase() == 'wet-paint')
		{
			rain = new FlxSprite(-160,-1600).loadGraphic(Paths.image('scarlett/backdrops/alley/rainReach'));
			rain.scrollFactor.set(0.0, 0.0);
			add(rain);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		doofExternal = new DialogueBox(false, dialogue);
		doofExternal.scrollFactor.set();
		doofExternal.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		add(splashGroup);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;


		FlxG.camera.setFilters(filters);
		FlxG.camera.filtersEnabled = true;


		healthBarBG = new FlxSprite(0, ((FlxG.height * 0.9) * hudYMultiplier) + hudYOffset).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		/*
		LEGACY HUD
		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("contb.ttf"), 16, FlxColor.WHITE, RIGHT);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);
		*/

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.x = FlxG.width;
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.x = 0;
		add(iconP2);

		scoreTxt = new FlxText(0, healthBarBG.y + 32, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("contb.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		scoreTxt.antialiasing = true;

		splashGroup.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'paintball':
					fadeIntro(doof);
				case 'allstar':
					add(doof);
				case 'wet-paint':
					wetPaintIntro(doof);
				case 'rendezvous':
					// doof.finishThing = rendezvousSceneB;
					FlxG.camera.zoom = 1.35;
					camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
					FlxG.camera.focusOn(camFollow.getPosition());
					fadeIntro(doof);
				case 'sawgrinder':
					add(doof);
				case 'russian-rundown':
					russianRundownIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		if (!shadersLoaded)
		{
			shadersLoaded = true;
			// also comment filters.push if your planning to do a disable shaders option
			filters.push(chromaticAberration);
			filters.push(chromaticAberrationTwo);
			// filters.push(ShadersHandler.radialBlur);
		}
		
		if (SONG.visuals_overlay != 'None' && SONG.visuals_overlay != null)
		{
			var texOverlay:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('overlays/' + SONG.visuals_overlay));
			texOverlay.blend = BlendMode.ADD;
			texOverlay.alpha = SONG.visuals_overlayAlpha;
			add(texOverlay);
			texOverlay.cameras = [camOverlay];
		}

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns' || SONG.song.toLowerCase() == 'allstar')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			black.alpha -= 0.05;

			if (black.alpha > 0)
			{
				tmr.reset(0.1);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function fadeIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			black.alpha -= 0.05;

			if (black.alpha > 0)
			{
				tmr.reset(0.1);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;
					add(dialogueBox);
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function wetPaintIntro(?dialogueBox:DialogueBox):Void
	{
		var doingScene:Bool = true;
		var theSceneStarted:Bool = false;

		camFollow.y = -100;
		camFollow.x = 0;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.zoom = 1.35;
		camFollow.x = 200;

		var cutsceneInitiated:Bool = false;
		var sceneTicks:Int = 0;

		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);
		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			black.alpha -= 0.05;

			if (black.alpha > 0)
			{
				tmr.reset(0.1);
			}
			else
			{
				remove(black);
			}
		});

		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			if (doingScene)
			{
				inCutscene = true;

				if (!cutsceneInitiated)
				{
					cutsceneInitiated = true;

					new FlxTimer().start(0.01, function(swagTimerOne:FlxTimer)
					{
						swagTimerOne.reset(0.01);
						sceneTicks++;

						if (sceneTicks == 1)
						{
							FlxG.sound.play(Paths.sound('cutscenes/wet-paint/wind'));
							// FlxG.sound.play(Paths.sound('cutscenes/wet-paint/suspense'));
						}

						if (sceneTicks == 140)
						{
							lightningStrikeShit();
							FlxG.sound.play(Paths.sound('cutscenes/wet-paint/lightningHit'));
						}

						if (sceneTicks == 150)
						{
							camHUD.visible = true;
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
									ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween)
									{
										doingScene = false;
										add(dialogueBox);
									}
									});
						}
					});
				}
			}
		});
	}

	
	function rendezvousSceneB():Void
	{
		camFollow.y = dad.getMidpoint().y - 100;
		camFollow.x = dad.getMidpoint().x + 80;

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			add(doofExternal);
		});
	}

	function russianRundownIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;

		FlxG.sound.play(Paths.sound('rr-intro'));

		var flasher:FlxSprite = new FlxSprite(-1280, -720).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.WHITE);
		flasher.scrollFactor.set();
		add(flasher);
		flasher.alpha = 1;
		FlxTween.tween(flasher, {alpha: 0}, 1.5);

		FlxG.camera.zoom = 0.7;

		camFollow.setPosition(dad.getMidpoint().x + 20, dad.getMidpoint().y - 80);

		camFollow.y = dad.getMidpoint().y - 80;
		camFollow.x = dad.getMidpoint().x + 20;

		camFollow.x += 220;

		FlxG.camera.focusOn(camFollow.getPosition());

		FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { ease: FlxEase.quadOut });

		animateDad = false;

		new FlxTimer().start(1.55, function(tmr:FlxTimer)
		{
			remove(flasher);
		});

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			add(dialogueBox);
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		// hudArrows = [];
		if (!ScarlettOptions.centerscroll)
			generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		if (SONG.song.toLowerCase() == 'rendezvous' && isStoryMode)
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 1.5, { ease: FlxEase.quadInOut });
		}

		if (SONG.song.toLowerCase() == 'russian-rundown' && isStoryMode)
		{
			animateDad = true;
		}

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			if (isAltMix)
			{
				FlxG.sound.playMusic(Paths.instAlt(PlayState.SONG.song, AltMixChooserState.altMixAlbum), 1, false);
			}
			else
			{
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			}
		}
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end

		songStarted = true;

		if (SONG.song.toLowerCase() == 'wet-paint')
		{
			alleyScud.velocity.x = 30;
		}
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
		{
			if (isAltMix)
			{
				vocals = new FlxSound().loadEmbedded(Paths.voicesAlt(PlayState.SONG.song, AltMixChooserState.altMixAlbum));
			}
			else
			{
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			}
		}
		else
		{
			vocals = new FlxSound();
		}

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var mn:Int = keyAmmo[mania]; //new var to determine max notes
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % mn);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] >= mn)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					sustainNote.x += (ScarlettOptions.centerscroll) ? -278 : 42;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
					else
					{
						sustainNote.strumTime -= FlxG.save.data.offset;
					}
				}

				swagNote.mustPress = gottaHitNote;

				swagNote.x += (ScarlettOptions.centerscroll) ? -278 : 42;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
					swagNote.strumTime -= FlxG.save.data.offset;
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	// var hudArrows:Array<FlxSprite>;
	// var hudArrXPos:Array<Float>;
	// var hudArrYPos:Array<Float>;
	private function generateStaticArrows(player:Int):Void
	{
		/* if (player == 1)
		{
			hudArrXPos = [];
			hudArrYPos = [];
		} */
		for (i in 0...keyAmmo[mania])
		{
			// FlxG.log.add(i);

			var babyArrow:FlxSprite = new FlxSprite(0, (strumLine.y * hudYMultiplier) + hudYOffset);
			// hudArrows.push(babyArrow);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purple', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

					var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
					var pPre:Array<String> = ['left', 'down', 'up', 'right'];
					switch (mania)
					{
						case 1:
							nSuf = ['KLEFT', 'LEFT', 'DOWN', 'SPACE', 'UP', 'RIGHT', 'KRIGHT'];
							pPre = ['kleft', 'left', 'down', 'space', 'up', 'right', 'kright'];
					}
					babyArrow.x += Note.swagWidth * i;
					babyArrow.animation.addByPrefix('static', 'arrow' + nSuf[i]);
					babyArrow.animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			
			if (ScarlettOptions.downscroll)
				babyArrow.y -= 107;

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += (ScarlettOptions.centerscroll) ? -278 : 42;
			babyArrow.x += ((FlxG.width / 2) * player);

			/* if (player == 1)
			{
				hudArrXPos.push(babyArrow.x);
				hudArrYPos.push(babyArrow.y);
				playerStrums.add(babyArrow);
			} */

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	var shadersLoaded:Bool = false;
	var ch = 2 / 1000;
	var ch2 = 0;

	public var didScreenJitter:Bool = false;

	public function screenJitter(time:Float = 0.01):Void
	{
		var jitterX:Int = FlxG.random.int(-15,15);
		var jitterY:Int = FlxG.random.int(-15,15);

		/* if (!didScreenJitter)
		{
			Lib.application.window.x += Std.int(Lib.application.window.width / 100);
		}
		else
		{
			Lib.application.window.x -= Std.int(Lib.application.window.width / 100);
		}
		didScreenJitter = !didScreenJitter; */

		Lib.application.window.x += Std.int((Lib.application.window.width / 100) * (jitterX / 10));
		Lib.application.window.y += Std.int((Lib.application.window.width / 100) * (jitterY / 10));

		new FlxTimer().start(time, function(swagTimerOne:FlxTimer)
		{
			Lib.application.window.x -= Std.int((Lib.application.window.width / 100) * (jitterX / 10));
			Lib.application.window.y -= Std.int((Lib.application.window.width / 100) * (jitterY / 10));
		});
	}

	var fragmentFragmentationSprites:Bool = false; // Enable to start fragmentation
	var fragmentateUseLongOneShot:Bool = false;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		// VFX shit
		if (distortionOne)
			heatwaveWarpOne.update(elapsed);
		if (distortionTwo)
			heatwaveWarpTwo.update(elapsed);

		if (fragmentFragmentationSprites)
			fragmentateLoop(fragmentateUseLongOneShot);

		if (curSong.toLowerCase() == 'wet-paint')
		{
			if (rain.y >= -800)
			{
				rain.y = -1600;
			}
			rain.y += 20;

			if (flashy.alpha > 0)
			{
				flashy.alpha -= 0.05;
			}
			else
			{
				flashy.alpha = 0;
			}
		}

		if (curSong.toLowerCase() == 'russian-rundown')
		{
			rundownWiggle.update(elapsed);
			velvetScreamTime += 1;
		}

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;

			case 'alley':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);
		/* playerStrums.forEach(function(spr:FlxSprite)
		{
			spr.x = hudArrXPos[spr.ID];//spr.offset.set(spr.frameWidth / 2, spr.frameHeight / 2);
			spr.y = hudArrYPos[spr.ID];
			if (spr.animation.curAnim.name == 'confirm')
			{
				var jj:Array<Float> = [0, 4];
				spr.x = hudArrXPos[spr.ID] + jj[mania];
				spr.y = hudArrYPos[spr.ID] + jj[mania];
			}
		}); */

			ch = ch2 / 5000;
			if (ch2 > 0)
			{
				ch2--;
				ch2--;
			}
			else
			{
				ch2 = 0;
			}

			setChrome(ch);
			// ShadersHandler.setRadialBlur(640+(FlxG.random.int(-100,100)),360+(FlxG.random.int(-100,100)),FlxG.random.float(0.001,0.005));
			// ShadersHandler.setRadialBlur(640+(FlxG.random.int(-10,10)),360+(FlxG.random.int(-10,10)),FlxG.random.float(0.001,0.005));

			// ShadersHandler.setChrome(0);

		// LEGACY: scoreTxt.text = "Score:" + songScore;
		scoreTxt.text = "SCORE: " + songScore + " - MISSES: " + missCount + " - HIGHEST COMBO: " + maxCombo;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		/* if (!songStarted)
		{
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		}
		else
		{
			iconP1.x = FlxMath.lerp(healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset), iconP1.x, 0.8);
			iconP2.x = FlxMath.lerp(healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset), iconP2.x, 0.8);
		} */

		if (health > 2)
			health = 2;

		/* if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0; */

		if (healthBar.percent > 80)
		{
			iconP2.animation.curAnim.curFrame = 1;
			iconP1.animation.curAnim.curFrame = 0;
		}
		else if (healthBar.percent < 20)
		{
			iconP1.animation.curAnim.curFrame = 1;
			iconP2.animation.curAnim.curFrame = 0;
		}
		else
		{
			iconP1.animation.curAnim.curFrame = 0;
			iconP2.animation.curAnim.curFrame = 0;
		}

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		// #if debug
		if (MainMenuState.isDevelopmentBuild)
		{
			if (FlxG.keys.justPressed.EIGHT)
				FlxG.switchState(new AnimationDebug(SONG.player2));
			if (FlxG.keys.justPressed.FIVE)
				FlxG.switchState(new AnimationDebug(SONG.player1));
		}
		// #end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;

					case 'velvet':
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x = dad.getMidpoint().x + 80;
					case 'velvet-rage':
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x = dad.getMidpoint().x + 80;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Massacre')
		{
			switch (curBeat)
			{
				case 8:
					gfSpeed = 2;
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET && !inCutscene)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			distortionOne = false;
			distortionTwo = false;
			FlxG.camera.setFilters([]);

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				daNote.checkMyTime = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * (daNote.warning ? 1.4 : 1) * FlxMath.roundDecimal(SONG.speed, 2)));

				if (!daNote.mustPress && ScarlettOptions.centerscroll)
				{
					daNote.active = true;
					daNote.visible = false;
				}
				else if (daNote.checkMyTime > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * (daNote.warning ? 1.4 : 1) * FlxMath.roundDecimal(SONG.speed, 2)));

				if (ScarlettOptions.downscroll)
				{
					daNote.y = ( ((strumLine.y * hudYMultiplier) + hudYOffset) - (Conductor.songPosition - daNote.strumTime) * (0.45 * (daNote.warning ? 1.4 : 1) * FlxMath.roundDecimal(SONG.speed, 2)));

					daNote.y = ((daNote.y - 720) * -1) + 513;

					if (daNote.animation.curAnim.name.endsWith("end"))
						daNote.y += 79;
				}

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.checkMyTime + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{

					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.checkMyTime, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					if (dad.curCharacter == 'velvet-rage')
					{
						velvetScreamTime = 0;

						if (!ScarlettOptions.epileptic)
						{
							if (ScarlettOptions.screenShake)
								FlxG.camera.shake(0.01, 0.25);
							if (velvetChromeAb)
							{
								ch2 = 30;
							}

							#if desktop
							if (!FlxG.fullscreen && screenShift)
							{
								if (ScarlettOptions.screenShake)
									screenJitter(0.01);
							}
							#end
						}
						else
						{
							if (ScarlettOptions.screenShake)
								FlxG.camera.shake(0.01, 0.05);
						}

						if (ScarlettOptions.ruvMode)
						{
							if (ruvMode)
							{
								gf.playAnim('scared', true);
							}
						}
					}

					if (mania == 1)
					{
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								dad.playAnim('singLEFT' + altAnim, true); //singFARLEFT
							case 1:
								dad.playAnim('singLEFT' + altAnim, true);
							case 2:
								dad.playAnim('singDOWN' + altAnim, true);
							case 3:
								dad.playAnim('singUP' + altAnim, true); //singCENTER
							case 4:
								dad.playAnim('singUP' + altAnim, true);
							case 5:
								dad.playAnim('singRIGHT' + altAnim, true);
							case 6:
								dad.playAnim('singRIGHT' + altAnim, true); //singFARRIGHT
						}
					}
					else
					{
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
						}
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.checkMyTime < -daNote.height)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						if (daNote.warning)
						{
							health -= 1;
							FlxG.sound.play(Paths.soundRandom('badnoise', 1, 3), FlxG.random.float(0.5, 0.6));
							boyfriend.playAnim('pain',true);
						}
						else
						{
							health -= 0.0475;
						}
						missCount++;
						combo = 0;
						vocals.volume = 0;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		// #if debug
		if (MainMenuState.isDevelopmentBuild)
		{
			if (FlxG.keys.justPressed.ONE)
				endSong();
		}
		// #end
	}

	var cycleSongDelay:Bool = false;
	var hasTransitionToNextSong:Bool = false;

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			if (!ScarlettOptions.ghostTap)
			{
				#if !switch
				if (isAltMix)
				{
					Highscore.saveScore(SONG.song + '-altmix-' + AltMixChooserState.altMixAlbum, songScore, storyDifficulty);
				}
				else
				{
					Highscore.saveScore(SONG.song, songScore, storyDifficulty);
				}
				#end
			}
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				if (SONG.validScore)
				{
					if (!ScarlettOptions.ghostTap)
					{
						NGio.unlockMedal(60961);
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));

					cycleSongDelay = true;
					hasTransitionToNextSong = true;
				}

				if (SONG.song.toLowerCase() == 'sawgrinder')
				{
					cycleSongDelay = true;
					hasTransitionToNextSong = true;
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				if (!cycleSongDelay)
				{
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();
					vocals.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
				else
				{
					SONG.needsVoices = false;
					FlxG.sound.music.stop();
					vocals.stop();
					vocals.volume = 0;
				}

				if (hasTransitionToNextSong)
					StorySongTransition(SONG.song);
			}
		}
		else if (isAltMix)
		{
			trace('WENT BACK TO ALT-MIX??');
			FlxG.switchState(new AltMixChooserState());
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
		}

		if (daRating == 'sick' && !daNote.isSustainNote)
		{
			// var recycledNote = splashGroup.recycle(NoteSplash);
			// recycledNote.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
			// grpNoteSplashes.add(recycledNote);

			var strum:FlxSprite = playerStrums.members[daNote.noteData];
			if(strum != null)
			{
				if (ScarlettOptions.noteSplash)
				{
					var recycledNote = splashGroup.recycle(NoteSplash);
					recycledNote.setupNoteSplash(strum.x, strum.y, daNote.noteData);
					splashGroup.add(recycledNote);
				}
			}
		}

		songScore += score;

		if (combo > maxCombo)
			maxCombo = combo;

		if(scoreScaleTween != null)
			scoreScaleTween.cancel();

		scoreTxt.scale.x = 1.05;
		scoreTxt.scale.y = 1.05;
		scoreScaleTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.25, {
			onComplete: function(twn:FlxTween) {
				scoreScaleTween = null;
			}
		});

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		if (altMixAlbum == "B-Side" && isAltMix)
			rating.loadGraphic(Paths.image("bside/" + pixelShitPart1 + daRating + pixelShitPart2));
		else
			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		if (ScarlettOptions.ratingVisibility)
		{
			add(rating);
		}

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				if (ScarlettOptions.ratingVisibility)
				{
					add(numScore);
				}

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	function spawnNoteSplashOnNote(note:Note)
	{
		if(note != null)
		{
			var strum:FlxSprite = playerStrums.members[note.noteData];
			if(strum != null)
			{
				var recycledNote = splashGroup.recycle(NoteSplash);
				recycledNote.setupNoteSplash(strum.x, strum.y, note.noteData);
				splashGroup.add(recycledNote);
			}
		}
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;
		var upb = controls.UPB;
		var rightb = controls.RIGHTB;
		var downb = controls.DOWNB;
		var leftb = controls.LEFTB;
		var space = controls.SPACE;
		var kright = controls.KRIGHT;
		var kleft = controls.KLEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var upbP = controls.UPB_P;
		var rightbP = controls.RIGHTB_P;
		var downbP = controls.DOWNB_P;
		var leftbP = controls.LEFTB_P;
		var spaceP = controls.SPACE_P;
		var krightP = controls.KRIGHT_P;
		var kleftP = controls.KLEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;
		var upbR = controls.UPB_R;
		var rightbR = controls.RIGHTB_R;
		var downbR = controls.DOWNB_R;
		var leftbR = controls.LEFTB_R;
		var spaceR = controls.SPACE_R;
		var krightR = controls.KRIGHT_R;
		var kleftR = controls.KLEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		var ankey = (upP || rightP || downP || leftP);
		if (mania == 1)
		{ 
			ankey = (kleftP || leftbP || downbP || spaceP || upbP || rightbP || krightP);
			controlArray = [kleftP, leftbP, downbP, spaceP, upbP, rightbP, krightP];
		}
		// FlxG.watch.addQuick('asdfa', upP);
		if (ankey && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote);

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									badNoteCheck();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							noteCheck(controlArray[coolNote.noteData], coolNote);
						}
					}
				}
				else // regular notes?
				{
					noteCheck(controlArray[daNote.noteData], daNote);
				}
				/* 
					if (controlArray[daNote.noteData])
						goodNoteHit(daNote);
				 */
				// trace(daNote.noteData);
				/* 
					/*
						switch (daNote.noteData)
						{
							case 0:
								if (upP || rightP || downP || leftP)
									noteCheck(leftP, daNote);
							case 1:
								if (upP || rightP || downP || leftP)
									noteCheck(downP, daNote);
							case 2:
								if (upP || rightP || downP || leftP)
									noteCheck(upP, daNote);
							case 3:
								if (upP || rightP || downP || leftP)
									noteCheck(rightP, daNote);
						}
					*/

					//this is already done in noteCheck / goodNoteHit
					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				 
			}
			else
			{
				badNoteCheck();
			}
		}

		var condition = (up || right || down || left);
		if (mania == 1)
		{
			condition = (upb || rightb || downb || leftb || kleft || kright || space);
		}

		if (condition && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					if (mania == 1)
					{
						switch (daNote.noteData)
						{
							case 0:
								if (kleft)
									goodNoteHit(daNote);
							case 1:
								if (leftb)
									goodNoteHit(daNote);
							case 2:
								if (downb)
									goodNoteHit(daNote);
							case 3:
								if (space)
									goodNoteHit(daNote);
							case 4:
								if (upb)
									goodNoteHit(daNote);
							case 5:
								if (rightb)
									goodNoteHit(daNote);
							case 6:
								if (kright)
									goodNoteHit(daNote);
						}
					}
					else
					{
						switch (daNote.noteData)
						{
							// NOTES YOU ARE HOLDING
							case 0:
								if (left)
									goodNoteHit(daNote);
							case 1:
								if (down)
									goodNoteHit(daNote);
							case 2:
								if (up)
									goodNoteHit(daNote);
							case 3:
								if (right)
									goodNoteHit(daNote);
						}
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (mania == 1)
			{
				switch (spr.ID)
				{
					case 0:
						if (kleftP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (kleftR)
							spr.animation.play('static');
					case 1:
						if (leftbP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (leftbR)
							spr.animation.play('static');
					case 2:
						if (downbP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (downbR)
							spr.animation.play('static');
					case 3:
						if (spaceP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (spaceR)
							spr.animation.play('static');
					case 4:
						if (upbP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (upbR)
							spr.animation.play('static');
					case 5:
						if (rightbP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (rightbR)
							spr.animation.play('static');
					case 6:
						if (krightP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (krightR)
							spr.animation.play('static');
				}
			}
			else
			{
				switch (spr.ID)
				{
					case 0:
						if (leftP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (leftR)
							spr.animation.play('static');
					case 1:
						if (downP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (downR)
							spr.animation.play('static');
					case 2:
						if (upP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (upR)
							spr.animation.play('static');
					case 3:
						if (rightP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (rightR)
							spr.animation.play('static');
				}
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			missCount++;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			if (mania == 1)
			{
				switch (direction)
				{
					case 0:
						boyfriend.playAnim('singLEFTmiss', true); // singFARLEFTmiss
					case 1:
						boyfriend.playAnim('singLEFTmiss', true);
					case 2:
						boyfriend.playAnim('singDOWNmiss', true);
					case 3:
						boyfriend.playAnim('singUPmiss', true); // singCENTERmiss
					case 4:
						boyfriend.playAnim('singUPmiss', true);
					case 5:
						boyfriend.playAnim('singRIGHTmiss', true);
					case 6:
						boyfriend.playAnim('singRIGHTmiss', true); // singFARRIGHTmiss
				}
			}
			else
			{
				switch (direction)
				{
					case 0:
						boyfriend.playAnim('singLEFTmiss', true);
					case 1:
						boyfriend.playAnim('singDOWNmiss', true);
					case 2:
						boyfriend.playAnim('singUPmiss', true);
					case 3:
						boyfriend.playAnim('singRIGHTmiss', true);
				}
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upbP = controls.UPB_P;
		var rightbP = controls.RIGHTB_P;
		var downbP = controls.DOWNB_P;
		var leftbP = controls.LEFTB_P;
		var spaceP = controls.SPACE_P;
		var krightP = controls.KRIGHT_P;
		var kleftP = controls.KLEFT_P;

		if (!ScarlettOptions.ghostTap)
		{
			if (mania == 1)
			{
				if (kleftP)
					noteMiss(0);
				if (leftbP)
					noteMiss(1);
				if (downbP)
					noteMiss(2);
				if (spaceP)
					noteMiss(3);
				if (upbP)
					noteMiss(4);
				if (rightbP)
					noteMiss(5);
				if (krightP)
					noteMiss(6);
			}
			else
			{
				if (leftP)
					noteMiss(0);
				if (downP)
					noteMiss(1);
				if (upP)
					noteMiss(2);
				if (rightP)
					noteMiss(3);
			}
		}
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteCheck();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
			if (mania == 1)
			{
				sDir = ['FARLEFT', 'LEFT', 'DOWN', 'CENTER', 'UP', 'RIGHT', 'FARRIGHT'];
			}

			boyfriend.playAnim('sing' + sDir[note.noteData], true);

			if (note.warning)
			{
				boyfriend.playAnim('dodge',true);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;

		phillyTrain.x = 2000;

		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		// halloweenBG.animation.play('lightning');

		if (curSong.toLowerCase() == 'wet-paint')
		{
			flashy.alpha = 1;
		}

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	function massacreHUDJitter():Void
	{
		var jitterX_A:Int = FlxG.random.int(-75,75);
		var jitterY_A:Int = FlxG.random.int(-75,75);
		var jitterX_B:Int = FlxG.random.int(-75,75);
		var jitterY_B:Int = FlxG.random.int(-75,75);

		iconP1.x += jitterX_A;
		iconP1.y += jitterY_A;
		iconP2.x += jitterX_B;
		iconP2.y += jitterY_B;

		strumLineNotes.forEach(function(spr:FlxSprite)
		{
			var jitterX_C:Int = FlxG.random.int(-75,75);
			var jitterY_C:Int = FlxG.random.int(-75,75);

			spr.x += jitterX_C;
			spr.y += jitterY_C;

			new FlxTimer().start(0.05, function(swagTimerOne:FlxTimer)
			{
				spr.x -= jitterX_C;
				spr.y -= jitterY_C;
			});
		});

		new FlxTimer().start(0.05, function(swagTimerOne:FlxTimer)
		{
			iconP1.x -= jitterX_A;
			iconP1.y -= jitterY_A;
			iconP2.x -= jitterX_B;
			iconP2.y -= jitterY_B;
		});
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ScarlettOptions.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && animateDad)
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (curSong.toLowerCase() == 'paintball' && curBeat >= 16 && curBeat < 48)
		{
			camZooming = true;
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
			// ch2 = 20;
		}


		if (curSong.toLowerCase() != 'massacre')
		{
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		
		if (curSong.toLowerCase() == 'allstar')
		{
			if (curBeat >= 96 && curBeat < 112 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (curBeat >= 124 && curBeat < 132 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (curBeat >= 148 && curBeat < 164 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.03;
				camHUD.zoom += 0.06;
			}


			if (curBeat == 280 && isStoryMode)
			{
				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				black.scrollFactor.set();
				add(black);
				black.alpha = 0;
				new FlxTimer().start(0.03, function(tmr:FlxTimer)
				{
					black.alpha += 0.05;

					if (black.alpha < 1)
					{
						tmr.reset(0.03);
					}
					else
					{
						black.alpha = 1;
					}
				});
			}
		}

		
		if (curSong.toLowerCase() == 'sawgrinder')
		{
			if (curBeat >= 128 && curBeat < 192 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (curBeat >= 280 && curBeat < 344 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		if (curSong.toLowerCase() == 'russian-rundown')
		{
			if (camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (curBeat == 324)
			{
				fragmentateUseLongOneShot = false;
				if (ScarlettOptions.screenShake)
					camHUD.shake(0.05, 0.2);
				fragmentFragmentationSprites = true;
			}
			if (curBeat >= 360)
			{
				removeFragmentationPortions();
				fragmentFragmentationSprites = false;
			}
		}

		if (curSong.toLowerCase() == 'massacre')
		{
			if (camZooming && curBeat % 4 == 0)
			{
				FlxG.camera.shake(0.03, 0.06);

				massacreHUDJitter();

				#if desktop
				if (!FlxG.fullscreen && screenShift)
				{
					screenJitter(0.025);
				}
				#end
			}
			if (camZooming)
			{
				camHUD.zoom += 0.06;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		// iconP1.x -= 5;
		// iconP2.x += 5;

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0 && animateGF)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && animateBF)
		{
			boyfriend.playAnim('idle');
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}

			case "alley":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}

			case 'glacier':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
		}

		if (curSong.toLowerCase() == 'wet-paint' && curBeat == 16)
		{
			lightningStrikeShit();
		}

		if (curSong == 'Wet-Paint' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
