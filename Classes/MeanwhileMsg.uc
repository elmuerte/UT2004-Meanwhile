/*******************************************************************************
	Message class, contains the message configuration							<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id -->
*******************************************************************************/
class MeanwhileMsg extends Info config(Meanwhile) parseconfig;

/** the value of "meanwhile..." */
var config string Meanwhile;
/** newline delimiter */
var config string delim;

/** in case other doesn't exist, use "someone" */
var config string Someone;

/** string to show when the game ends */
var config string EndGame;

/** miscelaneous lines, for example used with a random player (-1) */
var config array<string> msgMisc;
/** action id = 0 */
var config array<string> msgKiller;
/** action id = 1 */
var config array<string> msgBest;

defaultproperties
{
	Meanwhile="Meanwhile..."
	delim="�"

	Someone="Someone"

	EndGame="To be continued...�Next issue..."

	msgMisc[0]="%other% is still in the game."
	msgMisc[1]="%other% isn't just laying�around playing dead."
	msgMisc[2]="The tournament counsil thinks %other%�is a better player than %me%."
	msgMisc[3]="A lot of people left�the %me% fan club."

	msgKiller[0]="%other% gains another frag."
	msgKiller[1]="%other% found a way to get rid of %me%."

	msgBest[0]="%other% knows how to�handle the %oweapon%."
	msgBest[1]="%other% still has the highest score."
	msgBest[2]="%me% can't measure up to %other%."
}
