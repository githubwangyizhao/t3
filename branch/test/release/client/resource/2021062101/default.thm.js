window.skins=window.skins||{};
                var __extends = this && this.__extends|| function (d, b) {
                    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
                        function __() {
                            this.constructor = d;
                        }
                    __.prototype = b.prototype;
                    d.prototype = new __();
                };
                window.generateEUI = window.generateEUI||{};
                generateEUI.paths = generateEUI.paths||{};
                generateEUI.styles = undefined;
                generateEUI.skins = {};generateEUI.paths['resource/eui_skins/accessUI/AccessSkin.exml'] = window.accessSkin = (function (_super) {
	__extends(accessSkin, _super);
	function accessSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBj","u_itemName","u_mcItem","u_txtPath2","u_listAccess","u_scrollerItem","u_mcAccess","u_txtBlank"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_imgBj_i(),this._Image1_i(),this.u_mcItem_i(),this.u_mcAccess_i(),this.u_txtBlank_i()];
	}
	var _proto = accessSkin.prototype;

	_proto.u_imgBj_i = function () {
		var t = new eui.Image();
		this.u_imgBj = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 550;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(11,82,9,9);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_json.commonUI_bg";
		t.visible = true;
		t.width = 720;
		t.y = 38;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "accessUI_json.accessUI_img_bt";
		t.visible = true;
		t.x = 731;
		t.y = 61;
		return t;
	};
	_proto.u_mcItem_i = function () {
		var t = new eui.Group();
		this.u_mcItem = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 610;
		t.x = 471;
		t.y = 130.69;
		t.elementsContent = [this._Image2_i(),this.u_itemName_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(105,5,105,5);
		t.source = "commonUI_jw";
		t.width = 520;
		t.y = 3;
		return t;
	};
	_proto.u_itemName_i = function () {
		var t = new eui.Label();
		this.u_itemName = t;
		t.anchorOffsetX = 0;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 20;
		t.text = "Shop buy";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.y = 0;
		return t;
	};
	_proto.u_mcAccess_i = function () {
		var t = new eui.Group();
		this.u_mcAccess = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 610;
		t.y = 369.68;
		t.elementsContent = [this._Group1_i(),this.u_scrollerItem_i()];
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 50;
		t.scaleX = 1;
		t.scaleY = 1;
		t.width = 610;
		t.elementsContent = [this._Image3_i(),this.u_txtPath2_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(105,5,105,5);
		t.source = "commonUI_jw";
		t.verticalCenter = 0;
		t.visible = true;
		t.width = 520;
		return t;
	};
	_proto.u_txtPath2_i = function () {
		var t = new eui.Label();
		this.u_txtPath2 = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 16;
		t.text = "获取途径";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.verticalCenter = 2;
		t.visible = true;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 50;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 600;
		t.y = 50;
		t.viewport = this._Group2_i();
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.bottom = 0;
		t.elementsContent = [this.u_listAccess_i()];
		return t;
	};
	_proto.u_listAccess_i = function () {
		var t = new eui.List();
		this.u_listAccess = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtBlank_i = function () {
		var t = new eui.Label();
		this.u_txtBlank = t;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "点击空白处关闭窗口";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.verticalAlign = "middle";
		t.visible = true;
		t.y = 602;
		return t;
	};
	return accessSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/accessUI/render/AccessRenderSkin.exml'] = window.accessRenderSkin = (function (_super) {
	__extends(accessRenderSkin, _super);
	function accessRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgIcon","u_txtName","u_btnGoto"];
		
		this.height = 86;
		this.width = 600;
		this.elementsContent = [this._Image1_i(),this.u_imgIcon_i(),this.u_txtName_i(),this.u_btnGoto_i()];
	}
	var _proto = accessRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(30,10,570,55);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "accessUI_json.accessUI_bg_render";
		t.verticalCenter = 0;
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 70;
		t.verticalCenter = -2.5;
		t.visible = true;
		t.width = 70;
		t.x = 25;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = -30.5;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 20;
		t.text = "Label";
		t.textAlign = "center";
		t.textColor = 0x3F393C;
		t.verticalAlign = "middle";
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btnGoto_i = function () {
		var t = new eui.Image();
		this.u_btnGoto = t;
		t.source = "accessUI_json.accessUI_btn_1";
		t.verticalCenter = 0;
		t.visible = true;
		t.x = 458;
		return t;
	};
	return accessRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/accreditUI/AccreditUISkin.exml'] = window.AccreditUISkin = (function (_super) {
	__extends(AccreditUISkin, _super);
	function AccreditUISkin() {
		_super.call(this);
		this.skinParts = ["u_btnClose","u_txtMsg"];
		
		this.height = 507;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_btnClose_i(),this.u_txtMsg_i()];
	}
	var _proto = AccreditUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 497;
		t.scale9Grid = new egret.Rectangle(80,52,480,170);
		t.source = "commonPanelUI_json.commonPanelUI_panel_3";
		t.y = 12;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "commonsUI_json.commonsUI_tishi";
		t.y = 17;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.source = "commonsUI_json.commonsUI_btn_close_2";
		t.x = 550;
		t.y = 13;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.anchorOffsetX = 0;
		t.height = 194;
		t.horizontalCenter = 0;
		t.size = 26;
		t.stroke = 2;
		t.strokeColor = 0x254d60;
		t.text = "s";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.width = 480;
		t.y = 92;
		return t;
	};
	return AccreditUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/achievementUI/AchievementUISkin.exml'] = window.AchievementUISkin = (function (_super) {
	__extends(AchievementUISkin, _super);
	function AchievementUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgPage1","u_imgRed1","u_btnPage1","u_imgPage2","u_imgRed2","u_btnPage2","u_imgPage3","u_imgRed3","u_btnPage3"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this.u_btnPage1_i(),this.u_btnPage2_i(),this.u_btnPage3_i()];
	}
	var _proto = AchievementUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.height = 797;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(29,29,30,30);
		t.source = "commonsUI_json.commonUI_box_2";
		t.visible = true;
		t.width = 586;
		t.y = 192;
		return t;
	};
	_proto.u_btnPage1_i = function () {
		var t = new eui.Group();
		this.u_btnPage1 = t;
		t.height = 86;
		t.name = "btnName1";
		t.touchChildren = false;
		t.width = 108;
		t.x = 54;
		t.y = 107;
		t.elementsContent = [this.u_imgPage1_i(),this.u_imgRed1_i()];
		return t;
	};
	_proto.u_imgPage1_i = function () {
		var t = new eui.Image();
		this.u_imgPage1 = t;
		t.source = "achievementUI_json.achievementUI_1_2";
		t.visible = true;
		t.x = 0;
		t.y = 2;
		return t;
	};
	_proto.u_imgRed1_i = function () {
		var t = new eui.Image();
		this.u_imgRed1 = t;
		t.source = "commonsUI_json.commonsUI_red_1";
		t.visible = true;
		t.x = 75;
		t.y = 0;
		return t;
	};
	_proto.u_btnPage2_i = function () {
		var t = new eui.Group();
		this.u_btnPage2 = t;
		t.height = 86;
		t.name = "btnName2";
		t.touchChildren = false;
		t.width = 108;
		t.x = 194;
		t.y = 107;
		t.elementsContent = [this.u_imgPage2_i(),this.u_imgRed2_i()];
		return t;
	};
	_proto.u_imgPage2_i = function () {
		var t = new eui.Image();
		this.u_imgPage2 = t;
		t.height = 84;
		t.source = "achievementUI_json.achievementUI_2_1";
		t.visible = true;
		t.width = 108;
		t.x = 0;
		t.y = 2;
		return t;
	};
	_proto.u_imgRed2_i = function () {
		var t = new eui.Image();
		this.u_imgRed2 = t;
		t.source = "commonsUI_json.commonsUI_red_1";
		t.visible = true;
		t.x = 75;
		t.y = 0;
		return t;
	};
	_proto.u_btnPage3_i = function () {
		var t = new eui.Group();
		this.u_btnPage3 = t;
		t.height = 86;
		t.name = "btnName3";
		t.touchChildren = false;
		t.width = 108;
		t.x = 333;
		t.y = 107;
		t.elementsContent = [this.u_imgPage3_i(),this.u_imgRed3_i()];
		return t;
	};
	_proto.u_imgPage3_i = function () {
		var t = new eui.Image();
		this.u_imgPage3 = t;
		t.height = 84;
		t.source = "achievementUI_json.achievementUI_3_1";
		t.visible = true;
		t.width = 108;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgRed3_i = function () {
		var t = new eui.Image();
		this.u_imgRed3 = t;
		t.source = "commonsUI_json.commonsUI_red_1";
		t.visible = true;
		t.x = 75;
		t.y = 0;
		return t;
	};
	return AchievementUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/achievementUI/render/AchievementRenderSkin.exml'] = window.AchievementRenderSkin = (function (_super) {
	__extends(AchievementRenderSkin, _super);
	function AchievementRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtName","u_txtDesc","u_jindu","u_txtJindu","u_txtReward","u_itemIcon","u_txtCount","u_grpReward","u_imgGo","u_txtGo","u_imgRed","u_btnGo","u_imgReceived"];
		
		this.height = 158;
		this.width = 564;
		this.elementsContent = [this._Image1_i(),this.u_txtName_i(),this.u_txtDesc_i(),this._Group1_i(),this.u_txtReward_i(),this.u_grpReward_i(),this.u_btnGo_i(),this.u_imgReceived_i()];
	}
	var _proto = AchievementRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "achievementUI_json.achievementUI_di";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.bold = true;
		t.size = 20;
		t.text = "Monster";
		t.textColor = 0x38445D;
		t.visible = true;
		t.x = 16;
		t.y = 17;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.size = 18;
		t.text = "Kill 50 monsters";
		t.textColor = 0x38445D;
		t.visible = true;
		t.x = 18;
		t.y = 61;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.visible = true;
		t.x = 14;
		t.y = 88;
		t.elementsContent = [this._Image2_i(),this.u_jindu_i(),this.u_txtJindu_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 23;
		t.scale9Grid = new egret.Rectangle(8,9,219,13);
		t.source = "commonsUI_json.commonsUI_jindu_6";
		t.width = 350;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_jindu_i = function () {
		var t = new eui.Image();
		this.u_jindu = t;
		t.height = 15;
		t.scale9Grid = new egret.Rectangle(76,10,75,5);
		t.source = "commonsUI_json.commonsUI_jindu_5";
		t.width = 340;
		t.x = 5;
		t.y = 4;
		return t;
	};
	_proto.u_txtJindu_i = function () {
		var t = new eui.Label();
		this.u_txtJindu = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "40/100";
		t.y = 4;
		return t;
	};
	_proto.u_txtReward_i = function () {
		var t = new eui.Label();
		this.u_txtReward = t;
		t.size = 18;
		t.text = "Reward:";
		t.textColor = 0x38445D;
		t.visible = true;
		t.x = 12;
		t.y = 124;
		return t;
	};
	_proto.u_grpReward_i = function () {
		var t = new eui.Group();
		this.u_grpReward = t;
		t.x = 90;
		t.y = 111;
		t.elementsContent = [this.u_itemIcon_i(),this.u_txtCount_i()];
		return t;
	};
	_proto.u_itemIcon_i = function () {
		var t = new eui.Image();
		this.u_itemIcon = t;
		t.height = 40;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.width = 40;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtCount_i = function () {
		var t = new eui.Label();
		this.u_txtCount = t;
		t.bold = true;
		t.size = 20;
		t.text = "x9999";
		t.x = 39;
		t.y = 10;
		return t;
	};
	_proto.u_btnGo_i = function () {
		var t = new eui.Group();
		this.u_btnGo = t;
		t.height = 65;
		t.visible = true;
		t.width = 136;
		t.x = 409;
		t.y = 48;
		t.elementsContent = [this.u_imgGo_i(),this.u_txtGo_i(),this.u_imgRed_i()];
		return t;
	};
	_proto.u_imgGo_i = function () {
		var t = new eui.Image();
		this.u_imgGo = t;
		t.source = "commonsUI_json.commonsUI_btn_2";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtGo_i = function () {
		var t = new eui.Label();
		this.u_txtGo = t;
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.size = 22;
		t.text = "GO";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_imgRed_i = function () {
		var t = new eui.Image();
		this.u_imgRed = t;
		t.source = "commonsUI_json.commonsUI_red_1";
		t.x = 114;
		t.y = -3;
		return t;
	};
	_proto.u_imgReceived_i = function () {
		var t = new eui.Image();
		this.u_imgReceived = t;
		t.source = "commonsUI_json.commonsUI_received";
		t.visible = false;
		t.x = 433;
		t.y = 49;
		return t;
	};
	return AchievementRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/achievementUI/view/AchievemenViewSkin.exml'] = window.AchievemenViewSkin = (function (_super) {
	__extends(AchievemenViewSkin, _super);
	function AchievemenViewSkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_scrollerItem"];
		
		this.height = 770;
		this.width = 564;
		this.elementsContent = [this.u_scrollerItem_i()];
	}
	var _proto = AchievemenViewSkin.prototype;

	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 770;
		t.visible = true;
		t.width = 564;
		t.viewport = this.u_listItem_i();
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return AchievemenViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/bagUI/BagUISkin.exml'] = window.BagUISkin = (function (_super) {
	__extends(BagUISkin, _super);
	function BagUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_imgUse","u_txtUse","u_btnUse","u_txtName","u_txtDetail","u_txtAccess","u_txtAccessTit","u_grpAccess","u_grpExist","u_listItem","u_scrollItem","u_grpItemIcon","u_grpMask"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_imgBg_i(),this.u_grpExist_i(),this.u_scrollItem_i(),this.u_grpItemIcon_i(),this.u_grpMask_i()];
	}
	var _proto = BagUISkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 640;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(10,33,10,34);
		t.source = "bagUI_json.bagUI_bg";
		t.visible = true;
		t.width = 1136;
		return t;
	};
	_proto.u_grpExist_i = function () {
		var t = new eui.Group();
		this.u_grpExist = t;
		t.x = 766;
		t.y = 300;
		t.elementsContent = [this.u_btnUse_i(),this.u_txtName_i(),this.u_txtDetail_i(),this.u_grpAccess_i()];
		return t;
	};
	_proto.u_btnUse_i = function () {
		var t = new eui.Group();
		this.u_btnUse = t;
		t.visible = true;
		t.x = 58;
		t.y = 213;
		t.elementsContent = [this.u_imgUse_i(),this.u_txtUse_i()];
		return t;
	};
	_proto.u_imgUse_i = function () {
		var t = new eui.Image();
		this.u_imgUse = t;
		t.source = "bagUI_json.bagUI_btn_Use";
		t.visible = true;
		return t;
	};
	_proto.u_txtUse_i = function () {
		var t = new eui.Label();
		this.u_txtUse = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.size = 20;
		t.text = "使 用";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.visible = true;
		t.width = 47.5;
		t.x = 85.5;
		t.y = 17.5;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.fontFamily = "Microsoft YaHei";
		t.height = 18.5;
		t.size = 16;
		t.text = "冰冻卷轴";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.visible = true;
		t.width = 75;
		t.x = 129;
		t.y = 0;
		return t;
	};
	_proto.u_txtDetail_i = function () {
		var t = new eui.Label();
		this.u_txtDetail = t;
		t.fontFamily = "Microsoft YaHei";
		t.lineSpacing = 4;
		t.multiline = true;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 16;
		t.text = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
		t.textAlign = "left";
		t.textColor = 0xA5A5A5;
		t.verticalAlign = "middle";
		t.visible = true;
		t.width = 245;
		t.x = 77;
		t.y = 31;
		return t;
	};
	_proto.u_grpAccess_i = function () {
		var t = new eui.Group();
		this.u_grpAccess = t;
		t.height = 47;
		t.visible = true;
		t.width = 358;
		t.x = 0;
		t.y = 86.5;
		t.elementsContent = [this._Image1_i(),this.u_txtAccess_i(),this.u_txtAccessTit_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 2.2;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "bagUI_json.bagUI_img_line";
		t.visible = true;
		t.width = 306;
		t.x = 14;
		t.y = 7.5;
		return t;
	};
	_proto.u_txtAccess_i = function () {
		var t = new eui.Label();
		this.u_txtAccess = t;
		t.fontFamily = "Microsoft YaHei";
		t.left = 158;
		t.multiline = true;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 16;
		t.text = "Label";
		t.textAlign = "left";
		t.textColor = 0xA5A5A5;
		t.verticalAlign = "middle";
		t.y = 25.5;
		return t;
	};
	_proto.u_txtAccessTit_i = function () {
		var t = new eui.Label();
		this.u_txtAccessTit = t;
		t.fontFamily = "Microsoft YaHei";
		t.size = 16;
		t.text = "获取途径：";
		t.textAlign = "center";
		t.textColor = 0xA5A5A5;
		t.verticalAlign = "middle";
		t.x = 79;
		t.y = 26.5;
		return t;
	};
	_proto.u_scrollItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 582;
		t.width = 720;
		t.x = 47;
		t.y = 57;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_grpItemIcon_i = function () {
		var t = new eui.Group();
		this.u_grpItemIcon = t;
		t.height = 120;
		t.width = 120;
		t.x = 873;
		t.y = 163;
		return t;
	};
	_proto.u_grpMask_i = function () {
		var t = new eui.Group();
		this.u_grpMask = t;
		t.visible = false;
		t.x = 843.5;
		t.y = 276.5;
		t.elementsContent = [this._Image2_i(),this._Label1_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 56.295;
		t.source = "bagUI_json.bagUI_img_k";
		t.visible = true;
		t.width = 58.123;
		t.x = 59.25;
		t.y = 0;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.fontFamily = "Microsoft YaHei";
		t.size = 20;
		t.text = "背包中没有任何物品";
		t.textColor = 0xA5A5A5;
		t.x = 0;
		t.y = 89;
		return t;
	};
	return BagUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/bagUI/popup/ItemMergePopupSkin.exml'] = window.ItemMergePopupSkin = (function (_super) {
	__extends(ItemMergePopupSkin, _super);
	function ItemMergePopupSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_txtName","u_txtHave","u_descTip","u_txtDesc","u_txtCount","u_btnAdd","u_btnJian","u_btnMax","u_btnMin","u_btnMerge"];
		
		this.height = 262;
		this.width = 456;
		this.elementsContent = [this.u_imgBg_i(),this.u_txtName_i(),this.u_txtHave_i(),this._Image1_i(),this.u_descTip_i(),this.u_txtDesc_i(),this._Group1_i(),this.u_btnAdd_i(),this.u_btnJian_i(),this.u_btnMax_i(),this.u_btnMin_i(),this.u_btnMerge_i()];
	}
	var _proto = ItemMergePopupSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 262;
		t.scale9Grid = new egret.Rectangle(27,27,15,13);
		t.source = "commonUI_json.commonUI_di_2";
		t.visible = true;
		t.width = 456;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.size = 16;
		t.text = "道具名称";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 205;
		t.y = 25;
		return t;
	};
	_proto.u_txtHave_i = function () {
		var t = new eui.Label();
		this.u_txtHave = t;
		t.size = 16;
		t.text = "拥有数量";
		t.textColor = 0x369800;
		t.visible = true;
		t.x = 205;
		t.y = 53;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 114;
		t.scale9Grid = new egret.Rectangle(17,17,16,16);
		t.source = "commonUI_json.commonUI_box_1";
		t.visible = true;
		t.width = 422;
		t.x = 18;
		t.y = 85;
		return t;
	};
	_proto.u_descTip_i = function () {
		var t = new eui.Label();
		this.u_descTip = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "【物品描述】";
		t.textColor = 0xB4AA84;
		t.visible = true;
		t.y = 96;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.horizontalCenter = 0;
		t.lineSpacing = 10;
		t.size = 14;
		t.text = "描述描述";
		t.textAlign = "center";
		t.textColor = 0xB6B5B3;
		t.width = 380;
		t.wordWrap = true;
		t.y = 121;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 143;
		t.y = 145;
		t.elementsContent = [this._Image2_i(),this.u_txtCount_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(13,13,14,14);
		t.source = "mergeUI_json.mergeUI_dk";
		t.visible = true;
		t.width = 170;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtCount_i = function () {
		var t = new eui.Label();
		this.u_txtCount = t;
		t.horizontalCenter = 0.5;
		t.size = 18;
		t.text = "0";
		t.textColor = 0xB3AC92;
		t.verticalCenter = 1;
		t.visible = true;
		return t;
	};
	_proto.u_btnAdd_i = function () {
		var t = new eui.Image();
		this.u_btnAdd = t;
		t.height = 38;
		t.source = "mergeUI_json.mergeUI_btn_jia";
		t.visible = true;
		t.width = 38;
		t.x = 326;
		t.y = 147;
		return t;
	};
	_proto.u_btnJian_i = function () {
		var t = new eui.Image();
		this.u_btnJian = t;
		t.height = 38;
		t.source = "mergeUI_json.mergeUI_btn_jian";
		t.width = 38;
		t.x = 94;
		t.y = 147;
		return t;
	};
	_proto.u_btnMax_i = function () {
		var t = new eui.Image();
		this.u_btnMax = t;
		t.height = 38;
		t.source = "mergeUI_json.mergeUI_max";
		t.visible = true;
		t.width = 58;
		t.x = 375;
		t.y = 147;
		return t;
	};
	_proto.u_btnMin_i = function () {
		var t = new eui.Image();
		this.u_btnMin = t;
		t.height = 38;
		t.source = "mergeUI_json.mergeUI_min";
		t.visible = true;
		t.width = 58;
		t.x = 24;
		t.y = 147;
		return t;
	};
	_proto.u_btnMerge_i = function () {
		var t = new eui.Image();
		this.u_btnMerge = t;
		t.horizontalCenter = 0;
		t.source = "mergeUI_json.mergeUI_merge";
		t.visible = true;
		t.y = 209;
		return t;
	};
	return ItemMergePopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/bagUI/popup/ItemUsePopupSkin.exml'] = window.ItemUsePopupSkin = (function (_super) {
	__extends(ItemUsePopupSkin, _super);
	function ItemUsePopupSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_txtName","u_txtHoldings","u_imgBg2","u_txtDescTitle","u_txtDescribe","u_txtSourTitle","u_txtSource","u_grpSource"];
		
		this.height = 287.5;
		this.width = 345;
		this.elementsContent = [this.u_imgBg_i(),this.u_txtName_i(),this.u_txtHoldings_i(),this.u_imgBg2_i(),this.u_txtDescTitle_i(),this.u_txtDescribe_i(),this.u_grpSource_i()];
	}
	var _proto = ItemUsePopupSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 287.5;
		t.scale9Grid = new egret.Rectangle(23,23,24,24);
		t.source = "commonUI_json.commonUI_di_2";
		t.visible = true;
		t.width = 345;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.fontFamily = "Microsoft YaHei";
		t.height = 14.5;
		t.left = 108;
		t.size = 18;
		t.text = "Name";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.visible = true;
		t.y = 25.5;
		return t;
	};
	_proto.u_txtHoldings_i = function () {
		var t = new eui.Label();
		this.u_txtHoldings = t;
		t.fontFamily = "Microsoft YaHei";
		t.left = 108;
		t.size = 18;
		t.text = "Holdings:  99,999,999,999";
		t.textAlign = "left";
		t.verticalAlign = "middle";
		t.visible = true;
		t.y = 52;
		return t;
	};
	_proto.u_imgBg2_i = function () {
		var t = new eui.Image();
		this.u_imgBg2 = t;
		t.height = 180;
		t.scale9Grid = new egret.Rectangle(17,17,16,16);
		t.source = "bagUI_json.bagUI_img_gzbg";
		t.visible = true;
		t.width = 320;
		t.x = 13;
		t.y = 85;
		return t;
	};
	_proto.u_txtDescTitle_i = function () {
		var t = new eui.Label();
		this.u_txtDescTitle = t;
		t.fontFamily = "Microsoft YaHei";
		t.height = 23.5;
		t.horizontalCenter = 5;
		t.size = 18;
		t.text = "desc";
		t.textAlign = "center";
		t.textColor = 0xB1A782;
		t.verticalAlign = "middle";
		t.width = 169;
		t.y = 90;
		return t;
	};
	_proto.u_txtDescribe_i = function () {
		var t = new eui.Label();
		this.u_txtDescribe = t;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.lineSpacing = 6;
		t.multiline = true;
		t.size = 18;
		t.text = "AAA";
		t.textAlign = "center";
		t.textColor = 0xBCBBBA;
		t.verticalAlign = "middle";
		t.visible = true;
		t.width = 258.5;
		t.wordWrap = true;
		t.y = 116;
		return t;
	};
	_proto.u_grpSource_i = function () {
		var t = new eui.Group();
		this.u_grpSource = t;
		t.horizontalCenter = 0;
		t.width = 258.5;
		t.y = 135;
		t.elementsContent = [this.u_txtSourTitle_i(),this.u_txtSource_i()];
		return t;
	};
	_proto.u_txtSourTitle_i = function () {
		var t = new eui.Label();
		this.u_txtSourTitle = t;
		t.fontFamily = "Microsoft YaHei";
		t.height = 24.5;
		t.horizontalCenter = 3.5;
		t.size = 18;
		t.text = "source";
		t.textAlign = "center";
		t.textColor = 0xB1A782;
		t.verticalAlign = "middle";
		t.width = 170;
		t.x = 56;
		t.y = 0;
		return t;
	};
	_proto.u_txtSource_i = function () {
		var t = new eui.Label();
		this.u_txtSource = t;
		t.fontFamily = "Microsoft YaHei";
		t.lineSpacing = 6;
		t.multiline = true;
		t.size = 18;
		t.text = "aaa";
		t.textAlign = "left";
		t.textColor = 0xBCBBBA;
		t.verticalAlign = "middle";
		t.visible = true;
		t.width = 257.5;
		t.wordWrap = true;
		t.x = 1;
		t.y = 25.5;
		return t;
	};
	return ItemUsePopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/bagUI/render/BagRenderSkin.exml'] = window.BagRenderSkin = (function (_super) {
	__extends(BagRenderSkin, _super);
	function BagRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBj","u_imgSelected"];
		
		this.height = 130;
		this.width = 130;
		this.elementsContent = [this.u_imgBj_i(),this.u_imgSelected_i()];
	}
	var _proto = BagRenderSkin.prototype;

	_proto.u_imgBj_i = function () {
		var t = new eui.Image();
		this.u_imgBj = t;
		t.height = 120;
		t.scale9Grid = new egret.Rectangle(13,13,14,14);
		t.source = "bagUI_json.bagUI_icon_bg";
		t.width = 120;
		t.x = 5;
		t.y = 5;
		return t;
	};
	_proto.u_imgSelected_i = function () {
		var t = new eui.Image();
		this.u_imgSelected = t;
		t.alpha = 1;
		t.height = 120;
		t.source = "bagUI_json.bagUI_img_xz";
		t.visible = true;
		t.width = 120;
		t.x = 5;
		t.y = 5;
		return t;
	};
	return BagRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/bossEventUI/popup/BossEventPopUpSkin.exml'] = window.skins.BossEventUISkin = (function (_super) {
	__extends(BossEventUISkin, _super);
	function BossEventUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_imgMonst_Head","u_btnTo","u_textReach","u_textTime","u_textName","u_textShed","u_textDesc","u_btnBack","u_mcLeft"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_imgBg_i(),this._Image1_i(),this.u_imgMonst_Head_i(),this.u_btnTo_i(),this.u_textReach_i(),this.u_textTime_i(),this._Image2_i(),this.u_textName_i(),this.u_textShed_i(),this.u_textDesc_i(),this.u_mcLeft_i()];
	}
	var _proto = BossEventUISkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "bossEventUI_json.boossEventUI_name_line";
		t.x = 160.686;
		t.y = 435.613;
		return t;
	};
	_proto.u_imgMonst_Head_i = function () {
		var t = new eui.Image();
		this.u_imgMonst_Head = t;
		t.touchEnabled = false;
		t.x = 114.89;
		t.y = 137.118;
		return t;
	};
	_proto.u_btnTo_i = function () {
		var t = new eui.Image();
		this.u_btnTo = t;
		t.source = "bossEventUI_json.boossEventUI_img_go";
		t.x = 863.92;
		t.y = 300.77;
		return t;
	};
	_proto.u_textReach_i = function () {
		var t = new eui.Label();
		this.u_textReach = t;
		t.size = 14;
		t.text = "BOSS抵达时间：";
		t.textColor = 0xF0E4B0;
		t.x = 849.981;
		t.y = 368.691;
		return t;
	};
	_proto.u_textTime_i = function () {
		var t = new eui.Label();
		this.u_textTime = t;
		t.bold = true;
		t.size = 16;
		t.text = "战斗中...";
		t.textColor = 0xF0E4B0;
		t.x = 969.72;
		t.y = 368.291;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "bossEventUI_json.boossEventUI_name_bg";
		t.x = 456.491;
		t.y = 190.406;
		return t;
	};
	_proto.u_textName_i = function () {
		var t = new eui.Label();
		this.u_textName = t;
		t.bold = true;
		t.horizontalCenter = 33;
		t.size = 24;
		t.text = "牛魔王的小亲亲";
		t.textColor = 0xFDF9D4;
		t.visible = true;
		t.y = 228.106;
		return t;
	};
	_proto.u_textShed_i = function () {
		var t = new eui.Label();
		this.u_textShed = t;
		t.size = 24;
		t.text = "BOSS掉落:";
		t.textColor = 0xFFFADB;
		t.visible = true;
		t.x = 330.728;
		t.y = 324.478;
		return t;
	};
	_proto.u_textDesc_i = function () {
		var t = new eui.Label();
		this.u_textDesc = t;
		t.size = 16;
		t.text = "牛魔王又去找玉面狐狸了。。。";
		t.textColor = 0x595856;
		t.x = 335.893;
		t.y = 425.513;
		return t;
	};
	_proto.u_mcLeft_i = function () {
		var t = new eui.Group();
		this.u_mcLeft = t;
		t.width = 100;
		t.x = 1;
		t.y = 80.091;
		t.elementsContent = [this._Image3_i(),this.u_btnBack_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "bossEventUI_json.boossEventUI_img_left";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnBack_i = function () {
		var t = new eui.Image();
		this.u_btnBack = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "bossEventUI_json.bossEventUI_back";
		t.x = 4.648;
		t.y = 199;
		return t;
	};
	return BossEventUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/bossEventUI/view/BossEventViewSkin.exml'] = window.skins.BossEventViewSkin = (function (_super) {
	__extends(BossEventViewSkin, _super);
	function BossEventViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_imgBg_i()];
	}
	var _proto = BossEventViewSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 640;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(171,96,170,96);
		t.source = "bossEventUI_json.bossEventUI_bg";
		t.verticalCenter = 0;
		t.visible = true;
		t.width = 1136;
		return t;
	};
	return BossEventViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/cardBookUI/CardMainUISkin.exml'] = window.CardMainUISkin = (function (_super) {
	__extends(CardMainUISkin, _super);
	function CardMainUISkin() {
		_super.call(this);
		this.skinParts = ["u_btnColse","u_mcLeft"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_mcLeft_i()];
	}
	var _proto = CardMainUISkin.prototype;

	_proto.u_mcLeft_i = function () {
		var t = new eui.Group();
		this.u_mcLeft = t;
		t.x = 0;
		t.y = 147;
		t.elementsContent = [this._Image1_i(),this.u_btnColse_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "cardMainUI_json.cardMainUI_bg";
		t.visible = true;
		t.x = 1;
		t.y = 0;
		return t;
	};
	_proto.u_btnColse_i = function () {
		var t = new eui.Image();
		this.u_btnColse = t;
		t.source = "cardMainUI_json.cardMainUI_close";
		t.visible = true;
		t.x = 5;
		t.y = 129;
		return t;
	};
	return CardMainUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/cardBookUI/page/CardBookPageSkin.exml'] = window.CardBookPageSkin = (function (_super) {
	__extends(CardBookPageSkin, _super);
	function CardBookPageSkin() {
		_super.call(this);
		this.skinParts = ["u_mcContent","u_scrollerItem","u_imgMask"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_scrollerItem_i(),this.u_imgMask_i()];
	}
	var _proto = CardBookPageSkin.prototype;

	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 520;
		t.verticalCenter = -40;
		t.visible = true;
		t.width = 849;
		t.x = 219;
		t.viewport = this.u_mcContent_i();
		return t;
	};
	_proto.u_mcContent_i = function () {
		var t = new eui.Group();
		this.u_mcContent = t;
		return t;
	};
	_proto.u_imgMask_i = function () {
		var t = new eui.Image();
		this.u_imgMask = t;
		t.bottom = 0;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(379,56,378,57);
		t.source = "cardMainUI_json.cardMainUI_bg2";
		t.touchEnabled = false;
		return t;
	};
	return CardBookPageSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/cardBookUI/popup/CardInfoPopupSkin.exml'] = window.CardInfoPopupSkin = (function (_super) {
	__extends(CardInfoPopupSkin, _super);
	function CardInfoPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_imgTitle","u_txtTitle","u_condition","u_txtReward","u_txtBlank","u_itemList","u_txtMsg","u_scrollerItem"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_imgTitle_i(),this.u_txtTitle_i(),this.u_condition_i(),this.u_txtReward_i(),this.u_txtBlank_i(),this.u_itemList_i(),this.u_scrollerItem_i()];
	}
	var _proto = CardInfoPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(127,118,4,36);
		t.source = "cardBookUI_json.cardBookUI_box_3";
		t.visible = true;
		t.width = 678;
		t.y = 151;
		return t;
	};
	_proto.u_imgTitle_i = function () {
		var t = new eui.Image();
		this.u_imgTitle = t;
		t.visible = true;
		t.x = 248;
		t.y = 106;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.stroke = 2;
		t.text = "沼泽妖迹";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 164;
		return t;
	};
	_proto.u_condition_i = function () {
		var t = new eui.Label();
		this.u_condition = t;
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.size = 16;
		t.text = "激活条件";
		t.textColor = 0xF0E4B0;
		t.y = 212;
		return t;
	};
	_proto.u_txtReward_i = function () {
		var t = new eui.Label();
		this.u_txtReward = t;
		t.bold = true;
		t.right = 680;
		t.size = 16;
		t.text = "奖励: ";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 288;
		return t;
	};
	_proto.u_txtBlank_i = function () {
		var t = new eui.Label();
		this.u_txtBlank = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.stroke = 2;
		t.text = "点击空白处关闭窗口";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.visible = true;
		t.y = 548;
		return t;
	};
	_proto.u_itemList_i = function () {
		var t = new eui.Group();
		this.u_itemList = t;
		t.height = 100;
		t.horizontalCenter = 0;
		t.y = 245;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 75;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 624;
		t.y = 395;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 59;
		t.y = 161;
		t.elementsContent = [this.u_txtMsg_i()];
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.lineSpacing = 12;
		t.size = 16;
		t.strokeColor = 0x453A32;
		t.text = "地图说明地图说明地图说明地图说地图说明地图说明地图说明地图说明地图说明地图说明明地图说明地图说明地图说明地图说明";
		t.textAlign = "left";
		t.textColor = 0x8E7E6F;
		t.width = 624;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return CardInfoPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/cardBookUI/popup/CardRewardPopupSkin.exml'] = window.CardRewardPopupSkin = (function (_super) {
	__extends(CardRewardPopupSkin, _super);
	function CardRewardPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_imgTitle","u_txtTitle","u_condition","u_txtReward","u_txtBlank","u_itemList","u_txtMsg","u_scrollerItem"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_imgTitle_i(),this.u_txtTitle_i(),this.u_condition_i(),this.u_txtReward_i(),this.u_txtBlank_i(),this.u_itemList_i(),this.u_scrollerItem_i()];
	}
	var _proto = CardRewardPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(127,118,4,36);
		t.source = "cardBookUI_json.cardBookUI_box_3";
		t.visible = true;
		t.width = 678;
		t.y = 151;
		return t;
	};
	_proto.u_imgTitle_i = function () {
		var t = new eui.Image();
		this.u_imgTitle = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.y = 145;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.stroke = 2;
		t.text = "沼泽妖迹";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 164;
		return t;
	};
	_proto.u_condition_i = function () {
		var t = new eui.Label();
		this.u_condition = t;
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.size = 16;
		t.text = "激活条件";
		t.textColor = 0xF0E4B0;
		t.y = 212;
		return t;
	};
	_proto.u_txtReward_i = function () {
		var t = new eui.Label();
		this.u_txtReward = t;
		t.bold = true;
		t.right = 680;
		t.size = 16;
		t.text = "奖励: ";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 288;
		return t;
	};
	_proto.u_txtBlank_i = function () {
		var t = new eui.Label();
		this.u_txtBlank = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.stroke = 2;
		t.text = "点击空白处关闭窗口";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.visible = true;
		t.y = 548;
		return t;
	};
	_proto.u_itemList_i = function () {
		var t = new eui.Group();
		this.u_itemList = t;
		t.height = 100;
		t.horizontalCenter = 0;
		t.y = 245;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 75;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 624;
		t.y = 395;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 59;
		t.y = 161;
		t.elementsContent = [this.u_txtMsg_i()];
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.lineSpacing = 12;
		t.size = 16;
		t.strokeColor = 0x453A32;
		t.text = "地图说明地图说明地图说明地图说地图说明地图说明地图说明地图说明地图说明地图说明明地图说明地图说明地图说明地图说明";
		t.textAlign = "left";
		t.textColor = 0x8E7E6F;
		t.width = 624;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return CardRewardPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/cardBookUI/view/CardRewardItemSkin.exml'] = window.CardRewardItemSkin = (function (_super) {
	__extends(CardRewardItemSkin, _super);
	function CardRewardItemSkin() {
		_super.call(this);
		this.skinParts = ["u_imgReceive"];
		
		this.height = 100;
		this.width = 100;
		this.elementsContent = [this._Image1_i(),this.u_imgReceive_i()];
	}
	var _proto = CardRewardItemSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 100;
		t.width = 100;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgReceive_i = function () {
		var t = new eui.Image();
		this.u_imgReceive = t;
		t.source = "cardBookUI_json.cardBookUI_received";
		t.visible = true;
		t.x = 0;
		t.y = 14;
		return t;
	};
	return CardRewardItemSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/cardBookUI/view/CardTitieViewSkin.exml'] = window.CardTitieViewSkin = (function (_super) {
	__extends(CardTitieViewSkin, _super);
	function CardTitieViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgTitle","u_txtName","u_imgArrow","u_imgRed","u_jindu","u_txtJindu","u_btnShow","u_imgEff","u_btnReward","u_mcBg","u_mcContent"];
		
		this.height = 92;
		this.width = 849;
		this.elementsContent = [this._Image1_i(),this.u_imgTitle_i(),this.u_txtName_i(),this.u_imgArrow_i(),this.u_imgRed_i(),this._Group1_i(),this.u_btnShow_i(),this.u_imgEff_i(),this.u_btnReward_i(),this.u_mcContent_i()];
	}
	var _proto = CardTitieViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "cardBookUI_json.cardBookUI_title_bg2";
		t.visible = true;
		t.x = 0;
		t.y = 15;
		return t;
	};
	_proto.u_imgTitle_i = function () {
		var t = new eui.Image();
		this.u_imgTitle = t;
		t.visible = true;
		t.x = 34;
		t.y = 15;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.bold = true;
		t.size = 20;
		t.stroke = 2;
		t.text = "沼泽妖迹";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 52;
		t.y = 27;
		return t;
	};
	_proto.u_imgArrow_i = function () {
		var t = new eui.Image();
		this.u_imgArrow = t;
		t.anchorOffsetX = 6.5;
		t.anchorOffsetY = 3;
		t.scaleY = -1;
		t.source = "cardBookUI_json.cardBookUI_arrow";
		t.x = 424.5;
		t.y = 76.5;
		return t;
	};
	_proto.u_imgRed_i = function () {
		var t = new eui.Image();
		this.u_imgRed = t;
		t.source = "commonUI_json.commonUI_red";
		t.visible = true;
		t.x = 39;
		t.y = 18;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 314;
		t.y = 26;
		t.elementsContent = [this._Image2_i(),this.u_jindu_i(),this.u_txtJindu_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 19;
		t.scale9Grid = new egret.Rectangle(11,7,10,4);
		t.source = "commonUI_json.commonUI_jindu_1";
		t.visible = true;
		t.width = 355;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_jindu_i = function () {
		var t = new eui.Image();
		this.u_jindu = t;
		t.height = 15;
		t.scale9Grid = new egret.Rectangle(5,5,18,4);
		t.source = "commonUI_json.commonUI_jindu_2";
		t.verticalCenter = 0;
		t.width = 28;
		t.x = 2;
		return t;
	};
	_proto.u_txtJindu_i = function () {
		var t = new eui.Label();
		this.u_txtJindu = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 18;
		t.stroke = 2;
		t.text = "5/16";
		t.textColor = 0xF0E4B0;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btnShow_i = function () {
		var t = new eui.Image();
		this.u_btnShow = t;
		t.alpha = 0;
		t.height = 92;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(3,3,4,4);
		t.source = "commonUI_json.commonUI_box";
		t.visible = true;
		t.width = 849;
		return t;
	};
	_proto.u_imgEff_i = function () {
		var t = new eui.Image();
		this.u_imgEff = t;
		t.source = "cardBookUI_json.cardBookUI_reward_di";
		t.visible = true;
		t.x = 695;
		t.y = 0;
		return t;
	};
	_proto.u_btnReward_i = function () {
		var t = new eui.Image();
		this.u_btnReward = t;
		t.source = "cardBookUI_json.cardBookUI_reward";
		t.visible = true;
		t.x = 706;
		t.y = 8;
		return t;
	};
	_proto.u_mcContent_i = function () {
		var t = new eui.Group();
		this.u_mcContent = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 800;
		t.y = 85;
		t.elementsContent = [this.u_mcBg_i()];
		return t;
	};
	_proto.u_mcBg_i = function () {
		var t = new eui.Image();
		this.u_mcBg = t;
		t.height = 0;
		t.scale9Grid = new egret.Rectangle(37,53,36,35);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "cardBookUI_json.cardBookUI_box_4";
		t.width = 800;
		return t;
	};
	return CardTitieViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/cardBookUI/view/CardViewSkin.exml'] = window.CardViewSkin = (function (_super) {
	__extends(CardViewSkin, _super);
	function CardViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgQuality","u_imgIcon","u_txtCount","u_btnCheck","u_imgRed","u_imgReceived","u_btnClick"];
		
		this.height = 138;
		this.width = 116;
		this.elementsContent = [this._Image1_i(),this._Group1_i(),this.u_btnCheck_i(),this.u_imgRed_i(),this.u_imgReceived_i(),this.u_btnClick_i()];
	}
	var _proto = CardViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 135;
		t.scale9Grid = new egret.Rectangle(17,17,16,16);
		t.source = "cardBookUI_json.cardBookUI_box_1";
		t.visible = true;
		t.width = 104;
		t.x = 11;
		t.y = 0;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 13;
		t.y = 2;
		t.elementsContent = [this.u_imgQuality_i(),this.u_imgIcon_i(),this.u_txtCount_i()];
		return t;
	};
	_proto.u_imgQuality_i = function () {
		var t = new eui.Image();
		this.u_imgQuality = t;
		t.horizontalCenter = 0;
		t.source = "commonUI_json.commonUI_icon_q_3";
		t.visible = true;
		t.y = 0;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.y = 3;
		return t;
	};
	_proto.u_txtCount_i = function () {
		var t = new eui.Label();
		this.u_txtCount = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 16;
		t.stroke = 2;
		t.text = "10/10";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 110;
		return t;
	};
	_proto.u_btnCheck_i = function () {
		var t = new eui.Image();
		this.u_btnCheck = t;
		t.source = "cardBookUI_json.cardBookUI_check";
		t.x = 80;
		t.y = 14;
		return t;
	};
	_proto.u_imgRed_i = function () {
		var t = new eui.Image();
		this.u_imgRed = t;
		t.source = "commonUI_json.commonUI_red";
		t.visible = true;
		t.x = 3;
		t.y = 0;
		return t;
	};
	_proto.u_imgReceived_i = function () {
		var t = new eui.Image();
		this.u_imgReceived = t;
		t.horizontalCenter = 3;
		t.source = "cardBookUI_json.cardBookUI_complete";
		t.visible = true;
		t.x = 11;
		t.y = 53;
		return t;
	};
	_proto.u_btnClick_i = function () {
		var t = new eui.Image();
		this.u_btnClick = t;
		t.alpha = 0;
		t.height = 138;
		t.scale9Grid = new egret.Rectangle(3,3,4,4);
		t.source = "commonUI_json.commonUI_box";
		t.visible = true;
		t.width = 116;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return CardViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/cardUI/popup/CardPopupSkin.exml'] = window.skins.CardPopupSkin = (function (_super) {
	__extends(CardPopupSkin, _super);
	function CardPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtCountdown"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_txtCountdown_i()];
	}
	var _proto = CardPopupSkin.prototype;

	_proto.u_txtCountdown_i = function () {
		var t = new eui.Label();
		this.u_txtCountdown = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "Label";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.visible = true;
		t.y = 563;
		return t;
	};
	return CardPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/cardUI/view/CardSkin.exml'] = window.skins.CardSkin = (function (_super) {
	__extends(CardSkin, _super);
	function CardSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_itemIcon","u_imgGp"];
		
		this.height = 151;
		this.width = 108;
		this.elementsContent = [this.u_imgBg_i(),this.u_imgGp_i()];
	}
	var _proto = CardSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.anchorOffsetX = 54;
		t.anchorOffsetY = 75.5;
		t.height = 151;
		t.scaleX = 0;
		t.source = "cardUI_json.cardUI__imgBg";
		t.visible = true;
		t.width = 108;
		t.x = 53;
		t.y = 73;
		return t;
	};
	_proto.u_imgGp_i = function () {
		var t = new eui.Group();
		this.u_imgGp = t;
		t.anchorOffsetX = 54;
		t.anchorOffsetY = 75.5;
		t.height = 151;
		t.scaleX = 1.1;
		t.width = 108;
		t.x = 52;
		t.y = 76;
		t.elementsContent = [this._Image1_i(),this.u_itemIcon_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "cardUI_json.cardUI_imgIcon";
		t.visible = true;
		t.width = 108;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_itemIcon_i = function () {
		var t = new eui.Image();
		this.u_itemIcon = t;
		t.height = 60;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 60;
		t.y = 69;
		return t;
	};
	return CardSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/commonsUI/AttrItemSkin.exml'] = window.AttrItemSkin = (function (_super) {
	__extends(AttrItemSkin, _super);
	function AttrItemSkin() {
		_super.call(this);
		this.skinParts = ["txtName","txtValue","imgJiantou","mcChange"];
		
		this.height = 36;
		this.width = 212;
		this.elementsContent = [this.txtName_i(),this.mcChange_i()];
	}
	var _proto = AttrItemSkin.prototype;

	_proto.txtName_i = function () {
		var t = new eui.Label();
		this.txtName = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.size = 19;
		t.text = "攻击：87773";
		t.textAlign = "left";
		t.textColor = 0xffffff;
		t.x = 3;
		t.y = 10;
		return t;
	};
	_proto.mcChange_i = function () {
		var t = new eui.Group();
		this.mcChange = t;
		t.x = 129;
		t.y = 2;
		t.elementsContent = [this.txtValue_i(),this.imgJiantou_i()];
		return t;
	};
	_proto.txtValue_i = function () {
		var t = new eui.Label();
		this.txtValue = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.size = 16;
		t.text = "9999";
		t.textAlign = "left";
		t.textColor = 0x56F210;
		t.width = 62;
		t.x = 26.5;
		t.y = 10;
		return t;
	};
	_proto.imgJiantou_i = function () {
		var t = new eui.Image();
		this.imgJiantou = t;
		t.anchorOffsetX = 12.5;
		t.anchorOffsetY = 15;
		t.scaleY = -1;
		t.source = "commonsUI_json.commonsUI_jiantou";
		t.x = 13;
		t.y = 17;
		return t;
	};
	return AttrItemSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/commonsUI/entrance/BubbleTipSkin.exml'] = window.BubbleTipSkin = (function (_super) {
	__extends(BubbleTipSkin, _super);
	function BubbleTipSkin() {
		_super.call(this);
		this.skinParts = ["u_imgArrow","u_imgBj","u_txtMsg"];
		
		this.height = 74.8;
		this.width = 140.4;
		this.elementsContent = [this.u_imgArrow_i(),this.u_imgBj_i(),this.u_txtMsg_i()];
	}
	var _proto = BubbleTipSkin.prototype;

	_proto.u_imgArrow_i = function () {
		var t = new eui.Image();
		this.u_imgArrow = t;
		t.anchorOffsetX = 7;
		t.anchorOffsetY = 3.5;
		t.rotation = 180;
		t.source = "userMainUI_u_tishi_j";
		t.x = 41;
		t.y = 36.19;
		return t;
	};
	_proto.u_imgBj_i = function () {
		var t = new eui.Image();
		this.u_imgBj = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.scale9Grid = new egret.Rectangle(15,12,4,11);
		t.source = "userMainUI_u_tishi";
		t.width = 87;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.lineSpacing = 6;
		t.size = 18;
		t.stroke = 1;
		t.strokeColor = 0x686868;
		t.text = "文";
		t.textAlign = "left";
		t.textColor = 0xffffff;
		t.x = 14;
		t.y = 9;
		return t;
	};
	return BubbleTipSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/commonsUI/entrance/EntranceIconSkin.exml'] = window.EntranceIconSkin = (function (_super) {
	__extends(EntranceIconSkin, _super);
	function EntranceIconSkin() {
		_super.call(this);
		this.skinParts = ["u_imgIcon","u_txtDesc","u_imgName","u_btnClick"];
		
		this.height = 105;
		this.width = 105;
		this.elementsContent = [this.u_imgIcon_i(),this.u_txtDesc_i(),this.u_imgName_i(),this.u_btnClick_i()];
	}
	var _proto = EntranceIconSkin.prototype;

	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.horizontalCenter = 0;
		t.source = "entranceUI_json.1011_icon_ent";
		t.touchEnabled = false;
		t.y = 6;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.anchorOffsetX = 0;
		t.horizontalCenter = 0;
		t.multiline = false;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 16;
		t.stroke = 1;
		t.strokeColor = 0x232323;
		t.text = "";
		t.textAlign = "center";
		t.textColor = 0x00ff03;
		t.touchEnabled = false;
		t.y = 85;
		return t;
	};
	_proto.u_imgName_i = function () {
		var t = new eui.Image();
		this.u_imgName = t;
		t.horizontalCenter = 0;
		t.source = "entranceUI_json.1011_name_ent";
		t.touchEnabled = false;
		t.y = 41;
		return t;
	};
	_proto.u_btnClick_i = function () {
		var t = new eui.Image();
		this.u_btnClick = t;
		t.alpha = 0;
		t.anchorOffsetY = 0;
		t.height = 76;
		t.scale9Grid = new egret.Rectangle(1,1,8,8);
		t.source = "commonUI_json.commonUI_box";
		t.width = 71;
		t.x = 17;
		t.y = 7;
		return t;
	};
	return EntranceIconSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/commonsUI/floatTip/FloatTipUISkin.exml'] = window.FloatTipUISkin = (function (_super) {
	__extends(FloatTipUISkin, _super);
	function FloatTipUISkin() {
		_super.call(this);
		this.skinParts = ["u_tipBG","u_tipLabel","u_tipGroup"];
		
		this.height = 58;
		this.width = 1136;
		this.elementsContent = [this.u_tipGroup_i()];
	}
	var _proto = FloatTipUISkin.prototype;

	_proto.u_tipGroup_i = function () {
		var t = new eui.Group();
		this.u_tipGroup = t;
		t.percentHeight = 100;
		t.horizontalCenter = 0;
		t.verticalCenter = 0;
		t.percentWidth = 100;
		t.elementsContent = [this.u_tipBG_i(),this.u_tipLabel_i()];
		return t;
	};
	_proto.u_tipBG_i = function () {
		var t = new eui.Image();
		this.u_tipBG = t;
		t.height = 57;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(156,9,3,39);
		t.source = "commonUI_json.commonUI_float_bg";
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_tipLabel_i = function () {
		var t = new eui.Label();
		this.u_tipLabel = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.lineSpacing = 8;
		t.maxWidth = 600;
		t.size = 26;
		t.text = "";
		t.textAlign = "center";
		t.textColor = 0xFFFFFF;
		t.verticalCenter = -5.5;
		t.wordWrap = true;
		return t;
	};
	return FloatTipUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/commonsUI/head/CommonHeadSkin.exml'] = window.CommonHeadSkin = (function (_super) {
	__extends(CommonHeadSkin, _super);
	function CommonHeadSkin() {
		_super.call(this);
		this.skinParts = ["u_txtMoney0","u_imgMoney0","u_mcMoney0","u_txtMoney1","u_imgMoney1","u_mcMoney1","u_imgNotice","u_txtNotice","u_mcNotice","u_txtTitle","u_btnClose","u_mcLeft","u_btnAdd","u_btnEntrance"];
		
		this.height = 110;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_mcMoney0_i(),this.u_mcMoney1_i(),this.u_mcNotice_i(),this.u_mcLeft_i(),this.u_btnAdd_i(),this.u_btnEntrance_i()];
	}
	var _proto = CommonHeadSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.right = 0;
		t.source = "commonUI_head_right";
		t.visible = true;
		t.y = 0;
		return t;
	};
	_proto.u_mcMoney0_i = function () {
		var t = new eui.Group();
		this.u_mcMoney0 = t;
		t.name = "u_mcMoney0";
		t.x = 752.928;
		t.y = 0.634;
		t.elementsContent = [this.u_txtMoney0_i(),this.u_imgMoney0_i()];
		return t;
	};
	_proto.u_txtMoney0_i = function () {
		var t = new eui.Label();
		this.u_txtMoney0 = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 18.5;
		t.multiline = false;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 18;
		t.text = "999,999";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.width = 86;
		t.y = 10.6;
		return t;
	};
	_proto.u_imgMoney0_i = function () {
		var t = new eui.Image();
		this.u_imgMoney0 = t;
		t.height = 39;
		t.source = "commonUI_icon_gold";
		t.visible = true;
		t.width = 39;
		t.x = 0;
		t.y = 1;
		return t;
	};
	_proto.u_mcMoney1_i = function () {
		var t = new eui.Group();
		this.u_mcMoney1 = t;
		t.name = "u_mcMoney1";
		t.x = 890;
		t.y = 0.634;
		t.elementsContent = [this.u_txtMoney1_i(),this.u_imgMoney1_i()];
		return t;
	};
	_proto.u_txtMoney1_i = function () {
		var t = new eui.Label();
		this.u_txtMoney1 = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 18.5;
		t.multiline = false;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 18;
		t.text = "999,999";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.width = 86;
		t.y = 10.6;
		return t;
	};
	_proto.u_imgMoney1_i = function () {
		var t = new eui.Image();
		this.u_imgMoney1 = t;
		t.height = 39;
		t.source = "commonUI_icon_juan";
		t.visible = true;
		t.width = 39;
		t.x = 0;
		t.y = 1;
		return t;
	};
	_proto.u_mcNotice_i = function () {
		var t = new eui.Group();
		this.u_mcNotice = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.touchEnabled = false;
		t.x = 320;
		t.y = 8.096;
		t.elementsContent = [this.u_imgNotice_i(),this._Image2_i(),this.u_txtNotice_i()];
		return t;
	};
	_proto.u_imgNotice_i = function () {
		var t = new eui.Image();
		this.u_imgNotice = t;
		t.scale9Grid = new egret.Rectangle(48,8,48,8);
		t.source = "commonUI_json.commonUI_di_1";
		t.visible = true;
		t.width = 420;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "commonUI_json.commonUI_laba";
		t.visible = true;
		t.x = 4;
		t.y = 3;
		return t;
	};
	_proto.u_txtNotice_i = function () {
		var t = new eui.Label();
		this.u_txtNotice = t;
		t.anchorOffsetX = 0;
		t.fontFamily = "Microsoft YaHei";
		t.multiline = false;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 17;
		t.strokeColor = 0x333333;
		t.text = "欢迎到来";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.wordWrap = false;
		t.x = 34;
		t.y = 4;
		return t;
	};
	_proto.u_mcLeft_i = function () {
		var t = new eui.Group();
		this.u_mcLeft = t;
		t.x = 0;
		t.y = -1;
		t.elementsContent = [this.u_txtTitle_i(),this.u_btnClose_i()];
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.multiline = false;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 20;
		t.text = "英雄";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 84.744;
		t.y = 8;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Group();
		this.u_btnClose = t;
		t.height = 35;
		t.width = 125;
		t.x = 5.98;
		t.elementsContent = [this._Image3_i(),this._Image4_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.alpha = 0;
		t.height = 35;
		t.scale9Grid = new egret.Rectangle(3,3,4,4);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_json.commonUI_box";
		t.width = 125;
		t.x = 0;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "commonUI_json.commonUI_btn_close_1";
		t.visible = true;
		t.x = 46;
		t.y = 6;
		return t;
	};
	_proto.u_btnAdd_i = function () {
		var t = new eui.Group();
		this.u_btnAdd = t;
		t.height = 35;
		t.width = 56;
		t.x = 1018.804;
		t.y = 2.102;
		t.elementsContent = [this._Image5_i(),this._Image6_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.alpha = 0;
		t.height = 35;
		t.scale9Grid = new egret.Rectangle(3,3,4,4);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_json.commonUI_box";
		t.width = 56;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.source = "commonUI_json.commonUI_head_add";
		t.x = 10.343;
		t.y = 4.598;
		return t;
	};
	_proto.u_btnEntrance_i = function () {
		var t = new eui.Group();
		this.u_btnEntrance = t;
		t.height = 37;
		t.width = 55;
		t.x = 1079.683;
		t.y = 1.041;
		t.elementsContent = [this._Image7_i(),this._Image8_i()];
		return t;
	};
	_proto._Image7_i = function () {
		var t = new eui.Image();
		t.alpha = 0;
		t.height = 37;
		t.scale9Grid = new egret.Rectangle(3,3,4,4);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_json.commonUI_box";
		t.width = 55;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image8_i = function () {
		var t = new eui.Image();
		t.source = "commonUI_json.commonUI_head_btn";
		t.x = 14.174;
		t.y = 8.429;
		return t;
	};
	return CommonHeadSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/commonsUI/HScrollBarSkin.exml'] = window.HScrollBarSkin = (function (_super) {
	__extends(HScrollBarSkin, _super);
	function HScrollBarSkin() {
		_super.call(this);
		this.skinParts = ["thumb"];
		
		this.height = 17;
		this.width = 390;
		this.elementsContent = [this._Image1_i(),this.thumb_i()];
	}
	var _proto = HScrollBarSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 390;
		t.rotation = 269.984;
		t.source = "commonUI_json.commonUI_img_line";
		t.x = 0;
		t.y = 10;
		return t;
	};
	_proto.thumb_i = function () {
		var t = new eui.Group();
		this.thumb = t;
		t.height = 17;
		t.width = 32;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image2_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 32;
		t.rotation = 270.168;
		t.source = "commonUI_json.commonUI_img_hk";
		t.width = 17;
		t.x = 0;
		t.y = 17;
		return t;
	};
	return HScrollBarSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/commonsUI/hslider/HSliderViewSkin.exml'] = window.HSliderViewSkin = (function (_super) {
	__extends(HSliderViewSkin, _super);
	function HSliderViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgHighlight","u_btnThumb"];
		
		this.height = 20;
		this.width = 375;
		this.elementsContent = [this._Group1_i(),this.u_btnThumb_i()];
	}
	var _proto = HSliderViewSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.verticalCenter = 0;
		t.elementsContent = [this._Image1_i(),this.u_imgHighlight_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(5,5,10,10);
		t.source = "gameSettingUI_json.gameSettingUI_slideBg";
		t.verticalCenter = 0;
		t.width = 375;
		t.x = 0;
		return t;
	};
	_proto.u_imgHighlight_i = function () {
		var t = new eui.Image();
		this.u_imgHighlight = t;
		t.scale9Grid = new egret.Rectangle(5,5,10,10);
		t.source = "gameSettingUI_json.gameSettingUI_slideValue";
		t.verticalCenter = 0;
		t.visible = true;
		t.width = 375;
		return t;
	};
	_proto.u_btnThumb_i = function () {
		var t = new eui.Image();
		this.u_btnThumb = t;
		t.anchorOffsetX = 10;
		t.source = "gameSettingUI_json.gameSettingUI_thumb";
		t.verticalCenter = 2;
		t.visible = true;
		t.width = 52;
		t.x = 6;
		return t;
	};
	return HSliderViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/commonsUI/pageBar/CommonPageBarSkin.exml'] = window.CommonPageBarSkin = (function (_super) {
	__extends(CommonPageBarSkin, _super);
	function CommonPageBarSkin() {
		_super.call(this);
		this.skinParts = ["u_btnBack","u_listItem","u_scrollerItem"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_btnBack_i(),this.u_scrollerItem_i()];
	}
	var _proto = CommonPageBarSkin.prototype;

	_proto.u_btnBack_i = function () {
		var t = new eui.Image();
		this.u_btnBack = t;
		t.height = 83;
		t.width = 63;
		t.x = 531;
		t.y = 1011;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 150;
		t.width = 456;
		t.x = 62;
		t.y = 999;
		t.viewport = this.u_listItem_i();
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.x = -124;
		t.y = -1998;
		return t;
	};
	return CommonPageBarSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/commonsUI/pageBar/CommonPageBtnSkin.exml'] = window.CommonPageBtnSkin = (function (_super) {
	__extends(CommonPageBtnSkin, _super);
	function CommonPageBtnSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBj"];
		
		this.height = 105;
		this.width = 115;
		this.elementsContent = [this.u_imgBj_i()];
	}
	var _proto = CommonPageBtnSkin.prototype;

	_proto.u_imgBj_i = function () {
		var t = new eui.Image();
		this.u_imgBj = t;
		t.horizontalCenter = 0;
		t.source = "userMainUI_json.userMainUI_d_bar_b";
		return t;
	};
	return CommonPageBtnSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/commonsUI/PopupMsgTipSkin.exml'] = window.PopupMsgTipSkin = (function (_super) {
	__extends(PopupMsgTipSkin, _super);
	function PopupMsgTipSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBj","u_txtMsg","u_txtLeft","u_btnLeft","u_txtRight","u_btnRight","u_txtTishiMsg","u_imgGou","u_mcTishi","u_txtCountdown"];
		
		this.height = 346;
		this.width = 625;
		this.elementsContent = [this.u_imgBj_i(),this.u_txtMsg_i(),this.u_btnLeft_i(),this.u_btnRight_i(),this.u_mcTishi_i(),this.u_txtCountdown_i(),this._Image4_i()];
	}
	var _proto = PopupMsgTipSkin.prototype;

	_proto.u_imgBj_i = function () {
		var t = new eui.Image();
		this.u_imgBj = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.source = "publicPopupUI_json.publicPopupUI_img_Bg";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.height = 120;
		t.horizontalCenter = 0;
		t.lineSpacing = 8;
		t.multiline = true;
		t.size = 20;
		t.strokeColor = 0xedb295;
		t.text = "苏打水法发顺丰啊发发发发荣企鹅王v";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.verticalAlign = "middle";
		t.visible = true;
		t.width = 485;
		t.wordWrap = true;
		t.y = 70;
		return t;
	};
	_proto.u_btnLeft_i = function () {
		var t = new eui.Group();
		this.u_btnLeft = t;
		t.height = 45;
		t.width = 107;
		t.x = 133;
		t.y = 252;
		t.elementsContent = [this._Image1_i(),this.u_txtLeft_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 45;
		t.scale9Grid = new egret.Rectangle(3,3,4,4);
		t.source = "publicPopupUI_json.publicPopupUI_btn_qx";
		t.width = 107;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtLeft_i = function () {
		var t = new eui.Label();
		this.u_txtLeft = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0.5;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 20;
		t.stroke = 1;
		t.strokeColor = 0x5b0101;
		t.text = "NO";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 10;
		return t;
	};
	_proto.u_btnRight_i = function () {
		var t = new eui.Group();
		this.u_btnRight = t;
		t.height = 45;
		t.width = 107;
		t.x = 385;
		t.y = 252;
		t.elementsContent = [this._Image2_i(),this.u_txtRight_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 45;
		t.scale9Grid = new egret.Rectangle(3,3,4,4);
		t.source = "publicPopupUI_json.publicPopupUI_btn_qr";
		t.visible = true;
		t.width = 107;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtRight_i = function () {
		var t = new eui.Label();
		this.u_txtRight = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 20;
		t.stroke = 1;
		t.strokeColor = 0xc56737;
		t.text = "YES";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 10;
		return t;
	};
	_proto.u_mcTishi_i = function () {
		var t = new eui.Group();
		this.u_mcTishi = t;
		t.horizontalCenter = 0;
		t.y = 210;
		t.layout = this._HorizontalLayout1_i();
		t.elementsContent = [this.u_txtTishiMsg_i(),this._Group1_i()];
		return t;
	};
	_proto._HorizontalLayout1_i = function () {
		var t = new eui.HorizontalLayout();
		return t;
	};
	_proto.u_txtTishiMsg_i = function () {
		var t = new eui.Label();
		this.u_txtTishiMsg = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.height = 33;
		t.lineSpacing = 8;
		t.multiline = true;
		t.right = 27;
		t.size = 20;
		t.strokeColor = 0xEDB295;
		t.text = "Not reminded";
		t.textAlign = "right";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.verticalAlign = "middle";
		t.wordWrap = true;
		t.y = 11.1;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 33;
		t.verticalCenter = 0;
		t.x = 194;
		t.elementsContent = [this._Image3_i(),this.u_imgGou_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "publicPopupUI_json.publicPopupUI_img_qx";
		t.verticalCenter = 0;
		t.x = 0;
		return t;
	};
	_proto.u_imgGou_i = function () {
		var t = new eui.Image();
		this.u_imgGou = t;
		t.source = "publicPopupUI_json.publicPopupUI_img_Dg";
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_txtCountdown_i = function () {
		var t = new eui.Label();
		this.u_txtCountdown = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.height = 33;
		t.right = 52;
		t.size = 16;
		t.stroke = 1;
		t.strokeColor = 0x3c342e;
		t.text = "5s后关闭";
		t.textAlign = "right";
		t.textColor = 0xFF0000;
		t.verticalAlign = "middle";
		t.y = 268.5;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "publicPopupUI_json.publicPopupUI_img_ts";
		t.y = 9.415;
		return t;
	};
	return PopupMsgTipSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/commonsUI/PopupPrizeSkin.exml'] = window.PopupPrizeSkin = (function (_super) {
	__extends(PopupPrizeSkin, _super);
	function PopupPrizeSkin() {
		_super.call(this);
		this.skinParts = ["btnClose","txtPrize","txtMsg","scrollerItem","txtLeft","btnLeft","txtRight","btnRight"];
		
		this.height = 460;
		this.width = 566;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this._Image3_i(),this._Image4_i(),this.btnClose_i(),this.txtPrize_i(),this.scrollerItem_i(),this.btnLeft_i(),this.btnRight_i()];
	}
	var _proto = PopupPrizeSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 454;
		t.scale9Grid = new egret.Rectangle(234,57,57,96);
		t.source = "commonPanelUI_json.commonPanelUI_panel_4";
		t.width = 567.67;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.alpha = 0.5;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 129.4;
		t.horizontalCenter = 1.5;
		t.scale9Grid = new egret.Rectangle(30,23,17,30);
		t.source = "commonsUI_json.commonUI_box_2";
		t.width = 513;
		t.y = 50.2;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0.5;
		t.source = "commonsUI_json.commonsUI_tishi";
		t.y = 3;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.alpha = 0.6;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 132;
		t.horizontalCenter = 0.5;
		t.scale9Grid = new egret.Rectangle(10,11,14,15);
		t.source = "commonsUI_json.commonUI_box_2";
		t.width = 507;
		t.y = 219;
		return t;
	};
	_proto.btnClose_i = function () {
		var t = new eui.Image();
		this.btnClose = t;
		t.source = "commonsUI_btn_close";
		t.x = 510.5;
		t.y = -3;
		return t;
	};
	_proto.txtPrize_i = function () {
		var t = new eui.Label();
		this.txtPrize = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.size = 26;
		t.text = "共获得以下收益(奖励已发送至背包)";
		t.textAlign = "left";
		t.textColor = 0x335b70;
		t.x = 36;
		t.y = 189.5;
		return t;
	};
	_proto.scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 99;
		t.width = 478;
		t.x = 46;
		t.y = 65.5;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 59;
		t.y = 161;
		t.elementsContent = [this.txtMsg_i()];
		return t;
	};
	_proto.txtMsg_i = function () {
		var t = new eui.Label();
		this.txtMsg = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.lineSpacing = 6;
		t.size = 21;
		t.text = "";
		t.textAlign = "center";
		t.textColor = 0xFFFFFF;
		t.width = 477;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.btnLeft_i = function () {
		var t = new eui.Group();
		this.btnLeft = t;
		t.x = 130;
		t.y = 366;
		t.elementsContent = [this._Image5_i(),this.txtLeft_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_btn_2";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.txtLeft_i = function () {
		var t = new eui.Label();
		this.txtLeft = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 24;
		t.strokeColor = 0xa05a38;
		t.text = "确定";
		t.textAlign = "center";
		t.textColor = 0x3b1601;
		t.verticalCenter = 0;
		return t;
	};
	_proto.btnRight_i = function () {
		var t = new eui.Group();
		this.btnRight = t;
		t.x = 334;
		t.y = 366;
		t.elementsContent = [this._Image6_i(),this.txtRight_i()];
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_btn_2";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.txtRight_i = function () {
		var t = new eui.Label();
		this.txtRight = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 24;
		t.strokeColor = 0xa05a38;
		t.text = "取消";
		t.textAlign = "center";
		t.textColor = 0x3b1601;
		t.verticalCenter = 0;
		return t;
	};
	return PopupPrizeSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/commonsUI/rule/RulePopupSkin.exml'] = window.RulePopupSkin = (function (_super) {
	__extends(RulePopupSkin, _super);
	function RulePopupSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBj","u_txtMsg","u_scrollerItem","u_btnClose","imgTitle"];
		
		this.height = 419;
		this.width = 540;
		this.elementsContent = [this.u_imgBj_i(),this.u_scrollerItem_i(),this.u_btnClose_i(),this.imgTitle_i()];
	}
	var _proto = RulePopupSkin.prototype;

	_proto.u_imgBj_i = function () {
		var t = new eui.Image();
		this.u_imgBj = t;
		t.anchorOffsetY = 0;
		t.height = 419;
		t.scale9Grid = new egret.Rectangle(236,101,7,3);
		t.source = "commonPanelUI_json.commonPanelUI_panel_4";
		t.width = 540;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 303;
		t.width = 470;
		t.x = 35;
		t.y = 72.5;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 59;
		t.y = 161;
		t.elementsContent = [this.u_txtMsg_i()];
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.lineSpacing = 10;
		t.size = 22;
		t.strokeColor = 0x453a32;
		t.text = "rule";
		t.textAlign = "left";
		t.textColor = 0x424c60;
		t.width = 470;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 40;
		t.left = 480;
		t.right = 20;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.width = 40;
		t.y = -3;
		return t;
	};
	_proto.imgTitle_i = function () {
		var t = new eui.Image();
		this.imgTitle = t;
		t.horizontalCenter = 0;
		t.source = "commonsUI_json.commonsUI_rule";
		t.y = 4;
		return t;
	};
	return RulePopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/commonsUI/VScrollBarSkin.exml'] = window.VScrollBarSkin = (function (_super) {
	__extends(VScrollBarSkin, _super);
	function VScrollBarSkin() {
		_super.call(this);
		this.skinParts = ["thumb"];
		
		this.height = 390;
		this.width = 17;
		this.elementsContent = [this._Image1_i(),this.thumb_i()];
	}
	var _proto = VScrollBarSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.percentHeight = 100;
		t.horizontalCenter = 0;
		t.source = "commonUI_json.commonUI_img_line";
		return t;
	};
	_proto.thumb_i = function () {
		var t = new eui.Group();
		this.thumb = t;
		t.height = 32;
		t.width = 17;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image2_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(4,8,6,15);
		t.source = "commonUI_json.commonUI_img_hk";
		t.visible = true;
		t.y = 0;
		return t;
	};
	return VScrollBarSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/courseUI/CourseUISkin.exml'] = window.CourseUISkin = (function (_super) {
	__extends(CourseUISkin, _super);
	function CourseUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgIcon","u_txtMsg","u_imgDian1","u_imgDian2","u_imgDian3","u_imgDian4","u_btnClose","u_btnLeft","u_btnRight","u_grpMc"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_imgIcon_i(),this.u_txtMsg_i(),this._Group1_i(),this.u_grpMc_i()];
	}
	var _proto = CourseUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "courseUI_json.courseUI_bg";
		t.verticalCenter = -20;
		t.visible = true;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.horizontalCenter = -2.5;
		t.source = "courseUI_json.courseUI_tips1";
		t.visible = true;
		t.y = 240;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.height = 41;
		t.horizontalCenter = 0;
		t.lineSpacing = 5;
		t.size = 18;
		t.stroke = 2;
		t.strokeColor = 0x581D20;
		t.text = "Click the plus sign to adjust the weapon magnification The higher the multiplier,the more money you get";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.width = 500;
		t.wordWrap = true;
		t.y = 389.934;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.visible = true;
		t.y = 424.934;
		t.elementsContent = [this.u_imgDian1_i(),this.u_imgDian2_i(),this.u_imgDian3_i(),this.u_imgDian4_i()];
		return t;
	};
	_proto.u_imgDian1_i = function () {
		var t = new eui.Image();
		this.u_imgDian1 = t;
		t.source = "courseUI_json.courseUI_icon1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgDian2_i = function () {
		var t = new eui.Image();
		this.u_imgDian2 = t;
		t.source = "courseUI_json.courseUI_icon1";
		t.visible = true;
		t.x = 33;
		t.y = 0;
		return t;
	};
	_proto.u_imgDian3_i = function () {
		var t = new eui.Image();
		this.u_imgDian3 = t;
		t.source = "courseUI_json.courseUI_icon1";
		t.visible = true;
		t.x = 66;
		t.y = 0;
		return t;
	};
	_proto.u_imgDian4_i = function () {
		var t = new eui.Image();
		this.u_imgDian4 = t;
		t.source = "courseUI_json.courseUI_icon1";
		t.visible = true;
		t.x = 99;
		t.y = 0;
		return t;
	};
	_proto.u_grpMc_i = function () {
		var t = new eui.Group();
		this.u_grpMc = t;
		t.x = 399.583;
		t.y = 179.464;
		t.elementsContent = [this.u_btnClose_i(),this.u_btnLeft_i(),this.u_btnRight_i()];
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 35;
		t.source = "courseUI_json.courseUI_close";
		t.visible = true;
		t.width = 37;
		t.x = 397;
		t.y = 0;
		return t;
	};
	_proto.u_btnLeft_i = function () {
		var t = new eui.Image();
		this.u_btnLeft = t;
		t.height = 77;
		t.scaleX = -1;
		t.source = "courseUI_json.courseUI_arrow1";
		t.visible = true;
		t.width = 69;
		t.x = 0;
		t.y = 103;
		return t;
	};
	_proto.u_btnRight_i = function () {
		var t = new eui.Image();
		this.u_btnRight = t;
		t.height = 77;
		t.source = "courseUI_json.courseUI_arrow2";
		t.visible = true;
		t.width = 69;
		t.x = 328;
		t.y = 103;
		return t;
	};
	return CourseUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/creatRoleUI/CreatRoleUISkin.exml'] = window.CreatRoleUISkin = (function (_super) {
	__extends(CreatRoleUISkin, _super);
	function CreatRoleUISkin() {
		_super.call(this);
		this.skinParts = ["u_txtName","u_btnRandomName","u_txtTime","u_txtTishi","u_txtSex","u_btnGame","u_btnMan","u_btnWoman","u_imgSex0","u_imgSex1"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this._Image3_i(),this._Image4_i(),this.u_txtName_i(),this.u_btnRandomName_i(),this.u_txtTime_i(),this.u_txtTishi_i(),this.u_txtSex_i(),this.u_btnGame_i(),this.u_btnMan_i(),this.u_btnWoman_i(),this.u_imgSex0_i(),this.u_imgSex1_i()];
	}
	var _proto = CreatRoleUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "creatRoleUI_bj_jpg";
		t.visible = true;
		t.x = -125;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "creatRole_json.creatRoleUI_bj";
		t.visible = true;
		t.x = 173.285;
		t.y = 274.845;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "creatRole_json.creatRoleUI_role";
		t.visible = true;
		t.x = 46.031;
		t.y = 177.125;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(18,13,17,13);
		t.source = "creatRole_json.creatRoleUI_kuang";
		t.width = 273;
		t.x = 491;
		t.y = 336.251;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.EditableText();
		this.u_txtName = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.border = false;
		t.height = 35;
		t.size = 24;
		t.strokeColor = 0xabafce;
		t.text = "dsadasdfa";
		t.textAlign = "center";
		t.textColor = 0xffffff;
		t.verticalAlign = "middle";
		t.visible = true;
		t.width = 223;
		t.x = 496;
		t.y = 339;
		return t;
	};
	_proto.u_btnRandomName_i = function () {
		var t = new eui.Image();
		this.u_btnRandomName = t;
		t.height = 37;
		t.source = "creatRole_json.creatRoleUI_shaizi";
		t.visible = true;
		t.width = 36;
		t.x = 723.813;
		t.y = 336.908;
		return t;
	};
	_proto.u_txtTime_i = function () {
		var t = new eui.Label();
		this.u_txtTime = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.lineSpacing = 6;
		t.size = 20;
		t.stroke = 2;
		t.strokeColor = 0x037739;
		t.text = "10s";
		t.textAlign = "left";
		t.textColor = 0x00ff00;
		t.x = 772.314;
		t.y = 351;
		return t;
	};
	_proto.u_txtTishi_i = function () {
		var t = new eui.Label();
		this.u_txtTishi = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.horizontalCenter = 63;
		t.lineSpacing = 6;
		t.size = 20;
		t.strokeColor = 0x037739;
		t.text = "title";
		t.textAlign = "center";
		t.textColor = 0x6D665C;
		t.y = 305.156;
		return t;
	};
	_proto.u_txtSex_i = function () {
		var t = new eui.Label();
		this.u_txtSex = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.lineSpacing = 6;
		t.right = 584;
		t.size = 20;
		t.strokeColor = 0x037739;
		t.text = "性别：";
		t.textAlign = "right";
		t.textColor = 0x6D665C;
		t.y = 409.188;
		return t;
	};
	_proto.u_btnGame_i = function () {
		var t = new eui.Image();
		this.u_btnGame = t;
		t.horizontalCenter = 70;
		t.source = "creatRole_json.creatRoleUI_btn";
		t.y = 461.969;
		return t;
	};
	_proto.u_btnMan_i = function () {
		var t = new eui.Group();
		this.u_btnMan = t;
		t.height = 41;
		t.width = 84;
		t.x = 554.5;
		t.y = 397.72;
		t.elementsContent = [this._Image5_i(),this._Image6_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "creatRole_json.creatRoleUI_gou_bj";
		t.x = 51.5;
		t.y = 4.25;
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.source = "creatRole_json.creatRoleUI_nan";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnWoman_i = function () {
		var t = new eui.Group();
		this.u_btnWoman = t;
		t.height = 41;
		t.width = 84;
		t.x = 656.09;
		t.y = 398.85;
		t.elementsContent = [this._Image7_i(),this._Image8_i()];
		return t;
	};
	_proto._Image7_i = function () {
		var t = new eui.Image();
		t.source = "creatRole_json.creatRoleUI_gou_bj";
		t.x = 51.94;
		t.y = 2.81;
		return t;
	};
	_proto._Image8_i = function () {
		var t = new eui.Image();
		t.source = "creatRole_json.creatRoleUI_nv";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgSex0_i = function () {
		var t = new eui.Image();
		this.u_imgSex0 = t;
		t.source = "creatRole_json.creatRoleUI_gou";
		t.x = 605.69;
		t.y = 395;
		return t;
	};
	_proto.u_imgSex1_i = function () {
		var t = new eui.Image();
		this.u_imgSex1 = t;
		t.source = "creatRole_json.creatRoleUI_gou";
		t.x = 706.813;
		t.y = 395;
		return t;
	};
	return CreatRoleUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/creatRoleUI/popup/CreateRolePopupSkin.exml'] = window.CreateRolePopupSkin = (function (_super) {
	__extends(CreateRolePopupSkin, _super);
	function CreateRolePopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtTips","u_btnRandom","u_txtName","u_txtSex","u_imgMan","u_imgBoy","u_btnMan","u_imgWonman","u_imgGirl","u_btnWonman","u_btnSure"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtTips_i(),this._Image3_i(),this.u_btnRandom_i(),this.u_txtName_i(),this.u_txtSex_i(),this.u_btnMan_i(),this.u_btnWonman_i(),this.u_btnSure_i()];
	}
	var _proto = CreateRolePopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 92;
		t.source = "creatRole_json.creatRoleUI_bj";
		t.verticalCenter = 0.5;
		t.visible = true;
		t.x = 38;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "creatRole_json.creatRoleUI_role";
		t.visible = true;
		t.x = 156;
		t.y = 83;
		return t;
	};
	_proto.u_txtTips_i = function () {
		var t = new eui.Label();
		this.u_txtTips = t;
		t.bold = true;
		t.fontFamily = "Microsoft JhengHei";
		t.horizontalCenter = 163.5;
		t.size = 20;
		t.text = "name";
		t.textAlign = "center";
		t.textColor = 0x6D665C;
		t.verticalAlign = "middle";
		t.x = 390;
		t.y = 221;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(18,13,17,13);
		t.source = "creatRole_json.creatRoleUI_kuang";
		t.width = 268.8;
		t.x = 597;
		t.y = 253;
		return t;
	};
	_proto.u_btnRandom_i = function () {
		var t = new eui.Image();
		this.u_btnRandom = t;
		t.height = 37;
		t.source = "creatRole_json.creatRoleUI_shaizi";
		t.width = 36;
		t.x = 825;
		t.y = 255;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.EditableText();
		this.u_txtName = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.height = 35;
		t.size = 24;
		t.text = "zzzzzzzzzzzz";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.width = 223;
		t.x = 602;
		t.y = 256;
		return t;
	};
	_proto.u_txtSex_i = function () {
		var t = new eui.Label();
		this.u_txtSex = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.right = 479;
		t.size = 20;
		t.text = "性别：";
		t.textAlign = "right";
		t.textColor = 0x6D665C;
		t.y = 328;
		return t;
	};
	_proto.u_btnMan_i = function () {
		var t = new eui.Group();
		this.u_btnMan = t;
		t.x = 659.5;
		t.y = 314;
		t.elementsContent = [this.u_imgMan_i(),this._Image4_i(),this.u_imgBoy_i()];
		return t;
	};
	_proto.u_imgMan_i = function () {
		var t = new eui.Image();
		this.u_imgMan = t;
		t.source = "creatRole_json.creatRoleUI_nan";
		t.x = 0;
		t.y = 3;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "creatRole_json.creatRoleUI_gou_bj";
		t.x = 47.5;
		t.y = 5.500000000000057;
		return t;
	};
	_proto.u_imgBoy_i = function () {
		var t = new eui.Image();
		this.u_imgBoy = t;
		t.source = "creatRole_json.creatRoleUI_gou";
		t.x = 48;
		t.y = 0;
		return t;
	};
	_proto.u_btnWonman_i = function () {
		var t = new eui.Group();
		this.u_btnWonman = t;
		t.x = 755.5;
		t.y = 314;
		t.elementsContent = [this.u_imgWonman_i(),this._Image5_i(),this.u_imgGirl_i()];
		return t;
	};
	_proto.u_imgWonman_i = function () {
		var t = new eui.Image();
		this.u_imgWonman = t;
		t.source = "creatRole_json.creatRoleUI_nv";
		t.x = 0;
		t.y = 3;
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "creatRole_json.creatRoleUI_gou_bj";
		t.x = 46.5;
		t.y = 5.500000000000057;
		return t;
	};
	_proto.u_imgGirl_i = function () {
		var t = new eui.Image();
		this.u_imgGirl = t;
		t.source = "creatRole_json.creatRoleUI_gou";
		t.x = 48;
		t.y = 0;
		return t;
	};
	_proto.u_btnSure_i = function () {
		var t = new eui.Image();
		this.u_btnSure = t;
		t.source = "creatRole_json.creatRoleUI_btn";
		t.x = 642;
		t.y = 378;
		return t;
	};
	return CreateRolePopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/drawCardUI/DrawCardUISkin.exml'] = window.skins.DrawCardUISkin = (function (_super) {
	__extends(DrawCardUISkin, _super);
	function DrawCardUISkin() {
		_super.call(this);
		this.skinParts = ["u_btnRewardPreview","u_txtRewardPreview","u_txtDrawCardDesc","u_btnOneDraw","u_txtOneDraw","u_txtCountDown","u_gpOneDraw","u_btnTenDraw","u_txtTenDraw","u_imgOneUnit","u_txtOnePrice","u_imgTenUnit","u_txtTenPrice"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_btnRewardPreview_i(),this.u_txtRewardPreview_i(),this.u_txtDrawCardDesc_i(),this.u_gpOneDraw_i(),this._Group1_i(),this.u_imgOneUnit_i(),this.u_txtOnePrice_i(),this.u_imgTenUnit_i(),this.u_txtTenPrice_i()];
	}
	var _proto = DrawCardUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "drawCardUI_json.drawCardUI_bg";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 188;
		t.y = 47;
		return t;
	};
	_proto.u_btnRewardPreview_i = function () {
		var t = new eui.Image();
		this.u_btnRewardPreview = t;
		t.source = "drawCardUI_json.drawCardUI_reward_btn";
		t.visible = true;
		t.x = 998;
		t.y = 298;
		return t;
	};
	_proto.u_txtRewardPreview_i = function () {
		var t = new eui.Label();
		this.u_txtRewardPreview = t;
		t.anchorOffsetX = 32;
		t.fontFamily = "Microsoft YaHei";
		t.size = 16;
		t.stroke = 2;
		t.text = "獎勵預覽";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 1019;
		t.y = 349;
		return t;
	};
	_proto.u_txtDrawCardDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDrawCardDesc = t;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 73.5;
		t.size = 16;
		t.stroke = 2;
		t.text = "首次10連召喚，必得紫色怪物圖鑒卡";
		t.visible = true;
		t.y = 443;
		return t;
	};
	_proto.u_gpOneDraw_i = function () {
		var t = new eui.Group();
		this.u_gpOneDraw = t;
		t.height = 68;
		t.visible = true;
		t.width = 188;
		t.x = 418;
		t.y = 484;
		t.elementsContent = [this.u_btnOneDraw_i(),this.u_txtOneDraw_i(),this.u_txtCountDown_i()];
		return t;
	};
	_proto.u_btnOneDraw_i = function () {
		var t = new eui.Image();
		this.u_btnOneDraw = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "drawCardUI_json.drawCardUI_btn_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtOneDraw_i = function () {
		var t = new eui.Label();
		this.u_txtOneDraw = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "召喚 1 次";
		t.textColor = 0xFFF7D2;
		t.touchEnabled = false;
		t.verticalCenter = -2;
		t.visible = true;
		return t;
	};
	_proto.u_txtCountDown_i = function () {
		var t = new eui.Label();
		this.u_txtCountDown = t;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.size = 16;
		t.stroke = 2;
		t.text = "29:59:59後免費";
		t.textColor = 0x85FF49;
		t.touchEnabled = false;
		t.visible = true;
		t.y = -4;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 68;
		t.visible = true;
		t.width = 188;
		t.x = 678;
		t.y = 484;
		t.elementsContent = [this.u_btnTenDraw_i(),this.u_txtTenDraw_i()];
		return t;
	};
	_proto.u_btnTenDraw_i = function () {
		var t = new eui.Image();
		this.u_btnTenDraw = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "drawCardUI_json.drawCardUI_btn_2";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtTenDraw_i = function () {
		var t = new eui.Label();
		this.u_txtTenDraw = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "召喚 10 次";
		t.textColor = 0xFFF7D2;
		t.touchEnabled = false;
		t.verticalCenter = -2;
		t.visible = true;
		return t;
	};
	_proto.u_imgOneUnit_i = function () {
		var t = new eui.Image();
		this.u_imgOneUnit = t;
		t.height = 20;
		t.source = "commonUI_icon_juan";
		t.visible = true;
		t.width = 20;
		t.x = 485.5;
		t.y = 554.5;
		return t;
	};
	_proto.u_txtOnePrice_i = function () {
		var t = new eui.Label();
		this.u_txtOnePrice = t;
		t.fontFamily = "Microsoft YaHei";
		t.size = 16;
		t.stroke = 2;
		t.text = "100";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 512;
		t.y = 557;
		return t;
	};
	_proto.u_imgTenUnit_i = function () {
		var t = new eui.Image();
		this.u_imgTenUnit = t;
		t.height = 20;
		t.source = "commonUI_icon_juan";
		t.visible = true;
		t.width = 20;
		t.x = 740.5;
		t.y = 554.5;
		return t;
	};
	_proto.u_txtTenPrice_i = function () {
		var t = new eui.Label();
		this.u_txtTenPrice = t;
		t.fontFamily = "Microsoft YaHei";
		t.size = 16;
		t.stroke = 2;
		t.text = "1000";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 766.5;
		t.y = 557;
		return t;
	};
	return DrawCardUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/drawCardUI/popup/DrawCardRewardPopupSkin.exml'] = window.skins.DrawCardRewardPopupSkin = (function (_super) {
	__extends(DrawCardRewardPopupSkin, _super);
	function DrawCardRewardPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtRewrdTitle","u_btnClose","u_listItem","u_scrollerItem"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtRewrdTitle_i(),this.u_btnClose_i(),this.u_scrollerItem_i()];
	}
	var _proto = DrawCardRewardPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 580;
		t.scale9Grid = new egret.Rectangle(29,78,31,6);
		t.source = "drawCardUI_json.drawCardUI_reward_bg";
		t.visible = true;
		t.width = 980;
		t.x = 78;
		t.y = 30;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 30;
		t.source = "drawCardUI_json.drawCardUI_reward_btn";
		t.visible = true;
		t.width = 28;
		t.x = 99;
		t.y = 51;
		return t;
	};
	_proto.u_txtRewrdTitle_i = function () {
		var t = new eui.Label();
		this.u_txtRewrdTitle = t;
		t.fontFamily = "Microsoft YaHei";
		t.size = 16;
		t.text = "獎勵預覽";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 139;
		t.y = 59.8;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 16;
		t.source = "commonUI_json.commonUI_btn_close_2";
		t.width = 16;
		t.x = 1022;
		t.y = 59;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 506;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 980;
		t.y = 102;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 506;
		t.width = 980;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		return t;
	};
	return DrawCardRewardPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/drawCardUI/popup/DrawCardSummonPopupSkin.exml'] = window.skins.DrawCardSummonPopupSkin = (function (_super) {
	__extends(DrawCardSummonPopupSkin, _super);
	function DrawCardSummonPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtSummonTitle","u_listItem","u_scrollerItem","u_btnDraw","u_txtDraw","u_imgUnit","u_txtPrice","u_btnClose","u_txtClose"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_txtSummonTitle_i(),this._Image1_i(),this._Image2_i(),this._Image3_i(),this.u_scrollerItem_i(),this._Group2_i(),this.u_imgUnit_i(),this.u_txtPrice_i(),this._Group3_i()];
	}
	var _proto = DrawCardSummonPopupSkin.prototype;

	_proto.u_txtSummonTitle_i = function () {
		var t = new eui.Label();
		this.u_txtSummonTitle = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "您獲得了";
		t.textColor = 0xF0E6B0;
		t.y = 70;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(0,0,1,2);
		t.source = "drawCardUI_json.drawCardUI_summon_line";
		t.width = 1380;
		t.y = 120;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "drawCardUI_json.drawCardUI_summon_bg";
		t.y = 122;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(0,0,1,2);
		t.source = "drawCardUI_json.drawCardUI_summon_line";
		t.width = 1380;
		t.y = 522;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 210;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 140;
		t.y = 217;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.height = 68;
		t.horizontalCenter = -160;
		t.visible = true;
		t.width = 188;
		t.y = 534;
		t.elementsContent = [this.u_btnDraw_i(),this.u_txtDraw_i()];
		return t;
	};
	_proto.u_btnDraw_i = function () {
		var t = new eui.Image();
		this.u_btnDraw = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "drawCardUI_json.drawCardUI_btn_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtDraw_i = function () {
		var t = new eui.Label();
		this.u_txtDraw = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "召喚 1 次";
		t.textColor = 0xFFF7D2;
		t.touchEnabled = false;
		t.verticalCenter = -2;
		t.visible = true;
		return t;
	};
	_proto.u_imgUnit_i = function () {
		var t = new eui.Image();
		this.u_imgUnit = t;
		t.height = 20;
		t.source = "commonUI_icon_juan";
		t.visible = true;
		t.width = 20;
		t.x = 374.383;
		t.y = 604.5;
		return t;
	};
	_proto.u_txtPrice_i = function () {
		var t = new eui.Label();
		this.u_txtPrice = t;
		t.fontFamily = "Microsoft YaHei";
		t.size = 16;
		t.stroke = 2;
		t.text = "100";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 400.883;
		t.y = 607;
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.height = 68;
		t.horizontalCenter = 169;
		t.visible = true;
		t.width = 188;
		t.x = 324;
		t.y = 534;
		t.elementsContent = [this.u_btnClose_i(),this.u_txtClose_i()];
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "drawCardUI_json.drawCardUI_btn_2";
		t.touchEnabled = true;
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtClose_i = function () {
		var t = new eui.Label();
		this.u_txtClose = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "完成";
		t.textColor = 0xFFF7D2;
		t.touchEnabled = false;
		t.verticalCenter = -2;
		t.visible = true;
		return t;
	};
	return DrawCardSummonPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/drawCardUI/popup/render/DrawCardRewardRenderSkin.exml'] = window.skins.DrawCardRewardRenderSkin = (function (_super) {
	__extends(DrawCardRewardRenderSkin, _super);
	function DrawCardRewardRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgIcon","u_txtName"];
		
		this.height = 210;
		this.width = 140;
		this.elementsContent = [this._Image1_i(),this.u_imgIcon_i(),this.u_txtName_i()];
	}
	var _proto = DrawCardRewardRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 210;
		t.scale9Grid = new egret.Rectangle(17,17,16,16);
		t.source = "commonUI_json.commonUI_icon_bg";
		t.visible = true;
		t.width = 140;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 206;
		t.width = 136;
		t.x = 2;
		t.y = 2;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "角色名称";
		t.textColor = 0xF0E6D2;
		t.y = 166;
		return t;
	};
	return DrawCardRewardRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/drawCardUI/popup/render/DrawCardSummonRenderSkin.exml'] = window.skins.DrawCardSummonRenderSkin = (function (_super) {
	__extends(DrawCardSummonRenderSkin, _super);
	function DrawCardSummonRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgIcon","u_txtName"];
		
		this.height = 210;
		this.width = 140;
		this.elementsContent = [this._Image1_i(),this.u_imgIcon_i(),this.u_txtName_i()];
	}
	var _proto = DrawCardSummonRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 210;
		t.scale9Grid = new egret.Rectangle(17,17,16,16);
		t.source = "commonUI_json.commonUI_icon_bg";
		t.visible = true;
		t.width = 140;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 206;
		t.width = 136;
		t.x = 2;
		t.y = 2;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "角色名称";
		t.textColor = 0xF0E6D2;
		t.y = 166;
		return t;
	};
	return DrawCardSummonRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/exchangeShopUI/ExchangeShopUISkin.exml'] = window.skins.ExchangeShopUISkin = (function (_super) {
	__extends(ExchangeShopUISkin, _super);
	function ExchangeShopUISkin() {
		_super.call(this);
		this.skinParts = ["u_itemName","u_mcItem","u_heroName","u_txtTitle","u_listItem","u_scrollerItem","u_btnClose","u_imgItem","u_txtHave","u_txtExchange","u_btnExchange","u_mcRight"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_mcItem_i(),this.u_heroName_i(),this.u_mcRight_i()];
	}
	var _proto = ExchangeShopUISkin.prototype;

	_proto.u_mcItem_i = function () {
		var t = new eui.Group();
		this.u_mcItem = t;
		t.visible = true;
		t.x = -1;
		t.y = 37;
		t.elementsContent = [this._Image1_i(),this.u_itemName_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "exchangeShopUI_json.exchangeShopUI_item_bg";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_itemName_i = function () {
		var t = new eui.Label();
		this.u_itemName = t;
		t.bold = true;
		t.horizontalCenter = -1;
		t.size = 28;
		t.stroke = 2;
		t.strokeColor = 0x14151A;
		t.text = "物品名称";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 364;
		return t;
	};
	_proto.u_heroName_i = function () {
		var t = new eui.Label();
		this.u_heroName = t;
		t.bold = true;
		t.size = 28;
		t.stroke = 2;
		t.strokeColor = 0x14151A;
		t.text = "雷霆武神·雷震子";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.width = 300;
		t.x = 20;
		t.y = 558;
		return t;
	};
	_proto.u_mcRight_i = function () {
		var t = new eui.Group();
		this.u_mcRight = t;
		t.visible = true;
		t.width = 660;
		t.x = 426;
		t.y = 95;
		t.elementsContent = [this._Image2_i(),this._Group1_i(),this.u_scrollerItem_i(),this.u_btnClose_i(),this._Group3_i(),this.u_btnExchange_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 390;
		t.scale9Grid = new egret.Rectangle(17,17,16,16);
		t.source = "exchangeShopUI_json.exchangeShopUI_bg";
		t.visible = true;
		t.width = 660;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.visible = true;
		t.y = 35;
		t.elementsContent = [this._Image3_i(),this._Image4_i(),this.u_txtTitle_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scaleX = -1;
		t.source = "exchangeShopUI_json.exchangeShopUI_icon_design";
		t.visible = true;
		t.x = -33;
		t.y = 0;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.right = -198;
		t.source = "exchangeShopUI_json.exchangeShopUI_icon_design";
		t.visible = true;
		t.y = 0;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.size = 18;
		t.text = "兑换商店";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 1;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.height = 290;
		t.visible = true;
		t.width = 580;
		t.x = 40;
		t.y = 83;
		t.viewport = this._Group2_i();
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 16;
		t.source = "commonUI_json.commonUI_btn_close_2";
		t.visible = true;
		t.width = 16;
		t.x = 628;
		t.y = 18;
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.visible = true;
		t.y = 411;
		t.elementsContent = [this.u_imgItem_i(),this.u_txtHave_i()];
		return t;
	};
	_proto.u_imgItem_i = function () {
		var t = new eui.Image();
		this.u_imgItem = t;
		t.height = 33;
		t.source = "exchangeShopUI_json.exchangeShopUI_item_icon";
		t.visible = true;
		t.width = 29;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtHave_i = function () {
		var t = new eui.Label();
		this.u_txtHave = t;
		t.size = 16;
		t.text = "拥有：9999";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 41;
		t.y = 9;
		return t;
	};
	_proto.u_btnExchange_i = function () {
		var t = new eui.Group();
		this.u_btnExchange = t;
		t.height = 50;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.visible = true;
		t.width = 210;
		t.y = 458.99999999999994;
		t.elementsContent = [this._Image5_i(),this.u_txtExchange_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "exchangeShopUI_json.exchangeShopUI_btn_bg";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtExchange_i = function () {
		var t = new eui.Label();
		this.u_txtExchange = t;
		t.bold = true;
		t.horizontalCenter = 1;
		t.size = 20;
		t.text = "兑 换";
		t.textColor = 0xF0E4B0;
		t.verticalCenter = 2;
		t.visible = true;
		return t;
	};
	return ExchangeShopUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/exchangeShopUI/render/ExchangeShopRenderSkin.exml'] = window.skins.ExchangeShopRenderSkin = (function (_super) {
	__extends(ExchangeShopRenderSkin, _super);
	function ExchangeShopRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgSelect","u_itemIcon","u_txtCost"];
		
		this.height = 133;
		this.width = 100;
		this.elementsContent = [this.u_imgSelect_i(),this.u_itemIcon_i(),this.u_txtCost_i()];
	}
	var _proto = ExchangeShopRenderSkin.prototype;

	_proto.u_imgSelect_i = function () {
		var t = new eui.Image();
		this.u_imgSelect = t;
		t.source = "exchangeShopUI_json.exchangeShopUI_select";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_itemIcon_i = function () {
		var t = new eui.Image();
		this.u_itemIcon = t;
		t.height = 33;
		t.scaleX = 0.7;
		t.scaleY = 0.7;
		t.source = "exchangeShopUI_json.exchangeShopUI_item_icon";
		t.visible = true;
		t.width = 29;
		t.x = 30;
		t.y = 109;
		return t;
	};
	_proto.u_txtCost_i = function () {
		var t = new eui.Label();
		this.u_txtCost = t;
		t.size = 16;
		t.text = "15";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 52;
		t.y = 114;
		return t;
	};
	return ExchangeShopRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/exchangeUI/ExchangeUISkin.exml'] = window.ExchangeUISkin = (function (_super) {
	__extends(ExchangeUISkin, _super);
	function ExchangeUISkin() {
		_super.call(this);
		this.skinParts = ["u_imBj","u_txtDesc","u_txtAfter","u_btnClose","u_imgIcon1","u_btnJian","u_btnJia","u_imgIcon2","u_txtAfterCoin","u_imgItemBj1","u_imgItem1","u_imgItemBj2","u_imgItem2","u_txtMax","u_btnMax","u_txtMin","u_btnMin","u_txtOK","u_btnOK","u_imgGou","u_mcTishi","u_txtHas","u_txtTixian","u_btnTixian","u_mcContent","u_txtInput"];
		
		this.height = 760;
		this.width = 640;
		this.elementsContent = [this.u_imBj_i(),this._Image1_i(),this.u_txtDesc_i(),this.u_txtAfter_i(),this._Image2_i(),this._Image3_i(),this._Image4_i(),this.u_btnClose_i(),this.u_imgIcon1_i(),this.u_btnJian_i(),this.u_btnJia_i(),this._Group1_i(),this._Group2_i(),this._Group3_i(),this.u_btnMax_i(),this.u_btnMin_i(),this.u_btnOK_i(),this.u_mcTishi_i(),this.u_mcContent_i(),this.u_txtInput_i()];
	}
	var _proto = ExchangeUISkin.prototype;

	_proto.u_imBj_i = function () {
		var t = new eui.Image();
		this.u_imBj = t;
		t.anchorOffsetY = 0;
		t.height = 753;
		t.scale9Grid = new egret.Rectangle(312,53,26,179);
		t.source = "commonPanelUI_json.commonPanelUI_panel_3";
		t.visible = true;
		t.x = 0;
		t.y = 3;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0.5;
		t.source = "exchangeUI_json.exchangeUI_title";
		t.y = 9;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "1 dollar = 1000 Gold coin ";
		t.textColor = 0x38445D;
		t.visible = true;
		t.y = 70;
		return t;
	};
	_proto.u_txtAfter_i = function () {
		var t = new eui.Label();
		this.u_txtAfter = t;
		t.bold = true;
		t.right = 434;
		t.size = 20;
		t.text = "After exchange";
		t.textColor = 0x38445D;
		t.visible = true;
		t.y = 263;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "exchangeUI_json.exchangeUI_arrow";
		t.visible = true;
		t.y = 120;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 31;
		t.scale9Grid = new egret.Rectangle(85,23,85,24);
		t.source = "exchangeUI_json.exchangeUI_di";
		t.visible = true;
		t.width = 222;
		t.x = 208;
		t.y = 207;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0.5;
		t.source = "exchangeUI_json.exchangeUI_ziti";
		t.y = 419;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.source = "commonsUI_json.commonsUI_btn_close_2";
		t.visible = true;
		t.x = 534;
		t.y = 5;
		return t;
	};
	_proto.u_imgIcon1_i = function () {
		var t = new eui.Image();
		this.u_imgIcon1 = t;
		t.height = 40;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.width = 40;
		t.x = 213;
		t.y = 202;
		return t;
	};
	_proto.u_btnJian_i = function () {
		var t = new eui.Image();
		this.u_btnJian = t;
		t.height = 31;
		t.source = "commonsUI_json.commonsUI_btn_jian2";
		t.visible = true;
		t.width = 31;
		t.x = 179;
		t.y = 206;
		return t;
	};
	_proto.u_btnJia_i = function () {
		var t = new eui.Image();
		this.u_btnJia = t;
		t.height = 31;
		t.source = "commonsUI_json.commonsUI_btn_add2";
		t.visible = true;
		t.width = 31;
		t.x = 429;
		t.y = 207;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 208;
		t.y = 252;
		t.elementsContent = [this._Image5_i(),this.u_imgIcon2_i(),this.u_txtAfterCoin_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.height = 31;
		t.scale9Grid = new egret.Rectangle(85,23,85,24);
		t.source = "exchangeUI_json.exchangeUI_di";
		t.visible = true;
		t.width = 222;
		t.x = 0;
		t.y = 5;
		return t;
	};
	_proto.u_imgIcon2_i = function () {
		var t = new eui.Image();
		this.u_imgIcon2 = t;
		t.height = 40;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.width = 40;
		t.x = 5;
		t.y = 0;
		return t;
	};
	_proto.u_txtAfterCoin_i = function () {
		var t = new eui.Label();
		this.u_txtAfterCoin = t;
		t.bold = true;
		t.horizontalCenter = 13;
		t.size = 22;
		t.text = "1000000";
		t.textColor = 0x38445D;
		t.visible = true;
		t.y = 10;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.x = 172;
		t.y = 103;
		t.elementsContent = [this.u_imgItemBj1_i(),this.u_imgItem1_i()];
		return t;
	};
	_proto.u_imgItemBj1_i = function () {
		var t = new eui.Image();
		this.u_imgItemBj1 = t;
		t.source = "commonsUI_json.commonsUI_item_bj_1";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgItem1_i = function () {
		var t = new eui.Image();
		this.u_imgItem1 = t;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.x = 380;
		t.y = 103;
		t.elementsContent = [this.u_imgItemBj2_i(),this.u_imgItem2_i()];
		return t;
	};
	_proto.u_imgItemBj2_i = function () {
		var t = new eui.Image();
		this.u_imgItemBj2 = t;
		t.source = "commonsUI_json.commonsUI_item_bj_1";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgItem2_i = function () {
		var t = new eui.Image();
		this.u_imgItem2 = t;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnMax_i = function () {
		var t = new eui.Group();
		this.u_btnMax = t;
		t.height = 31;
		t.visible = true;
		t.width = 68;
		t.x = 462;
		t.y = 207;
		t.elementsContent = [this._Image6_i(),this.u_txtMax_i()];
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.source = "bagUI_json.bagUI_box_3";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtMax_i = function () {
		var t = new eui.Label();
		this.u_txtMax = t;
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.size = 20;
		t.text = "Max";
		t.verticalCenter = -0.5;
		return t;
	};
	_proto.u_btnMin_i = function () {
		var t = new eui.Group();
		this.u_btnMin = t;
		t.height = 31;
		t.visible = true;
		t.width = 68;
		t.x = 109;
		t.y = 207;
		t.elementsContent = [this._Image7_i(),this.u_txtMin_i()];
		return t;
	};
	_proto._Image7_i = function () {
		var t = new eui.Image();
		t.source = "bagUI_json.bagUI_box_3";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtMin_i = function () {
		var t = new eui.Label();
		this.u_txtMin = t;
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.size = 20;
		t.text = "Min";
		t.verticalCenter = -0.5;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.height = 65;
		t.visible = true;
		t.width = 135;
		t.x = 253;
		t.y = 321;
		t.elementsContent = [this._Image8_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image8_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "OK";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_mcTishi_i = function () {
		var t = new eui.Group();
		this.u_mcTishi = t;
		t.x = 517;
		t.y = 430.4;
		t.elementsContent = [this._Image9_i(),this.u_imgGou_i()];
		return t;
	};
	_proto._Image9_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_gou _di";
		t.x = 0;
		t.y = 1;
		return t;
	};
	_proto.u_imgGou_i = function () {
		var t = new eui.Image();
		this.u_imgGou = t;
		t.source = "commonsUI_json.commonsUI_gou";
		t.x = 2;
		t.y = -1;
		return t;
	};
	_proto.u_mcContent_i = function () {
		var t = new eui.Group();
		this.u_mcContent = t;
		t.x = 35;
		t.y = 495;
		t.elementsContent = [this._Image10_i(),this.u_txtHas_i(),this.u_btnTixian_i()];
		return t;
	};
	_proto._Image10_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(74,23,444,138);
		t.source = "exchangeUI_json.exchangeUI_bj";
		t.width = 578;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtHas_i = function () {
		var t = new eui.Label();
		this.u_txtHas = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 26;
		t.text = "There is $56 to withdraw";
		t.textColor = 0xffffff;
		t.visible = true;
		t.y = 74;
		return t;
	};
	_proto.u_btnTixian_i = function () {
		var t = new eui.Group();
		this.u_btnTixian = t;
		t.visible = true;
		t.x = 203;
		t.y = 126;
		t.elementsContent = [this._Image11_i(),this.u_txtTixian_i()];
		return t;
	};
	_proto._Image11_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_5";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtTixian_i = function () {
		var t = new eui.Label();
		this.u_txtTixian = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.stroke = 2;
		t.strokeColor = 0x9b5c18;
		t.text = "Withdraw";
		t.textColor = 0xfff9c9;
		t.verticalCenter = 3;
		t.visible = true;
		return t;
	};
	_proto.u_txtInput_i = function () {
		var t = new eui.Label();
		this.u_txtInput = t;
		t.bold = true;
		t.horizontalCenter = 16;
		t.size = 22;
		t.text = "1000000";
		t.textAlign = "center";
		t.textColor = 0x38445D;
		t.visible = true;
		t.width = 168;
		t.y = 212.5;
		return t;
	};
	return ExchangeUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/firstRechargeUI/FirstRechargeUISkin.exml'] = window.skins.FirstRechargeUI = (function (_super) {
	__extends(FirstRechargeUI, _super);
	function FirstRechargeUI() {
		_super.call(this);
		this.skinParts = ["u_txtPropName0","u_gpPropBg0","u_txtPropName1","u_gpPropBg1","u_txtPropName2","u_gpPropBg2","u_btnRecharge","u_txtCloseTips"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Group1_i(),this.u_gpPropBg0_i(),this.u_gpPropBg1_i(),this.u_gpPropBg2_i(),this.u_btnRecharge_i(),this.u_txtCloseTips_i()];
	}
	var _proto = FirstRechargeUI.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "firstRechargeUI_json.firstRechargeUI_img_bg";
		t.verticalCenter = 0;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.touchChildren = false;
		t.touchEnabled = false;
		t.x = 50;
		t.y = 20;
		t.elementsContent = [this._Image2_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "firstRechargeUI_json.firstRechargeUI_img_js";
		t.touchEnabled = false;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_gpPropBg0_i = function () {
		var t = new eui.Group();
		this.u_gpPropBg0 = t;
		t.height = 158;
		t.width = 128;
		t.x = 524;
		t.y = 258;
		t.elementsContent = [this._Image3_i(),this.u_txtPropName0_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "firstRechargeUI_json.firstRechargeUI_img_iconBg";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtPropName0_i = function () {
		var t = new eui.Label();
		this.u_txtPropName0 = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "道具名稱";
		t.textColor = 0x882A2A;
		t.y = 116;
		return t;
	};
	_proto.u_gpPropBg1_i = function () {
		var t = new eui.Group();
		this.u_gpPropBg1 = t;
		t.height = 158;
		t.width = 128;
		t.x = 656;
		t.y = 258;
		t.elementsContent = [this._Image4_i(),this.u_txtPropName1_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "firstRechargeUI_json.firstRechargeUI_img_iconBg";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtPropName1_i = function () {
		var t = new eui.Label();
		this.u_txtPropName1 = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "道具名稱";
		t.textColor = 0x882A2A;
		t.y = 116;
		return t;
	};
	_proto.u_gpPropBg2_i = function () {
		var t = new eui.Group();
		this.u_gpPropBg2 = t;
		t.height = 158;
		t.width = 128;
		t.x = 788;
		t.y = 258;
		t.elementsContent = [this._Image5_i(),this.u_txtPropName2_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "firstRechargeUI_json.firstRechargeUI_img_iconBg";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtPropName2_i = function () {
		var t = new eui.Label();
		this.u_txtPropName2 = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "道具名稱";
		t.textColor = 0x882A2A;
		t.y = 116;
		return t;
	};
	_proto.u_btnRecharge_i = function () {
		var t = new eui.Group();
		this.u_btnRecharge = t;
		t.height = 63;
		t.width = 164;
		t.x = 640;
		t.y = 446;
		t.elementsContent = [this._Image6_i()];
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "firstRechargeUI_json.firstRechargeUI_btn_bg";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtCloseTips_i = function () {
		var t = new eui.Label();
		this.u_txtCloseTips = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "點擊空白處關閉窗口";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.y = 574;
		return t;
	};
	return FirstRechargeUI;
})(eui.Skin);generateEUI.paths['resource/eui_skins/gameSettingUI/GameSettingUISkin.exml'] = window.GameSettingUISkin = (function (_super) {
	__extends(GameSettingUISkin, _super);
	function GameSettingUISkin() {
		_super.call(this);
		this.skinParts = ["u_titleLb","u_btnClose","u_btnPerson","u_txtId","u_txtName","u_btnEdit","u_soundValue","u_mc_soundBg","u_effectValue","u_mc_soundeEffect","u_txtPlayerEff","u_btnPlayerEffect","u_mc_playerEffect","u_txtPlayer","u_btnPlayer","u_mc_player","u_btnName","u_btnAccount"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_titleLb_i(),this.u_btnClose_i(),this.u_btnPerson_i(),this.u_txtId_i(),this.u_txtName_i(),this.u_btnEdit_i(),this._Image5_i(),this.u_mc_soundBg_i(),this.u_mc_soundeEffect_i(),this.u_mc_playerEffect_i(),this.u_mc_player_i(),this.u_btnAccount_i()];
	}
	var _proto = GameSettingUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 497.833;
		t.scale9Grid = new egret.Rectangle(10,80,40,10);
		t.source = "gameSettingUI_json.gameSettingUI__setBg";
		t.visible = true;
		t.width = 557;
		t.x = 289.833;
		t.y = 61.5;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "gameSettingUI_json.gameSettingUI_set";
		t.visible = true;
		t.x = 310.5;
		t.y = 81.667;
		return t;
	};
	_proto.u_titleLb_i = function () {
		var t = new eui.Label();
		this.u_titleLb = t;
		t.bold = true;
		t.size = 16;
		t.text = "设置";
		t.textColor = 0xF0E4B0;
		t.x = 343;
		t.y = 89.666;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.source = "gameSettingUI_json.gameSettingUI_btn_close";
		t.x = 812;
		t.y = 90;
		return t;
	};
	_proto.u_btnPerson_i = function () {
		var t = new eui.Group();
		this.u_btnPerson = t;
		t.x = 432;
		t.y = 151;
		t.elementsContent = [this._Image3_i(),this._Image4_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.alpha = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "gameSettingUI_json.gameSettingUI_iconBg";
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "gameSettingUI_json.gameSettingUI_iconSet";
		t.visible = true;
		t.x = 59;
		t.y = 56;
		return t;
	};
	_proto.u_txtId_i = function () {
		var t = new eui.Label();
		this.u_txtId = t;
		t.fontFamily = "Microsoft YaHei";
		t.height = 20;
		t.size = 16;
		t.text = "ID：";
		t.textColor = 0xA5A5A5;
		t.verticalAlign = "middle";
		t.x = 533;
		t.y = 200;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.fontFamily = "Microsoft YaHei";
		t.height = 20;
		t.size = 16;
		t.text = "名稱";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.x = 533;
		t.y = 170;
		return t;
	};
	_proto.u_btnEdit_i = function () {
		var t = new eui.Image();
		this.u_btnEdit = t;
		t.source = "gameSettingUI_json.gameSettingUI_nameEdit";
		t.x = 678;
		t.y = 166;
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "gameSettingUI_json.gameSettingUI_line";
		t.width = 520;
		t.y = 250;
		return t;
	};
	_proto.u_mc_soundBg_i = function () {
		var t = new eui.Group();
		this.u_mc_soundBg = t;
		t.height = 50;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 474;
		t.y = 264;
		t.elementsContent = [this._Image6_i(),this.u_soundValue_i()];
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.source = "gameSettingUI_json.gameSettingUI_music";
		t.verticalCenter = 0;
		t.visible = true;
		t.x = 5;
		return t;
	};
	_proto.u_soundValue_i = function () {
		var t = new eui.Label();
		this.u_soundValue = t;
		t.size = 16;
		t.text = "70%";
		t.textAlign = "right";
		t.textColor = 0xF0E4B0;
		t.verticalCenter = 0;
		t.x = 432;
		return t;
	};
	_proto.u_mc_soundeEffect_i = function () {
		var t = new eui.Group();
		this.u_mc_soundeEffect = t;
		t.height = 50;
		t.horizontalCenter = 0;
		t.width = 474;
		t.y = 324;
		t.elementsContent = [this._Image7_i(),this.u_effectValue_i()];
		return t;
	};
	_proto._Image7_i = function () {
		var t = new eui.Image();
		t.source = "gameSettingUI_json.gameSettingUI_effect";
		t.verticalCenter = 0;
		t.x = 6;
		return t;
	};
	_proto.u_effectValue_i = function () {
		var t = new eui.Label();
		this.u_effectValue = t;
		t.size = 16;
		t.text = "70%";
		t.textAlign = "right";
		t.textColor = 0xF0E4B0;
		t.verticalCenter = 0;
		t.x = 432;
		return t;
	};
	_proto.u_mc_playerEffect_i = function () {
		var t = new eui.Group();
		this.u_mc_playerEffect = t;
		t.height = 55;
		t.visible = true;
		t.width = 226;
		t.x = 331;
		t.y = 384;
		t.elementsContent = [this.u_txtPlayerEff_i(),this.u_btnPlayerEffect_i()];
		return t;
	};
	_proto.u_txtPlayerEff_i = function () {
		var t = new eui.Label();
		this.u_txtPlayerEff = t;
		t.fontFamily = "Microsoft YaHei";
		t.size = 16;
		t.text = "顯示玩家特效：";
		t.textColor = 0xA5A5A5;
		t.verticalAlign = "middle";
		t.verticalCenter = 0;
		t.x = 10;
		return t;
	};
	_proto.u_btnPlayerEffect_i = function () {
		var t = new eui.Image();
		this.u_btnPlayerEffect = t;
		t.source = "gameSettingUI_json.gameSettingUI_btn_on";
		t.verticalCenter = 0;
		t.x = 134;
		return t;
	};
	_proto.u_mc_player_i = function () {
		var t = new eui.Group();
		this.u_mc_player = t;
		t.height = 55;
		t.visible = true;
		t.width = 226;
		t.x = 578;
		t.y = 384;
		t.elementsContent = [this.u_txtPlayer_i(),this.u_btnPlayer_i()];
		return t;
	};
	_proto.u_txtPlayer_i = function () {
		var t = new eui.Label();
		this.u_txtPlayer = t;
		t.fontFamily = "Microsoft YaHei";
		t.size = 16;
		t.text = "顯示其他玩家：";
		t.textColor = 0xA5A5A5;
		t.verticalAlign = "middle";
		t.verticalCenter = 0;
		t.x = 6;
		return t;
	};
	_proto.u_btnPlayer_i = function () {
		var t = new eui.Image();
		this.u_btnPlayer = t;
		t.source = "gameSettingUI_json.gameSettingUI_btn_off";
		t.verticalCenter = 0;
		t.x = 130;
		return t;
	};
	_proto.u_btnAccount_i = function () {
		var t = new eui.Group();
		this.u_btnAccount = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.x = 713;
		t.y = 464;
		t.elementsContent = [this._Image8_i(),this.u_btnName_i()];
		return t;
	};
	_proto._Image8_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.scale9Grid = new egret.Rectangle(64,15,2,3);
		t.source = "gameSettingUI_json.gameSettingUI_btn_bg";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnName_i = function () {
		var t = new eui.Label();
		this.u_btnName = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "切换账号";
		t.textColor = 0xF0E4B0;
		t.y = 14;
		return t;
	};
	return GameSettingUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/godDragonUI/GodDragonBtnSkin.exml'] = window.skins.GodDragonViewSkin = (function (_super) {
	__extends(GodDragonViewSkin, _super);
	function GodDragonViewSkin() {
		_super.call(this);
		this.skinParts = ["u_btnOpen","u_txtProgress","u_textTime","u_imgProgress"];
		
		this.height = 140;
		this.width = 106;
		this.elementsContent = [this._Group1_i()];
	}
	var _proto = GodDragonViewSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_btnOpen_i(),this.u_txtProgress_i(),this.u_textTime_i(),this._Image1_i(),this.u_imgProgress_i()];
		return t;
	};
	_proto.u_btnOpen_i = function () {
		var t = new eui.Image();
		this.u_btnOpen = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "godDragonUI_json.godDragonUI_rechage";
		t.x = 3;
		t.y = 5;
		return t;
	};
	_proto.u_txtProgress_i = function () {
		var t = new eui.Label();
		this.u_txtProgress = t;
		t.horizontalCenter = 2;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 18;
		t.text = "0/100";
		t.textColor = 0xF0E4B0;
		t.y = 61;
		return t;
	};
	_proto.u_textTime_i = function () {
		var t = new eui.Label();
		this.u_textTime = t;
		t.horizontalCenter = 2;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 18;
		t.text = "00:00";
		t.textColor = 0xF0E4B0;
		t.y = 116;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "vipUI_json.vipUI_jdt1";
		t.width = 90;
		t.x = 2;
		t.y = 81;
		return t;
	};
	_proto.u_imgProgress_i = function () {
		var t = new eui.Image();
		this.u_imgProgress = t;
		t.height = 20;
		t.source = "vipUI_json.vipUI_jdt2";
		t.width = 0;
		t.x = 2;
		t.y = 81;
		return t;
	};
	return GodDragonViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/godDragonUI/popup/GodDragonPopupSkin.exml'] = window.skins.GodDragonPopupSkin = (function (_super) {
	__extends(GodDragonPopupSkin, _super);
	function GodDragonPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_btnLottery","u_textTip","u_imgIcon","u_textTitle","u_grpCentre"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Group1_i()];
	}
	var _proto = GodDragonPopupSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_btnLottery_i(),this.u_textTip_i(),this.u_imgIcon_i(),this.u_textTitle_i(),this.u_grpCentre_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(339,189,338,188);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_json.commonUI_bg";
		t.width = 700;
		t.x = 60;
		t.y = 37;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_json.commonUI_btn_recharge";
		t.y = 33.38899999999995;
		return t;
	};
	_proto.u_btnLottery_i = function () {
		var t = new eui.Image();
		this.u_btnLottery = t;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_json.commonUI_btn_recharge";
		t.y = 460.5799999999999;
		return t;
	};
	_proto.u_textTip_i = function () {
		var t = new eui.Label();
		this.u_textTip = t;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 18;
		t.text = "祈福一次消耗100枚幸运币";
		t.x = 463;
		t.y = 513.17;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_json.commonUI_jiazai";
		t.visible = false;
		t.x = 329;
		t.y = 288.7130000000001;
		return t;
	};
	_proto.u_textTitle_i = function () {
		var t = new eui.Label();
		this.u_textTitle = t;
		t.horizontalCenter = 0;
		t.text = "恭喜";
		t.visible = false;
		t.y = 151.93;
		return t;
	};
	_proto.u_grpCentre_i = function () {
		var t = new eui.Group();
		this.u_grpCentre = t;
		t.horizontalCenter = 0;
		t.y = 272;
		return t;
	};
	return GodDragonPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessBossUI/GuessBossUISkin.exml'] = window.GuessBossUISkin = (function (_super) {
	__extends(GuessBossUISkin, _super);
	function GuessBossUISkin() {
		_super.call(this);
		this.skinParts = ["u_txtDesc","u_scrollerItem","u_btnChallenge"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_scrollerItem_i(),this.u_btnChallenge_i()];
	}
	var _proto = GuessBossUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = -1.5;
		t.source = "guessBossUI_json.guessBossUI_bg";
		t.visible = true;
		t.y = 103;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 163;
		t.horizontalCenter = -1.5;
		t.scale9Grid = new egret.Rectangle(189,64,189,1);
		t.source = "guessBossUI_json.guessBossUI_bg3";
		t.visible = true;
		t.y = 830;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 110;
		t.horizontalCenter = 0;
		t.width = 470;
		t.y = 856;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 59;
		t.elementsContent = [this.u_txtDesc_i()];
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.lineSpacing = 10;
		t.size = 22;
		t.strokeColor = 0x453A32;
		t.text = "rule";
		t.textAlign = "left";
		t.textColor = 0x424C60;
		t.width = 470;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnChallenge_i = function () {
		var t = new eui.Group();
		this.u_btnChallenge = t;
		t.height = 128;
		t.horizontalCenter = 6;
		t.visible = true;
		t.width = 142;
		t.y = 391;
		t.elementsContent = [this._Image3_i(),this._Image4_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_btn_6";
		t.visible = true;
		t.x = 3;
		t.y = 0;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "commonsUI_json.commonsUI_challenge";
		t.visible = true;
		t.y = 45;
		return t;
	};
	return GuessBossUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessBossUI/popup/GuessEffectPopupSkin.exml'] = window.GuessEffectPopupSkin = (function (_super) {
	__extends(GuessEffectPopupSkin, _super);
	function GuessEffectPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_imgBg_i()];
	}
	var _proto = GuessEffectPopupSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.horizontalCenter = 0;
		t.source = "guessEffectUI_json.guessEffectUI_bg";
		t.y = 395;
		return t;
	};
	return GuessEffectPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessBossUI/popup/GuessFightPopupSkin.exml'] = window.GuessFightPopupSkin = (function (_super) {
	__extends(GuessFightPopupSkin, _super);
	function GuessFightPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_imgBg_i()];
	}
	var _proto = GuessFightPopupSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.source = "guessFightUI_json.guessFightUI_bg";
		t.width = 800;
		t.x = -80;
		return t;
	};
	return GuessFightPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessBossUI/popup/GuessRecordPopupSkin.exml'] = window.GuessRecordPopupSkin = (function (_super) {
	__extends(GuessRecordPopupSkin, _super);
	function GuessRecordPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtDesc","u_listItem","u_scrollerItem","u_btnClose"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this.u_txtDesc_i(),this.u_scrollerItem_i(),this.u_btnClose_i()];
	}
	var _proto = GuessRecordPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 1.5;
		t.source = "guessRecordUI_json.guessRecordUI_bg2";
		t.visible = true;
		t.y = 110;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "Trend chart of boss killed in recent 50 games";
		t.y = 215;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 615;
		t.visible = true;
		t.width = 574;
		t.x = 34;
		t.y = 413;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 40;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.visible = true;
		t.width = 40;
		t.x = 567;
		t.y = 135;
		return t;
	};
	return GuessRecordPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessBossUI/popup/GuessResultPopupSkin.exml'] = window.GuessResultPopupSkin = (function (_super) {
	__extends(GuessResultPopupSkin, _super);
	function GuessResultPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_imgIcon","u_iconNum","u_txtMsg","u_grpBoss","u_imgTitle","u_txtMyCost","u_imgIcon1","u_txtCount1","u_costIcon","u_grpCost","u_grpContent","u_txtTotalCost","u_imgIcon2","u_txtCount2","u_txtOK","u_btnOK","u_btnClose"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_imgBg_i(),this.u_grpBoss_i(),this.u_grpContent_i(),this._Group3_i(),this.u_btnOK_i(),this.u_btnClose_i()];
	}
	var _proto = GuessResultPopupSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_bg";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_grpBoss_i = function () {
		var t = new eui.Group();
		this.u_grpBoss = t;
		t.horizontalCenter = 0;
		t.y = 306;
		t.elementsContent = [this._Group1_i(),this._Image2_i(),this.u_txtMsg_i()];
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.visible = true;
		t.y = 0;
		t.elementsContent = [this._Image1_i(),this.u_imgIcon_i(),this.u_iconNum_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "guessInsideUI_json.guessInsideUI_head";
		t.visible = true;
		t.x = 0;
		t.y = 25;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 155;
		t.scaleX = 0.9;
		t.scaleY = 0.9;
		t.visible = true;
		t.width = 139;
		t.x = -8;
		t.y = -4;
		return t;
	};
	_proto.u_iconNum_i = function () {
		var t = new eui.Image();
		this.u_iconNum = t;
		t.source = "guessInsideUI_json.guessInsideUI_srl_2";
		t.visible = true;
		t.x = 78;
		t.y = 31;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "guessInsideUI_json.guessInsideUI_title_1";
		t.visible = true;
		t.y = 103;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.lineSpacing = 10;
		t.size = 20;
		t.text = "Congratulations on winning the contest";
		t.textAlign = "center";
		t.visible = true;
		t.width = 400;
		t.wordWrap = true;
		t.y = 164;
		return t;
	};
	_proto.u_grpContent_i = function () {
		var t = new eui.Group();
		this.u_grpContent = t;
		t.visible = true;
		t.width = 551;
		t.x = 45;
		t.y = 197;
		t.elementsContent = [this.u_imgTitle_i(),this._Label1_i(),this._Group2_i(),this._Image3_i(),this._Image4_i(),this.u_grpCost_i()];
		return t;
	};
	_proto.u_imgTitle_i = function () {
		var t = new eui.Image();
		this.u_imgTitle = t;
		t.source = "guessInsideUI_json.guessInsideUI_title_2";
		t.visible = true;
		t.x = 189;
		t.y = 0;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.size = 20;
		t.visible = true;
		t.x = 145;
		t.y = 320;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.height = 20;
		t.horizontalCenter = 0;
		t.y = 320;
		t.elementsContent = [this.u_txtMyCost_i(),this.u_imgIcon1_i(),this.u_txtCount1_i()];
		return t;
	};
	_proto.u_txtMyCost_i = function () {
		var t = new eui.Label();
		this.u_txtMyCost = t;
		t.bold = true;
		t.size = 20;
		t.text = "Cost of killing boss：";
		t.visible = true;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgIcon1_i = function () {
		var t = new eui.Image();
		this.u_imgIcon1 = t;
		t.height = 50;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.visible = true;
		t.width = 50;
		t.x = 196;
		t.y = -15;
		return t;
	};
	_proto.u_txtCount1_i = function () {
		var t = new eui.Label();
		this.u_txtCount1 = t;
		t.bold = true;
		t.size = 20;
		t.text = "XXXX";
		t.textColor = 0xC9C9D6;
		t.visible = true;
		t.wordWrap = true;
		t.x = 245;
		t.y = 0;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "missionJieSuanUI_json.missionJieSuanUI_design";
		t.x = 59;
		t.y = 408;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "missionJieSuanUI_json.missionJieSuanUI_rewarded";
		t.visible = true;
		t.x = 218;
		t.y = 404;
		return t;
	};
	_proto.u_grpCost_i = function () {
		var t = new eui.Group();
		this.u_grpCost = t;
		t.horizontalCenter = 0.5;
		t.y = 472;
		t.elementsContent = [this.u_costIcon_i()];
		return t;
	};
	_proto.u_costIcon_i = function () {
		var t = new eui.Image();
		this.u_costIcon = t;
		t.height = 50;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.width = 50;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.height = 20;
		t.horizontalCenter = 0.5;
		t.y = 559;
		t.elementsContent = [this.u_txtTotalCost_i(),this.u_imgIcon2_i(),this.u_txtCount2_i()];
		return t;
	};
	_proto.u_txtTotalCost_i = function () {
		var t = new eui.Label();
		this.u_txtTotalCost = t;
		t.bold = true;
		t.size = 20;
		t.text = "Cost of killing boss：";
		t.visible = true;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgIcon2_i = function () {
		var t = new eui.Image();
		this.u_imgIcon2 = t;
		t.height = 50;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.visible = true;
		t.width = 50;
		t.x = 196;
		t.y = -15;
		return t;
	};
	_proto.u_txtCount2_i = function () {
		var t = new eui.Label();
		this.u_txtCount2 = t;
		t.bold = true;
		t.size = 20;
		t.text = "XXXX";
		t.textColor = 0xC9C9D6;
		t.visible = true;
		t.wordWrap = true;
		t.x = 245;
		t.y = 0;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.height = 65;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 135;
		t.y = 770;
		t.elementsContent = [this._Image5_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "OK";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 40;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.visible = true;
		t.width = 40;
		t.x = 567;
		t.y = 180;
		return t;
	};
	return GuessResultPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessBossUI/popup/GuessTishiPopupSkin.exml'] = window.GuessTishiPopupSkin = (function (_super) {
	__extends(GuessTishiPopupSkin, _super);
	function GuessTishiPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_btnClose","u_txtTishiMsg","u_imgGou","u_mcTishi"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this.u_btnClose_i(),this.u_mcTishi_i()];
	}
	var _proto = GuessTishiPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "gussTishiUI_json.gussTishiUI_bg";
		t.visible = true;
		t.y = 102;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 35;
		t.source = "gussTishiUI_json.gussTishiUI_close";
		t.width = 37;
		t.x = 534;
		t.y = 136;
		return t;
	};
	_proto.u_mcTishi_i = function () {
		var t = new eui.Group();
		this.u_mcTishi = t;
		t.horizontalCenter = 0.5;
		t.y = 950;
		t.layout = this._HorizontalLayout1_i();
		t.elementsContent = [this.u_txtTishiMsg_i(),this._Group1_i()];
		return t;
	};
	_proto._HorizontalLayout1_i = function () {
		var t = new eui.HorizontalLayout();
		return t;
	};
	_proto.u_txtTishiMsg_i = function () {
		var t = new eui.Label();
		this.u_txtTishiMsg = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.height = 33;
		t.lineSpacing = 8;
		t.multiline = true;
		t.right = 38;
		t.size = 22;
		t.strokeColor = 0xEDB295;
		t.text = "Not reminded";
		t.textAlign = "right";
		t.textColor = 0xFFFFFF;
		t.touchEnabled = false;
		t.verticalAlign = "middle";
		t.wordWrap = true;
		t.y = 11.1;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 150;
		t.y = 0;
		t.elementsContent = [this._Image2_i(),this.u_imgGou_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_gou _di";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgGou_i = function () {
		var t = new eui.Image();
		this.u_imgGou = t;
		t.source = "commonsUI_json.commonsUI_gou";
		t.x = 1;
		t.y = 0;
		return t;
	};
	return GuessTishiPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessBossUI/render/GuessMyCostRenderSkin.exml'] = window.GuessMyCostRenderSkin = (function (_super) {
	__extends(GuessMyCostRenderSkin, _super);
	function GuessMyCostRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgIcon","u_iconNum","u_txtCost","u_btnClick"];
		
		this.height = 129;
		this.width = 110;
		this.elementsContent = [this._Image1_i(),this.u_imgIcon_i(),this.u_iconNum_i(),this._Image2_i(),this.u_txtCost_i(),this.u_btnClick_i()];
	}
	var _proto = GuessMyCostRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "guessInsideUI_json.guessInsideUI_head";
		t.visible = true;
		t.x = 0;
		t.y = 25;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 155;
		t.horizontalCenter = 0;
		t.scaleX = 0.9;
		t.scaleY = 0.9;
		t.visible = true;
		t.width = 139;
		t.y = -4;
		return t;
	};
	_proto.u_iconNum_i = function () {
		var t = new eui.Image();
		this.u_iconNum = t;
		t.source = "guessInsideUI_json.guessInsideUI_srl_1";
		t.visible = true;
		t.x = 74;
		t.y = 28;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 28;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(46,9,45,9);
		t.source = "guessInsideUI_json.guessInsideUI_di_1";
		t.width = 99;
		t.x = 6;
		t.y = 101;
		return t;
	};
	_proto.u_txtCost_i = function () {
		var t = new eui.Label();
		this.u_txtCost = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "1234567";
		t.x = 16;
		t.y = 106;
		return t;
	};
	_proto.u_btnClick_i = function () {
		var t = new eui.Image();
		this.u_btnClick = t;
		t.alpha = 0;
		t.height = 115;
		t.scale9Grid = new egret.Rectangle(26,27,27,27);
		t.source = "commonsUI_json.commonUI_box_1";
		t.width = 110;
		t.x = 0;
		t.y = 13;
		return t;
	};
	return GuessMyCostRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessBossUI/render/GuessRecordRenderSkin.exml'] = window.GuessRecordRenderSkin = (function (_super) {
	__extends(GuessRecordRenderSkin, _super);
	function GuessRecordRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtId","u_ingIcon"];
		
		this.height = 55;
		this.width = 574;
		this.elementsContent = [this.u_txtId_i(),this._Image1_i(),this.u_ingIcon_i()];
	}
	var _proto = GuessRecordRenderSkin.prototype;

	_proto.u_txtId_i = function () {
		var t = new eui.Label();
		this.u_txtId = t;
		t.bold = true;
		t.size = 20;
		t.text = "49";
		t.textAlign = "center";
		t.textColor = 0xC8DAF8;
		t.verticalCenter = 0.5;
		t.visible = true;
		t.width = 40;
		t.x = 1;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "guessRecordUI_json.guessRecordUI_line";
		t.x = 1;
		t.y = 54;
		return t;
	};
	_proto.u_ingIcon_i = function () {
		var t = new eui.Image();
		this.u_ingIcon = t;
		t.source = "guessRecordUI_json.guessRecordUI_box1";
		t.visible = true;
		t.width = 94;
		t.x = 395;
		t.y = 0;
		return t;
	};
	return GuessRecordRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessBossUI/view/GuessBossAvatarSkin.exml'] = window.GuessBossAvatarSkin = (function (_super) {
	__extends(GuessBossAvatarSkin, _super);
	function GuessBossAvatarSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBossId"];
		
		this.height = 56;
		this.width = 130;
		this.elementsContent = [this._Image1_i(),this._Group1_i()];
	}
	var _proto = GuessBossAvatarSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.scale9Grid = new egret.Rectangle(107,19,107,18);
		t.source = "guessBossUI_json.guessBossUI_bg2";
		t.visible = true;
		t.width = 130;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.y = 8;
		t.elementsContent = [this._Image2_i(),this.u_imgBossId_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "guessInsideUI_json.guessInsideUI_boss_title";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgBossId_i = function () {
		var t = new eui.Image();
		this.u_imgBossId = t;
		t.source = "guessInsideUI_json.guessInsideUI_boss_1";
		t.visible = true;
		t.x = 77;
		t.y = 0;
		return t;
	};
	return GuessBossAvatarSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessBossUI/view/GuessBossHeadSkin.exml'] = window.GuessBossHeadSkin = (function (_super) {
	__extends(GuessBossHeadSkin, _super);
	function GuessBossHeadSkin() {
		_super.call(this);
		this.skinParts = ["u_imgIcon","u_iconNum","u_txtNum"];
		
		this.height = 124;
		this.width = 94;
		this.elementsContent = [this._Image1_i(),this.u_imgIcon_i(),this.u_iconNum_i(),this.u_txtNum_i()];
	}
	var _proto = GuessBossHeadSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.scaleX = 0.85;
		t.scaleY = 0.85;
		t.source = "guessInsideUI_json.guessInsideUI_head";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 155;
		t.horizontalCenter = 0;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.visible = true;
		t.width = 139;
		t.y = -28;
		return t;
	};
	_proto.u_iconNum_i = function () {
		var t = new eui.Image();
		this.u_iconNum = t;
		t.source = "guessInsideUI_json.guessInsideUI_srl_1";
		t.visible = true;
		t.x = 63;
		t.y = 1;
		return t;
	};
	_proto.u_txtNum_i = function () {
		var t = new eui.Label();
		this.u_txtNum = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "32";
		t.textColor = 0xF5D770;
		t.visible = true;
		t.y = 101;
		return t;
	};
	return GuessBossHeadSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessBossUI/view/GuessBossHPSkin.exml'] = window.GuessBossHPSkin = (function (_super) {
	__extends(GuessBossHPSkin, _super);
	function GuessBossHPSkin() {
		_super.call(this);
		this.skinParts = ["u_hpLineimg","u_hpimg","u_imgBossId","u_imgIcon","u_grpTotal"];
		
		this.height = 100;
		this.width = 206;
		this.elementsContent = [this._Group1_i(),this._Group2_i(),this.u_grpTotal_i()];
	}
	var _proto = GuessBossHPSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 0;
		t.y = 40;
		t.elementsContent = [this._Image1_i(),this.u_hpLineimg_i(),this.u_hpimg_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 22;
		t.scale9Grid = new egret.Rectangle(138,12,139,13);
		t.source = "commonsUI_json.commonsUI_jindu_3";
		t.visible = true;
		t.width = 206;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_hpLineimg_i = function () {
		var t = new eui.Image();
		this.u_hpLineimg = t;
		t.height = 12;
		t.scale9Grid = new egret.Rectangle(11,10,351,3);
		t.source = "commonsUI_json.commonsUI_jindu_8";
		t.visible = true;
		t.width = 174;
		t.x = 18;
		t.y = 3;
		return t;
	};
	_proto.u_hpimg_i = function () {
		var t = new eui.Image();
		this.u_hpimg = t;
		t.height = 12;
		t.scale9Grid = new egret.Rectangle(11,10,351,3);
		t.source = "commonsUI_json.commonsUI_jindu_2";
		t.visible = true;
		t.width = 174;
		t.x = 18;
		t.y = 3;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.y = 60;
		t.elementsContent = [this._Image2_i(),this.u_imgBossId_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "guessInsideUI_json.guessInsideUI_boss_title";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgBossId_i = function () {
		var t = new eui.Image();
		this.u_imgBossId = t;
		t.source = "guessInsideUI_json.guessInsideUI_boss_1";
		t.visible = true;
		t.x = 77;
		t.y = 0;
		return t;
	};
	_proto.u_grpTotal_i = function () {
		var t = new eui.Group();
		this.u_grpTotal = t;
		t.horizontalCenter = 0;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.y = 0;
		t.elementsContent = [this.u_imgIcon_i(),this._Image3_i()];
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 45;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.width = 45;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "guessInsideUI_json.guessInsideUI_cost_m";
		t.verticalCenter = 0;
		t.visible = true;
		t.x = 47;
		return t;
	};
	return GuessBossHPSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessBossUI/view/GuessMyCostSkin.exml'] = window.GuessMyCostSkin = (function (_super) {
	__extends(GuessMyCostSkin, _super);
	function GuessMyCostSkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_scrollerItem","u_grpCost","u_btnShow"];
		
		this.height = 341;
		this.width = 390;
		this.elementsContent = [this.u_grpCost_i(),this.u_btnShow_i()];
	}
	var _proto = GuessMyCostSkin.prototype;

	_proto.u_grpCost_i = function () {
		var t = new eui.Group();
		this.u_grpCost = t;
		t.right = 8;
		t.y = 50;
		t.elementsContent = [this._Image1_i(),this.u_scrollerItem_i(),this._Image2_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "guessInsideUI_json.guessInsideUI_bg";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 250;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 372;
		t.y = 29;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.bottom = 0;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "guessInsideUI_json.guessInsideUI_cost";
		t.visible = true;
		t.x = 147;
		t.y = 10;
		return t;
	};
	_proto.u_btnShow_i = function () {
		var t = new eui.Image();
		this.u_btnShow = t;
		t.right = 0;
		t.source = "commonsUI_json.commonsUI_back_3";
		t.visible = true;
		t.y = 0;
		return t;
	};
	return GuessMyCostSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessBossUI/view/GuessTotalSkin.exml'] = window.GuessTotalSkin = (function (_super) {
	__extends(GuessTotalSkin, _super);
	function GuessTotalSkin() {
		_super.call(this);
		this.skinParts = ["u_imgIcon","u_grpTotal","u_imgBossId"];
		
		this.height = 60;
		this.width = 260;
		this.elementsContent = [this.u_grpTotal_i(),this._Group1_i()];
	}
	var _proto = GuessTotalSkin.prototype;

	_proto.u_grpTotal_i = function () {
		var t = new eui.Group();
		this.u_grpTotal = t;
		t.horizontalCenter = 0;
		t.y = 6;
		t.elementsContent = [this.u_imgIcon_i(),this._Image1_i()];
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 45;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.width = 45;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "guessInsideUI_json.guessInsideUI_cost_m";
		t.verticalCenter = 0;
		t.visible = true;
		t.x = 47;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 6.5;
		t.y = -39;
		t.elementsContent = [this._Image2_i(),this.u_imgBossId_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "guessInsideUI_json.guessInsideUI_boss_title";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgBossId_i = function () {
		var t = new eui.Image();
		this.u_imgBossId = t;
		t.source = "guessInsideUI_json.guessInsideUI_boss_1";
		t.visible = true;
		t.x = 77;
		t.y = 0;
		return t;
	};
	return GuessTotalSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessUI/GuessUISkin.exml'] = window.skins.GuessUISkin = (function (_super) {
	__extends(GuessUISkin, _super);
	function GuessUISkin() {
		_super.call(this);
		this.skinParts = ["u_textTime","u_grpUp"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_grpUp_i()];
	}
	var _proto = GuessUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessUI_json.guessUI_img_bg";
		t.x = 0;
		t.y = 80;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0.5;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessUI_json.guessUI_img_title";
		t.x = 0;
		t.y = 39.939;
		return t;
	};
	_proto.u_grpUp_i = function () {
		var t = new eui.Group();
		this.u_grpUp = t;
		t.x = 79.496;
		t.y = 53.227;
		t.elementsContent = [this.u_textTime_i(),this._Image3_i()];
		return t;
	};
	_proto.u_textTime_i = function () {
		var t = new eui.Label();
		this.u_textTime = t;
		t.left = 29;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 18;
		t.text = "剩余竞猜时间：0156";
		t.textAlign = "left";
		t.textColor = 0xFF0000;
		t.x = 31.50400000000002;
		t.y = 2.509;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessUI_json.guessUI_icon_warn";
		t.x = 0;
		t.y = 0;
		return t;
	};
	return GuessUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessUI/popup/GuessLoserPopupSkin.exml'] = window.skins.GuessLoserPopupSkin = (function (_super) {
	__extends(GuessLoserPopupSkin, _super);
	function GuessLoserPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_textTip","u_btnOK","u_textTitle"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Group1_i()];
	}
	var _proto = GuessLoserPopupSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.y = 0;
		t.elementsContent = [this._Image1_i(),this.u_textTip_i(),this._Image2_i(),this._Label1_i(),this.u_btnOK_i(),this.u_textTitle_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessWinUI_json.guessWinUI_img_bg_loser";
		t.visible = true;
		t.y = 74.178;
		return t;
	};
	_proto.u_textTip_i = function () {
		var t = new eui.Label();
		this.u_textTip = t;
		t.size = 16;
		t.text = "点击叩拜出关闭窗口";
		t.textColor = 0xF0E4B0;
		t.x = 428;
		t.y = 543.234;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "guessWinUI_json.guessWinUI_img_loser";
		t.x = 448.098;
		t.y = 183;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.text = "Label";
		t.visible = false;
		t.x = 457.201;
		t.y = 277.685;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Image();
		this.u_btnOK = t;
		t.source = "guessWinUI_json.guessWinUI_confirm_disabled";
		t.x = 444.608;
		t.y = 368.49;
		return t;
	};
	_proto.u_textTitle_i = function () {
		var t = new eui.Label();
		this.u_textTitle = t;
		t.horizontalCenter = 0;
		t.size = 18;
		t.text = "Label";
		t.textColor = 0xF0E4B0;
		t.y = 281.571;
		return t;
	};
	return GuessLoserPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessUI/popup/GuessWinPopupSkin.exml'] = window.skins.GuessFinalPopupSkin = (function (_super) {
	__extends(GuessFinalPopupSkin, _super);
	function GuessFinalPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_btnOK","u_textTip2","u_imgIcon0","u_grpAtkTable","u_textTitle","u_textTip1","u_imgSingle","u_imgDouble","u_imgIcon1","u_grpType1","u_imgMin","u_imgMax","u_imgIcon2","u_grpType2","u_imgIcon3","u_grpType3","u_grpPos","u_imgGold"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Group1_i()];
	}
	var _proto = GuessFinalPopupSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.y = 0;
		t.elementsContent = [this._Image1_i(),this.u_btnOK_i(),this.u_textTip2_i(),this.u_grpAtkTable_i(),this._Image4_i(),this.u_textTitle_i(),this.u_textTip1_i(),this.u_grpPos_i(),this.u_imgGold_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessWinUI_json.guessWinUI_img_bg_win2";
		t.visible = true;
		t.x = 72;
		t.y = 42.837999999999965;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Image();
		this.u_btnOK = t;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessWinUI_json.guessWinUI_confirm_normal";
		t.y = 474.9999999999999;
		return t;
	};
	_proto.u_textTip2_i = function () {
		var t = new eui.Label();
		this.u_textTip2 = t;
		t.horizontalCenter = 6.5;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 16;
		t.text = "5秒后自动关闭或者点击空白处关闭窗口";
		t.textColor = 0xF0E4B0;
		t.y = 538.464;
		return t;
	};
	_proto.u_grpAtkTable_i = function () {
		var t = new eui.Group();
		this.u_grpAtkTable = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.y = 368;
		t.elementsContent = [this._Image2_i(),this._Image3_i(),this.u_imgIcon0_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessWinUI_json.guessWinUI_img_db";
		t.x = -0.9999999999999716;
		t.y = 5.999999999999886;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "guessWinUI_json.guessWinUI_img_zgj";
		t.x = 19.373;
		t.y = 10;
		return t;
	};
	_proto.u_imgIcon0_i = function () {
		var t = new eui.Image();
		this.u_imgIcon0 = t;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.x = 83.52;
		t.y = 17;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "guessWinUI_json.guessWinUI_img_win";
		t.y = 147.711;
		return t;
	};
	_proto.u_textTitle_i = function () {
		var t = new eui.Label();
		this.u_textTitle = t;
		t.horizontalCenter = 1.5;
		t.size = 18;
		t.text = "恭喜您击败BOSS获得奖励";
		t.textColor = 0xF0E4B0;
		t.y = 221.502;
		return t;
	};
	_proto.u_textTip1_i = function () {
		var t = new eui.Label();
		this.u_textTip1 = t;
		t.horizontalCenter = -1;
		t.size = 16;
		t.text = "额外竞猜奖励";
		t.textColor = 0xF0E4B0;
		t.y = 340.381;
		return t;
	};
	_proto.u_grpPos_i = function () {
		var t = new eui.Group();
		this.u_grpPos = t;
		t.visible = false;
		t.x = 118;
		t.y = 366;
		t.elementsContent = [this.u_grpType1_i(),this.u_grpType2_i(),this.u_grpType3_i()];
		return t;
	};
	_proto.u_grpType1_i = function () {
		var t = new eui.Group();
		this.u_grpType1 = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.visible = true;
		t.x = -0.01999999999998181;
		t.y = 1.2719999999999914;
		t.elementsContent = [this._Image5_i(),this.u_imgSingle_i(),this.u_imgDouble_i(),this.u_imgIcon1_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessWinUI_json.guessWinUI_img_db";
		t.visible = true;
		t.x = -0.9999999999999716;
		t.y = 5.999999999999886;
		return t;
	};
	_proto.u_imgSingle_i = function () {
		var t = new eui.Image();
		this.u_imgSingle = t;
		t.source = "guessWinUI_json.guessWinUI_img_dan";
		t.visible = true;
		t.x = 32.466;
		t.y = 16.534;
		return t;
	};
	_proto.u_imgDouble_i = function () {
		var t = new eui.Image();
		this.u_imgDouble = t;
		t.source = "guessWinUI_json.guessWinUI_img_shuang";
		t.visible = true;
		t.x = 34;
		t.y = 17;
		return t;
	};
	_proto.u_imgIcon1_i = function () {
		var t = new eui.Image();
		this.u_imgIcon1 = t;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.x = 84;
		t.y = 17;
		return t;
	};
	_proto.u_grpType2_i = function () {
		var t = new eui.Group();
		this.u_grpType2 = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.visible = true;
		t.x = 257.593;
		t.y = 0.48099999999999454;
		t.elementsContent = [this._Image6_i(),this.u_imgMin_i(),this.u_imgMax_i(),this.u_imgIcon2_i()];
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessWinUI_json.guessWinUI_img_db";
		t.visible = true;
		t.x = -0.9999999999999716;
		t.y = 5.999999999999886;
		return t;
	};
	_proto.u_imgMin_i = function () {
		var t = new eui.Image();
		this.u_imgMin = t;
		t.source = "guessWinUI_json.guessWinUI_img_small";
		t.visible = true;
		t.x = 36;
		t.y = 17;
		return t;
	};
	_proto.u_imgMax_i = function () {
		var t = new eui.Image();
		this.u_imgMax = t;
		t.source = "guessWinUI_json.guessWinUI_img_max";
		t.visible = false;
		t.x = 35;
		t.y = 17;
		return t;
	};
	_proto.u_imgIcon2_i = function () {
		var t = new eui.Image();
		this.u_imgIcon2 = t;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.visible = true;
		t.x = 85;
		t.y = 17;
		return t;
	};
	_proto.u_grpType3_i = function () {
		var t = new eui.Group();
		this.u_grpType3 = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.visible = true;
		t.x = 511.563;
		t.y = 0.48099999999999454;
		t.elementsContent = [this._Image7_i(),this._Image8_i(),this.u_imgIcon3_i()];
		return t;
	};
	_proto._Image7_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessWinUI_json.guessWinUI_img_db";
		t.visible = true;
		t.x = -0.9999999999999716;
		t.y = 5.999999999999886;
		return t;
	};
	_proto._Image8_i = function () {
		var t = new eui.Image();
		t.source = "guessWinUI_json.guessWinUI_img_hao";
		t.x = 45.461;
		t.y = 17.015;
		return t;
	};
	_proto.u_imgIcon3_i = function () {
		var t = new eui.Image();
		this.u_imgIcon3 = t;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.x = 85;
		t.y = 16;
		return t;
	};
	_proto.u_imgGold_i = function () {
		var t = new eui.Image();
		this.u_imgGold = t;
		t.anchorOffsetX = 50;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "commonUI_json.commonUI_icon_gold";
		t.x = 451.152;
		t.y = 262.176;
		return t;
	};
	return GuessFinalPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessUI/render/GuessAtkRenderSkin.exml'] = window.skins.GuessAtkRenderSkin = (function (_super) {
	__extends(GuessAtkRenderSkin, _super);
	function GuessAtkRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_grpAll","u_grpMy","u_textTouch","u_textRate","u_imgSmall","u_imgBig","u_imgSelected"];
		
		this.height = 178;
		this.width = 219;
		this.elementsContent = [this._Group1_i()];
	}
	var _proto = GuessAtkRenderSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 178;
		t.visible = true;
		t.width = 219;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_grpAll_i(),this.u_grpMy_i(),this.u_textTouch_i(),this.u_textRate_i(),this.u_imgSmall_i(),this.u_imgBig_i(),this.u_imgSelected_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessUI_json.guessUI_img_bg5";
		t.visible = true;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0.5;
		t.source = "guessUI_json.guessUI_img_zgj";
		t.visible = true;
		t.y = 17.674;
		return t;
	};
	_proto.u_grpAll_i = function () {
		var t = new eui.Group();
		this.u_grpAll = t;
		t.visible = false;
		t.x = 50.76;
		t.y = 95.311;
		t.elementsContent = [this._Image3_i(),this._Image4_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessUI_json.guessUI_img_sum";
		t.visible = true;
		t.x = 0.914;
		t.y = 8.123;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.visible = true;
		t.x = 25.13;
		t.y = 6.254;
		return t;
	};
	_proto.u_grpMy_i = function () {
		var t = new eui.Group();
		this.u_grpMy = t;
		t.visible = false;
		t.x = 51.182;
		t.y = 126.75;
		t.elementsContent = [this._Image5_i(),this._Image6_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessUI_json.guessUI_img_me";
		t.visible = true;
		t.x = 0.321;
		t.y = 8.131;
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.visible = true;
		t.x = 24.537;
		t.y = 7.798;
		return t;
	};
	_proto.u_textTouch_i = function () {
		var t = new eui.Label();
		this.u_textTouch = t;
		t.horizontalCenter = 0.5;
		t.size = 16;
		t.text = "点击竞猜";
		t.textColor = 0x75403D;
		t.visible = true;
		t.y = 140.678;
		return t;
	};
	_proto.u_textRate_i = function () {
		var t = new eui.Label();
		this.u_textRate = t;
		t.size = 18;
		t.text = "x5.5";
		t.textColor = 0x62463C;
		t.x = 169.338;
		t.y = 76.008;
		return t;
	};
	_proto.u_imgSmall_i = function () {
		var t = new eui.Image();
		this.u_imgSmall = t;
		t.horizontalCenter = -30.5;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "guessUI_json.guessUI_img_num_1";
		t.visible = false;
		t.y = 48.008;
		return t;
	};
	_proto.u_imgBig_i = function () {
		var t = new eui.Image();
		this.u_imgBig = t;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "guessUI_json.guessUI_img_num_9";
		t.visible = false;
		t.x = 98;
		return t;
	};
	_proto.u_imgSelected_i = function () {
		var t = new eui.Image();
		this.u_imgSelected = t;
		t.height = 178;
		t.scale9Grid = new egret.Rectangle(48,49,48,50);
		t.source = "guessUI_json.guessUI_img_selected2";
		t.visible = false;
		t.width = 219;
		return t;
	};
	return GuessAtkRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessUI/render/GuessChipRenderSkin.exml'] = window.skins.GuessChipRenderSkin = (function (_super) {
	__extends(GuessChipRenderSkin, _super);
	function GuessChipRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_grpChip","u_imgChip_Light"];
		
		this.height = 112;
		this.width = 106;
		this.elementsContent = [this._Group1_i()];
	}
	var _proto = GuessChipRenderSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.scaleX = 1;
		t.scaleY = 1;
		t.x = 0.664;
		t.y = 3.291;
		t.elementsContent = [this.u_grpChip_i(),this.u_imgChip_Light_i()];
		return t;
	};
	_proto.u_grpChip_i = function () {
		var t = new eui.Group();
		this.u_grpChip = t;
		t.scaleX = 1;
		t.scaleY = 1;
		return t;
	};
	_proto.u_imgChip_Light_i = function () {
		var t = new eui.Image();
		this.u_imgChip_Light = t;
		t.source = "guessUI_json.guessUI_img_selected1";
		t.visible = false;
		t.x = 0;
		t.y = -2;
		return t;
	};
	return GuessChipRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessUI/render/GuessPosBigRenderSkin.exml'] = window.skins.GuessPosBigRenderSkin = (function (_super) {
	__extends(GuessPosBigRenderSkin, _super);
	function GuessPosBigRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgNum","u_imgSelected","u_textTouch","u_grpMy","u_grpAll"];
		
		this.height = 148;
		this.width = 184;
		this.elementsContent = [this._Group1_i()];
	}
	var _proto = GuessPosBigRenderSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this._Image1_i(),this.u_imgNum_i(),this.u_imgSelected_i(),this.u_textTouch_i(),this.u_grpMy_i(),this.u_grpAll_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "guessUI_json.guessUI_img_bg4";
		t.visible = true;
		t.y = 0;
		return t;
	};
	_proto.u_imgNum_i = function () {
		var t = new eui.Image();
		this.u_imgNum = t;
		t.horizontalCenter = 0;
		t.source = "guessUI_json.guessUI_img_small";
		t.visible = false;
		t.y = 17.159;
		return t;
	};
	_proto.u_imgSelected_i = function () {
		var t = new eui.Image();
		this.u_imgSelected = t;
		t.height = 148;
		t.scale9Grid = new egret.Rectangle(48,49,48,50);
		t.source = "guessUI_json.guessUI_img_selected2";
		t.visible = false;
		t.width = 184;
		t.x = 0;
		t.y = -2.628;
		return t;
	};
	_proto.u_textTouch_i = function () {
		var t = new eui.Label();
		this.u_textTouch = t;
		t.size = 16;
		t.text = "点击竞猜";
		t.textColor = 0x62463C;
		t.visible = true;
		t.x = 60.438;
		t.y = 109.504;
		return t;
	};
	_proto.u_grpMy_i = function () {
		var t = new eui.Group();
		this.u_grpMy = t;
		t.visible = false;
		t.x = 45.599;
		t.y = 116.72;
		t.elementsContent = [this._Image2_i(),this._Image3_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessUI_json.guessUI_img_me";
		t.visible = true;
		t.x = 0.39;
		t.y = -1.021;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.visible = true;
		t.x = 24.989;
		t.y = -2.121;
		return t;
	};
	_proto.u_grpAll_i = function () {
		var t = new eui.Group();
		this.u_grpAll = t;
		t.visible = false;
		t.x = 45.683;
		t.y = 72.67;
		t.elementsContent = [this._Image4_i(),this._Image5_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessUI_json.guessUI_img_sum";
		t.x = 0.062;
		t.y = 9.022;
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.visible = true;
		t.x = 24.033;
		t.y = 6.69;
		return t;
	};
	return GuessPosBigRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessUI/render/GuessPosSmallRenderSkin.exml'] = window.skins.GuessPosSmallRender = (function (_super) {
	__extends(GuessPosSmallRender, _super);
	function GuessPosSmallRender() {
		_super.call(this);
		this.skinParts = ["u_imgNum","u_imgSelected","u_textTouch","u_grpAll","u_grpMy"];
		
		this.height = 148;
		this.width = 144;
		this.elementsContent = [this._Group1_i()];
	}
	var _proto = GuessPosSmallRender.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image1_i(),this.u_imgNum_i(),this._Image2_i(),this.u_imgSelected_i(),this.u_textTouch_i(),this.u_grpAll_i(),this.u_grpMy_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "guessUI_json.guessUI_img_bg3";
		t.visible = true;
		t.y = 0;
		return t;
	};
	_proto.u_imgNum_i = function () {
		var t = new eui.Image();
		this.u_imgNum = t;
		t.source = "guessUI_json.guessUI_img_num_1";
		t.visible = false;
		t.x = 32.995;
		t.y = 20.665;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "guessUI_json.guessUI_img_number";
		t.visible = true;
		t.x = 62.992;
		t.y = 26.998;
		return t;
	};
	_proto.u_imgSelected_i = function () {
		var t = new eui.Image();
		this.u_imgSelected = t;
		t.horizontalCenter = 0;
		t.source = "guessUI_json.guessUI_img_selected2";
		t.visible = false;
		t.y = -2;
		return t;
	};
	_proto.u_textTouch_i = function () {
		var t = new eui.Label();
		this.u_textTouch = t;
		t.size = 16;
		t.text = "点击竞猜";
		t.textColor = 0x62463C;
		t.x = 39.996;
		t.y = 97.667;
		return t;
	};
	_proto.u_grpAll_i = function () {
		var t = new eui.Group();
		this.u_grpAll = t;
		t.visible = false;
		t.x = 20.682;
		t.y = 72.736;
		t.elementsContent = [this._Image3_i(),this._Image4_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessUI_json.guessUI_img_sum";
		t.visible = true;
		t.x = 0.862;
		t.y = 9.344;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.visible = true;
		t.x = 25.525;
		t.y = 8.34;
		return t;
	};
	_proto.u_grpMy_i = function () {
		var t = new eui.Group();
		this.u_grpMy = t;
		t.visible = false;
		t.x = 20.456;
		t.y = 107.139;
		t.elementsContent = [this._Image5_i(),this._Image6_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessUI_json.guessUI_img_me";
		t.visible = true;
		t.x = 0.555;
		t.y = 7.313;
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.visible = true;
		t.x = 24.547;
		t.y = 6.985;
		return t;
	};
	return GuessPosSmallRender;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessUI/view/GuessAtkViewSkin.exml'] = window.skins.GuessAtkViewSkin = (function (_super) {
	__extends(GuessAtkViewSkin, _super);
	function GuessAtkViewSkin() {
		_super.call(this);
		this.skinParts = ["u_textTitle","u_btnClean","u_listItem","u_chipList","u_grpChip"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_textTitle_i(),this.u_btnClean_i(),this._Group1_i(),this.u_grpChip_i()];
	}
	var _proto = GuessAtkViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 448.267;
		t.horizontalCenter = 1;
		t.scale9Grid = new egret.Rectangle(39,39,40,40);
		t.source = "guessUI_json.guessUI_img_bg2";
		t.width = 939.617;
		t.y = 94.606;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(20,13,20,5);
		t.source = "guessUI_json.guessUI_img_txtBg";
		t.visible = true;
		t.width = 581.389;
		t.x = 276.995;
		t.y = 113.024;
		return t;
	};
	_proto.u_textTitle_i = function () {
		var t = new eui.Label();
		this.u_textTitle = t;
		t.size = 18;
		t.text = "BOSS【总攻击】是多少？";
		t.textColor = 0xF0E4B0;
		t.x = 467.307;
		t.y = 120.777;
		return t;
	};
	_proto.u_btnClean_i = function () {
		var t = new eui.Image();
		this.u_btnClean = t;
		t.source = "guessUI_json.guessUI_btn_clean";
		t.x = 848;
		t.y = 548.375;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 375.212;
		t.width = 910.07;
		t.x = 113.851;
		t.y = 153.732;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		return t;
	};
	_proto.u_grpChip_i = function () {
		var t = new eui.Group();
		this.u_grpChip = t;
		t.height = 118;
		t.width = 709;
		t.x = 122.706;
		t.y = 526.456;
		t.elementsContent = [this.u_chipList_i()];
		return t;
	};
	_proto.u_chipList_i = function () {
		var t = new eui.List();
		this.u_chipList = t;
		return t;
	};
	return GuessAtkViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessUI/view/GuessInfoViewSkin.exml'] = window.skins.GuessInfoViewSkin = (function (_super) {
	__extends(GuessInfoViewSkin, _super);
	function GuessInfoViewSkin() {
		_super.call(this);
		this.skinParts = ["u_textFight_Title","u_grpFight","u_textAtk_Title","u_grpAtkNum","u_grpAtk","u_grpInfo","u_btnEnter","u_textTime","u_grpIcon"];
		
		this.height = 220;
		this.width = 300;
		this.elementsContent = [this.u_grpInfo_i(),this.u_grpIcon_i()];
	}
	var _proto = GuessInfoViewSkin.prototype;

	_proto.u_grpInfo_i = function () {
		var t = new eui.Group();
		this.u_grpInfo = t;
		t.height = 0;
		t.width = 0;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this.u_grpAtk_i()];
		return t;
	};
	_proto.u_grpAtk_i = function () {
		var t = new eui.Group();
		this.u_grpAtk = t;
		t.elementsContent = [this.u_grpFight_i(),this.u_grpAtkNum_i()];
		return t;
	};
	_proto.u_grpFight_i = function () {
		var t = new eui.Group();
		this.u_grpFight = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.visible = true;
		t.elementsContent = [this._Image1_i(),this.u_textFight_Title_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_json.commonUI_img_wj";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_textFight_Title_i = function () {
		var t = new eui.Label();
		this.u_textFight_Title = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 14;
		t.text = "战斗时间：";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 11.221000000000004;
		t.y = 10.622000000000014;
		return t;
	};
	_proto.u_grpAtkNum_i = function () {
		var t = new eui.Group();
		this.u_grpAtkNum = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.y = 36.864;
		t.elementsContent = [this._Image2_i(),this.u_textAtk_Title_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_json.commonUI_img_wj";
		t.visible = true;
		t.x = 0.365;
		t.y = 1.112;
		return t;
	};
	_proto.u_textAtk_Title_i = function () {
		var t = new eui.Label();
		this.u_textAtk_Title = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 14;
		t.text = "攻击BOSS：";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 11.586;
		t.y = 11.397;
		return t;
	};
	_proto.u_grpIcon_i = function () {
		var t = new eui.Group();
		this.u_grpIcon = t;
		t.x = 4.221;
		t.y = 90;
		t.elementsContent = [this.u_btnEnter_i(),this.u_textTime_i()];
		return t;
	};
	_proto.u_btnEnter_i = function () {
		var t = new eui.Image();
		this.u_btnEnter = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "guessUI_json.guessUI_icon_boss";
		t.visible = true;
		t.x = -1.061000000000007;
		t.y = -0.9130000000000109;
		return t;
	};
	_proto.u_textTime_i = function () {
		var t = new eui.Label();
		this.u_textTime = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 16;
		t.text = "剩余： 01:55";
		t.textColor = 0xFF0000;
		t.x = 19.479;
		t.y = 88.996;
		return t;
	};
	return GuessInfoViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guessUI/view/GuessPosViewSkin.exml'] = window.skins.GuessPosViewSkin = (function (_super) {
	__extends(GuessPosViewSkin, _super);
	function GuessPosViewSkin() {
		_super.call(this);
		this.skinParts = ["u_textTitle","u_btnClean","u_textRateName0","u_textRate_1","u_textRateName1","u_textRate_0","u_textRate_2","u_listItem","u_listItem1","u_chipList","u_grpChip"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_textTitle_i(),this._Image3_i(),this._Image4_i(),this.u_btnClean_i(),this.u_textRateName0_i(),this.u_textRate_1_i(),this.u_textRateName1_i(),this.u_textRate_0_i(),this.u_textRate_2_i(),this._Group1_i(),this._Group2_i(),this.u_grpChip_i()];
	}
	var _proto = GuessPosViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 262.341;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(39,39,40,40);
		t.source = "guessUI_json.guessUI_img_bg2";
		t.width = 940.025;
		t.y = 94.31;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(20,13,20,5);
		t.source = "guessUI_json.guessUI_img_txtBg";
		t.visible = true;
		t.width = 581.389;
		t.x = 276.995;
		t.y = 113.024;
		return t;
	};
	_proto.u_textTitle_i = function () {
		var t = new eui.Label();
		this.u_textTitle = t;
		t.size = 18;
		t.text = "BOSS【总攻击】是多少？";
		t.textColor = 0xF0E4B0;
		t.x = 467.307;
		t.y = 120.777;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 189.192;
		t.scale9Grid = new egret.Rectangle(39,39,40,40);
		t.source = "guessUI_json.guessUI_img_bg2";
		t.width = 474.210431939394;
		t.x = 98.537;
		t.y = 354.354;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.height = 189.192;
		t.scale9Grid = new egret.Rectangle(39,39,40,40);
		t.source = "guessUI_json.guessUI_img_bg2";
		t.width = 474.210431939394;
		t.x = 565.027;
		t.y = 354.354;
		return t;
	};
	_proto.u_btnClean_i = function () {
		var t = new eui.Image();
		this.u_btnClean = t;
		t.source = "guessUI_json.guessUI_btn_clean";
		t.x = 848;
		t.y = 548.375;
		return t;
	};
	_proto.u_textRateName0_i = function () {
		var t = new eui.Label();
		this.u_textRateName0 = t;
		t.size = 18;
		t.text = "赔率";
		t.textColor = 0x62463C;
		t.visible = true;
		t.x = 316.437;
		t.y = 421.383;
		return t;
	};
	_proto.u_textRate_1_i = function () {
		var t = new eui.Label();
		this.u_textRate_1 = t;
		t.bold = true;
		t.size = 18;
		t.text = "x1.8";
		t.textColor = 0x62463C;
		t.visible = true;
		t.x = 316.489;
		t.y = 454.164;
		return t;
	};
	_proto.u_textRateName1_i = function () {
		var t = new eui.Label();
		this.u_textRateName1 = t;
		t.size = 18;
		t.text = "赔率";
		t.textColor = 0x62463C;
		t.visible = true;
		t.x = 784.606;
		t.y = 421.471;
		return t;
	};
	_proto.u_textRate_0_i = function () {
		var t = new eui.Label();
		this.u_textRate_0 = t;
		t.bold = true;
		t.size = 20;
		t.text = "赔率 x5.5";
		t.textColor = 0x62463C;
		t.visible = true;
		t.x = 523.879;
		t.y = 312.852;
		return t;
	};
	_proto.u_textRate_2_i = function () {
		var t = new eui.Label();
		this.u_textRate_2 = t;
		t.bold = true;
		t.size = 18;
		t.text = "x1.8";
		t.textColor = 0x62463C;
		t.visible = true;
		t.x = 784.658;
		t.y = 454.252;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 149.212;
		t.width = 905.07;
		t.x = 118.851;
		t.y = 153.732;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.height = 152.212;
		t.visible = true;
		t.width = 903.07;
		t.x = 123.851;
		t.y = 367.732;
		t.elementsContent = [this.u_listItem1_i()];
		return t;
	};
	_proto.u_listItem1_i = function () {
		var t = new eui.List();
		this.u_listItem1 = t;
		return t;
	};
	_proto.u_grpChip_i = function () {
		var t = new eui.Group();
		this.u_grpChip = t;
		t.height = 118;
		t.width = 709;
		t.x = 122.706;
		t.y = 526.456;
		t.elementsContent = [this.u_chipList_i()];
		return t;
	};
	_proto.u_chipList_i = function () {
		var t = new eui.List();
		this.u_chipList = t;
		t.scaleX = 1;
		t.scaleY = 1;
		return t;
	};
	return GuessPosViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guideUI/GuideDIalogUISkin.exml'] = window.GuideDIalogUISkin = (function (_super) {
	__extends(GuideDIalogUISkin, _super);
	function GuideDIalogUISkin() {
		_super.call(this);
		this.skinParts = ["u_txtMsg"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this.u_txtMsg_i()];
	}
	var _proto = GuideDIalogUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 191;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(9,10,61,61);
		t.source = "commonsUI_json.commonUI_box_1";
		t.width = 472;
		t.y = 706;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.lineSpacing = 6;
		t.size = 18;
		t.text = "三段式翻板阀二部发沙发出版社吃不完吃吧sw";
		t.textAlign = "left";
		t.textColor = 0xFFFFFF;
		t.width = 446;
		t.x = 97;
		t.y = 717;
		return t;
	};
	return GuideDIalogUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/guideUI/GuideViewSkin.exml'] = window.GuideViewSkin = (function (_super) {
	__extends(GuideViewSkin, _super);
	function GuideViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBj","u_txtMsg"];
		
		this.height = 109;
		this.width = 200;
		this.elementsContent = [this.u_imgBj_i(),this.u_txtMsg_i()];
	}
	var _proto = GuideViewSkin.prototype;

	_proto.u_imgBj_i = function () {
		var t = new eui.Image();
		this.u_imgBj = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 109;
		t.scale9Grid = new egret.Rectangle(24,20,71,21);
		t.source = "commonsUI_json.commonUI_box_3";
		t.width = 200;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.lineSpacing = 6;
		t.size = 18;
		t.text = "三段式翻板阀二部发沙发出版社吃不完吃吧sw";
		t.textAlign = "left";
		t.textColor = 0xFFFFFF;
		t.width = 182;
		t.wordWrap = true;
		t.x = 10;
		t.y = 12;
		return t;
	};
	return GuideViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/invRebateUI/InvRebateUISkin.exml'] = window.InvRebateUISkin = (function (_super) {
	__extends(InvRebateUISkin, _super);
	function InvRebateUISkin() {
		_super.call(this);
		this.skinParts = ["u_txtBuy","u_btnBuy","u_listItem","u_scrollerItem"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_btnBuy_i(),this.u_scrollerItem_i(),this._Image4_i(),this._Image5_i()];
	}
	var _proto = InvRebateUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 869;
		t.horizontalCenter = -1;
		t.scale9Grid = new egret.Rectangle(29,29,30,30);
		t.source = "commonsUI_json.commonUI_box_2";
		t.width = 590;
		t.y = 94;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "shareUI_json.shareUI_bg";
		t.x = 46;
		t.y = 116.764;
		return t;
	};
	_proto.u_btnBuy_i = function () {
		var t = new eui.Group();
		this.u_btnBuy = t;
		t.height = 65;
		t.width = 135;
		t.x = 407.271;
		t.y = 189.413;
		t.elementsContent = [this._Image3_i(),this.u_txtBuy_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.x = 1.531;
		t.y = -0.714;
		return t;
	};
	_proto.u_txtBuy_i = function () {
		var t = new eui.Label();
		this.u_txtBuy = t;
		t.bold = true;
		t.borderColor = 0x060605;
		t.text = "Buy";
		t.textColor = 0x573118;
		t.x = 38.735;
		t.y = 14.286;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.height = 663.092;
		t.horizontalCenter = 0.5;
		t.rotation = 359.942;
		t.width = 550;
		t.y = 288.88;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 667.255;
		t.horizontalCenter = 0;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.y = 3;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.height = 50;
		t.width = 142.233;
		t.x = 107.756;
		t.y = 144.252;
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.height = 50;
		t.width = 200;
		t.x = 107;
		t.y = 211;
		return t;
	};
	return InvRebateUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/invRebateUI/render/InvRebateRenderSkin.exml'] = window.InvRebateRenderSkin = (function (_super) {
	__extends(InvRebateRenderSkin, _super);
	function InvRebateRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtRecive","u_btnReciveRed","u_btnRecive","u_txtLoginDay"];
		
		this.height = 142;
		this.width = 547;
		this.elementsContent = [this._Image1_i(),this.u_btnRecive_i(),this.u_txtLoginDay_i()];
	}
	var _proto = InvRebateRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "shareUI_json.shareUI_di";
		t.x = -2;
		return t;
	};
	_proto.u_btnRecive_i = function () {
		var t = new eui.Group();
		this.u_btnRecive = t;
		t.height = 65;
		t.width = 135;
		t.x = 373.77;
		t.y = 48.828;
		t.elementsContent = [this._Image2_i(),this.u_txtRecive_i(),this.u_btnReciveRed_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 65;
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.width = 135;
		t.x = 1.604;
		t.y = 0.967;
		return t;
	};
	_proto.u_txtRecive_i = function () {
		var t = new eui.Label();
		this.u_txtRecive = t;
		t.size = 25;
		t.text = "Recive";
		t.textAlign = "center";
		t.textColor = 0x573118;
		t.verticalAlign = "middle";
		t.width = 100.862;
		t.x = 17.069;
		t.y = 19.5;
		return t;
	};
	_proto.u_btnReciveRed_i = function () {
		var t = new eui.Image();
		this.u_btnReciveRed = t;
		t.source = "commonsUI_json.commonsUI_red_1";
		t.x = 108.868;
		t.y = 3.835;
		return t;
	};
	_proto.u_txtLoginDay_i = function () {
		var t = new eui.Label();
		this.u_txtLoginDay = t;
		t.horizontalCenter = 168;
		t.size = 20;
		t.text = "Label";
		t.textAlign = "center";
		t.textColor = 0x33D426;
		t.verticalCenter = -40;
		t.width = 152.521;
		return t;
	};
	return InvRebateRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/loadingUI/LoadingMissionUISkin.exml'] = window.LoadingMissionUISkin = (function (_super) {
	__extends(LoadingMissionUISkin, _super);
	function LoadingMissionUISkin() {
		_super.call(this);
		this.skinParts = ["bg","hand1","hand2","ray1","ray2","star"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.bg_i(),this.hand1_i(),this.hand2_i(),this.ray1_i(),this.ray2_i(),this.star_i()];
	}
	var _proto = LoadingMissionUISkin.prototype;

	_proto.bg_i = function () {
		var t = new eui.Image();
		this.bg = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 243;
		t.scale9Grid = new egret.Rectangle(1,1,3,3);
		t.source = "loadingMissionUI_json.loadingMissionUI_bg";
		t.width = 192;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.hand1_i = function () {
		var t = new eui.Image();
		this.hand1 = t;
		t.scaleX = 2;
		t.scaleY = 2;
		t.source = "loadingMissionUI_json.loadingMissionUI_hard1";
		t.x = -29;
		t.y = 194.5;
		return t;
	};
	_proto.hand2_i = function () {
		var t = new eui.Image();
		this.hand2 = t;
		t.scaleX = 2;
		t.scaleY = 2;
		t.source = "loadingMissionUI_json.loadingMissionUI_hard2";
		t.x = 297;
		t.y = 521;
		return t;
	};
	_proto.ray1_i = function () {
		var t = new eui.Image();
		this.ray1 = t;
		t.scaleX = 4;
		t.scaleY = 4;
		t.source = "loadingMissionUI_json.loadingMissionUI_ray1";
		t.x = -92;
		t.y = -127;
		return t;
	};
	_proto.ray2_i = function () {
		var t = new eui.Image();
		this.ray2 = t;
		t.scaleX = 4;
		t.scaleY = 4;
		t.source = "loadingMissionUI_json.loadingMissionUI_ray2";
		t.x = 142;
		t.y = 152;
		return t;
	};
	_proto.star_i = function () {
		var t = new eui.Image();
		this.star = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.blendMode = "add";
		t.height = 381;
		t.scaleX = 2;
		t.scaleY = 2;
		t.source = "loadingMissionUI_json.loadingMissionUI_star";
		t.width = 381;
		t.x = -5.5;
		t.y = 259;
		return t;
	};
	return LoadingMissionUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/loginUI/LoginAnnounceSkin.exml'] = window.LoginAnnounceSkin = (function (_super) {
	__extends(LoginAnnounceSkin, _super);
	function LoginAnnounceSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBj","u_txtTitle","u_txtMsg","u_scrollerItem"];
		
		this.height = 640;
		this.width = 969;
		this.elementsContent = [this.u_imgBj_i(),this.u_txtTitle_i(),this.u_scrollerItem_i()];
	}
	var _proto = LoginAnnounceSkin.prototype;

	_proto.u_imgBj_i = function () {
		var t = new eui.Image();
		this.u_imgBj = t;
		t.anchorOffsetY = 0;
		t.height = 635;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(323,98,9,151);
		t.source = "loginUI_bg_1";
		t.visible = true;
		t.width = 810;
		t.y = 3;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 1;
		t.italic = true;
		t.size = 26;
		t.stroke = 2;
		t.text = "Title";
		t.textColor = 0xFFE062;
		t.x = 248;
		t.y = 13.61;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 521;
		t.horizontalCenter = 0;
		t.width = 694;
		t.y = 65.5;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 59;
		t.y = 161;
		t.elementsContent = [this.u_txtMsg_i()];
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.lineSpacing = 8;
		t.size = 18;
		t.text = "尊敬的玩家：     ";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.width = 694;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return LoginAnnounceSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/loginUI/LoginUISkin.exml'] = window.LoginUISkin = (function (_super) {
	__extends(LoginUISkin, _super);
	function LoginUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgBj","u_txt_resVersion","u_txt_version","u_btnKefu","u_txtTishi","u_txt_test","u_mcTest","u_txt_password","u_txt_account","u_group_login","u_image_serverList","u_txt_serverName","u_image_state","u_group_server_list","u_btnLoginGame","u_txtTiMs","u_txtYinshi","u_txtAnd","u_txtXieyi","u_mcTishi"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_imgBj_i(),this._Image1_i(),this.u_txt_resVersion_i(),this.u_txt_version_i(),this.u_btnKefu_i(),this.u_txtTishi_i(),this.u_mcTest_i(),this.u_group_login_i(),this.u_group_server_list_i(),this.u_btnLoginGame_i(),this.u_mcTishi_i()];
	}
	var _proto = LoginUISkin.prototype;

	_proto.u_imgBj_i = function () {
		var t = new eui.Image();
		this.u_imgBj = t;
		t.horizontalCenter = 0;
		t.source = "index_bg_jpg";
		t.visible = true;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.bottom = 0;
		t.height = 55;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(83,18,82,4);
		t.source = "loginUI_json.loginUI_baidi";
		t.width = 1136;
		return t;
	};
	_proto.u_txt_resVersion_i = function () {
		var t = new eui.Label();
		this.u_txt_resVersion = t;
		t.anchorOffsetX = 0;
		t.size = 20;
		t.strokeColor = 0x325f77;
		t.text = "12541";
		t.textAlign = "left";
		t.x = 14.5;
		t.y = 37;
		return t;
	};
	_proto.u_txt_version_i = function () {
		var t = new eui.Label();
		this.u_txt_version = t;
		t.anchorOffsetX = 0;
		t.size = 20;
		t.strokeColor = 0x325f77;
		t.text = "12254501";
		t.textAlign = "left";
		t.x = 14.5;
		t.y = 61;
		return t;
	};
	_proto.u_btnKefu_i = function () {
		var t = new eui.Image();
		this.u_btnKefu = t;
		t.height = 72;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "loginUI_json.loginUI_kefu_tis";
		t.width = 72;
		t.x = 1040;
		t.y = 26;
		return t;
	};
	_proto.u_txtTishi_i = function () {
		var t = new eui.Label();
		this.u_txtTishi = t;
		t.anchorOffsetX = 0;
		t.height = 50;
		t.horizontalCenter = 0;
		t.lineSpacing = 4;
		t.size = 20;
		t.strokeColor = 0x325F77;
		t.text = "抵制不良游戏";
		t.textAlign = "center";
		t.textColor = 0xD1CFCF;
		t.verticalAlign = "middle";
		t.y = 591;
		return t;
	};
	_proto.u_mcTest_i = function () {
		var t = new eui.Group();
		this.u_mcTest = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.y = 64;
		t.elementsContent = [this._Image2_i(),this.u_txt_test_i(),this._Label1_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 70;
		t.scale9Grid = new egret.Rectangle(106,16,77,7);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "loginUI_json.loginUI_baidi";
		t.width = 500;
		return t;
	};
	_proto.u_txt_test_i = function () {
		var t = new eui.EditableText();
		this.u_txt_test = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.promptColor = 0x5e4444;
		t.size = 26;
		t.textAlign = "left";
		t.textColor = 0xFFFFFF;
		t.verticalAlign = "middle";
		t.width = 370;
		t.x = 100;
		t.y = 21.3;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.size = 26;
		t.text = "参数:";
		t.textAlign = "left";
		t.textColor = 0xFFFFFF;
		t.x = 28;
		t.y = 24.9;
		return t;
	};
	_proto.u_group_login_i = function () {
		var t = new eui.Group();
		this.u_group_login = t;
		t.horizontalCenter = 0.5;
		t.visible = true;
		t.y = 331;
		t.elementsContent = [this._Image3_i(),this._Image4_i(),this.u_txt_password_i(),this.u_txt_account_i(),this._Label2_i(),this._Label3_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 50;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(87,17,66,8);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "loginUI_json.loginUI_baidi";
		t.width = 335;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.height = 50;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(127,19,24,4);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "loginUI_json.loginUI_baidi";
		t.width = 335;
		t.y = 57;
		return t;
	};
	_proto.u_txt_password_i = function () {
		var t = new eui.EditableText();
		this.u_txt_password = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.displayAsPassword = true;
		t.height = 30;
		t.promptColor = 0x5e4444;
		t.text = "123456";
		t.textAlign = "left";
		t.textColor = 0xFFFFFF;
		t.width = 187;
		t.x = 143;
		t.y = 69;
		return t;
	};
	_proto.u_txt_account_i = function () {
		var t = new eui.EditableText();
		this.u_txt_account = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 35;
		t.promptColor = 0x5e4444;
		t.text = "admin";
		t.textAlign = "left";
		t.textColor = 0xFFFFFF;
		t.width = 191;
		t.x = 138;
		t.y = 7;
		return t;
	};
	_proto._Label2_i = function () {
		var t = new eui.Label();
		t.text = "账号:";
		t.textAlign = "right";
		t.textColor = 0xFFFFFF;
		t.width = 120;
		t.x = 7;
		t.y = 9;
		return t;
	};
	_proto._Label3_i = function () {
		var t = new eui.Label();
		t.text = "密码:";
		t.textAlign = "right";
		t.textColor = 0xFFFFFF;
		t.width = 120;
		t.x = 7;
		t.y = 67;
		return t;
	};
	_proto.u_group_server_list_i = function () {
		var t = new eui.Group();
		this.u_group_server_list = t;
		t.anchorOffsetY = 0;
		t.horizontalCenter = 0.5;
		t.visible = true;
		t.y = 390;
		t.elementsContent = [this.u_image_serverList_i(),this.u_txt_serverName_i(),this.u_image_state_i()];
		return t;
	};
	_proto.u_image_serverList_i = function () {
		var t = new eui.Image();
		this.u_image_serverList = t;
		t.height = 50;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(84,17,70,5);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "loginUI_json.loginUI_baidi";
		t.width = 335;
		t.x = 8;
		return t;
	};
	_proto.u_txt_serverName_i = function () {
		var t = new eui.Label();
		this.u_txt_serverName = t;
		t.anchorOffsetX = 0;
		t.bold = false;
		t.size = 30;
		t.stroke = 2;
		t.strokeColor = 0x1f294f;
		t.text = "测试服998";
		t.textAlign = "left";
		t.textColor = 0xffffff;
		t.touchEnabled = false;
		t.x = 21;
		t.y = 12;
		return t;
	};
	_proto.u_image_state_i = function () {
		var t = new eui.Image();
		this.u_image_state = t;
		t.horizontalCenter = 99.5;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "loginUI_json.loginUI_hot";
		t.verticalCenter = 0;
		t.x = 268;
		t.y = -92;
		return t;
	};
	_proto.u_btnLoginGame_i = function () {
		var t = new eui.Image();
		this.u_btnLoginGame = t;
		t.source = "loginUI_json.loginUI_btn_bj";
		t.visible = true;
		t.x = 461;
		t.y = 457;
		return t;
	};
	_proto.u_mcTishi_i = function () {
		var t = new eui.Group();
		this.u_mcTishi = t;
		t.horizontalCenter = 0.5;
		t.visible = true;
		t.y = 532;
		t.layout = this._HorizontalLayout1_i();
		t.elementsContent = [this._Image5_i(),this.u_txtTiMs_i(),this.u_txtYinshi_i(),this.u_txtAnd_i(),this.u_txtXieyi_i()];
		return t;
	};
	_proto._HorizontalLayout1_i = function () {
		var t = new eui.HorizontalLayout();
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "loginUI_json.loginUI_gou";
		t.x = 4.5;
		t.y = 11.5;
		return t;
	};
	_proto.u_txtTiMs_i = function () {
		var t = new eui.Label();
		this.u_txtTiMs = t;
		t.bold = true;
		t.size = 22;
		t.stroke = 2;
		t.strokeColor = 0x444444;
		t.text = "I have read and agreed";
		t.textAlign = "left";
		t.textColor = 0xffffff;
		t.x = 33;
		t.y = 11.5;
		return t;
	};
	_proto.u_txtYinshi_i = function () {
		var t = new eui.Label();
		this.u_txtYinshi = t;
		t.bold = true;
		t.size = 22;
		t.stroke = 2;
		t.strokeColor = 0x055abc;
		t.text = "Privacy Statement";
		t.textAlign = "right";
		t.textColor = 0x41beff;
		t.x = 281;
		t.y = 11.5;
		return t;
	};
	_proto.u_txtAnd_i = function () {
		var t = new eui.Label();
		this.u_txtAnd = t;
		t.bold = true;
		t.size = 22;
		t.stroke = 2;
		t.strokeColor = 0x444444;
		t.text = "and";
		t.textAlign = "left";
		t.textColor = 0xFFFFFF;
		t.x = 486;
		t.y = 11.5;
		return t;
	};
	_proto.u_txtXieyi_i = function () {
		var t = new eui.Label();
		this.u_txtXieyi = t;
		t.bold = true;
		t.size = 22;
		t.stroke = 2;
		t.strokeColor = 0x055abc;
		t.text = "User Agreement";
		t.textAlign = "left";
		t.textColor = 0x23b4fc;
		t.x = 538;
		t.y = 10.5;
		return t;
	};
	return LoginUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/loginUI/popup/LoginXieyiSkin.exml'] = window.LoginXieyiSkin = (function (_super) {
	__extends(LoginXieyiSkin, _super);
	function LoginXieyiSkin() {
		_super.call(this);
		this.skinParts = ["u_txtTitle","u_txtLoading","u_txtTishi","u_txtMsg","u_scrollerItem"];
		
		this.height = 560;
		this.width = 970;
		this.elementsContent = [this._Image1_i(),this.u_txtTitle_i(),this.u_txtLoading_i(),this.u_txtTishi_i(),this.u_scrollerItem_i()];
	}
	var _proto = LoginXieyiSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetY = 0;
		t.height = 528;
		t.horizontalCenter = 0.5;
		t.scale9Grid = new egret.Rectangle(311,144,20,16);
		t.source = "loginUI_bg_1";
		t.visible = true;
		t.width = 865;
		t.y = 6;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 1;
		t.italic = true;
		t.size = 26;
		t.stroke = 2;
		t.text = "Title";
		t.textColor = 0xFFE062;
		t.x = 248;
		t.y = 15.61;
		return t;
	};
	_proto.u_txtLoading_i = function () {
		var t = new eui.Label();
		this.u_txtLoading = t;
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.size = 40;
		t.text = "loading...";
		t.textColor = 0x00FF1D;
		t.x = 258;
		t.y = 230;
		return t;
	};
	_proto.u_txtTishi_i = function () {
		var t = new eui.Label();
		this.u_txtTishi = t;
		t.horizontalCenter = 0.5;
		t.size = 20;
		t.stroke = 2;
		t.text = "time";
		t.textColor = 0xF0E4B0;
		t.x = 268;
		t.y = 541;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 414;
		t.horizontalCenter = 0;
		t.width = 755;
		t.y = 65.5;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 59;
		t.y = 161;
		t.elementsContent = [this.u_txtMsg_i()];
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.lineSpacing = 10;
		t.size = 20;
		t.strokeColor = 0x453A32;
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.width = 755;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return LoginXieyiSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/loginUI/ServerListBtnItemSkin.exml'] = window.serverListBtnItem = (function (_super) {
	__extends(serverListBtnItem, _super);
	function serverListBtnItem() {
		_super.call(this);
		this.skinParts = ["u_txt_type"];
		
		this.height = 33;
		this.width = 116;
		this.elementsContent = [this._Image1_i(),this.u_txt_type_i()];
	}
	var _proto = serverListBtnItem.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.source = "loginUI_json.loginUI_id_1";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txt_type_i = function () {
		var t = new eui.Label();
		this.u_txt_type = t;
		t.anchorOffsetX = 0;
		t.horizontalCenter = 0;
		t.size = 18;
		t.stroke = 1;
		t.strokeColor = 0xAE8544;
		t.text = "asd ";
		t.textAlign = "center";
		t.textColor = 0xFFFFFF;
		t.y = 6;
		return t;
	};
	return serverListBtnItem;
})(eui.Skin);generateEUI.paths['resource/eui_skins/loginUI/ServerListItemSkin.exml'] = window.ServerListItemSkin = (function (_super) {
	__extends(ServerListItemSkin, _super);
	function ServerListItemSkin() {
		_super.call(this);
		this.skinParts = ["u_txtName","u_imgName","u_imgState"];
		
		this.height = 30;
		this.width = 185;
		this.elementsContent = [this._Image1_i(),this.u_txtName_i(),this.u_imgName_i(),this.u_imgState_i()];
	}
	var _proto = ServerListItemSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.scale9Grid = new egret.Rectangle(38,11,84,8);
		t.source = "loginUI_json.loginUI_id_2";
		t.width = 185;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.anchorOffsetX = 0;
		t.size = 16;
		t.text = "s.21 我的世界";
		t.textColor = 0xFFFFFF;
		t.x = 34;
		t.y = 8.371;
		return t;
	};
	_proto.u_imgName_i = function () {
		var t = new eui.Image();
		this.u_imgName = t;
		t.source = "loginUI_json.loginUI_huo";
		t.x = 10;
		t.y = 7;
		return t;
	};
	_proto.u_imgState_i = function () {
		var t = new eui.Image();
		this.u_imgState = t;
		t.source = "loginUI_json.loginUI_huo_img";
		t.x = 165;
		t.y = 7;
		return t;
	};
	return ServerListItemSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/loginUI/ServerListUISkin.exml'] = window.ServerListUISkin = (function (_super) {
	__extends(ServerListUISkin, _super);
	function ServerListUISkin() {
		_super.call(this);
		this.skinParts = ["u_list_type","u_scroller_type","u_list_item","u_scroller_item"];
		
		this.height = 620;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this._Image3_i(),this.u_scroller_type_i(),this.u_scroller_item_i()];
	}
	var _proto = ServerListUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.scale9Grid = new egret.Rectangle(309,156,15,29);
		t.source = "loginUI_json.loginUI_bg_1";
		t.visible = true;
		t.x = 255;
		t.y = 146.581;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 2;
		t.source = "loginUI_json.loginUI_title";
		t.y = 156.386;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 229.75;
		t.scale9Grid = new egret.Rectangle(18,15,14,3);
		t.source = "loginUI_json.loginUI_id_3";
		t.visible = true;
		t.width = 389.808;
		t.x = 436.882;
		t.y = 209.984;
		return t;
	};
	_proto.u_scroller_type_i = function () {
		var t = new eui.Scroller();
		this.u_scroller_type = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 232;
		t.visible = true;
		t.width = 120;
		t.x = 309.074;
		t.y = 209;
		t.viewport = this.u_list_type_i();
		return t;
	};
	_proto.u_list_type_i = function () {
		var t = new eui.List();
		this.u_list_type = t;
		return t;
	};
	_proto.u_scroller_item_i = function () {
		var t = new eui.Scroller();
		this.u_scroller_item = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 211;
		t.visible = true;
		t.width = 377;
		t.x = 443.459;
		t.y = 218;
		t.viewport = this.u_list_item_i();
		return t;
	};
	_proto.u_list_item_i = function () {
		var t = new eui.List();
		this.u_list_item = t;
		return t;
	};
	return ServerListUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckBossUI/LuckBossUISkin.exml'] = window.LuckBossUISkin = (function (_super) {
	__extends(LuckBossUISkin, _super);
	function LuckBossUISkin() {
		_super.call(this);
		this.skinParts = ["u_btnRule","u_txtTime","u_btnChart","u_btnClose","u_grpCost","u_btnClear","u_txtPeople","u_grpPeople","u_grpCanDo","u_txtBlank","u_grpCantTips","u_btnGuanZhan","u_grpCant","u_imgRateBg1","u_txtRate1","u_mcMid","u_imgRateBg2","u_txtRate2","u_mcRight","u_imgRateBg3","u_txtRate3","u_mcLeft","u_mcBet"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Group2_i(),this.u_grpCanDo_i(),this.u_grpCant_i(),this.u_mcBet_i()];
	}
	var _proto = LuckBossUISkin.prototype;

	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.height = 40;
		t.horizontalCenter = 0;
		t.width = 299;
		t.y = 27;
		t.elementsContent = [this._Image1_i(),this._Group1_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "luckBossUI_json.luckBossUI_bg_8";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = -5.5;
		t.y = 9;
		t.elementsContent = [this.u_btnRule_i(),this.u_txtTime_i()];
		return t;
	};
	_proto.u_btnRule_i = function () {
		var t = new eui.Image();
		this.u_btnRule = t;
		t.height = 23;
		t.source = "luckBossUI_json.luckBossUI_rule";
		t.visible = true;
		t.width = 22;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtTime_i = function () {
		var t = new eui.Label();
		this.u_txtTime = t;
		t.bold = true;
		t.size = 18;
		t.text = "剩余竞猜时间: 00:00";
		t.textColor = 0xF33131;
		t.visible = true;
		t.x = 32;
		t.y = 3;
		return t;
	};
	_proto.u_grpCanDo_i = function () {
		var t = new eui.Group();
		this.u_grpCanDo = t;
		t.visible = true;
		t.x = 20;
		t.y = 3;
		t.elementsContent = [this._Image2_i(),this.u_btnChart_i(),this.u_btnClose_i(),this.u_grpCost_i(),this.u_btnClear_i(),this.u_grpPeople_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "luckBossUI_json.luckBossUI_di_1";
		t.visible = true;
		t.x = 37;
		t.y = 541;
		return t;
	};
	_proto.u_btnChart_i = function () {
		var t = new eui.Image();
		this.u_btnChart = t;
		t.source = "luckBossUI_json.luckBossUI_btn_cahrt";
		t.visible = true;
		t.x = 14;
		t.y = 540;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 27;
		t.source = "commonUI_json.commonUI_btn_close_1";
		t.visible = true;
		t.width = 26;
		t.x = 0;
		t.y = 18;
		return t;
	};
	_proto.u_grpCost_i = function () {
		var t = new eui.Group();
		this.u_grpCost = t;
		t.x = 133;
		t.y = 530;
		return t;
	};
	_proto.u_btnClear_i = function () {
		var t = new eui.Image();
		this.u_btnClear = t;
		t.height = 69;
		t.source = "luckBossUI_json.luckBossUI_btn_clear";
		t.visible = true;
		t.width = 161;
		t.x = 788;
		t.y = 546;
		return t;
	};
	_proto.u_grpPeople_i = function () {
		var t = new eui.Group();
		this.u_grpPeople = t;
		t.height = 69;
		t.visible = true;
		t.width = 69;
		t.x = 1014;
		t.y = 540;
		t.elementsContent = [this._Image3_i(),this._Group3_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "luckBossUI_json.luckBossUI_icon_people";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.height = 32;
		t.visible = true;
		t.width = 33;
		t.x = 40;
		t.y = -5;
		t.elementsContent = [this._Image4_i(),this.u_txtPeople_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "luckBossUI_json.luckBossUI_icon_roll";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtPeople_i = function () {
		var t = new eui.Label();
		this.u_txtPeople = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "99";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 6;
		return t;
	};
	_proto.u_grpCant_i = function () {
		var t = new eui.Group();
		this.u_grpCant = t;
		t.height = 40;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 299;
		t.y = 547;
		t.elementsContent = [this.u_grpCantTips_i(),this.u_btnGuanZhan_i()];
		return t;
	};
	_proto.u_grpCantTips_i = function () {
		var t = new eui.Group();
		this.u_grpCantTips = t;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image5_i(),this.u_txtBlank_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "luckBossUI_json.luckBossUI_bg_8";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtBlank_i = function () {
		var t = new eui.Label();
		this.u_txtBlank = t;
		t.size = 16;
		t.stroke = 2;
		t.strokeColor = 0x2B2E2E;
		t.text = "当前时间不可操作";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.visible = true;
		t.x = 86;
		t.y = 12;
		return t;
	};
	_proto.u_btnGuanZhan_i = function () {
		var t = new eui.Image();
		this.u_btnGuanZhan = t;
		t.height = 63;
		t.source = "luckBossUI_json.luckBossUI_guanzhan";
		t.width = 161;
		t.x = 69;
		t.y = -11;
		return t;
	};
	_proto.u_mcBet_i = function () {
		var t = new eui.Group();
		this.u_mcBet = t;
		t.x = 19;
		t.y = 91;
		t.elementsContent = [this.u_mcMid_i(),this.u_mcRight_i(),this.u_mcLeft_i()];
		return t;
	};
	_proto.u_mcMid_i = function () {
		var t = new eui.Group();
		this.u_mcMid = t;
		t.height = 425;
		t.visible = true;
		t.width = 618;
		t.x = 240;
		t.y = 0;
		t.elementsContent = [this._Image6_i(),this._Group4_i()];
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.source = "luckBossUI_json.luckBossUI_bg_1";
		t.visible = true;
		t.x = 0;
		t.y = 26;
		return t;
	};
	_proto._Group4_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.visible = true;
		t.y = 0;
		t.elementsContent = [this.u_imgRateBg1_i(),this._Image7_i(),this.u_txtRate1_i()];
		return t;
	};
	_proto.u_imgRateBg1_i = function () {
		var t = new eui.Image();
		this.u_imgRateBg1 = t;
		t.scale9Grid = new egret.Rectangle(15,12,4,11);
		t.source = "commonUI_json.commonUI_qipao_1";
		t.visible = true;
		t.width = 130;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image7_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "commonUI_json.commonUI_qipao_2";
		t.y = 33;
		return t;
	};
	_proto.u_txtRate1_i = function () {
		var t = new eui.Label();
		this.u_txtRate1 = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "赔率: x5.5";
		t.textAlign = "center";
		t.textColor = 0xE9DDAB;
		t.visible = true;
		t.y = 9;
		return t;
	};
	_proto.u_mcRight_i = function () {
		var t = new eui.Group();
		this.u_mcRight = t;
		t.height = 425;
		t.visible = true;
		t.width = 233;
		t.x = 865;
		t.y = 0;
		t.elementsContent = [this._Image8_i(),this._Group5_i()];
		return t;
	};
	_proto._Image8_i = function () {
		var t = new eui.Image();
		t.source = "luckBossUI_json.luckBossUI_bg_2";
		t.visible = true;
		t.x = 0;
		t.y = 26;
		return t;
	};
	_proto._Group5_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.visible = true;
		t.y = 0;
		t.elementsContent = [this.u_imgRateBg2_i(),this._Image9_i(),this.u_txtRate2_i()];
		return t;
	};
	_proto.u_imgRateBg2_i = function () {
		var t = new eui.Image();
		this.u_imgRateBg2 = t;
		t.scale9Grid = new egret.Rectangle(15,12,4,11);
		t.source = "commonUI_json.commonUI_qipao_1";
		t.visible = true;
		t.width = 130;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image9_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "commonUI_json.commonUI_qipao_2";
		t.y = 33;
		return t;
	};
	_proto.u_txtRate2_i = function () {
		var t = new eui.Label();
		this.u_txtRate2 = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "赔率: x5.5";
		t.textAlign = "center";
		t.textColor = 0xE9DDAB;
		t.visible = true;
		t.y = 9;
		return t;
	};
	_proto.u_mcLeft_i = function () {
		var t = new eui.Group();
		this.u_mcLeft = t;
		t.height = 425;
		t.visible = true;
		t.width = 233;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image10_i(),this._Group6_i()];
		return t;
	};
	_proto._Image10_i = function () {
		var t = new eui.Image();
		t.source = "luckBossUI_json.luckBossUI_bg_2";
		t.visible = true;
		t.x = 0;
		t.y = 26;
		return t;
	};
	_proto._Group6_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.visible = true;
		t.y = 0;
		t.elementsContent = [this.u_imgRateBg3_i(),this._Image11_i(),this.u_txtRate3_i()];
		return t;
	};
	_proto.u_imgRateBg3_i = function () {
		var t = new eui.Image();
		this.u_imgRateBg3 = t;
		t.scale9Grid = new egret.Rectangle(15,12,4,11);
		t.source = "commonUI_json.commonUI_qipao_1";
		t.visible = true;
		t.width = 130;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image11_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "commonUI_json.commonUI_qipao_2";
		t.y = 33;
		return t;
	};
	_proto.u_txtRate3_i = function () {
		var t = new eui.Label();
		this.u_txtRate3 = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "赔率: x5.5";
		t.textAlign = "center";
		t.textColor = 0xE9DDAB;
		t.visible = true;
		t.y = 9;
		return t;
	};
	return LuckBossUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckBossUI/popup/LuckBossChartPopupSkin.exml'] = window.LuckBossChartPopupSkin = (function (_super) {
	__extends(LuckBossChartPopupSkin, _super);
	function LuckBossChartPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtDesc","u_listItem","u_scrollerItem","u_txtBlank"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this._Image3_i(),this.u_txtDesc_i(),this.u_scrollerItem_i(),this.u_txtBlank_i()];
	}
	var _proto = LuckBossChartPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(10,79,10,8);
		t.source = "commonUI_json.commonUI_bg";
		t.visible = true;
		t.x = 60;
		t.y = 33;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "luckBossChartUI_json.luckBossChartUI_bg";
		t.visible = true;
		t.x = 120;
		t.y = 93;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "luckBossChartUI_json.luckBossChartUI_title";
		t.y = 43;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "近50场BOSS";
		t.textColor = 0xD5CA9C;
		t.y = 108;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 392;
		t.visible = true;
		t.width = 768;
		t.x = 249;
		t.y = 131;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtBlank_i = function () {
		var t = new eui.Label();
		this.u_txtBlank = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.stroke = 2;
		t.strokeColor = 0x2B2E2E;
		t.text = "点击空白处关闭窗口";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.visible = true;
		t.y = 592;
		return t;
	};
	return LuckBossChartPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckBossUI/popup/LuckBossFTPopupSkin.exml'] = window.LuckBossFTPopupSkin = (function (_super) {
	__extends(LuckBossFTPopupSkin, _super);
	function LuckBossFTPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtMsg","u_scrollerItem","u_btnClose"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_scrollerItem_i(),this.u_btnClose_i()];
	}
	var _proto = LuckBossFTPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "luckBossFTUI_json.luckBossFTUI_img_js";
		t.visible = true;
		t.x = 32;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "luckBossFTUI_json.luckBossFTUI_img_tc";
		t.visible = true;
		t.x = 514;
		t.y = 160;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.height = 265;
		t.visible = true;
		t.width = 460;
		t.x = 544;
		t.y = 180;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.visible = true;
		t.x = 59;
		t.elementsContent = [this.u_txtMsg_i()];
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.lineSpacing = 10;
		t.size = 14;
		t.strokeColor = 0x000000;
		t.text = "1、西游记";
		t.textAlign = "left";
		t.textColor = 0xE9DDAB;
		t.visible = true;
		t.width = 460;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.source = "luckBossFTUI_json.luckBossFTUI_btn_qd";
		t.visible = true;
		t.x = 723;
		t.y = 503;
		return t;
	};
	return LuckBossFTPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckBossUI/popup/LuckBossResultPopupSkin.exml'] = window.LuckBossResultPopupSkin = (function (_super) {
	__extends(LuckBossResultPopupSkin, _super);
	function LuckBossResultPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_imgHead","u_txtTag","u_txtMsg1","u_txtMsg2","u_grpNum1","u_dxImgBg","u_grpNum2","u_txtNone2","u_grpDX","u_dsImgBg","u_grpNum3","u_txtNone3","u_grpDS","u_txtBlank","u_btnClose"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_imgBg_i(),this.u_imgHead_i(),this._Image1_i(),this._Group1_i(),this.u_txtMsg1_i(),this.u_txtMsg2_i(),this.u_grpNum1_i(),this.u_grpDX_i(),this.u_grpDS_i(),this.u_txtBlank_i(),this.u_btnClose_i()];
	}
	var _proto = LuckBossResultPopupSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.source = "luckBossResultUI_json.luckBossResultUI_bg1";
		t.visible = true;
		t.x = 75;
		t.y = 45;
		return t;
	};
	_proto.u_imgHead_i = function () {
		var t = new eui.Image();
		this.u_imgHead = t;
		t.scaleX = 1.4;
		t.scaleY = 1.4;
		t.source = "luckBossFightUI_json.luckBossFightUI_head1";
		t.visible = true;
		t.x = 521;
		t.y = 84;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "luckBossResultUI_json.luckBossResultUI_title";
		t.visible = true;
		t.x = 504;
		t.y = 151;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.visible = true;
		t.x = 597;
		t.y = 120;
		t.elementsContent = [this._Image2_i(),this.u_txtTag_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "luckBossResultUI_json.luckBossResultUI_roll";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtTag_i = function () {
		var t = new eui.Label();
		this.u_txtTag = t;
		t.bold = true;
		t.horizontalCenter = -0.5;
		t.size = 20;
		t.text = "5";
		t.textColor = 0xFFFCA9;
		t.visible = true;
		t.y = 6;
		return t;
	};
	_proto.u_txtMsg1_i = function () {
		var t = new eui.Label();
		this.u_txtMsg1 = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 18;
		t.text = "恭喜您赢得比赛，获得";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 220;
		return t;
	};
	_proto.u_txtMsg2_i = function () {
		var t = new eui.Label();
		this.u_txtMsg2 = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 18;
		t.text = "额外获得";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 340;
		return t;
	};
	_proto.u_grpNum1_i = function () {
		var t = new eui.Group();
		this.u_grpNum1 = t;
		t.horizontalCenter = -2.5;
		t.visible = true;
		t.y = 252;
		t.elementsContent = [this._Image3_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "luckBossResultUI_json.luckBossResultUI_num_m";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_grpDX_i = function () {
		var t = new eui.Group();
		this.u_grpDX = t;
		t.visible = true;
		t.x = 604;
		t.y = 372;
		t.elementsContent = [this.u_dxImgBg_i(),this.u_grpNum2_i(),this.u_txtNone2_i()];
		return t;
	};
	_proto.u_dxImgBg_i = function () {
		var t = new eui.Image();
		this.u_dxImgBg = t;
		t.source = "luckBossResultUI_json.luckBossResultUI_bg5";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_grpNum2_i = function () {
		var t = new eui.Group();
		this.u_grpNum2 = t;
		t.scaleX = 0.7;
		t.scaleY = 0.7;
		t.visible = true;
		t.x = 97;
		t.y = 7;
		t.elementsContent = [this._Image4_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "luckBossResultUI_json.luckBossResultUI_num_m";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtNone2_i = function () {
		var t = new eui.Label();
		this.u_txtNone2 = t;
		t.bold = true;
		t.size = 20;
		t.text = "未中奖";
		t.textColor = 0x56565D;
		t.visible = true;
		t.x = 101;
		t.y = 12;
		return t;
	};
	_proto.u_grpDS_i = function () {
		var t = new eui.Group();
		this.u_grpDS = t;
		t.x = 340;
		t.y = 372;
		t.elementsContent = [this.u_dsImgBg_i(),this.u_grpNum3_i(),this.u_txtNone3_i()];
		return t;
	};
	_proto.u_dsImgBg_i = function () {
		var t = new eui.Image();
		this.u_dsImgBg = t;
		t.source = "luckBossResultUI_json.luckBossResultUI_bg3";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_grpNum3_i = function () {
		var t = new eui.Group();
		this.u_grpNum3 = t;
		t.scaleX = 0.7;
		t.scaleY = 0.7;
		t.visible = true;
		t.x = 97;
		t.y = 7;
		t.elementsContent = [this._Image5_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "luckBossResultUI_json.luckBossResultUI_num_m";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtNone3_i = function () {
		var t = new eui.Label();
		this.u_txtNone3 = t;
		t.bold = true;
		t.size = 20;
		t.text = "未中奖";
		t.textColor = 0x56565D;
		t.visible = true;
		t.x = 101;
		t.y = 12;
		return t;
	};
	_proto.u_txtBlank_i = function () {
		var t = new eui.Label();
		this.u_txtBlank = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.stroke = 2;
		t.strokeColor = 0x2B2E2E;
		t.text = "点击空白处关闭窗口";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.visible = true;
		t.y = 540;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 45;
		t.source = "luckBossResultUI_json.luckBossResultUI_btn_sure1";
		t.visible = true;
		t.width = 107;
		t.x = 515;
		t.y = 474;
		return t;
	};
	return LuckBossResultPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckBossUI/render/LuckBossChartRenderSkin.exml'] = window.LuckBossChartRenderSkin = (function (_super) {
	__extends(LuckBossChartRenderSkin, _super);
	function LuckBossChartRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_txtId","u_imgIcon"];
		
		this.height = 392;
		this.width = 52;
		this.elementsContent = [this.u_imgBg_i(),this.u_txtId_i(),this.u_imgIcon_i()];
	}
	var _proto = LuckBossChartRenderSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.scale9Grid = new egret.Rectangle(17,17,16,16);
		t.source = "luckBossChartUI_json.luckBossChartUI_bg2";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtId_i = function () {
		var t = new eui.Label();
		this.u_txtId = t;
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.size = 16;
		t.text = "50";
		t.textColor = 0xD5CA9C;
		t.visible = true;
		t.x = 17;
		t.y = 10;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.horizontalCenter = 0;
		t.source = "luckBossChartUI_json.luckBossChartUI_icon";
		t.x = 10;
		t.y = 48;
		return t;
	};
	return LuckBossChartRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckBossUI/render/LuckBossFightHeadRenderSkin.exml'] = window.LuckBossFightHeadRenderSkin = (function (_super) {
	__extends(LuckBossFightHeadRenderSkin, _super);
	function LuckBossFightHeadRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgHead","u_txtTag","u_mcHead","u_imgDie"];
		
		this.height = 68;
		this.width = 68;
		this.elementsContent = [this.u_mcHead_i(),this.u_imgDie_i()];
	}
	var _proto = LuckBossFightHeadRenderSkin.prototype;

	_proto.u_mcHead_i = function () {
		var t = new eui.Group();
		this.u_mcHead = t;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this.u_imgHead_i(),this._Image1_i(),this.u_txtTag_i()];
		return t;
	};
	_proto.u_imgHead_i = function () {
		var t = new eui.Image();
		this.u_imgHead = t;
		t.source = "luckBossFightUI_json.luckBossFightUI_head1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "luckBossFightUI_json.luckBossFightUI_icon_roll";
		t.visible = true;
		t.x = 35;
		t.y = 40;
		return t;
	};
	_proto.u_txtTag_i = function () {
		var t = new eui.Label();
		this.u_txtTag = t;
		t.bold = true;
		t.size = 20;
		t.text = "5";
		t.textColor = 0xFFFCA9;
		t.visible = true;
		t.x = 45;
		t.y = 44;
		return t;
	};
	_proto.u_imgDie_i = function () {
		var t = new eui.Image();
		this.u_imgDie = t;
		t.source = "luckBossFightUI_json.luckBossFightUI_die";
		t.visible = true;
		t.x = 10;
		t.y = 7;
		return t;
	};
	return LuckBossFightHeadRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckBossUI/view/LuckBetViewSkin.exml'] = window.LuckBetViewSkin = (function (_super) {
	__extends(LuckBetViewSkin, _super);
	function LuckBetViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgGold","u_txtMsg","u_imgIcon","u_txtMyCost","u_grpMyCost"];
		
		this.height = 163;
		this.width = 163;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_imgGold_i(),this.u_txtMsg_i(),this.u_imgIcon_i(),this.u_grpMyCost_i()];
	}
	var _proto = LuckBetViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "luckBossUI_json.luckBossUI_bg_4";
		t.visible = true;
		t.x = 0;
		t.y = 3;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(9,9,8,8);
		t.source = "luckBossUI_json.luckBossUI_bg_5";
		t.visible = true;
		t.width = 151;
		t.x = 6;
		t.y = 100;
		return t;
	};
	_proto.u_imgGold_i = function () {
		var t = new eui.Image();
		this.u_imgGold = t;
		t.source = "luckBossUI_json.luckBossUI_num_icon_jb1";
		t.visible = true;
		t.x = 8;
		t.y = 88;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "下注区";
		t.textColor = 0x6B4A39;
		t.visible = true;
		t.x = 58;
		t.y = 133;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.source = "luckBossUI_json.luckBossUI_icon10";
		t.visible = true;
		t.x = 58;
		t.y = 15;
		return t;
	};
	_proto.u_grpMyCost_i = function () {
		var t = new eui.Group();
		this.u_grpMyCost = t;
		t.visible = true;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image3_i(),this.u_txtMyCost_i(),this._Image4_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 28;
		t.scale9Grid = new egret.Rectangle(55,9,56,4);
		t.source = "luckBossUI_json.luckBossUI_bg_7";
		t.visible = true;
		t.width = 151;
		t.x = 6;
		t.y = 126;
		return t;
	};
	_proto.u_txtMyCost_i = function () {
		var t = new eui.Label();
		this.u_txtMyCost = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "$50K";
		t.textColor = 0x6B4A39;
		t.visible = true;
		t.y = 132;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(59,53,60,54);
		t.source = "luckBossUI_json.luckBossUI_select2";
		t.visible = true;
		t.width = 162;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return LuckBetViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckBossUI/view/LuckBossChartHeadSkin.exml'] = window.LuckBossChartHeadSkin = (function (_super) {
	__extends(LuckBossChartHeadSkin, _super);
	function LuckBossChartHeadSkin() {
		_super.call(this);
		this.skinParts = ["u_imgHead","u_grpNum"];
		
		this.height = 48;
		this.width = 99;
		this.elementsContent = [this._Image1_i(),this.u_imgHead_i(),this.u_grpNum_i()];
	}
	var _proto = LuckBossChartHeadSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "luckBossChartUI_json.luckBossChartUI_head_bg";
		t.visible = true;
		t.x = 1;
		t.y = 1;
		return t;
	};
	_proto.u_imgHead_i = function () {
		var t = new eui.Image();
		this.u_imgHead = t;
		t.scaleX = 0.7;
		t.scaleY = 0.7;
		t.source = "luckBossFightUI_json.luckBossFightUI_head1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_grpNum_i = function () {
		var t = new eui.Group();
		this.u_grpNum = t;
		t.horizontalCenter = 19.5;
		t.y = 9;
		return t;
	};
	return LuckBossChartHeadSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckBossUI/view/LuckBossCostSkin.exml'] = window.LuckBossCostSkin = (function (_super) {
	__extends(LuckBossCostSkin, _super);
	function LuckBossCostSkin() {
		_super.call(this);
		this.skinParts = ["u_imgCost","u_imgSelect"];
		
		this.height = 111;
		this.width = 105;
		this.elementsContent = [this.u_imgCost_i(),this.u_imgSelect_i()];
	}
	var _proto = LuckBossCostSkin.prototype;

	_proto.u_imgCost_i = function () {
		var t = new eui.Image();
		this.u_imgCost = t;
		t.source = "luckBossUI_json.luckBossUI_icon_cm1";
		return t;
	};
	_proto.u_imgSelect_i = function () {
		var t = new eui.Image();
		this.u_imgSelect = t;
		t.horizontalCenter = 0;
		t.source = "luckBossUI_json.luckBossUI_select1";
		t.verticalCenter = 0;
		return t;
	};
	return LuckBossCostSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckBossUI/view/LuckBossFightTopSkin.exml'] = window.LuckBossFightTopSkin = (function (_super) {
	__extends(LuckBossFightTopSkin, _super);
	function LuckBossFightTopSkin() {
		_super.call(this);
		this.skinParts = ["u_btnDetail","u_btnChart","u_listItem"];
		
		this.height = 102;
		this.width = 847;
		this.elementsContent = [this._Group1_i()];
	}
	var _proto = LuckBossFightTopSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.y = 0;
		t.elementsContent = [this._Image1_i(),this.u_btnDetail_i(),this.u_btnChart_i(),this.u_listItem_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "luckBossFightUI_json.luckBossFightUI_bg";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnDetail_i = function () {
		var t = new eui.Image();
		this.u_btnDetail = t;
		t.height = 65;
		t.source = "luckBossFightUI_json.luckBossFightUI_btn_xzxq";
		t.visible = true;
		t.width = 60;
		t.x = 59;
		t.y = 12;
		return t;
	};
	_proto.u_btnChart_i = function () {
		var t = new eui.Image();
		this.u_btnChart = t;
		t.height = 65;
		t.source = "luckBossFightUI_json.luckBossFightUI_btn_qs";
		t.visible = true;
		t.width = 60;
		t.x = 728;
		t.y = 12;
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.height = 68;
		t.x = 178;
		t.y = 8;
		return t;
	};
	return LuckBossFightTopSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckBossUI/view/LuckBossViewSkin.exml'] = window.LuckBossViewSkin = (function (_super) {
	__extends(LuckBossViewSkin, _super);
	function LuckBossViewSkin() {
		_super.call(this);
		this.skinParts = ["u_bossIcon","u_bossIdx","u_imgGold","u_txtMsg","u_txtMyCost","u_grpMyCost"];
		
		this.height = 160;
		this.width = 178;
		this.elementsContent = [this._Image1_i(),this.u_bossIcon_i(),this._Group1_i(),this._Image3_i(),this.u_imgGold_i(),this.u_txtMsg_i(),this.u_grpMyCost_i()];
	}
	var _proto = LuckBossViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "luckBossUI_json.luckBossUI_bg_3";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_bossIcon_i = function () {
		var t = new eui.Image();
		this.u_bossIcon = t;
		t.source = "luckBossUI_json.luckBossUI_icon_boss1";
		t.visible = true;
		t.x = 6;
		t.y = 3;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 6;
		t.y = 3;
		t.elementsContent = [this._Image2_i(),this.u_bossIdx_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "luckBossUI_json.luckBossUI_bg_6";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_bossIdx_i = function () {
		var t = new eui.Image();
		this.u_bossIdx = t;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "luckBossUI_json.luckBossUI_num_1";
		t.visible = true;
		t.x = 7;
		t.y = 9;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(9,9,8,8);
		t.source = "luckBossUI_json.luckBossUI_bg_5";
		t.visible = true;
		t.width = 166;
		t.x = 6;
		t.y = 97;
		return t;
	};
	_proto.u_imgGold_i = function () {
		var t = new eui.Image();
		this.u_imgGold = t;
		t.source = "luckBossUI_json.luckBossUI_num_icon_jb1";
		t.visible = true;
		t.x = 8;
		t.y = 85;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "下注区";
		t.textColor = 0x6B4A39;
		t.visible = true;
		t.x = 65;
		t.y = 130;
		return t;
	};
	_proto.u_grpMyCost_i = function () {
		var t = new eui.Group();
		this.u_grpMyCost = t;
		t.visible = true;
		t.x = 0;
		t.y = -3;
		t.elementsContent = [this._Image4_i(),this.u_txtMyCost_i(),this._Image5_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.height = 28;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(55,9,56,4);
		t.source = "luckBossUI_json.luckBossUI_bg_7";
		t.visible = true;
		t.y = 126;
		return t;
	};
	_proto.u_txtMyCost_i = function () {
		var t = new eui.Label();
		this.u_txtMyCost = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "$50K";
		t.textColor = 0x6B4A39;
		t.visible = true;
		t.y = 132;
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "luckBossUI_json.luckBossUI_select2";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return LuckBossViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckBossUI/view/LuckMonsterHpSkin.exml'] = window.LuckMonsterHpSkin = (function (_super) {
	__extends(LuckMonsterHpSkin, _super);
	function LuckMonsterHpSkin() {
		_super.call(this);
		this.skinParts = ["u_hpLineimg","u_hpimg","u_txtTag","u_txtHp"];
		
		this.height = 19;
		this.width = 170;
		this.elementsContent = [this._Image1_i(),this.u_hpLineimg_i(),this.u_hpimg_i(),this._Group1_i(),this.u_txtHp_i()];
	}
	var _proto = LuckMonsterHpSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(11,6,10,7);
		t.source = "commonUI_json.commonUI_jindu_1";
		t.visible = true;
		t.width = 170;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_hpLineimg_i = function () {
		var t = new eui.Image();
		this.u_hpLineimg = t;
		t.scale9Grid = new egret.Rectangle(9,5,10,4);
		t.source = "commonUI_json.commonUI_jindu_2";
		t.verticalCenter = -0.5;
		t.visible = true;
		t.width = 165;
		t.x = 3;
		return t;
	};
	_proto.u_hpimg_i = function () {
		var t = new eui.Image();
		this.u_hpimg = t;
		t.scale9Grid = new egret.Rectangle(9,5,10,4);
		t.source = "commonUI_json.commonUI_jindu_3";
		t.visible = true;
		t.width = 165;
		t.x = 3;
		t.y = 2;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = -27;
		t.y = -4;
		t.elementsContent = [this._Image2_i(),this.u_txtTag_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "luckBossFightUI_json.luckBossFightUI_icon_roll";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtTag_i = function () {
		var t = new eui.Label();
		this.u_txtTag = t;
		t.bold = true;
		t.size = 20;
		t.text = "5";
		t.textColor = 0xFFFCA9;
		t.visible = true;
		t.x = 10;
		t.y = 4.5;
		return t;
	};
	_proto.u_txtHp_i = function () {
		var t = new eui.Label();
		this.u_txtHp = t;
		t.horizontalCenter = 0.5;
		t.size = 16;
		t.text = "100/1000";
		t.textColor = 0xFFFFFF;
		t.verticalCenter = 1.5;
		return t;
	};
	return LuckMonsterHpSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckyDrawUI/LuckyDrawUISkin.exml'] = window.skins.LuckyDrawUISkin = (function (_super) {
	__extends(LuckyDrawUISkin, _super);
	function LuckyDrawUISkin() {
		_super.call(this);
		this.skinParts = ["u_iconBg_0","u_iconBg_1","u_iconBg_2","u_iconBg_3","u_iconBg_4","u_iconBg_5","u_iconBg_6","u_iconBg_7","u_iconBg_8","u_iconBg_9","u_iconBg_10","u_iconBg_11","u_iconBg_12","u_iconBg_13","u_selectBg","u_iconGrp","u_tipBtn","u_luckyLb","u_luckyTip","u_valueLb","u_valueGrp","u_awdList","u_awdScroller","u_awardGrp","u_btn_0","u_btn_1","u_extraTitle","u_countLb","u_extraList","u_extraScroller","u_storeBtn"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_iconGrp_i(),this.u_valueGrp_i(),this.u_awardGrp_i(),this.u_btn_0_i(),this.u_btn_1_i(),this._Group1_i(),this._Image9_i(),this.u_storeBtn_i()];
	}
	var _proto = LuckyDrawUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "luckyDrawUI_json.luckyDrawUI_bg";
		t.visible = true;
		t.x = 188;
		t.y = 47;
		return t;
	};
	_proto.u_iconGrp_i = function () {
		var t = new eui.Group();
		this.u_iconGrp = t;
		t.height = 484.695;
		t.visible = true;
		t.width = 652;
		t.x = 224.983;
		t.y = 96.779;
		t.elementsContent = [this.u_iconBg_0_i(),this.u_iconBg_1_i(),this.u_iconBg_2_i(),this.u_iconBg_3_i(),this.u_iconBg_4_i(),this.u_iconBg_5_i(),this.u_iconBg_6_i(),this.u_iconBg_7_i(),this.u_iconBg_8_i(),this.u_iconBg_9_i(),this.u_iconBg_10_i(),this.u_iconBg_11_i(),this.u_iconBg_12_i(),this.u_iconBg_13_i(),this.u_selectBg_i(),this._Image2_i()];
		return t;
	};
	_proto.u_iconBg_0_i = function () {
		var t = new eui.Image();
		this.u_iconBg_0 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.visible = true;
		t.x = 2.372;
		t.y = 12.828;
		return t;
	};
	_proto.u_iconBg_1_i = function () {
		var t = new eui.Image();
		this.u_iconBg_1 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.x = 133;
		t.y = 12.828;
		return t;
	};
	_proto.u_iconBg_2_i = function () {
		var t = new eui.Image();
		this.u_iconBg_2 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.x = 267.284;
		t.y = 12.828;
		return t;
	};
	_proto.u_iconBg_3_i = function () {
		var t = new eui.Image();
		this.u_iconBg_3 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.x = 397.588;
		t.y = 12.828;
		return t;
	};
	_proto.u_iconBg_4_i = function () {
		var t = new eui.Image();
		this.u_iconBg_4 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.x = 529;
		t.y = 12.828;
		return t;
	};
	_proto.u_iconBg_5_i = function () {
		var t = new eui.Image();
		this.u_iconBg_5 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.x = 529;
		t.y = 126.992;
		return t;
	};
	_proto.u_iconBg_6_i = function () {
		var t = new eui.Image();
		this.u_iconBg_6 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.x = 529;
		t.y = 239;
		return t;
	};
	_proto.u_iconBg_7_i = function () {
		var t = new eui.Image();
		this.u_iconBg_7 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.x = 529;
		t.y = 352.0939;
		return t;
	};
	_proto.u_iconBg_8_i = function () {
		var t = new eui.Image();
		this.u_iconBg_8 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.x = 398.663;
		t.y = 352.093;
		return t;
	};
	_proto.u_iconBg_9_i = function () {
		var t = new eui.Image();
		this.u_iconBg_9 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.x = 266.208;
		t.y = 352.093;
		return t;
	};
	_proto.u_iconBg_10_i = function () {
		var t = new eui.Image();
		this.u_iconBg_10 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.x = 134.828;
		t.y = 352.093;
		return t;
	};
	_proto.u_iconBg_11_i = function () {
		var t = new eui.Image();
		this.u_iconBg_11 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.x = 2.372;
		t.y = 352.093;
		return t;
	};
	_proto.u_iconBg_12_i = function () {
		var t = new eui.Image();
		this.u_iconBg_12 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.x = 2.372;
		t.y = 239.005;
		return t;
	};
	_proto.u_iconBg_13_i = function () {
		var t = new eui.Image();
		this.u_iconBg_13 = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_iconBg";
		t.x = 2.372;
		t.y = 126.992;
		return t;
	};
	_proto.u_selectBg_i = function () {
		var t = new eui.Image();
		this.u_selectBg = t;
		t.alpha = 1;
		t.source = "luckyDrawUI_json.luckyDrawUI_flash";
		t.visible = true;
		t.x = 2.372;
		t.y = 12.828;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(40,40,40,40);
		t.source = "luckyDrawUI_json.luckyDrawUI_centerBg";
		t.visible = true;
		t.x = 130;
		t.y = 124;
		return t;
	};
	_proto.u_valueGrp_i = function () {
		var t = new eui.Group();
		this.u_valueGrp = t;
		t.height = 213.619;
		t.visible = true;
		t.width = 384.639;
		t.x = 360.612;
		t.y = 222.261;
		t.elementsContent = [this._Image3_i(),this.u_tipBtn_i(),this.u_luckyLb_i(),this.u_luckyTip_i(),this.u_valueLb_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "luckyDrawUI_json.luckyDrawUI_effect";
		t.x = 6;
		t.y = -12;
		return t;
	};
	_proto.u_tipBtn_i = function () {
		var t = new eui.Image();
		this.u_tipBtn = t;
		t.height = 25;
		t.source = "luckyDrawUI_json.luckyDrawUI_tip";
		t.width = 25;
		t.x = 6.412;
		t.y = 9.716;
		return t;
	};
	_proto.u_luckyLb_i = function () {
		var t = new eui.Label();
		this.u_luckyLb = t;
		t.bold = true;
		t.lineSpacing = 5;
		t.size = 22;
		t.stroke = 1;
		t.strokeColor = 0x333333;
		t.text = "当前幸运值";
		t.textAlign = "center";
		t.textColor = 0xFFFFFF;
		t.x = 159;
		t.y = 30;
		return t;
	};
	_proto.u_luckyTip_i = function () {
		var t = new eui.Label();
		this.u_luckyTip = t;
		t.height = 36.595;
		t.lineSpacing = 8;
		t.size = 16;
		t.stroke = 2;
		t.strokeColor = 0x333333;
		t.text = "幸运值越高，获得稀有物品的机会就会越大！";
		t.textColor = 0xA5A5A5;
		t.width = 210.062;
		t.x = 159;
		t.y = 66.444;
		return t;
	};
	_proto.u_valueLb_i = function () {
		var t = new eui.Label();
		this.u_valueLb = t;
		t.bold = true;
		t.size = 38;
		t.text = "10";
		t.textColor = 0xFDB702;
		t.x = 270.607;
		t.y = 19.607;
		return t;
	};
	_proto.u_awardGrp_i = function () {
		var t = new eui.Group();
		this.u_awardGrp = t;
		t.horizontalCenter = -14;
		t.visible = false;
		t.y = 230;
		t.elementsContent = [this._Image4_i(),this.u_awdScroller_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "luckyDrawUI_json.luckyDrawUI_title";
		t.y = 0;
		return t;
	};
	_proto.u_awdScroller_i = function () {
		var t = new eui.Scroller();
		this.u_awdScroller = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 60;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 360;
		t.y = 39.34;
		t.viewport = this.u_awdList_i();
		return t;
	};
	_proto.u_awdList_i = function () {
		var t = new eui.List();
		this.u_awdList = t;
		t.x = 433;
		t.y = 264;
		return t;
	};
	_proto.u_btn_0_i = function () {
		var t = new eui.Group();
		this.u_btn_0 = t;
		t.x = 370;
		t.y = 358;
		t.elementsContent = [this._Image5_i(),this._Label1_i(),this._Image6_i(),this._Label2_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "luckyDrawUI_json.luckyDrawUI_btnBg";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "夺宝1次";
		t.textColor = 0x333333;
		t.verticalCenter = -8;
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.source = "luckyDrawUI_json.luckyDrawUI_diamond";
		t.x = 63;
		t.y = 54;
		return t;
	};
	_proto._Label2_i = function () {
		var t = new eui.Label();
		t.size = 16;
		t.text = "100";
		t.textColor = 0xF0E4B0;
		t.x = 88.121;
		t.y = 55.272;
		return t;
	};
	_proto.u_btn_1_i = function () {
		var t = new eui.Group();
		this.u_btn_1 = t;
		t.x = 555;
		t.y = 358;
		t.elementsContent = [this._Image7_i(),this._Image8_i(),this._Label3_i(),this._Label4_i()];
		return t;
	};
	_proto._Image7_i = function () {
		var t = new eui.Image();
		t.source = "luckyDrawUI_json.luckyDrawUI_btnBg";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image8_i = function () {
		var t = new eui.Image();
		t.source = "luckyDrawUI_json.luckyDrawUI_diamond";
		t.x = 63;
		t.y = 54;
		return t;
	};
	_proto._Label3_i = function () {
		var t = new eui.Label();
		t.size = 16;
		t.text = "500";
		t.textColor = 0xF0E4B0;
		t.x = 88.121;
		t.y = 55.272;
		return t;
	};
	_proto._Label4_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "夺宝5次";
		t.textColor = 0x333333;
		t.verticalCenter = -8;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.visible = true;
		t.x = 946.09;
		t.y = 65;
		t.elementsContent = [this.u_extraTitle_i(),this.u_countLb_i(),this.u_extraScroller_i()];
		return t;
	};
	_proto.u_extraTitle_i = function () {
		var t = new eui.Label();
		this.u_extraTitle = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.stroke = 2;
		t.strokeColor = 0x52140F;
		t.text = "额外奖励";
		t.textAlign = "center";
		t.y = 0;
		return t;
	};
	_proto.u_countLb_i = function () {
		var t = new eui.Label();
		this.u_countLb = t;
		t.horizontalCenter = 0;
		t.lineSpacing = 15;
		t.size = 16;
		t.stroke = 2;
		t.strokeColor = 0x52140F;
		t.text = "本周累计\n5个";
		t.textAlign = "center";
		t.y = 39.28;
		return t;
	};
	_proto.u_extraScroller_i = function () {
		var t = new eui.Scroller();
		this.u_extraScroller = t;
		t.height = 305;
		t.width = 94;
		t.x = 0;
		t.y = 100.13;
		t.viewport = this.u_extraList_i();
		return t;
	};
	_proto.u_extraList_i = function () {
		var t = new eui.List();
		this.u_extraList = t;
		return t;
	};
	_proto._Image9_i = function () {
		var t = new eui.Image();
		t.source = "luckyDrawUI_json.luckyDrawUI_extra";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 910;
		t.y = 385;
		return t;
	};
	_proto.u_storeBtn_i = function () {
		var t = new eui.Group();
		this.u_storeBtn = t;
		t.x = 878.36;
		t.y = 550;
		t.elementsContent = [this._Image10_i(),this._Label5_i()];
		return t;
	};
	_proto._Image10_i = function () {
		var t = new eui.Image();
		t.source = "luckyDrawUI_json.luckyDrawUI_store";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Label5_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.size = 22;
		t.text = "兑换商店";
		t.textColor = 0xF0E4B0;
		t.x = 80.64;
		t.y = 22;
		return t;
	};
	return LuckyDrawUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckyDrawUI/pop/LuckyDrawExtraRewardPopSkin.exml'] = window.skins.LuckyDrawExtraRewardPopSkin = (function (_super) {
	__extends(LuckyDrawExtraRewardPopSkin, _super);
	function LuckyDrawExtraRewardPopSkin() {
		_super.call(this);
		this.skinParts = ["u_titleLb","u_desLb","u_buyBtn","u_complBtn","u_btnGrp","u_receivBtn","u_sureBtn"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_titleLb_i(),this.u_desLb_i(),this.u_btnGrp_i(),this.u_receivBtn_i(),this.u_sureBtn_i()];
	}
	var _proto = LuckyDrawExtraRewardPopSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 310.984;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(130,100,50,50);
		t.source = "luckyDrawUI_json.luckyDrawUI_extraBg";
		t.visible = true;
		t.width = 633.258;
		t.y = 182.95;
		return t;
	};
	_proto.u_titleLb_i = function () {
		var t = new eui.Label();
		this.u_titleLb = t;
		t.horizontalCenter = 0;
		t.size = 24;
		t.stroke = 2;
		t.strokeColor = 0x000000;
		t.text = "额外奖励";
		t.textColor = 0xF0E4B0;
		t.y = 195;
		return t;
	};
	_proto.u_desLb_i = function () {
		var t = new eui.Label();
		this.u_desLb = t;
		t.horizontalCenter = 0;
		t.lineSpacing = 8;
		t.size = 18;
		t.text = "您已累计购买5个\n再购买7个即可获得以下奖励";
		t.textAlign = "center";
		t.y = 237;
		return t;
	};
	_proto.u_btnGrp_i = function () {
		var t = new eui.Group();
		this.u_btnGrp = t;
		t.height = 53;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 321;
		t.y = 405;
		t.elementsContent = [this.u_buyBtn_i(),this.u_complBtn_i()];
		return t;
	};
	_proto.u_buyBtn_i = function () {
		var t = new eui.Image();
		this.u_buyBtn = t;
		t.height = 53;
		t.source = "luckyDrawUI_json.luckyDrawUI_bugAgain";
		t.width = 134;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_complBtn_i = function () {
		var t = new eui.Image();
		this.u_complBtn = t;
		t.height = 53;
		t.source = "luckyDrawUI_json.luckyDrawUI_complete";
		t.width = 134;
		t.x = 186.86;
		t.y = 0;
		return t;
	};
	_proto.u_receivBtn_i = function () {
		var t = new eui.Image();
		this.u_receivBtn = t;
		t.horizontalCenter = 0;
		t.source = "luckyDrawUI_json.luckyDrawUI_receive";
		t.visible = false;
		t.y = 405;
		return t;
	};
	_proto.u_sureBtn_i = function () {
		var t = new eui.Image();
		this.u_sureBtn = t;
		t.horizontalCenter = 0;
		t.source = "luckyDrawUI_json.luckyDrawUI_sure";
		t.visible = false;
		t.y = 405;
		return t;
	};
	return LuckyDrawExtraRewardPopSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckyDrawUI/pop/LuckyDrawRewardPopSkin.exml'] = window.skins.LuckyDrawRewardPop = (function (_super) {
	__extends(LuckyDrawRewardPop, _super);
	function LuckyDrawRewardPop() {
		_super.call(this);
		this.skinParts = ["u_bg","u_rewardGrp","u_buyBtn","u_sureBtn","u_closeTxt"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_bg_i(),this._Label1_i(),this.u_rewardGrp_i(),this.u_buyBtn_i(),this.u_sureBtn_i(),this.u_closeTxt_i()];
	}
	var _proto = LuckyDrawRewardPop.prototype;

	_proto.u_bg_i = function () {
		var t = new eui.Image();
		this.u_bg = t;
		t.scale9Grid = new egret.Rectangle(152,100,100,60);
		t.source = "rewardUI_json.rewardUI_bg";
		t.x = -122;
		t.y = 120;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "你获得了";
		t.textColor = 0xF0E4B0;
		t.y = 62;
		return t;
	};
	_proto.u_rewardGrp_i = function () {
		var t = new eui.Group();
		this.u_rewardGrp = t;
		t.anchorOffsetY = 0;
		t.height = 120;
		t.horizontalCenter = 0;
		t.x = 750;
		t.y = 220;
		return t;
	};
	_proto.u_buyBtn_i = function () {
		var t = new eui.Image();
		this.u_buyBtn = t;
		t.height = 53;
		t.source = "luckyDrawUI_json.luckyDrawUI_buyFive";
		t.width = 134;
		t.x = 398;
		t.y = 400;
		return t;
	};
	_proto.u_sureBtn_i = function () {
		var t = new eui.Image();
		this.u_sureBtn = t;
		t.height = 53;
		t.source = "luckyDrawUI_json.luckyDrawUI_sure";
		t.width = 134;
		t.x = 592;
		t.y = 400;
		return t;
	};
	_proto.u_closeTxt_i = function () {
		var t = new eui.Label();
		this.u_closeTxt = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "点击空白处关闭窗口";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.y = 548.825;
		return t;
	};
	return LuckyDrawRewardPop;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckyDrawUI/render/LuckyDrawAwdRenderSkin.exml'] = window.skins.LuckyDrawAwdRender = (function (_super) {
	__extends(LuckyDrawAwdRender, _super);
	function LuckyDrawAwdRender() {
		_super.call(this);
		this.skinParts = [];
		
		this.height = 60;
		this.width = 60;
	}
	var _proto = LuckyDrawAwdRender.prototype;

	return LuckyDrawAwdRender;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckyDrawUI/render/LuckyDrawExtraRenderSkin.exml'] = window.skins.LuckyDrawExtraRenderSkin = (function (_super) {
	__extends(LuckyDrawExtraRenderSkin, _super);
	function LuckyDrawExtraRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_boxIcon","u_countLb","u_receivedGrp"];
		
		this.height = 85;
		this.width = 95;
		this.elementsContent = [this._Image1_i(),this.u_boxIcon_i(),this.u_countLb_i(),this.u_receivedGrp_i()];
	}
	var _proto = LuckyDrawExtraRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 85;
		t.horizontalCenter = 0;
		t.source = "luckyDrawUI_json.luckyDrawUI_boxBg";
		t.width = 85;
		t.y = 0;
		return t;
	};
	_proto.u_boxIcon_i = function () {
		var t = new eui.Image();
		this.u_boxIcon = t;
		t.source = "luckyDrawUI_json.luckyDrawUI_box";
		t.x = 0;
		t.y = 3;
		return t;
	};
	_proto.u_countLb_i = function () {
		var t = new eui.Label();
		this.u_countLb = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.stroke = 2;
		t.strokeColor = 0x000000;
		t.text = "5个";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.y = 68;
		return t;
	};
	_proto.u_receivedGrp_i = function () {
		var t = new eui.Group();
		this.u_receivedGrp = t;
		t.visible = false;
		t.x = 23;
		t.y = 8;
		t.elementsContent = [this._Image2_i(),this._Label1_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "luckyDrawUI_json.luckyDrawUI_chose";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.size = 16;
		t.stroke = 2;
		t.text = "已领取";
		t.textColor = 0x30C524;
		t.x = 1;
		t.y = 38;
		return t;
	};
	return LuckyDrawExtraRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/luckyDrawUI/view/LuckyDrawRuleSkin.exml'] = window.skins.LuckyDrawRule = (function (_super) {
	__extends(LuckyDrawRule, _super);
	function LuckyDrawRule() {
		_super.call(this);
		this.skinParts = ["u_txtTitle","u_txtMsg"];
		
		this.height = 243;
		this.width = 374;
		this.elementsContent = [this._Image1_i(),this.u_txtTitle_i(),this._Scroller1_i()];
	}
	var _proto = LuckyDrawRule.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 243;
		t.scale9Grid = new egret.Rectangle(203,124,49,21);
		t.source = "luckyDrawUI_json.luckyDrawUI_ruleBg";
		t.visible = true;
		t.width = 374;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 5;
		t.size = 18;
		t.stroke = 2;
		t.strokeColor = 0x333333;
		t.text = "规则说明";
		t.textAlign = "center";
		t.textColor = 0xFFE2C5;
		t.visible = true;
		t.y = 12.82;
		return t;
	};
	_proto._Scroller1_i = function () {
		var t = new eui.Scroller();
		t.height = 156;
		t.horizontalCenter = 5;
		t.width = 314;
		t.y = 56;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_txtMsg_i()];
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.lineSpacing = 12;
		t.size = 14;
		t.text = "规则";
		t.textColor = 0xF0E4B0;
		t.width = 314;
		t.wordWrap = true;
		t.y = 3;
		return t;
	};
	return LuckyDrawRule;
})(eui.Skin);generateEUI.paths['resource/eui_skins/mailUI/popup/MailPopupSkin.exml'] = window.MailUISkin = (function (_super) {
	__extends(MailUISkin, _super);
	function MailUISkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_scrollItem","u_textTitle","u_textGoods","u_textDesc","u_imgAttach_Line","u_textRecerive","u_grpRecerive","u_gapDescBg","u_textNoMail","u_grpNoMail","u_textReadclick","u_grpTip","u_btnClose","u_textAllRecerive","u_grpAllRecerive","u_textAllDel","u_grpAllDel","u_imgCentreLine"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_scrollItem_i(),this.u_gapDescBg_i(),this.u_grpNoMail_i(),this.u_grpTip_i(),this._Image7_i(),this._Label1_i(),this.u_btnClose_i(),this.u_grpAllRecerive_i(),this.u_grpAllDel_i(),this.u_imgCentreLine_i()];
	}
	var _proto = MailUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.fillMode = "scale";
		t.height = 500;
		t.horizontalCenter = -1;
		t.scale9Grid = new egret.Rectangle(10,78,10,9);
		t.source = "commonUI_json.commonUI_bg";
		t.visible = true;
		t.width = 840;
		t.y = 69.416;
		return t;
	};
	_proto.u_scrollItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollItem = t;
		t.height = 378;
		t.visible = true;
		t.width = 350;
		t.x = 147.508;
		t.y = 141.58;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 0.895;
		t.y = -0.452;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_gapDescBg_i = function () {
		var t = new eui.Group();
		this.u_gapDescBg = t;
		t.visible = false;
		t.width = 490;
		t.x = 497.216;
		t.y = 140.672;
		t.elementsContent = [this.u_textTitle_i(),this.u_textGoods_i(),this.u_textDesc_i(),this._Image2_i(),this.u_imgAttach_Line_i(),this._Image3_i(),this.u_grpRecerive_i()];
		return t;
	};
	_proto.u_textTitle_i = function () {
		var t = new eui.Label();
		this.u_textTitle = t;
		t.bold = true;
		t.horizontalCenter = 4;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 22;
		t.text = "充值钻石";
		t.textAlign = "center";
		t.textColor = 0xF0E6D2;
		t.visible = true;
		t.y = 26.276;
		t.zIndex = 1;
		return t;
	};
	_proto.u_textGoods_i = function () {
		var t = new eui.Label();
		this.u_textGoods = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 3.5;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 20;
		t.text = "附件";
		t.textAlign = "center";
		t.textColor = 0x3F393C;
		t.visible = false;
		t.y = 205.81;
		return t;
	};
	_proto.u_textDesc_i = function () {
		var t = new eui.Label();
		this.u_textDesc = t;
		t.fontFamily = "Microsoft YaHei";
		t.lineSpacing = 6;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 16;
		t.text = "一件获取页面需要优化二件获取页面需要优化三件获取页面需要优化四件获取页面需要优化五件获取页面需要优化六件获取页面需要优化七件获取页面需要优化八件获取页面需要优化九件获取页面需要优化十件获取页面需要优化一件获取页面需要优化二件获取页面需要优化三件获取页面需要优化四件获取页面需要优化五件获取页面需要优化";
		t.textAlign = "left";
		t.textColor = 0x999587;
		t.verticalAlign = "middle";
		t.width = 420;
		t.x = 36.926;
		t.y = 84.596;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "mailUI_json.mailUI_img_line2";
		t.width = 448;
		t.x = 20.536;
		t.y = 68.254;
		return t;
	};
	_proto.u_imgAttach_Line_i = function () {
		var t = new eui.Image();
		this.u_imgAttach_Line = t;
		t.source = "mailUI_json.mailUI_img_line2";
		t.width = 448;
		t.x = 20.536;
		t.y = 221.856;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "mailUI_json.mailUI_img_line2";
		t.width = 448;
		t.x = 19.864;
		t.y = 311.136;
		return t;
	};
	_proto.u_grpRecerive_i = function () {
		var t = new eui.Group();
		this.u_grpRecerive = t;
		t.visible = true;
		t.x = 174.616;
		t.y = 346.232;
		t.elementsContent = [this._Image4_i(),this.u_textRecerive_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.height = 50;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "mailUI_json.mailUI_all_delete";
		t.visible = true;
		t.width = 140;
		return t;
	};
	_proto.u_textRecerive_i = function () {
		var t = new eui.Label();
		this.u_textRecerive = t;
		t.horizontalCenter = 1;
		t.size = 20;
		t.text = "删 除";
		t.textColor = 0xF0E4B0;
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_grpNoMail_i = function () {
		var t = new eui.Group();
		this.u_grpNoMail = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 164;
		t.y = 272.74;
		t.elementsContent = [this._Image5_i(),this.u_textNoMail_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "mailUI_json.mailUI_hint";
		t.visible = true;
		t.x = 51.964;
		t.y = 0;
		return t;
	};
	_proto.u_textNoMail_i = function () {
		var t = new eui.Label();
		this.u_textNoMail = t;
		t.size = 20;
		t.text = "邮箱中无任何邮件";
		t.textColor = 0x999587;
		t.x = 3.225;
		t.y = 89.411;
		return t;
	};
	_proto.u_grpTip_i = function () {
		var t = new eui.Group();
		this.u_grpTip = t;
		t.visible = false;
		t.x = 668.612;
		t.y = 271.106;
		t.elementsContent = [this._Image6_i(),this.u_textReadclick_i()];
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "mailUI_json.mailUI_hint";
		t.visible = true;
		t.x = 43.361;
		t.y = 0;
		return t;
	};
	_proto.u_textReadclick_i = function () {
		var t = new eui.Label();
		this.u_textReadclick = t;
		t.horizontalCenter = 2;
		t.size = 20;
		t.text = "请点击邮件阅读";
		t.textColor = 0x999587;
		t.y = 88.051;
		return t;
	};
	_proto._Image7_i = function () {
		var t = new eui.Image();
		t.source = "mailUI_json.mailUI_icon_title";
		t.x = 160.908;
		t.y = 94.244;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.size = 16;
		t.text = "邮件";
		t.textColor = 0xF0E4B0;
		t.x = 205.873;
		t.y = 99.489;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 16;
		t.source = "commonUI_json.commonUI_btn_close_2";
		t.width = 16;
		t.x = 952.652;
		t.y = 99.022;
		return t;
	};
	_proto.u_grpAllRecerive_i = function () {
		var t = new eui.Group();
		this.u_grpAllRecerive = t;
		t.visible = true;
		t.x = 148.193;
		t.y = 520.064;
		t.elementsContent = [this._Image8_i(),this.u_textAllRecerive_i()];
		return t;
	};
	_proto._Image8_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "mailUI_json.mailUI_btn_allget";
		t.visible = true;
		return t;
	};
	_proto.u_textAllRecerive_i = function () {
		var t = new eui.Label();
		this.u_textAllRecerive = t;
		t.horizontalCenter = -0.5;
		t.size = 20;
		t.text = "全部领取";
		t.textColor = 0xF0E4B0;
		t.y = 17.03;
		return t;
	};
	_proto.u_grpAllDel_i = function () {
		var t = new eui.Group();
		this.u_grpAllDel = t;
		t.horizontalCenter = -157.5;
		t.visible = true;
		t.x = 137.093;
		t.y = 520.15;
		t.elementsContent = [this._Image9_i(),this.u_textAllDel_i()];
		return t;
	};
	_proto._Image9_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "mailUI_json.mailUI_all_delete";
		t.visible = true;
		return t;
	};
	_proto.u_textAllDel_i = function () {
		var t = new eui.Label();
		this.u_textAllDel = t;
		t.horizontalCenter = 0.5;
		t.size = 20;
		t.text = "全部删除";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 57;
		t.y = 16.48;
		return t;
	};
	_proto.u_imgCentreLine_i = function () {
		var t = new eui.Image();
		this.u_imgCentreLine = t;
		t.height = 428;
		t.source = "mailUI_json.mailUI_img_line1";
		t.x = 496.556;
		t.y = 141.228;
		return t;
	};
	return MailUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/mailUI/render/MailRenderSkin.exml'] = window.skins.MailUIRenderSkin = (function (_super) {
	__extends(MailUIRenderSkin, _super);
	function MailUIRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgIcon","u_imgNew","u_textTitle","u_textTime","u_imgSelect"];
		
		this.height = 72;
		this.width = 348;
		this.elementsContent = [this._Group1_i()];
	}
	var _proto = MailUIRenderSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 72;
		t.visible = true;
		t.width = 348;
		t.elementsContent = [this.u_imgIcon_i(),this.u_imgNew_i(),this.u_textTitle_i(),this.u_textTime_i(),this.u_imgSelect_i(),this._Image1_i()];
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.source = "mailUI_json.mailUI_icon_award";
		t.visible = true;
		t.x = 279.894;
		t.y = 9.329;
		return t;
	};
	_proto.u_imgNew_i = function () {
		var t = new eui.Image();
		this.u_imgNew = t;
		t.source = "mailUI_json.mailUI_tag_new";
		t.visible = true;
		t.x = 319.696;
		t.y = 2.627;
		return t;
	};
	_proto.u_textTitle_i = function () {
		var t = new eui.Label();
		this.u_textTitle = t;
		t.border = false;
		t.size = 18;
		t.text = "邮件标题";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.x = 20.736;
		t.y = 15.788;
		return t;
	};
	_proto.u_textTime_i = function () {
		var t = new eui.Label();
		this.u_textTime = t;
		t.borderColor = 0x333333;
		t.size = 16;
		t.strokeColor = 0x333333;
		t.text = "2021/04/13  14:50";
		t.textAlign = "left";
		t.textColor = 0xBEBAAB;
		t.visible = true;
		t.x = 20.619;
		t.y = 40.54;
		return t;
	};
	_proto.u_imgSelect_i = function () {
		var t = new eui.Image();
		this.u_imgSelect = t;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "mailUI_json.mailUI_select_base";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "mailUI_json.mailUI_img_line2";
		t.width = 310;
		t.x = 18.795;
		t.y = 70.807;
		return t;
	};
	return MailUIRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/minMap/popup/MinMapPopupSkin.exml'] = window.skins.MiniMapPopup = (function (_super) {
	__extends(MiniMapPopup, _super);
	function MiniMapPopup() {
		_super.call(this);
		this.skinParts = [];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i()];
	}
	var _proto = MiniMapPopup.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 390;
		t.horizontalCenter = 2;
		t.scale9Grid = new egret.Rectangle(37,37,38,38);
		t.source = "userMainUI_json.userMainUI_x_bj";
		t.verticalCenter = -1;
		t.width = 900;
		return t;
	};
	return MiniMapPopup;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionEitherUI/MissionEitherUISkin.exml'] = window.MissionEitherUISkin = (function (_super) {
	__extends(MissionEitherUISkin, _super);
	function MissionEitherUISkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_scrollerItem","u_txtMsg","u_btnGame"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_scrollerItem_i(),this.u_txtMsg_i(),this.u_btnGame_i()];
	}
	var _proto = MissionEitherUISkin.prototype;

	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 600;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 590;
		t.x = 10;
		t.y = 157;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.horizontalCenter = 0;
		t.text = "副本id： ";
		t.y = 940;
		return t;
	};
	_proto.u_btnGame_i = function () {
		var t = new eui.Group();
		this.u_btnGame = t;
		t.horizontalCenter = 0;
		t.y = 790;
		t.elementsContent = [this._Image1_i(),this._Image2_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_btn_6";
		t.x = 8;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_challenge";
		t.x = 0;
		t.y = 47;
		return t;
	};
	return MissionEitherUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionEitherUI/render/MissionEitherRenderSkin.exml'] = window.MissionEitherRenderSkin = (function (_super) {
	__extends(MissionEitherRenderSkin, _super);
	function MissionEitherRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtName","u_btnSelect"];
		
		this.height = 60;
		this.width = 580;
		this.elementsContent = [this.u_txtName_i(),this.u_btnSelect_i()];
	}
	var _proto = MissionEitherRenderSkin.prototype;

	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.text = "副本id： ";
		t.verticalCenter = 0;
		t.x = 141;
		return t;
	};
	_proto.u_btnSelect_i = function () {
		var t = new eui.Image();
		this.u_btnSelect = t;
		t.alpha = 0;
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(26,27,27,27);
		t.source = "commonsUI_json.commonUI_box_1";
		t.verticalCenter = 0;
		t.width = 580;
		return t;
	};
	return MissionEitherRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionJieSuanUI/MissionRankSkin.exml'] = window.MissionRankSkin = (function (_super) {
	__extends(MissionRankSkin, _super);
	function MissionRankSkin() {
		_super.call(this);
		this.skinParts = ["u_btnMore","u_imgBg","u_imgRate","u_listItem","u_scrollerItem","u_imgMyRate","u_txtMySpend","u_grpMyRank","u_grpRank","u_btnShow"];
		
		this.width = 334;
		this.elementsContent = [this.u_grpRank_i(),this.u_btnShow_i()];
	}
	var _proto = MissionRankSkin.prototype;

	_proto.u_grpRank_i = function () {
		var t = new eui.Group();
		this.u_grpRank = t;
		t.right = 0;
		t.y = 56;
		t.elementsContent = [this.u_btnMore_i(),this.u_imgBg_i(),this._Image1_i(),this._Image2_i(),this._Group1_i(),this.u_scrollerItem_i(),this.u_imgMyRate_i(),this.u_txtMySpend_i(),this.u_grpMyRank_i()];
		return t;
	};
	_proto.u_btnMore_i = function () {
		var t = new eui.Image();
		this.u_btnMore = t;
		t.horizontalCenter = 1;
		t.scaleY = 1;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_arrow1";
		t.top = -34;
		return t;
	};
	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.bottom = 0;
		t.scale9Grid = new egret.Rectangle(111,68,112,69);
		t.source = "missionJieSuanUI_json.missionJieSuanUI_di2";
		t.visible = true;
		t.x = 0;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "missionJieSuanUI_json.missionJieSuanUI_ranking";
		t.top = 11;
		t.visible = true;
		t.x = 11;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "missionJieSuanUI_json.missionJieSuanUI_name";
		t.top = 11;
		t.visible = true;
		t.x = 104;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.top = 11;
		t.width = 140;
		t.x = 194;
		t.elementsContent = [this.u_imgRate_i()];
		return t;
	};
	_proto.u_imgRate_i = function () {
		var t = new eui.Image();
		this.u_imgRate = t;
		t.horizontalCenter = 0;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_mana";
		t.visible = true;
		t.y = 0;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 103;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 300;
		t.y = 44;
		t.viewport = this._Group2_i();
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.bottom = 0;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgMyRate_i = function () {
		var t = new eui.Image();
		this.u_imgMyRate = t;
		t.bottom = 24;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_ss_myPro";
		t.visible = true;
		t.x = 87;
		return t;
	};
	_proto.u_txtMySpend_i = function () {
		var t = new eui.Label();
		this.u_txtMySpend = t;
		t.bold = true;
		t.bottom = 25;
		t.size = 16;
		t.stroke = 1.5;
		t.strokeColor = 0x302B1E;
		t.text = "99999";
		t.textColor = 0xECCFA6;
		t.visible = true;
		t.x = 237;
		return t;
	};
	_proto.u_grpMyRank_i = function () {
		var t = new eui.Group();
		this.u_grpMyRank = t;
		t.bottom = 24;
		t.height = 18;
		t.width = 80;
		t.x = 6;
		return t;
	};
	_proto.u_btnShow_i = function () {
		var t = new eui.Image();
		this.u_btnShow = t;
		t.height = 51;
		t.right = -1;
		t.source = "commonsUI_json.commonsUI_back_3";
		t.visible = true;
		return t;
	};
	return MissionRankSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionJieSuanUI/MissionUIExitBtnSkin.exml'] = window.MissionUIExitBtnSkin = (function (_super) {
	__extends(MissionUIExitBtnSkin, _super);
	function MissionUIExitBtnSkin() {
		_super.call(this);
		this.skinParts = [];
		
		this.height = 72;
		this.width = 68;
		this.elementsContent = [this._Image1_i()];
	}
	var _proto = MissionUIExitBtnSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_back_2";
		return t;
	};
	return MissionUIExitBtnSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionJieSuanUI/MissionUIPointSkin.exml'] = window.MissionUIPointSkin = (function (_super) {
	__extends(MissionUIPointSkin, _super);
	function MissionUIPointSkin() {
		_super.call(this);
		this.skinParts = ["u_imgLv","u_grpLv"];
		
		this.height = 78;
		this.width = 364;
		this.elementsContent = [this._Image1_i(),this.u_grpLv_i()];
	}
	var _proto = MissionUIPointSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_u_biaoti";
		return t;
	};
	_proto.u_grpLv_i = function () {
		var t = new eui.Group();
		this.u_grpLv = t;
		t.horizontalCenter = 0.5;
		t.verticalCenter = -0.5;
		t.elementsContent = [this.u_imgLv_i()];
		return t;
	};
	_proto.u_imgLv_i = function () {
		var t = new eui.Image();
		this.u_imgLv = t;
		t.source = "missionText_json.missionText_num_l";
		t.x = 0;
		t.y = 0;
		return t;
	};
	return MissionUIPointSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionJieSuanUI/MissionUITimeSkin.exml'] = window.MissionUITimeSkin = (function (_super) {
	__extends(MissionUITimeSkin, _super);
	function MissionUITimeSkin() {
		_super.call(this);
		this.skinParts = ["u_imgTime","u_grpTime"];
		
		this.height = 40;
		this.width = 321;
		this.elementsContent = [this._Image1_i(),this.u_imgTime_i(),this.u_grpTime_i()];
	}
	var _proto = MissionUITimeSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "";
		return t;
	};
	_proto.u_imgTime_i = function () {
		var t = new eui.Image();
		this.u_imgTime = t;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_time_1";
		t.width = 187;
		t.x = 30;
		t.y = 0;
		return t;
	};
	_proto.u_grpTime_i = function () {
		var t = new eui.Group();
		this.u_grpTime = t;
		t.height = 40;
		t.width = 70;
		t.x = 218;
		t.y = -1;
		return t;
	};
	return MissionUITimeSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionJieSuanUI/popup/MissionFailPopupSkinSkin.exml'] = window.MissionFailPopupSkinSkin = (function (_super) {
	__extends(MissionFailPopupSkinSkin, _super);
	function MissionFailPopupSkinSkin() {
		_super.call(this);
		this.skinParts = ["u_txtDesc","u_txtLeave","u_btnLeave"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtDesc_i(),this.u_btnLeave_i()];
	}
	var _proto = MissionFailPopupSkinSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 5;
		t.source = "missionCompleteUI_json.missionCompleteUI_bg";
		t.visible = true;
		t.y = 405;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 6;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_defeated";
		t.visible = true;
		t.y = 381;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.lineSpacing = 10;
		t.size = 24;
		t.text = "xxxxxxxxxxxxxxxxxxx";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.verticalCenter = -20;
		t.visible = true;
		t.width = 470;
		t.wordWrap = true;
		return t;
	};
	_proto.u_btnLeave_i = function () {
		var t = new eui.Group();
		this.u_btnLeave = t;
		t.height = 65;
		t.horizontalCenter = 0.5;
		t.visible = true;
		t.width = 160;
		t.y = 655;
		t.elementsContent = [this._Image3_i(),this.u_txtLeave_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(64,22,2,21);
		t.source = "commonsUI_json.commonsUI_btn_7";
		t.visible = true;
		t.width = 160;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtLeave_i = function () {
		var t = new eui.Label();
		this.u_txtLeave = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "Leave(10)";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	return MissionFailPopupSkinSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionJieSuanUI/popup/MissionFirstPrizePopupSkin.exml'] = window.MissionFirstPrizePopupSkin = (function (_super) {
	__extends(MissionFirstPrizePopupSkin, _super);
	function MissionFirstPrizePopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtMsg","u_txtRank","u_grpReward","u_txtOK","u_btnOK","u_btnClose"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtMsg_i(),this.u_txtRank_i(),this._Image3_i(),this._Image4_i(),this.u_grpReward_i(),this.u_btnOK_i(),this.u_btnClose_i()];
	}
	var _proto = MissionFirstPrizePopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "missionJieSuanUI_json.missionJieSuanUI_bg";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = -1.5;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_title";
		t.visible = true;
		t.y = 175;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "Congratulations on winning the first prize";
		t.visible = true;
		t.y = 343;
		return t;
	};
	_proto.u_txtRank_i = function () {
		var t = new eui.Label();
		this.u_txtRank = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "Ranking :  ";
		t.visible = true;
		t.y = 395;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 6.5;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_design";
		t.y = 459;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "missionJieSuanUI_json.missionJieSuanUI_rewarded";
		t.visible = true;
		t.x = 271;
		t.y = 455;
		return t;
	};
	_proto.u_grpReward_i = function () {
		var t = new eui.Group();
		this.u_grpReward = t;
		t.height = 220;
		t.horizontalCenter = 0;
		t.y = 510;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.height = 65;
		t.horizontalCenter = 6.5;
		t.visible = true;
		t.width = 135;
		t.y = 770;
		t.elementsContent = [this._Image5_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "OK";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 40;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.visible = true;
		t.width = 40;
		t.x = 567;
		t.y = 181;
		return t;
	};
	return MissionFirstPrizePopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionJieSuanUI/popup/MissionPrizePopupSkin.exml'] = window.MissionPrizePopupSkin = (function (_super) {
	__extends(MissionPrizePopupSkin, _super);
	function MissionPrizePopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtMsg","u_txtMsg2","u_txtRank","u_grpMsg","u_txtOK","u_btnOK"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_grpMsg_i(),this.u_btnOK_i()];
	}
	var _proto = MissionPrizePopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "missionCompleteUI_json.missionCompleteUI_bg";
		t.visible = true;
		t.y = 421;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 4;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_complete";
		t.visible = true;
		t.y = 381;
		return t;
	};
	_proto.u_grpMsg_i = function () {
		var t = new eui.Group();
		this.u_grpMsg = t;
		t.horizontalCenter = 0;
		t.y = 538;
		t.elementsContent = [this.u_txtMsg_i(),this.u_txtMsg2_i(),this.u_txtRank_i()];
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "Unfortunately, you didn't get the first prize";
		t.visible = true;
		t.y = -2;
		return t;
	};
	_proto.u_txtMsg2_i = function () {
		var t = new eui.Label();
		this.u_txtMsg2 = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "Unfortunately, you didn't get the first prize";
		t.visible = true;
		t.x = 10;
		t.y = 26;
		return t;
	};
	_proto.u_txtRank_i = function () {
		var t = new eui.Label();
		this.u_txtRank = t;
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "Ranking :  ";
		t.visible = true;
		t.y = 54;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.height = 65;
		t.horizontalCenter = 0.5;
		t.visible = true;
		t.width = 135;
		t.y = 679;
		t.elementsContent = [this._Image3_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "OK";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	return MissionPrizePopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionJieSuanUI/render/MissionRankRenderSkin.exml'] = window.MissionRankRenderSkin = (function (_super) {
	__extends(MissionRankRenderSkin, _super);
	function MissionRankRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgRank","u_grpRank","u_txtName","u_txtSpend"];
		
		this.height = 32;
		this.width = 300;
		this.elementsContent = [this.u_grpRank_i(),this.u_txtName_i(),this.u_txtSpend_i()];
	}
	var _proto = MissionRankRenderSkin.prototype;

	_proto.u_grpRank_i = function () {
		var t = new eui.Group();
		this.u_grpRank = t;
		t.height = 32;
		t.visible = true;
		t.width = 35;
		t.x = 11;
		t.y = 0;
		t.elementsContent = [this.u_imgRank_i()];
		return t;
	};
	_proto.u_imgRank_i = function () {
		var t = new eui.Image();
		this.u_imgRank = t;
		t.horizontalCenter = 0;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_rank_1";
		t.visible = true;
		t.y = 0;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.bold = true;
		t.size = 16;
		t.stroke = 1;
		t.strokeColor = 0x2B2626;
		t.text = "name name name";
		t.textAlign = "center";
		t.visible = true;
		t.width = 160;
		t.x = 50;
		t.y = 9;
		return t;
	};
	_proto.u_txtSpend_i = function () {
		var t = new eui.Label();
		this.u_txtSpend = t;
		t.bold = true;
		t.size = 20;
		t.stroke = 1;
		t.strokeColor = 0x2B2626;
		t.text = "999999";
		t.textAlign = "center";
		t.textColor = 0xFF0000;
		t.visible = true;
		t.width = 100;
		t.x = 200;
		t.y = 7;
		return t;
	};
	return MissionRankRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionMultiUI/page/MissionMultiCreateSkin.exml'] = window.MissionMultiCreateSkin = (function (_super) {
	__extends(MissionMultiCreateSkin, _super);
	function MissionMultiCreateSkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_txtLimit","u_txtPart","u_txtMana","u_imgIcon1","u_txtEnteryCost","u_txtDesc","u_txtSingle","u_imgIcon2","u_txtSingleCost","u_txtAward","u_txtSetPass","u_iconGou","u_btnGou","u_txtInput","u_txtOK","u_btnOK"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this.u_listItem_i(),this.u_txtLimit_i(),this.u_txtPart_i(),this.u_txtMana_i(),this.u_imgIcon1_i(),this.u_txtEnteryCost_i(),this._Image2_i(),this.u_txtDesc_i(),this.u_txtSingle_i(),this.u_imgIcon2_i(),this.u_txtSingleCost_i(),this.u_txtAward_i(),this._Image3_i(),this.u_txtSetPass_i(),this.u_btnGou_i(),this._Group1_i(),this.u_btnOK_i()];
	}
	var _proto = MissionMultiCreateSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 450;
		t.scale9Grid = new egret.Rectangle(29,29,30,30);
		t.source = "commonsUI_json.commonUI_box_2";
		t.visible = true;
		t.width = 584;
		t.x = 29;
		t.y = 98;
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.width = 550;
		t.x = 45;
		t.y = 140;
		return t;
	};
	_proto.u_txtLimit_i = function () {
		var t = new eui.Label();
		this.u_txtLimit = t;
		t.bold = true;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "Limit: VIP1";
		t.visible = true;
		t.x = 68;
		t.y = 451;
		return t;
	};
	_proto.u_txtPart_i = function () {
		var t = new eui.Label();
		this.u_txtPart = t;
		t.bold = true;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "Participants: 5";
		t.visible = true;
		t.x = 271;
		t.y = 449;
		return t;
	};
	_proto.u_txtMana_i = function () {
		var t = new eui.Label();
		this.u_txtMana = t;
		t.bold = true;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "Player entry conditions:";
		t.textColor = 0xFFFFFF;
		t.visible = true;
		t.x = 68;
		t.y = 497;
		return t;
	};
	_proto.u_imgIcon1_i = function () {
		var t = new eui.Image();
		this.u_imgIcon1 = t;
		t.source = "userMainUI_json.userMainUI_u_yinbi_a";
		t.visible = true;
		t.x = 346;
		t.y = 493;
		return t;
	};
	_proto.u_txtEnteryCost_i = function () {
		var t = new eui.Label();
		this.u_txtEnteryCost = t;
		t.bold = true;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "2000";
		t.textColor = 0x00E22B;
		t.visible = true;
		t.x = 378;
		t.y = 497;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0.5;
		t.source = "commonsUI_json.commonsUI_line2";
		t.visible = true;
		t.y = 569;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.bold = true;
		t.horizontalCenter = 7;
		t.size = 22;
		t.text = "Description";
		t.textColor = 0x38445D;
		t.visible = true;
		t.y = 559;
		return t;
	};
	_proto.u_txtSingle_i = function () {
		var t = new eui.Label();
		this.u_txtSingle = t;
		t.bold = true;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "A single consumption:";
		t.textColor = 0xFFFFFF;
		t.visible = true;
		t.x = 60;
		t.y = 609;
		return t;
	};
	_proto.u_imgIcon2_i = function () {
		var t = new eui.Image();
		this.u_imgIcon2 = t;
		t.source = "userMainUI_json.userMainUI_u_yinbi_a";
		t.visible = true;
		t.x = 323;
		t.y = 605;
		return t;
	};
	_proto.u_txtSingleCost_i = function () {
		var t = new eui.Label();
		this.u_txtSingleCost = t;
		t.bold = true;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "2000";
		t.textColor = 0x00E22B;
		t.visible = true;
		t.x = 360;
		t.y = 609;
		return t;
	};
	_proto.u_txtAward_i = function () {
		var t = new eui.Label();
		this.u_txtAward = t;
		t.bold = true;
		t.lineSpacing = 8;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "Award : 90% gold coin of the total silver coin consumed by all players";
		t.visible = true;
		t.width = 479;
		t.wordWrap = true;
		t.x = 60;
		t.y = 658;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(114,1,114,0);
		t.source = "commonsUI_json.commonsUI_line";
		t.visible = true;
		t.width = 524;
		t.y = 727;
		return t;
	};
	_proto.u_txtSetPass_i = function () {
		var t = new eui.Label();
		this.u_txtSetPass = t;
		t.bold = true;
		t.size = 24;
		t.text = "Set password";
		t.textColor = 0x4C5B7B;
		t.visible = true;
		t.x = 62;
		t.y = 769;
		return t;
	};
	_proto.u_btnGou_i = function () {
		var t = new eui.Group();
		this.u_btnGou = t;
		t.height = 33;
		t.visible = true;
		t.width = 33;
		t.x = 229;
		t.y = 764;
		t.elementsContent = [this._Image4_i(),this.u_iconGou_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_gou _di";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_iconGou_i = function () {
		var t = new eui.Image();
		this.u_iconGou = t;
		t.horizontalCenter = 1.5;
		t.source = "commonsUI_json.commonsUI_gou";
		t.verticalCenter = -1.5;
		t.visible = true;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 54;
		t.y = 807;
		t.elementsContent = [this._Image5_i(),this.u_txtInput_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "missionMultiUI_json.missionMultiUI_bg_password";
		t.visible = true;
		return t;
	};
	_proto.u_txtInput_i = function () {
		var t = new eui.EditableText();
		this.u_txtInput = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.height = 45;
		t.horizontalCenter = "0";
		t.maxChars = 6;
		t.multiline = false;
		t.promptColor = 0x5E7089;
		t.size = 24;
		t.textColor = 0x614C4B;
		t.verticalAlign = "middle";
		t.verticalCenter = "0";
		t.visible = true;
		t.width = 340;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.height = 65;
		t.horizontalCenter = 2;
		t.visible = true;
		t.width = 200;
		t.y = 888;
		t.elementsContent = [this._Image6_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_3";
		t.visible = true;
		t.width = 200;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "OK";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	return MissionMultiCreateSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionMultiUI/page/MissionMultiListSkin.exml'] = window.MissionMultiListSkin = (function (_super) {
	__extends(MissionMultiListSkin, _super);
	function MissionMultiListSkin() {
		_super.call(this);
		this.skinParts = ["u_txtSelect","u_imgIcon","u_txtSingleCost","u_grpCost","u_iconArrow","u_btnSelect","u_imgNone","u_listItem","u_scrollerItem","u_txtTips","u_btnInput","u_txtTime","u_txtRefresh","u_btnRefresh"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_btnSelect_i(),this.u_imgNone_i(),this.u_scrollerItem_i(),this.u_btnInput_i(),this.u_txtTime_i(),this.u_btnRefresh_i()];
	}
	var _proto = MissionMultiListSkin.prototype;

	_proto.u_btnSelect_i = function () {
		var t = new eui.Group();
		this.u_btnSelect = t;
		t.x = 42;
		t.y = 114;
		t.elementsContent = [this.u_txtSelect_i(),this.u_grpCost_i(),this.u_iconArrow_i()];
		return t;
	};
	_proto.u_txtSelect_i = function () {
		var t = new eui.Label();
		this.u_txtSelect = t;
		t.bold = true;
		t.size = 20;
		t.text = "A single:";
		t.textColor = 0x8999AC;
		t.visible = true;
		t.x = 0;
		t.y = 7;
		return t;
	};
	_proto.u_grpCost_i = function () {
		var t = new eui.Group();
		this.u_grpCost = t;
		t.x = 220;
		t.y = 0;
		t.elementsContent = [this.u_imgIcon_i(),this.u_txtSingleCost_i()];
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.source = "userMainUI_json.userMainUI_u_yinbi_a";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtSingleCost_i = function () {
		var t = new eui.Label();
		this.u_txtSingleCost = t;
		t.bold = true;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "2000";
		t.textColor = 0x00E22B;
		t.visible = true;
		t.x = 30.94;
		t.y = 8.2;
		return t;
	};
	_proto.u_iconArrow_i = function () {
		var t = new eui.Image();
		this.u_iconArrow = t;
		t.source = "missionMultiUI_json.missionMultiUI_icon_1";
		t.visible = true;
		t.x = 303;
		t.y = 10;
		return t;
	};
	_proto.u_imgNone_i = function () {
		var t = new eui.Image();
		this.u_imgNone = t;
		t.horizontalCenter = 0;
		t.source = "missionMultiUI_json.missionMultiUI_none";
		t.y = 500;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 740;
		t.horizontalCenter = 1;
		t.visible = true;
		t.width = 567;
		t.y = 159;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnInput_i = function () {
		var t = new eui.Group();
		this.u_btnInput = t;
		t.visible = true;
		t.x = 72;
		t.y = 914;
		t.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtTips_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.scale9Grid = new egret.Rectangle(80,17,81,17);
		t.source = "missionMultiUI_json.missionMultiUI_bg_password";
		t.visible = true;
		t.width = 260;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "missionMultiUI_json.missionMultiUI_icon_2";
		t.visible = true;
		t.x = 6;
		t.y = 10;
		return t;
	};
	_proto.u_txtTips_i = function () {
		var t = new eui.Label();
		this.u_txtTips = t;
		t.bold = true;
		t.size = 20;
		t.text = "Enter invitation code";
		t.textColor = 0x5F7089;
		t.visible = true;
		t.x = 37;
		t.y = 17;
		return t;
	};
	_proto.u_txtTime_i = function () {
		var t = new eui.Label();
		this.u_txtTime = t;
		t.bold = true;
		t.size = 18;
		t.stroke = 1;
		t.text = "(10s)";
		t.textAlign = "center";
		t.width = 142;
		t.x = 418;
		t.y = 964;
		return t;
	};
	_proto.u_btnRefresh_i = function () {
		var t = new eui.Group();
		this.u_btnRefresh = t;
		t.height = 55;
		t.visible = true;
		t.width = 142;
		t.x = 418;
		t.y = 911;
		t.elementsContent = [this._Image3_i(),this.u_txtRefresh_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 55;
		t.source = "commonsUI_json.commonsUI_btn_7";
		t.visible = true;
		t.width = 142;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtRefresh_i = function () {
		var t = new eui.Label();
		this.u_txtRefresh = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "Refresh";
		t.textColor = 0x38445D;
		t.verticalCenter = 0;
		return t;
	};
	return MissionMultiListSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionMultiUI/page/MissionMultiRoomSkin.exml'] = window.MissionMultiRoomSkin = (function (_super) {
	__extends(MissionMultiRoomSkin, _super);
	function MissionMultiRoomSkin() {
		_super.call(this);
		this.skinParts = ["u_txtOwner","u_txtRoomId","u_txtCode","u_txtcopy","u_txtPart","u_txtInfo","u_txtSingle","u_imgIcon2","u_txtSingleCost","u_txtAward","u_grpInfo","u_grpHead","u_txtMana","u_imgIcon1","u_txtEnteryCost","u_txtLeave","u_btnLeave","u_txtReady","u_btnReady","u_txtStart","u_btnStart"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_txtOwner_i(),this.u_txtRoomId_i(),this.u_txtCode_i(),this.u_txtcopy_i(),this.u_txtPart_i(),this._Image1_i(),this.u_grpInfo_i(),this.u_grpHead_i(),this._Group1_i(),this.u_btnLeave_i(),this.u_btnReady_i(),this.u_btnStart_i()];
	}
	var _proto = MissionMultiRoomSkin.prototype;

	_proto.u_txtOwner_i = function () {
		var t = new eui.Label();
		this.u_txtOwner = t;
		t.bold = true;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "Homeowner:";
		t.textColor = 0x53B4FF;
		t.visible = true;
		t.x = 43;
		t.y = 119;
		return t;
	};
	_proto.u_txtRoomId_i = function () {
		var t = new eui.Label();
		this.u_txtRoomId = t;
		t.bold = true;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "Room ID:";
		t.textColor = 0x53B4FF;
		t.visible = true;
		t.x = 43;
		t.y = 155;
		return t;
	};
	_proto.u_txtCode_i = function () {
		var t = new eui.Label();
		this.u_txtCode = t;
		t.bold = true;
		t.horizontalCenter = 21;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "Invitation code:";
		t.textColor = 0x53B4FF;
		t.visible = true;
		t.y = 155;
		return t;
	};
	_proto.u_txtcopy_i = function () {
		var t = new eui.Label();
		this.u_txtcopy = t;
		t.bold = true;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "copy";
		t.textColor = 0x4DEA00;
		t.visible = true;
		t.x = 525;
		t.y = 157;
		return t;
	};
	_proto.u_txtPart_i = function () {
		var t = new eui.Label();
		this.u_txtPart = t;
		t.bold = true;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "Participants:";
		t.textColor = 0x53B4FF;
		t.visible = true;
		t.x = 428;
		t.y = 520;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 375;
		t.horizontalCenter = 0.5;
		t.scale9Grid = new egret.Rectangle(29,29,30,30);
		t.source = "commonsUI_json.commonUI_box_2";
		t.visible = true;
		t.width = 585;
		t.y = 187;
		return t;
	};
	_proto.u_grpInfo_i = function () {
		var t = new eui.Group();
		this.u_grpInfo = t;
		t.visible = true;
		t.x = 48;
		t.y = 595;
		t.elementsContent = [this._Image2_i(),this.u_txtInfo_i(),this._Image3_i(),this.u_txtSingle_i(),this.u_imgIcon2_i(),this.u_txtSingleCost_i(),this.u_txtAward_i(),this._Image4_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_line2";
		t.visible = true;
		t.x = 29;
		t.y = 9;
		return t;
	};
	_proto.u_txtInfo_i = function () {
		var t = new eui.Label();
		this.u_txtInfo = t;
		t.bold = true;
		t.size = 22;
		t.text = "Information";
		t.textColor = 0x38445D;
		t.visible = true;
		t.x = 221;
		t.y = 0;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "missionMultiUI_json.missionMultiUI_boss_select_1";
		t.visible = true;
		t.y = 90;
		return t;
	};
	_proto.u_txtSingle_i = function () {
		var t = new eui.Label();
		this.u_txtSingle = t;
		t.bold = true;
		t.size = 18;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "A single consumption:";
		t.textColor = 0xFFFFFF;
		t.visible = true;
		t.x = 195;
		t.y = 47;
		return t;
	};
	_proto.u_imgIcon2_i = function () {
		var t = new eui.Image();
		this.u_imgIcon2 = t;
		t.source = "userMainUI_json.userMainUI_u_yinbi_a";
		t.visible = true;
		t.x = 394;
		t.y = 40;
		return t;
	};
	_proto.u_txtSingleCost_i = function () {
		var t = new eui.Label();
		this.u_txtSingleCost = t;
		t.bold = true;
		t.size = 18;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "2000";
		t.textColor = 0x00E22B;
		t.visible = true;
		t.x = 426;
		t.y = 47;
		return t;
	};
	_proto.u_txtAward_i = function () {
		var t = new eui.Label();
		this.u_txtAward = t;
		t.bold = true;
		t.lineSpacing = 15;
		t.size = 18;
		t.stroke = 1.5;
		t.strokeColor = 0x72777F;
		t.text = "Award : 90% gold coin of the total silver coin consumed by all players";
		t.visible = true;
		t.width = 315;
		t.wordWrap = true;
		t.x = 191;
		t.y = 105;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(114,1,114,0);
		t.source = "commonsUI_json.commonsUI_line";
		t.width = 484;
		t.x = 30;
		t.y = 192;
		return t;
	};
	_proto.u_grpHead_i = function () {
		var t = new eui.Group();
		this.u_grpHead = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 540;
		t.y = 195;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0.5;
		t.y = 825;
		t.elementsContent = [this.u_txtMana_i(),this.u_imgIcon1_i(),this.u_txtEnteryCost_i()];
		return t;
	};
	_proto.u_txtMana_i = function () {
		var t = new eui.Label();
		this.u_txtMana = t;
		t.bold = true;
		t.size = 18;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "Player entry conditions:";
		t.textColor = 0xFFD800;
		t.visible = true;
		t.x = 0;
		t.y = 7;
		return t;
	};
	_proto.u_imgIcon1_i = function () {
		var t = new eui.Image();
		this.u_imgIcon1 = t;
		t.source = "userMainUI_json.userMainUI_u_yinbi_a";
		t.visible = true;
		t.x = 206;
		t.y = 0;
		return t;
	};
	_proto.u_txtEnteryCost_i = function () {
		var t = new eui.Label();
		this.u_txtEnteryCost = t;
		t.bold = true;
		t.size = 18;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "2000";
		t.textColor = 0x00E22B;
		t.visible = true;
		t.x = 238;
		t.y = 7;
		return t;
	};
	_proto.u_btnLeave_i = function () {
		var t = new eui.Group();
		this.u_btnLeave = t;
		t.height = 65;
		t.visible = true;
		t.width = 200;
		t.x = 77;
		t.y = 898;
		t.elementsContent = [this._Image5_i(),this.u_txtLeave_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_3";
		t.visible = true;
		t.width = 200;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtLeave_i = function () {
		var t = new eui.Label();
		this.u_txtLeave = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "Leave";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btnReady_i = function () {
		var t = new eui.Group();
		this.u_btnReady = t;
		t.height = 65;
		t.visible = true;
		t.width = 200;
		t.x = 369;
		t.y = 898;
		t.elementsContent = [this._Image6_i(),this.u_txtReady_i()];
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_3";
		t.visible = true;
		t.width = 200;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtReady_i = function () {
		var t = new eui.Label();
		this.u_txtReady = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "Ready";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btnStart_i = function () {
		var t = new eui.Group();
		this.u_btnStart = t;
		t.height = 65;
		t.visible = true;
		t.width = 200;
		t.x = 220;
		t.y = 898;
		t.elementsContent = [this._Image7_i(),this.u_txtStart_i()];
		return t;
	};
	_proto._Image7_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_3";
		t.visible = true;
		t.width = 200;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtStart_i = function () {
		var t = new eui.Label();
		this.u_txtStart = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "Start";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	return MissionMultiRoomSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionMultiUI/popup/MissionMultiFindPopupSkin.exml'] = window.MissionMultiFindPopupSkin = (function (_super) {
	__extends(MissionMultiFindPopupSkin, _super);
	function MissionMultiFindPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtCode","u_txtInput","u_btnInput","u_txtCancel","u_btnCancel","u_txtOK","u_btnOK","u_btnClose"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtCode_i(),this.u_btnInput_i(),this.u_btnCancel_i(),this.u_btnOK_i(),this.u_btnClose_i()];
	}
	var _proto = MissionMultiFindPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "commonPanelUI_json.commonPanelUI_panel_4";
		t.visible = true;
		t.x = 76;
		t.y = 428;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "missionMultiUI_json.missionMultiUI_txt_find";
		t.x = 195;
		t.y = 428;
		return t;
	};
	_proto.u_txtCode_i = function () {
		var t = new eui.Label();
		this.u_txtCode = t;
		t.size = 24;
		t.text = "Invitation code";
		t.textColor = 0x4C5B7B;
		t.visible = true;
		t.x = 146;
		t.y = 527;
		return t;
	};
	_proto.u_btnInput_i = function () {
		var t = new eui.Group();
		this.u_btnInput = t;
		t.visible = true;
		t.x = 142;
		t.y = 561;
		t.elementsContent = [this._Image3_i(),this.u_txtInput_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.scale9Grid = new egret.Rectangle(80,17,81,17);
		t.source = "missionMultiUI_json.missionMultiUI_bg_password";
		t.visible = true;
		t.width = 368;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtInput_i = function () {
		var t = new eui.EditableText();
		this.u_txtInput = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.height = 41;
		t.horizontalCenter = "0";
		t.maxChars = 6;
		t.promptColor = 0x5E7089;
		t.size = 24;
		t.textColor = 0x4C5B7B;
		t.verticalAlign = "middle";
		t.verticalCenter = "0";
		t.visible = true;
		t.width = 350;
		return t;
	};
	_proto.u_btnCancel_i = function () {
		var t = new eui.Group();
		this.u_btnCancel = t;
		t.height = 60;
		t.scaleX = 0.9;
		t.scaleY = 0.9;
		t.visible = true;
		t.width = 140;
		t.x = 348;
		t.y = 648;
		t.elementsContent = [this._Image4_i(),this.u_txtCancel_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(64,16,1,1);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.width = 140;
		return t;
	};
	_proto.u_txtCancel_i = function () {
		var t = new eui.Label();
		this.u_txtCancel = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "Cancel";
		t.textColor = 0x38445D;
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.height = 60;
		t.scaleX = 0.9;
		t.scaleY = 0.9;
		t.visible = true;
		t.width = 140;
		t.x = 162;
		t.y = 648;
		t.elementsContent = [this._Image5_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(64,16,1,1);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.width = 140;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "OK";
		t.textColor = 0x38445D;
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 40;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.visible = true;
		t.width = 40;
		t.x = 512;
		t.y = 428;
		return t;
	};
	return MissionMultiFindPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionMultiUI/popup/MissionMultiJoinPopupSkin.exml'] = window.MissionMultiJoinPopupSkin = (function (_super) {
	__extends(MissionMultiJoinPopupSkin, _super);
	function MissionMultiJoinPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtRoomId","u_txtPass","u_txtInput","u_btnInput","u_btnClose","u_txtCancel","u_btnCancel","u_txtOK","u_btnOK"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtRoomId_i(),this.u_txtPass_i(),this.u_btnInput_i(),this.u_btnClose_i(),this.u_btnCancel_i(),this.u_btnOK_i()];
	}
	var _proto = MissionMultiJoinPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "commonPanelUI_json.commonPanelUI_panel_4";
		t.visible = true;
		t.x = 76;
		t.y = 428;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "missionMultiUI_json.missionMultiUI_txt_join";
		t.x = 195;
		t.y = 428;
		return t;
	};
	_proto.u_txtRoomId_i = function () {
		var t = new eui.Label();
		this.u_txtRoomId = t;
		t.bold = true;
		t.size = 24;
		t.text = "Room ID    11";
		t.textColor = 0x4C5B7B;
		t.visible = true;
		t.x = 140;
		t.y = 520;
		return t;
	};
	_proto.u_txtPass_i = function () {
		var t = new eui.Label();
		this.u_txtPass = t;
		t.bold = true;
		t.size = 24;
		t.text = "Password";
		t.textColor = 0x4C5B7B;
		t.visible = true;
		t.x = 140;
		t.y = 573;
		return t;
	};
	_proto.u_btnInput_i = function () {
		var t = new eui.Group();
		this.u_btnInput = t;
		t.visible = true;
		t.x = 262;
		t.y = 558;
		t.elementsContent = [this._Image3_i(),this.u_txtInput_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.scale9Grid = new egret.Rectangle(80,17,81,17);
		t.source = "missionMultiUI_json.missionMultiUI_bg_password";
		t.visible = true;
		t.width = 240;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtInput_i = function () {
		var t = new eui.EditableText();
		this.u_txtInput = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.height = 41;
		t.horizontalCenter = "0";
		t.maxChars = 6;
		t.promptColor = 0x5E7089;
		t.size = 24;
		t.textColor = 0x4C5B7B;
		t.verticalAlign = "middle";
		t.verticalCenter = "0";
		t.visible = true;
		t.width = 220;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 40;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.visible = true;
		t.width = 40;
		t.x = 512;
		t.y = 428;
		return t;
	};
	_proto.u_btnCancel_i = function () {
		var t = new eui.Group();
		this.u_btnCancel = t;
		t.height = 60;
		t.scaleX = 0.9;
		t.scaleY = 0.9;
		t.visible = true;
		t.width = 140;
		t.x = 348;
		t.y = 648;
		t.elementsContent = [this._Image4_i(),this.u_txtCancel_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(64,16,1,1);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.width = 140;
		return t;
	};
	_proto.u_txtCancel_i = function () {
		var t = new eui.Label();
		this.u_txtCancel = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "Cancel";
		t.textColor = 0x38445D;
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.height = 60;
		t.scaleX = 0.9;
		t.scaleY = 0.9;
		t.visible = true;
		t.width = 140;
		t.x = 162;
		t.y = 648;
		t.elementsContent = [this._Image5_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(64,16,1,1);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.width = 140;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "OK";
		t.textColor = 0x38445D;
		t.verticalCenter = 0;
		return t;
	};
	return MissionMultiJoinPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionMultiUI/popup/MissionMultiResultPopupSkin.exml'] = window.MissionMultiResultPopupSkin = (function (_super) {
	__extends(MissionMultiResultPopupSkin, _super);
	function MissionMultiResultPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtName","u_txtMana","u_imgIcon1","u_txtCount1","u_txtCost","u_imgIcon2","u_txtCount2","u_grpCost","u_txtOK","u_btnOK","u_btnClose"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtName_i(),this._Group1_i(),this.u_grpCost_i(),this.u_btnOK_i(),this.u_btnClose_i()];
	}
	var _proto = MissionMultiResultPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "missionShishiResultUI_json.missionShishiResultUI_bg";
		t.visible = true;
		t.x = 0;
		t.y = 157;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 4;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_ss_finish";
		t.visible = true;
		t.y = 335;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "Winning the second prize：XXXX";
		t.visible = true;
		t.wordWrap = true;
		t.x = 304;
		t.y = 494;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 20;
		t.horizontalCenter = 0.5;
		t.x = 341;
		t.y = 545;
		t.elementsContent = [this.u_txtMana_i(),this.u_imgIcon1_i(),this.u_txtCount1_i()];
		return t;
	};
	_proto.u_txtMana_i = function () {
		var t = new eui.Label();
		this.u_txtMana = t;
		t.bold = true;
		t.size = 20;
		t.text = "Acquire mana：";
		t.visible = true;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgIcon1_i = function () {
		var t = new eui.Image();
		this.u_imgIcon1 = t;
		t.height = 50;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.visible = true;
		t.width = 50;
		t.x = 140;
		t.y = -15;
		return t;
	};
	_proto.u_txtCount1_i = function () {
		var t = new eui.Label();
		this.u_txtCount1 = t;
		t.bold = true;
		t.size = 20;
		t.text = "XXXX";
		t.textColor = 0xFCFF00;
		t.visible = true;
		t.wordWrap = true;
		t.x = 189;
		t.y = 0;
		return t;
	};
	_proto.u_grpCost_i = function () {
		var t = new eui.Group();
		this.u_grpCost = t;
		t.height = 20;
		t.horizontalCenter = 0;
		t.x = 284;
		t.y = 594;
		t.elementsContent = [this.u_txtCost_i(),this.u_imgIcon2_i(),this.u_txtCount2_i()];
		return t;
	};
	_proto.u_txtCost_i = function () {
		var t = new eui.Label();
		this.u_txtCost = t;
		t.bold = true;
		t.size = 20;
		t.text = "The total cost of the game:";
		t.visible = true;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgIcon2_i = function () {
		var t = new eui.Image();
		this.u_imgIcon2 = t;
		t.height = 50;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.visible = true;
		t.width = 50;
		t.x = 253;
		t.y = -15;
		return t;
	};
	_proto.u_txtCount2_i = function () {
		var t = new eui.Label();
		this.u_txtCount2 = t;
		t.bold = true;
		t.size = 20;
		t.text = "XXXX";
		t.textColor = 0xC9C9D6;
		t.visible = true;
		t.wordWrap = true;
		t.x = 302;
		t.y = 0;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.height = 65;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 135;
		t.y = 676;
		t.elementsContent = [this._Image3_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "OK";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 40;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.visible = true;
		t.width = 40;
		t.x = 567;
		t.y = 337;
		return t;
	};
	return MissionMultiResultPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionMultiUI/render/MissionMultiBossSkin.exml'] = window.MissionMultiBossSkin = (function (_super) {
	__extends(MissionMultiBossSkin, _super);
	function MissionMultiBossSkin() {
		_super.call(this);
		this.skinParts = ["u_imgSelect","u_btnClick"];
		
		this.height = 140;
		this.width = 177;
		this.elementsContent = [this.u_imgSelect_i(),this.u_btnClick_i()];
	}
	var _proto = MissionMultiBossSkin.prototype;

	_proto.u_imgSelect_i = function () {
		var t = new eui.Image();
		this.u_imgSelect = t;
		t.horizontalCenter = 0;
		t.source = "missionMultiUI_json.missionMultiUI_boss_select_1";
		t.visible = true;
		t.y = 70;
		return t;
	};
	_proto.u_btnClick_i = function () {
		var t = new eui.Image();
		this.u_btnClick = t;
		t.alpha = 0;
		t.height = 140;
		t.scale9Grid = new egret.Rectangle(26,27,27,27);
		t.source = "commonsUI_json.commonUI_box_1";
		t.visible = true;
		t.width = 177;
		return t;
	};
	return MissionMultiBossSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionMultiUI/render/MissionMultiListRenderSkin.exml'] = window.MissionMultiListRenderSkin = (function (_super) {
	__extends(MissionMultiListRenderSkin, _super);
	function MissionMultiListRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtCondition","u_txtEnteryCost","u_grpIcon","u_txtPartic","u_txtVip","u_txtJoin","u_iconLock","u_btnJoin"];
		
		this.height = 174;
		this.width = 567;
		this.elementsContent = [this._Image1_i(),this.u_txtCondition_i(),this.u_grpIcon_i(),this.u_txtPartic_i(),this.u_txtVip_i(),this._Image3_i(),this.u_btnJoin_i()];
	}
	var _proto = MissionMultiListRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "missionMultiUI_json.missionMultiUI_render_di";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtCondition_i = function () {
		var t = new eui.Label();
		this.u_txtCondition = t;
		t.bold = true;
		t.size = 19;
		t.stroke = 1.5;
		t.strokeColor = 0x72777F;
		t.text = "Essential condition:";
		t.visible = true;
		t.x = 159;
		t.y = 56;
		return t;
	};
	_proto.u_grpIcon_i = function () {
		var t = new eui.Group();
		this.u_grpIcon = t;
		t.x = 342;
		t.y = 51;
		t.elementsContent = [this._Image2_i(),this.u_txtEnteryCost_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_u_yinbi_a";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtEnteryCost_i = function () {
		var t = new eui.Label();
		this.u_txtEnteryCost = t;
		t.bold = true;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "2000";
		t.textColor = 0x00E22B;
		t.visible = true;
		t.x = 32;
		t.y = 4;
		return t;
	};
	_proto.u_txtPartic_i = function () {
		var t = new eui.Label();
		this.u_txtPartic = t;
		t.bold = true;
		t.size = 19;
		t.stroke = 1.5;
		t.strokeColor = 0x72777F;
		t.text = "Participants: 0/5";
		t.visible = true;
		t.x = 159;
		t.y = 90;
		return t;
	};
	_proto.u_txtVip_i = function () {
		var t = new eui.Label();
		this.u_txtVip = t;
		t.bold = true;
		t.size = 19;
		t.stroke = 1.5;
		t.strokeColor = 0x72777F;
		t.text = "Limit: VIP1";
		t.visible = true;
		t.x = 329;
		t.y = 89;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "missionMultiUI_json.missionMultiUI_boss_select_1";
		t.visible = true;
		t.x = 0;
		t.y = 95;
		return t;
	};
	_proto.u_btnJoin_i = function () {
		var t = new eui.Group();
		this.u_btnJoin = t;
		t.height = 59;
		t.visible = true;
		t.width = 122;
		t.x = 441;
		t.y = 56;
		t.elementsContent = [this._Image4_i(),this.u_txtJoin_i(),this.u_iconLock_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(64,15,2,3);
		t.scaleX = 0.9;
		t.scaleY = 0.9;
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtJoin_i = function () {
		var t = new eui.Label();
		this.u_txtJoin = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "Join";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_iconLock_i = function () {
		var t = new eui.Image();
		this.u_iconLock = t;
		t.source = "commonsUI_json.commonsUI_btn_suo";
		t.x = 90;
		t.y = -14;
		return t;
	};
	return MissionMultiListRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionMultiUI/render/MissionMultiSelectRenderSkin.exml'] = window.MissionMultiSelectRenderSkin = (function (_super) {
	__extends(MissionMultiSelectRenderSkin, _super);
	function MissionMultiSelectRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtSingle","u_imgIcon","u_txtSingleCost","u_grpIcon"];
		
		this.height = 56;
		this.width = 400;
		this.elementsContent = [this._Image1_i(),this.u_txtSingle_i(),this.u_grpIcon_i()];
	}
	var _proto = MissionMultiSelectRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "missionMultiUI_json.missionMultiUI_select_di2";
		t.y = 0;
		return t;
	};
	_proto.u_txtSingle_i = function () {
		var t = new eui.Label();
		this.u_txtSingle = t;
		t.bold = true;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "A single consumption:";
		t.textColor = 0xFFFFFF;
		t.visible = true;
		t.x = 23;
		t.y = 18;
		return t;
	};
	_proto.u_grpIcon_i = function () {
		var t = new eui.Group();
		this.u_grpIcon = t;
		t.x = 242;
		t.y = 12;
		t.elementsContent = [this.u_imgIcon_i(),this.u_txtSingleCost_i()];
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.source = "userMainUI_json.userMainUI_u_yinbi_a";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtSingleCost_i = function () {
		var t = new eui.Label();
		this.u_txtSingleCost = t;
		t.bold = true;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "2000";
		t.textColor = 0x00E22B;
		t.visible = true;
		t.x = 37;
		t.y = 4;
		return t;
	};
	return MissionMultiSelectRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionMultiUI/view/MissionMultiHeadSkin.exml'] = window.MissionMultiHeadSkin = (function (_super) {
	__extends(MissionMultiHeadSkin, _super);
	function MissionMultiHeadSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_imgHead","u_txtLv","u_txtName","u_imgReady","u_btnKick","u_grpHave"];
		
		this.height = 159;
		this.width = 167;
		this.elementsContent = [this._Group1_i()];
	}
	var _proto = MissionMultiHeadSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.scaleX = 1.2;
		t.scaleY = 1.2;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this.u_imgBg_i(),this.u_grpHave_i()];
		return t;
	};
	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.source = "missionMultiUI_json.missionMultiUI_head1";
		t.visible = true;
		t.x = 0;
		t.y = 12;
		return t;
	};
	_proto.u_grpHave_i = function () {
		var t = new eui.Group();
		this.u_grpHave = t;
		t.visible = true;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this.u_imgHead_i(),this._Image1_i(),this.u_txtLv_i(),this.u_txtName_i(),this.u_imgReady_i(),this.u_btnKick_i()];
		return t;
	};
	_proto.u_imgHead_i = function () {
		var t = new eui.Image();
		this.u_imgHead = t;
		t.height = 128;
		t.visible = true;
		t.width = 128;
		t.x = 6;
		t.y = -10;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(46,14,45,14);
		t.source = "missionMultiUI_json.missionMultiUI_select_di3";
		t.visible = true;
		t.x = 0;
		t.y = 90;
		return t;
	};
	_proto.u_txtLv_i = function () {
		var t = new eui.Label();
		this.u_txtLv = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.stroke = 1.5;
		t.text = "Lv.22";
		t.textColor = 0xFFFC25;
		t.visible = true;
		t.y = 93;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.stroke = 1.5;
		t.text = "Name";
		t.visible = true;
		t.y = 112;
		return t;
	};
	_proto.u_imgReady_i = function () {
		var t = new eui.Image();
		this.u_imgReady = t;
		t.source = "missionMultiUI_json.missionMultiUI_ready";
		t.visible = true;
		t.x = 35;
		t.y = 47;
		return t;
	};
	_proto.u_btnKick_i = function () {
		var t = new eui.Image();
		this.u_btnKick = t;
		t.height = 40;
		t.source = "missionMultiUI_json.missionMultiUI_kick";
		t.visible = true;
		t.width = 40;
		t.x = 99;
		t.y = 0;
		return t;
	};
	return MissionMultiHeadSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionMultiUI/view/MissionMultiSelectSkin.exml'] = window.MissionMultiSelectSkin = (function (_super) {
	__extends(MissionMultiSelectSkin, _super);
	function MissionMultiSelectSkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_scrollerItem","u_btnClose"];
		
		this.height = 540;
		this.width = 420;
		this.elementsContent = [this._Image1_i(),this.u_scrollerItem_i(),this.u_btnClose_i()];
	}
	var _proto = MissionMultiSelectSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 540;
		t.source = "missionMultiUI_json.missionMultiUI_select_di1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 440;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 400;
		t.x = 10;
		t.y = 63;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 40;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.visible = true;
		t.width = 40;
		t.x = 380;
		t.y = 11;
		return t;
	};
	return MissionMultiSelectSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionShishiUI/MissionShishiUISkin.exml'] = window.MissionShishiUISkin = (function (_super) {
	__extends(MissionShishiUISkin, _super);
	function MissionShishiUISkin() {
		_super.call(this);
		this.skinParts = ["u_txtDesc","u_scrollerItem","u_btnGame"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_scrollerItem_i(),this.u_btnGame_i()];
	}
	var _proto = MissionShishiUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "missionShishiUI_json.missionShishiUI_bj";
		t.y = 103;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 195;
		t.horizontalCenter = -1.5;
		t.scale9Grid = new egret.Rectangle(189,64,189,1);
		t.source = "guessBossUI_json.guessBossUI_bg3";
		t.visible = true;
		t.y = 793;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 140;
		t.horizontalCenter = 0;
		t.width = 470;
		t.y = 820;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 59;
		t.y = 161;
		t.elementsContent = [this.u_txtDesc_i()];
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.horizontalCenter = 0;
		t.lineSpacing = 10;
		t.size = 22;
		t.strokeColor = 0x453A32;
		t.text = "rule";
		t.textAlign = "left";
		t.textColor = 0x424C60;
		t.width = 470;
		t.wordWrap = true;
		t.y = 0;
		return t;
	};
	_proto.u_btnGame_i = function () {
		var t = new eui.Group();
		this.u_btnGame = t;
		t.height = 128;
		t.horizontalCenter = 0;
		t.width = 142;
		t.y = 618;
		t.elementsContent = [this._Image3_i(),this._Image4_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_btn_6";
		t.x = 8;
		t.y = 0;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_challenge";
		t.x = 0;
		t.y = 47;
		return t;
	};
	return MissionShishiUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionShishiUI/popup/MissionShishiFirstSkin.exml'] = window.MissionShishiFirstSkin = (function (_super) {
	__extends(MissionShishiFirstSkin, _super);
	function MissionShishiFirstSkin() {
		_super.call(this);
		this.skinParts = ["u_txtName","u_txtMana","u_imgGold","u_txtCount","u_listItem","u_scrollerItem","u_txtCost","u_imgGold2","u_txtCount2","u_grpCost","u_txtOK","u_btnOK","u_btnClose"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this._Group3_i(),this.u_btnOK_i(),this.u_btnClose_i()];
	}
	var _proto = MissionShishiFirstSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "missionShishiResultUI_json.missionShishiResultUI_bg";
		t.visible = true;
		t.x = 0;
		t.y = 157;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 4;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_ss_finish";
		t.visible = true;
		t.y = 335;
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.verticalCenter = 8;
		t.elementsContent = [this.u_txtName_i(),this._Group1_i(),this.u_scrollerItem_i(),this.u_grpCost_i()];
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "Winning the second prize：XXXX";
		t.visible = true;
		t.wordWrap = true;
		t.y = 0;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 20;
		t.horizontalCenter = 0;
		t.y = 30;
		t.elementsContent = [this.u_txtMana_i(),this.u_imgGold_i(),this.u_txtCount_i()];
		return t;
	};
	_proto.u_txtMana_i = function () {
		var t = new eui.Label();
		this.u_txtMana = t;
		t.bold = true;
		t.size = 20;
		t.text = "Acquire mana：";
		t.visible = true;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgGold_i = function () {
		var t = new eui.Image();
		this.u_imgGold = t;
		t.height = 50;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.visible = true;
		t.width = 50;
		t.x = 140;
		t.y = -15;
		return t;
	};
	_proto.u_txtCount_i = function () {
		var t = new eui.Label();
		this.u_txtCount = t;
		t.bold = true;
		t.size = 20;
		t.text = "XXXX";
		t.textColor = 0xFCFF00;
		t.visible = true;
		t.wordWrap = true;
		t.x = 189;
		t.y = 0;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 60;
		t.visible = true;
		t.width = 410;
		t.x = 0;
		t.y = 70;
		t.viewport = this._Group2_i();
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.bottom = 0;
		t.horizontalCenter = 0;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_grpCost_i = function () {
		var t = new eui.Group();
		this.u_grpCost = t;
		t.height = 20;
		t.horizontalCenter = 0;
		t.y = 145;
		t.elementsContent = [this.u_txtCost_i(),this.u_imgGold2_i(),this.u_txtCount2_i()];
		return t;
	};
	_proto.u_txtCost_i = function () {
		var t = new eui.Label();
		this.u_txtCost = t;
		t.bold = true;
		t.size = 20;
		t.text = "The total cost of the game:";
		t.visible = true;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgGold2_i = function () {
		var t = new eui.Image();
		this.u_imgGold2 = t;
		t.height = 50;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.visible = true;
		t.width = 50;
		t.x = 253;
		t.y = -15;
		return t;
	};
	_proto.u_txtCount2_i = function () {
		var t = new eui.Label();
		this.u_txtCount2 = t;
		t.bold = true;
		t.size = 20;
		t.text = "XXXX";
		t.textColor = 0xC9C9D6;
		t.visible = true;
		t.wordWrap = true;
		t.x = 302;
		t.y = 0;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.height = 65;
		t.horizontalCenter = 6.5;
		t.visible = true;
		t.width = 135;
		t.y = 688;
		t.elementsContent = [this._Image3_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "OK";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 40;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.visible = true;
		t.width = 40;
		t.x = 567;
		t.y = 337;
		return t;
	};
	return MissionShishiFirstSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionShishiUI/popup/MissionShishiSecondSkin.exml'] = window.MissionShishiSecondSkin = (function (_super) {
	__extends(MissionShishiSecondSkin, _super);
	function MissionShishiSecondSkin() {
		_super.call(this);
		this.skinParts = ["u_txtName","u_txtMana","u_imgGold","u_txtCount","u_txtOK","u_btnOK","u_btnClose"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtName_i(),this._Group1_i(),this.u_btnOK_i(),this.u_btnClose_i()];
	}
	var _proto = MissionShishiSecondSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "missionShishiResultUI_json.missionShishiResultUI_bg";
		t.visible = true;
		t.y = 203;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 4;
		t.source = "missionShishiResultUI_json.missionShishiResultUI_title";
		t.visible = true;
		t.y = 374;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "Winning the second prize：XXXXXXX";
		t.visible = true;
		t.wordWrap = true;
		t.y = 550;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 20;
		t.horizontalCenter = 0;
		t.y = 595;
		t.elementsContent = [this.u_txtMana_i(),this.u_imgGold_i(),this.u_txtCount_i()];
		return t;
	};
	_proto.u_txtMana_i = function () {
		var t = new eui.Label();
		this.u_txtMana = t;
		t.bold = true;
		t.size = 20;
		t.text = "Acquire mana：";
		t.visible = true;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgGold_i = function () {
		var t = new eui.Image();
		this.u_imgGold = t;
		t.height = 50;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.visible = true;
		t.width = 50;
		t.x = 140;
		t.y = -15;
		return t;
	};
	_proto.u_txtCount_i = function () {
		var t = new eui.Label();
		this.u_txtCount = t;
		t.bold = true;
		t.size = 20;
		t.text = "XXXX";
		t.textColor = 0xFCFF00;
		t.visible = true;
		t.wordWrap = true;
		t.x = 189;
		t.y = 0;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.height = 65;
		t.horizontalCenter = 0.5;
		t.visible = true;
		t.width = 135;
		t.y = 674;
		t.elementsContent = [this._Image3_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "OK";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 40;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.visible = true;
		t.width = 40;
		t.x = 566;
		t.y = 385;
		return t;
	};
	return MissionShishiSecondSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionShishiUI/render/MissionShishiWinerSkin.exml'] = window.MissionShishiWinerSkin = (function (_super) {
	__extends(MissionShishiWinerSkin, _super);
	function MissionShishiWinerSkin() {
		_super.call(this);
		this.skinParts = ["u_txtName","u_txtMana","u_imgGold","u_txtCount"];
		
		this.height = 50;
		this.width = 410;
		this.elementsContent = [this.u_txtName_i(),this._Group1_i()];
	}
	var _proto = MissionShishiWinerSkin.prototype;

	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "Winning the second prize：XXXX";
		t.visible = true;
		t.wordWrap = true;
		t.y = 0;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 20;
		t.horizontalCenter = 0;
		t.y = 30;
		t.elementsContent = [this.u_txtMana_i(),this.u_imgGold_i(),this.u_txtCount_i()];
		return t;
	};
	_proto.u_txtMana_i = function () {
		var t = new eui.Label();
		this.u_txtMana = t;
		t.bold = true;
		t.size = 20;
		t.text = "Acquire mana：";
		t.visible = true;
		t.wordWrap = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgGold_i = function () {
		var t = new eui.Image();
		this.u_imgGold = t;
		t.height = 50;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.visible = true;
		t.width = 50;
		t.x = 140;
		t.y = -15;
		return t;
	};
	_proto.u_txtCount_i = function () {
		var t = new eui.Label();
		this.u_txtCount = t;
		t.bold = true;
		t.size = 20;
		t.text = "XXXX";
		t.textColor = 0xFCFF00;
		t.visible = true;
		t.wordWrap = true;
		t.x = 189;
		t.y = 0;
		return t;
	};
	return MissionShishiWinerSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/missionShishiUI/view/MissionShishiProSkin.exml'] = window.MissionShishiProSkin = (function (_super) {
	__extends(MissionShishiProSkin, _super);
	function MissionShishiProSkin() {
		_super.call(this);
		this.skinParts = ["u_grpPro"];
		
		this.height = 102;
		this.width = 370;
		this.elementsContent = [this._Image1_i(),this.u_grpPro_i()];
	}
	var _proto = MissionShishiProSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 1;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_ss_pool";
		t.visible = true;
		t.y = 0;
		return t;
	};
	_proto.u_grpPro_i = function () {
		var t = new eui.Group();
		this.u_grpPro = t;
		t.height = 53;
		t.x = 0;
		t.y = 49;
		t.elementsContent = [this._Image2_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "missionJieSuanUI_json.missionJieSuanUI_ss_dikuang";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return MissionShishiProSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/monsterInfoUI/MonsterInfoUISkin.exml'] = window.MonsterInfoUISkin = (function (_super) {
	__extends(MonsterInfoUISkin, _super);
	function MonsterInfoUISkin() {
		_super.call(this);
		this.skinParts = [];
		
		this.height = 640;
		this.width = 1136;
	}
	var _proto = MonsterInfoUISkin.prototype;

	return MonsterInfoUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/monsterInfoUI/page/MonsterInfoPageSkin.exml'] = window.MonsterInfoPageSkin = (function (_super) {
	__extends(MonsterInfoPageSkin, _super);
	function MonsterInfoPageSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_imgBg_i(),this._Image1_i(),this._Image2_i()];
	}
	var _proto = MonsterInfoPageSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 528;
		t.scale9Grid = new egret.Rectangle(25,25,25,25);
		t.source = "monsterInfoUI_json.monsterInfoUI_img_bg";
		t.visible = true;
		t.width = 917;
		t.x = 149;
		t.y = 59;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 68;
		t.source = "monsterInfoUI_json.monsterInfoUI_btn_icon2";
		t.visible = false;
		t.width = 136.5;
		t.x = 20;
		t.y = 170;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 68;
		t.source = "monsterInfoUI_json.monsterInfoUI_btn_icon1";
		t.visible = false;
		t.width = 136.5;
		t.x = 20;
		t.y = 249;
		return t;
	};
	return MonsterInfoPageSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/monsterInfoUI/render/MonsterInfoBossRenderSkin.exml'] = window.MonsterInfoBossRenderSkin = (function (_super) {
	__extends(MonsterInfoBossRenderSkin, _super);
	function MonsterInfoBossRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_imgBossName","u_txtBossDesc"];
		
		this.height = 155;
		this.width = 875;
		this.elementsContent = [this.u_imgBg_i(),this.u_imgBossName_i(),this.u_txtBossDesc_i()];
	}
	var _proto = MonsterInfoBossRenderSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 155;
		t.width = 875;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgBossName_i = function () {
		var t = new eui.Image();
		this.u_imgBossName = t;
		t.x = 12;
		t.y = 103;
		return t;
	};
	_proto.u_txtBossDesc_i = function () {
		var t = new eui.Label();
		this.u_txtBossDesc = t;
		t.fontFamily = "SimSun";
		t.height = 71;
		t.lineSpacing = 5;
		t.size = 16;
		t.text = "desc";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.width = 545.5;
		t.x = 303;
		t.y = 50;
		return t;
	};
	return MonsterInfoBossRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/monsterInfoUI/render/MonsterInfoEventRenderSkin.exml'] = window.MonsterInfoEventRenderSkin = (function (_super) {
	__extends(MonsterInfoEventRenderSkin, _super);
	function MonsterInfoEventRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_imgEventName","u_txtEventDesc"];
		
		this.height = 130;
		this.width = 875;
		this.elementsContent = [this.u_imgBg_i(),this.u_imgEventName_i(),this.u_txtEventDesc_i()];
	}
	var _proto = MonsterInfoEventRenderSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 130;
		t.width = 875;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgEventName_i = function () {
		var t = new eui.Image();
		this.u_imgEventName = t;
		t.x = 193;
		t.y = 43;
		return t;
	};
	_proto.u_txtEventDesc_i = function () {
		var t = new eui.Label();
		this.u_txtEventDesc = t;
		t.fontFamily = "SimSun";
		t.height = 79;
		t.lineSpacing = 5;
		t.size = 16;
		t.text = "desc";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.width = 465;
		t.x = 386;
		t.y = 26;
		return t;
	};
	return MonsterInfoEventRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/monsterInfoUI/render/MonsterInfoSmallRenderSkin.exml'] = window.MonsterInfoSmallRenderSkin = (function (_super) {
	__extends(MonsterInfoSmallRenderSkin, _super);
	function MonsterInfoSmallRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgName","u_imgMoster","u_txtName","u_grpBei"];
		
		this.height = 136;
		this.width = 212;
		this.elementsContent = [this._Image1_i(),this.u_imgName_i(),this.u_imgMoster_i(),this.u_txtName_i(),this.u_grpBei_i()];
	}
	var _proto = MonsterInfoSmallRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 136;
		t.scale9Grid = new egret.Rectangle(17,17,16,16);
		t.source = "monsterInfoUI_json.monsterInfoUI_img_dt4";
		t.width = 212;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgName_i = function () {
		var t = new eui.Image();
		this.u_imgName = t;
		t.source = "monsterInfoUI_json.monsterInfoUI_img_name1";
		t.x = 2.1;
		t.y = 18;
		return t;
	};
	_proto.u_imgMoster_i = function () {
		var t = new eui.Image();
		this.u_imgMoster = t;
		t.height = 239.5;
		t.scale9Grid = new egret.Rectangle(50,0,77,84);
		t.visible = true;
		t.width = 251;
		t.x = 35;
		t.y = -25.5;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.fontFamily = "Microsoft YaHei";
		t.height = 22;
		t.size = 16;
		t.text = "name";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.x = 13;
		t.y = 21;
		return t;
	};
	_proto.u_grpBei_i = function () {
		var t = new eui.Group();
		this.u_grpBei = t;
		t.height = 30;
		t.width = 85;
		t.x = 11;
		t.y = 93;
		return t;
	};
	return MonsterInfoSmallRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/monsterInfoUI/render/MonsterInfoSpecRenderSkin.exml'] = window.MonsterInfoSpecRenderSkin = (function (_super) {
	__extends(MonsterInfoSpecRenderSkin, _super);
	function MonsterInfoSpecRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgMonster","u_grpMultiple","u_imgMosName","u_txtMosDesc"];
		
		this.height = 455;
		this.width = 250;
		this.elementsContent = [this._Image1_i(),this.u_imgMonster_i(),this.u_grpMultiple_i(),this.u_imgMosName_i(),this.u_txtMosDesc_i()];
	}
	var _proto = MonsterInfoSpecRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 455;
		t.scale9Grid = new egret.Rectangle(17,17,16,16);
		t.source = "monsterInfoUI_json.monsterInfoUI_img_dt4";
		t.width = 250;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgMonster_i = function () {
		var t = new eui.Image();
		this.u_imgMonster = t;
		t.height = 240;
		t.visible = true;
		t.width = 230;
		t.x = 10;
		t.y = 11;
		return t;
	};
	_proto.u_grpMultiple_i = function () {
		var t = new eui.Group();
		this.u_grpMultiple = t;
		t.height = 36.5;
		t.width = 208;
		t.x = 20;
		t.y = 18;
		t.elementsContent = [this._Image2_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "monsterInfoUI_json.monsterInfoUI_img_bt";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgMosName_i = function () {
		var t = new eui.Image();
		this.u_imgMosName = t;
		t.x = 76;
		t.y = 262;
		return t;
	};
	_proto.u_txtMosDesc_i = function () {
		var t = new eui.Label();
		this.u_txtMosDesc = t;
		t.fontFamily = "Microsoft YaHei";
		t.height = 135.5;
		t.lineSpacing = 5;
		t.size = 14;
		t.text = "desc";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "top";
		t.width = 230;
		t.x = 10;
		t.y = 305;
		return t;
	};
	return MonsterInfoSpecRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/monsterInfoUI/view/MonsterInfoBossSkin.exml'] = window.MonsterInfoBossSkin = (function (_super) {
	__extends(MonsterInfoBossSkin, _super);
	function MonsterInfoBossSkin() {
		_super.call(this);
		this.skinParts = ["u_bossList","u_scrollItem","u_imgTop","u_imgBottom","u_bossScrollBar"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_scrollItem_i(),this.u_imgTop_i(),this.u_imgBottom_i(),this.u_bossScrollBar_i(),this._Image1_i(),this._Image2_i()];
	}
	var _proto = MonsterInfoBossSkin.prototype;

	_proto.u_scrollItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollItem = t;
		t.height = 508;
		t.visible = true;
		t.width = 877;
		t.x = 170;
		t.y = 69;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_bossList_i()];
		return t;
	};
	_proto.u_bossList_i = function () {
		var t = new eui.List();
		this.u_bossList = t;
		return t;
	};
	_proto.u_imgTop_i = function () {
		var t = new eui.Image();
		this.u_imgTop = t;
		t.source = "commonUI_json.commonUI_icon_jts";
		t.visible = true;
		t.x = 1088;
		t.y = 67.5;
		return t;
	};
	_proto.u_imgBottom_i = function () {
		var t = new eui.Image();
		this.u_imgBottom = t;
		t.source = "commonUI_json.commonUI_icon_jtx";
		t.visible = true;
		t.x = 1088;
		t.y = 558.5;
		return t;
	};
	_proto.u_bossScrollBar_i = function () {
		var t = new eui.VScrollBar();
		this.u_bossScrollBar = t;
		t.height = 476;
		t.skinName = "VScrollBarSkin";
		t.width = 20;
		t.x = 1091;
		t.y = 82;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 100;
		t.source = "monsterInfoUI_json.monsterInfoUI_img_zz";
		t.visible = true;
		t.width = 1264;
		t.x = -64;
		t.y = 538.5;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 100;
		t.rotation = 180;
		t.source = "monsterInfoUI_json.monsterInfoUI_img_zz";
		t.visible = true;
		t.width = 1264;
		t.x = 1200;
		t.y = 100;
		return t;
	};
	return MonsterInfoBossSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/monsterInfoUI/view/MonsterInfoEventSkin.exml'] = window.MonsterInfoEventSkin = (function (_super) {
	__extends(MonsterInfoEventSkin, _super);
	function MonsterInfoEventSkin() {
		_super.call(this);
		this.skinParts = ["u_EventList","u_scrollItem","u_imgTop","u_imgBottom","u_eventScrollBar"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_scrollItem_i(),this.u_imgTop_i(),this.u_imgBottom_i(),this.u_eventScrollBar_i(),this._Image1_i(),this._Image2_i()];
	}
	var _proto = MonsterInfoEventSkin.prototype;

	_proto.u_scrollItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollItem = t;
		t.height = 489;
		t.width = 877;
		t.x = 170;
		t.y = 92;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_EventList_i()];
		return t;
	};
	_proto.u_EventList_i = function () {
		var t = new eui.List();
		this.u_EventList = t;
		return t;
	};
	_proto.u_imgTop_i = function () {
		var t = new eui.Image();
		this.u_imgTop = t;
		t.source = "commonUI_json.commonUI_icon_jts";
		t.visible = true;
		t.x = 1088;
		t.y = 66.5;
		return t;
	};
	_proto.u_imgBottom_i = function () {
		var t = new eui.Image();
		this.u_imgBottom = t;
		t.source = "commonUI_json.commonUI_icon_jtx";
		t.visible = true;
		t.x = 1088;
		t.y = 558;
		return t;
	};
	_proto.u_eventScrollBar_i = function () {
		var t = new eui.VScrollBar();
		this.u_eventScrollBar = t;
		t.height = 476;
		t.skinName = "VScrollBarSkin";
		t.width = 20;
		t.x = 1091;
		t.y = 81.5;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 100;
		t.rotation = 180;
		t.source = "monsterInfoUI_json.monsterInfoUI_img_zz";
		t.visible = true;
		t.width = 1264;
		t.x = 1200;
		t.y = 100;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 100;
		t.source = "monsterInfoUI_json.monsterInfoUI_img_zz";
		t.visible = true;
		t.width = 1264;
		t.x = -64;
		t.y = 538.5;
		return t;
	};
	return MonsterInfoEventSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/monsterInfoUI/view/MonsterInfoSmallSkin.exml'] = window.MonsterInfoSmallSkin = (function (_super) {
	__extends(MonsterInfoSmallSkin, _super);
	function MonsterInfoSmallSkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_scrollerItem","u_imgTop","u_imgBottom","u_smallScrollBar"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_scrollerItem_i(),this.u_imgTop_i(),this.u_imgBottom_i(),this.u_smallScrollBar_i(),this._Image1_i(),this._Image2_i()];
	}
	var _proto = MonsterInfoSmallSkin.prototype;

	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 507;
		t.visible = true;
		t.width = 878;
		t.x = 166.5;
		t.y = 69;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.y = 0;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		return t;
	};
	_proto.u_imgTop_i = function () {
		var t = new eui.Image();
		this.u_imgTop = t;
		t.source = "commonUI_json.commonUI_icon_jts";
		t.visible = true;
		t.x = 1088;
		t.y = 66;
		return t;
	};
	_proto.u_imgBottom_i = function () {
		var t = new eui.Image();
		this.u_imgBottom = t;
		t.source = "commonUI_json.commonUI_icon_jtx";
		t.visible = true;
		t.x = 1089;
		t.y = 558;
		return t;
	};
	_proto.u_smallScrollBar_i = function () {
		var t = new eui.VScrollBar();
		this.u_smallScrollBar = t;
		t.height = 478;
		t.skinName = "VScrollBarSkin";
		t.width = 20;
		t.x = 1091;
		t.y = 80.5;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 100;
		t.rotation = 180;
		t.source = "monsterInfoUI_json.monsterInfoUI_img_zz";
		t.visible = true;
		t.width = 1264;
		t.x = 1200;
		t.y = 100;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 100;
		t.source = "monsterInfoUI_json.monsterInfoUI_img_zz";
		t.visible = true;
		t.width = 1264;
		t.x = -64;
		t.y = 538.5;
		return t;
	};
	return MonsterInfoSmallSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/monsterInfoUI/view/MonsterInfoSpecSkin.exml'] = window.MonsterInfoSpecSkin = (function (_super) {
	__extends(MonsterInfoSpecSkin, _super);
	function MonsterInfoSpecSkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_scrollerItem","u_imgLeft","u_imgRight","u_specScrollBar"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_scrollerItem_i(),this._Image1_i(),this._Image2_i(),this.u_imgLeft_i(),this.u_imgRight_i(),this.u_specScrollBar_i()];
	}
	var _proto = MonsterInfoSpecSkin.prototype;

	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 456;
		t.visible = true;
		t.width = 895.5;
		t.x = 165;
		t.y = 93;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.y = 0;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 100;
		t.rotation = 180;
		t.source = "monsterInfoUI_json.monsterInfoUI_img_zz";
		t.visible = true;
		t.width = 1264;
		t.x = 1200;
		t.y = 100;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 100;
		t.source = "monsterInfoUI_json.monsterInfoUI_img_zz";
		t.visible = true;
		t.width = 1264;
		t.x = -64;
		t.y = 538.5;
		return t;
	};
	_proto.u_imgLeft_i = function () {
		var t = new eui.Image();
		this.u_imgLeft = t;
		t.rotation = 271.173;
		t.source = "commonUI_json.commonUI_icon_jts";
		t.visible = true;
		t.x = 153;
		t.y = 622;
		return t;
	};
	_proto.u_imgRight_i = function () {
		var t = new eui.Image();
		this.u_imgRight = t;
		t.rotation = 268.746;
		t.source = "commonUI_json.commonUI_icon_jtx";
		t.visible = true;
		t.x = 1047;
		t.y = 622;
		return t;
	};
	_proto.u_specScrollBar_i = function () {
		var t = new eui.HScrollBar();
		this.u_specScrollBar = t;
		t.height = 20;
		t.rotation = 359.9;
		t.skinName = "HScrollBarSkin";
		t.visible = true;
		t.width = 873.5;
		t.x = 172;
		t.y = 602;
		return t;
	};
	return MonsterInfoSpecSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/monsterRollUI/MonsterRollUISkin.exml'] = window.skins.MonsterRollUISkin = (function (_super) {
	__extends(MonsterRollUISkin, _super);
	function MonsterRollUISkin() {
		_super.call(this);
		this.skinParts = ["u_startBtn","u_slotGrp"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_startBtn_i(),this._Image1_i(),this.u_slotGrp_i(),this._Image2_i()];
	}
	var _proto = MonsterRollUISkin.prototype;

	_proto.u_startBtn_i = function () {
		var t = new eui.Image();
		this.u_startBtn = t;
		t.source = "monsterRollUI_json.monsterRollUI_start";
		t.x = 754.256;
		t.y = 223.717;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "monsterRollUI_json.monsterRollUI_slot_bg";
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_slotGrp_i = function () {
		var t = new eui.Group();
		this.u_slotGrp = t;
		t.height = 120.259;
		t.horizontalCenter = 0;
		t.verticalCenter = 12;
		t.visible = true;
		t.width = 315.932;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = -5.5;
		t.source = "monsterRollUI_json.monsterRollUI_win";
		t.y = 171.586;
		return t;
	};
	return MonsterRollUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/monsterRollUI/render/MonsterRollRenderSkin.exml'] = window.skins.MonsterRollRenderSkin = (function (_super) {
	__extends(MonsterRollRenderSkin, _super);
	function MonsterRollRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_icon"];
		
		this.height = 60;
		this.width = 65;
		this.elementsContent = [this.u_icon_i()];
	}
	var _proto = MonsterRollRenderSkin.prototype;

	_proto.u_icon_i = function () {
		var t = new eui.Image();
		this.u_icon = t;
		t.horizontalCenter = 0;
		t.source = "monsterRollUI_json.monsterRollUI_fruit_6";
		t.verticalCenter = 0;
		return t;
	};
	return MonsterRollRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/multiCreateUI/MultiCreateUISkin.exml'] = window.MultiCreateUISkin = (function (_super) {
	__extends(MultiCreateUISkin, _super);
	function MultiCreateUISkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_scrollerItem","u_txtLimit","u_txtPart","u_txtMana","u_txtDesc","u_txtVip","u_txtPer","u_txtSetPass","u_iconGou","u_btnGou","u_txtInput","u_txtOK","u_btnOK"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this.u_scrollerItem_i(),this.u_txtLimit_i(),this.u_txtPart_i(),this.u_txtMana_i(),this._Image2_i(),this.u_txtDesc_i(),this.u_txtVip_i(),this.u_txtPer_i(),this._Image3_i(),this.u_txtSetPass_i(),this.u_btnGou_i(),this._Group2_i(),this.u_btnOK_i()];
	}
	var _proto = MultiCreateUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 406;
		t.scale9Grid = new egret.Rectangle(29,29,30,30);
		t.source = "commonsUI_json.commonUI_box_2";
		t.visible = true;
		t.width = 584;
		t.x = 29;
		t.y = 98;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 260;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 550;
		t.y = 112;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtLimit_i = function () {
		var t = new eui.Label();
		this.u_txtLimit = t;
		t.bold = true;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "Limit: VIP1";
		t.visible = true;
		t.x = 68;
		t.y = 400;
		return t;
	};
	_proto.u_txtPart_i = function () {
		var t = new eui.Label();
		this.u_txtPart = t;
		t.bold = true;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "Participants: 5";
		t.visible = true;
		t.x = 271;
		t.y = 398;
		return t;
	};
	_proto.u_txtMana_i = function () {
		var t = new eui.Label();
		this.u_txtMana = t;
		t.bold = true;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "Mana cost per participant:  2000";
		t.visible = true;
		t.x = 68;
		t.y = 437;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "commonsUI_json.commonsUI_line2";
		t.y = 528;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.bold = true;
		t.horizontalCenter = 7;
		t.size = 22;
		t.text = "Description";
		t.textColor = 0x38445D;
		t.visible = true;
		t.y = 518;
		return t;
	};
	_proto.u_txtVip_i = function () {
		var t = new eui.Label();
		this.u_txtVip = t;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "Current VIP2";
		t.textColor = 0xFFD800;
		t.visible = true;
		t.x = 60;
		t.y = 560;
		return t;
	};
	_proto.u_txtPer_i = function () {
		var t = new eui.Label();
		this.u_txtPer = t;
		t.bold = true;
		t.lineSpacing = 8;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "The percentage of mana reward for each bureau: 2%";
		t.visible = true;
		t.width = 479;
		t.wordWrap = true;
		t.x = 60;
		t.y = 600;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(114,1,114,0);
		t.source = "commonsUI_json.commonsUI_line";
		t.visible = true;
		t.width = 524;
		t.y = 686;
		return t;
	};
	_proto.u_txtSetPass_i = function () {
		var t = new eui.Label();
		this.u_txtSetPass = t;
		t.bold = true;
		t.size = 24;
		t.text = "Set password";
		t.textColor = 0x4C5B7B;
		t.visible = true;
		t.x = 62;
		t.y = 713;
		return t;
	};
	_proto.u_btnGou_i = function () {
		var t = new eui.Group();
		this.u_btnGou = t;
		t.height = 33;
		t.visible = true;
		t.width = 33;
		t.x = 229;
		t.y = 708;
		t.elementsContent = [this._Image4_i(),this.u_iconGou_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_gou _di";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_iconGou_i = function () {
		var t = new eui.Image();
		this.u_iconGou = t;
		t.horizontalCenter = 1.5;
		t.source = "commonsUI_json.commonsUI_gou";
		t.verticalCenter = -1.5;
		t.visible = true;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.x = 54;
		t.y = 751;
		t.elementsContent = [this._Image5_i(),this.u_txtInput_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "multiCreateUI_json.multiCreateUI_txt_di";
		t.visible = true;
		return t;
	};
	_proto.u_txtInput_i = function () {
		var t = new eui.EditableText();
		this.u_txtInput = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.height = 47;
		t.horizontalCenter = "0";
		t.maxChars = 6;
		t.multiline = false;
		t.promptColor = 0x5E7089;
		t.size = 24;
		t.textColor = 0x614C4B;
		t.verticalAlign = "middle";
		t.verticalCenter = "0";
		t.visible = true;
		t.width = 345;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.horizontalCenter = 2;
		t.visible = true;
		t.y = 843;
		t.elementsContent = [this._Image6_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_3";
		t.visible = true;
		t.width = 200;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "OK";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	return MultiCreateUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/multiCreateUI/render/MultiCreateBossHeadSkin.exml'] = window.MultiCreateBossHeadSkin = (function (_super) {
	__extends(MultiCreateBossHeadSkin, _super);
	function MultiCreateBossHeadSkin() {
		_super.call(this);
		this.skinParts = ["u_imgHeadBG","u_imgLock","u_imgIcon","u_imgSelect","u_txtLv","u_grpLv"];
		
		this.height = 105;
		this.width = 110;
		this.elementsContent = [this.u_imgHeadBG_i(),this.u_imgLock_i(),this.u_imgIcon_i(),this.u_imgSelect_i(),this.u_grpLv_i()];
	}
	var _proto = MultiCreateBossHeadSkin.prototype;

	_proto.u_imgHeadBG_i = function () {
		var t = new eui.Image();
		this.u_imgHeadBG = t;
		t.source = "multiCreateUI_json.multiCreateUI_bossHead";
		t.visible = true;
		t.x = 0;
		t.y = 1;
		return t;
	};
	_proto.u_imgLock_i = function () {
		var t = new eui.Image();
		this.u_imgLock = t;
		t.source = "multiCreateUI_json.multiCreateUI_lock";
		t.visible = true;
		t.x = 8;
		t.y = -8;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 155;
		t.horizontalCenter = 0;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "multiCreateUI_json.multiCreateUI_icon";
		t.visible = true;
		t.width = 139;
		t.y = -19;
		return t;
	};
	_proto.u_imgSelect_i = function () {
		var t = new eui.Image();
		this.u_imgSelect = t;
		t.source = "multiCreateUI_json.multiCreateUI_select";
		t.visible = false;
		t.x = 9;
		t.y = -5;
		return t;
	};
	_proto.u_grpLv_i = function () {
		var t = new eui.Group();
		this.u_grpLv = t;
		t.height = 27;
		t.width = 81;
		t.x = 15;
		t.y = 78;
		t.elementsContent = [this._Image1_i(),this.u_txtLv_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "multiCreateUI_json.multiCreateUI_di1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtLv_i = function () {
		var t = new eui.Label();
		this.u_txtLv = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "Lv:80";
		t.textColor = 0x576685;
		t.verticalCenter = 1.5;
		return t;
	};
	return MultiCreateBossHeadSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/multiPlayerUI/MultiMainUISkin.exml'] = window.MultiMainUISkin = (function (_super) {
	__extends(MultiMainUISkin, _super);
	function MultiMainUISkin() {
		_super.call(this);
		this.skinParts = ["u_txtSelect","u_iconArrow","u_btnSelect","u_listItem","u_scrollerItem","u_txtTips","u_btnInput","u_txtTime","u_txtRefresh","u_btnRefresh"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_btnSelect_i(),this.u_scrollerItem_i(),this.u_btnInput_i(),this.u_txtTime_i(),this.u_btnRefresh_i()];
	}
	var _proto = MultiMainUISkin.prototype;

	_proto.u_btnSelect_i = function () {
		var t = new eui.Group();
		this.u_btnSelect = t;
		t.height = 30;
		t.visible = true;
		t.x = 48;
		t.y = 115;
		t.elementsContent = [this.u_txtSelect_i(),this.u_iconArrow_i()];
		return t;
	};
	_proto.u_txtSelect_i = function () {
		var t = new eui.Label();
		this.u_txtSelect = t;
		t.bold = true;
		t.size = 20;
		t.text = "BOSS  selection";
		t.textColor = 0x8999AC;
		t.verticalCenter = 0;
		t.visible = true;
		t.x = 0;
		return t;
	};
	_proto.u_iconArrow_i = function () {
		var t = new eui.Image();
		this.u_iconArrow = t;
		t.source = "multiPlayerUI_json.multiPlayerUI_icon1";
		t.visible = true;
		t.x = 138;
		t.y = 9;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 740;
		t.horizontalCenter = 1;
		t.visible = true;
		t.width = 567;
		t.y = 159;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnInput_i = function () {
		var t = new eui.Group();
		this.u_btnInput = t;
		t.visible = true;
		t.x = 72;
		t.y = 914;
		t.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtTips_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.scale9Grid = new egret.Rectangle(80,17,81,17);
		t.source = "multiPlayerUI_json.multiPlayerUI_txt_di1";
		t.visible = true;
		t.width = 260;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "multiPlayerUI_json.multiPlayerUI_icon2";
		t.visible = true;
		t.x = 6;
		t.y = 10;
		return t;
	};
	_proto.u_txtTips_i = function () {
		var t = new eui.Label();
		this.u_txtTips = t;
		t.bold = true;
		t.size = 20;
		t.text = "Enter invitation code";
		t.textColor = 0x5F7089;
		t.visible = true;
		t.x = 37;
		t.y = 17;
		return t;
	};
	_proto.u_txtTime_i = function () {
		var t = new eui.Label();
		this.u_txtTime = t;
		t.bold = true;
		t.size = 18;
		t.stroke = 1;
		t.text = "(10s)";
		t.textAlign = "center";
		t.width = 142;
		t.x = 418;
		t.y = 964;
		return t;
	};
	_proto.u_btnRefresh_i = function () {
		var t = new eui.Group();
		this.u_btnRefresh = t;
		t.visible = true;
		t.x = 418;
		t.y = 911;
		t.elementsContent = [this._Image3_i(),this.u_txtRefresh_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "multiPlayerUI_json.multiPlayerUI_btn_bg";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtRefresh_i = function () {
		var t = new eui.Label();
		this.u_txtRefresh = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "Refresh";
		t.textColor = 0x38445D;
		t.verticalCenter = 0;
		return t;
	};
	return MultiMainUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/multiPlayerUI/MultiRoomUISkin.exml'] = window.MultiRoomUISkin = (function (_super) {
	__extends(MultiRoomUISkin, _super);
	function MultiRoomUISkin() {
		_super.call(this);
		this.skinParts = ["u_txtOwner","u_txtRoomId","u_txtCode","u_txtcopy","u_txtPart","u_txtInfo","u_grpLv","u_txtMana","u_grpInfo","u_grpHead","u_txtVip","u_txtPer","u_txtAuto","u_iconGou","u_btnGou","u_grpOwner","u_txtLeave","u_btnLeave","u_txtReady","u_btnReady"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_txtOwner_i(),this.u_txtRoomId_i(),this.u_txtCode_i(),this.u_txtcopy_i(),this.u_txtPart_i(),this._Image1_i(),this.u_grpInfo_i(),this.u_grpHead_i(),this.u_grpOwner_i(),this.u_btnLeave_i(),this.u_btnReady_i()];
	}
	var _proto = MultiRoomUISkin.prototype;

	_proto.u_txtOwner_i = function () {
		var t = new eui.Label();
		this.u_txtOwner = t;
		t.bold = true;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "Homeowner:";
		t.textColor = 0x53B4FF;
		t.visible = true;
		t.x = 43;
		t.y = 119;
		return t;
	};
	_proto.u_txtRoomId_i = function () {
		var t = new eui.Label();
		this.u_txtRoomId = t;
		t.bold = true;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "Room ID:";
		t.textColor = 0x53B4FF;
		t.visible = true;
		t.x = 43;
		t.y = 155;
		return t;
	};
	_proto.u_txtCode_i = function () {
		var t = new eui.Label();
		this.u_txtCode = t;
		t.bold = true;
		t.horizontalCenter = 21;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "Invitation code:";
		t.textColor = 0x53B4FF;
		t.visible = true;
		t.y = 155;
		return t;
	};
	_proto.u_txtcopy_i = function () {
		var t = new eui.Label();
		this.u_txtcopy = t;
		t.bold = true;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "copy";
		t.textColor = 0x4DEA00;
		t.visible = true;
		t.x = 525;
		t.y = 157;
		return t;
	};
	_proto.u_txtPart_i = function () {
		var t = new eui.Label();
		this.u_txtPart = t;
		t.bold = true;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "Participants:";
		t.textColor = 0x53B4FF;
		t.visible = true;
		t.x = 428;
		t.y = 527;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 375;
		t.horizontalCenter = 0.5;
		t.scale9Grid = new egret.Rectangle(29,29,30,30);
		t.source = "commonsUI_json.commonUI_box_2";
		t.visible = true;
		t.width = 585;
		t.y = 187;
		return t;
	};
	_proto.u_grpInfo_i = function () {
		var t = new eui.Group();
		this.u_grpInfo = t;
		t.x = 48;
		t.y = 569;
		t.elementsContent = [this._Image2_i(),this.u_txtInfo_i(),this._Image3_i(),this._Group1_i(),this.u_txtMana_i(),this._Image6_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_line2";
		t.visible = true;
		t.x = 29;
		t.y = 9;
		return t;
	};
	_proto.u_txtInfo_i = function () {
		var t = new eui.Label();
		this.u_txtInfo = t;
		t.bold = true;
		t.size = 22;
		t.text = "Information";
		t.textColor = 0x38445D;
		t.visible = true;
		t.x = 221;
		t.y = 0;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "multiRoomUI_json.multiRoomUI_boss_di1";
		t.visible = true;
		t.x = 0;
		t.y = 92;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.visible = true;
		t.x = 15;
		t.y = 133;
		t.elementsContent = [this._Image4_i(),this.u_grpLv_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "multiPlayerUI_json.multiPlayerUI_boss_di2";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_grpLv_i = function () {
		var t = new eui.Group();
		this.u_grpLv = t;
		t.height = 23;
		t.horizontalCenter = 8;
		t.y = 4;
		t.elementsContent = [this._Image5_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "numberText_json.num_role_level_l";
		t.x = 0;
		return t;
	};
	_proto.u_txtMana_i = function () {
		var t = new eui.Label();
		this.u_txtMana = t;
		t.bold = true;
		t.size = 18;
		t.stroke = 1.5;
		t.strokeColor = 0x72777F;
		t.text = "Mana cost per participant:";
		t.visible = true;
		t.x = 191;
		t.y = 141;
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(114,1,114,0);
		t.source = "commonsUI_json.commonsUI_line";
		t.width = 484;
		t.x = 30;
		t.y = 192;
		return t;
	};
	_proto.u_grpHead_i = function () {
		var t = new eui.Group();
		this.u_grpHead = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 400;
		t.y = 195;
		return t;
	};
	_proto.u_grpOwner_i = function () {
		var t = new eui.Group();
		this.u_grpOwner = t;
		t.x = 91;
		t.y = 789;
		t.elementsContent = [this.u_txtVip_i(),this.u_txtPer_i(),this.u_txtAuto_i(),this.u_btnGou_i()];
		return t;
	};
	_proto.u_txtVip_i = function () {
		var t = new eui.Label();
		this.u_txtVip = t;
		t.size = 18;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "You current VIP2";
		t.textColor = 0xFFD800;
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtPer_i = function () {
		var t = new eui.Label();
		this.u_txtPer = t;
		t.bold = true;
		t.lineSpacing = 8;
		t.size = 18;
		t.stroke = 1.5;
		t.strokeColor = 0x6E7680;
		t.text = "The percentage of mana reward for each bureau: 2%";
		t.visible = true;
		t.width = 479;
		t.x = 0;
		t.y = 34;
		return t;
	};
	_proto.u_txtAuto_i = function () {
		var t = new eui.Label();
		this.u_txtAuto = t;
		t.bold = true;
		t.size = 18;
		t.text = "All ready auto start";
		t.textColor = 0x4C5B7B;
		t.x = 285;
		t.y = 84;
		return t;
	};
	_proto.u_btnGou_i = function () {
		var t = new eui.Group();
		this.u_btnGou = t;
		t.height = 33;
		t.visible = true;
		t.width = 33;
		t.x = 461;
		t.y = 72;
		t.elementsContent = [this._Image7_i(),this.u_iconGou_i()];
		return t;
	};
	_proto._Image7_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_gou _di";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_iconGou_i = function () {
		var t = new eui.Image();
		this.u_iconGou = t;
		t.horizontalCenter = 1.5;
		t.source = "commonsUI_json.commonsUI_gou";
		t.verticalCenter = -1.5;
		t.visible = true;
		return t;
	};
	_proto.u_btnLeave_i = function () {
		var t = new eui.Group();
		this.u_btnLeave = t;
		t.visible = true;
		t.x = 77;
		t.y = 910;
		t.elementsContent = [this._Image8_i(),this.u_txtLeave_i()];
		return t;
	};
	_proto._Image8_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_3";
		t.visible = true;
		t.width = 200;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtLeave_i = function () {
		var t = new eui.Label();
		this.u_txtLeave = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "Leave";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btnReady_i = function () {
		var t = new eui.Group();
		this.u_btnReady = t;
		t.visible = true;
		t.x = 369;
		t.y = 910;
		t.elementsContent = [this._Image9_i(),this.u_txtReady_i()];
		return t;
	};
	_proto._Image9_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_3";
		t.visible = true;
		t.width = 200;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtReady_i = function () {
		var t = new eui.Label();
		this.u_txtReady = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "Ready";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	return MultiRoomUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/multiPlayerUI/popup/MultiCompletePopupSkin.exml'] = window.MultiCompletePopupSkin = (function (_super) {
	__extends(MultiCompletePopupSkin, _super);
	function MultiCompletePopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtMsg","u_txtOK","u_btnOK"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtMsg_i(),this.u_btnOK_i()];
	}
	var _proto = MultiCompletePopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "missionCompleteUI_json.missionCompleteUI_bg";
		t.visible = true;
		t.y = 416;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 3;
		t.source = "missionJieSuanUI_json.missionJieSuanUI_complete";
		t.visible = true;
		t.y = 385;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.stroke = 1.5;
		t.strokeColor = 0x000000;
		t.text = "A total of mana 1000 was obtained this time";
		t.textAlign = "center";
		t.visible = true;
		t.width = 520;
		t.wordWrap = true;
		t.y = 535;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.y = 634;
		t.elementsContent = [this._Image3_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(79,15,1,2);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "OK";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	return MultiCompletePopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/multiPlayerUI/popup/MultiFindRoomPopupSkin.exml'] = window.MultiFindRoomPopupSkin = (function (_super) {
	__extends(MultiFindRoomPopupSkin, _super);
	function MultiFindRoomPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtCode","u_txtInput","u_btnInput","u_txtCancel","u_btnCancel","u_txtOK","u_btnOK","u_btnClose"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtCode_i(),this.u_btnInput_i(),this.u_btnCancel_i(),this.u_btnOK_i(),this.u_btnClose_i()];
	}
	var _proto = MultiFindRoomPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "commonPanelUI_json.commonPanelUI_panel_4";
		t.visible = true;
		t.x = 76;
		t.y = 428;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "multiPlayerUI_json.multiPlayerUI_find_room";
		t.x = 195;
		t.y = 428;
		return t;
	};
	_proto.u_txtCode_i = function () {
		var t = new eui.Label();
		this.u_txtCode = t;
		t.size = 24;
		t.text = "Invitation code";
		t.textColor = 0x4C5B7B;
		t.visible = true;
		t.x = 146;
		t.y = 527;
		return t;
	};
	_proto.u_btnInput_i = function () {
		var t = new eui.Group();
		this.u_btnInput = t;
		t.visible = true;
		t.x = 142;
		t.y = 561;
		t.elementsContent = [this._Image3_i(),this.u_txtInput_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.scale9Grid = new egret.Rectangle(80,17,81,17);
		t.source = "multiPlayerUI_json.multiPlayerUI_txt_di1";
		t.visible = true;
		t.width = 368;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtInput_i = function () {
		var t = new eui.EditableText();
		this.u_txtInput = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.height = 41;
		t.horizontalCenter = "0";
		t.maxChars = 6;
		t.promptColor = 0x5E7089;
		t.size = 24;
		t.textColor = 0x4C5B7B;
		t.verticalAlign = "middle";
		t.verticalCenter = "0";
		t.visible = true;
		t.width = 350;
		return t;
	};
	_proto.u_btnCancel_i = function () {
		var t = new eui.Group();
		this.u_btnCancel = t;
		t.scaleX = 0.9;
		t.scaleY = 0.9;
		t.visible = true;
		t.x = 348;
		t.y = 648;
		t.elementsContent = [this._Image4_i(),this.u_txtCancel_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(64,16,1,1);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.width = 140;
		return t;
	};
	_proto.u_txtCancel_i = function () {
		var t = new eui.Label();
		this.u_txtCancel = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "Cancel";
		t.textColor = 0x38445D;
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.scaleX = 0.9;
		t.scaleY = 0.9;
		t.visible = true;
		t.x = 162;
		t.y = 648;
		t.elementsContent = [this._Image5_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(64,16,1,1);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.width = 140;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "OK";
		t.textColor = 0x38445D;
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.visible = true;
		t.x = 512;
		t.y = 428;
		return t;
	};
	return MultiFindRoomPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/multiPlayerUI/popup/MultiJoinRoomPopupSkin.exml'] = window.MultiJoinRoomPopupSkin = (function (_super) {
	__extends(MultiJoinRoomPopupSkin, _super);
	function MultiJoinRoomPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtRoomId","u_txtPass","u_txtInput","u_btnInput","u_btnClose","u_txtCancel","u_btnCancel","u_txtOK","u_btnOK"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtRoomId_i(),this.u_txtPass_i(),this.u_btnInput_i(),this.u_btnClose_i(),this.u_btnCancel_i(),this.u_btnOK_i()];
	}
	var _proto = MultiJoinRoomPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "commonPanelUI_json.commonPanelUI_panel_4";
		t.visible = true;
		t.x = 76;
		t.y = 428;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "multiPlayerUI_json.multiPlayerUI_join_room";
		t.x = 195;
		t.y = 428;
		return t;
	};
	_proto.u_txtRoomId_i = function () {
		var t = new eui.Label();
		this.u_txtRoomId = t;
		t.bold = true;
		t.size = 24;
		t.text = "Room ID    11";
		t.textColor = 0x4C5B7B;
		t.visible = true;
		t.x = 140;
		t.y = 520;
		return t;
	};
	_proto.u_txtPass_i = function () {
		var t = new eui.Label();
		this.u_txtPass = t;
		t.bold = true;
		t.size = 24;
		t.text = "Password";
		t.textColor = 0x4C5B7B;
		t.visible = true;
		t.x = 140;
		t.y = 573;
		return t;
	};
	_proto.u_btnInput_i = function () {
		var t = new eui.Group();
		this.u_btnInput = t;
		t.visible = true;
		t.x = 262;
		t.y = 558;
		t.elementsContent = [this._Image3_i(),this.u_txtInput_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.scale9Grid = new egret.Rectangle(80,17,81,17);
		t.source = "multiPlayerUI_json.multiPlayerUI_txt_di1";
		t.visible = true;
		t.width = 240;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtInput_i = function () {
		var t = new eui.EditableText();
		this.u_txtInput = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.height = 41;
		t.horizontalCenter = "0";
		t.maxChars = 6;
		t.promptColor = 0x5E7089;
		t.size = 24;
		t.textColor = 0x4C5B7B;
		t.verticalAlign = "middle";
		t.verticalCenter = "0";
		t.visible = true;
		t.width = 220;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.visible = true;
		t.x = 512;
		t.y = 428;
		return t;
	};
	_proto.u_btnCancel_i = function () {
		var t = new eui.Group();
		this.u_btnCancel = t;
		t.scaleX = 0.9;
		t.scaleY = 0.9;
		t.visible = true;
		t.x = 348;
		t.y = 648;
		t.elementsContent = [this._Image4_i(),this.u_txtCancel_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(64,16,1,1);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.width = 140;
		return t;
	};
	_proto.u_txtCancel_i = function () {
		var t = new eui.Label();
		this.u_txtCancel = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "Cancel";
		t.textColor = 0x38445D;
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.scaleX = 0.9;
		t.scaleY = 0.9;
		t.visible = true;
		t.x = 162;
		t.y = 648;
		t.elementsContent = [this._Image5_i(),this.u_txtOK_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(64,16,1,1);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.width = 140;
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "OK";
		t.textColor = 0x38445D;
		t.verticalCenter = 0;
		return t;
	};
	return MultiJoinRoomPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/multiPlayerUI/popup/MultiWaitPopupSkin.exml'] = window.MultiWaitPopupSkin = (function (_super) {
	__extends(MultiWaitPopupSkin, _super);
	function MultiWaitPopupSkin() {
		_super.call(this);
		this.skinParts = [];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i()];
	}
	var _proto = MultiWaitPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = -3.5;
		t.source = "multiRoomUI_json.multiRoomUI_wait";
		t.visible = true;
		t.y = 468;
		return t;
	};
	return MultiWaitPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/multiPlayerUI/render/MultiMainRenderSkin.exml'] = window.MultiMainRenderSkin = (function (_super) {
	__extends(MultiMainRenderSkin, _super);
	function MultiMainRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtMana","u_txtPartic","u_txtVip","u_grpLv","u_txtJoin","u_iconLock","u_btnJoin"];
		
		this.height = 174;
		this.width = 567;
		this.elementsContent = [this._Image1_i(),this.u_txtMana_i(),this.u_txtPartic_i(),this.u_txtVip_i(),this._Image2_i(),this._Group1_i(),this.u_btnJoin_i()];
	}
	var _proto = MultiMainRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "multiPlayerUI_json.multiPlayerUI_di";
		t.visible = true;
		t.x = 9;
		t.y = 0;
		return t;
	};
	_proto.u_txtMana_i = function () {
		var t = new eui.Label();
		this.u_txtMana = t;
		t.bold = true;
		t.size = 19;
		t.stroke = 1.5;
		t.strokeColor = 0x72777F;
		t.text = "Mana quantity required:";
		t.visible = true;
		t.x = 159;
		t.y = 17;
		return t;
	};
	_proto.u_txtPartic_i = function () {
		var t = new eui.Label();
		this.u_txtPartic = t;
		t.bold = true;
		t.size = 19;
		t.stroke = 1.5;
		t.strokeColor = 0x72777F;
		t.text = "Participants: 0/5";
		t.visible = true;
		t.x = 159;
		t.y = 43;
		return t;
	};
	_proto.u_txtVip_i = function () {
		var t = new eui.Label();
		this.u_txtVip = t;
		t.bold = true;
		t.size = 19;
		t.stroke = 1.5;
		t.strokeColor = 0x72777F;
		t.text = "Limit: VIP1";
		t.visible = true;
		t.x = 329;
		t.y = 42;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "multiPlayerUI_json.multiPlayerUI_boss_di1";
		t.visible = true;
		t.x = 0;
		t.y = 83;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 16;
		t.y = 124;
		t.elementsContent = [this._Image3_i(),this.u_grpLv_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "multiPlayerUI_json.multiPlayerUI_boss_di2";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_grpLv_i = function () {
		var t = new eui.Group();
		this.u_grpLv = t;
		t.height = 23;
		t.horizontalCenter = 8;
		t.y = 4;
		t.elementsContent = [this._Image4_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "numberText_json.num_role_level_l";
		return t;
	};
	_proto.u_btnJoin_i = function () {
		var t = new eui.Group();
		this.u_btnJoin = t;
		t.height = 59;
		t.visible = true;
		t.width = 122;
		t.x = 441;
		t.y = 56;
		t.elementsContent = [this._Image5_i(),this.u_txtJoin_i(),this.u_iconLock_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(64,15,2,3);
		t.scaleX = 0.9;
		t.scaleY = 0.9;
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtJoin_i = function () {
		var t = new eui.Label();
		this.u_txtJoin = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 22;
		t.text = "Join";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_iconLock_i = function () {
		var t = new eui.Image();
		this.u_iconLock = t;
		t.source = "commonsUI_json.commonsUI_btn_suo";
		t.x = 90;
		t.y = -14;
		return t;
	};
	return MultiMainRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/multiPlayerUI/render/MultiSelectRenderSkin.exml'] = window.MultiSelectRenderSkin = (function (_super) {
	__extends(MultiSelectRenderSkin, _super);
	function MultiSelectRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtBoss","u_txtLimit","u_txtMana"];
		
		this.height = 56;
		this.width = 400;
		this.elementsContent = [this._Image1_i(),this.u_txtBoss_i(),this.u_txtLimit_i(),this.u_txtMana_i()];
	}
	var _proto = MultiSelectRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "multiPlayerUI_json.multiPlayerUI_select_di2";
		t.y = 0;
		return t;
	};
	_proto.u_txtBoss_i = function () {
		var t = new eui.Label();
		this.u_txtBoss = t;
		t.bold = true;
		t.size = 20;
		t.text = "BOSS 1";
		t.verticalCenter = 0;
		t.visible = true;
		t.x = 19;
		return t;
	};
	_proto.u_txtLimit_i = function () {
		var t = new eui.Label();
		this.u_txtLimit = t;
		t.bold = true;
		t.size = 20;
		t.text = "Limit:VIP1";
		t.verticalCenter = 0;
		t.visible = true;
		t.x = 120;
		t.y = 18;
		return t;
	};
	_proto.u_txtMana_i = function () {
		var t = new eui.Label();
		this.u_txtMana = t;
		t.bold = true;
		t.size = 20;
		t.text = "Mana:2000";
		t.verticalCenter = 0;
		t.visible = true;
		t.x = 256;
		t.y = 18;
		return t;
	};
	return MultiSelectRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/multiPlayerUI/view/MultiPlayerHeadViewSkin.exml'] = window.MultiPlayerHeadViewSkin = (function (_super) {
	__extends(MultiPlayerHeadViewSkin, _super);
	function MultiPlayerHeadViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_imgHead","u_txtLv","u_txtName","u_imgReady","u_btnKick","u_grpHave"];
		
		this.height = 159;
		this.width = 167;
		this.elementsContent = [this._Group1_i()];
	}
	var _proto = MultiPlayerHeadViewSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.scaleX = 1.2;
		t.scaleY = 1.2;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this.u_imgBg_i(),this.u_grpHave_i()];
		return t;
	};
	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.source = "multiRoomUI_json.multiRoomUI_head1";
		t.visible = true;
		t.x = 0;
		t.y = 12;
		return t;
	};
	_proto.u_grpHave_i = function () {
		var t = new eui.Group();
		this.u_grpHave = t;
		t.visible = true;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this.u_imgHead_i(),this._Image1_i(),this.u_txtLv_i(),this.u_txtName_i(),this.u_imgReady_i(),this.u_btnKick_i()];
		return t;
	};
	_proto.u_imgHead_i = function () {
		var t = new eui.Image();
		this.u_imgHead = t;
		t.horizontalCenter = 3;
		t.source = "userMainUI_json.userMainUI_u_headIcon";
		t.verticalCenter = -10.5;
		t.visible = true;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "multiRoomUI_json.multiRoomUI_di_1";
		t.visible = true;
		t.x = 0;
		t.y = 90;
		return t;
	};
	_proto.u_txtLv_i = function () {
		var t = new eui.Label();
		this.u_txtLv = t;
		t.horizontalCenter = 0;
		t.size = 18;
		t.stroke = 1.5;
		t.text = "Lv.22";
		t.textColor = 0xFFFC25;
		t.visible = true;
		t.y = 93;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.horizontalCenter = 0;
		t.size = 18;
		t.stroke = 1.5;
		t.text = "Name";
		t.visible = true;
		t.y = 112;
		return t;
	};
	_proto.u_imgReady_i = function () {
		var t = new eui.Image();
		this.u_imgReady = t;
		t.source = "multiRoomUI_json.multiRoomUI_ready";
		t.visible = false;
		t.x = 35;
		t.y = 47;
		return t;
	};
	_proto.u_btnKick_i = function () {
		var t = new eui.Image();
		this.u_btnKick = t;
		t.source = "multiRoomUI_json.multiRoomUI_kick";
		t.visible = false;
		t.x = 99;
		t.y = 0;
		return t;
	};
	return MultiPlayerHeadViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/multiPlayerUI/view/MultiSelectViewSkin.exml'] = window.MultiSelectViewSkin = (function (_super) {
	__extends(MultiSelectViewSkin, _super);
	function MultiSelectViewSkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_scrollerItem","u_btnClose"];
		
		this.height = 595;
		this.width = 420;
		this.elementsContent = [this._Image1_i(),this.u_scrollerItem_i(),this.u_btnClose_i()];
	}
	var _proto = MultiSelectViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "multiPlayerUI_json.multiPlayerUI_select_di1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 510;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 400;
		t.x = 10;
		t.y = 63;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.visible = true;
		t.x = 380;
		t.y = 11;
		return t;
	};
	return MultiSelectViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/passTicketUI/page/PassTicketRewardPageSkin.exml'] = window.PassTicketRewardPageSkin = (function (_super) {
	__extends(PassTicketRewardPageSkin, _super);
	function PassTicketRewardPageSkin() {
		_super.call(this);
		this.skinParts = ["u_btnBuy","u_imgJinduBg","u_imgJindu","u_btnBuyLv","u_mcReward","u_scrollerItem"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Group1_i(),this._Group2_i(),this.u_scrollerItem_i()];
	}
	var _proto = PassTicketRewardPageSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 150;
		t.width = 150;
		t.x = 90;
		t.y = 415;
		t.elementsContent = [this._Label1_i(),this._Image1_i()];
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0;
		t.italic = true;
		t.size = 18;
		t.text = "白银通行证";
		t.y = 14;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "commonUI_json.commonUI_icon_gold";
		t.y = 62;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.width = 150;
		t.x = 90;
		t.y = 211;
		t.elementsContent = [this._Label2_i(),this._Image2_i(),this.u_btnBuy_i()];
		return t;
	};
	_proto._Label2_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0;
		t.italic = true;
		t.size = 18;
		t.text = "钻石通行证";
		t.y = 14;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "commonUI_json.commonUI_icon_gold";
		t.y = 62;
		return t;
	};
	_proto.u_btnBuy_i = function () {
		var t = new eui.Label();
		this.u_btnBuy = t;
		t.background = true;
		t.backgroundColor = 0x000000;
		t.bold = true;
		t.height = 30;
		t.horizontalCenter = 0;
		t.size = 18;
		t.text = "启用";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.width = 100;
		t.y = 110;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 370;
		t.visible = true;
		t.width = 874;
		t.x = 260;
		t.y = 225;
		t.viewport = this.u_mcReward_i();
		return t;
	};
	_proto.u_mcReward_i = function () {
		var t = new eui.Group();
		this.u_mcReward = t;
		t.visible = true;
		t.elementsContent = [this.u_imgJinduBg_i(),this.u_imgJindu_i(),this.u_btnBuyLv_i()];
		return t;
	};
	_proto.u_imgJinduBg_i = function () {
		var t = new eui.Image();
		this.u_imgJinduBg = t;
		t.scale9Grid = new egret.Rectangle(11,6,10,7);
		t.source = "commonUI_json.commonUI_jindu_1";
		t.width = 100;
		t.x = 0;
		t.y = 218;
		return t;
	};
	_proto.u_imgJindu_i = function () {
		var t = new eui.Image();
		this.u_imgJindu = t;
		t.scale9Grid = new egret.Rectangle(49,5,35,4);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_json.commonUI_jindu_6";
		t.visible = true;
		t.width = 100;
		t.x = 0;
		t.y = 220;
		return t;
	};
	_proto.u_btnBuyLv_i = function () {
		var t = new eui.Group();
		this.u_btnBuyLv = t;
		t.height = 20;
		t.width = 40;
		t.y = 217;
		t.elementsContent = [this._Image3_i(),this._Label3_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 20;
		t.scale9Grid = new egret.Rectangle(17,17,16,16);
		t.source = "commonUI_json.commonUI_box_1";
		t.width = 40;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Label3_i = function () {
		var t = new eui.Label();
		t.size = 14;
		t.text = "购买";
		t.x = 6;
		t.y = 3;
		return t;
	};
	return PassTicketRewardPageSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/passTicketUI/page/PassTicketTaskPageSkin.exml'] = window.PassTicketTaskPageSkin = (function (_super) {
	__extends(PassTicketTaskPageSkin, _super);
	function PassTicketTaskPageSkin() {
		_super.call(this);
		this.skinParts = ["u_mcTask","u_scrollerItem"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_scrollerItem_i()];
	}
	var _proto = PassTicketTaskPageSkin.prototype;

	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 370;
		t.visible = true;
		t.width = 1136;
		t.y = 225;
		t.viewport = this.u_mcTask_i();
		return t;
	};
	_proto.u_mcTask_i = function () {
		var t = new eui.Group();
		this.u_mcTask = t;
		t.visible = true;
		return t;
	};
	return PassTicketTaskPageSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/passTicketUI/PassTicketUISkin.exml'] = window.PassTicketUISkin = (function (_super) {
	__extends(PassTicketUISkin, _super);
	function PassTicketUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_imgJindu","u_txtJindu","u_grpJindu","u_txtNextLv","u_txtTime","u_txtTitle","u_btnClose"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_imgBg_i(),this._Image1_i(),this.u_grpJindu_i(),this._Image3_i(),this.u_txtNextLv_i(),this.u_txtTime_i(),this.u_txtTitle_i(),this.u_btnClose_i()];
	}
	var _proto = PassTicketUISkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 640;
		t.scale9Grid = new egret.Rectangle(17,17,16,16);
		t.source = "commonUI_json.commonUI_box_1";
		t.width = 1136;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 186;
		t.scale9Grid = new egret.Rectangle(13,13,14,14);
		t.source = "commonUI_json.commonUI_icon_bg";
		t.width = 1136;
		t.y = 13;
		return t;
	};
	_proto.u_grpJindu_i = function () {
		var t = new eui.Group();
		this.u_grpJindu = t;
		t.horizontalCenter = -35.5;
		t.visible = true;
		t.y = 109;
		t.elementsContent = [this._Image2_i(),this.u_imgJindu_i(),this.u_txtJindu_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(65,10,65,4);
		t.source = "commonUI_json.commonUI_jindu_5";
		t.visible = true;
		t.width = 195;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgJindu_i = function () {
		var t = new eui.Image();
		this.u_imgJindu = t;
		t.scale9Grid = new egret.Rectangle(49,5,35,4);
		t.source = "commonUI_json.commonUI_jindu_6";
		t.visible = true;
		t.width = 179;
		t.x = 8;
		t.y = 5;
		return t;
	};
	_proto.u_txtJindu_i = function () {
		var t = new eui.Label();
		this.u_txtJindu = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.stroke = 2;
		t.text = "150/500";
		t.textColor = 0xF0E4B0;
		t.verticalCenter = -2;
		t.visible = true;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scaleX = -1;
		t.source = "commonUI_json.commonUI_btn_close_1";
		t.x = 665;
		t.y = 109;
		return t;
	};
	_proto.u_txtNextLv_i = function () {
		var t = new eui.Label();
		this.u_txtNextLv = t;
		t.bold = true;
		t.text = "27";
		t.x = 677;
		t.y = 108;
		return t;
	};
	_proto.u_txtTime_i = function () {
		var t = new eui.Label();
		this.u_txtTime = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 18;
		t.text = "离赛季结束还有";
		t.y = 165;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.text = "通行证";
		t.x = 188;
		t.y = 95;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.source = "commonUI_json.commonUI_btn_close_1";
		t.x = 27;
		t.y = 19;
		return t;
	};
	return PassTicketUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/passTicketUI/popup/PassTicketBuyPopSkin.exml'] = window.PassTicketBuyPopSkin = (function (_super) {
	__extends(PassTicketBuyPopSkin, _super);
	function PassTicketBuyPopSkin() {
		_super.call(this);
		this.skinParts = ["u_txtTitle","u_btnTips","u_btnClose","u_iconCost1","u_txtCost1","u_btnBuy1","u_iconCost2","u_txtCost2","u_btnBuy2"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_txtTitle_i(),this.u_btnTips_i(),this.u_btnClose_i(),this._Group2_i(),this._Group4_i()];
	}
	var _proto = PassTicketBuyPopSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 500;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(10,85,10,9);
		t.source = "commonUI_json.commonUI_bg";
		t.verticalCenter = 0;
		t.width = 900;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "获取通行证";
		t.y = 96;
		return t;
	};
	_proto.u_btnTips_i = function () {
		var t = new eui.Image();
		this.u_btnTips = t;
		t.height = 20;
		t.source = "commonUI_json.commonUI_btn_th";
		t.width = 20;
		t.x = 135;
		t.y = 98;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 30;
		t.source = "commonUI_json.commonUI_btn_close_2";
		t.width = 30;
		t.x = 884;
		t.y = 88;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.x = 225;
		t.y = 310;
		t.elementsContent = [this._Image2_i(),this._Label1_i(),this._Label2_i(),this.u_btnBuy1_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 212;
		t.scale9Grid = new egret.Rectangle(23,23,24,24);
		t.source = "commonUI_json.commonUI_di_2";
		t.width = 277;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.italic = true;
		t.text = "钻石通行证";
		t.y = 32.93;
		return t;
	};
	_proto._Label2_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.italic = true;
		t.size = 18;
		t.text = "解锁钻石通行证和任务奖励";
		t.x = 74;
		t.y = 97.93;
		return t;
	};
	_proto.u_btnBuy1_i = function () {
		var t = new eui.Group();
		this.u_btnBuy1 = t;
		t.horizontalCenter = 0;
		t.y = 135;
		t.elementsContent = [this._Image3_i(),this._Group1_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 59;
		t.scale9Grid = new egret.Rectangle(23,23,24,24);
		t.source = "commonUI_json.commonUI_di_2";
		t.width = 107;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.y = 12;
		t.elementsContent = [this.u_iconCost1_i(),this.u_txtCost1_i()];
		return t;
	};
	_proto.u_iconCost1_i = function () {
		var t = new eui.Image();
		this.u_iconCost1 = t;
		t.height = 27;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.width = 27;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtCost1_i = function () {
		var t = new eui.Label();
		this.u_txtCost1 = t;
		t.bold = true;
		t.size = 20;
		t.text = "15";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 35;
		t.y = 4;
		return t;
	};
	_proto._Group4_i = function () {
		var t = new eui.Group();
		t.x = 622;
		t.y = 310;
		t.elementsContent = [this._Image4_i(),this._Label3_i(),this._Label4_i(),this.u_btnBuy2_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 212;
		t.scale9Grid = new egret.Rectangle(23,23,24,24);
		t.source = "commonUI_json.commonUI_di_2";
		t.width = 277;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Label3_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.italic = true;
		t.text = "钻石通行证礼包";
		t.y = 32.93;
		return t;
	};
	_proto._Label4_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.italic = true;
		t.size = 18;
		t.text = "钻石通行证+10级奖励";
		t.x = 74;
		t.y = 97.93;
		return t;
	};
	_proto.u_btnBuy2_i = function () {
		var t = new eui.Group();
		this.u_btnBuy2 = t;
		t.horizontalCenter = 0;
		t.y = 135;
		t.elementsContent = [this._Image5_i(),this._Group3_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.height = 59;
		t.scale9Grid = new egret.Rectangle(23,23,24,24);
		t.source = "commonUI_json.commonUI_di_2";
		t.width = 107;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.y = 12;
		t.elementsContent = [this.u_iconCost2_i(),this.u_txtCost2_i()];
		return t;
	};
	_proto.u_iconCost2_i = function () {
		var t = new eui.Image();
		this.u_iconCost2 = t;
		t.height = 27;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.width = 27;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtCost2_i = function () {
		var t = new eui.Label();
		this.u_txtCost2 = t;
		t.bold = true;
		t.size = 20;
		t.text = "15";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 35;
		t.y = 4;
		return t;
	};
	return PassTicketBuyPopSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/passTicketUI/popup/PassTicketEndPopSkin.exml'] = window.PassTicketEndPopSkin = (function (_super) {
	__extends(PassTicketEndPopSkin, _super);
	function PassTicketEndPopSkin() {
		_super.call(this);
		this.skinParts = ["u_txtTitle","u_btnClose","u_txtTime","u_txtMsg","u_btnBuy"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_txtTitle_i(),this.u_btnClose_i(),this.u_txtTime_i(),this.u_txtMsg_i(),this.u_btnBuy_i()];
	}
	var _proto = PassTicketEndPopSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 500;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(10,85,10,9);
		t.source = "commonUI_json.commonUI_bg";
		t.verticalCenter = 0;
		t.width = 900;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "温馨提示";
		t.y = 96;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.source = "commonUI_json.commonUI_btn_close_2";
		t.x = 884;
		t.y = 88;
		return t;
	};
	_proto.u_txtTime_i = function () {
		var t = new eui.Label();
		this.u_txtTime = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 18;
		t.text = "离赛季结束还有";
		t.y = 202;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.lineSpacing = 10;
		t.size = 18;
		t.text = "离赛季结束还有";
		t.textAlign = "center";
		t.width = 578;
		t.wordWrap = true;
		t.x = 515;
		t.y = 276;
		return t;
	};
	_proto.u_btnBuy_i = function () {
		var t = new eui.Label();
		this.u_btnBuy = t;
		t.background = true;
		t.backgroundColor = 0x000000;
		t.bold = true;
		t.height = 30;
		t.horizontalCenter = 0;
		t.size = 18;
		t.text = "确定";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.width = 100;
		t.y = 462;
		return t;
	};
	return PassTicketEndPopSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/passTicketUI/popup/PassTicketLevelPopSkin.exml'] = window.PassTicketLevelPopSkin = (function (_super) {
	__extends(PassTicketLevelPopSkin, _super);
	function PassTicketLevelPopSkin() {
		_super.call(this);
		this.skinParts = ["u_txtTitle","u_btnClose","u_iconCost","u_txtCost","u_btnBuy"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_txtTitle_i(),this.u_btnClose_i(),this._Label1_i(),this.u_btnBuy_i()];
	}
	var _proto = PassTicketLevelPopSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 500;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(10,85,10,9);
		t.source = "commonUI_json.commonUI_bg";
		t.verticalCenter = 0;
		t.width = 900;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "解锁奖励";
		t.y = 96;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 30;
		t.source = "commonUI_json.commonUI_btn_close_2";
		t.width = 30;
		t.x = 884;
		t.y = 88;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.italic = true;
		t.size = 18;
		t.text = "是否解锁下一级奖励";
		t.x = 74;
		t.y = 305;
		return t;
	};
	_proto.u_btnBuy_i = function () {
		var t = new eui.Group();
		this.u_btnBuy = t;
		t.horizontalCenter = 0.5;
		t.y = 447;
		t.elementsContent = [this._Image2_i(),this._Group1_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 59;
		t.scale9Grid = new egret.Rectangle(23,23,24,24);
		t.source = "commonUI_json.commonUI_di_2";
		t.width = 107;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.y = 12;
		t.elementsContent = [this.u_iconCost_i(),this.u_txtCost_i()];
		return t;
	};
	_proto.u_iconCost_i = function () {
		var t = new eui.Image();
		this.u_iconCost = t;
		t.height = 27;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.width = 27;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtCost_i = function () {
		var t = new eui.Label();
		this.u_txtCost = t;
		t.bold = true;
		t.size = 20;
		t.text = "15";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 35;
		t.y = 4;
		return t;
	};
	return PassTicketLevelPopSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/passTicketUI/view/PassTicketBigBoxSkin.exml'] = window.PassTicketBigBoxSkin = (function (_super) {
	__extends(PassTicketBigBoxSkin, _super);
	function PassTicketBigBoxSkin() {
		_super.call(this);
		this.skinParts = ["u_txtName","u_txtMsg"];
		
		this.height = 120;
		this.width = 340;
		this.elementsContent = [this.u_txtName_i(),this.u_txtMsg_i()];
	}
	var _proto = PassTicketBigBoxSkin.prototype;

	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.bold = true;
		t.size = 20;
		t.text = "额外大宝箱";
		t.x = 140;
		t.y = 6;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.lineSpacing = 8;
		t.size = 16;
		t.text = "额外大宝箱";
		t.width = 179;
		t.wordWrap = true;
		t.x = 140;
		t.y = 38;
		return t;
	};
	return PassTicketBigBoxSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/passTicketUI/view/PassTicketDailyTaskSkin.exml'] = window.PassTicketDailyTaskSkin = (function (_super) {
	__extends(PassTicketDailyTaskSkin, _super);
	function PassTicketDailyTaskSkin() {
		_super.call(this);
		this.skinParts = ["u_txtTitle","u_txtTime"];
		
		this.height = 370;
		this.width = 400;
		this.elementsContent = [this.u_txtTitle_i(),this.u_txtTime_i()];
	}
	var _proto = PassTicketDailyTaskSkin.prototype;

	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.size = 18;
		t.text = "每日任务";
		t.x = 15;
		t.y = 10;
		return t;
	};
	_proto.u_txtTime_i = function () {
		var t = new eui.Label();
		this.u_txtTime = t;
		t.bold = true;
		t.right = 0;
		t.size = 18;
		t.text = "离刷新还有：00:00:00";
		t.y = 10;
		return t;
	};
	return PassTicketDailyTaskSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/passTicketUI/view/PassTicketLevelViewSkin.exml'] = window.PassTicketLevelViewSkin = (function (_super) {
	__extends(PassTicketLevelViewSkin, _super);
	function PassTicketLevelViewSkin() {
		_super.call(this);
		this.skinParts = ["u_txtLv","u_imgReceive1","u_imgReceive2","u_imgLock"];
		
		this.height = 370;
		this.width = 150;
		this.elementsContent = [this._Group1_i(),this.u_imgReceive1_i(),this.u_imgReceive2_i(),this.u_imgLock_i(),this._Image2_i(),this._Image3_i()];
	}
	var _proto = PassTicketLevelViewSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.x = 60;
		t.y = 214;
		t.elementsContent = [this._Image1_i(),this.u_txtLv_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "commonUI_json.commonUI_icon_juan";
		t.x = 2;
		t.y = 0;
		return t;
	};
	_proto.u_txtLv_i = function () {
		var t = new eui.Label();
		this.u_txtLv = t;
		t.bold = true;
		t.size = 16;
		t.text = "100";
		t.textAlign = "center";
		t.width = 31;
		t.x = 0;
		t.y = 4;
		return t;
	};
	_proto.u_imgReceive1_i = function () {
		var t = new eui.Image();
		this.u_imgReceive1 = t;
		t.source = "passTicketUI_json.passTicketUI_ylq";
		t.touchEnabled = false;
		t.x = 8;
		t.y = 249;
		return t;
	};
	_proto.u_imgReceive2_i = function () {
		var t = new eui.Image();
		this.u_imgReceive2 = t;
		t.source = "passTicketUI_json.passTicketUI_ylq";
		t.touchEnabled = false;
		t.x = -5;
		t.y = 39;
		return t;
	};
	_proto.u_imgLock_i = function () {
		var t = new eui.Image();
		this.u_imgLock = t;
		t.source = "passTicketUI_json.passTicketUI_lock";
		t.touchEnabled = false;
		t.x = 20;
		t.y = 49;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 96;
		t.horizontalCenter = 0;
		t.visible = false;
		t.width = 96;
		t.y = 255;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 120;
		t.horizontalCenter = 0;
		t.visible = false;
		t.width = 120;
		t.x = 37;
		t.y = 55;
		return t;
	};
	return PassTicketLevelViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/passTicketUI/view/PassTicketMonthTaskSkin.exml'] = window.PassTicketSeasonTaskSkin = (function (_super) {
	__extends(PassTicketSeasonTaskSkin, _super);
	function PassTicketSeasonTaskSkin() {
		_super.call(this);
		this.skinParts = ["u_listItem"];
		
		this.height = 370;
		this.width = 400;
		this.elementsContent = [this.u_listItem_i()];
	}
	var _proto = PassTicketSeasonTaskSkin.prototype;

	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		return t;
	};
	return PassTicketSeasonTaskSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/passTicketUI/view/PassTicketTaskViewSkin.exml'] = window.PassTicketTaskViewSkin = (function (_super) {
	__extends(PassTicketTaskViewSkin, _super);
	function PassTicketTaskViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgTitle","u_txtDesc","u_mcTitle","u_imgJindu","u_txtJindu","u_mcJindu","u_txtUnique","u_mcUnique","u_imgExp","u_txtExp","u_imgMark"];
		
		this.height = 130;
		this.width = 310;
		this.elementsContent = [this._Image1_i(),this.u_mcTitle_i(),this.u_mcJindu_i(),this.u_mcUnique_i(),this._Group1_i(),this.u_imgMark_i()];
	}
	var _proto = PassTicketTaskViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 130;
		t.scale9Grid = new egret.Rectangle(17,17,16,16);
		t.source = "commonUI_json.commonUI_box_1";
		t.width = 310;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_mcTitle_i = function () {
		var t = new eui.Group();
		this.u_mcTitle = t;
		t.x = 45;
		t.y = 23;
		t.elementsContent = [this.u_imgTitle_i(),this.u_txtDesc_i()];
		return t;
	};
	_proto.u_imgTitle_i = function () {
		var t = new eui.Image();
		this.u_imgTitle = t;
		t.source = "commonUI_json.commonUI_star_1";
		t.x = 0;
		t.y = 7;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.bold = true;
		t.lineSpacing = 8;
		t.size = 18;
		t.text = "任务描述任务描述任务描述";
		t.textAlign = "center";
		t.width = 154;
		t.wordWrap = true;
		t.x = 85;
		t.y = 0;
		return t;
	};
	_proto.u_mcJindu_i = function () {
		var t = new eui.Group();
		this.u_mcJindu = t;
		t.visible = false;
		t.x = 12;
		t.y = 100;
		t.elementsContent = [this._Image2_i(),this.u_imgJindu_i(),this.u_txtJindu_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(11,6,10,7);
		t.source = "commonUI_json.commonUI_jindu_1";
		t.width = 154;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgJindu_i = function () {
		var t = new eui.Image();
		this.u_imgJindu = t;
		t.scale9Grid = new egret.Rectangle(9,5,10,4);
		t.source = "commonUI_json.commonUI_jindu_2";
		t.width = 150;
		t.x = 2;
		t.y = 2;
		return t;
	};
	_proto.u_txtJindu_i = function () {
		var t = new eui.Label();
		this.u_txtJindu = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "1000/1000";
		t.y = 2;
		return t;
	};
	_proto.u_mcUnique_i = function () {
		var t = new eui.Group();
		this.u_mcUnique = t;
		t.visible = true;
		t.x = 18;
		t.y = 86;
		t.elementsContent = [this._Image3_i(),this.u_txtUnique_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "passTicketUI_json.passTicketUI_lock";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtUnique_i = function () {
		var t = new eui.Label();
		this.u_txtUnique = t;
		t.bold = true;
		t.size = 16;
		t.text = "钻石通行证专属";
		t.x = 36;
		t.y = 14;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 208;
		t.y = 95;
		t.elementsContent = [this.u_imgExp_i(),this.u_txtExp_i()];
		return t;
	};
	_proto.u_imgExp_i = function () {
		var t = new eui.Image();
		this.u_imgExp = t;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtExp_i = function () {
		var t = new eui.Label();
		this.u_txtExp = t;
		t.bold = true;
		t.size = 16;
		t.text = "1000";
		t.verticalCenter = 0;
		t.x = 33;
		return t;
	};
	_proto.u_imgMark_i = function () {
		var t = new eui.Image();
		this.u_imgMark = t;
		t.horizontalCenter = 0;
		t.source = "commonUI_json.commonUI_icon_wh";
		t.verticalCenter = 0;
		return t;
	};
	return PassTicketTaskViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/personalizationUI/PersonalizationUISkin.exml'] = window.skins.PersonalizationUISkin = (function (_super) {
	__extends(PersonalizationUISkin, _super);
	var PersonalizationUISkin$Skin1 = 	(function (_super) {
		__extends(PersonalizationUISkin$Skin1, _super);
		function PersonalizationUISkin$Skin1() {
			_super.call(this);
			this.skinParts = ["labelDisplay"];
			
			this.elementsContent = [this._Image1_i(),this.labelDisplay_i()];
			this.states = [
				new eui.State ("up",
					[
					])
				,
				new eui.State ("down",
					[
						new eui.SetProperty("_Image1","source","personalizationUI_json.personUI_pageSle")
					])
				,
				new eui.State ("disabled",
					[
					])
			];
		}
		var _proto = PersonalizationUISkin$Skin1.prototype;

		_proto._Image1_i = function () {
			var t = new eui.Image();
			this._Image1 = t;
			t.percentHeight = 100;
			t.source = "personalizationUI_json.personUI_btnBg";
			t.percentWidth = 100;
			return t;
		};
		_proto.labelDisplay_i = function () {
			var t = new eui.Label();
			this.labelDisplay = t;
			t.bold = true;
			t.horizontalCenter = 0;
			t.size = 16;
			t.textColor = 0xF0E4B0;
			t.verticalCenter = 0;
			return t;
		};
		return PersonalizationUISkin$Skin1;
	})(eui.Skin);

	var PersonalizationUISkin$Skin2 = 	(function (_super) {
		__extends(PersonalizationUISkin$Skin2, _super);
		function PersonalizationUISkin$Skin2() {
			_super.call(this);
			this.skinParts = ["labelDisplay"];
			
			this.elementsContent = [this._Image1_i(),this.labelDisplay_i()];
			this.states = [
				new eui.State ("up",
					[
					])
				,
				new eui.State ("down",
					[
						new eui.SetProperty("_Image1","source","personalizationUI_json.personUI_pageSle")
					])
				,
				new eui.State ("disabled",
					[
					])
			];
		}
		var _proto = PersonalizationUISkin$Skin2.prototype;

		_proto._Image1_i = function () {
			var t = new eui.Image();
			this._Image1 = t;
			t.percentHeight = 100;
			t.source = "personalizationUI_json.personUI_btnBg";
			t.percentWidth = 100;
			return t;
		};
		_proto.labelDisplay_i = function () {
			var t = new eui.Label();
			this.labelDisplay = t;
			t.bold = true;
			t.horizontalCenter = 0;
			t.size = 16;
			t.textColor = 0xF0E4B0;
			t.verticalCenter = 0;
			return t;
		};
		return PersonalizationUISkin$Skin2;
	})(eui.Skin);

	var PersonalizationUISkin$Skin3 = 	(function (_super) {
		__extends(PersonalizationUISkin$Skin3, _super);
		function PersonalizationUISkin$Skin3() {
			_super.call(this);
			this.skinParts = ["labelDisplay"];
			
			this.elementsContent = [this._Image1_i(),this.labelDisplay_i()];
			this.states = [
				new eui.State ("up",
					[
					])
				,
				new eui.State ("down",
					[
						new eui.SetProperty("_Image1","source","personalizationUI_json.personUI_pageSle")
					])
				,
				new eui.State ("disabled",
					[
					])
			];
		}
		var _proto = PersonalizationUISkin$Skin3.prototype;

		_proto._Image1_i = function () {
			var t = new eui.Image();
			this._Image1 = t;
			t.percentHeight = 100;
			t.source = "personalizationUI_json.personUI_btnBg";
			t.percentWidth = 100;
			return t;
		};
		_proto.labelDisplay_i = function () {
			var t = new eui.Label();
			this.labelDisplay = t;
			t.bold = true;
			t.horizontalCenter = 0;
			t.size = 16;
			t.textColor = 0xF0E4B0;
			t.verticalCenter = 0;
			return t;
		};
		return PersonalizationUISkin$Skin3;
	})(eui.Skin);

	function PersonalizationUISkin() {
		_super.call(this);
		this.skinParts = ["u_titleLb","u_closeBtn","u_btn0","u_btn1","u_btn2","u_titleLb1","u_list","u_scroller","u_icon","u_nameLb","u_detailLb","u_detailGrp","u_choseLb","u_lockImg","u_choseBtn"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_titleLb_i(),this.u_closeBtn_i(),this.u_btn0_i(),this.u_btn1_i(),this.u_btn2_i(),this._Group1_i(),this._Group2_i()];
	}
	var _proto = PersonalizationUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 500.755;
		t.scale9Grid = new egret.Rectangle(180,80,10,10);
		t.source = "personalizationUI_json.personUI_bg0";
		t.visible = true;
		t.width = 796.876;
		t.x = 168.814;
		t.y = 59;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "gameSettingUI_json.gameSettingUI_set";
		t.visible = true;
		t.x = 185.5;
		t.y = 79.667;
		return t;
	};
	_proto.u_titleLb_i = function () {
		var t = new eui.Label();
		this.u_titleLb = t;
		t.bold = true;
		t.size = 16;
		t.text = "设置";
		t.textColor = 0xF0E4B0;
		t.x = 218;
		t.y = 87.666;
		return t;
	};
	_proto.u_closeBtn_i = function () {
		var t = new eui.Image();
		this.u_closeBtn = t;
		t.source = "gameSettingUI_json.gameSettingUI_btn_close";
		t.x = 934;
		t.y = 90;
		return t;
	};
	_proto.u_btn0_i = function () {
		var t = new PersonalButton();
		this.u_btn0 = t;
		t.height = 100;
		t.label = "头像";
		t.width = 132;
		t.x = 170;
		t.y = 132;
		t.skinName = PersonalizationUISkin$Skin1;
		return t;
	};
	_proto.u_btn1_i = function () {
		var t = new PersonalButton();
		this.u_btn1 = t;
		t.height = 100;
		t.label = "头像框";
		t.width = 132;
		t.x = 170;
		t.y = 234;
		t.skinName = PersonalizationUISkin$Skin2;
		return t;
	};
	_proto.u_btn2_i = function () {
		var t = new PersonalButton();
		this.u_btn2 = t;
		t.height = 100;
		t.label = "聊天框";
		t.width = 132;
		t.x = 170;
		t.y = 336;
		t.skinName = PersonalizationUISkin$Skin3;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 322;
		t.y = 145;
		t.elementsContent = [this._Image3_i(),this.u_titleLb1_i(),this._Image4_i(),this.u_scroller_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 398;
		t.scale9Grid = new egret.Rectangle(20,20,20,20);
		t.source = "personalizationUI_json.personUI_bg1";
		t.width = 421;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_titleLb1_i = function () {
		var t = new eui.Label();
		this.u_titleLb1 = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "头像框";
		t.textColor = 0xF0E4B0;
		t.y = 19;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "personalizationUI_json.personUI_line";
		t.y = 45;
		return t;
	};
	_proto.u_scroller_i = function () {
		var t = new eui.Scroller();
		this.u_scroller = t;
		t.height = 312;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 385;
		t.y = 71;
		t.viewport = this.u_list_i();
		return t;
	};
	_proto.u_list_i = function () {
		var t = new eui.List();
		this.u_list = t;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.x = 759;
		t.y = 145;
		t.elementsContent = [this._Image5_i(),this.u_icon_i(),this.u_detailGrp_i(),this.u_choseBtn_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.height = 399;
		t.scale9Grid = new egret.Rectangle(20,20,20,20);
		t.source = "personalizationUI_json.personUI_bg1";
		t.width = 194;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_icon_i = function () {
		var t = new eui.Image();
		this.u_icon = t;
		t.height = 100;
		t.horizontalCenter = 0;
		t.width = 100;
		t.y = 60;
		return t;
	};
	_proto.u_detailGrp_i = function () {
		var t = new eui.Group();
		this.u_detailGrp = t;
		t.horizontalCenter = 0;
		t.y = 175;
		t.elementsContent = [this.u_nameLb_i(),this.u_detailLb_i()];
		return t;
	};
	_proto.u_nameLb_i = function () {
		var t = new eui.Label();
		this.u_nameLb = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "头像框名称";
		t.textColor = 0xF0E4B0;
		t.y = 0;
		return t;
	};
	_proto.u_detailLb_i = function () {
		var t = new eui.Label();
		this.u_detailLb = t;
		t.horizontalCenter = 0;
		t.lineSpacing = 5;
		t.size = 16;
		t.text = "开宝箱获得获取";
		t.textColor = 0xA5A5A5;
		t.y = 43;
		return t;
	};
	_proto.u_choseBtn_i = function () {
		var t = new eui.Group();
		this.u_choseBtn = t;
		t.horizontalCenter = 0;
		t.y = 292;
		t.elementsContent = [this._Image6_i(),this.u_choseLb_i(),this.u_lockImg_i()];
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "personalizationUI_json.personUI_btn_bg";
		t.visible = true;
		t.width = 159;
		t.y = 0;
		return t;
	};
	_proto.u_choseLb_i = function () {
		var t = new eui.Label();
		this.u_choseLb = t;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "选择";
		t.textColor = 0xF0E4B0;
		t.verticalCenter = -3;
		return t;
	};
	_proto.u_lockImg_i = function () {
		var t = new eui.Image();
		this.u_lockImg = t;
		t.source = "personalizationUI_json.personUI_lock";
		t.x = 8;
		t.y = 5;
		return t;
	};
	return PersonalizationUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/personalizationUI/render/PersonalIconRenderSkin.exml'] = window.skins.PersonalIconRenderSkin = (function (_super) {
	__extends(PersonalIconRenderSkin, _super);
	function PersonalIconRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_icon","u_lockImg","u_selectImg","u_using"];
		
		this.height = 80;
		this.width = 80;
		this.elementsContent = [this.u_icon_i(),this.u_lockImg_i(),this.u_selectImg_i(),this.u_using_i()];
	}
	var _proto = PersonalIconRenderSkin.prototype;

	_proto.u_icon_i = function () {
		var t = new eui.Image();
		this.u_icon = t;
		t.height = 80;
		t.horizontalCenter = 0;
		t.verticalCenter = 0;
		t.width = 80;
		return t;
	};
	_proto.u_lockImg_i = function () {
		var t = new eui.Image();
		this.u_lockImg = t;
		t.source = "personalizationUI_json.personUI_lock";
		t.x = 11;
		t.y = 18;
		return t;
	};
	_proto.u_selectImg_i = function () {
		var t = new eui.Image();
		this.u_selectImg = t;
		t.horizontalCenter = 0;
		t.source = "personalizationUI_json.personUI_select";
		t.verticalCenter = 0;
		t.visible = false;
		return t;
	};
	_proto.u_using_i = function () {
		var t = new eui.Label();
		this.u_using = t;
		t.horizontalCenter = 0;
		t.lineSpacing = 3;
		t.size = 16;
		t.stroke = 2;
		t.text = "使用中";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalCenter = 0;
		t.width = 70;
		return t;
	};
	return PersonalIconRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/promoteUI/PromoteUISkin.exml'] = window.PromoteUISkin = (function (_super) {
	__extends(PromoteUISkin, _super);
	function PromoteUISkin() {
		_super.call(this);
		this.skinParts = ["u_shareTips","u_btnRule","u_imgRed","u_btnInfo","u_listItem","u_scrollerItem","u_receiveRed","u_btnReceive","u_timesBg","u_txtTimes"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Group1_i(),this.u_btnRule_i(),this.u_btnInfo_i(),this.u_scrollerItem_i(),this.u_btnReceive_i(),this._Group3_i()];
	}
	var _proto = PromoteUISkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 2.36;
		t.y = 46.98;
		t.elementsContent = [this._Image1_i(),this.u_shareTips_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "shareUI_json.shareUI_img_nv";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_shareTips_i = function () {
		var t = new eui.Label();
		this.u_shareTips = t;
		t.bold = true;
		t.lineSpacing = 12;
		t.size = 18;
		t.stroke = 2;
		t.strokeColor = 0x6C4B3F;
		t.text = "Share it with";
		t.visible = true;
		t.x = 176;
		t.y = 141;
		return t;
	};
	_proto.u_btnRule_i = function () {
		var t = new eui.Image();
		this.u_btnRule = t;
		t.height = 44;
		t.source = "shareUI_json.shareUI_rule";
		t.touchEnabled = true;
		t.visible = true;
		t.width = 44;
		t.x = 451;
		t.y = 376.518;
		return t;
	};
	_proto.u_btnInfo_i = function () {
		var t = new eui.Group();
		this.u_btnInfo = t;
		t.height = 44;
		t.width = 45;
		t.x = 452.3;
		t.y = 430.65;
		t.elementsContent = [this._Image2_i(),this.u_imgRed_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "shareUI_json.shareUI_info";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgRed_i = function () {
		var t = new eui.Image();
		this.u_imgRed = t;
		t.source = "commonUI_json.commonUI_red";
		t.visible = true;
		t.x = 28.17;
		t.y = 0.83;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 350;
		t.horizontalCenter = 171;
		t.visible = true;
		t.width = 420;
		t.y = 132;
		t.viewport = this._Group2_i();
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.width = 420.151;
		t.x = -51.726;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnReceive_i = function () {
		var t = new eui.Group();
		this.u_btnReceive = t;
		t.height = 45;
		t.visible = true;
		t.width = 113;
		t.x = 196.833;
		t.y = 454.528;
		t.elementsContent = [this._Image3_i(),this.u_receiveRed_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(64,22,2,21);
		t.source = "shareUI_json.shareUI_btn_recive";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_receiveRed_i = function () {
		var t = new eui.Image();
		this.u_receiveRed = t;
		t.source = "commonUI_json.commonUI_red";
		t.x = 96.789;
		t.y = -3.876;
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.visible = true;
		t.x = 254;
		t.y = 435.41;
		t.elementsContent = [this.u_timesBg_i(),this.u_txtTimes_i()];
		return t;
	};
	_proto.u_timesBg_i = function () {
		var t = new eui.Image();
		this.u_timesBg = t;
		t.height = 27;
		t.scale9Grid = new egret.Rectangle(20,9,12,9);
		t.source = "shareUI_json.shareUI_tip_bj";
		t.width = 48;
		t.y = 0;
		return t;
	};
	_proto.u_txtTimes_i = function () {
		var t = new eui.Label();
		this.u_txtTimes = t;
		t.height = 18;
		t.horizontalCenter = 0;
		t.size = 18;
		t.text = "1/1";
		t.textAlign = "center";
		t.textColor = 0x4DEA00;
		t.visible = true;
		t.y = 4;
		return t;
	};
	return PromoteUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/promoteUI/render/PromoteInfoRenderSkin.exml'] = window.PromoteInfoRenderSkin = (function (_super) {
	__extends(PromoteInfoRenderSkin, _super);
	function PromoteInfoRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtTime","u_txtDesc","u_imgLine"];
		
		this.height = 50;
		this.width = 410;
		this.elementsContent = [this.u_txtTime_i(),this.u_txtDesc_i(),this.u_imgLine_i()];
	}
	var _proto = PromoteInfoRenderSkin.prototype;

	_proto.u_txtTime_i = function () {
		var t = new eui.Label();
		this.u_txtTime = t;
		t.bold = true;
		t.size = 14;
		t.text = "22:00";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.bold = true;
		t.height = 33;
		t.horizontalCenter = 0;
		t.lineSpacing = 5;
		t.size = 14;
		t.text = "newGet newGet newGet newGet newGet new";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.visible = true;
		t.width = 410;
		t.wordWrap = true;
		t.y = 15;
		return t;
	};
	_proto.u_imgLine_i = function () {
		var t = new eui.Image();
		this.u_imgLine = t;
		t.bottom = 0;
		t.horizontalCenter = 0;
		t.source = "shareUI_json.shareUI_line2";
		return t;
	};
	return PromoteInfoRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/promoteUI/render/PromoteRenderSkin.exml'] = window.PromoteRenderSkin = (function (_super) {
	__extends(PromoteRenderSkin, _super);
	function PromoteRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtInfo1","u_txtInfo2","u_txtInfo3","u_txtInfo4"];
		
		this.height = 110;
		this.width = 420;
		this.elementsContent = [this._Image1_i(),this.u_txtInfo1_i(),this.u_txtInfo2_i(),this.u_txtInfo3_i(),this.u_txtInfo4_i()];
	}
	var _proto = PromoteRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetY = 0;
		t.bottom = 0;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(182,19,183,2);
		t.source = "shareUI_json.shareUI_line_bj";
		t.visible = true;
		return t;
	};
	_proto.u_txtInfo1_i = function () {
		var t = new eui.Label();
		this.u_txtInfo1 = t;
		t.bold = true;
		t.size = 16;
		t.text = "Number";
		t.textColor = 0x3F393C;
		t.visible = true;
		t.x = 15;
		t.y = 12;
		return t;
	};
	_proto.u_txtInfo2_i = function () {
		var t = new eui.Label();
		this.u_txtInfo2 = t;
		t.bold = true;
		t.size = 16;
		t.text = "Number";
		t.textColor = 0x3F393C;
		t.visible = true;
		t.x = 15;
		t.y = 33;
		return t;
	};
	_proto.u_txtInfo3_i = function () {
		var t = new eui.Label();
		this.u_txtInfo3 = t;
		t.bold = true;
		t.size = 16;
		t.text = "Number";
		t.textColor = 0x3F393C;
		t.visible = true;
		t.x = 15;
		t.y = 54;
		return t;
	};
	_proto.u_txtInfo4_i = function () {
		var t = new eui.Label();
		this.u_txtInfo4 = t;
		t.bold = true;
		t.size = 16;
		t.text = "Number";
		t.textColor = 0x3F393C;
		t.visible = true;
		t.x = 15;
		t.y = 75;
		return t;
	};
	return PromoteRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/promoteUI/view/PromoteRecordSkin.exml'] = window.PromoteRecordSkin = (function (_super) {
	__extends(PromoteRecordSkin, _super);
	function PromoteRecordSkin() {
		_super.call(this);
		this.skinParts = ["u_txtTitle","u_listItem","u_scrollerItem","u_txtNone"];
		
		this.height = 247;
		this.width = 453;
		this.elementsContent = [this._Image1_i(),this.u_txtTitle_i(),this.u_scrollerItem_i(),this.u_txtNone_i()];
	}
	var _proto = PromoteRecordSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 247;
		t.horizontalCenter = 0;
		t.source = "shareUI_json.shareUI_di_1";
		t.verticalCenter = 0;
		t.width = 453;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 8.5;
		t.size = 18;
		t.stroke = 2;
		t.strokeColor = 0x333333;
		t.text = "推广记录";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.y = 14;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 170;
		t.horizontalCenter = 6.5;
		t.verticalCenter = 14;
		t.visible = true;
		t.width = 410;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtNone_i = function () {
		var t = new eui.Label();
		this.u_txtNone = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.lineSpacing = 12;
		t.size = 22;
		t.stroke = 2;
		t.strokeColor = 0x333333;
		t.text = "暂无推广记录";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalCenter = 8.5;
		t.wordWrap = true;
		return t;
	};
	return PromoteRecordSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/promoteUI/view/PromoteRuleSkin.exml'] = window.PromoteRuleSkin = (function (_super) {
	__extends(PromoteRuleSkin, _super);
	function PromoteRuleSkin() {
		_super.call(this);
		this.skinParts = ["u_txtTitle","u_txtMsg","u_scrollerItem"];
		
		this.height = 247;
		this.width = 458;
		this.elementsContent = [this._Image1_i(),this.u_txtTitle_i(),this.u_scrollerItem_i()];
	}
	var _proto = PromoteRuleSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 247;
		t.scale9Grid = new egret.Rectangle(203,124,49,21);
		t.source = "shareUI_json.shareUI_di_1";
		t.visible = true;
		t.width = 458;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 5;
		t.size = 18;
		t.stroke = 2;
		t.strokeColor = 0x333333;
		t.text = "规则说明";
		t.textAlign = "center";
		t.textColor = 0xFFE2C5;
		t.visible = true;
		t.y = 13;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.height = 165;
		t.width = 402;
		t.x = 34;
		t.y = 56;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_txtMsg_i()];
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.lineSpacing = 12;
		t.size = 14;
		t.text = "规则";
		t.textColor = 0xF0E4B0;
		t.width = 402;
		t.wordWrap = true;
		t.y = 3;
		return t;
	};
	return PromoteRuleSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/rankUI/RankPopupSkin.exml'] = window.skins.RankUISkin = (function (_super) {
	__extends(RankUISkin, _super);
	function RankUISkin() {
		_super.call(this);
		this.skinParts = ["u_closeBtn","u_rankLb","u_list","u_scroller"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_closeBtn_i(),this._Image2_i(),this.u_rankLb_i(),this.u_scroller_i()];
	}
	var _proto = RankUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 502.595;
		t.scale9Grid = new egret.Rectangle(9,80,11,11);
		t.source = "commonUI_json.commonUI_bg";
		t.visible = true;
		t.width = 1031.385;
		t.x = 52.802;
		t.y = 75.267;
		return t;
	};
	_proto.u_closeBtn_i = function () {
		var t = new eui.Image();
		this.u_closeBtn = t;
		t.height = 16;
		t.scaleX = 1;
		t.source = "rankUI_json.rankUI_close";
		t.width = 16;
		t.x = 1041;
		t.y = 104;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "rankUI_json.rankUI_sort";
		t.x = 70;
		t.y = 98;
		return t;
	};
	_proto.u_rankLb_i = function () {
		var t = new eui.Label();
		this.u_rankLb = t;
		t.size = 18;
		t.text = "排名信息";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 102;
		t.y = 102.999;
		return t;
	};
	_proto.u_scroller_i = function () {
		var t = new eui.Scroller();
		this.u_scroller = t;
		t.height = 378;
		t.horizontalCenter = 0;
		t.width = 974;
		t.y = 164;
		t.viewport = this.u_list_i();
		return t;
	};
	_proto.u_list_i = function () {
		var t = new eui.List();
		this.u_list = t;
		return t;
	};
	return RankUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/rankUI/render/RankRenderSkin.exml'] = window.skins.RankRenderSkin = (function (_super) {
	__extends(RankRenderSkin, _super);
	function RankRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_bg","u_rankImg","u_nameLb","u_goldLb","u_diamondLb","u_icon","u_imgFirst","u_grpHead"];
		
		this.height = 87;
		this.width = 487;
		this.elementsContent = [this.u_bg_i(),this.u_rankImg_i(),this.u_nameLb_i(),this._Image1_i(),this.u_goldLb_i(),this._Image2_i(),this.u_diamondLb_i(),this.u_grpHead_i()];
	}
	var _proto = RankRenderSkin.prototype;

	_proto.u_bg_i = function () {
		var t = new eui.Image();
		this.u_bg = t;
		t.source = "rankUI_json.xxBg_1";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_rankImg_i = function () {
		var t = new eui.Image();
		this.u_rankImg = t;
		t.horizontalCenter = -192;
		t.source = "rankUI_json.rankUI_icon_1";
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_nameLb_i = function () {
		var t = new eui.Label();
		this.u_nameLb = t;
		t.fontFamily = "Arial";
		t.size = 16;
		t.text = "S1.小明明天去上学";
		t.textColor = 0xF0E4B0;
		t.x = 202.334;
		t.y = 18.5;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 30;
		t.source = "commonUI_json.commonUI_icon_gold";
		t.width = 30;
		t.x = 203.167;
		t.y = 42.833;
		return t;
	};
	_proto.u_goldLb_i = function () {
		var t = new eui.Label();
		this.u_goldLb = t;
		t.horizontalCenter = 25.5;
		t.size = 16;
		t.text = "999.92K";
		t.textColor = 0xF0E4B0;
		t.y = 49.999;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 30;
		t.source = "commonUI_json.commonUI_icon_juan";
		t.width = 30;
		t.x = 340.834;
		t.y = 42.833;
		return t;
	};
	_proto.u_diamondLb_i = function () {
		var t = new eui.Label();
		this.u_diamondLb = t;
		t.horizontalCenter = 163.5;
		t.size = 16;
		t.text = "999.92K";
		t.textColor = 0xF0E4B0;
		t.y = 50.665;
		return t;
	};
	_proto.u_grpHead_i = function () {
		var t = new eui.Group();
		this.u_grpHead = t;
		t.x = 100;
		t.y = 4;
		t.elementsContent = [this.u_icon_i(),this.u_imgFirst_i()];
		return t;
	};
	_proto.u_icon_i = function () {
		var t = new eui.Image();
		this.u_icon = t;
		t.height = 60;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "rankUI_json.rankUI_icon";
		t.verticalCenter = 1;
		t.visible = false;
		t.width = 60;
		t.x = 3;
		t.y = -83;
		return t;
	};
	_proto.u_imgFirst_i = function () {
		var t = new eui.Image();
		this.u_imgFirst = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "rankUI_json.rankUI_img_hg";
		t.visible = false;
		t.x = 4;
		t.y = 0;
		return t;
	};
	return RankRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/rechargeUI/RechargeUISkin.exml'] = window.RechargeUISkin = (function (_super) {
	__extends(RechargeUISkin, _super);
	function RechargeUISkin() {
		_super.call(this);
		this.skinParts = ["u_txtMsg","u_imgJindu","u_txtVip","u_txtProgress","u_grpProgress","u_btnView","u_listItem","u_scrollerItem","u_tipBg","u_txtTips"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtMsg_i(),this.u_grpProgress_i(),this.u_btnView_i(),this.u_scrollerItem_i(),this._Group2_i()];
	}
	var _proto = RechargeUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 561.756;
		t.horizontalCenter = 0.5;
		t.scale9Grid = new egret.Rectangle(26,27,27,27);
		t.source = "rechargeUI_json.rechargeUI_bg";
		t.visible = true;
		t.width = 1002.692;
		t.y = 78.095;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 23;
		t.source = "rechargeUI_json.rechargeUI_icon_th";
		t.visible = true;
		t.width = 22;
		t.x = 390;
		t.y = 128;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.border = false;
		t.lineSpacing = 10;
		t.size = 18;
		t.stroke = 2;
		t.strokeColor = 0xA71C0D;
		t.text = "再充值$8    即可升级至";
		t.textAlign = "left";
		t.visible = true;
		t.wordWrap = true;
		t.x = 419;
		t.y = 128;
		return t;
	};
	_proto.u_grpProgress_i = function () {
		var t = new eui.Group();
		this.u_grpProgress = t;
		t.visible = true;
		t.width = 413.737;
		t.x = 381.197;
		t.y = 155.902;
		t.elementsContent = [this._Image3_i(),this.u_imgJindu_i(),this._Image4_i(),this.u_txtVip_i(),this.u_txtProgress_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 20;
		t.scale9Grid = new egret.Rectangle(15,8,281,8);
		t.source = "rechargeUI_json.rechargeUI_jdt1";
		t.visible = true;
		t.width = 307;
		t.x = 100;
		t.y = 0;
		return t;
	};
	_proto.u_imgJindu_i = function () {
		var t = new eui.Image();
		this.u_imgJindu = t;
		t.height = 18;
		t.scale9Grid = new egret.Rectangle(15,6,277,6);
		t.source = "rechargeUI_json.rechargeUI_jdt2";
		t.visible = true;
		t.width = 23;
		t.x = 102;
		t.y = 0.5;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "rechargeUI_json.rechargeUI_bg_vip";
		t.visible = true;
		t.x = 14;
		return t;
	};
	_proto.u_txtVip_i = function () {
		var t = new eui.Label();
		this.u_txtVip = t;
		t.bold = true;
		t.height = 20;
		t.size = 18;
		t.stroke = 2;
		t.strokeColor = 0xA71C0D;
		t.text = "VIP15";
		t.textAlign = "center";
		t.visible = true;
		t.width = 110;
		t.x = 13;
		t.y = 4;
		return t;
	};
	_proto.u_txtProgress_i = function () {
		var t = new eui.Label();
		this.u_txtProgress = t;
		t.height = 13;
		t.horizontalCenter = 50.13149999999999;
		t.italic = true;
		t.size = 14;
		t.stroke = 2;
		t.strokeColor = 0x3A5905;
		t.text = "0/100";
		t.textAlign = "center";
		t.verticalCenter = -2.5;
		t.visible = true;
		t.width = 300;
		t.x = 100;
		t.y = 10;
		return t;
	};
	_proto.u_btnView_i = function () {
		var t = new eui.Image();
		this.u_btnView = t;
		t.height = 63;
		t.source = "rechargeUI_json.rechargeUI_btn_tq";
		t.width = 162;
		t.x = 830;
		t.y = 120;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 360;
		t.horizontalCenter = 136;
		t.visible = true;
		t.width = 620;
		t.y = 200;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.width = 946;
		t.x = 92.36;
		t.y = 575.78;
		t.elementsContent = [this.u_tipBg_i(),this.u_txtTips_i(),this._Image5_i()];
		return t;
	};
	_proto.u_tipBg_i = function () {
		var t = new eui.Image();
		this.u_tipBg = t;
		t.height = 40;
		t.source = "rechargeUI_json.rechargeUI_tbg";
		t.width = 291;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtTips_i = function () {
		var t = new eui.Label();
		this.u_txtTips = t;
		t.bold = true;
		t.lineSpacing = 5;
		t.multiline = false;
		t.size = 18;
		t.text = "实际充值量根据汇率实时波动";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.wordWrap = true;
		t.x = 34.64;
		t.y = 11.48;
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.height = 23;
		t.source = "rechargeUI_json.rechargeUI_icon_th";
		t.visible = true;
		t.width = 22;
		t.x = 2.64;
		t.y = 9.22;
		return t;
	};
	return RechargeUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/rechargeUI/render/RechargeRenderSkin.exml'] = window.RechargeRenderSkin = (function (_super) {
	__extends(RechargeRenderSkin, _super);
	function RechargeRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBj","u_txtMoney","u_imgIcon","u_txtExp","u_mcContent"];
		
		this.height = 171;
		this.width = 143;
		this.elementsContent = [this.u_imgBj_i(),this.u_mcContent_i()];
	}
	var _proto = RechargeRenderSkin.prototype;

	_proto.u_imgBj_i = function () {
		var t = new eui.Image();
		this.u_imgBj = t;
		t.height = 171;
		t.source = "rechargeUI_json.rechargeUI_renderBg";
		t.visible = true;
		t.width = 143;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_mcContent_i = function () {
		var t = new eui.Group();
		this.u_mcContent = t;
		t.height = 171;
		t.width = 143;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this.u_txtMoney_i(),this.u_imgIcon_i(),this.u_txtExp_i()];
		return t;
	};
	_proto.u_txtMoney_i = function () {
		var t = new eui.Label();
		this.u_txtMoney = t;
		t.horizontalCenter = -1.5;
		t.size = 18;
		t.stroke = 1;
		t.strokeColor = 0xBA7C4F;
		t.text = "$6 ";
		t.textColor = 0xF0E4B0;
		t.y = 11.816;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 108.857;
		t.horizontalCenter = 0;
		t.scaleX = 0.7;
		t.scaleY = 0.7;
		t.source = "rechargeUI_json.rechargeUI_icon_yb";
		t.visible = true;
		t.width = 118.142;
		t.y = 39.658;
		return t;
	};
	_proto.u_txtExp_i = function () {
		var t = new eui.Label();
		this.u_txtExp = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "vip经验 +800k";
		t.textColor = 0x3F393C;
		t.y = 133;
		return t;
	};
	return RechargeRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/redPacketUI/RedPacketPopupSkin.exml'] = window.RedPacketPopupSkin = (function (_super) {
	__extends(RedPacketPopupSkin, _super);
	function RedPacketPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_btnClick","u_txtMsg","u_txtTime","u_txtTitle"];
		
		this.height = 600;
		this.width = 500;
		this.elementsContent = [this._Image1_i(),this.u_btnClick_i(),this.u_txtMsg_i(),this.u_txtTime_i(),this.u_txtTitle_i()];
	}
	var _proto = RedPacketPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "redPacketUI_json.redPacketUI_popup_bj";
		return t;
	};
	_proto.u_btnClick_i = function () {
		var t = new eui.Image();
		this.u_btnClick = t;
		t.alpha = 0;
		t.anchorOffsetY = 0;
		t.height = 109;
		t.scale9Grid = new egret.Rectangle(1,1,8,8);
		t.source = "commonUI_box";
		t.width = 104;
		t.x = 197.5;
		t.y = 376;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.lineSpacing = 10;
		t.size = 24;
		t.stroke = 2;
		t.strokeColor = 0x282828;
		t.text = "Add another another, another anotheranother nother anotheranother another another";
		t.textAlign = "center";
		t.textColor = 0xFAEDAD;
		t.verticalAlign = "middle";
		t.verticalCenter = -15;
		t.width = 350;
		t.wordWrap = true;
		return t;
	};
	_proto.u_txtTime_i = function () {
		var t = new eui.Label();
		this.u_txtTime = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.lineSpacing = 10;
		t.size = 20;
		t.stroke = 1;
		t.strokeColor = 0x2f8c01;
		t.text = "Destroyed after 15 s";
		t.textAlign = "center";
		t.textColor = 0x5eff00;
		t.verticalAlign = "middle";
		t.wordWrap = true;
		t.y = 503;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.lineSpacing = 10;
		t.size = 25;
		t.stroke = 2;
		t.strokeColor = 0x9A3612;
		t.text = "A red envelope award";
		t.textAlign = "center";
		t.textColor = 0xFAEDAD;
		t.verticalAlign = "middle";
		t.wordWrap = true;
		t.y = 92;
		return t;
	};
	return RedPacketPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/redPacketUI/RedPacketReceiveSkin.exml'] = window.RedPacketReceiveSkin = (function (_super) {
	__extends(RedPacketReceiveSkin, _super);
	function RedPacketReceiveSkin() {
		_super.call(this);
		this.skinParts = ["u_imgIcon","u_imgJia"];
		
		this.height = 126;
		this.width = 463;
		this.elementsContent = [this.u_imgIcon_i(),this.u_imgJia_i()];
	}
	var _proto = RedPacketReceiveSkin.prototype;

	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.x = 57;
		t.y = 20;
		return t;
	};
	_proto.u_imgJia_i = function () {
		var t = new eui.Image();
		this.u_imgJia = t;
		t.source = "numberText_json.num_sy_j";
		t.x = 132;
		t.y = 27;
		return t;
	};
	return RedPacketReceiveSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/redPacketUI/RedPacketUISkin.exml'] = window.RedPacketUISkin = (function (_super) {
	__extends(RedPacketUISkin, _super);
	function RedPacketUISkin() {
		_super.call(this);
		this.skinParts = ["u_txtMsg"];
		
		this.height = 192;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this.u_txtMsg_i()];
	}
	var _proto = RedPacketUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "redPacketUI_json.redPacketUI_bj";
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.height = 116;
		t.horizontalCenter = 0.5;
		t.lineSpacing = 10;
		t.size = 26;
		t.stroke = 2;
		t.strokeColor = 0x9a3612;
		t.text = "Add another another, another anotheranother another";
		t.textAlign = "center";
		t.textColor = 0xfaedad;
		t.verticalAlign = "middle";
		t.width = 439;
		t.wordWrap = true;
		t.y = 41;
		return t;
	};
	return RedPacketUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/rewardUI/RewardReceiveSkin.exml'] = window.RewardReceiveSkin = (function (_super) {
	__extends(RewardReceiveSkin, _super);
	function RewardReceiveSkin() {
		_super.call(this);
		this.skinParts = ["u_txtTip","u_txtTitle"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_txtTip_i(),this.u_txtTitle_i()];
	}
	var _proto = RewardReceiveSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(152,100,100,132);
		t.source = "rewardUI_json.rewardUI_bg";
		t.x = -122;
		t.y = 120;
		return t;
	};
	_proto.u_txtTip_i = function () {
		var t = new eui.Label();
		this.u_txtTip = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.size = 18;
		t.text = "点击空白处关闭窗口";
		t.textColor = 0xa5a5a5;
		t.touchEnabled = false;
		t.y = 564.83;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.size = 30;
		t.text = "点击空白处关闭窗口";
		t.textColor = 0xf0e4b0;
		t.touchEnabled = false;
		t.y = 56.83;
		return t;
	};
	return RewardReceiveSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/rewardUI/RewardShowSkin.exml'] = window.RewardShowSkin = (function (_super) {
	__extends(RewardShowSkin, _super);
	function RewardShowSkin() {
		_super.call(this);
		this.skinParts = ["u_btnSure","u_txtDesc","u_btnClose"];
		
		this.height = 416;
		this.width = 543;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_btnSure_i(),this.u_txtDesc_i(),this.u_btnClose_i()];
	}
	var _proto = RewardShowSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 415;
		t.scale9Grid = new egret.Rectangle(242,89,3,9);
		t.source = "commonPanelUI_json.commonPanelUI_panel_4";
		t.visible = true;
		t.width = 543;
		t.x = 0;
		t.y = 1;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_details";
		t.x = 141;
		t.y = 5;
		return t;
	};
	_proto.u_btnSure_i = function () {
		var t = new eui.Group();
		this.u_btnSure = t;
		t.height = 65;
		t.visible = true;
		t.width = 135;
		t.x = 202;
		t.y = 292;
		t.elementsContent = [this._Image3_i(),this._Label1_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(64,22,2,21);
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "OK";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.bold = true;
		t.lineSpacing = 10;
		t.size = 22;
		t.text = "Get a reward";
		t.textAlign = "center";
		t.textColor = 0x465B85;
		t.visible = false;
		t.width = 435;
		t.x = 54;
		t.y = 88;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 40;
		t.source = "commonsUI_json.commonsUI_btn_close";
		t.visible = true;
		t.width = 40;
		t.x = 478;
		t.y = 0;
		return t;
	};
	return RewardShowSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/roleListUI/render/RoleHeroRenderSkin.exml'] = window.RoleHeroRenderSkin = (function (_super) {
	__extends(RoleHeroRenderSkin, _super);
	function RoleHeroRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgQuailty","u_heroIcon","u_txtStar","u_grpStar","u_txtName","u_txtPath","u_imgJinduBg","u_imgJindu","u_txtJindu","u_grpJindu","u_itemIcon","u_grpItem","u_imgRed","u_imgSelect","u_imgLock"];
		
		this.height = 308;
		this.width = 195;
		this.elementsContent = [this.u_imgQuailty_i(),this.u_heroIcon_i(),this._Image1_i(),this.u_grpStar_i(),this.u_txtName_i(),this.u_txtPath_i(),this.u_grpItem_i(),this.u_imgRed_i(),this.u_imgSelect_i(),this.u_imgLock_i()];
	}
	var _proto = RoleHeroRenderSkin.prototype;

	_proto.u_imgQuailty_i = function () {
		var t = new eui.Image();
		this.u_imgQuailty = t;
		t.source = "roleListUI_json.roleListUI_quailty4";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_heroIcon_i = function () {
		var t = new eui.Image();
		this.u_heroIcon = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.x = 98;
		t.y = 0;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.bottom = 6;
		t.horizontalCenter = 0;
		t.source = "roleListUI_json.roleListUI_hero_mask";
		return t;
	};
	_proto.u_grpStar_i = function () {
		var t = new eui.Group();
		this.u_grpStar = t;
		t.horizontalCenter = 0;
		t.visible = true;
		t.x = 81;
		t.y = 211;
		t.elementsContent = [this._Image2_i(),this.u_txtStar_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "commonUI_json.commonUI_star_2";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtStar_i = function () {
		var t = new eui.Label();
		this.u_txtStar = t;
		t.bold = true;
		t.size = 18;
		t.text = "5";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.visible = true;
		t.x = 22;
		t.y = 3;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.horizontalCenter = 0.5;
		t.size = 16;
		t.stroke = 2;
		t.text = "角色名称";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 66;
		t.y = 245;
		return t;
	};
	_proto.u_txtPath_i = function () {
		var t = new eui.Label();
		this.u_txtPath = t;
		t.height = 44;
		t.horizontalCenter = 0;
		t.lineSpacing = 12;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 16;
		t.stroke = 2;
		t.text = "获取途径";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.visible = true;
		t.width = 155;
		t.y = 258;
		return t;
	};
	_proto.u_grpItem_i = function () {
		var t = new eui.Group();
		this.u_grpItem = t;
		t.height = 30;
		t.visible = true;
		t.x = 0;
		t.y = 278;
		t.elementsContent = [this.u_grpJindu_i(),this.u_itemIcon_i()];
		return t;
	};
	_proto.u_grpJindu_i = function () {
		var t = new eui.Group();
		this.u_grpJindu = t;
		t.visible = true;
		t.x = 0;
		t.elementsContent = [this.u_imgJinduBg_i(),this.u_imgJindu_i(),this.u_txtJindu_i()];
		return t;
	};
	_proto.u_imgJinduBg_i = function () {
		var t = new eui.Image();
		this.u_imgJinduBg = t;
		t.scale9Grid = new egret.Rectangle(65,10,65,4);
		t.source = "commonUI_json.commonUI_jindu_5";
		t.visible = true;
		t.width = 195;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgJindu_i = function () {
		var t = new eui.Image();
		this.u_imgJindu = t;
		t.scale9Grid = new egret.Rectangle(49,5,35,4);
		t.source = "commonUI_json.commonUI_jindu_6";
		t.visible = true;
		t.width = 179;
		t.x = 8;
		t.y = 5;
		return t;
	};
	_proto.u_txtJindu_i = function () {
		var t = new eui.Label();
		this.u_txtJindu = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.stroke = 2;
		t.text = "Max";
		t.textColor = 0xF0E4B0;
		t.verticalCenter = -2;
		t.visible = true;
		return t;
	};
	_proto.u_itemIcon_i = function () {
		var t = new eui.Image();
		this.u_itemIcon = t;
		t.height = 32;
		t.source = "roleListUI_json.roleListUI_icon_sp";
		t.visible = true;
		t.width = 34;
		t.x = 0;
		t.y = -5;
		return t;
	};
	_proto.u_imgRed_i = function () {
		var t = new eui.Image();
		this.u_imgRed = t;
		t.source = "commonUI_json.commonUI_red";
		t.visible = true;
		t.x = 169;
		t.y = 7;
		return t;
	};
	_proto.u_imgSelect_i = function () {
		var t = new eui.Image();
		this.u_imgSelect = t;
		t.source = "roleListUI_json.roleListUI_icon_equipped";
		t.visible = true;
		t.x = 12;
		t.y = 10;
		return t;
	};
	_proto.u_imgLock_i = function () {
		var t = new eui.Image();
		this.u_imgLock = t;
		t.horizontalCenter = 0;
		t.source = "roleListUI_json.roleListUI_icon_suo";
		t.verticalCenter = 0;
		t.visible = true;
		t.x = 83;
		t.y = 135;
		return t;
	};
	return RoleHeroRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/roleListUI/render/RoleSortRenderSkin.exml'] = window.RoleSortRenderSkin = (function (_super) {
	__extends(RoleSortRenderSkin, _super);
	function RoleSortRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtName","u_imgLine","u_btnClick"];
		
		this.height = 48;
		this.width = 148;
		this.elementsContent = [this.u_txtName_i(),this.u_imgLine_i(),this.u_btnClick_i()];
	}
	var _proto = RoleSortRenderSkin.prototype;

	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "英雄星级";
		t.textColor = 0xA5A5A5;
		t.touchEnabled = false;
		t.visible = true;
		t.y = 9;
		return t;
	};
	_proto.u_imgLine_i = function () {
		var t = new eui.Image();
		this.u_imgLine = t;
		t.source = "roleListUI_json.roleListUI_line";
		t.visible = true;
		t.width = 148;
		t.x = 0;
		t.y = 46;
		return t;
	};
	_proto.u_btnClick_i = function () {
		var t = new eui.Image();
		this.u_btnClick = t;
		t.alpha = 0;
		t.height = 48;
		t.source = "commonUI_json.commonUI_box";
		t.width = 148;
		return t;
	};
	return RoleSortRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/roleListUI/RoleListUISkin.exml'] = window.RoleListUISkin = (function (_super) {
	__extends(RoleListUISkin, _super);
	function RoleListUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_txtOwned","u_listItem","u_scrollerItem","u_imgArrow","u_txtSortMsg","u_btnSort","u_sortListBg","u_sortList","u_grpSort"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_imgBg_i(),this._Image1_i(),this.u_txtOwned_i(),this.u_scrollerItem_i(),this._Group2_i()];
	}
	var _proto = RoleListUISkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.source = "roleListUI_json.roleListUI_bg";
		t.visible = true;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "roleListUI_json.roleListUI_icon_yx";
		t.visible = true;
		t.x = 50;
		t.y = 70;
		return t;
	};
	_proto.u_txtOwned_i = function () {
		var t = new eui.Label();
		this.u_txtOwned = t;
		t.bold = true;
		t.size = 18;
		t.text = "4/12";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.visible = true;
		t.x = 84;
		t.y = 73;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 533;
		t.visible = true;
		t.width = 1043;
		t.x = 48;
		t.y = 107;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.visible = true;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.height = 32;
		t.x = 899;
		t.y = 55;
		t.elementsContent = [this.u_btnSort_i(),this.u_grpSort_i()];
		return t;
	};
	_proto.u_btnSort_i = function () {
		var t = new eui.Group();
		this.u_btnSort = t;
		t.height = 32;
		t.width = 187;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image2_i(),this.u_imgArrow_i(),this.u_txtSortMsg_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "roleListUI_json.roleListUI_order_bg2";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgArrow_i = function () {
		var t = new eui.Image();
		this.u_imgArrow = t;
		t.horizontalCenter = 74.5;
		t.scaleY = 1;
		t.source = "roleListUI_json.roleListUI_icon_arrow";
		t.verticalCenter = -0.5;
		t.visible = true;
		return t;
	};
	_proto.u_txtSortMsg_i = function () {
		var t = new eui.Label();
		this.u_txtSortMsg = t;
		t.size = 16;
		t.text = "排序";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.verticalCenter = 1;
		t.visible = true;
		t.x = 36;
		return t;
	};
	_proto.u_grpSort_i = function () {
		var t = new eui.Group();
		this.u_grpSort = t;
		t.visible = true;
		t.x = 0;
		t.y = 31;
		t.elementsContent = [this.u_sortListBg_i(),this.u_sortList_i()];
		return t;
	};
	_proto.u_sortListBg_i = function () {
		var t = new eui.Image();
		this.u_sortListBg = t;
		t.height = 185;
		t.scale9Grid = new egret.Rectangle(21,21,22,22);
		t.source = "roleListUI_json.roleListUI_order_bg1";
		t.visible = true;
		t.width = 187;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_sortList_i = function () {
		var t = new eui.List();
		this.u_sortList = t;
		t.width = 148;
		t.x = 20;
		t.y = 15;
		return t;
	};
	return RoleListUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/roleUI/popup/RoleDescPopupSkin.exml'] = window.RoleDescPopupSkin = (function (_super) {
	__extends(RoleDescPopupSkin, _super);
	function RoleDescPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtHeroName","u_txtMsg","u_scrollerItem","u_txtBlank"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_txtHeroName_i(),this.u_scrollerItem_i(),this.u_txtBlank_i()];
	}
	var _proto = RoleDescPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 460;
		t.scale9Grid = new egret.Rectangle(31,27,6,7);
		t.source = "roleUI_json.roleUI_popup_bg";
		t.visible = true;
		t.width = 916;
		t.x = 110;
		t.y = 63;
		return t;
	};
	_proto.u_txtHeroName_i = function () {
		var t = new eui.Label();
		this.u_txtHeroName = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.stroke = 2;
		t.text = "孙悟空";
		t.textColor = 0xFFE062;
		t.visible = true;
		t.y = 85;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 340;
		t.horizontalCenter = 0;
		t.width = 870;
		t.y = 126;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 59;
		t.elementsContent = [this.u_txtMsg_i()];
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.lineSpacing = 18;
		t.size = 16;
		t.stroke = 1;
		t.strokeColor = 0x453A32;
		t.text = "孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空孙悟空";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.width = 870;
		t.wordWrap = true;
		t.x = 0;
		t.y = 10;
		return t;
	};
	_proto.u_txtBlank_i = function () {
		var t = new eui.Label();
		this.u_txtBlank = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.stroke = 2;
		t.text = "点击空白处关闭窗口";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.visible = true;
		t.y = 569;
		return t;
	};
	return RoleDescPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/roleUI/popup/RoleVideoPopupSkin.exml'] = window.RoleVideoPopupSkin = (function (_super) {
	__extends(RoleVideoPopupSkin, _super);
	function RoleVideoPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_imgPlay","u_btnPlay","u_txtBlank"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_btnPlay_i(),this.u_txtBlank_i()];
	}
	var _proto = RoleVideoPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 316;
		t.scale9Grid = new egret.Rectangle(31,27,6,7);
		t.source = "roleUI_json.roleUI_popup_bg";
		t.visible = true;
		t.width = 596;
		t.x = 269;
		t.y = 164;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 290;
		t.scale9Grid = new egret.Rectangle(3,3,4,4);
		t.source = "commonUI_json.commonUI_box";
		t.visible = true;
		t.width = 570;
		t.x = 283;
		t.y = 175;
		return t;
	};
	_proto.u_btnPlay_i = function () {
		var t = new eui.Group();
		this.u_btnPlay = t;
		t.visible = true;
		t.x = 283;
		t.y = 175;
		t.elementsContent = [this._Image3_i(),this.u_imgPlay_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.alpha = 0;
		t.height = 290;
		t.scale9Grid = new egret.Rectangle(3,3,4,4);
		t.source = "commonUI_json.commonUI_box";
		t.visible = true;
		t.width = 570;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgPlay_i = function () {
		var t = new eui.Image();
		this.u_imgPlay = t;
		t.source = "roleUI_json.roleUI_play";
		t.visible = true;
		t.x = 248;
		t.y = 108;
		return t;
	};
	_proto.u_txtBlank_i = function () {
		var t = new eui.Label();
		this.u_txtBlank = t;
		t.horizontalCenter = 0;
		t.size = 16;
		t.stroke = 2;
		t.text = "点击空白处关闭窗口";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.visible = true;
		t.y = 503;
		return t;
	};
	return RoleVideoPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/roleUI/render/RoleWeapRenderSkin.exml'] = window.RoleWeapTipSkin = (function (_super) {
	__extends(RoleWeapTipSkin, _super);
	function RoleWeapTipSkin() {
		_super.call(this);
		this.skinParts = ["u_imgSelect","u_imgIcon","u_imgLock","u_txtName","u_txtDesc","u_btnClick"];
		
		this.height = 146;
		this.width = 230;
		this.elementsContent = [this.u_imgSelect_i(),this.u_imgIcon_i(),this.u_imgLock_i(),this.u_txtName_i(),this.u_txtDesc_i(),this.u_btnClick_i()];
	}
	var _proto = RoleWeapTipSkin.prototype;

	_proto.u_imgSelect_i = function () {
		var t = new eui.Image();
		this.u_imgSelect = t;
		t.source = "roleUI_json.roleUI_select1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 70;
		t.width = 70;
		t.x = 82;
		t.y = 25;
		return t;
	};
	_proto.u_imgLock_i = function () {
		var t = new eui.Image();
		this.u_imgLock = t;
		t.source = "roleUI_json.roleUI_lock";
		t.visible = true;
		t.x = 102;
		t.y = 33;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.horizontalCenter = 3;
		t.size = 16;
		t.text = "技能名";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 94;
		t.y = 107;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.lineSpacing = 7;
		t.size = 16;
		t.text = "技能名技能名技能名技能名技能名";
		t.textAlign = "center";
		t.textColor = 0xA5A5A5;
		t.visible = true;
		t.width = 200;
		t.x = 15;
		t.y = 98;
		return t;
	};
	_proto.u_btnClick_i = function () {
		var t = new eui.Image();
		this.u_btnClick = t;
		t.alpha = 0;
		t.height = 146;
		t.source = "commonUI_json.commonUI_box";
		t.visible = true;
		t.width = 230;
		return t;
	};
	return RoleWeapTipSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/roleUI/RoleUISkin.exml'] = window.RoleUISkin = (function (_super) {
	__extends(RoleUISkin, _super);
	function RoleUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_imgMask","u_imgQuailty","u_btnTips","u_txtHeroName","u_imgBiSha","u_imgBiShaPlay","u_imgBiShaLock","u_btnBisha","u_txtBisha","u_scrollerIBisha","u_txtSure","u_btnSure","u_tipsBg","u_txtTips","u_grpPath","u_mcLeft","u_btnLeft","u_btnRight","u_imgJinduBg","u_imgJindu","u_txtJindu","u_itemIcon","u_grpItem","u_txtUp","u_btnUp","u_mcMid","u_btnWeap","u_btnDesign","u_mcRight"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_imgBg_i(),this.u_imgMask_i(),this.u_mcLeft_i(),this.u_mcMid_i(),this.u_mcRight_i()];
	}
	var _proto = RoleUISkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.source = "roleUI_json.roleUI_bg";
		t.visible = true;
		return t;
	};
	_proto.u_imgMask_i = function () {
		var t = new eui.Image();
		this.u_imgMask = t;
		t.bottom = 0;
		t.scale9Grid = new egret.Rectangle(61,33,61,33);
		t.source = "roleUI_json.roleUI_mask";
		t.visible = true;
		t.width = 1136;
		return t;
	};
	_proto.u_mcLeft_i = function () {
		var t = new eui.Group();
		this.u_mcLeft = t;
		t.visible = true;
		t.x = 36;
		t.y = 141;
		t.elementsContent = [this._Group1_i(),this._Image1_i(),this.u_btnBisha_i(),this.u_scrollerIBisha_i(),this.u_btnSure_i(),this.u_grpPath_i()];
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.visible = true;
		t.x = 4;
		t.y = 0;
		t.elementsContent = [this.u_imgQuailty_i(),this.u_btnTips_i(),this.u_txtHeroName_i()];
		return t;
	};
	_proto.u_imgQuailty_i = function () {
		var t = new eui.Image();
		this.u_imgQuailty = t;
		t.source = "roleUI_json.roleUI_quality_3";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnTips_i = function () {
		var t = new eui.Image();
		this.u_btnTips = t;
		t.height = 26;
		t.source = "roleUI_json.roleUI_btn_tips";
		t.visible = true;
		t.width = 26;
		t.x = 186;
		t.y = 6;
		return t;
	};
	_proto.u_txtHeroName_i = function () {
		var t = new eui.Label();
		this.u_txtHeroName = t;
		t.bold = true;
		t.horizontalCenter = -18;
		t.size = 18;
		t.stroke = 2;
		t.text = "雷霆式神·雷震子雷";
		t.textColor = 0xFFFFFF;
		t.visible = true;
		t.y = 10;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 254;
		t.scale9Grid = new egret.Rectangle(26,28,12,11);
		t.source = "roleUI_json.roleUI_video_bg1";
		t.visible = true;
		t.width = 210;
		t.x = 4;
		t.y = 52;
		return t;
	};
	_proto.u_btnBisha_i = function () {
		var t = new eui.Group();
		this.u_btnBisha = t;
		t.height = 128;
		t.width = 208;
		t.x = 5;
		t.y = 56;
		t.elementsContent = [this._Image2_i(),this.u_imgBiSha_i(),this.u_imgBiShaPlay_i(),this.u_imgBiShaLock_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 128;
		t.scale9Grid = new egret.Rectangle(69,43,70,42);
		t.source = "roleUI_json.roleUI_video_bg2";
		t.visible = true;
		t.width = 208;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgBiSha_i = function () {
		var t = new eui.Image();
		this.u_imgBiSha = t;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(69,43,70,42);
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_imgBiShaPlay_i = function () {
		var t = new eui.Image();
		this.u_imgBiShaPlay = t;
		t.horizontalCenter = 5;
		t.source = "roleUI_json.roleUI_play";
		t.verticalCenter = -2.5;
		t.visible = true;
		return t;
	};
	_proto.u_imgBiShaLock_i = function () {
		var t = new eui.Image();
		this.u_imgBiShaLock = t;
		t.horizontalCenter = 0;
		t.source = "roleUI_json.roleUI_lock";
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_scrollerIBisha_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerIBisha = t;
		t.height = 110;
		t.visible = true;
		t.width = 180;
		t.x = 19;
		t.y = 188;
		t.viewport = this._Group2_i();
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.x = 59;
		t.elementsContent = [this.u_txtBisha_i()];
		return t;
	};
	_proto.u_txtBisha_i = function () {
		var t = new eui.Label();
		this.u_txtBisha = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.lineSpacing = 12;
		t.size = 16;
		t.strokeColor = 0x000000;
		t.text = "必杀：释放剑气，对一定范围";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.width = 180;
		t.wordWrap = true;
		t.x = 0;
		t.y = 3;
		return t;
	};
	_proto.u_btnSure_i = function () {
		var t = new eui.Group();
		this.u_btnSure = t;
		t.height = 58;
		t.visible = true;
		t.width = 218;
		t.x = 0;
		t.y = 329;
		t.elementsContent = [this._Image3_i(),this.u_txtSure_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "roleUI_json.roleUI_btn_Bg";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtSure_i = function () {
		var t = new eui.Label();
		this.u_txtSure = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "选 择";
		t.textColor = 0xF0E4B0;
		t.verticalCenter = -1;
		t.visible = true;
		return t;
	};
	_proto.u_grpPath_i = function () {
		var t = new eui.Group();
		this.u_grpPath = t;
		t.height = 58;
		t.visible = true;
		t.width = 218;
		t.x = 0;
		t.y = 329;
		t.elementsContent = [this.u_tipsBg_i(),this.u_txtTips_i(),this._Image4_i()];
		return t;
	};
	_proto.u_tipsBg_i = function () {
		var t = new eui.Image();
		this.u_tipsBg = t;
		t.scale9Grid = new egret.Rectangle(15,12,4,11);
		t.source = "roleUI_json.roleUI_btn_Bg";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtTips_i = function () {
		var t = new eui.Label();
		this.u_txtTips = t;
		t.bold = true;
		t.lineSpacing = 8;
		t.size = 16;
		t.text = "夺宝活动有机会动有机会";
		t.textAlign = "center";
		t.textColor = 0xE9DDAB;
		t.verticalCenter = -2;
		t.visible = true;
		t.width = 145;
		t.wordWrap = true;
		t.x = 61;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "roleUI_json.roleUI_lock";
		t.verticalCenter = -1.5;
		t.visible = true;
		t.x = 24;
		return t;
	};
	_proto.u_mcMid_i = function () {
		var t = new eui.Group();
		this.u_mcMid = t;
		t.visible = true;
		t.x = 324;
		t.y = 440;
		t.elementsContent = [this._Group3_i(),this.u_grpItem_i(),this.u_btnUp_i()];
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.visible = true;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this.u_btnLeft_i(),this.u_btnRight_i()];
		return t;
	};
	_proto.u_btnLeft_i = function () {
		var t = new eui.Image();
		this.u_btnLeft = t;
		t.height = 38;
		t.source = "roleUI_json.roleUI_arrow";
		t.width = 25;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnRight_i = function () {
		var t = new eui.Image();
		this.u_btnRight = t;
		t.height = 38;
		t.scaleX = -1;
		t.source = "roleUI_json.roleUI_arrow";
		t.visible = true;
		t.width = 25;
		t.x = 489;
		t.y = 0;
		return t;
	};
	_proto.u_grpItem_i = function () {
		var t = new eui.Group();
		this.u_grpItem = t;
		t.visible = true;
		t.x = 125;
		t.y = 128;
		t.elementsContent = [this._Group4_i(),this.u_itemIcon_i()];
		return t;
	};
	_proto._Group4_i = function () {
		var t = new eui.Group();
		t.x = 21;
		t.y = 5;
		t.elementsContent = [this.u_imgJinduBg_i(),this.u_imgJindu_i(),this.u_txtJindu_i()];
		return t;
	};
	_proto.u_imgJinduBg_i = function () {
		var t = new eui.Image();
		this.u_imgJinduBg = t;
		t.scale9Grid = new egret.Rectangle(65,10,65,7);
		t.source = "commonUI_json.commonUI_jindu_5";
		t.visible = true;
		t.width = 198;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgJindu_i = function () {
		var t = new eui.Image();
		this.u_imgJindu = t;
		t.scale9Grid = new egret.Rectangle(49,5,47,4);
		t.source = "commonUI_json.commonUI_jindu_6";
		t.visible = true;
		t.width = 184;
		t.x = 7;
		t.y = 5;
		return t;
	};
	_proto.u_txtJindu_i = function () {
		var t = new eui.Label();
		this.u_txtJindu = t;
		t.bold = true;
		t.horizontalCenter = -3.5;
		t.size = 16;
		t.stroke = 2;
		t.strokeColor = 0x000000;
		t.text = "90/100";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 5;
		return t;
	};
	_proto.u_itemIcon_i = function () {
		var t = new eui.Image();
		this.u_itemIcon = t;
		t.height = 32;
		t.source = "roleUI_json.roleUI_item_icon";
		t.visible = true;
		t.width = 34;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnUp_i = function () {
		var t = new eui.Group();
		this.u_btnUp = t;
		t.height = 58;
		t.visible = true;
		t.width = 138;
		t.x = 175;
		t.y = 128;
		t.elementsContent = [this._Image5_i(),this.u_txtUp_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "roleUI_json.roleUI_btn_star";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtUp_i = function () {
		var t = new eui.Label();
		this.u_txtUp = t;
		t.bold = true;
		t.horizontalCenter = 1;
		t.size = 20;
		t.text = "升 星";
		t.textColor = 0xFFF7D2;
		t.verticalCenter = -2;
		t.visible = true;
		return t;
	};
	_proto.u_mcRight_i = function () {
		var t = new eui.Group();
		this.u_mcRight = t;
		t.visible = true;
		t.x = 1019;
		t.y = 239;
		t.elementsContent = [this.u_btnWeap_i(),this.u_btnDesign_i()];
		return t;
	};
	_proto.u_btnWeap_i = function () {
		var t = new eui.Image();
		this.u_btnWeap = t;
		t.height = 78;
		t.source = "roleUI_json.roleUI_pic_wq";
		t.visible = true;
		t.width = 78;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnDesign_i = function () {
		var t = new eui.Image();
		this.u_btnDesign = t;
		t.height = 78;
		t.source = "roleUI_json.roleUI_pic_zs";
		t.visible = true;
		t.width = 78;
		t.x = 0;
		t.y = 118;
		return t;
	};
	return RoleUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/roleUI/view/RoleWeapViewSkin.exml'] = window.RoleWeapViewSkin = (function (_super) {
	__extends(RoleWeapViewSkin, _super);
	function RoleWeapViewSkin() {
		_super.call(this);
		this.skinParts = ["u_txtWeapon","u_btnClose","u_iconSelect1","u_imgSelect1","u_btnSelect1","u_iconSelect2","u_imgSelect2","u_btnSelect2","u_weapList","u_weapScroller","u_grpPart"];
		
		this.height = 640;
		this.width = 301;
		this.elementsContent = [this.u_grpPart_i()];
	}
	var _proto = RoleWeapViewSkin.prototype;

	_proto.u_grpPart_i = function () {
		var t = new eui.Group();
		this.u_grpPart = t;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtWeapon_i(),this.u_btnClose_i(),this.u_btnSelect1_i(),this.u_btnSelect2_i(),this.u_weapScroller_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "roleUI_json.roleUI_part_bg";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "roleUI_json.roleUI_icon_bt";
		t.visible = true;
		t.x = 16;
		t.y = 24;
		return t;
	};
	_proto.u_txtWeapon_i = function () {
		var t = new eui.Label();
		this.u_txtWeapon = t;
		t.bold = true;
		t.size = 16;
		t.text = "武器/装饰";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 57;
		t.y = 29;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 16;
		t.source = "roleUI_json.roleUI_close";
		t.visible = true;
		t.width = 16;
		t.x = 264;
		t.y = 29;
		return t;
	};
	_proto.u_btnSelect1_i = function () {
		var t = new eui.Group();
		this.u_btnSelect1 = t;
		t.x = 229;
		t.y = 71;
		t.elementsContent = [this.u_iconSelect1_i(),this.u_imgSelect1_i()];
		return t;
	};
	_proto.u_iconSelect1_i = function () {
		var t = new eui.Image();
		this.u_iconSelect1 = t;
		t.source = "roleUI_json.roleUI_select2";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgSelect1_i = function () {
		var t = new eui.Image();
		this.u_imgSelect1 = t;
		t.source = "roleUI_json.roleUI_btn_wq2";
		t.visible = true;
		t.x = 12;
		t.y = 127;
		return t;
	};
	_proto.u_btnSelect2_i = function () {
		var t = new eui.Group();
		this.u_btnSelect2 = t;
		t.x = 229;
		t.y = 356;
		t.elementsContent = [this.u_iconSelect2_i(),this.u_imgSelect2_i()];
		return t;
	};
	_proto.u_iconSelect2_i = function () {
		var t = new eui.Image();
		this.u_iconSelect2 = t;
		t.source = "roleUI_json.roleUI_select2";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgSelect2_i = function () {
		var t = new eui.Image();
		this.u_imgSelect2 = t;
		t.source = "roleUI_json.roleUI_btn_zs2";
		t.visible = true;
		t.x = 12;
		t.y = 128;
		return t;
	};
	_proto.u_weapScroller_i = function () {
		var t = new eui.Scroller();
		this.u_weapScroller = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 568;
		t.visible = true;
		t.width = 230;
		t.x = 0;
		t.y = 72;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_weapList_i()];
		return t;
	};
	_proto.u_weapList_i = function () {
		var t = new eui.List();
		this.u_weapList = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return RoleWeapViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/rotaryTableUI/RotaryTableSkin.exml'] = window.RotaryTableSkin = (function (_super) {
	__extends(RotaryTableSkin, _super);
	function RotaryTableSkin() {
		_super.call(this);
		this.skinParts = ["u_gpZhuan","u_btnStart"];
		
		this.height = 640;
		this.width = 1134;
		this.elementsContent = [this._Group1_i()];
	}
	var _proto = RotaryTableSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.alpha = 1;
		t.anchorOffsetX = 272;
		t.anchorOffsetY = 252;
		t.bottom = 98;
		t.left = 272;
		t.right = 334;
		t.top = 55;
		t.elementsContent = [this._Image1_i(),this.u_gpZhuan_i(),this._Image3_i(),this.u_btnStart_i(),this._Image4_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "rotaryTableUI_json.rotaryTableUI_bg1";
		t.x = 88.69;
		t.y = 62.21;
		return t;
	};
	_proto.u_gpZhuan_i = function () {
		var t = new eui.Group();
		this.u_gpZhuan = t;
		t.anchorOffsetX = 157.5;
		t.anchorOffsetY = 157.5;
		t.height = 315;
		t.width = 315;
		t.x = 278.05;
		t.y = 256;
		t.elementsContent = [this._Rect1_i(),this._Image2_i(),this._Rect2_i()];
		return t;
	};
	_proto._Rect1_i = function () {
		var t = new eui.Rect();
		t.height = 1;
		t.width = 1;
		t.x = 157.5;
		t.y = 157.5;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.alpha = 1;
		t.source = "rotaryTableUI_json.rotaryTableUI_part4";
		t.x = 1;
		t.y = 9;
		return t;
	};
	_proto._Rect2_i = function () {
		var t = new eui.Rect();
		t.anchorOffsetX = 4;
		t.anchorOffsetY = 117.5;
		t.height = 118.5;
		t.rotation = 349.32;
		t.visible = false;
		t.width = 7;
		t.x = 156;
		t.y = 155;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "rotaryTableUI_json.rotaryTableUI_part2";
		t.x = 123.65;
		t.y = 92.98;
		return t;
	};
	_proto.u_btnStart_i = function () {
		var t = new eui.Image();
		this.u_btnStart = t;
		t.anchorOffsetX = 58;
		t.anchorOffsetY = 50;
		t.source = "rotaryTableUI_json.rotaryTableUI_bt1";
		t.x = 276.98;
		t.y = 252.69;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "rotaryTableUI_json.rotaryTableUI_part3";
		t.x = 225.12;
		t.y = 63.2;
		return t;
	};
	return RotaryTableSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/sceneSelectUI/render/SceneSelectRenderSkin.exml'] = window.SceneSelectRenderSkin = (function (_super) {
	__extends(SceneSelectRenderSkin, _super);
	function SceneSelectRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBj","u_imgMonster","u_imgShow","u_imgName","u_btnClick","u_imgIcon1","u_imgIcon2","u_imgIcon3","u_btnMore"];
		
		this.height = 405;
		this.width = 314;
		this.elementsContent = [this.u_btnClick_i(),this._Image1_i(),this._Image2_i(),this._Image3_i(),this._Image4_i(),this._Image5_i(),this.u_imgIcon1_i(),this.u_imgIcon2_i(),this.u_imgIcon3_i(),this.u_btnMore_i()];
	}
	var _proto = SceneSelectRenderSkin.prototype;

	_proto.u_btnClick_i = function () {
		var t = new eui.Group();
		this.u_btnClick = t;
		t.height = 270;
		t.width = 251;
		t.x = 43;
		t.y = 65;
		t.elementsContent = [this.u_imgBj_i(),this.u_imgMonster_i(),this.u_imgShow_i(),this.u_imgName_i()];
		return t;
	};
	_proto.u_imgBj_i = function () {
		var t = new eui.Image();
		this.u_imgBj = t;
		t.source = "sceneSelectUI_json.sceneSelectUI_bj";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgMonster_i = function () {
		var t = new eui.Image();
		this.u_imgMonster = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "sceneSelectUI_json.sceneSelectUI_img";
		t.x = -26;
		t.y = -67;
		return t;
	};
	_proto.u_imgShow_i = function () {
		var t = new eui.Image();
		this.u_imgShow = t;
		t.source = "sceneSelectUI_json.sceneSelectUI_show";
		t.x = -38;
		t.y = 158;
		return t;
	};
	_proto.u_imgName_i = function () {
		var t = new eui.Image();
		this.u_imgName = t;
		t.horizontalCenter = -15;
		t.source = "sceneSelectUI_json.sceneSelectUI_name";
		t.y = 206;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "sceneSelectUI_json.sceneSelectUI_icon_bg";
		t.x = 37.032;
		t.y = 345.111;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "sceneSelectUI_json.sceneSelectUI_icon_bg";
		t.x = 100.33333333333333;
		t.y = 345.111;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "sceneSelectUI_json.sceneSelectUI_icon_bg";
		t.x = 163.95266666666666;
		t.y = 345.111;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "sceneSelectUI_json.sceneSelectUI_icon_bg";
		t.visible = true;
		t.x = 226.746;
		t.y = 345.111;
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "sceneSelectUI_json.sceneSelectUI_more";
		t.visible = true;
		t.x = 227.254;
		t.y = 344.873;
		return t;
	};
	_proto.u_imgIcon1_i = function () {
		var t = new eui.Image();
		this.u_imgIcon1 = t;
		t.height = 50;
		t.source = "sceneSelectUI_json.sceneSelectUI_icon_bg";
		t.width = 50;
		t.x = 38.302;
		t.y = 345.508;
		return t;
	};
	_proto.u_imgIcon2_i = function () {
		var t = new eui.Image();
		this.u_imgIcon2 = t;
		t.height = 50;
		t.source = "sceneSelectUI_json.sceneSelectUI_icon_bg";
		t.width = 50;
		t.x = 101.603;
		t.y = 345.508;
		return t;
	};
	_proto.u_imgIcon3_i = function () {
		var t = new eui.Image();
		this.u_imgIcon3 = t;
		t.height = 50;
		t.source = "sceneSelectUI_json.sceneSelectUI_icon_bg";
		t.width = 50;
		t.x = 165.222;
		t.y = 345.508;
		return t;
	};
	_proto.u_btnMore_i = function () {
		var t = new eui.Image();
		this.u_btnMore = t;
		t.alpha = 0;
		t.source = "sceneSelectUI_json.sceneSelectUI_more";
		t.width = 240;
		t.x = 37.254;
		t.y = 344.873;
		return t;
	};
	return SceneSelectRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/sceneSelectUI/SceneSelectUISkin.exml'] = window.SceneSelectUISkin = (function (_super) {
	__extends(SceneSelectUISkin, _super);
	function SceneSelectUISkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_scrollerItem"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_scrollerItem_i()];
	}
	var _proto = SceneSelectUISkin.prototype;

	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 405;
		t.verticalCenter = 0;
		t.width = 1131;
		t.x = 3;
		t.viewport = this.u_listItem_i();
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		return t;
	};
	return SceneSelectUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/sevenDaysUI/render/SevenDaysRenderSkin.exml'] = window.SevenDaysRenderSkin = (function (_super) {
	__extends(SevenDaysRenderSkin, _super);
	function SevenDaysRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_bgSelect","u_txtDay","u_awardLb","u_contentGrp","u_imgReceived"];
		
		this.height = 158;
		this.width = 103;
		this.elementsContent = [this.u_imgBg_i(),this.u_bgSelect_i(),this.u_contentGrp_i(),this.u_imgReceived_i()];
	}
	var _proto = SevenDaysRenderSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.bottom = 0;
		t.horizontalCenter = 0;
		t.source = "sevenDaysUI_json.sevenDaysUI_tab";
		t.visible = true;
		return t;
	};
	_proto.u_bgSelect_i = function () {
		var t = new eui.Image();
		this.u_bgSelect = t;
		t.height = 149;
		t.horizontalCenter = 0;
		t.source = "sevenDaysUI_json.sevenDaysUI_tab1";
		t.visible = false;
		t.width = 105;
		t.y = 0;
		return t;
	};
	_proto.u_contentGrp_i = function () {
		var t = new eui.Group();
		this.u_contentGrp = t;
		t.height = 120;
		t.horizontalCenter = 0.5;
		t.visible = true;
		t.width = 80;
		t.y = 22;
		t.elementsContent = [this.u_txtDay_i(),this.u_awardLb_i(),this._Image1_i()];
		return t;
	};
	_proto.u_txtDay_i = function () {
		var t = new eui.Label();
		this.u_txtDay = t;
		t.horizontalCenter = 0;
		t.size = 18;
		t.stroke = 2;
		t.strokeColor = 0x885A3C;
		t.text = "Day 7";
		t.textAlign = "center";
		t.textColor = 0xFFF6BB;
		t.visible = true;
		t.y = 0;
		return t;
	};
	_proto.u_awardLb_i = function () {
		var t = new eui.Label();
		this.u_awardLb = t;
		t.horizontalCenter = -0.5;
		t.size = 20;
		t.text = "1000";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.y = 25;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 70;
		t.width = 70;
		t.x = 4;
		t.y = 53;
		return t;
	};
	_proto.u_imgReceived_i = function () {
		var t = new eui.Image();
		this.u_imgReceived = t;
		t.height = 71;
		t.horizontalCenter = 0;
		t.source = "sevenDaysUI_json.sevenDaysUI_received";
		t.touchEnabled = false;
		t.visible = false;
		t.width = 90;
		t.y = 55;
		return t;
	};
	return SevenDaysRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/sevenDaysUI/render/SevenSlotRenderSkin.exml'] = window.SevenSlotRenderSkin = (function (_super) {
	__extends(SevenSlotRenderSkin, _super);
	function SevenSlotRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_img"];
		
		this.height = 64;
		this.width = 80;
		this.elementsContent = [this.u_img_i()];
	}
	var _proto = SevenSlotRenderSkin.prototype;

	_proto.u_img_i = function () {
		var t = new eui.Image();
		this.u_img = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 54;
		t.horizontalCenter = 0;
		t.source = "sevenDaysUI_json.sevenDaysUI_0";
		t.verticalCenter = 0;
		t.width = 53;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return SevenSlotRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/sevenDaysUI/SevenDaysUISkin.exml'] = window.SevenDaysUISkin = (function (_super) {
	__extends(SevenDaysUISkin, _super);
	var SevenDaysUISkin$Skin4 = 	(function (_super) {
		__extends(SevenDaysUISkin$Skin4, _super);
		function SevenDaysUISkin$Skin4() {
			_super.call(this);
			this.skinParts = ["labelDisplay"];
			
			this.elementsContent = [this._Image1_i(),this.labelDisplay_i()];
			this.states = [
				new eui.State ("up",
					[
					])
				,
				new eui.State ("down",
					[
						new eui.SetProperty("_Image1","source","sevenDaysUI_json.sevenDaysUI_btn_down")
					])
				,
				new eui.State ("disabled",
					[
					])
			];
		}
		var _proto = SevenDaysUISkin$Skin4.prototype;

		_proto._Image1_i = function () {
			var t = new eui.Image();
			this._Image1 = t;
			t.percentHeight = 100;
			t.source = "sevenDaysUI_json.sevenDaysUI_btn_up";
			t.percentWidth = 100;
			return t;
		};
		_proto.labelDisplay_i = function () {
			var t = new eui.Label();
			this.labelDisplay = t;
			t.horizontalCenter = 0;
			t.verticalCenter = 0;
			return t;
		};
		return SevenDaysUISkin$Skin4;
	})(eui.Skin);

	function SevenDaysUISkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_scrollerItem","u_slotGrp","u_awd0","u_awd1","u_awd2","u_startBtn"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_scrollerItem_i(),this.u_slotGrp_i(),this._Image2_i(),this._Label1_i(),this._Label2_i(),this.u_awd0_i(),this.u_awd1_i(),this.u_awd2_i(),this._Image3_i(),this.u_startBtn_i(),this._Label3_i()];
	}
	var _proto = SevenDaysUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.scale9Grid = new egret.Rectangle(26,27,27,27);
		t.source = "sevenDaysUI_json.sevenDaysUI_bg";
		t.visible = true;
		t.x = 187.819;
		t.y = 46.263;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 165;
		t.horizontalCenter = 72;
		t.visible = true;
		t.width = 721;
		t.y = 120.902;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_slotGrp_i = function () {
		var t = new eui.Group();
		this.u_slotGrp = t;
		t.height = 120;
		t.visible = true;
		t.width = 289.651;
		t.x = 552.209;
		t.y = 316;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 135;
		t.source = "sevenDaysUI_json.sevenDaysUI_mask";
		t.width = 319.357;
		t.x = 536.41;
		t.y = 306.659;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.anchorOffsetX = 0;
		t.bold = true;
		t.horizontalCenter = -154;
		t.size = 16;
		t.stroke = 0;
		t.strokeColor = 0xFFFFFF;
		t.text = "基本奖金";
		t.textAlign = "center";
		t.textColor = 0xFFF6BB;
		t.y = 468.054;
		return t;
	};
	_proto._Label2_i = function () {
		var t = new eui.Label();
		t.anchorOffsetX = 0;
		t.bold = true;
		t.horizontalCenter = 71;
		t.size = 16;
		t.stroke = 0;
		t.strokeColor = 0xFFFFFF;
		t.text = "VIP奖励";
		t.textAlign = "center";
		t.textColor = 0xFFF6BB;
		t.x = 253;
		t.y = 466.933;
		return t;
	};
	_proto.u_awd0_i = function () {
		var t = new NumberView();
		this.u_awd0 = t;
		t.height = 36;
		t.horizontalCenter = -154;
		t.verticalCenter = 189;
		t.width = 120;
		t.y = 477;
		return t;
	};
	_proto.u_awd1_i = function () {
		var t = new NumberView();
		this.u_awd1 = t;
		t.height = 36;
		t.horizontalCenter = 71;
		t.verticalCenter = 189;
		t.width = 120;
		t.y = 477;
		return t;
	};
	_proto.u_awd2_i = function () {
		var t = new NumberView();
		this.u_awd2 = t;
		t.height = 36;
		t.horizontalCenter = 293;
		t.verticalCenter = 189;
		t.width = 120;
		t.y = 477;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "sevenDaysUI_json.sevenDaysUI_hd";
		t.x = 347;
		t.y = 317;
		return t;
	};
	_proto.u_startBtn_i = function () {
		var t = new eui.Button();
		this.u_startBtn = t;
		t.x = 884;
		t.y = 295;
		t.skinName = SevenDaysUISkin$Skin4;
		return t;
	};
	_proto._Label3_i = function () {
		var t = new eui.Label();
		t.anchorOffsetX = 0;
		t.bold = true;
		t.horizontalCenter = 293;
		t.size = 16;
		t.stroke = 0;
		t.strokeColor = 0xFFFFFF;
		t.text = "合计";
		t.textAlign = "center";
		t.textColor = 0xFFF6BB;
		t.x = 263;
		t.y = 466.933;
		return t;
	};
	return SevenDaysUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/sevenDaysUI/view/SevenSlotViewSkin.exml'] = window.SevenSlotViewSkin = (function (_super) {
	__extends(SevenSlotViewSkin, _super);
	function SevenSlotViewSkin() {
		_super.call(this);
		this.skinParts = ["area","u_listItem","u_scroller"];
		
		this.height = 128;
		this.width = 90;
		this.elementsContent = [this.area_i(),this.u_scroller_i()];
		
		eui.Binding.$bindProperties(this, ["area"],[0],this.u_scroller,"mask");
	}
	var _proto = SevenSlotViewSkin.prototype;

	_proto.area_i = function () {
		var t = new eui.Rect();
		this.area = t;
		t.height = 128;
		t.horizontalCenter = 0;
		t.strokeAlpha = 1;
		t.verticalCenter = 0;
		t.percentWidth = 100;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_scroller_i = function () {
		var t = new eui.Scroller();
		this.u_scroller = t;
		t.bottom = -32;
		t.height = 448;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.visible = true;
		t.percentWidth = 100;
		t.x = 0;
		t.viewport = this.u_listItem_i();
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return SevenSlotViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shareUI/page/SharePageSkin.exml'] = window.SharePageSkin = (function (_super) {
	__extends(SharePageSkin, _super);
	function SharePageSkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_scrollerItem","u_btnTop","u_btnBottom","u_vScrollBar"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_scrollerItem_i(),this._Group2_i()];
	}
	var _proto = SharePageSkin.prototype;

	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 333.785;
		t.horizontalCenter = 17;
		t.visible = true;
		t.width = 747.663;
		t.y = 131.165;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.visible = true;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.visible = true;
		t.x = 174;
		t.y = 120;
		t.elementsContent = [this.u_btnTop_i(),this.u_btnBottom_i(),this.u_vScrollBar_i()];
		return t;
	};
	_proto.u_btnTop_i = function () {
		var t = new eui.Image();
		this.u_btnTop = t;
		t.height = 15;
		t.horizontalCenter = 0;
		t.source = "commonUI_json.commonUI_icon_jts";
		t.visible = true;
		t.width = 21;
		t.y = 5;
		return t;
	};
	_proto.u_btnBottom_i = function () {
		var t = new eui.Image();
		this.u_btnBottom = t;
		t.height = 15;
		t.horizontalCenter = 0;
		t.source = "commonUI_json.commonUI_icon_jtx";
		t.visible = true;
		t.width = 21;
		t.y = 345;
		return t;
	};
	_proto.u_vScrollBar_i = function () {
		var t = new eui.VScrollBar();
		this.u_vScrollBar = t;
		t.autoVisibility = false;
		t.height = 310;
		t.horizontalCenter = 0;
		t.skinName = "VScrollBarSkin";
		t.verticalCenter = 0;
		t.visible = true;
		t.width = 17;
		return t;
	};
	return SharePageSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shareUI/render/ShareRenderSkin.exml'] = window.ShareRenderSkin = (function (_super) {
	__extends(ShareRenderSkin, _super);
	function ShareRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtDesc","u_btnIcon","u_txtReceive","u_receiveRed","u_imgReceived","u_btnReceive"];
		
		this.height = 127;
		this.width = 730;
		this.elementsContent = [this._Image1_i(),this.u_txtDesc_i(),this.u_btnReceive_i()];
	}
	var _proto = ShareRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "shareUI_json.shareUI_linebg";
		t.verticalCenter = -0.5;
		t.visible = true;
		t.width = 730;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.bold = true;
		t.height = 42;
		t.lineSpacing = 5;
		t.right = 10;
		t.size = 18;
		t.text = "Successfully Successfully Successfully Successfully";
		t.textColor = 0x3F393C;
		t.visible = true;
		t.width = 230;
		t.wordWrap = true;
		t.y = 19;
		return t;
	};
	_proto.u_btnReceive_i = function () {
		var t = new eui.Group();
		this.u_btnReceive = t;
		t.bottom = 13;
		t.height = 45;
		t.right = 66;
		t.visible = true;
		t.width = 107;
		t.elementsContent = [this.u_btnIcon_i(),this.u_txtReceive_i(),this.u_receiveRed_i(),this.u_imgReceived_i()];
		return t;
	};
	_proto.u_btnIcon_i = function () {
		var t = new eui.Image();
		this.u_btnIcon = t;
		t.scale9Grid = new egret.Rectangle(64,22,2,21);
		t.source = "shareUI_json.shareUI_btn_klq";
		t.visible = true;
		t.width = 107;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtReceive_i = function () {
		var t = new eui.Label();
		this.u_txtReceive = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.height = 18;
		t.horizontalCenter = -3.5;
		t.size = 24;
		t.text = "Receive";
		t.textColor = 0x573118;
		t.verticalCenter = -2.5;
		t.visible = false;
		t.width = 84;
		return t;
	};
	_proto.u_receiveRed_i = function () {
		var t = new eui.Image();
		this.u_receiveRed = t;
		t.source = "commonUI_json.commonUI_red";
		t.x = 94;
		t.y = -4;
		return t;
	};
	_proto.u_imgReceived_i = function () {
		var t = new eui.Image();
		this.u_imgReceived = t;
		t.height = 58;
		t.source = "shareUI_json.shareUI_iconbg2";
		t.visible = true;
		t.width = 62;
		t.x = 21;
		t.y = -13;
		return t;
	};
	return ShareRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shareUI/ShareUISkin.exml'] = window.ShareUISkin = (function (_super) {
	__extends(ShareUISkin, _super);
	function ShareUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgCaise","u_btnShare"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_imgCaise_i(),this.u_btnShare_i()];
	}
	var _proto = ShareUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "shareUI_json.shareUI_bg";
		t.x = 126.169;
		t.y = 73.926;
		return t;
	};
	_proto.u_imgCaise_i = function () {
		var t = new eui.Image();
		this.u_imgCaise = t;
		t.source = "shareUI_json.shareUI_bg_zs";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 54.06;
		t.y = 56.456;
		return t;
	};
	_proto.u_btnShare_i = function () {
		var t = new eui.Image();
		this.u_btnShare = t;
		t.scale9Grid = new egret.Rectangle(64,22,2,21);
		t.source = "shareUI_json.shareUI_btn_yjfx";
		t.visible = true;
		t.x = 850;
		t.y = 448;
		return t;
	};
	return ShareUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shopHallUI/render/BuyPropRenderSkin.exml'] = window.BuyPropRenderSkin = (function (_super) {
	__extends(BuyPropRenderSkin, _super);
	function BuyPropRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgQuality","u_imgIcon","u_txtPropName","u_txtPropNum","u_imgBuyIcon","u_txtAmount","u_btnBuyProp"];
		
		this.height = 190;
		this.width = 150;
		this.elementsContent = [this.u_imgQuality_i(),this.u_btnBuyProp_i()];
	}
	var _proto = BuyPropRenderSkin.prototype;

	_proto.u_imgQuality_i = function () {
		var t = new eui.Image();
		this.u_imgQuality = t;
		t.height = 190;
		t.source = "shopHallUI_json.shopHallUI_img_2";
		t.width = 150;
		return t;
	};
	_proto.u_btnBuyProp_i = function () {
		var t = new eui.Group();
		this.u_btnBuyProp = t;
		t.height = 190;
		t.width = 150;
		t.elementsContent = [this.u_imgIcon_i(),this.u_txtPropName_i(),this.u_txtPropNum_i(),this._Group1_i()];
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 100;
		t.width = 100;
		t.x = 25;
		t.y = 29;
		return t;
	};
	_proto.u_txtPropName_i = function () {
		var t = new eui.Label();
		this.u_txtPropName = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 16;
		t.text = "道具名字";
		t.visible = false;
		t.y = 15;
		return t;
	};
	_proto.u_txtPropNum_i = function () {
		var t = new eui.Label();
		this.u_txtPropNum = t;
		t.height = 16;
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "道具数量";
		t.y = 135;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 2.5;
		t.scaleX = 1;
		t.scaleY = 1;
		t.x = 30.999999999999986;
		t.y = 159;
		t.elementsContent = [this.u_imgBuyIcon_i(),this.u_txtAmount_i()];
		return t;
	};
	_proto.u_imgBuyIcon_i = function () {
		var t = new eui.Image();
		this.u_imgBuyIcon = t;
		t.height = 22;
		t.width = 22;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtAmount_i = function () {
		var t = new eui.Label();
		this.u_txtAmount = t;
		t.fontFamily = "Microsoft YaHei";
		t.height = 22;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 18;
		t.text = "金币数量";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "bottom";
		t.x = 21;
		return t;
	};
	return BuyPropRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shopHallUI/render/CoinRenderSkin.exml'] = window.CoinRenderSkin = (function (_super) {
	__extends(CoinRenderSkin, _super);
	function CoinRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgIcon","u_txtBuyNum","u_txtExp","u_txtCash","u_btnBuyCoin"];
		
		this.height = 190;
		this.width = 150;
		this.elementsContent = [this._Image1_i(),this.u_btnBuyCoin_i()];
	}
	var _proto = CoinRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 190;
		t.source = "shopHallUI_json.shopHallUI_img_jbd";
		t.width = 150;
		return t;
	};
	_proto.u_btnBuyCoin_i = function () {
		var t = new eui.Group();
		this.u_btnBuyCoin = t;
		t.height = 190;
		t.width = 150;
		t.elementsContent = [this.u_imgIcon_i(),this.u_txtBuyNum_i(),this.u_txtExp_i(),this.u_txtCash_i()];
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 81;
		t.width = 111;
		t.x = 22;
		t.y = 22;
		return t;
	};
	_proto.u_txtBuyNum_i = function () {
		var t = new eui.Label();
		this.u_txtBuyNum = t;
		t.height = 17;
		t.horizontalCenter = 2.5;
		t.size = 16;
		t.text = "num";
		t.textAlign = "center";
		t.width = 111;
		t.y = 107;
		return t;
	};
	_proto.u_txtExp_i = function () {
		var t = new eui.Label();
		this.u_txtExp = t;
		t.horizontalCenter = 2.5;
		t.size = 16;
		t.text = "VIP 经验 + ";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.width = 111;
		t.y = 129;
		return t;
	};
	_proto.u_txtCash_i = function () {
		var t = new eui.Label();
		this.u_txtCash = t;
		t.horizontalCenter = 1.5;
		t.size = 16;
		t.text = "$ 2";
		t.y = 162;
		return t;
	};
	return CoinRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shopHallUI/render/DianmondRenderSkin.exml'] = window.DianmondRenderSkin = (function (_super) {
	__extends(DianmondRenderSkin, _super);
	function DianmondRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgIcon","u_txtBuyNum","u_txtExp","u_txtCash","u_btnBuy"];
		
		this.height = 190;
		this.width = 150;
		this.elementsContent = [this._Image1_i(),this.u_btnBuy_i()];
	}
	var _proto = DianmondRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 190;
		t.source = "shopHallUI_json.shopHallUI_img_jbd";
		t.width = 150;
		return t;
	};
	_proto.u_btnBuy_i = function () {
		var t = new eui.Group();
		this.u_btnBuy = t;
		t.height = 190;
		t.width = 150;
		t.elementsContent = [this.u_imgIcon_i(),this.u_txtBuyNum_i(),this.u_txtExp_i(),this.u_txtCash_i()];
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 81;
		t.width = 111;
		t.x = 22;
		t.y = 22;
		return t;
	};
	_proto.u_txtBuyNum_i = function () {
		var t = new eui.Label();
		this.u_txtBuyNum = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.height = 22;
		t.horizontalCenter = 2.5;
		t.size = 24;
		t.text = "num";
		t.textAlign = "center";
		t.width = 111;
		t.y = 107;
		return t;
	};
	_proto.u_txtExp_i = function () {
		var t = new eui.Label();
		this.u_txtExp = t;
		t.fontFamily = "Microsoft YaHei";
		t.size = 16;
		t.text = "VIP 经验 + ";
		t.textAlign = "center";
		t.textColor = 0xF0C04C;
		t.verticalAlign = "middle";
		t.width = 111;
		t.x = 22;
		t.y = 135;
		return t;
	};
	_proto.u_txtCash_i = function () {
		var t = new eui.Label();
		this.u_txtCash = t;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 2;
		t.size = 18;
		t.text = "$2";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.y = 161.5;
		return t;
	};
	return DianmondRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shopHallUI/render/VipRenderSkin.exml'] = window.skins.VipRenderSkin = (function (_super) {
	__extends(VipRenderSkin, _super);
	function VipRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtawardName","u_imgIcon"];
		
		this.height = 150;
		this.width = 155;
		this.elementsContent = [this._Image1_i(),this.u_txtawardName_i(),this.u_imgIcon_i()];
	}
	var _proto = VipRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 150;
		t.source = "shopHallUI_json.shopHallUI_img_tqd";
		t.width = 155;
		return t;
	};
	_proto.u_txtawardName_i = function () {
		var t = new eui.Label();
		this.u_txtawardName = t;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 1;
		t.size = 18;
		t.text = "name";
		t.textColor = 0x5B2F00;
		t.y = 10;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.height = 100;
		t.width = 100;
		t.x = 29;
		t.y = 40;
		return t;
	};
	return VipRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shopHallUI/ShopHallUISkin.exml'] = window.ShopHallUISkin = (function (_super) {
	__extends(ShopHallUISkin, _super);
	function ShopHallUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_grpShopHall","u_rechargeScroll","u_imgBottom","u_img1","u_imgType1","u_btn1","u_img2","u_imgType2","u_btn2","u_imgType3","u_img3","u_btn3","u_imgType4","u_btn4","u_btnArray"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_imgBg_i(),this.u_rechargeScroll_i(),this.u_btnArray_i()];
	}
	var _proto = ShopHallUISkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.scale9Grid = new egret.Rectangle(23,23,24,24);
		t.visible = true;
		return t;
	};
	_proto.u_rechargeScroll_i = function () {
		var t = new eui.Scroller();
		this.u_rechargeScroll = t;
		t.height = 480;
		t.visible = true;
		t.width = 1116;
		t.x = 10;
		t.y = 54;
		t.viewport = this.u_grpShopHall_i();
		return t;
	};
	_proto.u_grpShopHall_i = function () {
		var t = new eui.Group();
		this.u_grpShopHall = t;
		return t;
	};
	_proto.u_btnArray_i = function () {
		var t = new eui.Group();
		this.u_btnArray = t;
		t.height = 80;
		t.width = 1136;
		t.y = 557;
		t.elementsContent = [this.u_imgBottom_i(),this.u_btn1_i(),this.u_btn2_i(),this.u_btn3_i(),this.u_btn4_i()];
		return t;
	};
	_proto.u_imgBottom_i = function () {
		var t = new eui.Image();
		this.u_imgBottom = t;
		t.scale9Grid = new egret.Rectangle(460,27,460,27);
		t.source = "shopHallUI_json.shopHallUI_img_navBg";
		t.visible = true;
		t.percentWidth = 100;
		t.x = 0;
		return t;
	};
	_proto.u_btn1_i = function () {
		var t = new eui.Group();
		this.u_btn1 = t;
		t.height = 60;
		t.name = "Name1";
		t.width = 276;
		t.x = 0;
		t.y = 20;
		t.elementsContent = [this._Image1_i(),this.u_img1_i(),this.u_imgType1_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 25;
		t.horizontalCenter = 3.5;
		t.source = "shopHallUI_json.shopHallUI_icon_zs";
		t.visible = true;
		t.width = 27;
		t.y = 15.5;
		return t;
	};
	_proto.u_img1_i = function () {
		var t = new eui.Image();
		this.u_img1 = t;
		t.height = 60;
		t.right = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "shopHallUI_json.shopHallUI_img_line";
		t.visible = true;
		t.y = 0;
		return t;
	};
	_proto.u_imgType1_i = function () {
		var t = new eui.Image();
		this.u_imgType1 = t;
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(95,18,94,19);
		t.source = "shopHallUI_json.shopHallUI_img_xz";
		t.visible = false;
		t.percentWidth = 100;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btn2_i = function () {
		var t = new eui.Group();
		this.u_btn2 = t;
		t.height = 60;
		t.name = "Name2";
		t.scaleX = 1;
		t.scaleY = 1;
		t.visible = true;
		t.width = 277;
		t.x = 288;
		t.y = 20;
		t.elementsContent = [this._Image2_i(),this.u_img2_i(),this.u_imgType2_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 25;
		t.horizontalCenter = -2;
		t.source = "shopHallUI_json.shopHallUI_icon_sc";
		t.visible = true;
		t.width = 27;
		t.y = 15.5;
		return t;
	};
	_proto.u_img2_i = function () {
		var t = new eui.Image();
		this.u_img2 = t;
		t.right = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "shopHallUI_json.shopHallUI_img_line";
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_imgType2_i = function () {
		var t = new eui.Image();
		this.u_imgType2 = t;
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(95,18,94,19);
		t.source = "shopHallUI_json.shopHallUI_img_xz";
		t.visible = false;
		t.percentWidth = 100;
		return t;
	};
	_proto.u_btn3_i = function () {
		var t = new eui.Group();
		this.u_btn3 = t;
		t.height = 60;
		t.name = "Name3";
		t.width = 278;
		t.x = 571;
		t.y = 20;
		t.elementsContent = [this._Image3_i(),this.u_imgType3_i(),this.u_img3_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 23;
		t.horizontalCenter = 0.5;
		t.source = "shopHallUI_json.shopHallUI_icon_jb";
		t.visible = true;
		t.width = 24.5;
		t.y = 15.5;
		return t;
	};
	_proto.u_imgType3_i = function () {
		var t = new eui.Image();
		this.u_imgType3 = t;
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(95,18,94,19);
		t.source = "shopHallUI_json.shopHallUI_img_xz";
		t.visible = false;
		t.percentWidth = 100;
		return t;
	};
	_proto.u_img3_i = function () {
		var t = new eui.Image();
		this.u_img3 = t;
		t.right = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "shopHallUI_json.shopHallUI_img_line";
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btn4_i = function () {
		var t = new eui.Group();
		this.u_btn4 = t;
		t.height = 60;
		t.name = "Name4";
		t.width = 275;
		t.x = 857;
		t.y = 20;
		t.elementsContent = [this._Image4_i(),this.u_imgType4_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = -0.5;
		t.source = "shopHallUI_json.shopHallUI_icon_tq";
		t.visible = true;
		t.y = 15;
		return t;
	};
	_proto.u_imgType4_i = function () {
		var t = new eui.Image();
		this.u_imgType4 = t;
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(95,18,94,19);
		t.source = "shopHallUI_json.shopHallUI_img_xz";
		t.visible = false;
		t.percentWidth = 100;
		return t;
	};
	return ShopHallUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shopHallUI/view/BuyPropViewSkin.exml'] = window.BuyPropViewSkin = (function (_super) {
	__extends(BuyPropViewSkin, _super);
	function BuyPropViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_imgIcon","u_txtCoinShop","u_grpCoinShop","u_propList"];
		
		this.height = 478;
		this.width = 284;
		this.elementsContent = [this.u_imgBg_i(),this.u_grpCoinShop_i(),this.u_propList_i()];
	}
	var _proto = BuyPropViewSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 478;
		t.source = "shopHallUI_json.shopHallUI_img_nrbg";
		t.width = 284;
		return t;
	};
	_proto.u_grpCoinShop_i = function () {
		var t = new eui.Group();
		this.u_grpCoinShop = t;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image1_i(),this._Group1_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 55;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(95,18,94,19);
		t.source = "shopHallUI_json.shopHallUI_img_bt2";
		t.y = 0;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 16;
		t.y = 14;
		t.elementsContent = [this.u_imgIcon_i(),this.u_txtCoinShop_i()];
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.source = "shopHallUI_json.shopHallUI_icon_sd";
		t.x = 0;
		return t;
	};
	_proto.u_txtCoinShop_i = function () {
		var t = new eui.Label();
		this.u_txtCoinShop = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.height = 28;
		t.size = 18;
		t.text = "金币商店";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.width = 99;
		t.x = 37;
		t.y = 0;
		return t;
	};
	_proto.u_propList_i = function () {
		var t = new eui.List();
		this.u_propList = t;
		t.height = 400;
		t.x = 10;
		t.y = 56;
		return t;
	};
	return BuyPropViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shopHallUI/view/CoinViewSkin.exml'] = window.CoinViewSkin = (function (_super) {
	__extends(CoinViewSkin, _super);
	function CoinViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_txtCoin","u_headTitle","u_coinList"];
		
		this.height = 478;
		this.width = 284;
		this.elementsContent = [this.u_imgBg_i(),this.u_headTitle_i(),this.u_coinList_i()];
	}
	var _proto = CoinViewSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 478;
		t.scale9Grid = new egret.Rectangle(20,20,20,20);
		t.source = "shopHallUI_json.shopHallUI_img_nrbg";
		t.width = 284;
		return t;
	};
	_proto.u_headTitle_i = function () {
		var t = new eui.Group();
		this.u_headTitle = t;
		t.height = 55;
		t.width = 284;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtCoin_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 55;
		t.horizontalCenter = 0;
		t.source = "shopHallUI_json.shopHallUI_img_bt2";
		t.width = 284;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = -25;
		t.source = "shopHallUI_json.shopHallUI_icon_jbsd";
		t.y = 15;
		return t;
	};
	_proto.u_txtCoin_i = function () {
		var t = new eui.Label();
		this.u_txtCoin = t;
		t.fontFamily = "Microsoft YaHei";
		t.height = 28;
		t.horizontalCenter = 15;
		t.size = 16;
		t.text = "金币";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.y = 15;
		return t;
	};
	_proto.u_coinList_i = function () {
		var t = new eui.List();
		this.u_coinList = t;
		t.height = 400;
		t.x = 10;
		t.y = 56;
		return t;
	};
	return CoinViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shopHallUI/view/DiamondViewSkin.exml'] = window.DiamondViewSkin = (function (_super) {
	__extends(DiamondViewSkin, _super);
	function DiamondViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_txtDiamond","u_grpDiaTil","u_diamondList"];
		
		this.height = 478;
		this.width = 284;
		this.elementsContent = [this.u_imgBg_i(),this.u_grpDiaTil_i(),this.u_diamondList_i()];
	}
	var _proto = DiamondViewSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 478;
		t.scale9Grid = new egret.Rectangle(20,20,20,20);
		t.source = "shopHallUI_json.shopHallUI_img_nrbg";
		t.width = 284;
		return t;
	};
	_proto.u_grpDiaTil_i = function () {
		var t = new eui.Group();
		this.u_grpDiaTil = t;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image1_i(),this._Group1_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 55;
		t.horizontalCenter = 0;
		t.source = "shopHallUI_json.shopHallUI_img_bt1";
		t.y = 0;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 10.5;
		t.y = 14;
		t.elementsContent = [this._Image2_i(),this.u_txtDiamond_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "shopHallUI_json.shopHallUI_icon_zssd";
		t.x = 0;
		return t;
	};
	_proto.u_txtDiamond_i = function () {
		var t = new eui.Label();
		this.u_txtDiamond = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.height = 28;
		t.size = 18;
		t.text = "钻石";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.width = 62;
		t.x = 37;
		t.y = 0;
		return t;
	};
	_proto.u_diamondList_i = function () {
		var t = new eui.List();
		this.u_diamondList = t;
		t.height = 400;
		t.x = 10;
		t.y = 56;
		return t;
	};
	return DiamondViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shopHallUI/view/VipViewSkin.exml'] = window.VipViewSkin = (function (_super) {
	__extends(VipViewSkin, _super);
	function VipViewSkin() {
		_super.call(this);
		this.skinParts = ["u_grpVip","u_txtMsg","u_imgjinDu","u_txtRecive","u_btnRecive","u_txtjinDu","u_txtVipPriv","u_awardList","u_awardScroll","u_btnLeft","u_btnRight"];
		
		this.height = 478;
		this.width = 800;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this._Image3_i(),this.u_grpVip_i(),this.u_txtMsg_i(),this._Image4_i(),this.u_imgjinDu_i(),this.u_btnRecive_i(),this.u_txtjinDu_i(),this.u_txtVipPriv_i(),this.u_awardScroll_i(),this.u_btnLeft_i(),this.u_btnRight_i()];
	}
	var _proto = VipViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 478;
		t.scale9Grid = new egret.Rectangle(20,20,20,20);
		t.source = "shopHallUI_json.shopHallUI_img_nrbg";
		t.width = 800;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "shopHallUI_json.shopHallUI_img_tq";
		t.width = 800;
		t.y = 40;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "shopHallUI_json.shopHallUI_img_vip";
		t.x = 31;
		t.y = 24;
		return t;
	};
	_proto.u_grpVip_i = function () {
		var t = new eui.Group();
		this.u_grpVip = t;
		t.height = 43;
		t.width = 55;
		t.x = 86.5;
		t.y = 46;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.height = 25.31;
		t.left = 245;
		t.size = 16;
		t.text = "再充值$8         即可升级至VIP6";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.y = 56.136;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(7,7,8,8);
		t.source = "shopHallUI_json.shopHallUI_img_jd1";
		t.width = 390;
		t.x = 245;
		t.y = 82;
		return t;
	};
	_proto.u_imgjinDu_i = function () {
		var t = new eui.Image();
		this.u_imgjinDu = t;
		t.height = 12;
		t.scale9Grid = new egret.Rectangle(5,5,4,4);
		t.source = "shopHallUI_json.shopHallUI_img_jd2";
		t.visible = true;
		t.width = 380;
		t.x = 250;
		t.y = 87;
		return t;
	};
	_proto.u_btnRecive_i = function () {
		var t = new eui.Group();
		this.u_btnRecive = t;
		t.visible = false;
		t.x = 663;
		t.y = 55;
		t.elementsContent = [this._Image5_i(),this.u_txtRecive_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "shopHallUI_json.shopHallUI_btn_vip";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtRecive_i = function () {
		var t = new eui.Label();
		this.u_txtRecive = t;
		t.fontFamily = "Microsoft YaHei";
		t.text = "领取";
		t.x = 36;
		t.y = 10;
		return t;
	};
	_proto.u_txtjinDu_i = function () {
		var t = new eui.Label();
		this.u_txtjinDu = t;
		t.fontFamily = "Microsoft YaHei";
		t.height = 12;
		t.horizontalCenter = 39.5;
		t.size = 12;
		t.stroke = 2;
		t.strokeColor = 0x000000;
		t.text = "90/100";
		t.textColor = 0xF0E4B0;
		t.y = 88.5;
		return t;
	};
	_proto.u_txtVipPriv_i = function () {
		var t = new eui.Label();
		this.u_txtVipPriv = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 11.5;
		t.size = 24;
		t.text = "vip特权";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.y = 128;
		return t;
	};
	_proto.u_awardScroll_i = function () {
		var t = new eui.Scroller();
		this.u_awardScroll = t;
		t.height = 302;
		t.width = 638;
		t.x = 92;
		t.y = 155;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_awardList_i()];
		return t;
	};
	_proto.u_awardList_i = function () {
		var t = new eui.List();
		this.u_awardList = t;
		return t;
	};
	_proto.u_btnLeft_i = function () {
		var t = new eui.Image();
		this.u_btnLeft = t;
		t.height = 38;
		t.source = "shopHallUI_json.shopHallUI_btn_z";
		t.width = 25;
		t.x = 50;
		t.y = 287.5;
		return t;
	};
	_proto.u_btnRight_i = function () {
		var t = new eui.Image();
		this.u_btnRight = t;
		t.source = "shopHallUI_json.shopHallUI_btn_y";
		t.x = 750;
		t.y = 287.5;
		return t;
	};
	return VipViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shopUI/popup/ShopBuyPopupSkin.exml'] = window.ShopBuyPopupSkin = (function (_super) {
	__extends(ShopBuyPopupSkin, _super);
	function ShopBuyPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtBlank"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_txtBlank_i()];
	}
	var _proto = ShopBuyPopupSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 360;
		t.scale9Grid = new egret.Rectangle(11,78,9,12);
		t.source = "commonUI_json.commonUI_bg";
		t.width = 651;
		t.x = 243;
		t.y = 104.77;
		return t;
	};
	_proto.u_txtBlank_i = function () {
		var t = new eui.Label();
		this.u_txtBlank = t;
		t.horizontalCenter = 0;
		t.size = 18;
		t.text = "点击空白处关闭窗口";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.y = 568.66;
		return t;
	};
	return ShopBuyPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/shopUI/view/ShopBuyViewSkin.exml'] = window.ShopBuyViewSkin = (function (_super) {
	__extends(ShopBuyViewSkin, _super);
	function ShopBuyViewSkin() {
		_super.call(this);
		this.skinParts = ["u_txtName","u_mcName","u_imgSell","u_imgPrice","u_txtPrice","u_textSelling","u_imgTotal","u_imgPriceCount","u_txtPriceCount","u_txtTotal","u_txtCount","u_btnReduc","u_btnAdd","u_btnAddTen","u_btnReducTen","u_btnReduc_Gray","u_btnAdd_Gray","u_btnAddTen_Gray","u_btnReducTen_Gray","u_btnBuy","u_btnRecharge"];
		
		this.height = 320;
		this.width = 600;
		this.elementsContent = [this.u_mcName_i(),this._Group1_i(),this._Group2_i(),this._Group3_i(),this.u_btnBuy_i(),this.u_btnRecharge_i()];
	}
	var _proto = ShopBuyViewSkin.prototype;

	_proto.u_mcName_i = function () {
		var t = new eui.Group();
		this.u_mcName = t;
		t.height = 15;
		t.visible = true;
		t.width = 424;
		t.x = 75;
		t.y = 15;
		t.elementsContent = [this._Image1_i(),this.u_txtName_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(133,1,40,13);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_jw";
		t.width = 520;
		t.y = 0;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.fontFamily = "Arial";
		t.horizontalCenter = 0;
		t.size = 18;
		t.text = "道具名稱七個字（限制購買*1）";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.y = -1;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 210;
		t.y = 86;
		t.elementsContent = [this.u_imgSell_i(),this.u_imgPrice_i(),this.u_txtPrice_i(),this.u_textSelling_i()];
		return t;
	};
	_proto.u_imgSell_i = function () {
		var t = new eui.Image();
		this.u_imgSell = t;
		t.scale9Grid = new egret.Rectangle(13,13,14,14);
		t.source = "shopBuyUI_json.shopBuyUI_img_frame";
		t.visible = true;
		t.width = 240;
		t.x = 41;
		return t;
	};
	_proto.u_imgPrice_i = function () {
		var t = new eui.Image();
		this.u_imgPrice = t;
		t.height = 40;
		t.scale9Grid = new egret.Rectangle(37,4,223,26);
		t.source = "";
		t.visible = true;
		t.width = 40;
		t.x = 38.788;
		t.y = 0;
		return t;
	};
	_proto.u_txtPrice_i = function () {
		var t = new eui.Label();
		this.u_txtPrice = t;
		t.size = 14;
		t.text = "500k";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.x = 77;
		t.y = 14;
		return t;
	};
	_proto.u_textSelling_i = function () {
		var t = new eui.Label();
		this.u_textSelling = t;
		t.size = 16;
		t.text = "售价";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.x = 3.03;
		t.y = 12.79;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.x = 210;
		t.y = 146;
		t.elementsContent = [this.u_imgTotal_i(),this.u_imgPriceCount_i(),this.u_txtPriceCount_i(),this.u_txtTotal_i()];
		return t;
	};
	_proto.u_imgTotal_i = function () {
		var t = new eui.Image();
		this.u_imgTotal = t;
		t.scale9Grid = new egret.Rectangle(13,13,14,14);
		t.source = "shopBuyUI_json.shopBuyUI_img_frame";
		t.visible = true;
		t.width = 240;
		t.x = 41;
		return t;
	};
	_proto.u_imgPriceCount_i = function () {
		var t = new eui.Image();
		this.u_imgPriceCount = t;
		t.height = 40;
		t.scale9Grid = new egret.Rectangle(37,4,223,26);
		t.source = "";
		t.visible = true;
		t.width = 40;
		t.x = 39.546;
		t.y = 0.512;
		return t;
	};
	_proto.u_txtPriceCount_i = function () {
		var t = new eui.Label();
		this.u_txtPriceCount = t;
		t.size = 14;
		t.text = "500k";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.x = 76.596;
		t.y = 14;
		return t;
	};
	_proto.u_txtTotal_i = function () {
		var t = new eui.Label();
		this.u_txtTotal = t;
		t.size = 16;
		t.text = "总价";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.x = 3.03;
		t.y = 12.032;
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.width = 413.05;
		t.x = 80;
		t.y = 206;
		t.elementsContent = [this._Image2_i(),this.u_txtCount_i(),this.u_btnReduc_i(),this.u_btnAdd_i(),this.u_btnAddTen_i(),this.u_btnReducTen_i(),this.u_btnReduc_Gray_i(),this.u_btnAdd_Gray_i(),this.u_btnAddTen_Gray_i(),this.u_btnReducTen_Gray_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(13,13,14,14);
		t.source = "shopBuyUI_json.shopBuyUI_img_frame";
		t.visible = true;
		t.width = 172;
		t.x = 121;
		t.y = 0;
		return t;
	};
	_proto.u_txtCount_i = function () {
		var t = new eui.Label();
		this.u_txtCount = t;
		t.size = 16;
		t.text = "8";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.width = 90;
		t.x = 160.414;
		t.y = 14.294;
		return t;
	};
	_proto.u_btnReduc_i = function () {
		var t = new eui.Image();
		this.u_btnReduc = t;
		t.height = 38;
		t.source = "shopBuyUI_json.shopBuyUI_normal_subtract";
		t.visible = true;
		t.width = 38;
		t.x = 68.242;
		t.y = 2.484;
		return t;
	};
	_proto.u_btnAdd_i = function () {
		var t = new eui.Image();
		this.u_btnAdd = t;
		t.height = 38;
		t.source = "shopBuyUI_json.shopBuyUI_normal_add";
		t.visible = true;
		t.width = 38;
		t.x = 308.245;
		t.y = 2.484;
		return t;
	};
	_proto.u_btnAddTen_i = function () {
		var t = new eui.Image();
		this.u_btnAddTen = t;
		t.height = 38;
		t.source = "shopBuyUI_json.shopBuyUI_normal_add10";
		t.visible = true;
		t.width = 58;
		t.x = 357.194;
		t.y = 2.484;
		return t;
	};
	_proto.u_btnReducTen_i = function () {
		var t = new eui.Image();
		this.u_btnReducTen = t;
		t.height = 38;
		t.source = "shopBuyUI_json.shopBuyUI_normal_subtract10";
		t.visible = true;
		t.width = 58;
		t.x = 0;
		t.y = 2.484;
		return t;
	};
	_proto.u_btnReduc_Gray_i = function () {
		var t = new eui.Image();
		this.u_btnReduc_Gray = t;
		t.source = "shopBuyUI_json.shopBuyUI_disabled_subtract";
		t.visible = false;
		t.x = 68.242;
		t.y = 2.484;
		return t;
	};
	_proto.u_btnAdd_Gray_i = function () {
		var t = new eui.Image();
		this.u_btnAdd_Gray = t;
		t.source = "shopBuyUI_json.shopBuyUI_disabled_add";
		t.visible = false;
		t.x = 308.245;
		t.y = 2.484;
		return t;
	};
	_proto.u_btnAddTen_Gray_i = function () {
		var t = new eui.Image();
		this.u_btnAddTen_Gray = t;
		t.height = 38;
		t.source = "shopBuyUI_json.shopBuyUI_disabled_add10";
		t.visible = false;
		t.width = 58;
		t.x = 357.194;
		t.y = 2.484;
		return t;
	};
	_proto.u_btnReducTen_Gray_i = function () {
		var t = new eui.Image();
		this.u_btnReducTen_Gray = t;
		t.source = "shopBuyUI_json.shopBuyUI_disabled_subtract10";
		t.visible = false;
		t.x = 0;
		t.y = 2.484;
		return t;
	};
	_proto.u_btnBuy_i = function () {
		var t = new eui.Image();
		this.u_btnBuy = t;
		t.height = 41;
		t.source = "shopBuyUI_json.shopBuyUI_btn_buy";
		t.width = 97;
		t.x = 323;
		t.y = 266;
		return t;
	};
	_proto.u_btnRecharge_i = function () {
		var t = new eui.Image();
		this.u_btnRecharge = t;
		t.height = 41;
		t.source = "commonUI_json.commonUI_btn_recharge";
		t.width = 97;
		t.x = 160;
		t.y = 266;
		return t;
	};
	return ShopBuyViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/signInUI/render/SignInRenderSkin.exml'] = window.SignInRenderSkin = (function (_super) {
	__extends(SignInRenderSkin, _super);
	function SignInRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_ImgSignInBg","u_txtDay","u_txtSignInCount","u_imgMulti","u_receivedGrp","u_imgResign","u_btnClick"];
		
		this.height = 159;
		this.width = 132;
		this.elementsContent = [this.u_ImgSignInBg_i(),this.u_txtDay_i(),this.u_txtSignInCount_i(),this.u_imgMulti_i(),this.u_receivedGrp_i(),this.u_imgResign_i(),this.u_btnClick_i()];
	}
	var _proto = SignInRenderSkin.prototype;

	_proto.u_ImgSignInBg_i = function () {
		var t = new eui.Image();
		this.u_ImgSignInBg = t;
		t.horizontalCenter = 0;
		t.source = "signInUI_json.signInUI_tab1";
		t.visible = true;
		t.y = 0;
		return t;
	};
	_proto.u_txtDay_i = function () {
		var t = new eui.Label();
		this.u_txtDay = t;
		t.background = false;
		t.backgroundColor = 0xFFFFFF;
		t.bold = false;
		t.border = false;
		t.borderColor = 0x000000;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.size = 16;
		t.sortableChildren = false;
		t.stroke = 1.5;
		t.strokeColor = 0x8E5E3D;
		t.text = "第1日";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.verticalAlign = "middle";
		t.visible = true;
		t.y = 8;
		return t;
	};
	_proto.u_txtSignInCount_i = function () {
		var t = new eui.Label();
		this.u_txtSignInCount = t;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 0;
		t.size = 16;
		t.text = "1000";
		t.textAlign = "center";
		t.textColor = 0x14151A;
		t.touchEnabled = false;
		t.verticalAlign = "middle";
		t.y = 42;
		return t;
	};
	_proto.u_imgMulti_i = function () {
		var t = new eui.Image();
		this.u_imgMulti = t;
		t.source = "signInUI_json.signInUI_double";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_receivedGrp_i = function () {
		var t = new eui.Group();
		this.u_receivedGrp = t;
		t.height = 159;
		t.touchChildren = false;
		t.touchEnabled = false;
		t.visible = false;
		t.width = 132;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image1_i(),this._Image2_i(),this._Label1_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "signInUI_json.signInUI_mask";
		t.visible = true;
		t.x = 1;
		t.y = 1;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "signInUI_json.signInUI_chose";
		t.visible = true;
		t.y = 45;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.horizontalCenter = 0;
		t.size = 18;
		t.text = "已签到";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 90;
		return t;
	};
	_proto.u_imgResign_i = function () {
		var t = new eui.Image();
		this.u_imgResign = t;
		t.horizontalCenter = 0;
		t.source = "signInUI_json.signInUI_sign";
		t.touchEnabled = false;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btnClick_i = function () {
		var t = new eui.Image();
		this.u_btnClick = t;
		t.alpha = 0;
		t.height = 80;
		t.scale9Grid = new egret.Rectangle(3,3,4,4);
		t.source = "commonUI_json.commonUI_box";
		t.visible = true;
		t.width = 90;
		t.x = 21;
		t.y = 65;
		return t;
	};
	return SignInRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/signInUI/SignInUISkin.exml'] = window.SignInUISkin = (function (_super) {
	__extends(SignInUISkin, _super);
	function SignInUISkin() {
		_super.call(this);
		this.skinParts = ["u_listItem","u_scrollerItem"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this.u_scrollerItem_i()];
	}
	var _proto = SignInUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "signInUI_json.signInUI_bg";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 188;
		t.y = 47.4;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 480.206;
		t.visible = true;
		t.width = 842;
		t.x = 223.212;
		t.y = 125.39;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.width = 635;
		t.elementsContent = [this.u_listItem_i()];
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		return t;
	};
	return SignInUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/soloCreateUI/render/SoloCapitalListRenderSkin.exml'] = window.skins.SoloCapitalListUISkin = (function (_super) {
	__extends(SoloCapitalListUISkin, _super);
	function SoloCapitalListUISkin() {
		_super.call(this);
		this.skinParts = ["u_backImg","u_txtCapital","u_txtCost","u_txtWin","u_iconCost","u_iconWin","u_btnChoose"];
		
		this.height = 54;
		this.width = 547;
		this.elementsContent = [this.u_backImg_i(),this.u_btnChoose_i()];
	}
	var _proto = SoloCapitalListUISkin.prototype;

	_proto.u_backImg_i = function () {
		var t = new eui.Image();
		this.u_backImg = t;
		t.height = 54;
		t.scale9Grid = new egret.Rectangle(29,29,30,30);
		t.source = "commonsUI_json.commonUI_box_2";
		t.width = 547;
		t.x = 0.874;
		t.y = -1;
		return t;
	};
	_proto.u_btnChoose_i = function () {
		var t = new eui.Group();
		this.u_btnChoose = t;
		t.height = 54;
		t.width = 547;
		t.x = 2;
		t.y = -1;
		t.elementsContent = [this.u_txtCapital_i(),this._Label1_i(),this.u_txtCost_i(),this._Label2_i(),this.u_txtWin_i(),this.u_iconCost_i(),this.u_iconWin_i()];
		return t;
	};
	_proto.u_txtCapital_i = function () {
		var t = new eui.Label();
		this.u_txtCapital = t;
		t.horizontalCenter = -180.5;
		t.size = 20;
		t.text = "Magnification";
		t.verticalCenter = 0;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.horizontalCenter = -55;
		t.size = 20;
		t.text = "Cost:";
		t.verticalCenter = 1;
		return t;
	};
	_proto.u_txtCost_i = function () {
		var t = new eui.Label();
		this.u_txtCost = t;
		t.horizontalCenter = 37.5;
		t.size = 20;
		t.text = "99999";
		t.verticalCenter = 0;
		return t;
	};
	_proto._Label2_i = function () {
		var t = new eui.Label();
		t.horizontalCenter = 109.5;
		t.size = 20;
		t.text = "Win:";
		t.verticalCenter = 1;
		return t;
	};
	_proto.u_txtWin_i = function () {
		var t = new eui.Label();
		this.u_txtWin = t;
		t.horizontalCenter = 200.5;
		t.size = 20;
		t.text = "99999";
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_iconCost_i = function () {
		var t = new eui.Image();
		this.u_iconCost = t;
		t.horizontalCenter = -13;
		t.scaleX = 0.6;
		t.scaleY = 0.6;
		t.verticalCenter = 0.5;
		return t;
	};
	_proto.u_iconWin_i = function () {
		var t = new eui.Image();
		this.u_iconWin = t;
		t.horizontalCenter = 147;
		t.scaleX = 0.6;
		t.scaleY = 0.6;
		t.verticalCenter = 0.5;
		return t;
	};
	return SoloCapitalListUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/soloCreateUI/SoloCreateRoomUISkin.exml'] = window.skins.SoloCreateRoomUISkin = (function (_super) {
	__extends(SoloCreateRoomUISkin, _super);
	function SoloCreateRoomUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgOne","u_txtJoinOne","u_btnJoinOne","u_imgTwo","u_txtJoinTwo","u_btnJoinTwo","u_txtCreate","u_btnCreate","u_txtCapital1","u_btnCapital1","u_txtCapital2","u_btnCapital2","u_txtCapital3","u_btnCapital3","u_itemList","u_scrollItem"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this.u_btnJoinOne_i(),this.u_btnJoinTwo_i(),this.u_btnCreate_i(),this.u_btnCapital1_i(),this.u_btnCapital2_i(),this.u_btnCapital3_i(),this.u_scrollItem_i()];
	}
	var _proto = SoloCreateRoomUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 900;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(29,29,30,30);
		t.source = "commonsUI_json.commonUI_box_2";
		t.width = 590;
		t.y = 95;
		return t;
	};
	_proto.u_btnJoinOne_i = function () {
		var t = new eui.Group();
		this.u_btnJoinOne = t;
		t.height = 269.527;
		t.name = "btnJoin1";
		t.width = 247.55;
		t.x = 61.742;
		t.y = 114.738;
		t.elementsContent = [this.u_imgOne_i(),this.u_txtJoinOne_i()];
		return t;
	};
	_proto.u_imgOne_i = function () {
		var t = new eui.Image();
		this.u_imgOne = t;
		t.anchorOffsetX = -6.89;
		t.height = 262.319;
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.width = 243.761;
		t.x = -3.813;
		t.y = 2.265;
		return t;
	};
	_proto.u_txtJoinOne_i = function () {
		var t = new eui.Label();
		this.u_txtJoinOne = t;
		t.size = 25;
		t.text = "Join";
		t.textAlign = "center";
		t.textColor = 0x0A0303;
		t.verticalAlign = "middle";
		t.x = 99.177;
		t.y = 116.252;
		return t;
	};
	_proto.u_btnJoinTwo_i = function () {
		var t = new eui.Group();
		this.u_btnJoinTwo = t;
		t.height = 263.324;
		t.name = "btnJoin2";
		t.width = 235.146;
		t.x = 351.29;
		t.y = 115.824;
		t.elementsContent = [this.u_imgTwo_i(),this.u_txtJoinTwo_i()];
		return t;
	};
	_proto.u_imgTwo_i = function () {
		var t = new eui.Image();
		this.u_imgTwo = t;
		t.anchorOffsetX = -6.414;
		t.height = 255.974;
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.width = 226.912;
		t.x = -3.227;
		t.y = 4.423;
		return t;
	};
	_proto.u_txtJoinTwo_i = function () {
		var t = new eui.Label();
		this.u_txtJoinTwo = t;
		t.size = 25;
		t.text = "Join";
		t.textAlign = "center";
		t.textColor = 0x0A0303;
		t.verticalAlign = "middle";
		t.x = 98.315;
		t.y = 113.026;
		return t;
	};
	_proto.u_btnCreate_i = function () {
		var t = new eui.Group();
		this.u_btnCreate = t;
		t.height = 112.23;
		t.width = 280.138;
		t.x = 194.138;
		t.y = 427.829;
		t.elementsContent = [this._Image2_i(),this.u_txtCreate_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 106.411;
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.width = 268.435;
		t.x = 4.393;
		t.y = 0.231;
		return t;
	};
	_proto.u_txtCreate_i = function () {
		var t = new eui.Label();
		this.u_txtCreate = t;
		t.height = 53.006;
		t.size = 40;
		t.text = "Create";
		t.textAlign = "center";
		t.textColor = 0x0A0303;
		t.verticalAlign = "middle";
		t.width = 169.862;
		t.x = 50;
		t.y = 29;
		return t;
	};
	_proto.u_btnCapital1_i = function () {
		var t = new eui.Group();
		this.u_btnCapital1 = t;
		t.height = 82;
		t.name = "btnCap1";
		t.visible = true;
		t.width = 161;
		t.x = 34;
		t.y = 574;
		t.elementsContent = [this._Image3_i(),this.u_txtCapital1_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = -1.4680000000000035;
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.verticalCenter = 0.35549999999999926;
		return t;
	};
	_proto.u_txtCapital1_i = function () {
		var t = new eui.Label();
		this.u_txtCapital1 = t;
		t.horizontalCenter = -0.4680000000000035;
		t.text = "1K";
		t.verticalCenter = -1.1445000000000007;
		return t;
	};
	_proto.u_btnCapital2_i = function () {
		var t = new eui.Group();
		this.u_btnCapital2 = t;
		t.height = 77.848;
		t.name = "btnCap2";
		t.width = 162.077;
		t.x = 235.096;
		t.y = 574;
		t.elementsContent = [this._Image4_i(),this.u_txtCapital2_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0.4615000000000009;
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.verticalCenter = 0.5760000000000005;
		return t;
	};
	_proto.u_txtCapital2_i = function () {
		var t = new eui.Label();
		this.u_txtCapital2 = t;
		t.horizontalCenter = 0.9615000000000009;
		t.text = "10K";
		t.textColor = 0xFFFFFF;
		t.verticalCenter = -1.9239999999999995;
		return t;
	};
	_proto.u_btnCapital3_i = function () {
		var t = new eui.Group();
		this.u_btnCapital3 = t;
		t.height = 84;
		t.name = "btnCap3";
		t.width = 157;
		t.x = 448.29;
		t.y = 574;
		t.elementsContent = [this._Image5_i(),this.u_txtCapital3_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = -2.4009999999999962;
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.verticalCenter = -0.7550000000000026;
		return t;
	};
	_proto.u_txtCapital3_i = function () {
		var t = new eui.Label();
		this.u_txtCapital3 = t;
		t.horizontalCenter = -3.4009999999999962;
		t.text = "100K";
		t.verticalCenter = -1.2550000000000026;
		return t;
	};
	_proto.u_scrollItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollItem = t;
		t.height = 314;
		t.horizontalCenter = -0.5;
		t.width = 547;
		t.y = 676;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.width = 600;
		t.x = -1.742;
		t.elementsContent = [this.u_itemList_i()];
		return t;
	};
	_proto.u_itemList_i = function () {
		var t = new eui.List();
		this.u_itemList = t;
		t.x = 5;
		t.y = 7;
		return t;
	};
	return SoloCreateRoomUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/soloPlayerUI/popup/SoloWaitPopupSkin.exml'] = window.skins.SoloWaitPopupSkin = (function (_super) {
	__extends(SoloWaitPopupSkin, _super);
	function SoloWaitPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_txtNum","u_numGrp"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_numGrp_i()];
	}
	var _proto = SoloWaitPopupSkin.prototype;

	_proto.u_numGrp_i = function () {
		var t = new eui.Group();
		this.u_numGrp = t;
		t.height = 300;
		t.width = 300;
		t.x = 155.864;
		t.y = 368.738;
		t.elementsContent = [this.u_txtNum_i()];
		return t;
	};
	_proto.u_txtNum_i = function () {
		var t = new eui.Label();
		this.u_txtNum = t;
		t.height = 118.973;
		t.horizontalCenter = 2.5;
		t.size = 89;
		t.text = "0";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.verticalCenter = -5.5;
		t.visible = false;
		t.width = 119.216;
		return t;
	};
	return SoloWaitPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/soloPlayerUI/render/SoloRoomRenderSkin.exml'] = window.skins.SoloRoomRenderSkin = (function (_super) {
	__extends(SoloRoomRenderSkin, _super);
	function SoloRoomRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_img1","u_txtJoin1","u_btnJoin1","u_img2","u_txtJoin2","u_btnJoin2","u_txtMana1","u_txtMana2"];
		
		this.height = 200;
		this.width = 547;
		this.elementsContent = [this._Image1_i(),this.u_btnJoin1_i(),this.u_btnJoin2_i(),this._Label1_i(),this._Label2_i(),this.u_txtMana1_i(),this._Label3_i(),this.u_txtMana2_i()];
	}
	var _proto = SoloRoomRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 200;
		t.scale9Grid = new egret.Rectangle(29,29,30,30);
		t.source = "commonsUI_json.commonUI_box_2";
		t.width = 547;
		t.x = 0.181;
		t.y = -0.67;
		return t;
	};
	_proto.u_btnJoin1_i = function () {
		var t = new eui.Group();
		this.u_btnJoin1 = t;
		t.height = 100;
		t.visible = true;
		t.width = 125;
		t.x = 48;
		t.y = 23;
		t.elementsContent = [this.u_img1_i(),this.u_txtJoin1_i()];
		return t;
	};
	_proto.u_img1_i = function () {
		var t = new eui.Image();
		this.u_img1 = t;
		t.height = 97;
		t.source = "commonsUI_json.commonUI_box_3";
		t.visible = true;
		t.width = 122;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtJoin1_i = function () {
		var t = new eui.Label();
		this.u_txtJoin1 = t;
		t.height = 30;
		t.size = 20;
		t.text = "Join";
		t.textAlign = "center";
		t.textColor = 0x0E0A0A;
		t.verticalAlign = "middle";
		t.visible = false;
		t.width = 70.424;
		t.x = 27;
		t.y = 34;
		return t;
	};
	_proto.u_btnJoin2_i = function () {
		var t = new eui.Group();
		this.u_btnJoin2 = t;
		t.height = 100;
		t.width = 125;
		t.x = 330;
		t.y = 20;
		t.elementsContent = [this.u_img2_i(),this.u_txtJoin2_i()];
		return t;
	};
	_proto.u_img2_i = function () {
		var t = new eui.Image();
		this.u_img2 = t;
		t.height = 98;
		t.source = "commonsUI_json.commonUI_box_3";
		t.visible = true;
		t.width = 121;
		t.x = 2.12;
		t.y = -1;
		return t;
	};
	_proto.u_txtJoin2_i = function () {
		var t = new eui.Label();
		this.u_txtJoin2 = t;
		t.height = 30;
		t.size = 20;
		t.text = "Join";
		t.textAlign = "center";
		t.textColor = 0x0E0B0B;
		t.verticalAlign = "middle";
		t.visible = false;
		t.width = 71.685;
		t.x = 24;
		t.y = 34;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.height = 52;
		t.horizontalCenter = -20;
		t.size = 36;
		t.text = "VS";
		t.textAlign = "center";
		t.textColor = 0xE6E1E1;
		t.verticalAlign = "middle";
		t.width = 110.548;
		t.y = 70.08;
		return t;
	};
	_proto._Label2_i = function () {
		var t = new eui.Label();
		t.size = 20;
		t.text = "medal:";
		t.textColor = 0x180101;
		t.x = 48;
		t.y = 153.438;
		return t;
	};
	_proto.u_txtMana1_i = function () {
		var t = new eui.Label();
		this.u_txtMana1 = t;
		t.size = 20;
		t.width = 78;
		t.x = 100;
		t.y = 154.04;
		return t;
	};
	_proto._Label3_i = function () {
		var t = new eui.Label();
		t.size = 20;
		t.text = "medal:";
		t.textColor = 0x070101;
		t.x = 328;
		t.y = 149;
		return t;
	};
	_proto.u_txtMana2_i = function () {
		var t = new eui.Label();
		this.u_txtMana2 = t;
		t.size = 20;
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.width = 78;
		t.x = 379.78;
		t.y = 150.78;
		return t;
	};
	return SoloRoomRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/soloPlayerUI/SoloRoomListUISkin.exml'] = window.SoloRoomListUISkin = (function (_super) {
	__extends(SoloRoomListUISkin, _super);
	function SoloRoomListUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgNone","u_itemList","u_scrollItem","u_txtMatch","u_btnMatch","u_txtCapital1","u_btnCapital1","u_txtCapital2","u_btnCapital2","u_txtCapital3","u_btnCapital3"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this.u_imgNone_i(),this.u_scrollItem_i(),this.u_btnMatch_i(),this.u_btnCapital1_i(),this.u_btnCapital2_i(),this.u_btnCapital3_i()];
	}
	var _proto = SoloRoomListUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 900;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(29,29,30,30);
		t.source = "commonsUI_json.commonUI_box_2";
		t.width = 590;
		t.y = 95;
		return t;
	};
	_proto.u_imgNone_i = function () {
		var t = new eui.Image();
		this.u_imgNone = t;
		t.horizontalCenter = 0;
		t.source = "soloPlayerUI_json.soloPlayerUI_none";
		t.y = 411;
		return t;
	};
	_proto.u_scrollItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollItem = t;
		t.height = 641;
		t.horizontalCenter = -0.5;
		t.width = 547;
		t.y = 98.408;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 676.775;
		t.x = 1.704;
		t.elementsContent = [this.u_itemList_i()];
		return t;
	};
	_proto.u_itemList_i = function () {
		var t = new eui.List();
		this.u_itemList = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.x = -2;
		t.y = 4;
		return t;
	};
	_proto.u_btnMatch_i = function () {
		var t = new eui.Group();
		this.u_btnMatch = t;
		t.height = 72.612;
		t.visible = false;
		t.width = 205.971;
		t.x = 212.01;
		t.y = 769.987;
		t.elementsContent = [this._Image2_i(),this.u_txtMatch_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.width = 194.713;
		t.y = 4;
		return t;
	};
	_proto.u_txtMatch_i = function () {
		var t = new eui.Label();
		this.u_txtMatch = t;
		t.height = 31.99;
		t.text = "Match";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.width = 100;
		t.x = 49.32;
		t.y = 18;
		return t;
	};
	_proto.u_btnCapital1_i = function () {
		var t = new eui.Group();
		this.u_btnCapital1 = t;
		t.height = 80;
		t.name = "btnCap1";
		t.width = 162;
		t.x = 28;
		t.y = 895;
		t.elementsContent = [this._Image3_i(),this.u_txtCapital1_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 80;
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.width = 162;
		return t;
	};
	_proto.u_txtCapital1_i = function () {
		var t = new eui.Label();
		this.u_txtCapital1 = t;
		t.text = "1K";
		t.x = 57.88;
		t.y = 23.99;
		return t;
	};
	_proto.u_btnCapital2_i = function () {
		var t = new eui.Group();
		this.u_btnCapital2 = t;
		t.height = 80;
		t.name = "btnCap2";
		t.width = 162;
		t.x = 234.068;
		t.y = 895;
		t.elementsContent = [this._Image4_i(),this.u_txtCapital2_i()];
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.height = 80;
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.width = 162;
		return t;
	};
	_proto.u_txtCapital2_i = function () {
		var t = new eui.Label();
		this.u_txtCapital2 = t;
		t.text = "10K";
		t.x = 57.94;
		t.y = 22;
		return t;
	};
	_proto.u_btnCapital3_i = function () {
		var t = new eui.Group();
		this.u_btnCapital3 = t;
		t.height = 80;
		t.name = "btnCap3";
		t.width = 162;
		t.x = 444;
		t.y = 895;
		t.elementsContent = [this._Image5_i(),this.u_txtCapital3_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.height = 80;
		t.source = "commonsUI_json.commonsUI_btn_1";
		t.width = 162;
		return t;
	};
	_proto.u_txtCapital3_i = function () {
		var t = new eui.Label();
		this.u_txtCapital3 = t;
		t.horizontalCenter = -3.5;
		t.text = "100K";
		t.verticalCenter = -2;
		return t;
	};
	return SoloRoomListUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/soloPlayerUI/SoloRoomUISkin.exml'] = window.skins.SoloRoomUISkin = (function (_super) {
	__extends(SoloRoomUISkin, _super);
	function SoloRoomUISkin() {
		_super.call(this);
		this.skinParts = ["u_img1","u_img2","u_btnStart","u_txtMana1","u_txtMana2"];
		
		this.height = 1128;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this.u_img1_i(),this._Label1_i(),this.u_img2_i(),this._Label2_i(),this._Label3_i(),this.u_btnStart_i(),this._Label4_i(),this.u_txtMana1_i(),this._Label5_i(),this.u_txtMana2_i()];
	}
	var _proto = SoloRoomUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 900;
		t.scale9Grid = new egret.Rectangle(29,29,30,30);
		t.source = "commonsUI_json.commonUI_box_2";
		t.width = 590;
		t.x = 25;
		t.y = 95;
		return t;
	};
	_proto.u_img1_i = function () {
		var t = new eui.Image();
		this.u_img1 = t;
		t.height = 150;
		t.width = 200;
		t.x = 50.472;
		t.y = 323.897;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.height = 62.002;
		t.text = "玩家";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.width = 102.633;
		t.x = 96;
		t.y = 374;
		return t;
	};
	_proto.u_img2_i = function () {
		var t = new eui.Image();
		this.u_img2 = t;
		t.height = 150;
		t.width = 200;
		t.x = 377;
		t.y = 322;
		return t;
	};
	_proto._Label2_i = function () {
		var t = new eui.Label();
		t.height = 58.843;
		t.text = "玩家";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.width = 99.265;
		t.x = 427;
		t.y = 374;
		return t;
	};
	_proto._Label3_i = function () {
		var t = new eui.Label();
		t.height = 51;
		t.text = "VS";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.width = 89.159;
		t.x = 271;
		t.y = 421;
		return t;
	};
	_proto.u_btnStart_i = function () {
		var t = new eui.Label();
		this.u_btnStart = t;
		t.height = 51;
		t.horizontalCenter = 0;
		t.text = "Start";
		t.textAlign = "center";
		t.verticalAlign = "middle";
		t.visible = false;
		t.width = 89.159;
		t.y = 721;
		return t;
	};
	_proto._Label4_i = function () {
		var t = new eui.Label();
		t.text = "medal:";
		t.x = 58.84;
		t.y = 532;
		return t;
	};
	_proto.u_txtMana1_i = function () {
		var t = new eui.Label();
		this.u_txtMana1 = t;
		t.x = 133.892;
		t.y = 532;
		return t;
	};
	_proto._Label5_i = function () {
		var t = new eui.Label();
		t.text = "medal:";
		t.x = 390.524;
		t.y = 532;
		return t;
	};
	_proto.u_txtMana2_i = function () {
		var t = new eui.Label();
		this.u_txtMana2 = t;
		t.x = 466.524;
		t.y = 532.684;
		return t;
	};
	return SoloRoomUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/taskUI/TaskMainUISkin.exml'] = window.skins.TaskMainUISkin = (function (_super) {
	__extends(TaskMainUISkin, _super);
	function TaskMainUISkin() {
		_super.call(this);
		this.skinParts = ["u_grpItem","u_scrollItem","u_btnTop","u_imgMask","u_vsItem","u_btnBottom"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_scrollItem_i(),this.u_btnTop_i(),this.u_imgMask_i(),this.u_vsItem_i(),this.u_btnBottom_i()];
	}
	var _proto = TaskMainUISkin.prototype;

	_proto.u_scrollItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollItem = t;
		t.height = 504;
		t.verticalCenter = -2.5;
		t.visible = true;
		t.width = 845;
		t.x = 221;
		t.viewport = this.u_grpItem_i();
		return t;
	};
	_proto.u_grpItem_i = function () {
		var t = new eui.Group();
		this.u_grpItem = t;
		t.visible = true;
		return t;
	};
	_proto.u_btnTop_i = function () {
		var t = new eui.Image();
		this.u_btnTop = t;
		t.anchorOffsetX = -0.9;
		t.anchorOffsetY = 1;
		t.height = 14;
		t.rotation = 179.591;
		t.source = "taskUI_json.taskUI_arrow";
		t.visible = true;
		t.width = 19;
		t.x = 1105;
		t.y = 77.5;
		return t;
	};
	_proto.u_imgMask_i = function () {
		var t = new eui.Image();
		this.u_imgMask = t;
		t.bottom = 0;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(379,56,378,57);
		t.source = "cardMainUI_json.cardMainUI_bg2";
		t.touchEnabled = false;
		return t;
	};
	_proto.u_vsItem_i = function () {
		var t = new eui.VScrollBar();
		this.u_vsItem = t;
		t.height = 473;
		t.skinName = "VScrollBarSkin";
		t.width = 18.5;
		t.x = 1086;
		t.y = 84;
		return t;
	};
	_proto.u_btnBottom_i = function () {
		var t = new eui.Image();
		this.u_btnBottom = t;
		t.height = 13.5;
		t.source = "taskUI_json.taskUI_arrow";
		t.visible = true;
		t.width = 18.5;
		t.x = 1085.5;
		t.y = 561;
		return t;
	};
	return TaskMainUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/taskUI/view/TaskReceiveViewSkin.exml'] = window.skins.TaskReceiveViewSkin = (function (_super) {
	__extends(TaskReceiveViewSkin, _super);
	function TaskReceiveViewSkin() {
		_super.call(this);
		this.skinParts = ["u_taskName","u_imgJd1","u_imgJd2","u_txtJd","u_imgReceive","u_txtDesc"];
		
		this.height = 230;
		this.width = 845;
		this.elementsContent = [this._Image1_i(),this.u_taskName_i(),this.u_imgJd1_i(),this.u_imgJd2_i(),this.u_txtJd_i(),this.u_imgReceive_i(),this.u_txtDesc_i(),this._Group1_i()];
	}
	var _proto = TaskReceiveViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 148;
		t.scale9Grid = new egret.Rectangle(20,20,20,20);
		t.source = "taskUI_json.taskUI_zkbg";
		t.visible = true;
		t.width = 827;
		t.x = 8.8;
		t.y = 0;
		return t;
	};
	_proto.u_taskName_i = function () {
		var t = new eui.Label();
		this.u_taskName = t;
		t.fontFamily = "Microsoft YaHei";
		t.height = 52;
		t.left = 21;
		t.size = 20;
		t.text = "Label";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.width = 225;
		t.y = 20;
		return t;
	};
	_proto.u_imgJd1_i = function () {
		var t = new eui.Image();
		this.u_imgJd1 = t;
		t.height = 24.5;
		t.scale9Grid = new egret.Rectangle(10,6,10,7);
		t.source = "taskUI_json.taskUI_jd1";
		t.visible = true;
		t.width = 416;
		t.x = 20.5;
		t.y = 75.5;
		return t;
	};
	_proto.u_imgJd2_i = function () {
		var t = new eui.Image();
		this.u_imgJd2 = t;
		t.height = 24.5;
		t.scale9Grid = new egret.Rectangle(9,5,8,4);
		t.source = "taskUI_json.taskUI_jd2";
		t.visible = true;
		t.width = 416;
		t.x = 20.5;
		t.y = 75.5;
		return t;
	};
	_proto.u_txtJd_i = function () {
		var t = new eui.Label();
		this.u_txtJd = t;
		t.fontFamily = "Microsoft YaHei";
		t.height = 20;
		t.size = 16;
		t.text = "10/50";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.x = 212;
		t.y = 78;
		return t;
	};
	_proto.u_imgReceive_i = function () {
		var t = new eui.Image();
		this.u_imgReceive = t;
		t.source = "taskUI_json.taskUI_receive";
		t.x = 710;
		t.y = 54;
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.height = 58;
		t.left = 69;
		t.lineSpacing = 10;
		t.size = 20;
		t.text = "描述";
		t.textAlign = "left";
		t.textColor = 0x8E7E6F;
		t.verticalAlign = "top";
		t.width = 717;
		t.y = 167;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.height = 105.184;
		t.visible = false;
		t.width = 227.826;
		t.x = 463;
		t.y = 20;
		return t;
	};
	return TaskReceiveViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/taskUI/view/TaskViewSkin.exml'] = window.skins.TaskViewSkin = (function (_super) {
	__extends(TaskViewSkin, _super);
	function TaskViewSkin() {
		_super.call(this);
		this.skinParts = ["u_grpContent","u_imgBg","u_txtName","u_btnSpare"];
		
		this.height = 92;
		this.width = 845;
		this.elementsContent = [this.u_grpContent_i(),this.u_imgBg_i(),this.u_txtName_i(),this.u_btnSpare_i()];
	}
	var _proto = TaskViewSkin.prototype;

	_proto.u_grpContent_i = function () {
		var t = new eui.Group();
		this.u_grpContent = t;
		t.width = 845;
		t.x = 0;
		t.y = 71;
		return t;
	};
	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 92;
		t.width = 845;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.bold = true;
		t.fontFamily = "Microsoft YaHei";
		t.horizontalCenter = 9.5;
		t.size = 20;
		t.text = "Label";
		t.textAlign = "center";
		t.textColor = 0xFBFBD3;
		t.verticalAlign = "middle";
		t.y = 29;
		return t;
	};
	_proto.u_btnSpare_i = function () {
		var t = new eui.Image();
		this.u_btnSpare = t;
		t.alpha = 0;
		t.height = 92;
		t.source = "commonUI_json.commonUI_box";
		t.width = 845;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return TaskViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/turnTableUI/TurntableUISkin.exml'] = window.TurntableUISkin = (function (_super) {
	__extends(TurntableUISkin, _super);
	function TurntableUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgBlade1","u_imgBlade2","u_imgBlade3","u_imgBlade4","u_imgBlade5","u_imgBlade6","u_imgBlade7","u_imgBlade8","u_imgBlade9","u_imgBlade10","u_imgJiantou","u_imgRoll","u_imgJindu","u_txtJindu","u_imgRed","u_btnReward","u_txtTime","u_btnOnce","u_txtExpend1","u_imgIcon1","u_txtCost1","u_btnTen","u_txtExpend2","u_imgIcon2","u_txtCost2","u_btnClose"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_imgBlade1_i(),this.u_imgBlade2_i(),this.u_imgBlade3_i(),this.u_imgBlade4_i(),this.u_imgBlade5_i(),this.u_imgBlade6_i(),this.u_imgBlade7_i(),this.u_imgBlade8_i(),this.u_imgBlade9_i(),this.u_imgBlade10_i(),this.u_imgJiantou_i(),this.u_imgRoll_i(),this._Group1_i(),this._Image4_i(),this.u_imgRed_i(),this.u_btnReward_i(),this.u_txtTime_i(),this._Group3_i(),this._Group5_i(),this.u_btnClose_i()];
	}
	var _proto = TurntableUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 140;
		t.scale9Grid = new egret.Rectangle(135,57,136,2);
		t.source = "turntableUI_json.turntableUI_bg2";
		t.visible = true;
		t.x = 122;
		t.y = 717;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(203,552,204,1);
		t.source = "turntableUI_json.turntableUI_bg1";
		t.visible = true;
		t.x = 5;
		t.y = 209;
		return t;
	};
	_proto.u_imgBlade1_i = function () {
		var t = new eui.Image();
		this.u_imgBlade1 = t;
		t.anchorOffsetX = 75;
		t.anchorOffsetY = 65.5;
		t.source = "turntableUI_json.turntableUI_light";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 324;
		t.y = 322.5;
		return t;
	};
	_proto.u_imgBlade2_i = function () {
		var t = new eui.Image();
		this.u_imgBlade2 = t;
		t.anchorOffsetX = 75;
		t.anchorOffsetY = 65.5;
		t.rotation = 36;
		t.source = "turntableUI_json.turntableUI_light";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 424;
		t.y = 354.5;
		return t;
	};
	_proto.u_imgBlade3_i = function () {
		var t = new eui.Image();
		this.u_imgBlade3 = t;
		t.anchorOffsetX = 75;
		t.anchorOffsetY = 65.5;
		t.rotation = 72;
		t.source = "turntableUI_json.turntableUI_light";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 485;
		t.y = 438.5;
		return t;
	};
	_proto.u_imgBlade4_i = function () {
		var t = new eui.Image();
		this.u_imgBlade4 = t;
		t.anchorOffsetX = 75;
		t.anchorOffsetY = 65.5;
		t.rotation = 108;
		t.source = "turntableUI_json.turntableUI_light";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 484;
		t.y = 542.5;
		return t;
	};
	_proto.u_imgBlade5_i = function () {
		var t = new eui.Image();
		this.u_imgBlade5 = t;
		t.anchorOffsetX = 75;
		t.anchorOffsetY = 65.5;
		t.rotation = 144;
		t.source = "turntableUI_json.turntableUI_light";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 422;
		t.y = 625.5;
		return t;
	};
	_proto.u_imgBlade6_i = function () {
		var t = new eui.Image();
		this.u_imgBlade6 = t;
		t.anchorOffsetX = 75;
		t.anchorOffsetY = 65.5;
		t.rotation = 180;
		t.source = "turntableUI_json.turntableUI_light";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 323;
		t.y = 656.5;
		return t;
	};
	_proto.u_imgBlade7_i = function () {
		var t = new eui.Image();
		this.u_imgBlade7 = t;
		t.anchorOffsetX = 75;
		t.anchorOffsetY = 65.5;
		t.rotation = 216;
		t.source = "turntableUI_json.turntableUI_light";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 225;
		t.y = 624.5;
		return t;
	};
	_proto.u_imgBlade8_i = function () {
		var t = new eui.Image();
		this.u_imgBlade8 = t;
		t.anchorOffsetX = 75;
		t.anchorOffsetY = 65.5;
		t.rotation = 252;
		t.source = "turntableUI_json.turntableUI_light";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 164;
		t.y = 540.5;
		return t;
	};
	_proto.u_imgBlade9_i = function () {
		var t = new eui.Image();
		this.u_imgBlade9 = t;
		t.anchorOffsetX = 75;
		t.anchorOffsetY = 65.5;
		t.rotation = 288;
		t.source = "turntableUI_json.turntableUI_light";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 164;
		t.y = 436.5;
		return t;
	};
	_proto.u_imgBlade10_i = function () {
		var t = new eui.Image();
		this.u_imgBlade10 = t;
		t.anchorOffsetX = 75;
		t.anchorOffsetY = 65.5;
		t.rotation = 324;
		t.source = "turntableUI_json.turntableUI_light";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 225;
		t.y = 353.5;
		return t;
	};
	_proto.u_imgJiantou_i = function () {
		var t = new eui.Image();
		this.u_imgJiantou = t;
		t.anchorOffsetX = 80;
		t.anchorOffsetY = 156;
		t.source = "turntableUI_json.turntableUI_arrow1";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 325;
		t.y = 487;
		return t;
	};
	_proto.u_imgRoll_i = function () {
		var t = new eui.Image();
		this.u_imgRoll = t;
		t.anchorOffsetX = 82.5;
		t.anchorOffsetY = 82.5;
		t.source = "turntableUI_json.turntableUI_arrow2";
		t.touchEnabled = false;
		t.visible = true;
		t.x = 324.5;
		t.y = 489.5;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.x = 173;
		t.y = 751;
		t.elementsContent = [this._Image3_i(),this.u_imgJindu_i(),this.u_txtJindu_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(17,9,17,9);
		t.source = "turntableUI_json.turntableUI_jindu_di";
		t.visible = true;
		t.width = 254;
		t.x = 0;
		t.y = 11;
		return t;
	};
	_proto.u_imgJindu_i = function () {
		var t = new eui.Image();
		this.u_imgJindu = t;
		t.scale9Grid = new egret.Rectangle(5,16,194,17);
		t.source = "turntableUI_json.turntableUI_jindu";
		t.visible = true;
		t.width = 250;
		t.x = 2;
		t.y = 0;
		return t;
	};
	_proto.u_txtJindu_i = function () {
		var t = new eui.Label();
		this.u_txtJindu = t;
		t.bold = true;
		t.horizontalCenter = 4.5;
		t.size = 22;
		t.stroke = 1.5;
		t.text = "1/1";
		t.textColor = 0xFFF9D5;
		t.visible = true;
		t.y = 15;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "turntableUI_json.turntableUI_box";
		t.visible = true;
		t.x = 393;
		t.y = 723;
		return t;
	};
	_proto.u_imgRed_i = function () {
		var t = new eui.Image();
		this.u_imgRed = t;
		t.source = "commonsUI_json.commonsUI_red_1";
		t.x = 459;
		t.y = 728;
		return t;
	};
	_proto.u_btnReward_i = function () {
		var t = new eui.Image();
		this.u_btnReward = t;
		t.alpha = 0;
		t.source = "commonsUI_json.commonUI_box_1";
		t.x = 406;
		t.y = 728;
		return t;
	};
	_proto.u_txtTime_i = function () {
		var t = new eui.Label();
		this.u_txtTime = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.text = "Reset  00:00:00";
		t.textColor = 0x25E00C;
		t.y = 802;
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.width = 202;
		t.x = 89;
		t.y = 856;
		t.elementsContent = [this.u_btnOnce_i(),this._Group2_i()];
		return t;
	};
	_proto.u_btnOnce_i = function () {
		var t = new eui.Image();
		this.u_btnOnce = t;
		t.height = 66;
		t.source = "turntableUI_json.turntableUI_btn_once";
		t.visible = true;
		t.width = 200;
		t.x = 2;
		t.y = 0;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = -3;
		t.y = 66;
		t.elementsContent = [this.u_txtExpend1_i(),this.u_imgIcon1_i(),this.u_txtCost1_i()];
		return t;
	};
	_proto.u_txtExpend1_i = function () {
		var t = new eui.Label();
		this.u_txtExpend1 = t;
		t.bold = true;
		t.size = 22;
		t.stroke = 1.5;
		t.strokeColor = 0x202F46;
		t.text = "Cost:";
		t.textColor = 0xFFF4B2;
		t.visible = true;
		t.x = 0;
		t.y = 13;
		return t;
	};
	_proto.u_imgIcon1_i = function () {
		var t = new eui.Image();
		this.u_imgIcon1 = t;
		t.height = 45;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.width = 45;
		t.x = 54;
		t.y = 2;
		return t;
	};
	_proto.u_txtCost1_i = function () {
		var t = new eui.Label();
		this.u_txtCost1 = t;
		t.bold = true;
		t.size = 28;
		t.stroke = 1;
		t.strokeColor = 0x654747;
		t.text = "500";
		t.textColor = 0xFFF4B2;
		t.visible = true;
		t.x = 95;
		t.y = 11;
		return t;
	};
	_proto._Group5_i = function () {
		var t = new eui.Group();
		t.visible = true;
		t.width = 202;
		t.x = 355;
		t.y = 856;
		t.elementsContent = [this.u_btnTen_i(),this._Group4_i()];
		return t;
	};
	_proto.u_btnTen_i = function () {
		var t = new eui.Image();
		this.u_btnTen = t;
		t.height = 66;
		t.source = "turntableUI_json.turntableUI_btn_ten";
		t.visible = true;
		t.width = 200;
		t.x = 2;
		t.y = 0;
		return t;
	};
	_proto._Group4_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 5;
		t.y = 66;
		t.elementsContent = [this.u_txtExpend2_i(),this.u_imgIcon2_i(),this.u_txtCost2_i()];
		return t;
	};
	_proto.u_txtExpend2_i = function () {
		var t = new eui.Label();
		this.u_txtExpend2 = t;
		t.bold = true;
		t.size = 22;
		t.stroke = 1.5;
		t.strokeColor = 0x202F46;
		t.text = "Cost:";
		t.textColor = 0xFFF4B2;
		t.visible = true;
		t.x = -1;
		t.y = 13;
		return t;
	};
	_proto.u_imgIcon2_i = function () {
		var t = new eui.Image();
		this.u_imgIcon2 = t;
		t.height = 45;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.width = 45;
		t.x = 54;
		t.y = 2;
		return t;
	};
	_proto.u_txtCost2_i = function () {
		var t = new eui.Label();
		this.u_txtCost2 = t;
		t.bold = true;
		t.size = 28;
		t.stroke = 2;
		t.strokeColor = 0x6B5032;
		t.text = "4800";
		t.textColor = 0xFFF4B2;
		t.visible = true;
		t.x = 95;
		t.y = 11;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 94;
		t.source = "turntableUI_json.turntableUI_btn_close";
		t.visible = true;
		t.width = 85;
		t.x = 464;
		t.y = 274;
		return t;
	};
	return TurntableUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/turnTableUI/view/TurnRewardSkin.exml'] = window.TurnRewardSkin = (function (_super) {
	__extends(TurnRewardSkin, _super);
	function TurnRewardSkin() {
		_super.call(this);
		this.skinParts = ["u_imgTitle","u_item","u_grpItem"];
		
		this.height = 250;
		this.width = 357;
		this.elementsContent = [this.u_grpItem_i()];
	}
	var _proto = TurnRewardSkin.prototype;

	_proto.u_grpItem_i = function () {
		var t = new eui.Group();
		this.u_grpItem = t;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this.u_imgTitle_i(),this.u_item_i()];
		return t;
	};
	_proto.u_imgTitle_i = function () {
		var t = new eui.Image();
		this.u_imgTitle = t;
		t.source = "turntableUI_json.turntableUI_title";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_item_i = function () {
		var t = new eui.Image();
		this.u_item = t;
		t.height = 86;
		t.horizontalCenter = 2.5;
		t.width = 86;
		t.y = 164;
		return t;
	};
	return TurnRewardSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/MainFightViewSkin.exml'] = window.MainFightViewSkin = (function (_super) {
	__extends(MainFightViewSkin, _super);
	function MainFightViewSkin() {
		_super.call(this);
		this.skinParts = ["u_btnJian","u_btnAdd","u_btnAttack","u_btnNotice","u_btnTask"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_btnJian_i(),this.u_btnAdd_i(),this.u_btnAttack_i(),this.u_btnNotice_i(),this.u_btnTask_i()];
	}
	var _proto = MainFightViewSkin.prototype;

	_proto.u_btnJian_i = function () {
		var t = new eui.Image();
		this.u_btnJian = t;
		t.source = "userMainUI_json.userMainUI_d_btn_jian";
		t.x = 917.992;
		t.y = 575.022;
		return t;
	};
	_proto.u_btnAdd_i = function () {
		var t = new eui.Image();
		this.u_btnAdd = t;
		t.source = "userMainUI_json.userMainUI_d_btn_add";
		t.x = 1064.992;
		t.y = 574.016;
		return t;
	};
	_proto.u_btnAttack_i = function () {
		var t = new eui.Image();
		this.u_btnAttack = t;
		t.height = 130;
		t.source = "userMainUI_json.userMainUI_attack_btn";
		t.width = 130;
		t.x = 948.472;
		t.y = 443.273;
		return t;
	};
	_proto.u_btnNotice_i = function () {
		var t = new eui.Image();
		this.u_btnNotice = t;
		t.height = 44;
		t.source = "userMainUI_json.userMainUI_u_btn_lt";
		t.width = 44;
		t.x = 1066.166;
		t.y = 225.353;
		return t;
	};
	_proto.u_btnTask_i = function () {
		var t = new eui.Group();
		this.u_btnTask = t;
		t.height = 44;
		t.width = 44;
		t.x = 1063.94;
		t.y = 161.35;
		t.elementsContent = [this._Image1_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_u_btn_rw";
		t.x = 0;
		t.y = 0;
		return t;
	};
	return MainFightViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/MainSceneViewSkin.exml'] = window.MainSceneViewSkin = (function (_super) {
	__extends(MainSceneViewSkin, _super);
	function MainSceneViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_imgScrollBg","u_btnScene","u_btnChooseSix","u_btnMultiplayer","u_btnQuickOpen","u_mcRightInfo","u_btnSet","u_txtName","u_imgExp","u_imgSex","u_btnVip","u_grpAvatar","u_imgBottom","u_grpIcon1","u_btnEntrance1","u_grpIcon2","u_btnEntrance2","u_grpIcon3","u_btnEntrance3","u_grpIcon4","u_btnEntrance4","u_grpIcon5","u_btnEntrance5","u_grpIcon6","u_btnEntrance6","u_imgLine1","u_imgLine2","u_imgLine3","u_imgLine4","u_imgLine5","u_imgLight","u_grpBottom"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this.u_imgBg_i(),this.u_imgScrollBg_i(),this.u_mcRightInfo_i(),this.u_grpAvatar_i(),this.u_grpBottom_i()];
	}
	var _proto = MainSceneViewSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.visible = true;
		return t;
	};
	_proto.u_imgScrollBg_i = function () {
		var t = new eui.Image();
		this.u_imgScrollBg = t;
		t.height = 113;
		t.scale9Grid = new egret.Rectangle(24,14,362,85);
		t.visible = true;
		t.width = 485;
		t.x = 0;
		t.y = 475;
		return t;
	};
	_proto.u_mcRightInfo_i = function () {
		var t = new eui.Group();
		this.u_mcRightInfo = t;
		t.x = 575;
		t.y = 48;
		t.elementsContent = [this.u_btnScene_i(),this.u_btnChooseSix_i(),this.u_btnMultiplayer_i(),this.u_btnQuickOpen_i()];
		return t;
	};
	_proto.u_btnScene_i = function () {
		var t = new eui.Group();
		this.u_btnScene = t;
		t.height = 114;
		t.width = 360;
		t.x = 135;
		t.y = 94;
		t.elementsContent = [this._Image1_i(),this._Image2_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "sceneMainUI_json.sceneMainUI_btn_zz_bg";
		t.visible = true;
		t.x = 6.817;
		t.y = -38.897;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "sceneMainUI_json.sceneMainUI_img_zz";
		t.visible = true;
		t.x = 38.97;
		t.y = 1.752;
		return t;
	};
	_proto.u_btnChooseSix_i = function () {
		var t = new eui.Group();
		this.u_btnChooseSix = t;
		t.height = 114;
		t.width = 171;
		t.x = 137;
		t.y = 221;
		t.elementsContent = [this._Image3_i(),this._Image4_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.source = "sceneMainUI_json.sceneMainUI_btn_jdc_bg";
		t.visible = true;
		t.x = -54.135;
		t.y = -20.852;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "sceneMainUI_json.sceneMainUI_img_jdc";
		t.x = -36.942;
		t.y = 56.694;
		return t;
	};
	_proto.u_btnMultiplayer_i = function () {
		var t = new eui.Group();
		this.u_btnMultiplayer = t;
		t.height = 114;
		t.width = 171;
		t.x = 326;
		t.y = 221;
		t.elementsContent = [this._Image5_i(),this._Image6_i()];
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "sceneMainUI_json.sceneMainUI_btn_dr_bg";
		t.visible = true;
		t.x = -32.882;
		t.y = -20.852;
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.source = "sceneMainUI_json.sceneMainUI_img_yj";
		t.x = -14.466;
		t.y = 58.308;
		return t;
	};
	_proto.u_btnQuickOpen_i = function () {
		var t = new eui.Group();
		this.u_btnQuickOpen = t;
		t.height = 114;
		t.width = 360;
		t.x = 135;
		t.y = 346;
		t.elementsContent = [this._Image7_i(),this._Image8_i()];
		return t;
	};
	_proto._Image7_i = function () {
		var t = new eui.Image();
		t.source = "sceneMainUI_json.sceneMainUI_btn_ks_bg";
		t.visible = true;
		t.x = 46.917;
		t.y = 2.406;
		return t;
	};
	_proto._Image8_i = function () {
		var t = new eui.Image();
		t.source = "sceneMainUI_json.sceneMainUI_img_ksks";
		t.x = 143.11;
		t.y = 41.852;
		return t;
	};
	_proto.u_grpAvatar_i = function () {
		var t = new eui.Group();
		this.u_grpAvatar = t;
		t.height = 103.103;
		t.visible = true;
		t.width = 284.927;
		t.elementsContent = [this.u_btnSet_i(),this.u_txtName_i(),this._Image9_i(),this.u_imgExp_i(),this.u_imgSex_i(),this.u_btnVip_i()];
		return t;
	};
	_proto.u_btnSet_i = function () {
		var t = new eui.Image();
		this.u_btnSet = t;
		t.alpha = 0;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 75.8;
		t.scale9Grid = new egret.Rectangle(1,1,8,8);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_box";
		t.visible = true;
		t.width = 71.2;
		t.x = 11.4;
		t.y = 11.59;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 16;
		t.strokeColor = 0x168702;
		t.text = "S.000";
		t.textAlign = "left";
		t.textColor = 0xfff6d3;
		t.visible = true;
		t.x = 96.268;
		t.y = 13.268;
		return t;
	};
	_proto._Image9_i = function () {
		var t = new eui.Image();
		t.source = "sceneMainUI_json.sceneMainUI_img_jd1";
		t.visible = true;
		t.x = 92.778;
		t.y = 37.632;
		return t;
	};
	_proto.u_imgExp_i = function () {
		var t = new eui.Image();
		this.u_imgExp = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "sceneMainUI_json.sceneMainUI_img_jd2";
		t.visible = true;
		t.width = 167;
		t.x = 101.656;
		t.y = 42.634;
		return t;
	};
	_proto.u_imgSex_i = function () {
		var t = new eui.Image();
		this.u_imgSex = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_json.commonUI_sex_0";
		t.visible = false;
		t.x = -2;
		t.y = -2;
		return t;
	};
	_proto.u_btnVip_i = function () {
		var t = new eui.Image();
		this.u_btnVip = t;
		t.alpha = 0;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 23.8;
		t.scale9Grid = new egret.Rectangle(1,1,8,8);
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "commonUI_box";
		t.visible = false;
		t.width = 99.2;
		t.x = 76;
		t.y = 26;
		return t;
	};
	_proto.u_grpBottom_i = function () {
		var t = new eui.Group();
		this.u_grpBottom = t;
		t.visible = true;
		t.x = 0.396;
		t.y = 556.33;
		t.elementsContent = [this.u_imgBottom_i(),this.u_btnEntrance1_i(),this.u_btnEntrance2_i(),this.u_btnEntrance3_i(),this.u_btnEntrance4_i(),this.u_btnEntrance5_i(),this.u_btnEntrance6_i(),this.u_imgLine1_i(),this.u_imgLine2_i(),this.u_imgLine3_i(),this.u_imgLine4_i(),this.u_imgLine5_i(),this.u_imgLight_i()];
		return t;
	};
	_proto.u_imgBottom_i = function () {
		var t = new eui.Image();
		this.u_imgBottom = t;
		t.anchorOffsetX = 0;
		t.horizontalCenter = 0;
		t.source = "sceneMainUI_json.sceneMainUI_navBg";
		t.visible = true;
		t.width = 1136;
		t.y = 0.524;
		return t;
	};
	_proto.u_btnEntrance1_i = function () {
		var t = new eui.Group();
		this.u_btnEntrance1 = t;
		t.height = 68;
		t.name = "u_btnEntrance1";
		t.touchChildren = false;
		t.visible = true;
		t.width = 187;
		t.y = 14.925;
		t.elementsContent = [this.u_grpIcon1_i()];
		return t;
	};
	_proto.u_grpIcon1_i = function () {
		var t = new eui.Group();
		this.u_grpIcon1 = t;
		t.height = 36;
		t.scaleX = 1;
		t.scaleY = 1;
		t.width = 36;
		t.x = 77;
		t.y = 17;
		t.elementsContent = [this._Image10_i()];
		return t;
	};
	_proto._Image10_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_d_btn_1";
		t.visible = true;
		t.width = 36;
		t.y = 0;
		return t;
	};
	_proto.u_btnEntrance2_i = function () {
		var t = new eui.Group();
		this.u_btnEntrance2 = t;
		t.height = 68;
		t.name = "u_btnEntrance2";
		t.touchChildren = false;
		t.width = 187;
		t.x = 190.405;
		t.y = 14.663;
		t.elementsContent = [this.u_grpIcon2_i()];
		return t;
	};
	_proto.u_grpIcon2_i = function () {
		var t = new eui.Group();
		this.u_grpIcon2 = t;
		t.height = 36;
		t.scaleX = 1;
		t.scaleY = 1;
		t.width = 36;
		t.x = 75;
		t.y = 18;
		t.elementsContent = [this._Image11_i()];
		return t;
	};
	_proto._Image11_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_d_btn_2";
		t.width = 36;
		t.x = 0.2459999999999809;
		t.y = 0;
		return t;
	};
	_proto.u_btnEntrance3_i = function () {
		var t = new eui.Group();
		this.u_btnEntrance3 = t;
		t.height = 68;
		t.name = "u_btnEntrance3";
		t.touchChildren = false;
		t.width = 187;
		t.x = 378.487;
		t.y = 14.663;
		t.elementsContent = [this.u_grpIcon3_i()];
		return t;
	};
	_proto.u_grpIcon3_i = function () {
		var t = new eui.Group();
		this.u_grpIcon3 = t;
		t.height = 36;
		t.scaleX = 1;
		t.scaleY = 1;
		t.width = 36;
		t.x = 75;
		t.y = 18;
		t.elementsContent = [this._Image12_i()];
		return t;
	};
	_proto._Image12_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_d_btn_3";
		t.width = 36;
		t.x = 1.9099999999999682;
		t.y = 0;
		return t;
	};
	_proto.u_btnEntrance4_i = function () {
		var t = new eui.Group();
		this.u_btnEntrance4 = t;
		t.height = 68;
		t.name = "u_btnEntrance4";
		t.touchChildren = false;
		t.width = 187;
		t.x = 568.383;
		t.y = 14.663;
		t.elementsContent = [this.u_grpIcon4_i()];
		return t;
	};
	_proto.u_grpIcon4_i = function () {
		var t = new eui.Group();
		this.u_grpIcon4 = t;
		t.height = 36;
		t.scaleX = 1;
		t.scaleY = 1;
		t.width = 36;
		t.x = 75;
		t.y = 18;
		t.elementsContent = [this._Image13_i()];
		return t;
	};
	_proto._Image13_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_d_btn_4";
		t.width = 36;
		t.x = 0.010999999999967258;
		t.y = 0;
		return t;
	};
	_proto.u_btnEntrance5_i = function () {
		var t = new eui.Group();
		this.u_btnEntrance5 = t;
		t.height = 68;
		t.name = "u_btnEntrance5";
		t.touchChildren = false;
		t.width = 187;
		t.x = 757.016;
		t.y = 14.663;
		t.elementsContent = [this.u_grpIcon5_i()];
		return t;
	};
	_proto.u_grpIcon5_i = function () {
		var t = new eui.Group();
		this.u_grpIcon5 = t;
		t.height = 36;
		t.width = 36;
		t.x = 75;
		t.y = 18;
		t.elementsContent = [this._Image14_i()];
		return t;
	};
	_proto._Image14_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_d_btn_5";
		t.width = 36;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnEntrance6_i = function () {
		var t = new eui.Group();
		this.u_btnEntrance6 = t;
		t.height = 68;
		t.name = "u_btnEntrance6";
		t.touchChildren = false;
		t.width = 187;
		t.x = 947.642;
		t.y = 14.663;
		t.elementsContent = [this.u_grpIcon6_i()];
		return t;
	};
	_proto.u_grpIcon6_i = function () {
		var t = new eui.Group();
		this.u_grpIcon6 = t;
		t.height = 36;
		t.scaleX = 1;
		t.scaleY = 1;
		t.width = 36;
		t.x = 85;
		t.y = 28;
		t.elementsContent = [this._Image15_i()];
		return t;
	};
	_proto._Image15_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_d_btn_6";
		t.width = 36;
		t.x = -10;
		t.y = -10;
		return t;
	};
	_proto.u_imgLine1_i = function () {
		var t = new eui.Image();
		this.u_imgLine1 = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "sceneMainUI_json.sceneMainUI_nav_line";
		t.x = 187.764;
		t.y = 25.291;
		return t;
	};
	_proto.u_imgLine2_i = function () {
		var t = new eui.Image();
		this.u_imgLine2 = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "sceneMainUI_json.sceneMainUI_nav_line";
		t.x = 375.861;
		t.y = 25.291;
		return t;
	};
	_proto.u_imgLine3_i = function () {
		var t = new eui.Image();
		this.u_imgLine3 = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "sceneMainUI_json.sceneMainUI_nav_line";
		t.x = 566;
		t.y = 25.291;
		return t;
	};
	_proto.u_imgLine4_i = function () {
		var t = new eui.Image();
		this.u_imgLine4 = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "sceneMainUI_json.sceneMainUI_nav_line";
		t.x = 754.521;
		t.y = 25.291;
		return t;
	};
	_proto.u_imgLine5_i = function () {
		var t = new eui.Image();
		this.u_imgLine5 = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "sceneMainUI_json.sceneMainUI_nav_line";
		t.x = 944.75;
		t.y = 25.291;
		return t;
	};
	_proto.u_imgLight_i = function () {
		var t = new eui.Image();
		this.u_imgLight = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.scaleY = 1;
		t.source = "sceneMainUI_json.sceneMainUI_img_select";
		t.touchEnabled = false;
		t.visible = false;
		t.x = 0;
		t.y = 14.401;
		return t;
	};
	return MainSceneViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/render/BubbleItemRenderSkin.exml'] = window.BubbleItemRenderSkin = (function (_super) {
	__extends(BubbleItemRenderSkin, _super);
	function BubbleItemRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtContext","u_imgOver"];
		
		this.height = 72;
		this.width = 310;
		this.elementsContent = [this._Image1_i(),this.u_txtContext_i(),this.u_imgOver_i()];
	}
	var _proto = BubbleItemRenderSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_u_line";
		t.width = 270;
		t.x = 20;
		t.y = 70;
		return t;
	};
	_proto.u_txtContext_i = function () {
		var t = new eui.Label();
		this.u_txtContext = t;
		t.anchorOffsetX = 0;
		t.height = 68;
		t.lineSpacing = 6;
		t.size = 16;
		t.text = "就这？你太菜了！";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.touchEnabled = false;
		t.verticalAlign = "middle";
		t.width = 306;
		t.x = 2;
		t.y = 2;
		return t;
	};
	_proto.u_imgOver_i = function () {
		var t = new eui.Image();
		this.u_imgOver = t;
		t.alpha = 0;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 68;
		t.scale9Grid = new egret.Rectangle(12,12,76,76);
		t.source = "commonUI_box";
		t.visible = true;
		t.width = 306;
		t.x = 2;
		t.y = 2;
		return t;
	};
	return BubbleItemRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/render/StickerItemRenderSkin.exml'] = window.skins.StickerItemRenderSkin = (function (_super) {
	__extends(StickerItemRenderSkin, _super);
	function StickerItemRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgSticker","u_imgLock","u_txtOutput"];
		
		this.height = 90;
		this.width = 90;
		this.elementsContent = [this.u_imgSticker_i(),this.u_imgLock_i(),this.u_txtOutput_i()];
	}
	var _proto = StickerItemRenderSkin.prototype;

	_proto.u_imgSticker_i = function () {
		var t = new eui.Image();
		this.u_imgSticker = t;
		t.height = 90;
		t.width = 90;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgLock_i = function () {
		var t = new eui.Image();
		this.u_imgLock = t;
		t.height = 26;
		t.horizontalCenter = 0;
		t.source = "roleUI_json.roleUI_lock";
		t.verticalCenter = 0;
		t.width = 20;
		return t;
	};
	_proto.u_txtOutput_i = function () {
		var t = new eui.Label();
		this.u_txtOutput = t;
		t.horizontalCenter = 0;
		t.size = 12;
		t.text = "获取途径";
		t.textColor = 0xF0E4B0;
		t.y = 76;
		return t;
	};
	return StickerItemRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/skill/MainAttackSkillIconSkin.exml'] = window.skins.MainAttackSkillIconSkin = (function (_super) {
	__extends(MainAttackSkillIconSkin, _super);
	function MainAttackSkillIconSkin() {
		_super.call(this);
		this.skinParts = ["u_imgIcon","u_txtCd"];
		
		this.height = 30;
		this.width = 30;
		this.elementsContent = [this.u_imgIcon_i(),this.u_txtCd_i()];
	}
	var _proto = MainAttackSkillIconSkin.prototype;

	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.source = "userMainUI_json.userMainUI_d_skill_107";
		return t;
	};
	_proto.u_txtCd_i = function () {
		var t = new eui.Label();
		this.u_txtCd = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.border = false;
		t.borderColor = 0x0A0909;
		t.fontFamily = "Arial";
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 16;
		t.stroke = 1;
		t.strokeColor = 0x131313;
		t.text = "60";
		t.textAlign = "right";
		t.textColor = 0xFFFFFF;
		t.y = 13.164;
		return t;
	};
	return MainAttackSkillIconSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/skill/MainAttackSkillViewSkin.exml'] = window.skins.MainAttackSkillViewSkin = (function (_super) {
	__extends(MainAttackSkillViewSkin, _super);
	function MainAttackSkillViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBj"];
		
		this.height = 150;
		this.width = 375;
		this.elementsContent = [this.u_imgBj_i(),this._Image1_i()];
	}
	var _proto = MainAttackSkillViewSkin.prototype;

	_proto.u_imgBj_i = function () {
		var t = new eui.Image();
		this.u_imgBj = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 50;
		t.scale9Grid = new egret.Rectangle(17,15,2,2);
		t.source = "userMainUI_json.userMainUI_u_tishi";
		t.width = 371;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "commonUI_json.commonUI_icon_gold";
		t.x = 13;
		t.y = 6;
		return t;
	};
	return MainAttackSkillViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/view/BubbleViewSkin.exml'] = window.BubbleViewSkin = (function (_super) {
	__extends(BubbleViewSkin, _super);
	function BubbleViewSkin() {
		_super.call(this);
		this.skinParts = ["u_chatListItem","u_chatScrollerItem","u_faceListItem","u_faceScrollerItem","u_imgChatStatus","u_btnChat","u_imgFaceStatus","u_btnFace","u_txtTitle","u_btnClose"];
		
		this.height = 640;
		this.width = 380;
		this.elementsContent = [this._Image1_i(),this.u_chatScrollerItem_i(),this.u_faceScrollerItem_i(),this._Group3_i(),this._Group4_i(),this._Image2_i(),this.u_txtTitle_i(),this.u_btnClose_i()];
	}
	var _proto = BubbleViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 640;
		t.scale9Grid = new egret.Rectangle(6,76,9,8);
		t.source = "userMainUI_json.userMainUI_xinxi_bj";
		t.visible = true;
		t.width = 380;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_chatScrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_chatScrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 566;
		t.scaleX = 1;
		t.scaleY = 1;
		t.visible = true;
		t.width = 310;
		t.x = 0;
		t.y = 72;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_chatListItem_i()];
		return t;
	};
	_proto.u_chatListItem_i = function () {
		var t = new eui.List();
		this.u_chatListItem = t;
		return t;
	};
	_proto.u_faceScrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_faceScrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 566;
		t.scaleX = 1;
		t.scaleY = 1;
		t.visible = true;
		t.width = 310;
		t.x = 0;
		t.y = 72;
		t.viewport = this._Group2_i();
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_faceListItem_i()];
		return t;
	};
	_proto.u_faceListItem_i = function () {
		var t = new eui.List();
		this.u_faceListItem = t;
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.height = 283;
		t.width = 70;
		t.x = 310;
		t.y = 72;
		t.elementsContent = [this.u_imgChatStatus_i(),this.u_btnChat_i()];
		return t;
	};
	_proto.u_imgChatStatus_i = function () {
		var t = new eui.Image();
		this.u_imgChatStatus = t;
		t.height = 283;
		t.source = "userMainUI_json.userMainUI_u_select";
		t.verticalCenter = 0;
		t.width = 70;
		t.x = 0;
		return t;
	};
	_proto.u_btnChat_i = function () {
		var t = new eui.Image();
		this.u_btnChat = t;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_u_btn_lt";
		t.verticalCenter = 0;
		return t;
	};
	_proto._Group4_i = function () {
		var t = new eui.Group();
		t.height = 283;
		t.width = 70;
		t.x = 310;
		t.y = 355;
		t.elementsContent = [this.u_imgFaceStatus_i(),this.u_btnFace_i()];
		return t;
	};
	_proto.u_imgFaceStatus_i = function () {
		var t = new eui.Image();
		this.u_imgFaceStatus = t;
		t.height = 283;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_u_select";
		t.verticalCenter = 0;
		t.width = 70;
		return t;
	};
	_proto.u_btnFace_i = function () {
		var t = new eui.Image();
		this.u_btnFace = t;
		t.horizontalCenter = 0;
		t.source = "userMainUI_json.userMainUI_u_btn_lt";
		t.verticalCenter = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_xinxi_tupiao";
		t.x = 20;
		t.y = 23;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.height = 27;
		t.size = 16;
		t.text = "快捷信息";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.x = 57;
		t.y = 23;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 16;
		t.source = "userMainUI_json.userMainUI_u_btn_gb";
		t.width = 16;
		t.x = 334;
		t.y = 29;
		return t;
	};
	return BubbleViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/view/DashIconViewSkin.exml'] = window.DashIconViewSkin = (function (_super) {
	__extends(DashIconViewSkin, _super);
	function DashIconViewSkin() {
		_super.call(this);
		this.skinParts = ["u_power0","u_power1","u_power2","u_power3","u_jiantou","u_txtCd"];
		
		this.height = 90;
		this.width = 90;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_power0_i(),this.u_power1_i(),this.u_power2_i(),this.u_power3_i(),this.u_jiantou_i(),this.u_txtCd_i()];
	}
	var _proto = DashIconViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_nqz";
		t.touchEnabled = false;
		t.x = 7;
		t.y = 8;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.scaleX = 1.1;
		t.scaleY = 1.1;
		t.source = "userMainUI_json.userMainUI_d_skill_bj";
		t.touchEnabled = false;
		t.x = -2.1;
		t.y = -2.2;
		return t;
	};
	_proto.u_power0_i = function () {
		var t = new eui.Image();
		this.u_power0 = t;
		t.anchorOffsetX = 44;
		t.anchorOffsetY = 42.81;
		t.rotation = 181.23;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "userMainUI_json.userMainUI_d_skill_power1";
		t.touchEnabled = false;
		t.x = 47.67;
		t.y = 47.2;
		return t;
	};
	_proto.u_power1_i = function () {
		var t = new eui.Image();
		this.u_power1 = t;
		t.anchorOffsetX = 44;
		t.anchorOffsetY = 42.81;
		t.rotation = 89.4;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "userMainUI_json.userMainUI_d_skill_power1";
		t.touchEnabled = false;
		t.x = 48.98;
		t.y = 43.58;
		return t;
	};
	_proto.u_power2_i = function () {
		var t = new eui.Image();
		this.u_power2 = t;
		t.anchorOffsetX = 44;
		t.anchorOffsetY = 42.81;
		t.rotation = 359.73;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "userMainUI_json.userMainUI_d_skill_power1";
		t.touchEnabled = false;
		t.x = 44.32;
		t.y = 41.98;
		return t;
	};
	_proto.u_power3_i = function () {
		var t = new eui.Image();
		this.u_power3 = t;
		t.anchorOffsetX = 44;
		t.anchorOffsetY = 42.81;
		t.rotation = 271.46;
		t.scaleX = 0.8;
		t.scaleY = 0.8;
		t.source = "userMainUI_json.userMainUI_d_skill_power1";
		t.touchEnabled = false;
		t.x = 42.3;
		t.y = 45.97;
		return t;
	};
	_proto.u_jiantou_i = function () {
		var t = new eui.Image();
		this.u_jiantou = t;
		t.anchorOffsetX = 21.25;
		t.anchorOffsetY = 82;
		t.height = 82;
		t.scale9Grid = new egret.Rectangle(17,29,9,19);
		t.source = "userMainUI_json.userMainUI_d_skill_power2";
		t.touchEnabled = false;
		t.x = 44.75;
		t.y = 45.65;
		return t;
	};
	_proto.u_txtCd_i = function () {
		var t = new eui.Label();
		this.u_txtCd = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.border = false;
		t.borderColor = 0x0A0909;
		t.fontFamily = "Arial";
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 26;
		t.stroke = 1;
		t.strokeColor = 0x131313;
		t.text = "60";
		t.textAlign = "right";
		t.textColor = 0xFFFFFF;
		t.verticalCenter = 0;
		t.visible = false;
		return t;
	};
	return DashIconViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/view/DebugUISkin.exml'] = window.DebugUISkin = (function (_super) {
	__extends(DebugUISkin, _super);
	function DebugUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgDraw","u_textInput","u_btnSend","u_btnClose"];
		
		this.height = 100;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this.u_imgDraw_i(),this._Group1_i()];
	}
	var _proto = DebugUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 100;
		t.scale9Grid = new egret.Rectangle(3,3,4,4);
		t.source = "commonUI_box";
		t.width = 640;
		return t;
	};
	_proto.u_imgDraw_i = function () {
		var t = new eui.Group();
		this.u_imgDraw = t;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this._Image2_i(),this._Label1_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 39;
		t.scale9Grid = new egret.Rectangle(36,8,56,9);
		t.source = "commonUI_di_1";
		t.width = 640;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.size = 22;
		t.text = "Debug调试";
		t.textColor = 0xFFFFFF;
		t.x = 272;
		t.y = 8;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.bottom = 0;
		t.x = 0;
		t.elementsContent = [this.u_textInput_i(),this.u_btnSend_i(),this.u_btnClose_i()];
		return t;
	};
	_proto.u_textInput_i = function () {
		var t = new eui.EditableText();
		this.u_textInput = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bold = true;
		t.height = 34;
		t.prompt = "请输入文本...";
		t.promptColor = 0xffffff;
		t.size = 26;
		t.text = "";
		t.textColor = 0xFFFFFF;
		t.width = 395;
		t.x = 13;
		t.y = 13;
		return t;
	};
	_proto.u_btnSend_i = function () {
		var t = new eui.Group();
		this.u_btnSend = t;
		t.visible = true;
		t.x = 447;
		t.y = 0;
		t.elementsContent = [this._Image3_i(),this._Label2_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 60;
		t.scale9Grid = new egret.Rectangle(2,2,1,1);
		t.source = "commonUI_box_0";
		t.visible = true;
		t.width = 113;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Label2_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 18;
		t.text = "调试";
		t.textColor = 0xffffff;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.scaleX = -1;
		t.source = "commonUI_btn_close_1";
		t.x = 618;
		t.y = 20;
		return t;
	};
	return DebugUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/view/MainTaskViewSkin.exml'] = window.MainTaskViewSkin = (function (_super) {
	__extends(MainTaskViewSkin, _super);
	function MainTaskViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_txtTask","u_btnTask"];
		
		this.height = 68;
		this.width = 291;
		this.elementsContent = [this.u_imgBg_i(),this.u_txtTask_i(),this.u_btnTask_i()];
	}
	var _proto = MainTaskViewSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.scale9Grid = new egret.Rectangle(68,8,170,52);
		t.source = "userMainUI_json.userMainUI_zx";
		t.width = 162;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtTask_i = function () {
		var t = new eui.Label();
		this.u_txtTask = t;
		t.bold = true;
		t.size = 18;
		t.text = "任务描述";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.x = 70.5;
		t.y = 22;
		return t;
	};
	_proto.u_btnTask_i = function () {
		var t = new eui.Image();
		this.u_btnTask = t;
		t.alpha = 0;
		t.height = 68;
		t.source = "commonUI_json.commonUI_box";
		t.width = 291;
		return t;
	};
	return MainTaskViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/view/MenuViewSkin.exml'] = window.skins.MenuViewSkin = (function (_super) {
	__extends(MenuViewSkin, _super);
	function MenuViewSkin() {
		_super.call(this);
		this.skinParts = ["u_btnClose","u_txtTitle","u_btnHero","u_btnBag","u_btnShop","u_btnShare","u_btnMail","u_btnContact","u_btnExit"];
		
		this.height = 640;
		this.width = 260;
		this.elementsContent = [this._Image1_i(),this.u_btnClose_i(),this._Image2_i(),this.u_txtTitle_i(),this.u_btnHero_i(),this.u_btnBag_i(),this.u_btnShop_i(),this.u_btnShare_i(),this.u_btnMail_i(),this.u_btnContact_i(),this.u_btnExit_i()];
	}
	var _proto = MenuViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.height = 640;
		t.scale9Grid = new egret.Rectangle(33,80,34,11);
		t.source = "userMainUI_json.userMainUI_caidan_bj";
		t.width = 260;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 16;
		t.source = "userMainUI_json.userMainUI_u_btn_gb";
		t.width = 16;
		t.x = 224;
		t.y = 29;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "commonUI_json.commonUI_head_btn";
		t.x = 20;
		t.y = 27;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.height = 20;
		t.size = 16;
		t.text = "菜单";
		t.textColor = 0xF0E4B0;
		t.verticalAlign = "middle";
		t.x = 57;
		t.y = 27;
		return t;
	};
	_proto.u_btnHero_i = function () {
		var t = new eui.Group();
		this.u_btnHero = t;
		t.height = 81;
		t.width = 260;
		t.y = 72;
		t.elementsContent = [this._Image3_i(),this._Image4_i(),this._Image5_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_u_line";
		t.width = 220;
		t.x = 20;
		t.y = 78;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_1";
		t.verticalCenter = 0;
		t.x = 86;
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_1_name";
		t.verticalCenter = 0;
		t.x = 142;
		return t;
	};
	_proto.u_btnBag_i = function () {
		var t = new eui.Group();
		this.u_btnBag = t;
		t.height = 81;
		t.width = 260;
		t.x = 0;
		t.y = 153;
		t.elementsContent = [this._Image6_i(),this._Image7_i(),this._Image8_i()];
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_u_line";
		t.width = 220;
		t.x = 20;
		t.y = 78;
		return t;
	};
	_proto._Image7_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_2";
		t.verticalCenter = 0;
		t.x = 86;
		return t;
	};
	_proto._Image8_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_2_name";
		t.verticalCenter = 0;
		t.x = 142;
		return t;
	};
	_proto.u_btnShop_i = function () {
		var t = new eui.Group();
		this.u_btnShop = t;
		t.height = 81;
		t.width = 260;
		t.x = 0;
		t.y = 234;
		t.elementsContent = [this._Image9_i(),this._Image10_i(),this._Image11_i()];
		return t;
	};
	_proto._Image9_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_u_line";
		t.width = 220;
		t.x = 20;
		t.y = 78;
		return t;
	};
	_proto._Image10_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_3";
		t.verticalCenter = 0;
		t.x = 86;
		return t;
	};
	_proto._Image11_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_3_name";
		t.verticalCenter = 0;
		t.x = 142;
		return t;
	};
	_proto.u_btnShare_i = function () {
		var t = new eui.Group();
		this.u_btnShare = t;
		t.height = 81;
		t.width = 260;
		t.x = 0;
		t.y = 315;
		t.elementsContent = [this._Image12_i(),this._Image13_i(),this._Image14_i()];
		return t;
	};
	_proto._Image12_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_u_line";
		t.width = 220;
		t.x = 20;
		t.y = 78;
		return t;
	};
	_proto._Image13_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_4";
		t.verticalCenter = 0;
		t.x = 86;
		return t;
	};
	_proto._Image14_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_4_name";
		t.verticalCenter = 0;
		t.x = 142;
		return t;
	};
	_proto.u_btnMail_i = function () {
		var t = new eui.Group();
		this.u_btnMail = t;
		t.height = 81;
		t.width = 260;
		t.x = 0;
		t.y = 396;
		t.elementsContent = [this._Image15_i(),this._Image16_i(),this._Image17_i()];
		return t;
	};
	_proto._Image15_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_u_line";
		t.width = 220;
		t.x = 20;
		t.y = 78;
		return t;
	};
	_proto._Image16_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_5";
		t.verticalCenter = 0;
		t.x = 86;
		return t;
	};
	_proto._Image17_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_5_name";
		t.verticalCenter = 0;
		t.x = 142;
		return t;
	};
	_proto.u_btnContact_i = function () {
		var t = new eui.Group();
		this.u_btnContact = t;
		t.height = 81;
		t.width = 260;
		t.x = 0;
		t.y = 477;
		t.elementsContent = [this._Image18_i(),this._Image19_i(),this._Image20_i()];
		return t;
	};
	_proto._Image18_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_u_line";
		t.width = 220;
		t.x = 20;
		t.y = 78;
		return t;
	};
	_proto._Image19_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_6";
		t.verticalCenter = 0;
		t.x = 86;
		return t;
	};
	_proto._Image20_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_6_name";
		t.verticalCenter = 0;
		t.x = 142;
		return t;
	};
	_proto.u_btnExit_i = function () {
		var t = new eui.Group();
		this.u_btnExit = t;
		t.height = 81;
		t.width = 260;
		t.x = 0;
		t.y = 558;
		t.elementsContent = [this._Image21_i(),this._Image22_i(),this._Image23_i()];
		return t;
	};
	_proto._Image21_i = function () {
		var t = new eui.Image();
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "userMainUI_json.userMainUI_u_line";
		t.width = 220;
		t.x = 20;
		t.y = 78;
		return t;
	};
	_proto._Image22_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_7";
		t.verticalCenter = 0;
		t.x = 86;
		return t;
	};
	_proto._Image23_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_d_btn_7_name";
		t.verticalCenter = 0;
		t.x = 142;
		return t;
	};
	return MenuViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/view/MinMapViewSkin.exml'] = window.skins.minMapViewSkin = (function (_super) {
	__extends(minMapViewSkin, _super);
	function minMapViewSkin() {
		_super.call(this);
		this.skinParts = ["u_btnMonsterInfo","u_btnRank","u_btnCheckMap","u_txtMoney0","u_imgMoney0","u_mcMoney0","u_txtMoney1","u_imgMoney1","u_mcMoney1","u_mainInfo","u_imgMap","u_grpMap"];
		
		this.height = 170;
		this.width = 348;
		this.elementsContent = [this.u_mainInfo_i(),this.u_grpMap_i()];
	}
	var _proto = minMapViewSkin.prototype;

	_proto.u_mainInfo_i = function () {
		var t = new eui.Group();
		this.u_mainInfo = t;
		t.visible = true;
		t.elementsContent = [this.u_btnMonsterInfo_i(),this.u_btnRank_i(),this.u_btnCheckMap_i(),this._Image1_i(),this._Image2_i(),this.u_mcMoney0_i(),this.u_mcMoney1_i()];
		return t;
	};
	_proto.u_btnMonsterInfo_i = function () {
		var t = new eui.Image();
		this.u_btnMonsterInfo = t;
		t.height = 30;
		t.source = "userMainUI_json.userMainUI_x_xx";
		t.width = 30;
		t.x = 316.54;
		t.y = 95.27;
		return t;
	};
	_proto.u_btnRank_i = function () {
		var t = new eui.Image();
		this.u_btnRank = t;
		t.height = 30;
		t.source = "userMainUI_json.userMainUI_x_ph";
		t.width = 30;
		t.x = 316.67;
		t.y = 139.77;
		return t;
	};
	_proto.u_btnCheckMap_i = function () {
		var t = new eui.Image();
		this.u_btnCheckMap = t;
		t.height = 30;
		t.source = "userMainUI_json.userMainUI_x_dt";
		t.width = 30;
		t.x = 317.78;
		t.y = 48.1;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_x_kuang";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_icon_rank1";
		t.x = 12.336;
		t.y = 135.7;
		return t;
	};
	_proto.u_mcMoney0_i = function () {
		var t = new eui.Group();
		this.u_mcMoney0 = t;
		t.name = "u_mcMoney1";
		t.scaleX = 1;
		t.scaleY = 1;
		t.x = 127.62;
		t.y = 137.116;
		t.elementsContent = [this.u_txtMoney0_i(),this.u_imgMoney0_i()];
		return t;
	};
	_proto.u_txtMoney0_i = function () {
		var t = new eui.Label();
		this.u_txtMoney0 = t;
		t.anchorOffsetX = 0;
		t.horizontalCenter = 14.5;
		t.multiline = false;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 16;
		t.text = "999.8M";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 3.57;
		return t;
	};
	_proto.u_imgMoney0_i = function () {
		var t = new eui.Image();
		this.u_imgMoney0 = t;
		t.height = 39;
		t.scaleX = 0.58;
		t.scaleY = 0.58;
		t.source = "commonUI_icon_gold";
		t.visible = true;
		t.width = 39;
		t.x = 0.744;
		t.y = 0;
		return t;
	};
	_proto.u_mcMoney1_i = function () {
		var t = new eui.Group();
		this.u_mcMoney1 = t;
		t.name = "u_mcMoney1";
		t.scaleX = 1;
		t.scaleY = 1;
		t.x = 214.18;
		t.y = 137.116;
		t.elementsContent = [this.u_txtMoney1_i(),this.u_imgMoney1_i()];
		return t;
	};
	_proto.u_txtMoney1_i = function () {
		var t = new eui.Label();
		this.u_txtMoney1 = t;
		t.anchorOffsetX = 0;
		t.horizontalCenter = 13.5;
		t.multiline = false;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 16;
		t.text = "999.8M";
		t.textAlign = "center";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.y = 3.57;
		return t;
	};
	_proto.u_imgMoney1_i = function () {
		var t = new eui.Image();
		this.u_imgMoney1 = t;
		t.height = 39;
		t.scaleX = 0.58;
		t.scaleY = 0.58;
		t.source = "commonUI_icon_juan";
		t.visible = true;
		t.width = 39;
		t.x = -0.314;
		t.y = 1;
		return t;
	};
	_proto.u_grpMap_i = function () {
		var t = new eui.Group();
		this.u_grpMap = t;
		t.height = 130;
		t.visible = true;
		t.width = 300;
		t.elementsContent = [this.u_imgMap_i()];
		return t;
	};
	_proto.u_imgMap_i = function () {
		var t = new eui.Image();
		this.u_imgMap = t;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return minMapViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/view/RangeViewSkin.exml'] = window.RangeViewSkin = (function (_super) {
	__extends(RangeViewSkin, _super);
	function RangeViewSkin() {
		_super.call(this);
		this.skinParts = ["u_imgMenk","u_btnClick"];
		
		this.height = 90;
		this.width = 90;
		this.elementsContent = [this._Image1_i(),this.u_imgMenk_i(),this._Image2_i(),this.u_btnClick_i()];
	}
	var _proto = RangeViewSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_nqbg";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_imgMenk_i = function () {
		var t = new eui.Image();
		this.u_imgMenk = t;
		t.source = "userMainUI_json.userMainUI_nqjd";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "userMainUI_json.userMainUI_nqz";
		t.x = 7;
		t.y = 8;
		return t;
	};
	_proto.u_btnClick_i = function () {
		var t = new eui.Image();
		this.u_btnClick = t;
		t.alpha = 0;
		t.height = 82;
		t.horizontalCenter = -1;
		t.scale9Grid = new egret.Rectangle(3,3,3,3);
		t.source = "commonUI_json.commonUI_box";
		t.verticalCenter = -1;
		t.visible = true;
		t.width = 82;
		return t;
	};
	return RangeViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/view/SkillMainIconSkin.exml'] = window.SkillMainIconSkin = (function (_super) {
	__extends(SkillMainIconSkin, _super);
	function SkillMainIconSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBj","u_imgIcon","u_txtCd","u_imgCount","u_txtCount","u_mcCount","u_btnClick"];
		
		this.height = 87;
		this.width = 87;
		this.elementsContent = [this.u_imgBj_i(),this._Image1_i(),this.u_imgIcon_i(),this.u_txtCd_i(),this.u_mcCount_i(),this.u_btnClick_i()];
	}
	var _proto = SkillMainIconSkin.prototype;

	_proto.u_imgBj_i = function () {
		var t = new eui.Image();
		this.u_imgBj = t;
		t.source = "userMainUI_json.userMainUI_d_skill_k";
		t.visible = false;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "userMainUI_json.userMainUI_d_skill_bj";
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.horizontalCenter = 0;
		t.source = "userMainUI_json.userMainUI_d_skill_203";
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_txtCd_i = function () {
		var t = new eui.Label();
		this.u_txtCd = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.border = false;
		t.borderColor = 0x0A0909;
		t.fontFamily = "Arial";
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 26;
		t.stroke = 1;
		t.strokeColor = 0x131313;
		t.text = "60";
		t.textAlign = "right";
		t.textColor = 0xFFFFFF;
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_mcCount_i = function () {
		var t = new eui.Group();
		this.u_mcCount = t;
		t.horizontalCenter = 0;
		t.y = 60.75;
		t.elementsContent = [this.u_imgCount_i(),this.u_txtCount_i()];
		return t;
	};
	_proto.u_imgCount_i = function () {
		var t = new eui.Image();
		this.u_imgCount = t;
		t.scale9Grid = new egret.Rectangle(16,4,1,24);
		t.source = "userMainUI_json.userMainUI_d_skill_num";
		t.width = 40;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtCount_i = function () {
		var t = new eui.Label();
		this.u_txtCount = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.border = false;
		t.borderColor = 0x0A0909;
		t.fontFamily = "Arial";
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 18;
		t.stroke = 1;
		t.strokeColor = 0x131313;
		t.text = "69";
		t.textAlign = "right";
		t.textColor = 0xFFFFFF;
		t.y = 5.75;
		return t;
	};
	_proto.u_btnClick_i = function () {
		var t = new eui.Image();
		this.u_btnClick = t;
		t.alpha = 0;
		t.height = 76;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(3,3,3,3);
		t.source = "commonUI_json.commonUI_box";
		t.verticalCenter = 0;
		t.visible = true;
		t.width = 76;
		return t;
	};
	return SkillMainIconSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/userMainUI/WorldNoticeSkin.exml'] = window.WorldNoticeSkin = (function (_super) {
	__extends(WorldNoticeSkin, _super);
	function WorldNoticeSkin() {
		_super.call(this);
		this.skinParts = ["u_imgbg","u_text"];
		
		this.height = 37;
		this.width = 450;
		this.elementsContent = [this.u_imgbg_i(),this._Image1_i(),this.u_text_i()];
	}
	var _proto = WorldNoticeSkin.prototype;

	_proto.u_imgbg_i = function () {
		var t = new eui.Image();
		this.u_imgbg = t;
		t.scale9Grid = new egret.Rectangle(48,8,48,8);
		t.source = "commonUI_json.commonUI_di_1";
		t.visible = true;
		t.width = 440;
		t.y = 6;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "commonUI_json.commonUI_laba";
		t.visible = true;
		t.x = 4;
		t.y = 9;
		return t;
	};
	_proto.u_text_i = function () {
		var t = new eui.Label();
		this.u_text = t;
		t.anchorOffsetX = 0;
		t.bold = true;
		t.multiline = false;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 14;
		t.stroke = 2;
		t.strokeColor = 0x333333;
		t.text = "欢迎到来";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.wordWrap = false;
		t.x = 34;
		t.y = 11;
		return t;
	};
	return WorldNoticeSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/vipUI/VipUISkin.exml'] = window.VipUISkin = (function (_super) {
	__extends(VipUISkin, _super);
	function VipUISkin() {
		_super.call(this);
		this.skinParts = ["u_txtMsg","u_imgJindu","u_txtVip","u_txtProgress","u_grpProgress","u_btnRecharge","u_tipBg","u_txtTips","u_btnLeft","u_btnRight","u_txtPrivilege","u_btnReceive","u_txtDesc","u_imgReceived"];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i(),this._Image2_i(),this.u_txtMsg_i(),this.u_grpProgress_i(),this.u_btnRecharge_i(),this._Group1_i(),this._Group3_i()];
	}
	var _proto = VipUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 561.756;
		t.horizontalCenter = 0.5;
		t.scale9Grid = new egret.Rectangle(26,27,27,27);
		t.source = "vipUI_json.vipUI_bg";
		t.visible = true;
		t.width = 1002.692;
		t.y = 78.095;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.height = 23;
		t.source = "vipUI_json.vipUI_icon_th";
		t.visible = true;
		t.width = 22;
		t.x = 390;
		t.y = 128;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.border = false;
		t.borderColor = 0x000000;
		t.lineSpacing = 10;
		t.size = 18;
		t.stroke = 2;
		t.strokeColor = 0xA71C0D;
		t.text = "再充值$8    即可升级至";
		t.textAlign = "left";
		t.visible = true;
		t.wordWrap = true;
		t.x = 419;
		t.y = 128;
		return t;
	};
	_proto.u_grpProgress_i = function () {
		var t = new eui.Group();
		this.u_grpProgress = t;
		t.visible = true;
		t.width = 413.737;
		t.x = 381.197;
		t.y = 155.902;
		t.elementsContent = [this._Image3_i(),this.u_imgJindu_i(),this._Image4_i(),this.u_txtVip_i(),this.u_txtProgress_i()];
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.height = 20;
		t.scale9Grid = new egret.Rectangle(15,8,281,8);
		t.source = "vipUI_json.vipUI_jdt1";
		t.visible = true;
		t.width = 307;
		t.x = 100;
		t.y = 0;
		return t;
	};
	_proto.u_imgJindu_i = function () {
		var t = new eui.Image();
		this.u_imgJindu = t;
		t.height = 18;
		t.scale9Grid = new egret.Rectangle(15,6,277,6);
		t.source = "vipUI_json.vipUI_jdt2";
		t.visible = true;
		t.width = 23;
		t.x = 102;
		t.y = 0.5;
		return t;
	};
	_proto._Image4_i = function () {
		var t = new eui.Image();
		t.source = "vipUI_json.vipUI_bg_vip";
		t.visible = true;
		t.x = 14;
		return t;
	};
	_proto.u_txtVip_i = function () {
		var t = new eui.Label();
		this.u_txtVip = t;
		t.bold = true;
		t.height = 20;
		t.size = 18;
		t.stroke = 2;
		t.strokeColor = 0xA71C0D;
		t.text = "VIP15";
		t.textAlign = "center";
		t.visible = true;
		t.width = 110;
		t.x = 13;
		t.y = 4;
		return t;
	};
	_proto.u_txtProgress_i = function () {
		var t = new eui.Label();
		this.u_txtProgress = t;
		t.border = false;
		t.borderColor = 0x3A5905;
		t.height = 13;
		t.horizontalCenter = 50.13149999999999;
		t.italic = true;
		t.size = 14;
		t.stroke = 2;
		t.strokeColor = 0x3A5905;
		t.text = "0/100";
		t.textAlign = "center";
		t.verticalCenter = -2.5;
		t.visible = true;
		t.width = 300;
		t.x = 100;
		t.y = 10;
		return t;
	};
	_proto.u_btnRecharge_i = function () {
		var t = new eui.Image();
		this.u_btnRecharge = t;
		t.height = 63;
		t.source = "vipUI_json.vipUI_btn_cz";
		t.width = 162;
		t.x = 830;
		t.y = 120;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.width = 946;
		t.x = 92.36;
		t.y = 575.78;
		t.elementsContent = [this.u_tipBg_i(),this.u_txtTips_i(),this._Image5_i()];
		return t;
	};
	_proto.u_tipBg_i = function () {
		var t = new eui.Image();
		this.u_tipBg = t;
		t.height = 40;
		t.source = "vipUI_json.vipUI_tbg";
		t.width = 291;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtTips_i = function () {
		var t = new eui.Label();
		this.u_txtTips = t;
		t.bold = true;
		t.lineSpacing = 5;
		t.size = 18;
		t.text = "实际充值量根据汇率实时波动";
		t.textAlign = "left";
		t.textColor = 0xF0E4B0;
		t.visible = true;
		t.width = 800;
		t.wordWrap = true;
		t.x = 34.64;
		t.y = 11.48;
		return t;
	};
	_proto._Image5_i = function () {
		var t = new eui.Image();
		t.height = 23;
		t.source = "vipUI_json.vipUI_icon_th";
		t.visible = true;
		t.width = 22;
		t.x = 2.64;
		t.y = 9.22;
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.x = 408.23;
		t.y = 201.13;
		t.elementsContent = [this._Image6_i(),this.u_btnLeft_i(),this.u_btnRight_i(),this._Image7_i(),this.u_txtPrivilege_i(),this.u_btnReceive_i(),this._Scroller1_i(),this.u_imgReceived_i()];
		return t;
	};
	_proto._Image6_i = function () {
		var t = new eui.Image();
		t.height = 362;
		t.source = "vipUI_json.vipUI_tqyl";
		t.width = 601;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnLeft_i = function () {
		var t = new eui.Image();
		this.u_btnLeft = t;
		t.height = 49;
		t.source = "vipUI_json.vipUI_arrow_left";
		t.width = 33;
		t.x = 69.84;
		t.y = 105.87;
		return t;
	};
	_proto.u_btnRight_i = function () {
		var t = new eui.Image();
		this.u_btnRight = t;
		t.height = 49;
		t.source = "vipUI_json.vipUI_arrow_right";
		t.width = 33;
		t.x = 497.75;
		t.y = 105.87;
		return t;
	};
	_proto._Image7_i = function () {
		var t = new eui.Image();
		t.height = 34;
		t.source = "vipUI_json.vipUI_tqbg";
		t.width = 278;
		t.x = 165.29;
		t.y = 9.62;
		return t;
	};
	_proto.u_txtPrivilege_i = function () {
		var t = new eui.Label();
		this.u_txtPrivilege = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0xC2662D;
		t.text = "VIP6特权";
		t.textAlign = "center";
		t.textColor = 0xFFFFFF;
		t.y = 16;
		return t;
	};
	_proto.u_btnReceive_i = function () {
		var t = new eui.Image();
		this.u_btnReceive = t;
		t.height = 45;
		t.source = "vipUI_json.vipUI_btn_lq";
		t.width = 107;
		t.x = 249.53;
		t.y = 200.14;
		return t;
	};
	_proto._Scroller1_i = function () {
		var t = new eui.Scroller();
		t.height = 76;
		t.width = 554;
		t.x = 21;
		t.y = 269;
		t.viewport = this._Group2_i();
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.u_txtDesc_i()];
		return t;
	};
	_proto.u_txtDesc_i = function () {
		var t = new eui.Label();
		this.u_txtDesc = t;
		t.lineSpacing = 10;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 18;
		t.text = "1.实际充值效果根据汇率实时波动";
		t.textColor = 0xF0E4B0;
		t.width = 554;
		t.wordWrap = true;
		t.x = 0;
		t.y = 3;
		return t;
	};
	_proto.u_imgReceived_i = function () {
		var t = new eui.Image();
		this.u_imgReceived = t;
		t.height = 61;
		t.source = "vipUI_json.vipUI_received";
		t.width = 85;
		t.x = 258.413;
		t.y = 191.619;
		return t;
	};
	return VipUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/welcomeUI/WelcomeUISkin.exml'] = window.WelcomeUISkin = (function (_super) {
	__extends(WelcomeUISkin, _super);
	function WelcomeUISkin() {
		_super.call(this);
		this.skinParts = ["u_txtTime","u_btnClick"];
		
		this.height = 698;
		this.width = 640;
		this.elementsContent = [this._Image1_i(),this.u_txtTime_i(),this.u_btnClick_i()];
	}
	var _proto = WelcomeUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = -0.5;
		t.source = "welcomeUI_json.welcomeUI_bj";
		t.y = 166;
		return t;
	};
	_proto.u_txtTime_i = function () {
		var t = new eui.Label();
		this.u_txtTime = t;
		t.lineSpacing = 10;
		t.size = 20;
		t.text = "5s";
		t.textColor = 0x19ff02;
		t.visible = true;
		t.wordWrap = true;
		t.x = 448;
		t.y = 580;
		return t;
	};
	_proto.u_btnClick_i = function () {
		var t = new eui.Group();
		this.u_btnClick = t;
		t.height = 66;
		t.width = 200;
		t.x = 221;
		t.y = 554;
		t.elementsContent = [this._Image2_i(),this._Image3_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.source = "welcomeUI_json.welcomeUI_btn";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image3_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "welcomeUI_json.welcomeUI_btn_name";
		t.y = 12;
		return t;
	};
	return WelcomeUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/welfareUI/WelfareUISkin.exml'] = window.skins.WelfareUISkin = (function (_super) {
	__extends(WelfareUISkin, _super);
	function WelfareUISkin() {
		_super.call(this);
		this.skinParts = [];
		
		this.height = 640;
		this.width = 1136;
		this.elementsContent = [this._Image1_i()];
	}
	var _proto = WelfareUISkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 550;
		t.scale9Grid = new egret.Rectangle(10,10,10,10);
		t.source = "welfareUI_json.welfareUI_bg";
		t.visible = true;
		t.width = 151;
		t.x = 46;
		t.y = 56;
		return t;
	};
	return WelfareUISkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/withdrawalUI/popup/WithdrawalPopupSkin.exml'] = window.WithdrawalPopupSkin = (function (_super) {
	__extends(WithdrawalPopupSkin, _super);
	function WithdrawalPopupSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_imgBg2","u_txtTitle","u_txtHistory","u_btnRecord","u_txtHave","u_txtIcon","u_txtMoney","u_txtTimes","u_listItem","u_scrollerItem","u_txtRecycle","u_btnRecycle","u_btnClose"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_imgBg_i(),this.u_imgBg2_i(),this.u_txtTitle_i(),this.u_btnRecord_i(),this.u_txtHave_i(),this._Group1_i(),this.u_txtTimes_i(),this.u_scrollerItem_i(),this.u_btnRecycle_i(),this.u_btnClose_i()];
	}
	var _proto = WithdrawalPopupSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 1156;
		t.scale9Grid = new egret.Rectangle(12,12,11,11);
		t.source = "recycleUI_json.recycleUI_bg1";
		t.visible = true;
		t.width = 660;
		t.x = -10;
		t.y = -10;
		return t;
	};
	_proto.u_imgBg2_i = function () {
		var t = new eui.Image();
		this.u_imgBg2 = t;
		t.height = 910;
		t.scale9Grid = new egret.Rectangle(100,58,100,4);
		t.source = "recycleUI_json.recycleUI_bg";
		t.visible = true;
		t.width = 720;
		t.x = -40;
		t.y = 240;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.text = "Withdraw";
		t.y = 35;
		return t;
	};
	_proto.u_btnRecord_i = function () {
		var t = new eui.Group();
		this.u_btnRecord = t;
		t.height = 30;
		t.right = 22;
		t.width = 90;
		t.y = 37;
		t.elementsContent = [this.u_txtHistory_i()];
		return t;
	};
	_proto.u_txtHistory_i = function () {
		var t = new eui.Label();
		this.u_txtHistory = t;
		t.horizontalCenter = 0;
		t.size = 26;
		t.text = "History";
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_txtHave_i = function () {
		var t = new eui.Label();
		this.u_txtHave = t;
		t.horizontalCenter = 0;
		t.size = 26;
		t.text = "You have";
		t.y = 121;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = -7.5;
		t.y = 155;
		t.elementsContent = [this.u_txtIcon_i(),this.u_txtMoney_i()];
		return t;
	};
	_proto.u_txtIcon_i = function () {
		var t = new eui.Label();
		this.u_txtIcon = t;
		t.bold = true;
		t.size = 28;
		t.text = "$";
		t.visible = true;
		t.x = 0;
		t.y = 16;
		return t;
	};
	_proto.u_txtMoney_i = function () {
		var t = new eui.Label();
		this.u_txtMoney = t;
		t.bold = true;
		t.size = 50;
		t.text = "0.66";
		t.visible = true;
		t.x = 17;
		t.y = 0;
		return t;
	};
	_proto.u_txtTimes_i = function () {
		var t = new eui.Label();
		this.u_txtTimes = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 26;
		t.text = "VIP1 Residue degree: 1";
		t.textColor = 0x5ABEFC;
		t.y = 264;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 650;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 600;
		t.y = 305;
		t.viewport = this.u_listItem_i();
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_btnRecycle_i = function () {
		var t = new eui.Group();
		this.u_btnRecycle = t;
		t.height = 80;
		t.visible = true;
		t.width = 480;
		t.x = 80;
		t.y = 996;
		t.elementsContent = [this._Image1_i(),this.u_txtRecycle_i()];
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.scale9Grid = new egret.Rectangle(45,22,45,21);
		t.source = "recycleUI_json.recycleUI_btn_1";
		t.visible = true;
		t.width = 480;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtRecycle_i = function () {
		var t = new eui.Label();
		this.u_txtRecycle = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 26;
		t.text = "Withdraw";
		t.textColor = 0xFFFFFF;
		t.verticalCenter = 0;
		t.visible = true;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 40;
		t.source = "recycleUI_json.recycleUI_arrow1";
		t.width = 30;
		t.x = 12;
		t.y = 27;
		return t;
	};
	return WithdrawalPopupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/withdrawalUI/popup/WithdrawalRecordPopSkin.exml'] = window.WithdrawalRecordPopSkin = (function (_super) {
	__extends(WithdrawalRecordPopSkin, _super);
	function WithdrawalRecordPopSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_btnClose","u_txtTitle","u_listItem","u_scrollerItem"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_imgBg_i(),this.u_btnClose_i(),this.u_txtTitle_i(),this._Image1_i(),this.u_scrollerItem_i()];
	}
	var _proto = WithdrawalRecordPopSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 1156;
		t.scale9Grid = new egret.Rectangle(12,12,11,11);
		t.source = "recycleUI_json.recycleUI_bg2";
		t.visible = true;
		t.width = 660;
		t.x = -10;
		t.y = -10;
		return t;
	};
	_proto.u_btnClose_i = function () {
		var t = new eui.Image();
		this.u_btnClose = t;
		t.height = 40;
		t.source = "recycleUI_json.recycleUI_arrow2";
		t.width = 30;
		t.x = 14;
		t.y = 30;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.text = "History";
		t.textColor = 0x000000;
		t.y = 35;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(20,2,20,1);
		t.source = "recycleUI_json.recycleUI_line";
		t.visible = true;
		t.width = 660;
		t.y = 76;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 1016;
		t.horizontalCenter = 0;
		t.visible = true;
		t.width = 600;
		t.y = 100;
		t.viewport = this.u_listItem_i();
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return WithdrawalRecordPopSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/withdrawalUI/popup/WithdrawalResultSkin.exml'] = window.WithdrawalResultSkin = (function (_super) {
	__extends(WithdrawalResultSkin, _super);
	function WithdrawalResultSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_txtTitle","u_txtMsg","u_txtOK","u_btnOK"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_imgBg_i(),this.u_txtTitle_i(),this.u_txtMsg_i(),this._Image1_i(),this.u_btnOK_i()];
	}
	var _proto = WithdrawalResultSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 436;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(12,12,2,2);
		t.source = "recycleUI_json.recycleUI_di_3";
		t.visible = true;
		t.width = 450;
		t.y = 312;
		return t;
	};
	_proto.u_txtTitle_i = function () {
		var t = new eui.Label();
		this.u_txtTitle = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "Cue";
		t.textColor = 0x000000;
		t.y = 328;
		return t;
	};
	_proto.u_txtMsg_i = function () {
		var t = new eui.Label();
		this.u_txtMsg = t;
		t.bold = true;
		t.height = 157;
		t.horizontalCenter = 0;
		t.lineSpacing = 10;
		t.size = 24;
		t.text = "111";
		t.textAlign = "center";
		t.textColor = 0x000000;
		t.verticalAlign = "middle";
		t.width = 400;
		t.wordWrap = true;
		t.y = 433;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(20,2,20,1);
		t.source = "recycleUI_json.recycleUI_line";
		t.width = 444;
		t.y = 674;
		return t;
	};
	_proto.u_btnOK_i = function () {
		var t = new eui.Group();
		this.u_btnOK = t;
		t.height = 65;
		t.width = 442;
		t.x = 99;
		t.y = 679;
		t.elementsContent = [this.u_txtOK_i(),this._Image2_i()];
		return t;
	};
	_proto.u_txtOK_i = function () {
		var t = new eui.Label();
		this.u_txtOK = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "OK";
		t.textColor = 0x003A82;
		t.visible = true;
		t.y = 22;
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.alpha = 0;
		t.height = 65;
		t.scale9Grid = new egret.Rectangle(26,27,27,27);
		t.source = "commonsUI_json.commonUI_box_1";
		t.width = 442;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return WithdrawalResultSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/withdrawalUI/render/WithdrawalRecRenderSkin.exml'] = window.WithdrawalRecRenderSkin = (function (_super) {
	__extends(WithdrawalRecRenderSkin, _super);
	function WithdrawalRecRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_txtTime","u_txtMoney","u_imgState"];
		
		this.height = 50;
		this.width = 600;
		this.elementsContent = [this.u_txtTime_i(),this.u_txtMoney_i(),this.u_imgState_i()];
	}
	var _proto = WithdrawalRecRenderSkin.prototype;

	_proto.u_txtTime_i = function () {
		var t = new eui.Label();
		this.u_txtTime = t;
		t.bold = true;
		t.size = 24;
		t.text = "2021-01-28";
		t.textColor = 0x000000;
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_txtMoney_i = function () {
		var t = new eui.Label();
		this.u_txtMoney = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 24;
		t.text = "- 10元";
		t.textColor = 0x000000;
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_imgState_i = function () {
		var t = new eui.Image();
		this.u_imgState = t;
		t.source = "recycleUI_json.recycleUI_state2";
		t.verticalCenter = 0;
		t.x = 492;
		return t;
	};
	return WithdrawalRecRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/withdrawalUI/render/WithdrawalRenderSkin.exml'] = window.WithdrawalRenderSkin = (function (_super) {
	__extends(WithdrawalRenderSkin, _super);
	function WithdrawalRenderSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_txtName","u_imgGo","u_txtGo","u_imgRed","u_btnGo","u_imgReceived","u_txtTishi","u_txtNum","u_imgIcon"];
		
		this.height = 152;
		this.width = 555;
		this.elementsContent = [this.u_imgBg_i(),this._Image1_i(),this.u_txtName_i(),this.u_btnGo_i(),this.u_imgReceived_i(),this.u_txtTishi_i(),this.u_txtNum_i(),this.u_imgIcon_i()];
	}
	var _proto = WithdrawalRenderSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.source = "withdrawalUI_json.withdrawalUI_di_1";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "withdrawalUI_json.withdrawalUI_txt_bg";
		t.visible = true;
		t.x = 18;
		t.y = 15;
		return t;
	};
	_proto.u_txtName_i = function () {
		var t = new eui.Label();
		this.u_txtName = t;
		t.bold = true;
		t.size = 22;
		t.stroke = 2;
		t.strokeColor = 0x853F2B;
		t.text = "拥有";
		t.visible = true;
		t.x = 38;
		t.y = 23;
		return t;
	};
	_proto.u_btnGo_i = function () {
		var t = new eui.Group();
		this.u_btnGo = t;
		t.height = 65;
		t.visible = true;
		t.width = 136;
		t.x = 393;
		t.y = 59;
		t.elementsContent = [this.u_imgGo_i(),this.u_txtGo_i(),this.u_imgRed_i()];
		return t;
	};
	_proto.u_imgGo_i = function () {
		var t = new eui.Image();
		this.u_imgGo = t;
		t.scale9Grid = new egret.Rectangle(45,22,45,21);
		t.source = "commonsUI_json.commonsUI_btn_2";
		t.visible = true;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtGo_i = function () {
		var t = new eui.Label();
		this.u_txtGo = t;
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.size = 22;
		t.text = "GO";
		t.textColor = 0x573118;
		t.verticalCenter = 0;
		return t;
	};
	_proto.u_imgRed_i = function () {
		var t = new eui.Image();
		this.u_imgRed = t;
		t.source = "commonsUI_json.commonsUI_red_1";
		t.x = 114;
		t.y = -3;
		return t;
	};
	_proto.u_imgReceived_i = function () {
		var t = new eui.Image();
		this.u_imgReceived = t;
		t.source = "commonsUI_json.commonsUI_received";
		t.visible = false;
		t.x = 417;
		t.y = 61;
		return t;
	};
	_proto.u_txtTishi_i = function () {
		var t = new eui.Label();
		this.u_txtTishi = t;
		t.bold = true;
		t.size = 26;
		t.stroke = 2;
		t.strokeColor = 0x3a9104;
		t.text = "award：";
		t.visible = true;
		t.x = 38;
		t.y = 96.5;
		return t;
	};
	_proto.u_txtNum_i = function () {
		var t = new eui.Label();
		this.u_txtNum = t;
		t.bold = true;
		t.size = 26;
		t.stroke = 2;
		t.strokeColor = 0x3a9104;
		t.text = "x 5";
		t.visible = true;
		t.x = 216;
		t.y = 96.5;
		return t;
	};
	_proto.u_imgIcon_i = function () {
		var t = new eui.Image();
		this.u_imgIcon = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.source = "commonsUI_json.commonsUI_item_icon";
		t.x = 132;
		t.y = 54;
		return t;
	};
	return WithdrawalRenderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/withdrawalUI/render/WithdrawalSelectSkin.exml'] = window.WithdrawalSelectSkin = (function (_super) {
	__extends(WithdrawalSelectSkin, _super);
	function WithdrawalSelectSkin() {
		_super.call(this);
		this.skinParts = ["u_imgBg","u_txtNum"];
		
		this.height = 70;
		this.width = 188;
		this.elementsContent = [this.u_imgBg_i(),this.u_txtNum_i()];
	}
	var _proto = WithdrawalSelectSkin.prototype;

	_proto.u_imgBg_i = function () {
		var t = new eui.Image();
		this.u_imgBg = t;
		t.height = 70;
		t.scale9Grid = new egret.Rectangle(9,12,6,2);
		t.source = "recycleUI_json.recycleUI_di_2";
		t.visible = true;
		t.width = 188;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.u_txtNum_i = function () {
		var t = new eui.Label();
		this.u_txtNum = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 36;
		t.text = "$10";
		t.verticalCenter = 0;
		return t;
	};
	return WithdrawalSelectSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/withdrawalUI/WithdrawalUISkin.exml'] = window.WithdrawalUISkin = (function (_super) {
	__extends(WithdrawalUISkin, _super);
	function WithdrawalUISkin() {
		_super.call(this);
		this.skinParts = ["u_imgTitle","u_txtTime","u_listItem","u_scrollerItem"];
		
		this.height = 1136;
		this.width = 640;
		this.elementsContent = [this.u_imgTitle_i(),this.u_txtTime_i(),this.u_scrollerItem_i()];
	}
	var _proto = WithdrawalUISkin.prototype;

	_proto.u_imgTitle_i = function () {
		var t = new eui.Image();
		this.u_imgTitle = t;
		t.horizontalCenter = -1.5;
		t.source = "withdrawalUI_json.withdrawalUI_bg";
		t.visible = true;
		t.y = 42;
		return t;
	};
	_proto.u_txtTime_i = function () {
		var t = new eui.Label();
		this.u_txtTime = t;
		t.bold = true;
		t.right = 60;
		t.size = 20;
		t.stroke = 1.5;
		t.strokeColor = 0x342929;
		t.text = "剩余时间: 10:00:00";
		t.textColor = 0xF1AAAA;
		t.visible = true;
		t.y = 301;
		return t;
	};
	_proto.u_scrollerItem_i = function () {
		var t = new eui.Scroller();
		this.u_scrollerItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 650;
		t.horizontalCenter = 0.5;
		t.visible = true;
		t.width = 555;
		t.y = 340;
		t.viewport = this.u_listItem_i();
		return t;
	};
	_proto.u_listItem_i = function () {
		var t = new eui.List();
		this.u_listItem = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	return WithdrawalUISkin;
})(eui.Skin);