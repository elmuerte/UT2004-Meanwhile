/*******************************************************************************
	Meanwhile mutator, this is the main file. It will install all classes
	needed to run this mod.														<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id: MutMeanwhile.uc,v 1.4 2004/06/02 21:37:03 elmuerte Exp $ -->
*******************************************************************************/
class MutMeanwhile extends Mutator config;

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


/** install our game rules class */
event PreBeginPlay()
{
	Super.PreBeginPlay();
	Level.Game.AddGameModifier(Spawn(MeanwhileGameRulesClass));

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
	if (bSelectHumans)
	{
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
		Level.Game.BroadcastLocalized(none, class'SuperHumanMessage', 2, SuperHero.PlayerReplicationInfo);
		MakePawnNormal(SuperHero);
		SuperHero = none;
		Level.Game.BroadcastLocalized(none, class'SuperHumanMessage', 2, SuperVillain.PlayerReplicationInfo);
		MakePawnNormal(SuperVillain);
		SuperVillain = none;

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
	local Controller C;
	local int i;

	log("SelectSuperHuman"@team, name);
	for (C = Level.ControllerList; C != none; C = C.nextController)
	{
		if (!C.bIsPlayer) continue;
		if (C.PlayerReplicationInfo.Team.TeamIndex == team)
		{
			for (i = 0; i < PastSuperHumans.length; i++)
			{
				if (PastSuperHumans[i] == C) break;
			}
			if (i == PastSuperHumans.length) // found new
			{
				PastSuperHumans[i] = C;
				if (team == 0) SuperHero = C;
				else SuperVillain = C;
				SpawnSuperHumanEffect(C, team);
				return;
			}
		}
	}
}

/** make the controller super */
function SpawnSuperHumanEffect(Controller C, int team)
{
	log("New super human:"@C.PlayerReplicationInfo.PlayerName, name);
	BroadcastLocalizedMessage(class'SuperHumanMessage', team, C.PlayerReplicationInfo);
	MakePawnSuper(C);
}

/** check if a super human respawned */
function ModifyPlayer(Pawn Other)
{
	super.ModifyPlayer(Other);
	if (!bSHEn) return;
	log("ModifyPlayer", name);
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
	local SuperHumanEffect Effect;
	log("MakePawnSuper", name);
	if (C.Pawn == none) return;
	//TODO: check for vehicles
	C.Pawn.BaseEyeHeight = C.Pawn.default.BaseEyeHeight*fSuperHumanMod;
	//C.Pawn.CollisionHeight = C.Pawn.default.CollisionHeight*fSuperHumanMod;
	C.Pawn.GroundSpeed = C.Pawn.default.GroundSpeed*fSuperHumanMod;
	C.Pawn.AirSpeed = C.Pawn.default.AirSpeed*fSuperHumanMod;
	C.Pawn.WaterSpeed = C.Pawn.default.WaterSpeed*fSuperHumanMod;
	C.Pawn.AccelRate = C.Pawn.default.AccelRate*fSuperHumanMod;
	C.Pawn.JumpZ = C.Pawn.default.JumpZ*fSuperHumanMod;
	C.Pawn.HealthMax = C.Pawn.default.HealthMax*fSuperHumanMod;
	C.Pawn.Health = C.Pawn.HealthMax;
	C.Pawn.SuperHealthMax = C.Pawn.default.SuperHealthMax*fSuperHumanMod;
	C.Pawn.CrouchHeight = C.Pawn.default.CrouchHeight*fSuperHumanMod;
	C.Pawn.SetDrawScale(C.Pawn.default.DrawScale*fSuperHumanMod);

	if (C.Pawn.Role == ROLE_Authority)
	{
		if (C == SuperHero) Effect = SuperHeroEffect;
		else Effect = SuperVillainEffect;
		if (Effect != none) Effect.Destroy();
        Effect = Spawn(class'SuperHumanEffect', C.Pawn,, C.Pawn.Location, C.Pawn.Rotation);
    }

}

function MakePawnNormal(Controller C)
{
	log("MakePawnNormal", name);
	if (C.Pawn == none) return;
	//TODO: check for vehicles
	C.Pawn.BaseEyeHeight = C.Pawn.default.BaseEyeHeight;
	//C.Pawn.CollisionHeight = C.Pawn.default.CollisionHeight;
	C.Pawn.GroundSpeed = C.Pawn.default.GroundSpeed;
	C.Pawn.AirSpeed = C.Pawn.default.AirSpeed;
	C.Pawn.WaterSpeed = C.Pawn.default.WaterSpeed;
	C.Pawn.AccelRate = C.Pawn.default.AccelRate;
	C.Pawn.JumpZ = C.Pawn.default.JumpZ;
	C.Pawn.HealthMax = C.Pawn.default.HealthMax;
	C.Pawn.SuperHealthMax = C.Pawn.default.SuperHealthMax;
	C.Pawn.CrouchHeight = C.Pawn.default.CrouchHeight;
	C.Pawn.SetDrawScale(C.Pawn.default.DrawScale);

	if (C.Pawn.Role == ROLE_Authority)
	{
		if (C == SuperHero)
		{
			if (SuperHeroEffect != none) SuperHeroEffect.Destroy();
			SuperHeroEffect = none;
		}
		else {
			if (SuperVillainEffect != none) SuperVillainEffect.Destroy();
			SuperVillainEffect = none;
		}
    }
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	super.FillPlayInfo(PlayInfo);
	default.MeanwhileGameRulesClass.static.FillPlayInfo(PlayInfo);
}

static event string GetDescriptionText(string PropName)
{
	return "";
}

DefaultProperties
{
	MeanwhileGameRulesClass=class'mwgr';

	FriendlyName="Meanwhile"
	GroupName="Meanwhile"
	Description="Meanwhile..."

	bSuperHumans=true
	fSuperHumanMod=1.5
	fSuperinterval=60
	fSuperDuration=60
}
