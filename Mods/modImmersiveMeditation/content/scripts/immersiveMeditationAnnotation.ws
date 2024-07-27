///// commonMenu.ws /////
@wrapMethod(CR4CommonMenu) function OnRequestMenu( MenuName : name, MenuState : string)
{
	if( MenuName == (name)'MeditationClockMenu' )
	{
		thePlayer.AddTimer('BeginNewMeditation', 0.1, false);
		// ((CMeditationUI)thePlayer.getMeditation()).NewMeditate();
		CloseMenu();
	}
	else
	{
		wrappedMethod(MenuName, MenuState);
	}
}

///// meditationClockMenu.ws /////
@wrapMethod(CR4MeditationClockMenu) function OnCloseMenu()
{
	var passedSecondsInGameTime : float;
	var passedSecondsInRealTime : float;
	if(thePlayer.GetCurrentStateName() != 'MeditationWaiting' || thePlayer.GetCurrentStateName() != 'Meditation')
	{
		passedSecondsInGameTime = GameTimeToSeconds(theGame.GetGameTime() - ((CMeditationUI)thePlayer.getMeditation()).getWaitStartTime());
		passedSecondsInRealTime = ConvertGameSecondsToRealTimeSeconds(passedSecondsInGameTime);

		((CMeditationUI)thePlayer.getMeditation()).setMedMenuBool(true);
		((CMeditationUI)thePlayer.getMeditation()).NewMeditate();			
	}

	else
	{
		wrappedMethod();
	}
}

///// playerInput.ws /////
@wrapMethod(CPlayerInput) function OnMeditationAbort(action : SInputAction)
{
	var imInstalled : bool;
	
	if( StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('ImmersiveCamPositionsMeditation', 'medRotSpeed') ) >= 0.1 )
		imInstalled = true;
		
	if( ((CMeditationUI)thePlayer.getMeditation()).getMedMenuBool() && imInstalled )
	{
		((CMeditationUI)thePlayer.getMeditation()).NewMeditate();
	}
	wrappedMethod(action);
}

///// playerInput.ws /////
@addMethod(W3PlayerWitcher) timer function IM_Clock( dt : float, id : int ) 
{ 
	((CMeditationUI)thePlayer.getMeditation()).ClockFix(); 
}

@addMethod(W3PlayerWitcher) timer function IM_Unblock( dt : float, id : int ) 
{ 
	if ( GetWitcherPlayer().GetCurrentStateName() != 'Meditation' )
	{
		((CMeditationUI)thePlayer.getMeditation()).UnblockFix();
	}
	else
	{
		thePlayer.AddTimer('IM_Unblock', 0.2, false);
	}
}

///// r4player.ws /////
@addField(CR4Player)
public var mImmersive : CMeditationImmersive;

@addField(CR4Player)
public editable var mMeditation : CMeditationUI;

@addMethod(CR4Player) timer function SetMeditationVars(dt : float, id : int)
{
	mImmersive.SetMeditationVars();
}
	
@addMethod(CR4Player) public function getMeditation() : CMeditationUI
{
	return this.mMeditation;
}
	
@addMethod(CR4Player) public function setMeditation( mMeditation : CMeditationUI)
{
	this.mMeditation = mMeditation;
}
	
@addMethod(CR4Player) timer function BeginNewMeditation(dt : float, id : int)
{
	this.mMeditation.NewMeditate();
}
	
@addMethod(CR4Player) public function UpdateCameraMeditation( out moveData : SCameraMovementData, timeDelta : float )
{
	theGame.GetGameCamera().ChangePivotRotationController( 'ExplorationInterior' );
	theGame.GetGameCamera().ChangePivotDistanceController( 'Default' );
	theGame.GetGameCamera().ChangePivotPositionController( 'Default' );

	// HACK
	moveData.pivotRotationController = theGame.GetGameCamera().GetActivePivotRotationController();
	moveData.pivotDistanceController = theGame.GetGameCamera().GetActivePivotDistanceController();
	moveData.pivotPositionController = theGame.GetGameCamera().GetActivePivotPositionController();
	// END HACK
		
	moveData.pivotPositionController.SetDesiredPosition( GetWorldPosition(), 15.f );

	moveData.pivotDistanceController.SetDesiredDistance( 3.0 );
	moveData.pivotPositionController.offsetZ = 0.3f;
	
	DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( mImmersive.medOffset , mImmersive.medDepth, mImmersive.medHeight  ), 0.6, timeDelta );
}

///// campfire.ws /////
@addField(W3Campfire)
public var customCampfire : W3Campfire;

@addMethod(W3Campfire) public function setCampfire(fire : W3Campfire)
{
	this.customCampfire = fire;
}

@addMethod(W3Campfire) public function getCampfire() : W3Campfire
{
	return this.customCampfire;
}

@addMethod(W3Campfire) timer function Light(dt : float, id : int)
{
	if (thePlayer.GetCurrentStateName() == 'Meditation' || thePlayer.GetCurrentStateName() == 'MeditationWaiting')
	{
		this.customCampfire.ToggleFire( true );
	}
}

@addMethod(W3Campfire) timer function UnLight(dt : float, id : int)
{
	if (thePlayer.GetCurrentStateName() == 'Meditation' || thePlayer.GetCurrentStateName() == 'MeditationWaiting')
	{
		this.customCampfire.ToggleFire( false );	
	}
	AddTimer('Despawn',5.0,false); // number in here (5.0 by default) changes how long it takes for the fire to despawn
}

@addMethod(W3Campfire) timer function Despawn(dt : float, id : int)
{
	// This makes the fire despawn only when its not on fire, if you want it to despawn even when on fire, then comment out this if
	if(!this.customCampfire.IsOnFire()) // add // infront of the if and and the { } signs and it will despawn even when its on fire
	{
		((CEntity)this.customCampfire).Destroy();	
	}
}