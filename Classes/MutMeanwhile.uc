/*******************************************************************************
	Meanwhile mutator, this is the main file. It will install all classes
	needed to run this mod.														<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id -->
*******************************************************************************/
class MutMeanwhile extends Mutator;

/** install our game rules class */
event PostBeginPlay()
{
	Super.PostBeginPlay();
	Level.Game.AddGameModifier(Spawn(class'mwgr'));
}

DefaultProperties
{
	FriendlyName="Meanwhile"
	GroupName="Meanwhile"
	Description="Meanwhile..."
}
