#===================================================================
#        定数設定
#-------------------------------------------------------------------
#            (C) 2016 @white_mns
#===================================================================

# パッケージの定義    ---------------#    
package ConstData;

# パッケージの使用宣言    ---------------#
use strict;
use warnings;

# 定数宣言    ---------------#
    use constant SPLIT        => "\t";    # 区切り文字

# ▼ 実行制御 =============================================
#      実行する場合は 1 ，実行しない場合は 0 ．
    
    use constant EXE_BATTLE       => 1;    # 戦闘結果データ生成
    
    use constant EXE_CHARA        => 1;
        use constant EXE_CHARA_NAME                            => 1;
        use constant EXE_CHARA_ITEM                            => 1;
        use constant EXE_CHARA_STATUS                          => 1;
        use constant EXE_CHARA_FORTRESS_DATA                   => 1;
        use constant EXE_CHARA_FORTRESS_GUARD                  => 1;
        use constant EXE_CHARA_CASTLE_CONDITION_TEXT           => 1;
        use constant EXE_CHARA_CASTLE_STRUCTURE                => 1;
        use constant EXE_CHARA_CASTLE_STRUCTURE_MAJOR_TYPE_NUM => 1;
        use constant EXE_CHARA_PAYOFF                          => 1;
    use constant EXE_CHARALIST    => 1;
        use constant EXE_CHARALIST_NEXT_BATTLE  => 1;
    use constant EXE_MARKET       => 1;
    use constant EXE_MEGANE       => 1;
    use constant EXE_NEW          => 0;
        use constant EXE_NEW_FUKA            => 1;
    use constant EXE_DATA         => 1;
        use constant EXE_DATA_UNIT_TYPE         => 1;
        use constant EXE_DATA_UNIT_ORIG_NAME    => 1;
        use constant EXE_DATA_FUKA              => 1;
        use constant EXE_DATA_ELEMENTAL         => 1;
        use constant EXE_DATA_REGALIA           => 1;
        use constant EXE_DATA_CASTLE_CONDITION  => 1;
        use constant EXE_DATA_FRAME_TYPE        => 1;
        use constant EXE_DATA_ADD_EFFECT        => 1;


    use constant SAVE_SAMEDATA    => 0;    # 0=>上書き 1=>再更新
    use constant GENERATE_NO      => 0;    # 0=>上書き 1=>再更新

1;
