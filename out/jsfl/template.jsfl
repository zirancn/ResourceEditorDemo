fl.outputPanel.clear();

var dom;
var lib;
var dirs = ${dirs};
var configs = ${configs};
var actions = new Array(${actions});
var exportName = ${exportName};

importFolder();

function importFolder() {
	if(dirs.length > 0){
		dom = fl.createDocument();
		lib = dom.library;
		createSWF('file:///' + dirs);
	}else{
		fl.trace('end');
	}
}

function createSWF(folderURL){
var folderContents;
	var fitem, i;
	var txtURL;
	folderContents = FLfile.listFolder(folderURL + "/","files");
	for(i in folderContents){
		fitem = folderContents[i];
		for(action_tmp in actions) {
		action = actions[action_tmp];
			if(fitem.indexOf(action) != -1 ) {
				var inx = fitem.lastIndexOf(".");
				if (inx > 0) {
					var ext = fitem.substr(inx+1).toLowerCase();  //扩展名
					if (ext == "txt"){
						txtURL = folderURL + "/" + fitem;
					}
					if (ext == "jpg" ||ext == "png" || ext == "gif") {
						dom.importFile(folderURL + "/" + fitem, true);
					}
				}
			}
		}
	}
	
	var lenLib = lib.items.length;
	var item;
	for (i=0; i<lenLib; i++) {
		item = lib.items[i];
		if (item.itemType == "bitmap") {
			item.linkageExportForAS = true;
			item.linkageExportInFirstFrame = true;
			item.linkageBaseClass = "flash.display.BitmapData";
			item.compressionType="photo";
			var className = item.name.substr(0, item.name.lastIndexOf("."));
			item.linkageClassName = className;
		}
	}	
	//写入配置文件
	dom.getTimeline().setSelectedFrames(0,1);
	var str = configs;
	dom.getTimeline().layers[0].frames[0].actionScript = str;
	
    //保存SWF
	dom.exportSWF(folderURL+ '/swfs/' + exportName + '.swf');
}
