package oni
{
	import oni.Oni;
	import oni.utils.Backend;
	import oni.utils.Platform;
    //import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import starling.core.Starling;
    import starling.utils.RectangleUtil;
    import starling.utils.ScaleMode;
	
	/**
	 * The startup class, your main/document class should extend this.
	 * @author Sam Hellawell
	 */
	public class Startup extends Sprite
	{
		/**
		 * The class we use for the engine
		 */
		public static var StartupClass:Class = Oni;
		
		/**
		 * The starling instance
		 */
		private var _starling:Starling;
		
		/**
		 * Initialiser
		 */
		public function Startup(stageWidth:int=960, stageHeight:int=540) 
		{
			//Set target dimensions
			Platform.STAGE_WIDTH = stageWidth;
			Platform.STAGE_HEIGHT = stageHeight;
			
			//Setup the stage
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//Setup starling
			Starling.multitouchEnabled = true;
			Starling.handleLostContext = Platform.isAndroid();
			
			//Get the stage dimensions
			var stageWidth:int = stage.stageWidth;
			var stageHeight:int = stage.stageHeight;
			
			//Check if mobile and set screen dimensions
			if (Platform.isMobile())
			{
				stageWidth = stage.fullScreenWidth;
				stageHeight = stage.fullScreenHeight;
			}
			
			//Check if we're an iPad, if so, set minimum stage dimensions
			if (stageWidth == 1024 || stageWidth == 2048)
			{
				Platform.STAGE_WIDTH = 1024;
				Platform.STAGE_HEIGHT = 768;
			}
			
			//Set viewport
			var viewport:Rectangle = RectangleUtil.fit(new Rectangle(0, 0, Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT), 
													   new Rectangle(0, 0, stageWidth, stageHeight), 
													   ScaleMode.SHOW_ALL);
													  
			//Create instance
			_starling = new Starling(StartupClass, stage, viewport);
			_starling.antiAliasing = 1;
            _starling.simulateMultitouch = false;
			_starling.showStats = Platform.debugEnabled;
            _starling.enableErrorChecking = Platform.debugEnabled;
			_starling.stage.stageWidth  = Platform.STAGE_WIDTH;
			_starling.stage.stageHeight = Platform.STAGE_HEIGHT;
			
			//test
			_starling.showStats = true;
			
			//Start!
			_starling.start();
			
			//Listen for application activate
            /*NativeApplication.nativeApplication.addEventListener(
                Event.ACTIVATE, function (e:*):void { _starling.start(); });
            
			//Listen for application deactivate
            NativeApplication.nativeApplication.addEventListener(
                Event.DEACTIVATE, function (e:*):void { _starling.stop(true); });*/
		}
	}
	
}