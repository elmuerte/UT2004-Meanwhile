/*******************************************************************************
	Meanwhile mutator, this is the main file. It will install all classes
	needed to run this mod.														<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id: MutMeanwhile.uc,v 1.7 2004/06/05 12:34:16 elmuerte Exp $ -->
*******************************************************************************/
class MutMeanwhile extends Mutator config;

const CVSId = "$Id: MutMeanwhile.uc,v 1.7 2004/06/05 12:34:16 elmuerte Exp $";

/** our game rules class */
var class<mwgr> MeanwhileGameRulesClass;

/** Team 0's super human */
var Controller SuperHero;
/** Team 1's super human */
var Controller SuperVillain;
/** past super humans */
var array<Controller> PastSuperHumans;
/** effects for each super human */
var SuperHumanEffect SuperHeroEffect, SuperVillainEffect;

/** enable super humans (only for team games) */
var(Config) config bool bSuperHumans;
/** super human modifier */
var(Config) config float fSuperHumanMod;
/** time to wait before selecting super humans */
var(Config) config float fSuperInterval;
/** duration of the super human powers */
var(Config) config float fSuperDuration;

/** select super humans at the next timer event */
var protected bool bSelectHumans;
/** true if super humans is enabled */
var protected bool bSHEn;

var localized string PIdesc[4], PIhelp[4];

/** install our game rules class */
event PreBeginPlay()
{
	local mwgr mwgr;
	Super.PreBeginPlay();
	log("Loading"@FriendlyName@"("$CVSId$")", name);

	mwgr = Spawn(MeanwhileGameRulesClass);
	mwgr.mwmut = self;
	Level.Game.AddGameModifier(mwgr);

	bSHEn = bSuperHumans && Level.Game.bTeamGame;
 	if (bSHEn)
	{
		enable('tick');
	}
}

event Tick(float DeltaTime)
{
	if (!Level.Game.GameReplicationInfo.bMatchHasBegun) return;
	if (bSHEn)
	{
		bSelectHumans = true;
		SetTimer(fSuperInterval, false);
	}
	disable('tick');
}

event Timer()
{
	if (Level.Game.bGameEnded) return;
	if (bSelectHumans)
	{
		if (Level.Game.NumPlayers+Level.Game.NumPlayers < 2)
		{	// not enough players
			SetTimer(fSuperInterval, false);
			return;
		}
		SelectSuperHuman(0);
		SelectSuperHuman(1);
		if (fSuperDuration > 0)
		{
			bSelectHumans = false;
			SetTimer(fSuperDuration, false);
		}
	}
	else {
		// remove super human powers
		if (SuperHero != none)
		{
			Level.Game.BroadcastLocalized(none, class'SuperHumanMessage', 2, SuperHero.PlayerReplicationInfo);
			MakePawnNormal(SuperHero);
			SuperHero = none;
		}
		if (SuperVillain != none)
		{
			Level.Game.BroadcastLocalized(none, class'SuperHumanMessage', 2, SuperVillain.PlayerReplicationInfo);
			MakePawnNormal(SuperVillain);
			SuperVillain = none;
		}
		bSelectHumans = true;
		SetTimer(fSuperInterval, false);
	}
}

function NotifyLogout(Controller Exiting)
{
	local int i;
	super.NotifyLogout(Exiting);
	if (!bSHEn) return;

	if (Exiting == SuperHero) SelectSuperHuman(0);
	else if (Exiting == SuperVillain) SelectSuperHuman(1);

	// remove from past list
	for (i = PastSuperHumans.length-1; i >= 0; i--)
	{
		if (PastSuperHumans[i] == Exiting)
		{
			PastSuperHumans.Remove(i, 1);
			return;
		}
	}
}

/** select a new super human */
function SelectSuperHuman(int team)
{
	local array<Controller> clist;
	local Controller C;
	local int i;

	//log("SelectSuperHuman"@team, name);
	for (C = Level.ControllerList; C != none; C = C.nextController)
	{
		if (!C.bIsPlayer) continue;
		if (C.PlayerReplicationInfo.Team.TeamIndex == team)
		{
			for (i = 0; i < PastSuperHumans.length; i++)
			{
				if (PastSuperHumans[i] == C) break;
			}
			clist[clist.length] = C;
		}
	}

	if (clist.length == 0)
	{
		if (PastSuperHumans.length == 0) return;
		PastSuperHumans.length = 0;
		SelectSuperHuman(team);
		return;
	}
	C = clist[rand(clist.length)];
	PastSuperHumans[i] = C;
	if (team == 0) SuperHero = C;
	else SuperVillain = C;
	SpawnSuperHumanEffect(C, team);
}

/** make the controller super */
function SpawnSuperHumanEffect(Controller C, int team)
{
	//log("New super human:"@C.PlayerReplicationInfo.PlayerName, name);
	BroadcastLocalizedMessage(class'SuperHumanMessage', team, C.PlayerReplicationInfo);
	MakePawnSuper(C);
}

/** check if a super human respawned */
function ModifyPlayer(Pawn Other)
{
	super.ModifyPlayer(Other);
	if (!bSHEn) return;
	//log("ModifyPlayer", name);
	if (Other.Controller == SuperHero)
	{
		if (Other.Controller.PlayerReplicationInfo.Team.TeamIndex == 0)
		{
			MakePawnSuper(Other.Controller);
		}
		else {
			SuperHero = none;
			SelectSuperHuman(0);
		}
	}
	else if (Other.Controller == SuperVillain)
	{
		if (Other.Controller.PlayerReplicationInfo.Team.TeamIndex == 1)
		{
			MakePawnSuper(Other.Controller);
		}
		else {
			SuperVillain = none;
			SelectSuperHuman(1);
		}
	}
}

/** modify the player pawn to become super */
function MakePawnSuper(Controller C)
{
	local Pawn RealPawn;
	local float fSizeMod;
	if (Vehicle(C.Pawn) != none)
	{
		RealPawn = Vehicle(C.Pawn).Driver;
	}
	else RealPawn = C.Pawn;
	if (RealPawn == none) return;
	//log("MakePawnSuper", name);

	fSizeMod = 1.0+(fSuperHumanMod-1.0)*2;

	RealPawn.BaseEyeHeight = RealPawn.default.BaseEyeHeight*fSizeMod;
	RealPawn.SetCollisionSize(RealPawn.default.CollisionRadius*fSizeMod, RealPawn.default.CollisionHeight*fSizeMod);
	RealPawn.GroundSpeed = RealPawn.default.GroundSpeed*fSuperHumanMod;
	RealPawn.AirSpeed = RealPawn.default.AirSpeed*fSuperHumanMod;
	RealPawn.WaterSpeed = RealPawn.default.WaterSpeed*fSuperHumanMod;
	RealPawn.AccelRate = RealPawn.default.AccelRate*fSuperHumanMod;
	RealPawn.JumpZ = RealPawn.default.JumpZ*fSuperHumanMod;
	RealPawn.HealthMax = RealPawn.default.HealthMax*fSuperHumanMod;
	RealPawn.Health = RealPawn.HealthMax;
	RealPawn.SuperHealthMax = RealPawn.default.SuperHealthMax*fSuperHumanMod;
	RealPawn.CrouchHeight = RealPawn.default.CrouchHeight*fSizeMod;
	RealPawn.SetDrawScale(RealPawn.default.DrawScale*fSizeMod);

	if (RealPawn.Role == ROLE_Authority)
	{
		if (C == SuperHero)
		{
			//if (SuperHeroEffect != none) SuperHeroEffect.Die();
			SuperHeroEffect = Spawn(class'SuperHumanEffect', RealPawn,, RealPawn.Location, RealPawn.Rotation);
		}
		else {
			//if (SuperVillainEffect != none) SuperVillainEffect.Die();
			SuperVillainEffect = Spawn(class'SuperHumanEffect', RealPawn,, RealPawn.Location, RealPawn.Rotation);
		}
	}

}

/** return the human to the normal state */
function MakePawnNormal(Controller C)
{
	local Pawn RealPawn;
	if (Vehicle(C.Pawn) != none)
	{
		RealPawn = Vehicle(C.Pawn).Driver;
	}
	else RealPawn = C.Pawn;
	if (RealPawn == none) return;
	//log("MakePawnNormal", name);

	RealPawn.BaseEyeHeight = RealPawn.default.BaseEyeHeight;
	RealPawn.SetCollisionSize(RealPawn.default.CollisionRadius, RealPawn.default.CollisionHeight);
	RealPawn.GroundSpeed = RealPawn.default.GroundSpeed;
	RealPawn.AirSpeed = RealPawn.default.AirSpeed;
	RealPawn.WaterSpeed = RealPawn.default.WaterSpeed;
	RealPawn.AccelRate = RealPawn.default.AccelRate;
	RealPawn.JumpZ = RealPawn.default.JumpZ;
	RealPawn.HealthMax = RealPawn.default.HealthMax;
	RealPawn.SuperHealthMax = RealPawn.default.SuperHealthMax;
	RealPawn.CrouchHeight = RealPawn.default.CrouchHeight;
	RealPawn.SetDrawScale(RealPawn.default.DrawScale);

	if (RealPawn.Role == ROLE_Authority)
	{
		if (C == SuperHero)
		{
			if (SuperHeroEffect != none) SuperHeroEffect.Die();
			SuperHeroEffect = none;
		}
		else {
			if (SuperVillainEffect != none) SuperVillainEffect.Die();
			SuperVillainEffect = none;
		}
	}
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.GroupName, "bSuperHumans", 		default.PIdesc[0], 5, 1, "Check");
	PlayInfo.AddSetting(default.GroupName, "fSuperHumanMod", 	default.PIdesc[1], 5, 1, "Text", "5;1:10");
	PlayInfo.AddSetting(default.GroupName, "fSuperInterval", 	default.PIdesc[2], 5, 1, "Text", "5;0:9999");
	PlayInfo.AddSetting(default.GroupName, "fSuperDuration", 	default.PIdesc[3], 5, 1, "Text", "5;0:9999");
	default.MeanwhileGameRulesClass.static.FillPlayInfo(PlayInfo);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bSuperHumans":	return default.PIhelp[0];
		case "fSuperHumanMod":	return default.PIhelp[1];
		case "fSuperinterval":	return default.PIhelp[2];
		case "fSuperDuration":	return default.PIhelp[3];
	}
	return "";
}

DefaultProperties
{
	MeanwhileGameRulesClass=class'mwgr';

	FriendlyName="Meanwhile..."
	GroupName="Meanwhile"
	Description="Meanwhile... super villain El Muerte continues to move onward to Earth. Can you stop him?"

	PIdesc[0]="Enable super humans"
	PIhelp[0]="Will choose a super hero and super villain at set intervals, only available for team games."
	PIdesc[1]="Super human modification factor"
	PIhelp[1]="Controlls with what multiplier the super humans will be modified."
	PIdesc[2]="Selection delay"
	PIhelp[2]="Time to wait before selecting super humans."
	PIdesc[3]="Duration"
	PIhelp[3]="Duration of the super powers."

	bSuperHumans=true
	fSuperHumanMod=1.25
	fSuperinterval=120
	fSuperDuration=60
}
