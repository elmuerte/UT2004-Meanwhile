/*******************************************************************************
	The interaction that will perform the client side meanwhile					<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id: mwInteraction.uc,v 1.5 2004/06/05 12:34:16 elmuerte Exp $ -->
*******************************************************************************/
class mwInteraction extends Interaction config;

#EXEC AUDIO IMPORT NAME=elmw FILE=Sounds\el2.wav
#EXEC AUDIO IMPORT NAME=eltbc FILE=Sounds\el-cont.wav

/** old hud state */
var protected bool bOldHideHUD, bOldCrosshairShow;

/** sound to play on the meanwhile event */
var sound sndMeanwhile;
/** end game sound */
var sound sndToBeContinued;

/** materials we use to draw our borders */
var config TexRotator texBorder, texCaption[3];
/** current values for the outer border rotation */
var float texrot, rotmod;
/** grid overlay */
var config Material Grid;
/** caption texture to use */
var int captex[2];

/** font used for all the text */
var config Font ComicFont;

/** available crunches */
var config array<TexRotator> Crunches;
/** selected crunch */
var TexRotator SelCrunch;
/** crunch position */
var float CrunchPos[2];
var vector pendingCrunchPos;
/** draw scale, updated in the tick */
var float CrunchSize;
var float CrunchTime;

/** the text to print */
var array<string> lines, infostring;

var bool bEndGame, bCrunch;
var float EndGameCountDown;

/** initial set up */
event Initialized()
{
	super.Initialized();
}

/** active the meanwhile stuff */
function Meanwhile(coerce string msg)
{
	//log("Meanwhile", name);
	bOldHideHUD = ViewportOwner.Actor.myHUD.bHideHUD;
	bOldCrosshairShow = ViewportOwner.Actor.myHUD.bCrosshairShow;
	ViewportOwner.Actor.myHUD.bHideHUD = true;
	ViewportOwner.Actor.myHUD.bCrosshairShow = false;

	if (frand() > 0.25) ViewportOwner.Actor.PlayOwnedSound(sndMeanwhile, SLOT_Talk, 0.5,, maxint);

	texrot = frand()*1500-750;
	if (frand() >= 0.5) rotmod = 1;
	else rotmod = -1;
	texBorder.Rotation.Pitch = texrot/-2;
	texBorder.Rotation.Roll = texrot/-2;
	texBorder.Rotation.Yaw = texrot;

	captex[0] = rand(3);
	captex[1] = rand(3);

	split(msg, Chr(10), lines); // newline is newline

	bEndGame = false;
	bCrunch = false;
	bVisible = true;
	bRequiresTick = true;
}

/** game over */
function Endgame(coerce string msg)
{
	bOldHideHUD = ViewportOwner.Actor.myHUD.bHideHUD;
	bOldCrosshairShow = ViewportOwner.Actor.myHUD.bCrosshairShow;

	texrot = frand()*1500-750;
	if (frand() >= 0.5) rotmod = 1;
	else rotmod = -1;
	texBorder.Rotation.Pitch = texrot/-2;
	texBorder.Rotation.Roll = texrot/-2;
	texBorder.Rotation.Yaw = texrot;

	captex[0] = rand(3);
	captex[1] = rand(3);

	split(msg, Chr(10), infostring); // newline is newline

	EndGameCountDown = 2;
	bEndGame = true;
	bVisible = true;
	bRequiresTick = true;
}

/** draw a comic crunch on screen */
function Crunch(vector PlayerLoc)
{
	log("Crunch", name);
	bOldHideHUD = ViewportOwner.Actor.myHUD.bHideHUD;
	bOldCrosshairShow = ViewportOwner.Actor.myHUD.bCrosshairShow;

	pendingCrunchPos = PlayerLoc;
	CrunchPos[0] = -1;
	CrunchSize = 0.25;
	SelCrunch = Crunches[rand(Crunches.length)];
	SelCrunch.Rotation.Yaw = frand()*4000-2000;
	SelCrunch.Rotation.Roll = SelCrunch.Rotation.Yaw / -2;
	SelCrunch.Rotation.Pitch = SelCrunch.Rotation.Yaw / -2;
	CrunchTime = 1;
	bCrunch = true;
	bVisible = true;
	bRequiresTick = true;
}

/** clean up all the mess we made */
function Reset(optional bool bRemove)
{
	//log("Reset", name);
	bVisible = false;
	bRequiresTick = false;
	bCrunch = false;
	ViewportOwner.Actor.myHUD.bHideHUD = bOldHideHUD;
	ViewportOwner.Actor.myHUD.bCrosshairShow = bOldCrosshairShow;
	if (bRemove) Master.RemoveInteraction(self);
}

/** updat the border rotation */
function Tick(float DeltaTime)
{
	if (EndGameCountDown > 0 && bEndGame)
	{
		EndGameCountDown = EndGameCountDown-DeltaTime;
		if (EndGameCountDown < 0) ViewportOwner.Actor.PlayOwnedSound(sndToBeContinued, SLOT_Talk, 0.75,, maxint);
	}
	if (ViewportOwner.Actor.PlayerReplicationInfo.bOnlySpectator)
	{
		Reset(); // because else the mutator will become screwed up
		return;
	}
	if (bCrunch)
	{
		if (CrunchSize < 1)
		{
			CrunchSize = CrunchSize + (DeltaTime*4);
			CrunchSize = fmin(CrunchSize, 1);
		}
		CrunchTime = CrunchTime-DeltaTime;
		if (CrunchTime < 0)
		{
			Reset();
		}
		return;
	}
	if (texrot >= 750) rotmod = -1;
	else if (texrot <= -750) rotmod = 1;
	texrot = texrot+(rotmod*12.5*DeltaTime);
	texBorder.Rotation.Pitch = texrot/-2;
	texBorder.Rotation.Roll = texrot/-2;
	texBorder.Rotation.Yaw = texrot;
}

/** render our comic look */
function PostRender( canvas Canvas )
{
	local float TextX, TextY;
	local float tmpx, tmpy;
	local int i;
	local vector v;

	Canvas.Reset();

	if (bCrunch) // draw CRUNCH
	{
		if (CrunchPos[0] == -1)
		{
			v = Canvas.WorldToScreen(pendingCrunchPos);
			CrunchPos[0] = v.X;
			CrunchPos[1] = v.Y;
		}
		Canvas.DrawColor = Canvas.MakeColor(255,255,255,196);
		Canvas.SetPos(CrunchPos[0]-(float(SelCrunch.MaterialUSize())*CrunchSize/2.0),CrunchPos[1]-(float(SelCrunch.MaterialVSize())*CrunchSize/2.0));
		Canvas.DrawTileScaled(SelCrunch, CrunchSize*(float(Canvas.SizeX)/1024.0), CrunchSize*(float(Canvas.SizeY)/768.0)); // tweaked on 1024x768
		//tmpx = float(SelCrunch.MaterialUSize())*CrunchSize*(float(Canvas.SizeX)/1024.0);
		//tmpy = float(SelCrunch.MaterialVSize())*CrunchSize*(float(Canvas.SizeY)/768.0);
		//Canvas.DrawTile(SelCrunch, tmpx, tmpy, 0, 0, SelCrunch.MaterialUSize(), SelCrunch.MaterialVSize());
		return;
	}

	// grid
	Canvas.DrawColor = Canvas.MakeColor(255,255,255,128);
	Canvas.SetPos(0,0);
	//Canvas.DrawPattern(Grid, Canvas.SizeX, Canvas.SizeY, 2);
	Canvas.DrawTile(Grid, Canvas.ClipX, Canvas.ClipY, 0, 0, Canvas.ClipX/2, Canvas.ClipY/2);
	// Border
	Canvas.DrawColor = Canvas.MakeColor(255,255,255,255);
	Canvas.SetPos(-0.12*Canvas.SizeX, -0.12*Canvas.SizeY);
	Canvas.DrawTile(texBorder, 1.24*Canvas.SizeX, 1.24*Canvas.SizeY, 0, 0, 256, 256);

	Canvas.Font = ComicFont;
	if (!bEndGame)
	{
		// calc text size
		for (i = 0; i < lines.length; i++)
		{
			Canvas.TextSize(lines[i], tmpx, tmpy);
			TextX = fmax(tmpx, TextX);
			TextY = fmax(tmpy, TextY);
		}
		TextY = TextY*1.1;

		// Caption frame
		Canvas.DrawColor = Canvas.MakeColor(255,255,255,228);
		Canvas.SetPos(0.08*Canvas.SizeX, 0.08*Canvas.SizeY);
		Canvas.DrawTile(texCaption[captex[0]], TextX*1.3, TextY*lines.length*1.3, 0, 0, 256, 128);
		// draw Text
		Canvas.DrawColor = Canvas.MakeColor(0,0,0,255);
		for (i = 0; i < lines.length; i++)
		{
			Canvas.SetPos(0.105*Canvas.SizeX, (0.0905*Canvas.SizeY)+(TextY*i));
			Canvas.DrawText(lines[i]);
		}
	}

	// draw info string
	if (!bEndGame)
	{
		if (HudBDeathMatch(ViewportOwner.Actor.myHUD) != none)
			split(HudBDeathMatch(ViewportOwner.Actor.myHUD).GetInfoString(), ".", infostring);
		else if (HudCDeathMatch(ViewportOwner.Actor.myHUD) != none)
			split(HudCDeathMatch(ViewportOwner.Actor.myHUD).GetInfoString(), ".", infostring);
	}

	if (infostring.Length == 0) return;

	for (i = infostring.length-1; i >=0; i--)
	{
		if (infostring[i] == "") infostring.remove(i,1);
	}

	TextX = 0;
	TextY = 0;
	for (i = 0; i < infostring.length; i++)
	{
		Canvas.TextSize(infostring[i], tmpx, tmpy);
		TextX = fmax(tmpx, TextX);
		TextY = fmax(tmpy, TextY);
	}
	TextY = TextY*1.1;
	// Caption frame
	Canvas.DrawColor = Canvas.MakeColor(255,255,255,228);
	Canvas.SetPos(Canvas.SizeX*0.85-TextX, Canvas.SizeY*0.91-(TextY*infostring.length));
	Canvas.DrawTile(texCaption[captex[1]], TextX*1.3, TextY*infostring.length*1.3, 0, 0, 256, 128);
	// draw Text
	Canvas.DrawColor = Canvas.MakeColor(0,0,0,255);
	for (i = 0; i < infostring.length; i++)
	{
		Canvas.SetPos(Canvas.SizeX*0.87-TextX, Canvas.SizeY*0.92-(TextY*infostring.length)+(TextY*i));
		Canvas.DrawText(infostring[i]$".");
	}
}

/** level changed, force ourselfs away */
event NotifyLevelChange()
{
	Reset(true);
}

defaultproperties
{
	sndMeanwhile=sound'elmw'
	sndToBeContinued=sound'eltbc'
	texBorder=Material'MeanwhileTex.ToonBorder'
	texCaption[0]=Material'MeanwhileTex.ToonCaption1'
	texCaption[1]=Material'MeanwhileTex.ToonCaption2'
	texCaption[2]=Material'MeanwhileTex.ToonCaption3'
	Grid=Material'MeanwhileTex.Grid'
	ComicFont=Font'MeanwhileTex.Comic'
	Crunches[0]=Material'MeanwhileTex.Crunch.Crunch1'
	Crunches[1]=Material'MeanwhileTex.Crunch.Crunch2'
	Crunches[2]=Material'MeanwhileTex.Crunch.Crunch3'
}
