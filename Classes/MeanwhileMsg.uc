/*******************************************************************************
	Message class, contains the message configuration							<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id: MeanwhileMsg.uc,v 1.2 2004/06/01 21:39:39 elmuerte Exp $ -->
*******************************************************************************/
class MeanwhileMsg extends Info config(Meanwhile) parseconfig;

/** the value of "meanwhile..." */
var config string Meanwhile;
/** newline delimiter */
var config string delim;

/** in case other doesn't exist, use "someone" */
var config string Someone;

var config string It;

/** string to show when the game ends */
var config string EndGame;

/** miscelaneous lines, for example used with a random player (-1) */
var config array<string> msgMisc;
/** action id = 0 */
var config array<string> msgKiller;
/** action id = 1 */
var config array<string> msgBest;
/** action id = 2 */
var config array<string> msgCarrierFriendly, msgCarrierEnemy;
/** action id = 3 */
var config array<string> msgFFlagBaseSafe, msgFFlagBaseLost, msgEFlagBaseSafe, msgEFlagBaseLost;
/** action id = 4 */
var config array<string> msgCPnoteam, msgCPmyteam, msgCPenemyteam;
/** action id = 5 */
var config array<string> msgMyFinalPCAttack, msgMyFinalPC, msgOtherFinalPCAttack, msgOtherFinalPC,
	msgMyPCAttack, msgMyPC, msgOtherPCAttack, msgOtherPC;
/** action id = 6 */
var config array<string> msgObjectiveDoneA, msgObjectiveTodoA, msgObjectiveDoneD, msgObjectiveTodoD;

struct FlagNameEntry
{
	/** the game type */
	var string gametype;
	/** true if it's our flag, ignore this for games that don't use CTFFlag decorastions */
	var bool bourflag;
	/** the flag name */
	var string flagname;
};
var config array<FlagNameEntry> FlagNames;

/** return the right name for the flag */
static function string getFlagName(coerce string gametype, optional bool bOurFlag)
{
	local int i;
	for (i = 0; i < default.FlagNames.length; i++)
	{
		if (default.FlagNames[i].gametype ~= gametype)
		{
			if (default.FlagNames[i].bourflag == bOurflag)
			{
				return default.FlagNames[i].flagname;
			}
		}
	}
	return "";
}

defaultproperties
{
	Meanwhile="Meanwhile..."
	delim="ÿ"

	Someone="Someone"
	It="it"

	EndGame="To be continued...ÿNext issue..."

	//
	msgMisc[0]="%other% is still in the game."
	msgMisc[1]="%other% isn't just layingÿaround playing dead."
	msgMisc[2]="The tournament counsil thinks %other%ÿis a better player than %me%."
	msgMisc[3]="A lot of people leftÿthe %me% fan club."

	//
	msgKiller[0]="%other% gains another frag."
	msgKiller[1]="%other% found a way to get rid of %me%."

	//
	msgBest[0]="%other% knows how toÿhandle the %oweapon%."
	msgBest[1]="%other% still has the highest score."
	msgBest[2]="%me% can't measure up to %other%."

	//
	msgCarrierFriendly[0]="%other% %hasflagmsg%"
	msgCarrierFriendly[1]="%other% is going for a point"
	msgCarrierFriendly[2]="%other% is running around with %flag%"

	msgCarrierEnemy[0]="%other% %hasflagmsg%"
	msgCarrierEnemy[1]="%other% is going for a point"
	msgCarrierEnemy[2]="%other% is running around with %flag%"

	FlagNames[0]=(gametype="XGame.xCTFGame",bOurflag=true,flagname="our flag")
	FlagNames[1]=(gametype="XGame.xCTFGame",bOurflag=false,flagname="the enemy flag")
	FlagNames[2]=(gametype="XGame.xVehicleCTFGame",bOurflag=true,flagname="our flag")
	FlagNames[3]=(gametype="XGame.xVehicleCTFGame",bOurflag=false,flagname="the enemy flag")
	FlagNames[4]=(gametype="XGame.xBombingRun",flagname="the ball")

	//
	msgFFlagBaseSafe[0]="Your flag is still safe"
	msgFFlagBaseLost[0]="Your flag has been taken"

	msgEFlagBaseSafe[0]="The enemy's flag is safe"
	msgEFlagBaseLost[0]="The other team lost their flag"

	//
	msgCPnoteam[0]="Control point %cp_name%ÿbelongs to nobody."

	msgCPmyteam[0]="Control point %cp_name% isÿin danger because you're dead"
	msgCPmyteam[1]="%cp_controller% still controlls point %cp_name%"

	msgCPenemyteam[0]="The other team stillÿhas a control point."
	msgCPenemyteam[1]="%cp_controller% still controlls point %cp_name%"

	//
	msgMyFinalPCAttack[0]="Your power core is under attack"

	msgMyFinalPC[0]="Your power core is still safe"

	msgOtherFinalPCAttack[0]="The enemy power core is being attacked"

	msgOtherFinalPC[0]="Your destination is still safe"

	msgMyPCAttack[0]="One of your power nodes is under attack."

	msgMyPC[0]="This power node is holding up."

	msgOtherPCAttack[0]="One of the enemy's powerÿnode is under attack."

	msgOtherPC[0]="This power node is still working."

	//
	msgObjectiveDoneA[0]="you had more luck toÿ%objective_desc%"

	msgObjectiveTodoA[0]="you have toÿ%objective_desc%"
	msgObjectiveTodoA[1]="nobody told %me%ÿto %objective_infoa%"

	msgObjectiveDoneD[0]="you're messing upÿjust like with %objective%"

	msgObjectiveTodoD[0]="you have toÿ%objective_infod%"

}
