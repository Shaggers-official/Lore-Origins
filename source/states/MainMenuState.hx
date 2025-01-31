package states;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxBackdrop;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is used for Discord RPC
	public static var loreVersion:String = '2.0'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var playedIntro:Bool = false;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = [
		'lore',
		'skins',
		'achievements',
		'options',
		'credits'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Lore Menu", null);
		#end

		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;

		var xScroll:Float = Math.min(0.1 - (0.05 * (optionShit.length - 4)), 0.01);
		if (xScroll < 0) xScroll = 0;
		var bg:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('mainmenu/bg'));
		bg.scrollFactor.set(xScroll, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.7));
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		var grid:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/grid'));
		grid.scrollFactor.set(0, 0);
		grid.velocity.set(40, 40);
		grid.alpha = 0.5;
		add(grid);

		var lettabox1:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox'), X, 0, 0);
		lettabox1.scrollFactor.set(0, 0);
		lettabox1.velocity.set(40, 0);
		lettabox1.y = FlxG.height - lettabox1.height;
		add(lettabox1);

		var lettabox2:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/lettabox2'), X, 0, 0);
		lettabox2.scrollFactor.set(0, 0);
		lettabox2.velocity.set(-40, 0);
		add(lettabox2);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1.4;

		for (i in 0...optionShit.length)
		{
			var offset:Float = (i * 410) + (48 * (optionShit.length - 5) * 0.135);
			var menuItem:FlxSprite = new FlxSprite(offset + 115);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + '_idle', 8);
			menuItem.animation.addByPrefix('selected', optionShit[i] + '_s', 8);
			menuItem.animation.play('idle');
			menuItem.scrollFactor.set(1, 0);
			menuItem.updateHitbox();
			menuItem.screenCenter(Y);
			menuItem.centerOffsets();
			menuItem.ID = i;
			menuItems.add(menuItem);
		}

		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat(Paths.font('ourple.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var loreVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Lore Origins v" + loreVersion, 12);
		loreVer.scrollFactor.set();
		loreVer.setFormat(Paths.font('ourple.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(loreVer);

		changeItem();
		super.create();

		FlxG.camera.follow(camFollow, null, 9);

		if (!playedIntro) playIntro();
		if (FlxG.sound.music.pitch < 1) FlxTween.tween(FlxG.sound.music, {pitch: 1}, 1); // For Outdated State transition

		if (!FlxG.mouse.visible) FlxG.mouse.visible = true;
		add(new ExitButton('title'));
	}

	public var selectedSomethin:Bool = false;

	public var usingMouse:Bool = false;
	public var canClick:Bool = true;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}
		
		if (!selectedSomethin)
		{
			if (usingMouse)
			{
				menuItems.forEach(function(spr:FlxSprite)
				{
					if (FlxG.mouse.overlaps(spr))
					{
						if (spr.animation.curAnim.name != 'selected') {
							changeItem(spr.ID, true);
						}

						if (FlxG.mouse.pressed)
						{
							selectedSomethin = true;
							canClick = false;
							FlxG.sound.play(Paths.sound('confirmMenu'));
							processItems();
						}
					} 
					else if (spr.animation.curAnim.name != 'idle' && !menuItems.any(function(spr:FlxSprite) {return spr.animation.curAnim.name == 'selected';}))
					{
						spr.animation.play('idle');
						spr.updateHitbox();
					}
				});
			} else {
				if (controls.UI_LEFT_P)
					changeItem(-1);
	
				if (controls.UI_RIGHT_P)
					changeItem(1);
			}

			if (controls.BACK_P)
			{
				selectedSomethin = true;
				exitState(new TitleState());
			}

			if (controls.ACCEPT_P)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				processItems();
			}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				/*selectedSomethin = true;
				exitState(new MasterEditorMenu(true));*/
				FlxG.sound.play(Paths.sound('cancelMenu')); //You ain't getting access to this, bozo.
			}
			#end
		}

		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 7.5));
		super.update(elapsed);

		if (FlxG.mouse.deltaScreenX > 2 || FlxG.mouse.deltaScreenY > 2) FlxG.mouse.visible = true;
		
		if (controls.UI_LEFT || controls.UI_RIGHT) {
			usingMouse = false;
			FlxG.mouse.visible = false;
		} else {
			usingMouse = (menuItems.any(function(spr:FlxSprite) {return FlxG.mouse.overlaps(spr);}) && FlxG.mouse.visible);
		}
	}

	function changeItem(huh:Int = 0, ?goTo:Bool = false)
	{
		FlxG.camera.zoom += 0.03;

		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].animation.play('idle');
		menuItems.members[curSelected].updateHitbox();

		if (goTo)
			curSelected = huh;
		else
			curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.members[curSelected].animation.play('selected');
		menuItems.members[curSelected].centerOffsets();

		camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x - getPosOffsetMenuItems());
	}

	private function processItems():Void
	{
		FlxG.camera.zoom += 0.06;
		FlxTween.tween(FlxG.camera, {y: Lib.application.window.height}, 1.2, {ease: FlxEase.expoInOut});

		menuItems.forEach(function(spr:FlxSprite) {
			if (curSelected != spr.ID)
			{
				FlxTween.tween(spr, { alpha: 0 }, 0.4, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.kill();
					}
				});
			}
			else
			{
				if (spr.animation.curAnim.name != 'selected') spr.animation.play('selected');
				FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					var daChoice:String = optionShit[curSelected];
		
					switch (daChoice)
					{
						case 'lore':
							MusicBeatState.switchState(new states.FreeplaySelectState(true));
						case 'options':
							options.OptionsState.onPlayState = false;
							MusicBeatState.switchState(new options.OptionsState(true));
						case 'skins':
							MusicBeatState.switchState(new states.OurpleSkinSelector(true));
						case 'achievements':
							MusicBeatState.switchState(new states.AchievementsMenuState(true));
						case 'credits':
							MusicBeatState.switchState(new states.credits.CreditsSubgroupState(true));
					}
				});
			}
		});
	}

	function playIntro() 
	{
		selectedSomethin = true;
		canClick = false;
		for (i in 0...menuItems.members.length)
		{
			var posX:Float = menuItems.members[i].x;
			menuItems.members[i].x = -1000;
			FlxTween.tween(menuItems.members[i], {x: posX}, 1, {startDelay: 1, ease: FlxEase.cubeOut, onComplete: function(twn:FlxTween) {
				selectedSomethin = false;
				canClick = true;
			}});
		}
		playedIntro = true;
	}

	private function getPosOffsetMenuItems():Float {
		var midIndex = menuItems.length / 2;
		var offsetFactor = 120;
		return (curSelected - midIndex) * offsetFactor;
	}
}