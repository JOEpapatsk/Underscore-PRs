function loadAnimations()
{
	addByPrefix('idle', 'BF idle dance w gf', 24, false);
	addByPrefix('singUP', 'BF NOTE UP0', 24, false);
	addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
	addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
	addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
	addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
	addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
	addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
	addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

	addOffset('idle', 0, 0);
	addOffset('bfCatch', 0, 0);

	addOffset("singLEFT", 11, 4);
	addOffset("singDOWN", -10, -10);
	addOffset("singUP", -42, 10);
	addOffset("singRIGHT", -41, 20);

	addOffset("singLEFTmiss", 10, 4);
	addOffset("singDOWNmiss", -10, -10);
	addOffset("singUPmiss", -32, 8);
	addOffset("singRIGHTmiss", -34, 33);

	playAnim('idle');

	set('antialiasing', true);

	setBarColor([49, 176, 209]);
	setOffsets(0, 340);
	setIcon('bf-holding-gf');
	if (isPlayer)
	{
		setDeathChar('bf-holding-gf-dead');
		set('flipX', false);
	}
	else
	{
		set('flipX', true);
		setOffsets(-90, 580);
		setCamOffsets(130, 0);
		flipLeftRight();
	}
}