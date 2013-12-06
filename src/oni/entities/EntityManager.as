package oni.entities 
{
	import flash.geom.Point;
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.util.Debug;
	import oni.assets.AssetManager;
	import oni.core.ISerializable;
	import oni.Oni;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.space.Space;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class EntityManager extends EventDispatcher implements ISerializable
	{
		/**
		 * The physics time step
		 */
		public static var TIME_STEP:Number = 1 / 30;
		
		/**
		 * The physics data for props
		 */
		public static var PHYSICS_DATA:Object;
		
		/**
		 * A list of current entities
		 */
		public var entities:Vector.<Entity>;
		
		/**
		 * The physics space
		 */
		private var _space:Space;
		
		/**
		 * Whether the entities should update or not
		 */
		private var _paused:Boolean;
		
		/**
		 * Creates an entity manager instance, with physics enabled or not
		 * @param	physics
		 * @param	gravity
		 */
		public function EntityManager(physics:Boolean=true, gravity:Vec2=null) 
		{
			//Create an entities vector
			entities = new Vector.<Entity>();
			
			//Setup physics
			if (physics) setupPhysics(gravity);
			
			//Listen for update
			addEventListener(Oni.UPDATE, _onUpdate);
			
			//Listen for events to relay
			addEventListener(Oni.ENABLE_DEBUG, _relayEvent);
			addEventListener(Oni.DISABLE_DEBUG, _relayEvent);
		}
		
		/**
		 * Sets up a physics space with the given parameters
		 * @param	gravity
		 */
		public function setupPhysics(gravity:Vec2=null):void
		{
			//Load physics data
			if (EntityManager.PHYSICS_DATA == null) EntityManager.PHYSICS_DATA = AssetManager.getJSON("physics_data");
			
			//Set default gravity
			if (gravity == null) gravity = new Vec2(0, 600);
			
			//Check if we already have a physics space
			if (_space != null)
			{
				//Clear and set gravity
				_space.clear();
				_space.gravity = gravity;
			}
			else
			{
				//Create a physics space
				_space = new Space(new Vec2(0, 600));
			
				//Create collision interaction listeners
				_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CbType.ANY_BODY, CbType.ANY_BODY, _onCollisionInteraction));
				_space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.COLLISION, CbType.ANY_BODY, CbType.ANY_BODY, _onCollisionInteraction));
				
				//Create sensor interaction listeners
				_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, CbType.ANY_BODY, CbType.ANY_BODY, _onSensorInteraction));
				_space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.SENSOR, CbType.ANY_BODY, CbType.ANY_BODY, _onSensorInteraction));
			}
		}
		
		/**
		 * Called when there is a collision interaction
		 * @param	callback
		 */
		private function _onCollisionInteraction(callback:InteractionCallback):void
		{
			//Get contacts
			var a:PhysicsEntity = callback.int1.userData.entity;
			var b:PhysicsEntity = callback.int2.userData.entity;
			
			//Set data
			var data:Object = { type: InteractionType.COLLISION, event: callback.event, arbiters: callback.arbiters, a: a, b: b };
			
			//Callback
			a.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
			b.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
		}
		
		/**
		 * Called when there is a sensor interaction
		 * @param	callback
		 */
		private function _onSensorInteraction(callback:InteractionCallback):void
		{
			//Get contacts
			var a:PhysicsEntity = callback.int1.userData.entity;
			var b:PhysicsEntity = callback.int2.userData.entity;
			
			//Set data
			var data:Object = { type:InteractionType.SENSOR, event: callback.event, arbiters: callback.arbiters, a: a, b: b };
			
			//Callback
			a.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
			b.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
		}
		
		/**
		 * Whether physics are enabled or not
		 */
		public function get physicsEnabled():Boolean
		{
			return _space != null;
		}
		
		/**
		 * Whether physics are enabled or not
		 */
		public function set physicsEnabled(value:Boolean):void
		{
			if (physicsEnabled && !value)
			{
				//Disable
				_space.clear();
				_space = null;
			}
			else if (value)
			{
				//Enable
				setupPhysics();
			}
		}
		
		/**
		 * Called when the engine updates
		 * @param	e
		 */
		private function _onUpdate(e:Event):void
		{
			//Only if not paused
			if (!_paused)
			{
				//Step physics
				if (_space != null) _space.step(TIME_STEP);
				
				//Relay
				_relayEvent(e);
			}
		}
		
		/**
		 * Relays an event to all entities
		 * @param	e
		 */
		private function _relayEvent(e:Event):void
		{
			//Relay event to all entities
			for (var i:uint = 0; i < entities.length; i++)
			{
				entities[i].dispatchEvent(e);
			}
		}
		
		/**
		 * Adds an entity, if silent it won't dispatch an added event
		 * @param	entity
		 * @param	silent
		 * @return
		 */
		public function add(entity:Entity, silent:Boolean=false):Entity
		{
			//Dispatch added event
			entity.dispatchEventWith(Oni.ENTITY_ADDED, false, { manager:this, space: _space } );
			
			//Add to list
			entities.push(entity);
			
			//Dispatch event
			if(!silent) dispatchEventWith(Oni.ENTITY_ADDED, false, { entity:entity } );
			
			//Return
			return entity;
		}
		
		/**
		 * Removes an entity, if silent it won't dispatch a removed event
		 * @param	entity
		 * @param	silent
		 * @return
		 */
		public function remove(entity:Entity, silent:Boolean=false):void
		{
			//Dispatch removed event
			entity.dispatchEventWith(Oni.ENTITY_REMOVED, false, { manager:this } );
			
			//Remove
			entities.splice(entities.indexOf(entity), 1);
			
			//Dispatch event
			if(!silent) dispatchEventWith(Oni.ENTITY_REMOVED, false, { entity:entity } );
		}
		
		/**
		 * Removes all entities, if silent it won't dispatch a removed event
		 * @param	silent
		 */
		public function removeAll(silent:Boolean=false):void
		{
			//Remove all entities
			for (var i:int = 0; i < entities.length; i++) remove(entities[i], silent);
		}
		
		/**
		 * Gets an entity by index
		 * @param	index
		 * @return
		 */
		public function get(index:int):Entity
		{
			return entities[index];
		}
		
		/**
		 * Whether the entities should update or not
		 */
		public function get paused():Boolean
		{
			return _paused;
		}
		
		/**
		 * Whether the entities should update or not
		 */
		public function set paused(value:Boolean):void
		{
			_paused = value;
		}
		
		/**
		 * Serializes data to an object
		 * @return
		 */
		public function serialize():Object
		{
			var data:Array = new Array();
			for (var i:uint = 0; i < entities.length; i++)
			{
				data.push(entities[i].serialize());
			}
			return data;
		}
		
	}

}