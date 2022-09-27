function loadAnimations()
{
	/* ===== ANIMATION PREFIXES ===== */

	addByPrefix('idle', 'Tankman Idle Dance', 24, false);

	//
	addByPrefix('singLEFT', 'Tankman Right Note 1', 24, false);
	addByPrefix('singDOWN', 'Tankman DOWN note 1', 24, false);
	addByPrefix('singUP', 'Tankman UP note 1', 24, false);
	addByPrefix('singRIGHT', 'Tankman Note Left 1', 24, false);

	//
	addByPrefix('singUPmiss', 'Tankman UP note MISS 1', 24, false);
	addByPrefix('singRIGHTmiss', 'Tankman Note Left MISS 1', 24, false);
	addByPrefix('singLEFTmiss', 'Tankman Right Note MISS 1', 24, false);
	addByPrefix('singDOWNmiss', 'Tankman DOWN note MISS 1', 24, false);

	//
	addByPrefix('singUP-alt', 'TANKMAN UGH', 24, false);
	addByPrefix('singDOWN-alt', 'PRETTY GOOD tankman', 24, false);

	/* ===== OFFSETS ===== */

	addOffset("idle", 0, -100);

	//
	addOffset("singLEFT", 70, -114);
	addOffset("singDOWN", 58, -200);
	addOffset("singUP", 44, -42);
	addOffset("singRIGHT", -21, -127);

	//
	addOffset("singLEFTmiss", 70, -114);
	addOffset("singDOWNmiss", 58, -200);
	addOffset("singUPmiss", 44, -42);
	addOffset("singRIGHTmiss", -21, -127);

	//
	addOffset("singUP-alt", -16, -106); // ugh
	addOffset("singDOWN-alt", -2, -84); // pretty good

	playAnim('idle');

	/* ===== MISC CONFIGURATIONS ===== */

	set('flipX', true);
	set('antialiasing', true);
	setBarColor([255, 255, 255]);
	setCamOffsets(0, 150);
	setOffsets(0, 490);
}