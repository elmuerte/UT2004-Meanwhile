/*******************************************************************************
	Super Human power messages													<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id: SuperHumanMessage.uc,v 1.1 2004/06/02 21:37:03 elmuerte Exp $ -->
*******************************************************************************/
class SuperHumanMessage extends LocalMessage;

var localized string msgSuperHero, msgSuperVillain, msgLostPowers;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    switch (switch)
    {
		case 0:	return repl(default.msgSuperHero, "%s", RelatedPRI_1.PlayerName);
		case 1:	return repl(default.msgSuperVillain, "%s", RelatedPRI_1.PlayerName);
		case 2:	return repl(default.msgLostPowers, "%s", RelatedPRI_1.PlayerName);
    }
    return "";
}

defaultproperties
{
	bFadeMessage=True
	bIsSpecial=True
	Lifetime=3
	bBeep=False

	DrawColor=(R=128,G=255,B=0)
	FontSize=1

	StackMode=SM_Down
	PosY=0.1

	msgSuperHero="%s became a super hero"
	msgSuperVillain="%s became a super villain"
	msgLostPowers="%s is no longer a super human"
}
