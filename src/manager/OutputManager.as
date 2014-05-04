package manager {
    import com.adobe.images.PNGEncoder;

    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import flash.utils.ByteArray;

    import flash.utils.Dictionary;
    import flash.utils.setTimeout;

    import vo.FrameVO;

    import vo.FrameVO;

    import vo.ResourceVO;

    /**
     * 模块说明
     * @author Zhangziran
     * @date 14-2-11.
     */
    public class OutputManager {
        public static function savePNG(rs:ResourceVO):void {
            rs.pngDirPath = rs.f.parent.nativePath + '/' + rs.f.name + '_temp';
            rs.pngDirPath = rs.pngDirPath.replace(/\\/g, "/");
            var configDic:Dictionary = new Dictionary();
            var configFiles:Dictionary = new Dictionary();
            if (rs.type == "r") {
                for (var action:String in rs.frames) {
                    for each (var temp_dic:Array in rs.frames[action]) {
                        configDic[action] = "var " + action + "_l:int = " + temp_dic.length + ";";
                        break;
                    }
                    configFiles[action] = [];
                    var dic:Dictionary = rs.frames[action];
                    for each (var vos:Array in dic) {
                        for (var i:int = 0, len:int = vos.length; i < len; i++) {
                            var frame2:FrameVO = vos[i];
                            FileManager.inciseIMG(frame2);
                            saveItem(frame2);
                            configDic[action] += "var " + frame2.name + "_x:int = " + frame2.offsetX + ";";
                            configDic[action] += "var " + frame2.name + "_y:int = " + frame2.offsetY + ";";
                            configDic[action] += "var " + frame2.name + "_h:int = " + 4 + ";";
                            configFiles[action].push(frame2);
                        }
                    }
                }
            }
            rs.configs = configDic;
            rs.configFile = configFiles;

            function saveItem(frame:FrameVO):void {
                var byt:ByteArray = PNGEncoder.encode(frame.bitmapData);
                var file:File = new File(rs.pngDirPath + '/' + frame.name + '.png');
                var myFileStream:FileStream = new FileStream();
                myFileStream.open(file, FileMode.WRITE);
                myFileStream.writeBytes(byt, 0, byt.length);
            }
        }

        public static function output(rss:Array, skin_id:int):void {
            for (var i:int = 0; i < rss.length; i++) {
                var rs:ResourceVO = rss[i];
                var num:int = 0;
                for (var action:String in rs.configs) {
                    var config:String = rs.configs[action];
                    var files:Array = rs.configFile[action];

                    var jsflTemplate:String = FileManager.jsflTemplate.concat();
                    jsflTemplate = jsflTemplate.replace("${dirs}", '"' + rs.pngDirPath + '"');
                    jsflTemplate = jsflTemplate.replace("${actions}", '"' + action + '"');
                    jsflTemplate = jsflTemplate.replace("${exportName}", '"' + skin_id + "_" + action + '"');
                    config = "var action:String='" + action + "';" + config;

                    jsflTemplate = jsflTemplate.replace("${configs}", '"' + config + '"');
                    var file:File = new File(rs.pngDirPath + "/" + action + ".jsfl");
                    var stream:FileStream = new FileStream();
                    stream.open(file, FileMode.WRITE);
                    stream.writeMultiByte(jsflTemplate, "utf8");
                    stream.close();

                    var file2:File = new File(rs.pngDirPath + "/swfs");
                    if (!file2.exists) {
                        file2.createDirectory();
                    }
                    setTimeout(function (item:File):void {
                        item.openWithDefaultApplication();
                    }, num * 30000, file);
                    num++;
                }
            }
        }
    }
}
