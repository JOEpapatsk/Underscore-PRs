function loadAnimations()
{
	addByPrefix('idle', 'BF IDLE', 24, false);
	addByPrefix('singUP', 'BF UP NOTE', 24, false);
	addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
	addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
	addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
	addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
	addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);
	addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
	addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);

	addOffset('idle', 0, 50);
	addOffset('singUP', 0, 50);
	addOffset('singDOWN', 0, 50);
	addOffset('singLEFT', 0, 50);
	addOffset('singRIGHT', 0, 50);
	addOffset('singUPmiss', 0, 50);
	addOffset('singDOWNmiss', 0, 50);
	addOffset('singLEFTmiss', 0, 50);
	addOffset('singRIGHTmiss', 0, 50);

	playAnim('idle');

	setGraphicSize(get('width') * 6);
	set('antialiasing', false);

	setBarColor([123, 214, 246]);

	if (curStage == 'stage')
	{
		setOffsets(0, 910);
		setCamOffsets(-30, -150);
	}

	if (curStage == 'school' || curStage == 'schoolEvil')
		setOffsets(15, 400);

	if (curStage == 'school')
		setCamOffsets(50, -100);

	if (curStage == 'schoolEvil')
		setCamOffsets(200, -100);

	if (isPlayer)
	{
		setDeathChar('bf-pixel-dead', 'fnf_loss_sfx-pixel', 'gameOver-pixel', 'gameOverEnd-pixel');
		set('flipX', false);
	}
	else
	{
		set('flipX', true);
		flipLeftRight();

		if (curStage == 'school')
		{
			setOffsets(-135, 400);
			setCamOffsets(-80, -200);
		}

		if (curStage == 'schoolEvil')
		{
			setOffsets(150, 900);
			setCamOffsets(0, -230);
		}
	}
}