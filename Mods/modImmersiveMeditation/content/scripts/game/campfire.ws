/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



 

class W3Campfire extends CGameplayEntity
{
	editable var dontCheckForNPCs : bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( !dontCheckForNPCs )
		{
			AddTimer('CheckForNPCs', 3.0, true);
		}
	}

	event OnDestroyed()
	{
		if( !dontCheckForNPCs )
		{
			RemoveTimer('CheckForNPCs');
		}
	}
	
		
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		if ( activator == thePlayer && interactionComponentName == "ApplyDamage" )
		{
			ApplyDamage ();
			AddTimer ( 'ApplyDamageTimer', 3.0f, true );
		}
	}
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		if ( activator == thePlayer && interactionComponentName == "ApplyDamage"  )
		{
			RemoveTimer ( 'ApplyDamageTimer' );
		}
	}
	
	function ApplyDamage ()
	{
		if ( IsOnFire() )
		{
			thePlayer.AddEffectDefault(EET_Burning, this, 'environment');
		}
	}
	
	timer function ApplyDamageTimer ( dt : float, id : int )
	{
		ApplyDamage ();
	}
	
	timer function CheckForNPCs( dt : float, id : int )
	{
		var range : float;
		var entities : array< CGameplayEntity >;
		var i : int;
		var actor : CActor;

		
		range = 30.f;
		if ( VecDistanceSquared( GetWorldPosition(), thePlayer.GetWorldPosition() ) <= range*range )
			return;

		FindGameplayEntitiesInRange(entities, this, 20.0, 10,, 2);

		
		if ( entities.Size() == 0 )
		{
			ToggleFire( false );		
		}
		else
		{
			
			for ( i = 0; i < entities.Size(); i+=1 )
			{
				actor = (CActor)entities[i];

				
				if ( actor.IsHuman() )
				{
					ToggleFire( true );
					return;
				}
			}
			
			
			
			ToggleFire( false );
		}
	}

	function IsOnFire () : bool
	{
		var gameLightComp : CGameplayLightComponent;		
		gameLightComp = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');
		
		return gameLightComp.IsLightOn();
	}
	
	function ToggleFire( toggle : bool )
	{
		var gameLightComp : CGameplayLightComponent;		
		gameLightComp = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');

		if(gameLightComp)
			gameLightComp.SetLight( toggle );		
	}
	//	Immersive Meditation++
	public var customCampfire : W3Campfire;
	public function setCampfire(fire : W3Campfire)
	{
		this.customCampfire = fire;
	}
	public function getCampfire() : W3Campfire
	{
		return this.customCampfire;
	}
	timer function Light(dt : float, id : int)
	{
		if (thePlayer.GetCurrentStateName() == 'Meditation' || thePlayer.GetCurrentStateName() == 'MeditationWaiting')
		{
			this.customCampfire.ToggleFire( true );
		}
	}
	timer function UnLight(dt : float, id : int)
	{
		if (thePlayer.GetCurrentStateName() == 'Meditation' || thePlayer.GetCurrentStateName() == 'MeditationWaiting')
		{
			this.customCampfire.ToggleFire( false );	
		}
		AddTimer('Despawn',5.0,false); // number in here (5.0 by default) changes how long it takes for the fire to despawn
	}	
	timer function Despawn(dt : float, id : int)
	{
		// This makes the fire despawn only when its not on fire, if you want it to despawn even when on fire, then comment out this if
		if(!this.customCampfire.IsOnFire()) // add // infront of the if and and the { } signs and it will despawn even when its on fire
		{
			((CEntity)this.customCampfire).Destroy();	
		}
	}	
	//	Immersive Meditation--
}	
