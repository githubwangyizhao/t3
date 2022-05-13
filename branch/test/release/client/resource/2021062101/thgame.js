var sceneType = "local";
var loadScript = function (list, callback) {
        var loaded = 0;
		var idx = 0;
        var loadNext = function () {

			var url = list[idx];
			url = rootTruePath + url;
			var func = loadSingleScript;
            func(url,idx, function () {
                loaded++;
                setLoadingProgress(loaded,list.length);
                if (loaded >= list.length) {
                    callback();
                }
                else {
					// idx++;
                    // loadNext();
                }
            });
        };

		for(idx = 0; idx < list.length; idx ++)
		{
			loadNext();
		}
    };
    /*返回上级目录路径*/
    function returnLastDir()
    {
    	var curDirPath = window.location.href;
		if(sceneType == "local")
		{
			return "";
		}
		console.log("============" + curDirPath);
    	var dirArr = curDirPath.split("/");
    	var lastDirPath = "";
    	for (var i = 0; i < dirArr.length; i++) {
    		if (i < dirArr.length - 2) 
    		{
    			lastDirPath = lastDirPath + dirArr[i] + "/";
    		}
    	}
		console.log("============" + curDirPath);
    	return lastDirPath;
    }
    
    var setLoadingProgress = function (cur,max) 
    {
        var loadingPercent = cur / max;
        if (loadingPercent > 1) 
        {
            loadingPercent = 1;
        }
     
        var loadingline = document.getElementById("loadingline");
        loadingline.style.width = (loadingPercent * 100) + "%";

        if(loadingPercent == 1)
        {
            // console.log("preloadComplete...");
        }
    }

	window["hideLoadingDiv"] = function(){
		var loadingDiv = document.getElementById("loadingDiv");
        loadingDiv.parentNode.removeChild(loadingDiv);
	}

    var loadSingleScript = function (src,idx, callback) {
        var s = document.createElement('script');
        s.async = false;
        s.src = src;
        //console.log("src = " + src)
        s.addEventListener('load', function () {
            s.parentNode.removeChild(s);
            s.removeEventListener('load', arguments.callee, false);
            callback();
        }, false);
        document.body.appendChild(s);
    };
	
	
	var jsExec = (function (text, forceTag) {
		if (!text) return text;
		var script = document.createElement('script');
		script.setAttribute('type', 'text/javascript');
		script.text = text;
		document.body.appendChild(script);
		document.body.removeChild(script);
		return text;
	});

	var manifestData = "nil";
	var settingData = "nil";
	var rootUrl = ".";
	var rootTruePath = returnLastDir();//真实root路径
	// console.log("============" + rootUrl + "\n============" + rootTruePath);
	var getURLVar = function(name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
        var r = window.location.search.substr(1).match(reg);
        return r != null ? unescape(r[2]) : null
    };
	
	/**testEntrance*/
	var debugParam = getURLVar("debug");
	
	if(debugParam && debugParam != "")
	{
		if(debugParam == "afd_debug")
		{
			rootUrl = "https://cdn-afd-wsx.8zy.com/afd_debug";
		}
	}
	
	var loadScriptList =  function(){
		var manifest = manifestData;
		var list = manifest.initial.concat(manifest.game);
        loadScript(list, function () {
			startGame();
        });
	}

	var startGame = function(){
		// console.log("startGame");
		if(settingData != "nil" && rootUrl == ".")
		{
			// console.log("startGame11111111111");
			URIManager.initSetting(settingData);
		}
		else
		{
			URIManager.rootUrl = rootUrl;
			// console.log("startGame ===========" + rootTruePath + rootUrl);
		}
		egret.runEgret({ renderMode: "webgl", audioType: 0 });
	}

	if(manifestData == "nil" || rootUrl != ".")
	{
		var xhr = new XMLHttpRequest();

		xhr.open('GET', rootUrl + '/manifest.json?v=' + Math.random(), true);

		xhr.addEventListener("load", function () {
			manifestData = JSON.parse(xhr.response);
			loadScriptList();
		});
		xhr.send(null);
	}
	else
	{
		loadScriptList();
	}