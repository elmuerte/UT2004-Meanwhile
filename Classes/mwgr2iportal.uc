/*******************************************************************************
	Game rules to interaction portal											<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id: mwgr2iportal.uc,v 1.3 2004/06/05 12:34:16 elmuerte Exp $ -->
*******************************************************************************/
class mwgr2iportal extends Info;

/** our interaction */
var protected mwInteraction I;

replication
{
	reliable if (Role == ROLE_Authority)
		AddInteraction, Meanwhile, ResetMW, EndGame, Crunch;
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

simulated function Crunch(vector PlayerLoc)
{
	I.Crunch(PlayerLoc);
}

simulated function ResetMW(optional bool bRemove)
{
	I.Reset(bRemove);
	if (bRemove) I = none;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
