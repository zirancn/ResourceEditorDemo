package manager {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    import mx.controls.Alert;

    import utils.DecodeLoader;

    import vo.FrameVO;
    import vo.ResourceVO;

    /**
     * 模块说明
     * @author Zhangziran
     * @date 14-2-11.
     */
    public class FileManager {
        public static var jsflTemplate:String;
        public static var files:Dictionary;
        public static var offsetX:Number = 256;
        public static var offsetY:Number = 256;

        public static function inciseIMG(frame:FrameVO):void {
            var source:BitmapData = frame.bitmapData;
            var rect:Rectangle = source.getColorBoundsRect(0xff000000, 0x00000000, false);
            if (rect.width == 0 || rect.height == 0) {
                rect.width = 1;
                rect.height = 1;
            }
            var target:BitmapData = new BitmapData(rect.width, rect.height);
            target.copyPixels(source, rect, new Point(0, 0));
            frame.offsetX = rect.x - offsetX;
            frame.offsetY = rect.y - offsetY;
            frame.bitmapData = target;
        }

        public static function inputPNG(f:File, type:String, loaded:Function):void {
            if (files[f.name] == null) {
                var rs:ResourceVO = new ResourceVO();
                rs.loaded = loaded;
                rs.type = type;
                rs.f = f;

                findPNG(rs);
                files[f.name] = rs;
            }
        }

        private static function findPNG(rs:ResourceVO):void {
            find(rs.f, 0, rs);
            var allFrames:Array = [];
            var arr:Array;
            for (var i:String in rs.frames) {
                if (rs.type == "r") {
                    for (var s:String in rs.frames[i]) {
                        arr = rs.frames[i][s] as Array;
                        allFrames = allFrames.concat(arr);
                    }
                }
            }
            loadItem(rs, allFrames);
        }

        private static var decodeLoader:DecodeLoader;

        private static function loadItem(rs:ResourceVO, frames:Array):void { //一次性加载整个文件夹
            if (frames.length > 0) {
                if (!decodeLoader) {
                    decodeLoader = new DecodeLoader();
                    decodeLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onDecodeComplete);
                }
                var frame:FrameVO = frames.shift();
                var fileByte:ByteArray = new ByteArray();
                var fileStream:FileStream = new FileStream();
                var f:File = File(frame.f);
                fileStream.open(f, FileMode.READ);
                fileStream.readBytes(fileByte, 0, fileStream.bytesAvailable);
                fileStream.close();
                decodeLoader.targetKey = frame.f.name;
                decodeLoader.targetFrame = frame;
                decodeLoader.frames = frames;
                decodeLoader.rs = rs;
                decodeLoader.loadBytes(fileByte);
            } else {
                if (rs.loaded != null) {
                    rs.loaded();
                }
            }
        }

        private static function onDecodeComplete(event:Event):void {
            var loaderInfo:LoaderInfo = event.target as LoaderInfo;
            var decodeloader:DecodeLoader = loaderInfo.loader as DecodeLoader;
            var bitmap:Bitmap = loaderInfo.content as Bitmap;
            var bitmapData:BitmapData = bitmap.bitmapData;
            var rs:ResourceVO = decodeloader.rs;
            var frame:FrameVO = decodeloader.targetFrame;
            if (frame.reverse == true) {
                frame.bitmapData = horizontal(bitmapData);
            } else {
                frame.bitmapData = bitmapData;
            }
            loadItem(rs, decodeloader.frames);
        }

        private static function horizontal(bt:BitmapData):BitmapData {
            var bmd:BitmapData = new BitmapData(bt.width, bt.height, true, 0x00000000);
            var mat:Matrix = new Matrix()
            mat.scale(-1, 1);
            mat.tx += bt.width
            bmd.draw(bt, mat);
            return bmd;
        }

        private static function find(file:File, index:int, rs:ResourceVO):void {
            if (file.isDirectory) {
                var files:Array = file.getDirectoryListing();
                files.sort(sortFile);
                for (var i:int = 0; i < files.length; i++) {
                    var fileTemp:File = files[i] as File;
                    if (fileTemp.isDirectory || fileTemp.extension == "png") {
                        find(fileTemp, i, rs);
                    } else { //如果不是PNG并不是文件夹则忽略
                        files.splice(i, 1);
                        i--;
                    }
                }
            } else if (file.extension == "png") {
                //没有指定文件结构的默认动作
                var _dir:String = file.parent.name;
                var _action:String = file.parent.parent.name;
                if (rs.type == "r") {
                    var action:String = ConfigManager.actionNames[_action];
                    var dir:String = ConfigManager.dirNames[_dir];
                    if (dir == "d5" || dir == "d6" || dir == "d7") {
                        switch (dir) {
                            case "d5":
                                dir = "d3";
                                break;
                            case "d6":
                                dir = "d2";
                                break;
                            case "d7":
                                dir = "d1";
                                break;
                        }
                        var reverse:Boolean = true;
                    } else {
                        reverse = false;
                    }
                    var fileName:String = action + "_" + dir + "_" + index;
                    var frame:FrameVO = new FrameVO();
                    frame.f = file;
                    frame.name = fileName;
                    frame.reverse = reverse;
                    rs.frames[action] ||= new Dictionary();
                    rs.frames[action][dir] ||= [];
                    rs.frames[action][dir].push(frame);
                }
            }

            function sortFile(file1:File, file2:File):int {
                var name1:String = file1.name.substring(0, file1.name.indexOf("."));
                var code:int;
                var numIndex:int;
                for (var i:int = 0; i < name1.length; i++) {
                    code = name1.charCodeAt(i);
                    if (code >= 48 && code <= 57) {
                        numIndex = i;
                        break;
                    }
                }
                name1 = name1.substr(numIndex, name1.length);
                numIndex = 0;
                var name2:String = file2.name.substring(0, file2.name.indexOf("."));
                for (var j:int = 0; j < name2.length; j++) {
                    code = name2.charCodeAt(j);
                    if (code >= 48 && code <= 57) {
                        numIndex = j;
                        break;
                    }
                }
                name2 = name2.substr(numIndex, name2.length);
                var fileName1:int = int(name1);
                var fileName2:int = int(name2);
                if (fileName1 < fileName2) {
                    return -1;
                } else if (fileName1 > fileName2) {
                    return 1;
                } else {
                    return 0;
                }
            }
        }
    }
}
