/**
 *
 * @author
 *
 */

/*		
		var player = {
			"Attack": 10, //攻击力
			"Defense": 4, //防御力
			"HP": 50, //当前hp
			"MaxHP": 60, //hp上限
			"MP": 15, //当前mp
			"MaxMP": 20, //mp上限
			"SkillIds": [1,15,1009], //拥有的技能id数组
			"DiceSkillIds": [15,0,0,0,0,66] //骰子技能,对应到点数
		};
		
		var member = {
            "Player": Player, //玩家信息
			"Belong": belong  //属于某一方
        };

		var team = {
			"Roll": 0, //摇次数
            "Dice1": 0, //骰子点数
			"Dice2": 0, //第二个骰子点数
            "ReDice": 0, //重摇次数
			"NowReDice": 0, //当前重摇次数
            "SkillDice": 0, //技能附加点数
            "DiceFlag": 0,  //当前操作
			"DiceSkillNum": 0, //骰子技能触发数量
            "Member": member, //玩家信息
			"Belong": member.Belong  //属于某一方
        };
		
		var fightData = {
			"Round": 0, 
			"AttackBelong": War.BELONG_NO,//当前攻击方
            "TeamA": teamA,   //左边的队伍
            "TeamB": teamB,   //右边的队伍
			"Result": 0,      //战斗结果
			"Seed1": seed1,     //随机数种子 基数,数字较大
			"Seed2": seed2,     //随机数种子 范围是0-999
			"IsReDice": true, //副本的是否重摇
			"ReRatio": 800,   //副本重摇的概率
			"DiceWeightA1": [100,150,350,600,800,1000] //玩家骰子的权重1
			"DiceWeightA2": [100,150,350,600,800,1000] //玩家骰子的权重2
			"DiceWeightB1": [100,150,350,600,800,1000] //怪物骰子的权重1
			"DiceWeightB2": [100,150,350,600,800,1000] //怪物骰子的权重2
        };
*/

//单步操作调用 War.fightone(fightData,diceFlag);
//参数说明. fightData: 参考上面注释中的代码(fightData是object,不是字符串).  diceFlag:当前的操作(整型,查看文件结尾处的注释说明)
//返回数据. 服务端不需要. 客户端自己根据需求自己写. 
//说明: fightData.Result 为战斗结果, 常量说明在本文件结尾处附近.

//本文件中所有中文均为注释, 如有不明白之处再做协商调整.
var War = (function () {
    function War() {
    }

	War.setDiceWeights = function(str){ //外部调用
		//War._consolelog("setDiceWeights " + str);
		var a = JSON.parse(str);
		var b = {};
		for(var i =0;i<a.length;i++){
			var id = a[i].Id;
			var t = a[i].Type;
			var v = a[i].Value;


			a[i].WeightP1 = War._str2weight(a[i].WeightP1);
			a[i].WeightP2 = War._str2weight(a[i].WeightP2);
			a[i].Weight1  = War._str2weight(a[i].Weight1);
			a[i].Weight2  = War._str2weight(a[i].Weight2);
			if(!b[id]){
				b[id] = {};
			}
			if(!(b[id].Value)){
				b[id].Value = [];
			}
			if(!(b[id].Value[t])){
				b[id].Value[t] = {};
			}
			
			b[id].Value[t][v] = a[i];

			if(!(b[id].MaxValue)){
				b[id].MaxValue = [0,0,0];
			}
			if(b[id].MaxValue[t] < v){
				b[id].MaxValue[t] = v;
			}
		}
		War.DiceWeights = b;
	}

	War._str2weight = function(w){
		w = w.split("|");
		var sum = 0;
		for(var i = 0;i<w.length;i++){
			sum += parseInt(w[i]);
			w[i] = sum;
		}
		return w;
	}

	War.setReDiceMP = function(m){//外部调用
		m = parseInt(m);
		War.REDICE_MP = m
	}

	War.setskills = function(str){ //外部调用
		var a = JSON.parse(str);
		var b = {};
		for(var i =0;i<a.length;i++){
			var id = a[i].Id ;
			a[i].ConditionTargets = [];
			a[i].Conditions = [];
			a[i].Operators = [];
			a[i].ConditionParams = [];
			a[i].ParamTypes = [];

			var target = a[i].ConditionTarget.split("|");
			var con = a[i].Condition.split("|");
			var opt = a[i].Operator.split("|");
			var param = a[i].ConditionParam.split("|");
			var paramType = a[i].ParamType.split("|");

			for(var ti = 0; ti< target.length;ti++){
				a[i].ConditionTargets[ti] = parseInt(target[ti]);
				a[i].Conditions[ti] = parseInt(con[ti]);
				a[i].Operators[ti] = opt[ti];
				a[i].ConditionParams[ti] = parseInt(param[ti]);
				a[i].ParamTypes[ti] = parseInt(paramType[ti]);
			}
			b[a[i].Id] = a[i];
		}
		War.Skills = b ;
		//War._consolelog("War.Skills " , War.Skills[200710055] );
	}

	War.setRandList = function(str){ //设置随机数列表 , 数组.//外部调用
		//War._consolelog("RandList " + arr);
		var a = JSON.parse(str);
		War.RandList = a.Seed;
	}

	War.setControlTypeValue = function(t,v){//外部调用
		War.ControlType = parseInt(t);
		War.ControlValue = parseInt(v);
	}

    War.fight = function (PlayerA, PlayerB, fightParam, process, seed1,seed2,fightType) { //外部调用
		War._consolelog("-- func fight PlayerA " + PlayerA);
		War._consolelog("PlayerB " + PlayerB);
		War._consolelog("fightParam " + fightParam);
		War._consolelog("process " + process);
		War._consolelog("seed1 " + seed1);
		War._consolelog("seed2 " + seed2);

        PlayerA = JSON.parse(PlayerA);
		PlayerB = JSON.parse(PlayerB);
		fightParam = JSON.parse(fightParam);
		process = JSON.parse(process);

		seed1 = parseInt(seed1);
		seed2 = parseInt(seed2);

		if(seed1<0 || seed2 <0){//随机数种子错误了
			War._consolelog("fight  seed1<0 || seed2 <0 FIGHT_ERROR");
			return War.FIGHT_ERROR;
		}		

		PlayerA = War.makePlayer(PlayerA.Attack,PlayerA.Defense,PlayerA.HP,PlayerA.MaxHP,PlayerA.MP,PlayerA.MaxMP,PlayerA.SkillIds,PlayerA.DiceSkillIds);
		PlayerB = War.makePlayer(PlayerB.Attack,PlayerB.Defense,PlayerB.HP,PlayerB.MaxHP,PlayerB.MP,PlayerB.MaxMP,PlayerB.SkillIds,PlayerB.DiceSkillIds);
		fightParam = War.makeFightParam(fightParam.DiceId,fightParam.IsReDice,fightParam.ReRatio,
			fightParam.DiceWeightA1,fightParam.DiceWeightA2,fightParam.DiceWeightB1,fightParam.DiceWeightB2);

        var result = War._dofight(PlayerA, PlayerB, fightParam, process, seed1,seed2,fightType);

		War._consolelog("fight result "+result );
        
        return result;
    };

	War._dofight = function (PlayerA, PlayerB,fightParam, process, seed1,seed2,fightType) {
        
        var memberA = War.makeMember(PlayerA,War.BELONG_A);
        var teamA =  War.makeTeam(memberA);
		var memberB = War.makeMember(PlayerB,War.BELONG_B);
        var teamB =  War.makeTeam(memberB);
        
        var data = War.makeFightData(teamA,teamB,seed1,seed2,fightParam,fightType);

        var len = process.length;
        War._consolelog("-- func dofight process.length " + len);

		var i = 0;
        for (i = 0; i < len; i++) {
            var diceFlag = process[i];

			War._consolelog("process.i " + i );

            War.fightone(data, diceFlag);

			if (data.Result == War.FIGHT_ERROR) {
				return War.FIGHT_ERROR;
			}
			if (data.Result != War.FIGHT_CONTINUE) {
				break;
			}
        }

		War._consolelog("process. i+1 " + (i+1) + " len: "+len);

		if(i+1 != len){
			return War.FIGHT_ERROR;
		}
		return data.Result;
    };

	War.roundBegin = function(data){ // 废弃不用
		         
	}

	War.fightone = function (data,diceFlag){ //外部调用

		War._consolelog("-- func fightone diceFlag: "+diceFlag);

        War.appendWarStep(diceFlag);

		if (diceFlag > 0) {
            data.TeamA.DiceFlag = diceFlag;
        } else if (diceFlag < 0) {
            data.TeamB.DiceFlag = diceFlag;
        } else {
            data.Result = War.FIGHT_ERROR;
			War._consolelog("fightone  diceFlag ==0 FIGHT_ERROR");
			return 
        }

		War._consolelog("data.TeamA.DiceFlag", data.TeamA.DiceFlag)
		War._consolelog("data.TeamB.DiceFlag", data.TeamB.DiceFlag)

		switch (diceFlag) {
			case War.DICE_FLAG1:

                War._onDiceRoll(data);//摇骰子

                break;
            case War.DICE_FLAG2:

				if( War.isServer ){
					if( !War.checkOnDiceReRoll(data) ){
						data.Result = War.FIGHT_ERROR;
						War._consolelog("fightone  checkOnDiceReRoll FIGHT_ERROR");
						return ;
					}
				}

                War._onDiceReRoll(data);//检测重摇

                break;
            case War.DICE_FLAG3:

                War._onDiceReRoll(data);//检测是否有一方重摇

                War._onDiceOk(data);//检测双方骰子确定
                break;
            case War.DICE_FLAGR1:

                War._onDiceRoll(data);//摇骰子

                break;
            case War.DICE_FLAGR2:
				if( War.isServer ){
					if( !War.checkOnDiceReRoll_R(data) ){
						data.Result = War.FIGHT_ERROR;
						War._consolelog("fightone  checkOnDiceReRoll_R FIGHT_ERROR");
						return ;
					}
				}

                War._onDiceReRoll(data);//检测双方是否重摇

                break;

            case War.DICE_FLAGR3:

				if( War.isServer ){
					if (War.PVE == data.FightType && War.checkOnDiceReRoll_R(data) ) 
					{
						data.Result = War.FIGHT_ERROR;
						War._consolelog("fightone  War.PVE == data.FightType && checkOnDiceReRoll_R FIGHT_ERROR");
						return ;
					}
				}

                War._onDiceReRoll(data);//检测是否有一方重摇

                War._onDiceOk(data);//检测双方骰子确定
                break;

            default:
                data.Result = War.FIGHT_ERROR;
				War._consolelog("fightone  switch FIGHT_ERROR");
				return ;
        }
		
		War._consolelog("fightone result: "+ data.Result);

	};

	War.getDice = function(team){
		War._consolelog("-- func getDice Dice1 " + team.Dice1 + " Dice2 " + team.Dice2)
		War._consolelog("ReDice " + team.ReDice + " SkillDice " + team.SkillDice)
		return team.Dice1 + team.Dice2 + team.ReDice + team.SkillDice;
	}

	War.getMPUse = function(ReDice){ //外部调用 当前重摇需要多少mp ReDice重摇次数
		var all = 1;
		for(var i=0; i<ReDice + 1;i++){
			all *= War.REDICE_MP;
		}
		return all ;
	}

	War.checkOnDiceReRoll = function(data){ //验证玩家能不能重摇 外部调用

		War._consolelog("-- func checkOnDiceReRoll");

		if (data.TeamA.Member.Player.MP < War.getMPUse(data.TeamA.ReDice) ) { //每个大回合 消耗mp重新计数, 每次计数翻倍
			War._consolelog("TeamA mp not enough: "+data.TeamA.Member.Player.MP+" ReDice: "+data.TeamA.ReDice);
			return false ;
		}
		return true ;
	} ;

	War.checkOnDiceReRoll_R = function(data){//验证怪能不能重摇 外部调用

		War._consolelog("-- func checkOnDiceReRoll_R");

        if (data.TeamB.Member.Player.MP < War.getMPUse(data.TeamB.ReDice) ) { //每个大回合 消耗mp重新计数, 每次计数翻倍
			War._consolelog("TeamB mp not enough: "+data.TeamB.Member.Player.MP+" ReDice: "+data.TeamB.ReDice);
			return false;
		}

		if(War.PVE == data.FightType ){ //验证pve重摇
			if (!data.FightParam.IsReDice)
			{
				War._consolelog("!data.FightParam.IsReDice");
				return false;
			}

			if(War.getDice(data.TeamA) < War.getDice(data.TeamB)){
				War._consolelog("getDice TeamA < TeamB");
				return false;
			}

			var r = War._getRand(data, 1000);
			if(r > data.FightParam.ReRatio){
				War._consolelog("r > data.FightParam.ReRatio: "+r + " " + data.FightParam.ReRatio);
				return false;
			}
		}
		War._consolelog("checkOnDiceReRoll_R true");

		return true ;
	} ;

	War._playerReSetAttr = function(player){ //外部调用
		War._consolelog("-- func _playerReSetAttr player" , player);
		player.Attack = player.AttackOld;
		player.Defense = player.DefenseOld;
		player.MaxHP = player.MaxHPOld;
		if(player.HP > player.MaxHP){
			player.HP = player.MaxHP;
		}
		player.MaxMP = player.MaxMPOld;
		if(player.MP > player.MaxMP){
			player.MP = player.MaxMP;
		}
	}

	War.makePlayer = function(Attack,Defense,HP,MaxHP,MP,MaxMP,SkillIds,DiceSkillIds){ //外部调用
		return {
			"Attack": Attack, //攻击力
			"AttackOld": Attack,
			"Defense": Defense, //防御力
			"DefenseOld": Defense, //防御力
			"HP": HP, //当前hp
			"HPOld": HP, //当前hp
			"MaxHP": MaxHP, //hp上限
			"MaxHPOld": MaxHP, //hp上限
			"MP": MP, //当前mp
			"MPOld": MP, //当前mp
			"MaxMP": MaxMP, //mp上限
			"MaxMPOld": MaxMP, //mp上限

			"SkillIds": SkillIds, //拥有的技能id数组
			"DiceSkillIds": DiceSkillIds //骰子技能,对应到点数
		}
	}

	War.makeMember = function (Player,belong){ //外部调用

		return {
			"TiggerDiceSkillIds": [],
            "Player": Player,
			"Belong": belong
        };
	};

	War.makeTeam = function (member){ //外部调用
		return {
			"Roll": 0,
            "Dice1": 0,
			"Dice2": 0,
			"NowDice": false,
            "ReDice": 0,
			"AllReDice": 0,
			"NowReDice": 0,
            "SkillDice": 0,
            "DiceFlag": 0,
			"DiceSkillNum": 0,
            "Member": member,
			"Belong": member.Belong,
			"CopySkill": 0,
			"LastOneHP": 0,
			"StrengthenSkill": {},
			"SeriesEffect": [],
			"ConditionHP": [],
        };
	};

	War.makeFightParam = function(DiceId,IsReDice,ReRatio,DiceWeightA1,DiceWeightA2,DiceWeightB1,DiceWeightB2){ //外部调用
		War._consolelog("makeFightParam. DiceId " + DiceId);
		return {
			"DiceId" : DiceId,
			"IsReDice": IsReDice, //bool
			"ReRatio": ReRatio,
			"DiceWeightA1": DiceWeightA1,
			"DiceWeightA2": DiceWeightA2,
			"DiceWeightB1": DiceWeightB1,
			"DiceWeightB2": DiceWeightB2
		};
	}

	War.makeFightData = function(teamA,teamB,seed1,seed2,fightParam,fightType ){ //外部调用

		var diceWeights = {};
		if(fightParam.DiceId > 0 && War.DiceWeights[fightParam.DiceId]){
			diceWeights = War.DiceWeights[fightParam.DiceId] ;
		} else {
			fightParam.DiceId = 0;
		}
		
		return {
			"Round" : 0,
			"AttackBelong": War.BELONG_NO,//当前攻击方
            "TeamA": teamA,
            "TeamB": teamB,
			"HasDiceFlagOne": false, 
			"Result": War.FIGHT_CONTINUE,
			"Seed1": seed1,
			"Seed2": seed2,
			"FightParam": fightParam,
			//"IsReDice": fightParam.IsReDice,
			//"ReRatio": fightParam.ReRatio,
			//"DiceWeightA1": fightParam.DiceWeightA1,
			//"DiceWeightA2": fightParam.DiceWeightA2,
			//"DiceWeightB1": fightParam.DiceWeightB1,
			//"DiceWeightB2": fightParam.DiceWeightB2,
			"FightType": fightType,
			//"DiceId": fightParam.DiceId,
			"DiceWeights" : diceWeights
        };
	}

	War._makeSkill = function(belong,s){
		return {"Belong":belong,"Skill": s};
	}

	War._setTwoDiceFlag0 = function(data){
		data.TeamA.DiceFlag = War.DICE_FLAG0;
		data.TeamB.DiceFlag = War.DICE_FLAG0;
	};

	//摇骰子
    War._onDiceRoll = function(data){
        if( data.TeamA.DiceFlag == War.DICE_FLAG1 && data.TeamB.DiceFlag == War.DICE_FLAGR1)
        {
			data.Round += 1 ;
			 
			data.HasDiceFlagOne = true;

			var teamA = data.TeamA;
			var teamB = data.TeamB;

			teamA.Roll += 1 ;
			teamA.ReDice = 0;
			teamA.NowDice = true;
			teamA.NowReDice = 0;
			teamA.SkillDice = 0;
			teamA.DiceSkillNum = 0;
			teamA.CopySkill = 0;
			teamA.LastOneHP = 0;
			teamA.StrengthenSkill = {};
			
			teamB.Roll += 1 ;
			teamB.ReDice = 0;
			teamB.NowDice = true;
			teamB.NowReDice = 0;
			teamB.SkillDice = 0;
			teamB.DiceSkillNum = 0;
			teamB.CopySkill = 0;
			teamB.LastOneHP = 0;
			teamB.StrengthenSkill = {};
			
			War._playerReSetAttr(teamA.Member.Player);
			War._playerReSetAttr(teamB.Member.Player);

			//【7】
			War._resetTriggerTime(data);
			var skills = War._trigger(data.TeamA.Member,data.TeamB.Member,7);
			War._release(data,  skills);

            War._setRollDice(data,teamA, false);
            War._setRollDice(data,teamB, false);

            teamA.DiceSkillNum = War._triggerDiceSkill(teamA.Member,teamA.Dice1,teamA.Dice2);
            teamB.DiceSkillNum = War._triggerDiceSkill(teamB.Member,teamB.Dice1,teamB.Dice2);

            War._setTwoDiceFlag0(data);

            //技能触发时机3
            //技能触发时机5
			War._resetTriggerTime(data);
            var skills3 = War._trigger(teamA.Member,teamB.Member,3);
			
            var s5 = War._trigger(teamA.Member,teamB.Member,5);
			War._pushObjArray(skills3,s5);

            War._release(data,skills3);

			teamA.NowDice = false;
			teamB.NowDice = false;

            return;//返回战报数据
        }
    }

    //重摇骰子
    War._onDiceReRoll = function(data){
        if(data.TeamB.DiceFlag == War.DICE_FLAGR2 && data.TeamA.DiceFlag == War.DICE_FLAG2)//双方重摇
        {
			var teamA = data.TeamA;
			var teamB = data.TeamB;
			
            teamA.NowReDice = 1;
            teamA.SkillDice = 0;

            teamB.NowReDice = 1;
            teamB.SkillDice = 0;

            War._setReRollDice(data,teamA);
            War._setReRollDice(data,teamB);

            teamA.DiceSkillNum = War._triggerDiceSkill(teamA.Member,teamA.Dice1,teamA.Dice2);
            teamB.DiceSkillNum = War._triggerDiceSkill(teamB.Member,teamB.Dice1,teamB.Dice2);

            War._setTwoDiceFlag0(data);

            //技能触发时机4
            //技能触发时机5
			War._resetTriggerTime(data);
            var skills = War._trigger(teamA.Member,teamB.Member,4);

            var s5 = War._trigger(teamA.Member,teamB.Member,5);
            War._pushObjArray(skills,s5);

            War._release(data,skills);
        }
        else if((data.TeamA.DiceFlag == War.DICE_FLAG3 && data.TeamB.DiceFlag == War.DICE_FLAGR2) || 
			(data.TeamB.DiceFlag == War.DICE_FLAGR3 && data.TeamA.DiceFlag == War.DICE_FLAG2)) //其中一方不重摇
        {
            var reRollteam = data.TeamA.DiceFlag == War.DICE_FLAG3 ? data.TeamB : data.TeamA;
            var okteam = data.TeamA.DiceFlag != War.DICE_FLAG3 ? data.TeamB : data.TeamA;
			
			
            reRollteam.NowReDice = 1;
            reRollteam.SkillDice = 0;

			okteam.NowReDice = 0;

            War._setReRollDice(data,reRollteam);

            reRollteam.DiceSkillNum = War._triggerDiceSkill(reRollteam.Member,reRollteam.Dice1,reRollteam.Dice2);

            War._setTwoDiceFlag0(data);

            //技能触发时机4
            //技能触发时机5
			War._resetTriggerTime(data);
            var skills = War._trigger(data.TeamA.Member,data.TeamB.Member,4);

            var s5 = War._trigger(data.TeamA.Member,data.TeamB.Member,5);
            War._pushObjArray(skills,s5);

            War._release(data,skills);

        }
    }

    //确认骰子
    War._onDiceOk = function(data){

        if(data.TeamA.DiceFlag == War.DICE_FLAG3) {
            data.TeamA.NowReDice = 0;
        }

        if(data.TeamB.DiceFlag == War.DICE_FLAGR3) {
            data.TeamB.NowReDice = 0;
        }

        if (data.TeamA.DiceFlag == War.DICE_FLAG3 && data.TeamB.DiceFlag == War.DICE_FLAGR3) {

			if(!data.HasDiceFlagOne){
				data.Result = War.FIGHT_ERROR;
				War._consolelog("_onDiceOk  HasDiceFlagOne FIGHT_ERROR");
				return ;
			}

			War._resetTriggerTime(data);
			var skills = War._trigger(data.TeamA.Member,data.TeamB.Member,8);
			War._release(data,  skills);

            War._doFightOne(data);

			War._setTwoDiceFlag0(data);
			data.HasDiceFlagOne = false;
        }
    }

	War._triggerDiceSkill = function(member,dice1,dice2){
		member.TiggerDiceSkillIds = [];
		var s1 = 0;
		if(!member.Player.DiceSkillIds || !(member.Player.DiceSkillIds.length) ){
			
		} else {
			s1 = member.Player.DiceSkillIds[dice1-1];
			War._consolelog("_triggerDiceSkill. s1 " + s1);

			if (s1 > 0)
			{
				member.TiggerDiceSkillIds.push(s1);
			}

			s1 = member.Player.DiceSkillIds[dice2-1];
			War._consolelog("_triggerDiceSkill. s2 " + s1);

			if (s1 > 0)
			{
				member.TiggerDiceSkillIds.push(s1);
			}
		}

		return member.TiggerDiceSkillIds.length
	}

	War._doFightOne = function (data) {

        var left = War.getDice(data.TeamA); 
        var right = War.getDice(data.TeamB); 
        
        War._consolelog("_doFightOne: " + " left: " + left + " right: " + right);

		War._resetTriggerTime(data);
		var skills1 = War._trigger(data.TeamA.Member,data.TeamB.Member,1);
        War._release(data,  skills1);

		if (data.Result != War.FIGHT_CONTINUE )
		{
			return;
		}

        if (left != right) {

            if (left > right) {
				data.AttackBelong = data.TeamA.Belong ; //攻击方

				War._doFightOnePK(data, data.TeamA, data.TeamB);

            } else {

				data.AttackBelong = data.TeamB.Belong ;//攻击方

				War._doFightOnePK(data, data.TeamB, data.TeamA);

            }
			
        }

		data.AttackBelong = War.BELONG_NO ;
		
        return
    };

	War._doFightOnePK = function(data,attackTeam,targetTeam){

		War._consolelog("--_doFightOnePK targetTeam Member.Belong " +targetTeam.Belong+ " targetTeam.Member.Player.HP " + targetTeam.Member.Player.HP);

        var hp = attackTeam.Member.Player.Attack - targetTeam.Member.Player.Defense;
        if (hp <= 0) {
            hp = 1;
        }
		War._consolelog("_doFightOnePK fight hp "+hp);

        //技能ID 技能目标 技能效果 数值 加入战报列表
        War.appendWarReport(-1,attackTeam.Member.Belong,targetTeam.Member,1,hp);


		War._resetTriggerTime(data);
		if(War.doPlayerHP(data,targetTeam, -hp )){
			return;
		}

		//技能触发时机2 【2】普通攻击命中时
		
		var skills = War._trigger(data.TeamA.Member,data.TeamB.Member,2); 
		
		War._release(data,  skills);
		
	}

	/*
		[
	{Id:1,Type:1,Value:1,weight...},
	{Id:1,Type:2,Value:1,weight...},
	{Id:1,Type:1,Value:1,weight...}
		]
	
	*/
	
	War._setRollDice = function(data,team,isReRoll){

		var p1 = null;
		var p2 = null;
		var p3 = null;
		var p4 = null;

		War._consolelog("_setRollDice. data.FightParam.DiceId " + data.FightParam.DiceId);

		War._consolelog("_setRollDice. data.FightType " + data.FightType,"isReRoll",isReRoll);

		if(data.FightType == War.PVE && data.FightParam.DiceId > 0){
			var t = 0;
			var round = 0;
			if(isReRoll){
				t = 2;
				round = data.TeamA.ReDice;
			} else {
				t = 1;
				round = data.Round;
			}

			War._consolelog("_setRollDice. t " , t , " round " , round);

			var v = data.DiceWeights.Value[t];
			if(v){
				var weight = null;
				var max = data.DiceWeights.MaxValue[t]; 
				War._consolelog("max " , max)
				if(round >= max){
					weight = v[max];
				} else {
					weight = v[round];
				}
				War._consolelog("weight " , weight)
				if(weight) {
					p1 = weight.WeightP1;
					p2 = weight.WeightP2;
					p3 = weight.Weight1;
					p4 = weight.Weight2;
				}
			}
		}

		War._consolelog("p1 " + p1  );
		War._consolelog("p2 " + p2  );
		War._consolelog("p3 " + p3  );
		War._consolelog("p4 " + p4  );

		if(team.Belong == War.BELONG_A){
			
			team.Dice1 = War._getRandDice(data, p1 ? p1 : data.FightParam.DiceWeightA1);

			team.Dice2 = War._getRandDice(data, p2 ? p2 : data.FightParam.DiceWeightA2);
		} else {
			team.Dice1 = War._getRandDice(data, p3 ? p3 : data.FightParam.DiceWeightB1);

			team.Dice2 = War._getRandDice(data, p4 ? p4 : data.FightParam.DiceWeightB2);
		}
		
	};

	War._setReRollDice = function(data,team){

		War._consolelog("func _setReRollDice belong " + team.Belong);

		var mp = War.getMPUse(team.ReDice);

		team.Member.Player.MP -= mp;

		War._consolelog("+++ after reroll team.Member.Player.MP " + team.Member.Player.MP);
		if(team.Member.Player.MP <0){
			team.Member.Player.MP = 0;
		}

		team.ReDice += 1;
		team.AllReDice += 1;

		War._setRollDice(data,team, true);
		
	};

	War._resetTriggerTime = function(data){
		data.TeamA.SeriesEffect = [];
		data.TeamA.ConditionHP = [];

		data.TeamB.SeriesEffect = [];
		data.TeamB.ConditionHP = [];

	};

	War._trigger = function(teamAMember,teamBMember,type){
		War._consolelog("Trigger type: "+ type);

		var skills = [];

		var tmp = War._skillTrigger(teamAMember.Belong, teamAMember.Player.SkillIds,type);

		War._pushObjArray(skills,tmp);
		
		var tmp2 = War._skillTrigger(teamBMember.Belong, teamBMember.Player.SkillIds,type);
		War._pushObjArray(skills,tmp2);

		var tmp3 = War._skillTrigger(teamAMember.Belong, teamAMember.TiggerDiceSkillIds,type);
		War._pushObjArray(skills,tmp3);

		var tmp4 = War._skillTrigger(teamBMember.Belong, teamBMember.TiggerDiceSkillIds,type);
		War._pushObjArray(skills,tmp4);

		War._consolelog("Trigger skills.length " + skills.length);
		
				
		return skills;
	}

	War._skillTrigger = function(belong,skillIds,type){
		
		var tmp = [];
		var j = 0;
		var len = skillIds.length;

		War._consolelog("_skillTrigger skillIds.length " , len,"skillIds",skillIds);

		for(var i=0;i<len;i++){
			if(skillIds[i] > 0){
				var s = War.Skills[skillIds[i]];

				War._consolelog("_skillTrigger skillIds[i] " , skillIds[i] , " i " + i , " s " + s);

				if (s && s.Trigger == type)
				{
					War._consolelog("_skillTrigger Belong: "+ belong + " s.Id " + s.Id +  " j "+j);
					tmp[j] = War._makeSkill(belong,s); 
					j ++;
				}
			}
		}
		War._consolelog("_skillTrigger tmp.length " + tmp.length);
		return tmp;
	}

	

	War._echoobject = function(obj){
		War._consolelog("--_echoobject:");
		if (typeof obj == "object") {
			for(var i in obj){
				if (typeof obj[i] == "object") {
					War._echoobject(obj[i]);
				} else {
					War._consolelog(obj[i]);
				}
			}
		} else {
			War._consolelog(obj);
		}
	}

	War._conditionOperator = function(v, condition, operator, p, paramType ){

		if(condition == 6 || condition == 7 || condition == 9){
			if(paramType == 2){
				p /= 1000 ;
			}
		}
		
		War._consolelog("conditionOperator v", v, "operator", operator, "p", p);
		War._consolelog("condition", condition, "paramType", paramType);

		switch(operator){
			case ">":
				if(v > p){
				} else {
					return false;
				}
				break;
			case ">=":
				if(v >= p){
				} else {
					return false;
				}
				break;
			case "=":
				if(v == p){
				} else {
					return false;
				}
				break;
			case "<":
				if(v < p){
				} else {
					return false;
				}
				break;
			case "<=":
				if(v <= p){
				} else {
					return false;
				}
				break;
			default: 
				return false;
		}
		return true;
	}

	War._conditionCheck = function(data,friendTeam,enemyTeam, skill, i){

		var target = skill.Skill.ConditionTargets[i]; 
		if (target>4 || target < 1) {
 			return false;
		}
		var con = skill.Skill.Conditions[i]; 
		var opt = skill.Skill.Operators[i]; 
		var param = skill.Skill.ConditionParams[i]; 
		var paramType = skill.Skill.ParamTypes[i]; 

		War._consolelog("_conditionCheck skill.Condition: " , con,"opt",opt,"param",param);

		var v = 0;
		var fv = 0;
		var ev = 0;

		switch(con){
			case 0:
				return true;

			case 1:
				fv = friendTeam.DiceSkillNum ;
				ev = enemyTeam.DiceSkillNum ;
				break;
				
			case 2:
				fv = friendTeam.AllReDice ;
				ev = enemyTeam.AllReDice ;
				break;

			case 3:
				fv = friendTeam.ReDice ;
				ev = enemyTeam.ReDice ;
				break;

			case 4:
				fv = friendTeam.NowReDice ;
				ev = enemyTeam.NowReDice ;
				break;
			case 5:
				fv = friendTeam.Member.Player.HP ;
				ev = enemyTeam.Member.Player.HP ;
				break;
			case 6:
 				if(target == 1){
					for (var i=0;i<friendTeam.ConditionHP.length ;i++ ) {
						var vv = friendTeam.ConditionHP[i] / friendTeam.Member.Player.MaxHP;
						if(War._conditionOperator(vv,con,opt,param,paramType )){
							return true;
						}
					}
				} else if (target == 2) {
					for (var i=0;i<enemyTeam.ConditionHP.length ;i++ ) {
						var vv = enemyTeam.ConditionHP[i] / enemyTeam.Member.Player.MaxHP;
						if(War._conditionOperator(vv,con,opt,param,paramType )){
							return true;
						}
					}
				}
				return false;
				 
			case 7:
				fv =  friendTeam.Member.Player.HP  / friendTeam.Member.Player.MaxHP;
				ev =  enemyTeam.Member.Player.HP  / enemyTeam.Member.Player.MaxHP;
				break;
			case 8:
				fv =  friendTeam.Member.Player.MP ;
				ev =  enemyTeam.Member.Player.MP ;
				break;
			case 9:
				fv =  friendTeam.Member.Player.MP / friendTeam.Member.Player.MaxMP ;
				ev =  enemyTeam.Member.Player.MP / enemyTeam.Member.Player.MaxMP ;
				break;
			case 10:
				fv =  friendTeam.Member.Player.Attack ;
				ev =  enemyTeam.Member.Player.Attack ;
				break;
			case 11:
				fv =  friendTeam.Member.Player.Defense ;
				ev =  enemyTeam.Member.Player.Defense ;
				break;
			case 12:
				fv =  War.getDice(friendTeam);
				ev =  War.getDice(enemyTeam); 
				break;
			case 13:

				return War._conditionOperator( data.Round ,con,opt,param,paramType ) ;

			case 14:
				if(target == 1){
					if(War._findArrayInt(friendTeam.SeriesEffect,param)>=0){
						return true;
					}
				} else if (target == 2) {
					if(War._findArrayInt(enemyTeam.SeriesEffect,param)>=0){
						return true;
					}
				}
				return false;
			default :
				return false;
		}

		if(target == 1){
			v = fv ;
		} else if(target == 2) {
			v = ev ;
		} else if (target == 3) {
			v = fv + ev ;
		} else if (target == 4) {
			v = fv - ev ;
		} 

		War._consolelog("_conditionCheck v " , v , " fv: " , fv , " ev: " , ev);

		return War._conditionOperator(v,con,opt,param,paramType ) ;
	}

	War._findArrayInt = function(arr,v){
		for(var i = 0;i<arr.length;i++){
			if (arr[i] == v) {
				return i;
			}
		}
		return -1;
	}

	War._condition = function(data,skill){

		War._consolelog("_condition skill.Skill.Id: " + skill.Skill.Id);

		War._consolelog(" skill.ReleaseRatio: " + skill.Skill.ReleaseRatio);

			var r1 = War._getRand(data, 1000);

			War._consolelog("_condition r1: " + r1);

			if(r1 > skill.Skill.ReleaseRatio){
				return;
			}

			r1 = War._getRand(data, 1000);

			War._consolelog("_condition r1: " + r1 + " skill.HitRatio: " + skill.Skill.HitRatio );
			
			var isHit = true;
			if(r1 > skill.Skill.HitRatio){
				isHit = false;
			}
			
			var skillTargetTeam = {};
			var friendTeam = {};
			var enemyTeam = {};

			if(skill.Belong == War.BELONG_A){
				friendTeam = data.TeamA;
				enemyTeam =  data.TeamB;
			} else {
				friendTeam = data.TeamB;
				enemyTeam =  data.TeamA;
			}
			skillTargetTeam = skill.Skill.Target == 1 ? friendTeam : enemyTeam;
			
			var check = true;
			for(var i=0; i<(skill.Skill.ConditionTargets).length; i++){
				
				if (! War._conditionCheck(data,friendTeam,enemyTeam, skill, i)) {
					check = false;
					break;
				}
			}

			War._consolelog("_condition check: " + check);

			if (check) {
				War._settlement(data,friendTeam,enemyTeam,skillTargetTeam,skill,isHit,false);
			}
	}

	War._skillSort = function(ss){
		var skills = [];
		var len = ss.length ;
		for(var i=0;i<len;i++){
			if(ss[i].Skill){
				skills.push(ss[i]);
			}
		}

		var len = skills.length ;
		for(var i=0;i<len;i++){
			for(var j=i+1;j<len;j++){
				if(skills[i].Skill.Sort < skills[j].Skill.Sort){
					var t = skills[i];
					skills[i] = skills[j];
					skills[j] = t;
				} else if(skills[i].Skill.Sort == skills[j].Skill.Sort){
					if(skills[i].Belong == War.BELONG_B && skills[j].Belong == War.BELONG_A){
						var t = skills[i];
						skills[i] = skills[j];
						skills[j] = t;
					}
				}
			}
		}

		return skills;
	}

	War._release = function(data,skills){
		if (data.Result != War.FIGHT_CONTINUE) {
			return;
		}

		skills = War._skillSort(skills);
		var len = skills.length;
		War._consolelog("Release skills.length: " + len);
		for(var i=0;i<len;i++){
			
			War._condition(data,skills[i]);

			if (data.Result != War.FIGHT_CONTINUE) {
				return;
			}
			
		}
	};

	War._settlement = function(data,friendTeam,enemyTeam,skillTargetTeam,skill,isHit,isCopy){

		var ratio = 0;
		switch(skill.Skill.EffectParam) {
			case 0: 
				ratio = 1;
				break;
			case 1:
				ratio = friendTeam.DiceSkillNum;
				break;
			case 2:
				ratio = enemyTeam.DiceSkillNum;
				break;
			case 3:
				ratio = friendTeam.DiceSkillNum + enemyTeam.DiceSkillNum;
				break;
			case 4:
				ratio = data.Round;
				break;
		}

		var skillTargetMember = skillTargetTeam.Member

		var oldvalue = War._getSettlementValue(data, friendTeam.Member.Player, enemyTeam.Member.Player, skill.Skill) * ratio;

		War._consolelog("Settlement skill.Effect: " , skill.Skill.Effect , " oldvalue: " , oldvalue , " ratio: ",ratio , " isHit: ",isHit);

		if (!isHit) {
			return;
		}

		var value = Math.floor(oldvalue);

		if(friendTeam.StrengthenSkill[skill.Skill.Series] ){
			value = Math.floor(oldvalue * (1 + friendTeam.StrengthenSkill[skill.Skill.Series] / 1000 ));
		}

		if(value >= 0 && value < 1){
			value = 1;
		}

		War._consolelog("value", value)
		
		switch(skill.Skill.Effect) {
			case 0:
				break;
			case 1:
				
                War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,value);

				if(War.doPlayerHP(data,skillTargetTeam, -value )){
					return;
				}

				break;
			case 2:
				skillTargetMember.Player.MP -= value;
                War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,value);
                //技能ID 技能目标 技能效果 数值 加入战报列表
				if(skillTargetMember.Player.MP<0){
					skillTargetMember.Player.MP = 0;
				}
				break;
			case 3:
                War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,value);

				if(War.doPlayerHP(data,skillTargetTeam, value )){
					return;
				}
				
				break;
			case 4:
				skillTargetMember.Player.MP += value;
                War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,value);

				if(skillTargetMember.Player.MP > skillTargetMember.Player.MaxMP){
					skillTargetMember.Player.MP = skillTargetMember.Player.MaxMP
				}
				if(skillTargetMember.Player.MP<0){
					skillTargetMember.Player.MP = 0;
				}

				War._consolelog("+++ after skill now Mp: " + skillTargetMember.Player.MP);

				break;
			case 5:
				skillTargetMember.Player.Attack += value;
                War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,value);
				if(skillTargetMember.Player.Attack<0){
					skillTargetMember.Player.Attack = 0;
				}
				break;
			case 6:
				skillTargetMember.Player.Defense += value;
                War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,value);
				if(skillTargetMember.Player.Defense<0){
					skillTargetMember.Player.Defense = 0;
				}
				break;
			case 7:
				skillTargetMember.Player.Attack -= value;
                War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,value);
				if(skillTargetMember.Player.Attack<0){
					skillTargetMember.Player.Attack = 0;
				}
				break;
			case 8:
				skillTargetMember.Player.Defense -= value;
                War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,value);
				if(skillTargetMember.Player.Defense<0){
					skillTargetMember.Player.Defense = 0;
				}
				break;
			case 9:
				skillTargetTeam.SkillDice += value;
                War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,value);
				break;
			case 10:
				
                War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,-value);

				if(War.doPlayerHP(data,skillTargetTeam,-value )){
					return;
				}
				
                War.appendWarReport(skill.Skill.Id,skill.Belong,friendTeam.Member,skill.Skill.Effect,value);

				if(War.doPlayerHP(data,friendTeam, value )){
					return;
				}

				break;
			case 11:
				var h = value - enemyTeam.Member.Player.Defense; 
				if (h <= 0) {
					h = 1;
				}
				
                War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,-h);

				if(War.doPlayerHP(data,skillTargetTeam,-h )){
					return;
				}

				break;
			case 12:   // 1 10 11 12 可以合并
				var h = value - enemyTeam.Member.Player.Defense; 
				if (h <= 0) {
					h = 1;
				}
				
				War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,-h);
				if(War.doPlayerHP(data,skillTargetTeam,-h )){
					return;
				}
				
				War.appendWarReport(skill.Skill.Id,skill.Belong,friendTeam.Member,skill.Skill.Effect,h);
				if(War.doPlayerHP(data,friendTeam, h )){
					return;
				}

				break;
			case 13:
				War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,value);

				skillTargetTeam.CopySkill += 1;
				break;
			case 14:
				War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,value);

				skillTargetTeam.LastOneHP += 1;
				break;
			case 15:
				War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,value);
				
				if(!skillTargetTeam.StrengthenSkill[skill.Skill.Series]){
					skillTargetTeam.StrengthenSkill[skill.Skill.Series] = 0;
				}
				skillTargetTeam.StrengthenSkill[skill.Skill.Series] += oldvalue;
				break;
			case 16:
				War.appendWarReport(skill.Skill.Id,skill.Belong,skillTargetMember,skill.Skill.Effect,value);

				if(!skillTargetTeam.StrengthenSkill[skill.Skill.Series]){
					skillTargetTeam.StrengthenSkill[skill.Skill.Series] = 0;
				}
				skillTargetTeam.StrengthenSkill[skill.Skill.Series] -= oldvalue;
				break;
		}

		skillTargetTeam.SeriesEffect.push(skill.Skill.Series);

		War._consolelog("skillTargetTeam.CopySkill " + skillTargetTeam.CopySkill);
		War._consolelog("skillTargetTeam.LastOneHP", skillTargetTeam.LastOneHP);
		War._consolelog("isCopy ", isCopy);
		War._consolelog("skillTargetTeam.Belong ", skillTargetTeam.Belong);
		War._consolelog("friendTeam.Belong ", friendTeam.Belong);

		if(!isCopy && skillTargetTeam.CopySkill > 0){
			if(skillTargetTeam.Belong !=  friendTeam.Belong){

				skillTargetTeam.CopySkill -= 1;

				var skillother = War._makeSkill(enemyTeam.Belong, skill.Skill);

				War._consolelog("_settlement copyskill");

				War._settlement(data,enemyTeam,friendTeam,friendTeam,skillother,isHit, true);
			}
		}

		if (skill.Skill.OtherRatio > 0 && skill.Skill.OtherId > 0)
		{
			var r = War._getRand(data, 1000);
			if (r < skill.Skill.OtherRatio)
			{
				var s = War.Skills[skill.Skill.OtherId];
				if (s)
				{
					var skills = [];
					skills[0] = War._makeSkill(friendTeam.Belong,s);
					War._release(data,skills);
				}
			}			
		}
		
	};

	War.doPlayerHP = function(data, team, hp){
		var m = team.Member;
		var oldhp = m.Player.HP;
		War._consolelog("-- doPlayerHP hp " , hp , " m.Belong " , m.Belong , " m.Player.HP " , m.Player.HP)
		m.Player.HP += hp
		War._consolelog("m.Player.HP " , m.Player.HP)

		if(m.Player.HP > m.Player.MaxHP) {
			m.Player.HP = m.Player.MaxHP
		}
		
		if(m.Player.HP <= 0) {
			if(team.LastOneHP >0 ){
				m.Player.HP = 1;
				team.LastOneHP -= 1 ;
			} else {
				if (m.Belong == War.BELONG_A ){
					data.Result = War.WIN_B ;
				} else {
					data.Result = War.WIN_A ;
				}
				return true ;
			}
		}

		var change = m.Player.HP - oldhp;
		War._consolelog("change", change)
		team.ConditionHP.push(change);

		return false
	}

	War._getSettlementValue = function(data,friendPlayer,enemyPlayer,skill){

		War._consolelog("_getSettlementValue skill.ValueType",skill.ValueType);

		switch (skill.ValueType)
		{
		case 1:
			
			var a = skill.ValueEnd - skill.ValueBegin;
			if(a<=0){
				a = 1;
			}
			var r = War._getRand(data, a);

			return skill.ValueBegin + Math.floor(r);

		case 2:

			
			var a = skill.RatioEnd - skill.RatioBegin;
			if(a<=0){
				a = 1;
			}
			var r = War._getRand(data, a);

			var b = (skill.RatioBegin + r)/1000;

			War._consolelog("_getSettlementValue b: ", b , " skill.RatioBegin: ",skill.RatioBegin , " skill.RatioEnd: " , skill.RatioEnd);
			War._consolelog("skill.RatioTarget " , skill.RatioTarget);

			switch(skill.RatioTarget){
				case 1:
					return friendPlayer.MaxHP * b ;
				case 2:
					return friendPlayer.HP * b ;
				case 3:
					return friendPlayer.Attack * b ;
				case 4:
					War._consolelog("friendPlayer.Defense " , friendPlayer.Defense);
					return friendPlayer.Defense * b ;
				case 5:
					return friendPlayer.MaxMP * b ;
				case 6:
					return friendPlayer.MP * b ;
				case 7:
					return friendPlayer.AttackOld * b ;
				case 8:
					War._consolelog("friendPlayer.DefenseOld " , friendPlayer.DefenseOld);
					return friendPlayer.DefenseOld * b ;

				case 9:
					return enemyPlayer.MaxHP * b ;
				case 10:
					return enemyPlayer.HP * b ;
				case 11:
					return enemyPlayer.Attack * b ;
				case 12:
					War._consolelog("enemyPlayer.Defense " , enemyPlayer.Defense);
					return enemyPlayer.Defense * b ;
				case 13:
					return enemyPlayer.MaxMP * b ;
				case 14:
					return enemyPlayer.MP * b ;
				case 15:
					return enemyPlayer.AttackOld * b ;
				case 16:
					War._consolelog("enemyPlayer.DefenseOld " , enemyPlayer.DefenseOld);
					return enemyPlayer.DefenseOld * b ;
				case 17:
					var aa = friendPlayer.Attack - enemyPlayer.Defense ;
					if(aa < 0){
						aa = 0;
					}
					return aa * b ;
				case 18:
					var aa = enemyPlayer.Attack - friendPlayer.Defense  ;
					if(aa < 0){
						aa = 0;
					}
					return aa * b ;
				case 19:
					return friendPlayer.HP / friendPlayer.MaxHP * b ;
				case 20:
					return (friendPlayer.MaxHP - friendPlayer.HP) / friendPlayer.MaxHP * b ;
				case 21:
					return enemyPlayer.HP / enemyPlayer.MaxHP * b ;
				case 22:
					return (enemyPlayer.MaxHP - enemyPlayer.HP) / enemyPlayer.MaxHP * b ;
			}

			return 0;
		
		}
	};
	
    War._getRandDice = function (data, diceWeight) {
		War._consolelog("")
		War._consolelog("_getRandDice seed1: "+data.Seed1);
		War._consolelog("_getRandDice seed2: "+data.Seed2);

		War._consolelog(" diceWeight: " + diceWeight);

		if (!diceWeight || !diceWeight.length || diceWeight.length < 6 ){
			War._consolelog("!diceWeight dice 1")
			return 1;
		}

		var num = diceWeight[5];
		if (!num) {
			num = 0;
		}

		War._consolelog("_getRandDice num: "+num);

        var r = War._getRand(data, num);

		War._consolelog("_getRandDice _getRand: "+r);
		
		for (var i=0; i< 6; i++)
		{
			if(r <= diceWeight[i]){
				War._consolelog("_getRandDice Dice "+(i+1));
				return i+1;
			}
		}

		War._consolelog("end _getRandDice dice 1")
        return 1;
    };

	War._getRand = function(data, number){
		var s2 = War.RandList[data.Seed2];

		War._consolelog("_getRand s2: "+s2);

		if (!s2)
		{
			s2 = 1;
		}

		var r = Math.floor((( (data.Seed1 + s2) * 9301 + 49297 ) % 233280 ) /  233280  * number);
		if(r < 0 ){
			r = 0;
		}
		War._seedAdd(data);
		return r
	}

	War._seedAdd = function (data){
		var s = data.Seed2 + 1;
		if (s >= War.RandList.length)
		{
			s = 0;
		}
		data.Seed2 = s;
	}

    //加入战报数据 //外部调用
    War.appendWarReport = function (SkillId,Player,Traget,HurtType,Value){
        if(War.isServer) return;//服务端无需记录
        var warReport = {
            "SkillId": SkillId,
            "Player": Player,
            "Traget": Traget.Belong,
            "HurtType": HurtType,
            "Value": Value
        };
        War._consolelog("appendWarReport:" + JSON.stringify(warReport));
        War.warReportList.push(warReport);
    }

    //获得骰子技能列表 //外部调用
    War.getDiceSkillList = function (skills){
        skills = War._skillSort(skills);
        return skills
    }

    //加入战斗操作 //外部调用
    War.appendWarStep = function (Value){
        if(War.isServer) return;//服务端无需记录
        War.warStepList.push(Value);
    }

    //重置战斗数据  //外部调用
    War.resetWar = function(){
        War.warStepList = [];
        War.warReportList = [];
    }

	War._pushObjArray = function(obj1,obj2){
		var len = obj2.length;
		for(var i=0;i<len;i++){
			obj1.push(obj2[i]);
		}
	};

    War._consolelog = function () {

		var str = "";
		var len = arguments.length;
		for(var i =0;i<len; i++){
			if(typeof arguments[i] == "object"){
				str += JSON.stringify(arguments[i]) + " ";
			} else {
				str += arguments[i] + " ";
			}
		}
        console.log(str);
    };

	War.DefaultWeightA1 = [100,200,300,400,500,600];
	War.DefaultWeightA2 = [100,200,300,400,500,600];
	War.DefaultWeightB1 = [100,200,300,400,500,600];
	War.DefaultWeightB2 = [100,200,300,400,500,600];

	War.DiceWeights = {};//全局 json 表
	
	War.PVE = 1; //pve
	War.PVP = 2; //pvp

	War.BELONG_NO = 0; //不属于任何一方 //外部调用
	War.BELONG_A = 1; //属于左边 //外部调用
	War.BELONG_B = 2; //属于右边 //外部调用

	War.DICE_FLAG0 = 0; //没有任何操作 //外部调用
    War.DICE_FLAG1 = 1; //摇 //外部调用
    War.DICE_FLAG2 = 2; //重摇 //外部调用
    War.DICE_FLAG3 = 3; //确认 //外部调用
    War.DICE_FLAGR1 = -1; //右边摇 //外部调用
    War.DICE_FLAGR2 = -2; //右边重摇 //外部调用
    War.DICE_FLAGR3 = -3; //右边确认 //外部调用

    War.FIGHT_CONTINUE = 0; //战斗结果: 继续操作 //外部调用
    War.WIN_A = 1; //左边胜利 //外部调用
	War.WIN_B = 2; //右边胜利 //外部调用
	War.FIGHT_ERROR = 3; //结算错误 //外部调用

	War.REDICE_MP = 2; //重摇扣mp点数的基数 //外部调用
    
	War.Skills = {}; //全局技能. 不能修改其中的数据 //外部调用

    War.warStepList = [];//战斗操作列表 //外部调用
    War.warReportList = [];//战斗战报列表 //外部调用

    War.isServer = true;//是否是服务端环境 //外部调用

	War.RandList = []; //数据在另外文件

    return War;
})();
