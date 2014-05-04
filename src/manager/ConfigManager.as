package manager {
	import flash.utils.Dictionary;

	public class ConfigManager {
		public static var frameRate:int;
        public static var offsetX:int;
        public static var offsetY:int;

		public static var actionNames:Dictionary = new Dictionary; //文件夹名对应的动作名
        public static var dirNames:Dictionary = new Dictionary();
		public static var englishActionDic:Dictionary = new Dictionary; //可识别的参照物动作
		public static var englishActionArr:Array = new Array; //可识别的参照物动作

		public static function parseConfig(config:XML):void {
			frameRate = int(config.set[0].@frameRate);
			offsetX = int(config.set[0].@centerX);
			offsetY = int(config.set[0].@centerY);

            for each (var dir:XML in XML(config.dirs[0]).children()) {
                dirNames[String(dir.@label)] = String(dir.@data);
            }
			for each (var action:XML in XML(config.actions[0]).children()) {
				actionNames[String(action.@label)] = String(action.@data);
			}
			for each (var ref:XML in XML(config.englishAction[0]).children()) {
				var obj:Object = {label: String(ref.@label), data: String(ref.@data),sort:int(ref.@sort)};
				englishActionArr.push(obj);
				englishActionDic[String(ref.@data)] = obj;
			}
		}
	}
}