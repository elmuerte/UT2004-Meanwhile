/*******************************************************************************
	Meanwhile mutator, this is the main file. It will install all classes
	needed to run this mod.														<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id: MutMeanwhile.uc,v 1.2 2004/06/01 21:39:39 elmuerte Exp $ -->
*******************************************************************************/
class MutMeanwhile extends Mutator;

var class<mwgr> MeanwhileGameRulesClass;

/** install our game rules class */
event PostBeginPlay()
{
	Super.PostBeginPlay();
	Level.Game.AddGameModifier(Spawn(MeanwhileGameRulesClass));
}

DefaultProperties
{
	MeanwhileGameRulesClass=class'mwgr';

	FriendlyName="Meanwhile"
	GroupName="Meanwhile"
	Description="Meanwhile..."
}
