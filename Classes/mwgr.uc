/*******************************************************************************
	Our gamerules class, this will detected when to start the meanwhile			<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id: mwgr.uc,v 1.5 2004/06/03 20:57:24 elmuerte Exp $ -->
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

/** the meanwhile message class to spawn */
var class<MeanwhileMsg> MeanwhileMsgClass;
/** meanwhile to interaction portal class */
var class<mwgr2iportal> PortalClass;

/** enable debug logging */
var config bool bDebug;

//!Localization
var localized string PIname[2], PIdesc[2];

event PreBeginPlay()
{
	super.PreBeginPlay();
	AddToPackageMap();
	messages = spawn(MeanwhileMsgClass);
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

	if (bDebug) log(Killed.PlayerReplicationInfo.PlayerName@"got killed, meanwhile...");
	if (PCI[i].I == none)
	{
		PCI[i].I = spawn(PortalClass, PCI[i].PC);
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

/** check endgame */
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
		p = spawn(PortalClass, PCI[i].PC);
		p.AddInteraction();
		p.EndGame(repl(messages.EndGame, messages.delim, NL));
	}
	disable('Tick');
}

/** find the meanwhile action. idx is the index in the CI list */
function FindMeanwhile(int idx, optional Controller Killer)
{
	local GameTypeAction GTA;
	local int a, olda, i;
	local Controller C, last;
	local array<int> opt;

	if (!GetActions(GTA)) return;
	opt = GTA.Actions;

	i = rand(opt.length);
	a = opt[i];
	while (a >= 0)
	{
		olda = a;
		switch (a)
		{
			case 0:	if (mwKiller(idx, a, Killer)) return; break;
			case 1:	if (mwTopScorer(idx, a, Killer)) return; break;
			case 2: if (mwFlagCarrier(idx, a, Killer)) return; break;
			case 3: if (mwFlagBase(idx, a)) return; break;
			case 4: if (mwControlPoints(idx, a)) return; break;
			case 5: if (mwPowerCore(idx, a)) return; break;
			case 6: if (mwObjective(idx, a)) return; break;
			case 7: if (mwMutant(idx, a)) return; break;
			case 8: if (mwBottomFeeder(idx, a)) return; break;
		}
		if (a == olda) // to prevent a run away loop
		{
			opt.Remove(i, 1); // remove old
			i = rand(opt.length); // get new
			a = opt[i];
		}
	}
	if (a == -1) // get a random player
	{
		for (C = Level.ControllerList; C != none; C = C.nextController)
		{
			if (C == PCI[idx].PC) continue;
			if (C.Pawn == none) continue;
			if (!C.bIsPlayer) continue;
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
function string format(coerce string msg, int idx, optional Actor A)
{
	local Object O;
	local Controller C;
	local xDomPoint DP;
	local GameObjective GO;

	msg = messages.Meanwhile$NL$repl(msg, messages.delim, NL);
	msg = repl(msg, "%me%", PCI[idx].PC.PlayerReplicationInfo.PlayerName);

	C = Controller(A);
	if (C != none)
	{
		msg = repl(msg, "%other%", C.PlayerReplicationInfo.PlayerName);
		if (C.Pawn != none) msg = repl(msg, "%oweapon%", C.Pawn.Weapon.GetHumanReadableName());
		else msg = repl(msg, "%oweapon%", messages.It);
		if (InStr(msg, "%hasflagmsg%") > -1)
		{
			if (CTFFlag(C.PlayerReplicationInfo.HasFlag) != none)
			{
				O = CTFFlag(C.PlayerReplicationInfo.HasFlag).Team;
			}
			msg = repl(msg, "%hasflagmsg%", C.PlayerReplicationInfo.HasFlag.MessageClass.static.GetString(4, C.PlayerReplicationInfo,, O));
		}
		if (InStr(msg, "%flag%") > -1)
		{
			if (CTFFlag(C.PlayerReplicationInfo.HasFlag) != none)
			{
				O = CTFFlag(C.PlayerReplicationInfo.HasFlag).Team;
			}
			else O = none;
			msg = repl(msg, "%flag%", messages.getFlagName(Level.Game.Class, UnrealTeamInfo(O) == PCI[idx].PC.PlayerReplicationInfo.Team));
		}
	}
	else {
		msg = repl(msg, "%other%", messages.Someone);
		msg = repl(msg, "%oweapon%", messages.It);
	}

	DP = xDomPoint(A);
	if (DP != none)
	{
		msg = repl(msg, "%cp_name%", DP.PointName);
		if (DP.ControllingPawn != none)
			msg = repl(msg, "%cp_controller%", DP.ControllingPawn.Controller.PlayerReplicationInfo.PlayerName);
	}

	GO = GameObjective(A);
	if (GO != none)
	{
		msg = repl(msg, "%objective%", GO.ObjectiveName);
		msg = repl(msg, "%objective_desc%", GO.ObjectiveDescription);
		msg = repl(msg, "%objective_infoa%", GO.Objective_Info_Attacker);
		msg = repl(msg, "%objective_infod%", GO.Objective_Info_Defender);
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
	if (bDebug) log("mwKiller", name);
	if (Other != none)
	{
		PCI[idx].PC.ClientSetViewTarget(Other);
		PCI[idx].PC.SetViewTarget(Other);
		PCI[idx].I.Meanwhile(format(messages.msgKiller[rand(messages.msgKiller.length)], idx, Other));
		return true;
	}
	return false;
}

function bool mwTopScorer(int idx, out int a, optional controller Other)
{
	local float score;
	local Controller C, best;
	if (bDebug) log("mwTopScorer", name);
	for (C = Level.ControllerList; C != none; C = C.nextController)
	{
		if (!C.bIsPlayer) continue;
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
	return false;
}

function bool mwFlagCarrier(int idx, out int a, optional controller Other)
{
	local Controller C;
	local array<Controller> carriers;
	if (bDebug) log("mwFlagCarrier", name);
	for (C = Level.ControllerList; C != none; C = C.nextController)
	{
		if (C == PCI[idx].PC) continue;
		if (C.PlayerReplicationInfo.HasFlag != none)
		{
			carriers[carriers.length] = C;
		}
	}
	if (carriers.length > 0)
	{
		C = carriers[rand(carriers.length)];
		PCI[idx].PC.ClientSetViewTarget(C);
		PCI[idx].PC.SetViewTarget(C);
		if (C.PlayerReplicationInfo.Team == PCI[idx].PC.PlayerReplicationInfo.Team)
			PCI[idx].I.Meanwhile(format(messages.msgCarrierFriendly[rand(messages.msgCarrierFriendly.length)], idx, C));
			else PCI[idx].I.Meanwhile(format(messages.msgCarrierEnemy[rand(messages.msgCarrierEnemy.length)], idx, C));
		return true;
	}
	return false;
}

function bool mwFlagBase(int idx, out int a, optional controller Other)
{
	local array<CTFBase> bases;
	local CTFBase c;
	if (bDebug) log("mwFlagBase", name);
	bases[0] = CTFBase(TeamGame(Level.Game).Teams[0].HomeBase);
	bases[1] = CTFBase(TeamGame(Level.Game).Teams[1].HomeBase);
	c = bases[rand(bases.length)];
	if (C != none)
	{
		PCI[idx].PC.ClientSetViewTarget(C);
		PCI[idx].PC.SetViewTarget(C);
		if (C.myFlag.Team == PCI[idx].PC.PlayerReplicationInfo.Team)
		{
			if (C.bHidden) PCI[idx].I.Meanwhile(format(messages.msgFFlagBaseLost[rand(messages.msgFFlagBaseLost.length)], idx));
			else PCI[idx].I.Meanwhile(format(messages.msgFFlagBaseSafe[rand(messages.msgFFlagBaseSafe.length)], idx));
		}
		else {
			if (C.bHidden) PCI[idx].I.Meanwhile(format(messages.msgEFlagBaseLost[rand(messages.msgEFlagBaseLost.length)], idx));
			else PCI[idx].I.Meanwhile(format(messages.msgEFlagBaseSafe[rand(messages.msgEFlagBaseSafe.length)], idx));
		}
		return true;
	}
	return false;
}

function bool mwControlPoints(int idx, out int a, optional controller Other)
{
	local xDomPoint c;
	if (bDebug) log("mwControlPoints", name);

	if (frand() > 0.5) c = xDoubleDom(Level.Game).xDomPoints[0];
	else c = xDoubleDom(Level.Game).xDomPoints[1];

	if (C != none)
	{
		PCI[idx].PC.ClientSetViewTarget(C);
		PCI[idx].PC.SetViewTarget(C);

		if (C.ControllingTeam == none)
		{
			PCI[idx].I.Meanwhile(format(messages.msgCPnoteam[rand(messages.msgCPnoteam.length)], idx, C));
		}
		else if (C.ControllingTeam == PCI[idx].PC.PlayerReplicationInfo.Team)
		{
			PCI[idx].I.Meanwhile(format(messages.msgCPmyteam[rand(messages.msgCPmyteam.length)], idx, C));
		}
		else {
			PCI[idx].I.Meanwhile(format(messages.msgCPenemyteam[rand(messages.msgCPenemyteam.length)], idx, C));
		}
		return true;
	}
	return false;
}

function bool mwPowerCore(int idx, out int a, optional controller Other)
{
	local array<ONSPowerCore> Clist;
	local ONSPowerCore C;
	if (bDebug) log("mwPowerCore", name);

	Clist = ONSOnslaughtGame(Level.Game).PowerCores;
	do {
		c = Clist[rand(Clist.length)];
		if ((c.Health > 0) && (c.DefenderTeamIndex < 2)) break;
		c = none;
	} until (Clist.length == 0)

 	if (C != none)
 	{
 		if (C.bFinalCore)
 		{
 			PCI[idx].PC.ClientSetViewTarget(C);
			PCI[idx].PC.SetViewTarget(C);

 			if (C.DefenderTeamIndex == PCI[idx].PC.PlayerReplicationInfo.Team.TeamIndex)
 			{
 				if (C.bUnderAttack) PCI[idx].I.Meanwhile(format(messages.msgMyFinalPCAttack[rand(messages.msgMyFinalPCAttack.length)], idx, C));
 					else PCI[idx].I.Meanwhile(format(messages.msgMyFinalPC[rand(messages.msgMyFinalPC.length)], idx, C));
 			}
 			else {
 				if (C.bUnderAttack) PCI[idx].I.Meanwhile(format(messages.msgOtherFinalPCAttack[rand(messages.msgOtherFinalPCAttack.length)], idx, C));
 					else PCI[idx].I.Meanwhile(format(messages.msgOtherFinalPC[rand(messages.msgOtherFinalPC.length)], idx, C));
 			}

 			return true;
 		}
 		else {
			if (C.DefenderTeamIndex == PCI[idx].PC.PlayerReplicationInfo.Team.TeamIndex)
 			{
 				PCI[idx].PC.ClientSetViewTarget(C);
				PCI[idx].PC.SetViewTarget(C);

 				if (C.bUnderAttack) PCI[idx].I.Meanwhile(format(messages.msgMyPCAttack[rand(messages.msgMyPCAttack.length)], idx, C));
 					else PCI[idx].I.Meanwhile(format(messages.msgMyPC[rand(messages.msgMyPC.length)], idx, C));

 				return true;
 			}
 			else {
 				PCI[idx].PC.ClientSetViewTarget(C);
				PCI[idx].PC.SetViewTarget(C);

 				if (C.bUnderAttack) PCI[idx].I.Meanwhile(format(messages.msgOtherPCAttack[rand(messages.msgOtherPCAttack.length)], idx, C));
 					else PCI[idx].I.Meanwhile(format(messages.msgOtherPC[rand(messages.msgOtherPC.length)], idx, C));

 				return true;
 			}
 		}
 	}
	return false;
}

function bool mwObjective(int idx, out int a, optional controller Other)
{
	local GameObjective O;
	if (bDebug) log("mwObjective", name);
	if (frand() > 0.5) O = ASGameInfo(Level.Game).LastDisabledObjective;
	else O = ASGameInfo(Level.Game).CurrentObjective;

	if (O != none)
	{
		PCI[idx].PC.ClientSetViewTarget(O);
		PCI[idx].PC.SetViewTarget(O);
		if (ASGameInfo(Level.Game).CurrentAttackingTeam == PCI[idx].PC.PlayerReplicationInfo.Team.TeamIndex)
		{
			if (O.bDisabled) PCI[idx].I.Meanwhile(format(messages.msgObjectiveDoneA[rand(messages.msgObjectiveDoneA.length)], idx, O));
				else PCI[idx].I.Meanwhile(format(messages.msgObjectiveTodoA[rand(messages.msgObjectiveTodoA.length)], idx, O));
		}
		else {
			if (O.bDisabled) PCI[idx].I.Meanwhile(format(messages.msgObjectiveDoneD[rand(messages.msgObjectiveDoneD.length)], idx, O));
				else PCI[idx].I.Meanwhile(format(messages.msgObjectiveTodoD[rand(messages.msgObjectiveTodoD.length)], idx, O));
		}
		return true;
	}
	return false;
}

function bool mwMutant(int idx, out int a, optional controller Other)
{
	if (bDebug) log("mwMutant", name);
	if (xMutantGame(Level.Game).CurrentMutant != none)
	{
		PCI[idx].PC.ClientSetViewTarget(xMutantGame(Level.Game).CurrentMutant);
		PCI[idx].PC.SetViewTarget(xMutantGame(Level.Game).CurrentMutant);
		PCI[idx].I.Meanwhile(format(messages.msgMutant[rand(messages.msgMutant.length)], idx, xMutantGame(Level.Game).CurrentMutant));
		return true;
	}
	return false;
}

function bool mwBottomFeeder(int idx, out int a, optional controller Other)
{
	if (bDebug) log("mwMutant", name);
	if (xMutantGame(Level.Game).CurrentBottomFeeder != none)
	{
		PCI[idx].PC.ClientSetViewTarget(xMutantGame(Level.Game).CurrentBottomFeeder);
		PCI[idx].PC.SetViewTarget(xMutantGame(Level.Game).CurrentBottomFeeder);
		if (xMutantGame(Level.Game).CurrentBottomFeeder == PCI[idx].PC) PCI[idx].I.Meanwhile(format(messages.msgBottomFeederSelf[rand(messages.msgBottomFeederSelf.length)], idx));
			else PCI[idx].I.Meanwhile(format(messages.msgBottomFeeder[rand(messages.msgBottomFeeder.length)], idx, xMutantGame(Level.Game).CurrentBottomFeeder));
		return true;
	}
	return false;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	super.FillPlayInfo(PlayInfo);
	//TODO: doesn't work just yet
	PlayInfo.AddSetting(class'MutMeanwhile'.default.GroupName, "Actions", default.PIname[0], 5, 1, "Custom", ";;");

	default.MeanwhileMsgClass.static.FillPlayInfo(PlayInfo);
	default.PortalClass.static.FillPlayInfo(PlayInfo);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "actions": return default.PIdesc[0];
	}
	return "";
}

defaultproperties
{
	MeanwhileMsgClass=class'MeanwhileMsg'
	PortalClass=class'mwgr2iportal'

	bDebug=false

	PIname[0]="Actions"
	PIdesc[0]="Set the actions that can be used per gametype"

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
	Actions[10]=(gametype="XGame.xVehicleCTFGame",Actions=(-1,0,1,2,3))
}
