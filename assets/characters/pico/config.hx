function loadAnimations()
{
	addByPrefix('idle', "Pico Idle Dance", 24, false);
	addByPrefix('singUP', 'pico Up note0', 24, false);
	addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
	addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
	addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);

	addOffset('idle', 0, -303);
	addOffset('singUP', -29, -276);
	addOffset('singRIGHT', -68, -310);
	addOffset('singLEFT', 65, -293);
	addOffset('singDOWN', 200, -373);
	addOffset('singUPmiss', -19, -236);
	addOffset('singRIGHTmiss', -60, -262);
	addOffset('singLEFTmiss', 62, -239);
	addOffset('singDOWNmiss', 210, -331);

	playAnim('idle');

	set('flipX', true);
	set('antialiasing', true);
	setBarColor([183, 216, 85]);
	setCamOffsets(30, 300);
	setOffsets(0, 410);
}