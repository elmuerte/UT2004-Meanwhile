/*******************************************************************************
	Our gamerules class, this will detected when to start the meanwhile			<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id -->
*******************************************************************************/
class mwgr extends GameRules config;

/** Controller to Interaction mapping*/
struct PCIRecord
{
	var PlayerController PC;
	var mwgr2iportal I;
};
/** list with interactions and controllers, used to remove the interaction when needed */
var array<PCIRecord> PCI;

/** per gametype action configuration */
struct GameTypeAction
{
	var string Gametype;
	/**
		list with action IDs, check the code for the meaning of each ID. 		<br />
		-1:	focus a random player (fall back)
		0:	focus killer
		1:	focus top scorer (if self use killer)
		2:	flag carrier (CTF, BR)
		3:	flag base (CTF)
		4:	control points (DDOM)
		5:	power core (ONS)
		6:	objective (AS)
		7:	mutant (mutant)
		8:	bottom feeder (mutant)
	*/
	var array<int> Actions;
};
var config array<GameTypeAction> Actions;

/** class that contains our messages */
var protected MeanwhileMsg messages;

/** newline character */
var protected string NL;

event PreBeginPlay()
{
	super.PreBeginPlay();
	AddToPackageMap();
	messages = spawn(class'MeanwhileMsg');
	NL = Chr(10);
	enable('Tick');
}

/** player died, summon the meanwhile */
function ScoreKill(Controller Killer, Controller Killed)
{
	local int i;
	super.ScoreKill(Killer, Killed);
	if (PlayerController(Killed) == none) return;
	if (PlayerController(Killed).Player == none) return;

	for (i = 0; i < PCI.length; i++)
	{
		if (PCI[i].PC == PlayerController(Killed)) break;
	}
	if (i == PCI.length)
	{
		PCI.length = i+1;
		PCI[i].PC = PlayerController(Killed);
	}

	if (PCI[i].PC.PlayerReplicationInfo.bOnlySpectator) // became spectator
	{
		if (PCI[i].I != none)
		{
			PCI[i].I.ResetMW();
			PCI[i].I = none;
		}
		return;
	}

	log(Killed.PlayerReplicationInfo.PlayerName@"got killed, meanwhile...");
	if (PCI[i].I == none)
	{
		PCI[i].I = spawn(class'mwgr2iportal', PCI[i].PC);
		PCI[i].I.AddInteraction();
	}
	if (Killed == Killer) FindMeanwhile(i);
	else FindMeanwhile(i, Killer);
}

/** player respawn, remove our meanwhile */
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
	local int i;
	if (PlayerController(Player) != none)
	{
		for (i = 0; i < PCI.length; i++)
		{
			if (PCI[i].PC == PlayerController(Player))
			{
				if (PCI[i].I != none)
				{
					PCI[i].I.ResetMW();
					PCI[i].I = none;
				}
				break;
			}
		}
	}
	return Super.FindPlayerStart(Player,InTeam,incomingName);
}

event Tick(float deltatime)
{
	local int i;
	local Controller C;
	local mwgr2iportal p;

	if (!Level.Game.bGameEnded) return;
	for (i = 0; i < PCI.length; i++)
	{
		if (PCI[i].I != none)
		{
			PCI[i].I.ResetMW();
			PCI[i].I = none;
		}
	}
	for (C = Level.ControllerList; C != none; C = C.nextController)
	{
		if (PlayerController(C) == none) continue;
		p = spawn(class'mwgr2iportal', PCI[i].PC);
		p.AddInteraction();
		p.EndGame(repl(messages.EndGame, messages.delim, NL));
	}
	disable('Tick');
}

/** find the meanwhile action. idx is the index in the CI list */
function FindMeanwhile(int idx, optional Controller Killer)
{
	local GameTypeAction GTA;
	local int a;
	local Controller C, last;

	if (!GetActions(GTA)) return;
	a = GTA.Actions[rand(GTA.Actions.Length)];
	while (a >= 0)
	{
		switch (a)
		{
			case 0:	if (mwKiller(idx, a, Killer)) return; break;
			case 1:	if (mwTopScorer(idx, a, Killer)) return; break;
		}
	}
	if (a == -1) // get a random player
	{
		for (C = Level.ControllerList; C != none; C = C.nextController)
		{
			if (C == PCI[idx].PC) continue;
			if (C.Pawn == none) continue;
			last = C;
			if (frand() > 0.5) break;
		}
		if (C == none) C = last;
		if (C != none)
		{
			PCI[idx].PC.ClientSetViewTarget(C);
			PCI[idx].PC.SetViewTarget(C);
			PCI[idx].I.Meanwhile(format(messages.msgMisc[rand(messages.msgMisc.length)], idx, C));
		}
	}
	else {
		PCI[idx].I.ResetMW();
		PCI[idx].I = none;
	}
}

/** get the GameTypeAction record for the requested gametype (current by default),
	returns true if a record was found */
function bool GetActions(out GameTypeAction GTA, optional coerce string gametype)
{
	local int i;
	if (gametype == "") gametype = string(Level.Game.Class);
	for (i = 0; i < Actions.length; i++)
	{
		if (Actions[i].Gametype ~= gametype)
		{
			GTA = Actions[i];
			return true;
		}
	}
	GTA = Actions[0]; // default
	return false;
}

/** format a message string */
function string format(coerce string msg, int idx, optional Controller C)
{
	msg = messages.Meanwhile$NL$repl(msg, messages.delim, NL);
	msg = repl(msg, "%me%", PCI[idx].PC.PlayerReplicationInfo.PlayerName);
	if (C != none)
	{
		msg = repl(msg, "%other%", C.PlayerReplicationInfo.PlayerName);
		msg = repl(msg, "%oweapon%", C.Pawn.Weapon.GetHumanReadableName());
	}
	else {
		msg = repl(msg, "%other%", messages.Someone);
	}

	return msg;
}

//
// Note: all meanwhile functions should have the format:
//		bool mwFunction(int idx, out int a, optional controller Other)
// return true if this is the last call, if not "a" should be set to a new action
// value, or -1 for the fallback. If a < -1 then no further action is taken
//

function bool mwKiller(int idx, out int a, optional controller Other)
{
	if (Other != none)
	{
		PCI[idx].PC.ClientSetViewTarget(Other);
		PCI[idx].PC.SetViewTarget(Other);
		PCI[idx].I.Meanwhile(format(messages.msgKiller[rand(messages.msgKiller.length)], idx, Other));
		return true;
	}
	a = -1;
	return false;
}

function bool mwTopScorer(int idx, out int a, optional controller Other)
{
	local float score;
	local Controller C, best;
	for (C = Level.ControllerList; C != none; C = C.nextController)
	{
		if (C.PlayerReplicationInfo.Score > score)
		{
			score = C.PlayerReplicationInfo.Score;
			best = C;
		}
	}
	if ((best != none) && (best != PCI[idx].PC))
	{
		PCI[idx].PC.ClientSetViewTarget(best);
		PCI[idx].PC.SetViewTarget(best);
		PCI[idx].I.Meanwhile(format(messages.msgBest[rand(messages.msgBest.length)], idx, best));
		return true;
	}
	a = 0;
	return false;
}

defaultproperties
{
	Actions[0]=(gametype="XGame.xDeathmatch",Actions=(-1,0,1))
	Actions[1]=(gametype="XGame.xTeamGame",Actions=(-1,0,1))
	Actions[2]=(gametype="XGame.xCTFGame",Actions=(-1,0,1,2,3))
	Actions[3]=(gametype="XGame.xBombingRun",Actions=(-1,0,1,2))
	Actions[4]=(gametype="XGame.xDoubleDom",Actions=(-1,0,1,4))
	Actions[5]=(gametype="ut2k4Assault.ASGameInfo",Actions=(-1,0,1,6))
	Actions[6]=(gametype="Onslaught.ONSOnslaughtGame",Actions=(-1,0,1,5))
	Actions[7]=(gametype="SkaarjPack.Invasion",Actions=(-1,0,1))
	Actions[8]=(gametype="bonuspack.xMutantGame",Actions=(-1,0,1,7,8))
	Actions[9]=(gametype="bonuspack.xLastManStandingGame",Actions=(-1,0,1,1))
}
