function loadAnimations()
{
	addByPrefix('idle', 'BF idle dance', 24, false);
	addByPrefix('singUP', 'BF NOTE UP0', 24, false);
	addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
	addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
	addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
	addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
	addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
	addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
	addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
	addByPrefix('hey', 'BF HEY', 24, false);
	addByPrefix('scared', 'BF idle shaking', 24);

	addOffset("idle", -5, 0);
	addOffset("hey", -4, -1);
	addOffset("singRIGHT", -5, 0);
	addOffset("singDOWN", 0, 0);
	addOffset("singUP", -6, -1);
	addOffset("singLEFT", -8, 0);
	addOffset("singRIGHTmiss", -5, 0);
	addOffset("singDOWNmiss", 0, 0);
	addOffset("singUPmiss", -6, -1);
	addOffset("singLEFTmiss", -8, 0);

	playAnim('idle');

	set('antialiasing', true);

	setBarColor([49, 176, 209]);
	setCamOffsets(0, -50);
	if (isPlayer)
	{
		setOffsets(0, 430);
		set('flipX', false);
	}
	else
	{
		setOffsets(-135, 770);
		set('flipX', true);
		flipLeftRight();
	}
}