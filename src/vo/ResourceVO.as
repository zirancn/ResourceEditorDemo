package vo {
    import flash.filesystem.File;
    import flash.utils.Dictionary;

    /**
     * 模块说明
     * @author Zhangziran
     * @date 14-2-11.
     */
    public class ResourceVO {
        public var type:String;
        public var f:File;
        public var loaded:Function;
        public var pngDirPath:String;
        public var frames:Dictionary = new Dictionary();
        public var configs:Dictionary;
        public var configFile:Dictionary;
    }
}
