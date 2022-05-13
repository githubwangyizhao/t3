class BuffNewEffectEnum 
{
     /**【停止】眩晕,冰冻   【[dizzy]】*/
     public static DIZZY:number                          = 1;
     /**【击飞-眩晕】击飞接眩晕（击飞期间无法操作）（击飞时间=填表参数）（其他时间眩晕）    【[knock1,击飞时间]】*/
     public static KNOCK1:number                         = 2;
     /**【击退-反方向-眩晕】（击退期间无法操作）（击退方向为BUFF的反方向）（击退时间=填表参数）（其他时间眩晕）    【[knock2,击退像素,击退时间]】*/
     public static KNOCK2:number                         = 3;
     /**【击退-固定值-眩晕】（击退期间无法操作）（击退方向为参数）（击退时间=填表参数）（其他时间眩晕）   【[knock3,击退像素,方向角度,击退时间]】*/
     public static KNOCK3:number                         = 4;
     /**【击飞】纯击飞（击飞期间无法操作）（击飞时间=buff持续时间）【[knock4]】*/
     public static KNOCK4:number                         = 5;
     /**【击退-反方向】（击退期间无法操作）（击退方向为BUFF的反方向）（击退时间=buff持续时间）    【[knock5,击退像素]】*/
     public static KNOCK5:number                         = 6;
     /**【击退-固定值-眩晕】（击退期间无法操作）（击退方向为参数）（击退时间=buff持续时间）   【[knock6,击退像素,方向角度]】*/
     public static KNOCK6:number                         = 7;

     public constructor() {} 
}
