/*******************************************************************************
	Meanwhile mutator, this is the main file. It will install all classes
	needed to run this mod.														<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id: MutMeanwhile.uc,v 1.3 2004/06/02 09:21:23 elmuerte Exp $ -->
*******************************************************************************/
class MutMeanwhile extends Mutator;

var class<mwgr> MeanwhileGameRulesClass;

/** install our game rules class */
event PostBeginPlay()
{
	Super.PostBeginPlay();
	Level.Game.AddGameModifier(Spawn(MeanwhileGameRulesClass));
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
}
