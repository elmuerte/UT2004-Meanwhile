/*******************************************************************************
	Message class, contains the message configuration							<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id: MeanwhileMsg.uc,v 1.4 2004/06/05 12:34:16 elmuerte Exp $ -->
*******************************************************************************/
class MeanwhileMsg extends Info config(Meanwhile) parseconfig;

/*
	The following replacements are accepted (some are context sensitive):
	%me%						current player name
	%his_her%					"his" or "her" for the player
	%team%						team name

	- context: random player/killer/top scorer/flag carrier/mutant/bottom feeder
	%other%						player name or "someone"
	%ohis_her%					"his" or "her" for the other player
	%oweapon%					other player's weapon
	%hasflagmsg%				other has/took flag/ball message
	%flag%						flag/ball name
	%oteam%						team name

	- context: control point
	%cp_name%					name fo the control point
	%cp_controller%				name of the player controlling the point
	%cp_team%					controlling team name

	- context: objective
	%objective%					the name of the objective
	%objective_desc%			descriptiong of the objective
	%objective_infoa%			attack info
	%objective_infod%			defend info
*/

/** the value of "meanwhile..." */
var config string Meanwhile;
/** newline delimiter */
var config string delim;

/** in case other doesn't exist, use "someone" */
var config string Someone;
/** used when no weapon name was available */
var config string It;
/** his and her strings */
var config string His, Her;

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
/** action id = 7 */
var config array<string> msgMutant;
/** action id = 8 */
var config array<string> msgBottomFeeder, msgBottomFeederSelf;

struct FlagNameEntry
{
	/** the game type */
	var string gametype;
	/** true if it's our flag, ignore this for games that don't use CTFFlag decorastions */
	var bool bourflag;
	/** the flag name */
	var string flagname;
};
/** name of the "flag" for each gametype */
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
	His="his"
	Her="her"

	EndGame="To be continued...ÿNext issue..."

	//
	msgMisc[0]="%other% is still in the game."
	msgMisc[1]="%other% isn't just layingÿaround playing dead."
	msgMisc[2]="The tournament counsil thinks %other%ÿis a better player than %me%."
	msgMisc[3]="A lot of people leftÿthe %me% fan club."

	//
	msgKiller[0]="%other% gains another frag."
	msgKiller[1]="%other% found a way toÿget rid of %me%."
	msgKiller[2]="%me% has been downsizedÿby %other%"
	msgKiller[3]="%me% got to know %oweapon% up close."

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
	msgFFlagBaseSafe[0]="Your flag is still safe."
	msgFFlagBaseLost[0]="Your flag has been taken."

	msgEFlagBaseSafe[0]="The enemy's flag is safe."
	msgEFlagBaseLost[0]="The other team lost their flag."

	//
	msgCPnoteam[0]="Control point %cp_name%ÿbelongs to nobody."
	msgCPnoteam[1]="One of the control pointsÿis not being controlled."

	msgCPmyteam[0]="Control point %cp_name% isÿin danger because you're dead"
	msgCPmyteam[1]="%cp_controller% still controlls point %cp_name%"

	msgCPenemyteam[0]="The other team stillÿhas a control point."
	msgCPenemyteam[1]="%cp_controller% still controlls point %cp_name%"

	//
	msgMyFinalPCAttack[0]="Your power core is under attack."
	msgMyFinalPCAttack[1]="You're losing your power core."

	msgMyFinalPC[0]="Your power core is still safe."
	msgMyFinalPC[1]="Nobody knows how longÿyour core will be safe."

	msgOtherFinalPCAttack[0]="The enemy power coreÿis being attacked."
	msgOtherFinalPCAttack[1]="The rest of your teamÿis trying to win."

	msgOtherFinalPC[0]="Your destination is still safe."
	msgOtherFinalPC[1]="The enemy power coreÿisn't within reach."

	msgMyPCAttack[0]="One of your power nodes is under attack."
	msgMyPCAttack[1]="The enemy is gaining on you."

	msgMyPC[0]="This power node is holding up."
	msgMyPC[1]="The enemy doesn'tÿknowabout his node."

	msgOtherPCAttack[0]="One of the enemy's powerÿnode is under attack."
	msgOtherPCAttack[1]="One going down, more to go."

	msgOtherPC[0]="This power node is still working."
	msgOtherPC[1]="The enemy still has anÿoperational power node."

	//
	msgObjectiveDoneA[0]="You had more luck toÿ%objective_desc%."
	msgObjectiveDoneA[1]="Remember how you completedÿthe last objective?"

	msgObjectiveTodoA[0]="You have toÿ%objective_desc%."
	msgObjectiveTodoA[1]="Nobody told %me%ÿto %objective_infoa%."

	msgObjectiveDoneD[0]="You're messing upÿjust like with %objective%"
	msgObjectiveDoneD[1]="Do you remember whatÿhappened with %objective%ÿyou FAILED!."

	msgObjectiveTodoD[0]="You have toÿ%objective_infod%."
	msgObjectiveTodoD[1]="%objective% is unguarded."

	//
	msgMutant[0]="%other% is still the mutant"
	msgMutant[1]="%other% is trying to stay theÿmutant for the rest of the game"

	//
	msgBottomFeeder[0]="%other% is stillÿthe bottom feeder"
	msgBottomFeeder[1]="the bottom feederÿcould use some points"
	msgBottomFeederSelf[0]="the bottom feeder isÿnobody else than %me%"
	msgBottomFeederSelf[1]="you are stillÿthe bottom feeder"

}
