package;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

#if (haxe >= "4.0.0")
enum abstract Action(String) to String from String
{
	var UP = "up";
	var LEFT = "left";
	var RIGHT = "right";
	var DOWN = "down";
	var UPB = "upb";
	var LEFTB = "leftb";
	var RIGHTB = "rightb";
	var DOWNB = "downb";
	var KLEFT = "kleft";
	var KRIGHT = "kright";
	var SPACE = "space";

	var UP_P = "up-press";
	var LEFT_P = "left-press";
	var RIGHT_P = "right-press";
	var DOWN_P = "down-press";
	var UPB_P = "upb-press";
	var LEFTB_P = "leftb-press";
	var RIGHTB_P = "rightb-press";
	var DOWNB_P = "downb-press";
	var KLEFT_P = "kleft-press";
	var KRIGHT_P = "kright-press";
	var SPACE_P = "space-press";

	var UP_R = "up-release";
	var LEFT_R = "left-release";
	var RIGHT_R = "right-release";
	var DOWN_R = "down-release";
	var UPB_R = "upb-release";
	var LEFTB_R = "leftb-release";
	var RIGHTB_R = "rightb-release";
	var DOWNB_R = "downb-release";
	var KLEFT_R = "kleft-release";
	var KRIGHT_R = "kright-release";
	var SPACE_R = "space-release";

		// ----------

	var ACCEPT = "accept";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
	var CHEAT = "cheat";
}
#else
@:enum
abstract Action(String) to String from String
{
	var UP = "up";
	var LEFT = "left";
	var RIGHT = "right";
	var DOWN = "down";
	var UPB = "upb";
	var LEFTB = "leftb";
	var RIGHTB = "rightb";
	var DOWNB = "downb";
	var KLEFT = "kleft";
	var KRIGHT = "kright";
	var SPACE = "space";

	var UP_P = "up-press";
	var LEFT_P = "left-press";
	var RIGHT_P = "right-press";
	var DOWN_P = "down-press";
	var UPB_P = "upb-press";
	var LEFTB_P = "leftb-press";
	var RIGHTB_P = "rightb-press";
	var DOWNB_P = "downb-press";
	var KLEFT_P = "kleft-press";
	var KRIGHT_P = "kright-press";
	var SPACE_P = "space-press";

	var UP_R = "up-release";
	var LEFT_R = "left-release";
	var RIGHT_R = "right-release";
	var DOWN_R = "down-release";
	var UPB_R = "upb-release";
	var LEFTB_R = "leftb-release";
	var RIGHTB_R = "rightb-release";
	var DOWNB_R = "downb-release";
	var KLEFT_R = "kleft-release";
	var KRIGHT_R = "kright-release";
	var SPACE_R = "space-release";

		// ----------

	var ACCEPT = "accept";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
	var CHEAT = "cheat";
}
#end

enum Device
{
	Keys;
	Gamepad(id:Int);
}

/**
 * Since, in many cases multiple actions should use similar keys, we don't want the
 * rebinding UI to list every action. ActionBinders are what the user percieves as
 * an input so, for instance, they can't set jump-press and jump-release to different keys.
 */
enum Control
{
	UP;
	LEFT;
	RIGHT;
	DOWN;
	UPB;
	LEFTB;
	RIGHTB;
	DOWNB;
	KLEFT;
	KRIGHT;
	SPACE;

	RESET;
	ACCEPT;
	BACK;
	PAUSE;
	CHEAT;
}

enum KeyboardScheme
{
	Solo;
	Duo(first:Bool);
	None;
	Custom;
}

/**
 * A list of actions that a player would invoke via some input device.
 * Uses FlxActions to funnel various inputs to a single action.
 */
class Controls extends FlxActionSet
{
	var _up = new FlxActionDigital(Action.UP);
	var _left = new FlxActionDigital(Action.LEFT);
	var _right = new FlxActionDigital(Action.RIGHT);
	var _down = new FlxActionDigital(Action.DOWN);
	//==========================================
	var _upb = new FlxActionDigital(Action.UPB);
	var _leftb = new FlxActionDigital(Action.LEFTB);
	var _rightb = new FlxActionDigital(Action.RIGHTB);
	var _downb = new FlxActionDigital(Action.DOWNB);
	var _kleft = new FlxActionDigital(Action.KLEFT);
	var _kright = new FlxActionDigital(Action.KRIGHT);
	var _space = new FlxActionDigital(Action.SPACE);

	var _upP = new FlxActionDigital(Action.UP_P);
	var _leftP = new FlxActionDigital(Action.LEFT_P);
	var _rightP = new FlxActionDigital(Action.RIGHT_P);
	var _downP = new FlxActionDigital(Action.DOWN_P);
	//==========================================
	var _upbP = new FlxActionDigital(Action.UPB_P);
	var _leftbP = new FlxActionDigital(Action.LEFTB_P);
	var _rightbP = new FlxActionDigital(Action.RIGHTB_P);
	var _downbP = new FlxActionDigital(Action.DOWNB_P);
	var _kleftP = new FlxActionDigital(Action.KLEFT_P);
	var _krightP = new FlxActionDigital(Action.KRIGHT_P);
	var _spaceP = new FlxActionDigital(Action.SPACE_P);

	var _upR = new FlxActionDigital(Action.UP_R);
	var _leftR = new FlxActionDigital(Action.LEFT_R);
	var _rightR = new FlxActionDigital(Action.RIGHT_R);
	var _downR = new FlxActionDigital(Action.DOWN_R);
	//==========================================
	var _upbR = new FlxActionDigital(Action.UPB_R);
	var _leftbR = new FlxActionDigital(Action.LEFTB_R);
	var _rightbR = new FlxActionDigital(Action.RIGHTB_R);
	var _downbR = new FlxActionDigital(Action.DOWNB_R);
	var _kleftR = new FlxActionDigital(Action.KLEFT_R);
	var _krightR = new FlxActionDigital(Action.KRIGHT_R);
	var _spaceR = new FlxActionDigital(Action.SPACE_R);

		// ----------

	var _accept = new FlxActionDigital(Action.ACCEPT);
	var _back = new FlxActionDigital(Action.BACK);
	var _pause = new FlxActionDigital(Action.PAUSE);
	var _reset = new FlxActionDigital(Action.RESET);
	var _cheat = new FlxActionDigital(Action.CHEAT);

	#if (haxe >= "4.0.0")
	var byName:Map<String, FlxActionDigital> = [];
	#else
	var byName:Map<String, FlxActionDigital> = new Map<String, FlxActionDigital>();
	#end

	public var gamepadsAdded:Array<Int> = [];
	public var keyboardScheme = KeyboardScheme.None;

	public var UP(get, never):Bool;

	inline function get_UP()
		return _up.check();

	public var LEFT(get, never):Bool;

	inline function get_LEFT()
		return _left.check();

	public var RIGHT(get, never):Bool;

	inline function get_RIGHT()
		return _right.check();

	public var DOWN(get, never):Bool;

	inline function get_DOWN()
		return _down.check();
	// ========================
	public var UPB(get, never):Bool;
	inline function get_UPB()
		return _upb.check();

	public var LEFTB(get, never):Bool;
	inline function get_LEFTB()
		return _leftb.check();

	public var RIGHTB(get, never):Bool;
	inline function get_RIGHTB()
		return _rightb.check();

	public var DOWNB(get, never):Bool;
	inline function get_DOWNB()
		return _downb.check();

	public var KLEFT(get, never):Bool;

	inline function get_KLEFT()
		return _kleft.check();

	public var KRIGHT(get, never):Bool;

	inline function get_KRIGHT()
		return _kright.check();

	public var SPACE(get, never):Bool;

	inline function get_SPACE()
		return _space.check();

		// ----------

	public var UP_P(get, never):Bool;

	inline function get_UP_P()
		return _upP.check();

	public var LEFT_P(get, never):Bool;

	inline function get_LEFT_P()
		return _leftP.check();

	public var RIGHT_P(get, never):Bool;

	inline function get_RIGHT_P()
		return _rightP.check();

	public var DOWN_P(get, never):Bool;

	inline function get_DOWN_P()
		return _downP.check();
	// ========================
	public var UPB_P(get, never):Bool;
	inline function get_UPB_P()
		return _upbP.check();

	public var LEFTB_P(get, never):Bool;
	inline function get_LEFTB_P()
		return _leftbP.check();

	public var RIGHTB_P(get, never):Bool;
	inline function get_RIGHTB_P()
		return _rightbP.check();

	public var DOWNB_P(get, never):Bool;
	inline function get_DOWNB_P()
		return _downbP.check();

	public var KLEFT_P(get, never):Bool;

	inline function get_KLEFT_P()
		return _kleftP.check();

	public var KRIGHT_P(get, never):Bool;

	inline function get_KRIGHT_P()
		return _krightP.check();

	public var SPACE_P(get, never):Bool;

	inline function get_SPACE_P()
		return _spaceP.check();

		// ----------

	public var UP_R(get, never):Bool;

	inline function get_UP_R()
		return _upR.check();

	public var LEFT_R(get, never):Bool;

	inline function get_LEFT_R()
		return _leftR.check();

	public var RIGHT_R(get, never):Bool;

	inline function get_RIGHT_R()
		return _rightR.check();

	public var DOWN_R(get, never):Bool;

	inline function get_DOWN_R()
		return _downR.check();
	// ========================
	public var UPB_R(get, never):Bool;
	inline function get_UPB_R()
		return _upbR.check();

	public var LEFTB_R(get, never):Bool;
	inline function get_LEFTB_R()
		return _leftbR.check();

	public var RIGHTB_R(get, never):Bool;
	inline function get_RIGHTB_R()
		return _rightbR.check();

	public var DOWNB_R(get, never):Bool;
	inline function get_DOWNB_R()
		return _downbR.check();

	public var KLEFT_R(get, never):Bool;

	inline function get_KLEFT_R()
		return _kleftR.check();

	public var KRIGHT_R(get, never):Bool;

	inline function get_KRIGHT_R()
		return _krightR.check();

	public var SPACE_R(get, never):Bool;

	inline function get_SPACE_R()
		return _spaceR.check();

		// ----------

	public var ACCEPT(get, never):Bool;

	inline function get_ACCEPT()
		return _accept.check();

	public var BACK(get, never):Bool;

	inline function get_BACK()
		return _back.check();

	public var PAUSE(get, never):Bool;

	inline function get_PAUSE()
		return _pause.check();

	public var RESET(get, never):Bool;

	inline function get_RESET()
		return _reset.check();

	public var CHEAT(get, never):Bool;

	inline function get_CHEAT()
		return _cheat.check();

	#if (haxe >= "4.0.0")
	public function new(name, scheme = None)
	{
		super(name);

		add(_up);
		add(_left);
		add(_right);
		add(_down);
		add(_upb);
		add(_leftb);
		add(_rightb);
		add(_downb);
		add(_kleft);
		add(_kright);
		add(_space);

		add(_upP);
		add(_leftP);
		add(_rightP);
		add(_downP);
		add(_upbP);
		add(_leftbP);
		add(_rightbP);
		add(_downbP);
		add(_kleftP);
		add(_krightP);
		add(_spaceP);

		add(_upR);
		add(_leftR);
		add(_rightR);
		add(_downR);
		add(_upbR);
		add(_leftbR);
		add(_rightbR);
		add(_downbR);
		add(_kleftR);
		add(_krightR);
		add(_spaceR);

		// ----------

		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_cheat);

		for (action in digitalActions)
			byName[action.name] = action;

		setKeyboardScheme(scheme, false);
	}
	#else
	public function new(name, scheme:KeyboardScheme = null)
	{
		super(name);

		add(_up);
		add(_left);
		add(_right);
		add(_down);
		add(_upb);
		add(_leftb);
		add(_rightb);
		add(_downb);
		add(_kleft);
		add(_kright);
		add(_space);

		add(_upP);
		add(_leftP);
		add(_rightP);
		add(_downP);
		add(_upbP);
		add(_leftbP);
		add(_rightbP);
		add(_downbP);
		add(_kleftP);
		add(_krightP);
		add(_spaceP);

		add(_upR);
		add(_leftR);
		add(_rightR);
		add(_downR);
		add(_upbR);
		add(_leftbR);
		add(_rightbR);
		add(_downbR);
		add(_kleftR);
		add(_krightR);
		add(_spaceR);

		// ----------

		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_cheat);

		for (action in digitalActions)
			byName[action.name] = action;
			
		if (scheme == null)
			scheme = None;
		setKeyboardScheme(scheme, false);
	}
	#end

	override function update()
	{
		super.update();
	}

	// inline
	public function checkByName(name:Action):Bool
	{
		#if debug
		if (!byName.exists(name))
			throw 'Invalid name: $name';
		#end
		return byName[name].check();
	}

	public function getDialogueName(action:FlxActionDigital):String
	{
		var input = action.inputs[0];
		return switch input.device
		{
			case KEYBOARD: return '[${(input.inputID : FlxKey)}]';
			case GAMEPAD: return '(${(input.inputID : FlxGamepadInputID)})';
			case device: throw 'unhandled device: $device';
		}
	}

	public function getDialogueNameFromToken(token:String):String
	{
		return getDialogueName(getActionFromControl(Control.createByName(token.toUpperCase())));
	}

	function getActionFromControl(control:Control):FlxActionDigital
	{
		return switch (control)
		{
			case UP: _up;
			case DOWN: _down;
			case LEFT: _left;
			case RIGHT: _right;
			case UPB: _upb;
			case DOWNB: _downb;
			case LEFTB: _leftb;
			case RIGHTB: _rightb;
			case SPACE: _space;
			case KLEFT: _kleft;
			case KRIGHT: _kright;

			case ACCEPT: _accept;
			case BACK: _back;
			case PAUSE: _pause;
			case RESET: _reset;
			case CHEAT: _cheat;
		}
	}

	static function init():Void
	{
		var actions = new FlxActionManager();
		FlxG.inputs.add(actions);
	}

	/**
	 * Calls a function passing each action bound by the specified control
	 * @param control
	 * @param func
	 * @return ->Void)
	 */
	function forEachBound(control:Control, func:FlxActionDigital->FlxInputState->Void)
	{
		switch (control)
		{
			case UP:
				func(_up, PRESSED);
				func(_upP, JUST_PRESSED);
				func(_upR, JUST_RELEASED);
			case LEFT:
				func(_left, PRESSED);
				func(_leftP, JUST_PRESSED);
				func(_leftR, JUST_RELEASED);
			case RIGHT:
				func(_right, PRESSED);
				func(_rightP, JUST_PRESSED);
				func(_rightR, JUST_RELEASED);
			case DOWN:
				func(_down, PRESSED);
				func(_downP, JUST_PRESSED);
				func(_downR, JUST_RELEASED);
			case UPB:
				func(_upb, PRESSED);
				func(_upbP, JUST_PRESSED);
				func(_upbR, JUST_RELEASED);
			case LEFTB:
				func(_leftb, PRESSED);
				func(_leftbP, JUST_PRESSED);
				func(_leftbR, JUST_RELEASED);
			case RIGHTB:
				func(_rightb, PRESSED);
				func(_rightbP, JUST_PRESSED);
				func(_rightbR, JUST_RELEASED);
			case DOWNB:
				func(_downb, PRESSED);
				func(_downbP, JUST_PRESSED);
				func(_downbR, JUST_RELEASED);
			case KLEFT:
				func(_kleft, PRESSED);
				func(_kleftP, JUST_PRESSED);
				func(_kleftR, JUST_RELEASED);
			case KRIGHT:
				func(_kright, PRESSED);
				func(_krightP, JUST_PRESSED);
				func(_krightR, JUST_RELEASED);
			case SPACE:
				func(_space, PRESSED);
				func(_spaceP, JUST_PRESSED);
				func(_spaceR, JUST_RELEASED);

			case ACCEPT:
				func(_accept, JUST_PRESSED);
			case BACK:
				func(_back, JUST_PRESSED);
			case PAUSE:
				func(_pause, JUST_PRESSED);
			case RESET:
				func(_reset, JUST_PRESSED);
			case CHEAT:
				func(_cheat, JUST_PRESSED);
		}
	}

	public function replaceBinding(control:Control, device:Device, ?toAdd:Int, ?toRemove:Int)
	{
		if (toAdd == toRemove)
			return;

		switch (device)
		{
			case Keys:
				if (toRemove != null)
					unbindKeys(control, [toRemove]);
				if (toAdd != null)
					bindKeys(control, [toAdd]);

			case Gamepad(id):
				if (toRemove != null)
					unbindButtons(control, id, [toRemove]);
				if (toAdd != null)
					bindButtons(control, id, [toAdd]);
		}
	}

	public function copyFrom(controls:Controls, ?device:Device)
	{
		#if (haxe >= "4.0.0")
		for (name => action in controls.byName)
		{
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
					byName[name].add(cast input);
			}
		}
		#else
		for (name in controls.byName.keys())
		{
			var action = controls.byName[name];
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
				byName[name].add(cast input);
			}
		}
		#end

		switch (device)
		{
			case null:
				// add all
				#if (haxe >= "4.0.0")
				for (gamepad in controls.gamepadsAdded)
					if (!gamepadsAdded.contains(gamepad))
						gamepadsAdded.push(gamepad);
				#else
				for (gamepad in controls.gamepadsAdded)
					if (gamepadsAdded.indexOf(gamepad) == -1)
					  gamepadsAdded.push(gamepad);
				#end

				mergeKeyboardScheme(controls.keyboardScheme);

			case Gamepad(id):
				gamepadsAdded.push(id);
			case Keys:
				mergeKeyboardScheme(controls.keyboardScheme);
		}
	}

	inline public function copyTo(controls:Controls, ?device:Device)
	{
		controls.copyFrom(this, device);
	}

	function mergeKeyboardScheme(scheme:KeyboardScheme):Void
	{
		if (scheme != None)
		{
			switch (keyboardScheme)
			{
				case None:
					keyboardScheme = scheme;
				default:
					keyboardScheme = Custom;
			}
		}
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addKeys(action, keys, state));
		#else
		forEachBound(control, function(action, state) addKeys(action, keys, state));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeKeys(action, keys));
		#else
		forEachBound(control, function(action, _) removeKeys(action, keys));
		#end
	}

	inline static function addKeys(action:FlxActionDigital, keys:Array<FlxKey>, state:FlxInputState)
	{
		for (key in keys)
			action.addKey(key, state);
	}

	static function removeKeys(action:FlxActionDigital, keys:Array<FlxKey>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (input.device == KEYBOARD && keys.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function setKeyboardScheme(scheme:KeyboardScheme, reset = true)
	{
		if (reset)
			removeKeyboard();

		keyboardScheme = scheme;
		
		#if (haxe >= "4.0.0")
		switch (scheme)
		{
			case Solo:
				inline bindKeys(Control.UP, [W, FlxKey.UP]);
				inline bindKeys(Control.DOWN, [S, FlxKey.DOWN]);
				inline bindKeys(Control.LEFT, [A, FlxKey.LEFT]);
				inline bindKeys(Control.RIGHT, [D, FlxKey.RIGHT]);

				inline bindKeys(Control.UPB, [FlxKey.UP]);
				inline bindKeys(Control.DOWNB, [FlxKey.DOWN]);
				inline bindKeys(Control.LEFTB, [FlxKey.LEFT]);
				inline bindKeys(Control.RIGHTB, [FlxKey.RIGHT]);
				inline bindKeys(Control.KLEFT, [A]);
				inline bindKeys(Control.KRIGHT, [D]);
				inline bindKeys(Control.SPACE, [FlxKey.SPACE]);

				inline bindKeys(Control.ACCEPT, [Z, FlxKey.SPACE, ENTER]);
				inline bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
				inline bindKeys(Control.PAUSE, [P, ENTER, ESCAPE]);
				inline bindKeys(Control.RESET, [R]);
			case Duo(true):
				inline bindKeys(Control.UP, [W]);
				inline bindKeys(Control.DOWN, [S]);
				inline bindKeys(Control.LEFT, [A]);
				inline bindKeys(Control.RIGHT, [D]);
				inline bindKeys(Control.ACCEPT, [G, Z]);
				inline bindKeys(Control.BACK, [H, X]);
				inline bindKeys(Control.PAUSE, [ONE]);
				inline bindKeys(Control.RESET, [R]);
			case Duo(false):
				inline bindKeys(Control.UP, [FlxKey.UP]);
				inline bindKeys(Control.DOWN, [FlxKey.DOWN]);
				inline bindKeys(Control.LEFT, [FlxKey.LEFT]);
				inline bindKeys(Control.RIGHT, [FlxKey.RIGHT]);
				inline bindKeys(Control.ACCEPT, [O]);
				inline bindKeys(Control.BACK, [P]);
				inline bindKeys(Control.PAUSE, [ENTER]);
				inline bindKeys(Control.RESET, [BACKSPACE]);
			case None: // nothing
			case Custom: // nothing
		}
		#else
		switch (scheme)
		{
			case Solo:
				bindKeys(Control.UP, [W, FlxKey.UP]);
				bindKeys(Control.DOWN, [S, FlxKey.DOWN]);
				bindKeys(Control.LEFT, [A, FlxKey.LEFT]);
				bindKeys(Control.RIGHT, [D, FlxKey.RIGHT]);

				bindKeys(Control.UPB, [FlxKey.UP]);
				bindKeys(Control.DOWNB, [FlxKey.DOWN]);
				bindKeys(Control.LEFTB, [FlxKey.LEFT]);
				bindKeys(Control.RIGHTB, [FlxKey.RIGHT]);
				bindKeys(Control.KLEFT, [A]);
				bindKeys(Control.KRIGHT, [D]);
				bindKeys(Control.SPACE, [FlxKey.SPACE]);

				bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
				bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
				bindKeys(Control.PAUSE, [P, ENTER, ESCAPE]);
				bindKeys(Control.RESET, [R]);
			case Duo(true):
				bindKeys(Control.UP, [W]);
				bindKeys(Control.DOWN, [S]);
				bindKeys(Control.LEFT, [A]);
				bindKeys(Control.RIGHT, [D]);
				bindKeys(Control.ACCEPT, [G, Z]);
				bindKeys(Control.BACK, [H, X]);
				bindKeys(Control.PAUSE, [ONE]);
				bindKeys(Control.RESET, [R]);
			case Duo(false):
				bindKeys(Control.UP, [FlxKey.UP]);
				bindKeys(Control.DOWN, [FlxKey.DOWN]);
				bindKeys(Control.LEFT, [FlxKey.LEFT]);
				bindKeys(Control.RIGHT, [FlxKey.RIGHT]);
				bindKeys(Control.ACCEPT, [O]);
				bindKeys(Control.BACK, [P]);
				bindKeys(Control.PAUSE, [ENTER]);
				bindKeys(Control.RESET, [BACKSPACE]);
			case None: // nothing
			case Custom: // nothing
		}
		#end
	}

	function removeKeyboard()
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == KEYBOARD)
					action.remove(input);
			}
		}
	}

	public function addGamepad(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);
		
		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	inline function addGamepadLiteral(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);

		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	public function removeGamepad(deviceID:Int = FlxInputDeviceID.ALL):Void
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID))
					action.remove(input);
			}
		}

		gamepadsAdded.remove(deviceID);
	}

	public function addDefaultGamepad(id):Void
	{
		#if !switch
		addGamepadLiteral(id, [
			Control.ACCEPT => [A],
			Control.BACK => [B],
			Control.UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
			Control.DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
			Control.LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
			Control.RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			Control.RESET => [Y]
		]);
		#else
		addGamepadLiteral(id, [
			//Swap A and B for switch
			Control.ACCEPT => [B],
			Control.BACK => [A],
			Control.UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP, RIGHT_STICK_DIGITAL_UP],
			Control.DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN, RIGHT_STICK_DIGITAL_DOWN],
			Control.LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT, RIGHT_STICK_DIGITAL_LEFT],
			Control.RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT, RIGHT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			//Swap Y and X for switch
			Control.RESET => [Y],
			Control.CHEAT => [X]
		]);
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindButtons(control:Control, id, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addButtons(action, buttons, state, id));
		#else
		forEachBound(control, function(action, state) addButtons(action, buttons, state, id));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindButtons(control:Control, gamepadID:Int, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeButtons(action, gamepadID, buttons));
		#else
		forEachBound(control, function(action, _) removeButtons(action, gamepadID, buttons));
		#end
	}

	inline static function addButtons(action:FlxActionDigital, buttons:Array<FlxGamepadInputID>, state, id)
	{
		for (button in buttons)
			action.addGamepad(button, state, id);
	}

	static function removeButtons(action:FlxActionDigital, gamepadID:Int, buttons:Array<FlxGamepadInputID>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (isGamepad(input, gamepadID) && buttons.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function getInputsFor(control:Control, device:Device, ?list:Array<Int>):Array<Int>
	{
		if (list == null)
			list = [];

		switch (device)
		{
			case Keys:
				for (input in getActionFromControl(control).inputs)
				{
					if (input.device == KEYBOARD)
						list.push(input.inputID);
				}
			case Gamepad(id):
				for (input in getActionFromControl(control).inputs)
				{
					if (input.deviceID == id)
						list.push(input.inputID);
				}
		}
		return list;
	}

	public function removeDevice(device:Device)
	{
		switch (device)
		{
			case Keys:
				setKeyboardScheme(None);
			case Gamepad(id):
				removeGamepad(id);
		}
	}

	static function isDevice(input:FlxActionInput, device:Device)
	{
		return switch device
		{
			case Keys: input.device == KEYBOARD;
			case Gamepad(id): isGamepad(input, id);
		}
	}

	inline static function isGamepad(input:FlxActionInput, deviceID:Int)
	{
		return input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID);
	}
}
