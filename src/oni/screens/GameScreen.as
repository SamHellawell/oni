package oni.screens 
{
	import oni.assets.AssetManager;
	import oni.components.Camera;
	import oni.editor.EditorScreen;
	import oni.core.Scene;
	import oni.entities.EntityManager;
	import oni.screens.GameScreen;
	import flash.geom.Point;
	import oni.Oni;
	import oni.core.Scene;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * A base class for game screens
	 * @author Sam Hellawell
	 */
	public class GameScreen extends Screen
	{
		public var camera:Camera;
		
		public var entities:EntityManager;
		
		private var _scene:Scene;
		
		public function GameScreen(oni:Oni, physics:Boolean=true) 
		{
			//Super
			super(oni, "game");
			
			//Create an entity manager
			entities = new EntityManager(physics);
			components.add(entities);
			
			//Create a camera
			camera = new Camera();
			components.add(camera);
			
			//Listen for entity added and removed
			entities.addEventListener(Oni.ENTITY_ADDED, _entityAdded);
			entities.addEventListener(Oni.ENTITY_REMOVED, _entityRemoved);
			
			//Listen for camera position update
			camera.addEventListener(Oni.UPDATE_POSITION, _updatePosition);
			
			//addChild(new EditorScreen(scene, entities)).visible = true;
		}
		
		public function get paused():Boolean
		{
			return entities.paused;
		}
		
		public function set paused(value:Boolean):void
		{
			entities.paused = value;
		}
		
		/**
		 * Create a scene
		 */
		public function set scene(value:Scene):void
		{
			//Check if we already have a scene
			if (_scene != null)
			{
				//Dispose
				_scene.dispose();
				components.remove(_scene);
			}
			
			//Create a scene instance
			_scene = value;
			
			//Add to components
			components.add(_scene);
			
			//Add to display list
			addChild(_scene);
		}
		
		public function get scene():Scene
		{
			return _scene;
		}
		
		/**
		 * Resets the game
		 */
		public function reset():void
		{
			//Remove all entities
			entities.removeAll();
			
			//Dispose of scene
			if (scene != null)
			{
				scene.dispose();
				components.remove(scene);
				if (contains(scene)) removeChild(scene);
				scene = null;
			}
		}
		
		/**
		 * Called when an entity needs to be added to the scene
		 * @param	e
		 */
		private function _entityAdded(e:Event):void
		{
			//Add to scene
			if(scene != null) scene.addEntity(e.data.entity);
			
			//Relay event
			dispatchEvent(e);
		}
		
		/**
		 * Called when an entity needs to be removed from the scene
		 * @param	e
		 */
		private function _entityRemoved(e:Event):void
		{
			//Remove from scene
			if(scene != null) scene.removeEntity(e.data.entity);
			
			//Relay event
			dispatchEvent(e);
		}
		
		/**
		 * Called when the camera updates its position
		 * @param	e
		 */
		private function _updatePosition(e:Event):void
		{
			//Relay to scene
			if(scene != null) this.scene.dispatchEvent(e);
		}
		
	}

}