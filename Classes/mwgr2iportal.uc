/*******************************************************************************
	Game rules to interaction portal											<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id: mwgr2iportal.uc,v 1.2 2004/06/01 21:39:39 elmuerte Exp $ -->
*******************************************************************************/
class mwgr2iportal extends Info;

/** our interaction */
var protected mwInteraction I;

replication
{
	reliable if (Role == ROLE_Authority)
		AddInteraction, Meanwhile, ResetMW, EndGame;
}

simulated function AddInteraction(optional string Interaction)
{
	local PlayerController PC;
	PC = Level.GetLocalPlayerController();
	if (Interaction == "") Interaction = string(class'mwInteraction');
	I = mwInteraction(PC.Player.InteractionMaster.AddInteraction(Interaction, PC.Player));
}

simulated function Meanwhile(coerce string msg)
{
	I.Meanwhile(msg);
}

simulated function EndGame(coerce string msg)
{
	I.EndGame(msg);
}

simulated function ResetMW(optional bool bDontRemove)
{
	I.Reset(bDontRemove);
	I = none;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
