/*******************************************************************************
	Nice visual effect for super humans											<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id: SuperHumanEffect.uc,v 1.1 2004/06/02 21:37:03 elmuerte Exp $ -->
*******************************************************************************/

class SuperHumanEffect extends RegenCrosses;

defaultproperties
{
	Skins=(FinalBlend'XEffectMat.RedBoltFB')
	mColorRange(0)=(B=150,G=150,R=250)
    mColorRange(1)=(B=150,G=250,R=250)
}
