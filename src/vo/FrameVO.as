package vo {
    import flash.display.BitmapData;
    import flash.filesystem.File;
    import flash.utils.Dictionary;

    /**
     * 模块说明
     * @author Zhangziran
     * @date 14-2-11.
     */
    public class FrameVO {
        public var type:int;
        public var f:File;
        public var name:String;
        public var reverse:Boolean;
        public var bitmapData:BitmapData;
        public var offsetX:int;
        public var offsetY:int;
        public var frames:Dictionary = new Dictionary();
    }
}
