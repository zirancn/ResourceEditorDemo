package utils {
    import flash.display.Loader;

    import vo.FrameVO;
    import vo.ResourceVO;

    public class DecodeLoader extends Loader {
        public var targetKey:String;
        public var targetFrame:FrameVO;
        public var frames:Array;
        public var rs:ResourceVO;

        public function DecodeLoader() {
            super();
        }
    }
}