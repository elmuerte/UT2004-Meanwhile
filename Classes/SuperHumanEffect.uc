/*******************************************************************************
	Nice visual effect for super humans											<br />
																				<br />
	Copyright 2004, Michiel "El Muerte" Hendriks								<br />
	Released under the Open Unreal Mod License									<br />
	http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense
	<!-- $Id: SuperHumanEffect.uc,v 1.2 2004/06/03 20:57:24 elmuerte Exp $ -->
*******************************************************************************/

class SuperHumanEffect extends Emitter;

#exec OBJ LOAD FILE=EpicParticles.utx

event Tick(float deltatime)
{
	if (Owner == none) return;
	if (Pawn(Owner).Health <= 0) Die();
	Emitters[0].StartLocationRange.Z.Min = Pawn(Owner).CollisionHeight / -2;
	Emitters[0].StartLocationRange.Z.Max = Pawn(Owner).CollisionHeight / 2;
	SetLocation(Owner.Location);
}

function Die()
{
	//log("Die", name);
	Emitters[0].Disabled = true;
	Kill();
}

defaultproperties
{
	Begin Object Class=SpriteEmitter Name=SpriteEmitter0
		//Acceleration=(Z=-50.000000)
		UseColorScale=True
		ColorScale(0)=(Color=(B=0,G=255,R=6))
		ColorScale(1)=(RelativeTime=0.700000,Color=(G=255,R=190))
		ColorScale(2)=(RelativeTime=1.000000,Color=(G=255,R=190))
		ColorMultiplierRange=(Z=(Min=0.500000,Max=0.500000))
		FadeOutStartTime=0.700000
		FadeOut=True
		CoordinateSystem=PTCS_Independent
		MaxParticles=200
		StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-75.000000,Max=75.000000))
		UseRotationFrom=PTRS_Actor
		UseSizeScale=True
		UseRegularSizeScale=False
		SizeScale(0)=(RelativeSize=1.700000)
		SizeScale(1)=(RelativeTime=1.000000)
		StartSizeRange=(X=(Min=2.00000,Max=3.00000),Y=(Min=2.00000,Max=3.00000))
		UniformSize=True
		UseSkeletalLocationAs=PTSU_SpawnOffset
		SkeletalScale=(X=0.380000,Y=0.380000,Z=0.380000)
		Texture=Texture'EpicParticles.BurnFlare1'
		LifetimeRange=(Min=0.900000,Max=0.900000)
		SecondsBeforeInactive=0
		Name="SpriteEmitter0"
	End Object
	Emitters(0)=SpriteEmitter'SpriteEmitter0'

	bHighDetail=true
	bHardAttach=true
	bNoDelete=false
	RemoteRole=ROLE_None
	bNetTemporary=true
	bHidden=false
	AutoDestroy=true
	AutoReset=false
}
