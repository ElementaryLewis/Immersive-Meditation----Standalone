/* Immersive Meditation Control Script v 4.0 */

class CMeditationImmersive
{
	/* ------ IMMERSIVE MEDITATION CONFIGURATION START --------------------------------------------------	
	Edit the default values as desired, but remember that small changes make big differences.
	For some variables, only certain values are valid.  Those values are explained in the variable's comments.
	-------------------------------------------------------------------------------------------- */
	
	//--- CAMERA CONFIGURATIONS ---
	
	// Exploration Camera
	default expOffset 		= 0.0;		// increase = right   |  decrease = left  		( vanilla 0.0 ) 
	default expDepth 		= 0.0;		// increase = zoom in |  decrease = zoom out 	( vanilla 0.0 )
	default expHeight 		= 0.0;		// increase = higher  |  decrease = lower  		( vanilla 0.0 )  
	
	// Interior Camera
	default noInteriorCamChange = false; // true = exploration cam does not change upon entering buildings 
	
	//The following interior camera settings are not used if noInteriorCamChange = true
	default intOffset 		= 0.3;		// increase = right   |  decrease = left		 ( vanilla 0.3 )
	default intDepth 		= 2.8;		// increase = zoom in |  decrease = zoom out	 ( vanilla 2.8 )
	default intHeight 		= 0.0;		// increase to raise  |  decrease to lower		 ( vanilla 0.0 )
	
	/////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////
	// --- IMMERSIVE MEDITATION CONFIGURATION
	
	default medOffset		= -0.6;	// increase = right   |  decrease = left
	default medDepth		= 1.5;		// increase = zoom in |  decrease = zoom out
	default medHeight		= 0.6;		// increase = higher  |  decrease = lower
	
	default medEndFacing	= 240;		// This number determines the ending camera facing during meditation.  180 = the camera facing straight back 
	default medRotSpeed		= 0.3;		// The higher this number, the faster the camera rotates to your end facing target
	default medPitch		= -1.0;		// Negative numbers set the camera to look down on Geralt.  Positive numbers set the camera to look up at Geralt.
	default medHPS			= 3.0;		// The number of game hours passed per real time second of meditation.
	default useCampfire		= false;		// Set to false to prevent Geralt from making a campfire when meditating outside.
	default medFreeCam		= false;	// Set to true to allow free control of the camera rotation during meditation.
	
	/* ---- IMMERSIVE IMMERSIVE CONFIGURATION END (DO NOT CHANGE ANYTHING BELOW THIS LINE) -----    */
	
	////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////

	public var useCampfire, medFreeCam														: bool;
	public var noInteriorCamChange															: bool;
	public var expOffset, expDepth, expHeight 												: float;
	public var intOffset, intDepth, intHeight 												: float;
	public var medOffset, medDepth, medHeight, medRotSpeed, medPitch, medEndFacing, medHPS	: float;
	public var sprintMode, sprintOffset, sprintDepth, sprintHeight							: float;
	
	private var igconfig					: CInGameConfigWrapper;
	
	private function InitializeMenuSettings()
	{
		igconfig = theGame.GetInGameConfigWrapper();
		
		igconfig.SetVarValue('ImmersiveCamPositionsExploration', 'noInteriorCamChange', noInteriorCamChange);
		igconfig.SetVarValue( 'ImmersiveCamPositionsExploration', 'expOffset', FloatToString( expOffset ) ); 
		igconfig.SetVarValue( 'ImmersiveCamPositionsExploration', 'expDepth', FloatToString( expDepth ) ); 
		igconfig.SetVarValue( 'ImmersiveCamPositionsExploration', 'expHeight', FloatToString( expHeight ) ); 
		igconfig.SetVarValue( 'ImmersiveCamPositionsExploration', 'intDepth', FloatToString( intDepth ) ); 
		igconfig.SetVarValue( 'ImmersiveCamPositionsExploration', 'intOffset', FloatToString( intOffset ) ); 
		igconfig.SetVarValue( 'ImmersiveCamPositionsExploration', 'intHeight', FloatToString( intHeight ) );
		
		igconfig.SetVarValue( 'ImmersiveCam', 'v42Initialized', true); 
	}
	
	public function SetMeditationVars()
	{
		InitializeImmersiveMeditation();
		
		// If values already exist in user.settings, read and set those values in icControl.
		// If the values are missing, the GUI is not set, so set it.
		if ( !igconfig.GetVarValue('ImmersiveCam', 'v42Initialized') )  
		{
			InitializeMenuSettings();
			return;
		}
		
		noInteriorCamChange = igconfig.GetVarValue('ImmersiveCamPositionsExploration', 'noInteriorCamChange');
		expOffset = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'expOffset' ) );
		expDepth = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'expDepth' ) );
		expHeight = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'expHeight' ) );
		intDepth = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'intDepth' ) );
		intOffset = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'intOffset' ) );
		intHeight = StringToFloat( igconfig.GetVarValue( 'ImmersiveCamPositionsExploration', 'intHeight' ) );
	}
	
	private function InitializeImmersiveMeditation()
	{
		if( StringToFloat( igconfig.GetVarValue('ImmersiveCamPositionsMeditation', 'medRotSpeed') ) >= 0.1 )
		{
			medFreeCam = igconfig.GetVarValue('ImmersiveCamPositionsMeditation', 'medFreeCam');
			useCampfire = igconfig.GetVarValue('ImmersiveCamPositionsMeditation', 'useCampfire');
			medOffset = StringToFloat( igconfig.GetVarValue('ImmersiveCamPositionsMeditation', 'medOffset') );
			medDepth = StringToFloat( igconfig.GetVarValue('ImmersiveCamPositionsMeditation', 'medDepth') );
			medHeight = StringToFloat( igconfig.GetVarValue('ImmersiveCamPositionsMeditation', 'medHeight') );
			medPitch = StringToFloat( igconfig.GetVarValue('ImmersiveCamPositionsMeditation', 'medPitch') );
			medEndFacing = StringToFloat( igconfig.GetVarValue('ImmersiveCamPositionsMeditation', 'medEndFacing') );
			medRotSpeed = StringToFloat( igconfig.GetVarValue('ImmersiveCamPositionsMeditation', 'medRotSpeed') );
			medHPS = StringToFloat( igconfig.GetVarValue('ImmersiveCamPositionsMeditation', 'medHPS') );
		}
		else
		{
			igconfig.SetVarValue('ImmersiveCamPositionsMeditation', 'medFreeCam', medFreeCam );
			igconfig.SetVarValue('ImmersiveCamPositionsMeditation', 'useCampfire', useCampfire );
			igconfig.SetVarValue('ImmersiveCamPositionsMeditation', 'medOffset', FloatToString( medOffset ) );
			igconfig.SetVarValue('ImmersiveCamPositionsMeditation', 'medDepth', FloatToString( medDepth ) );
			igconfig.SetVarValue('ImmersiveCamPositionsMeditation', 'medHeight', FloatToString( medHeight ) );
			igconfig.SetVarValue('ImmersiveCamPositionsMeditation', 'medPitch', FloatToString( medPitch ) );
			igconfig.SetVarValue('ImmersiveCamPositionsMeditation', 'medEndFacing', FloatToString( medEndFacing ) );
			igconfig.SetVarValue('ImmersiveCamPositionsMeditation', 'medRotSpeed', FloatToString( medRotSpeed ) );
			igconfig.SetVarValue('ImmersiveCamPositionsMeditation', 'medHPS', FloatToString( medHPS ) );
		}
	}
	
	public function RegisterMeditationVars( init : bool )  
	{
		if( !igconfig )
			igconfig = theGame.GetInGameConfigWrapper();
			
		if ( init )
			SetMeditationVars();
		else
			thePlayer.AddTimer('SetMeditationVars', 0.5, false);
	}
	
	public function mImmersiveInit()
	{
		RegisterMeditationVars( true );
	}
}

/***********************************************************************/
/** Author : Erxv
/***********************************************************************/

class CMeditationUI extends CPlayerInput
{
	private var fire : W3Campfire;
	private var medMenuBool : bool;
	private var waitStartTime : GameTime;
	private var actionDelay : bool;
	public var passedSecondsInGameTime 	: Float;
	public var passedSecondsInRealTime 	: Float;
	default medMenuBool = false;	
	
	public function getWaitStartTime() : GameTime
	{
		return this.waitStartTime;
	}
	public function getPassedSecondsInGameTime() : float
	{
		return this.passedSecondsInGameTime;
	}
	public function getPassedSecondsInRealTime() : float
	{
		return this.passedSecondsInRealTime;
	}
	public function getMedMenuBool() : bool
	{
		return this.medMenuBool;
	}
	public function setMedMenuBool(a : bool)
	{
		this.medMenuBool = a;
	}
	public function GetCampFire() : W3Campfire
	{
		return this.fire;
	}
	public function setCampFire(fire : W3Campfire) 
	{
		this.fire = fire;
	}
	
	public function NewMeditate()
	{			
		var pos : Vector;
		var rot : EulerAngles;
		var template : CEntityTemplate;
		var z : float;

		var medFreeCam, useCampfire : bool;
		medFreeCam = thePlayer.mImmersive.medFreeCam;
		useCampfire = thePlayer.mImmersive.useCampfire;

		//RovanFrost Fix
		if ( actionDelay )
			return;
		//RovanFrost Fix
		
		if(!this.medMenuBool)
		{
			//theGame.GetGuiManager().ShowNotification("Start");
			waitStartTime = theGame.GetGameTime();
			theGame.RequestMenuWithBackground( 'MeditationClockMenu', 'MeditationClockMenu' );			
			thePlayer.EnableManualCameraControl( medFreeCam, 'Finisher' );
			
			GetWitcherPlayer().Meditate();
			thePlayer.BlockAction(EIAB_RunAndSprint, 'InCombat' );
			thePlayer.BlockAction(EIAB_Movement, 'InCombat' );
			thePlayer.BlockAction(EIAB_DrawWeapon, 'InCombat' );
			thePlayer.BlockAction(EIAB_RadialMenu, 'InCombat' );
			thePlayer.BlockAction(EIAB_QuickSlots, 'InCombat' );
			thePlayer.BlockAction(EIAB_CallHorse,			'InCombat');
			thePlayer.BlockAction(EIAB_Signs,				'InCombat');
			thePlayer.BlockAction(EIAB_Crossbow,			'InCombat');
			thePlayer.BlockAction(EIAB_UsableItem,			'InCombat');
			thePlayer.BlockAction(EIAB_ThrowBomb,			'InCombat');
			thePlayer.BlockAction(EIAB_SwordAttack,			'InCombat');
			thePlayer.BlockAction(EIAB_Jump,				'InCombat');
			thePlayer.BlockAction(EIAB_Roll,				'InCombat');
			thePlayer.BlockAction(EIAB_Dodge,				'InCombat');
			thePlayer.BlockAction(EIAB_LightAttacks,		'InCombat');
			thePlayer.BlockAction(EIAB_HeavyAttacks,		'InCombat');
			thePlayer.BlockAction(EIAB_SpecialAttackLight,	'InCombat');
			thePlayer.BlockAction(EIAB_SpecialAttackHeavy,	'InCombat');
			
			this.medMenuBool = true;
			
			if( !useCampfire )
				return;
			
			template = (CEntityTemplate)LoadResource( "environment\decorations\light_sources\campfire\campfire_01.w2ent", true);
			pos = thePlayer.GetWorldPosition() + VecFromHeading( thePlayer.GetHeading() ) * Vector(0.8, 0.8, 0);
			if( theGame.GetWorld().NavigationComputeZ( pos, pos.Z - 128, pos.Z + 128, z ) )
			{
				pos.Z = z;
			}
			if( theGame.GetWorld().PhysicsCorrectZ( pos, z ) )
			{
				pos.Z = z;
			}
			rot = thePlayer.GetWorldRotation();
			if( !thePlayer.IsInInterior() )
			{
				fire = (W3Campfire)theGame.CreateEntity(template, pos, rot);
				((W3Campfire)fire).setCampfire(fire);
				((W3Campfire)fire).AddTimer('Light',4.9,false);
			}
		}
		else
		{		
			
			thePlayer.EnableManualCameraControl( true, 'Finisher' );		
			GetWitcherPlayer().MeditationForceAbort(true);
			
			if( !useCampfire )
			{
				this.medMenuBool = false;
				//RovanFrost Fix
				thePlayer.AddTimer('IM_Unblock', 0.2f, false);
				actionDelay = true;
				//RovanFrost Fix
				return;
			}
				
			passedSecondsInGameTime = GameTimeToSeconds(theGame.GetGameTime() - waitStartTime);
			passedSecondsInRealTime = ConvertGameSecondsToRealTimeSeconds(passedSecondsInGameTime);
			if (passedSecondsInRealTime > 7.0)
			{
				((W3Campfire)fire).AddTimer('UnLight',1.7,false);
			}
			else
			{
				((W3Campfire)fire).AddTimer('UnLight',(8.7-passedSecondsInRealTime),false);
			}	
			this.medMenuBool = false;
			//RovanFrost Fix
			thePlayer.AddTimer('IM_Unblock', 0.2f, false);
			actionDelay = true;
			//RovanFrost Fix
		}
	}
	
	//RovanFrost Fix
	public function ClockFix()
	{
		if ( GetWitcherPlayer().GetCurrentStateName() == 'Meditation' && medMenuBool )
		{
			if ( theGame.GetGuiManager().IsAnyMenu() || theGame.IsBlackscreenOrFading() )
			{
				thePlayer.AddTimer('IM_Clock', 0.2f, false);
			}
			else
			{ 
				theGame.RequestMenu( 'MeditationClockMenu' ); 
			}
		}
	}
	
	public function UnblockFix()
	{
		thePlayer.UnblockAction(EIAB_QuickSlots, 'InCombat' );
		thePlayer.UnblockAction(EIAB_RunAndSprint, 'InCombat' );
		thePlayer.UnblockAction(EIAB_Movement, 'InCombat' );
		thePlayer.UnblockAction(EIAB_DrawWeapon, 'InCombat' );
		thePlayer.UnblockAction(EIAB_RadialMenu, 'InCombat' );
		thePlayer.UnblockAction(EIAB_CallHorse,			'InCombat');
		thePlayer.UnblockAction(EIAB_Signs,				'InCombat');
		thePlayer.UnblockAction(EIAB_Crossbow,			'InCombat');
		thePlayer.UnblockAction(EIAB_UsableItem,			'InCombat');
		thePlayer.UnblockAction(EIAB_ThrowBomb,			'InCombat');
		thePlayer.UnblockAction(EIAB_SwordAttack,			'InCombat');
		thePlayer.UnblockAction(EIAB_Jump,				'InCombat');
		thePlayer.UnblockAction(EIAB_Roll,				'InCombat');
		thePlayer.UnblockAction(EIAB_Dodge,				'InCombat');
		thePlayer.UnblockAction(EIAB_LightAttacks,		'InCombat');
		thePlayer.UnblockAction(EIAB_HeavyAttacks,		'InCombat');
		thePlayer.UnblockAction(EIAB_SpecialAttackLight,	'InCombat');
		thePlayer.UnblockAction(EIAB_SpecialAttackHeavy,	'InCombat');
		actionDelay = false;
	}
	//RovanFrost Fix
}
