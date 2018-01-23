#===================================================================
#        キャラステータス解析パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use ConstData;
use HTML::TreeBuilder;
use source::lib::GetNode;


require "./source/lib/IO.pm";
require "./source/lib/time.pm";
require "./source/lib/NumCode.pm";

require "./source/chara/Name.pm";
#require "./source/chara/Item.pm";
#require "./source/chara/Skill.pm";
#require "./source/chara/Status.pm";
#require "./source/chara/Profile.pm";
#require "./source/chara/Purpose.pm";
#require "./source/chara/Gacha.pm";
#require "./source/chara/Comp.pm";
#require "./source/chara/NextBattle.pm";
#require "./source/chara/BattleResult.pm";
#require "./source/chara/Equip.pm";
#require "./source/chara/SkillUse.pm";

#require "./source/data/SkillList.pm";
#require "./source/data/GemList.pm";
#require "./source/data/EquipList.pm";
#require "./source/data/EnemyList.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package Character;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class        = shift;
  my %datas        = ();
  my %dataHandlers = ();
  my %methods      = ();

  bless {
    Datas         => \%datas,
    DataHandlers  => \%dataHandlers,
    Methods       => \%methods,
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;
    $self->{ResultNo0} = sprintf("%03d", $self->{ResultNo});

    #インスタンス作成
    if(ConstData::EXE_CHARA_NAME)          { $self->{DataHandlers}{Name}         = Name->new();}
    #if(ConstData::EXE_CHARA_ITEM)          { $self->{DataHandlers}{Item}         = Item->new();}
    #if(ConstData::EXE_CHARA_SKILL)         { $self->{DataHandlers}{Skill}        = Skill->new();}
    #if(ConstData::EXE_CHARA_STATUS)        { $self->{DataHandlers}{Status}       = Status->new();}
    #if(ConstData::EXE_CHARA_PROFILE)       { $self->{DataHandlers}{Profile}      = Profile->new();}
    #if(ConstData::EXE_CHARA_PURPOSE)       { $self->{DataHandlers}{Purpose}      = Purpose->new();}
    #if(ConstData::EXE_CHARA_NEXT_BATTLE)   { $self->{DataHandlers}{NextBattle}   = NextBattle->new();}
    #if(ConstData::EXE_CHARA_BATTLE_RESULT) { $self->{DataHandlers}{BattleResult} = BattleResult->new();}
    #if(ConstData::EXE_CHARA_EQUIP)         { $self->{DataHandlers}{Equip}        = Equip->new();}
    #if(ConstData::EXE_CHARA_SKILL_USE)     { $self->{DataHandlers}{SkillUse}     = SkillUse->new();}
    #$self->{DataHandlers}{EquipList} = EquipList->new();
    #$self->{DataHandlers}{SkillList} = SkillList->new();
    #$self->{DataHandlers}{GemList}   = GemList->new();
    #$self->{DataHandlers}{EnemyList} = EnemyList->new();

    #初期化処理
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Init($self->{ResultNo},$self->{GenerateNo});
    }
    
    return;
}

#-----------------------------------#
#    圧縮結果から詳細データファイルを抽出
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self        = shift;

    print "read files...\n";

    my $start = 1;
    my $end   = 0;
    my $directory = './data/utf/' . $self->{ResultNo0} . '/RESULT';
    $directory .= ($self->{GenerateNo} == 0) ? '' :  '_' . $self->{GenerateNo};
    if(ConstData::EXE_ALLRESULT){
        #結果全解析
        my @file_list = grep { -f } glob("$directory/c*.html");
        my $i = 0;
        foreach my $file_adr (@file_list){
            if($file_adr =~ /catalog/) {next};
            if($i % 10 == 0){print $i . "\n"};
            $i++;

            $file_adr =~ /c(.*?)\.html/;
            my $file_name = $1;
            my $e_no = $file_name+0;
            
            $self->ParsePage($directory  . "/c" . $file_name . ".html", $e_no);
        }
    }else{
        #指定範囲解析
        $start = ConstData::FLAGMENT_START;
        $end   = ConstData::FLAGMENT_END;
        print "$start to $end\n";

        for(my $i=$start; $i<=$end; $i++){
            if($i % 10 == 0){print $i . "\n"};
            my $i0 = sprintf("%04d", $i);
            $self->ParsePage($directory  . "/c" . $i0 . ".html",$i);
        }
    }

    
    return ;
}
#-----------------------------------#
#       ファイルを解析
#-----------------------------------#
#    引数｜ファイル名
#    　　　ENo
#    　　　FNo
##-----------------------------------#
sub ParsePage{
    my $self        = shift;
    my $file_name   = shift;
    my $e_no        = shift;

    #結果の読み込み
    my $content = "";
    $content = &IO::FileRead($file_name);

    if(!$content){ return;}

    $content = &NumCode::EncodeEscape($content);
        
    #スクレイピング準備
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);

    my $player_nodes     = &GetNode::GetNode_Tag_Id("h2","player", \$tree);
    my $charadata_node   = $$player_nodes[0]->right;
    my $minieffect_nodes = &GetNode::GetNode_Tag_Class("div","minieffect", \$charadata_node);
    my $item_nodes       = &GetNode::GetNode_Tag_Class("td","ItemData", \$charadata_node);
    my $skill_nodes      = &GetNode::GetNode_Tag_Class("td","SkillData", \$tree);
    my $pcdata_nodes     = &GetNode::GetNode_Tag_Class("td","PCData", \$tree);
    my $profile_nodes    = &GetNode::GetNode_Tag_Class("td","proftable", \$tree);
    my $open_nodes       = &GetNode::GetNode_Tag_Name("div","open", \$tree);
    my $bounty_nodes     = &GetNode::GetNode_Tag_Class("td","bounty", \$tree);
    my $subtitle_nodes   = &GetNode::GetNode_Tag_Class("th","SubTitle", \$tree);
    my $use_skill_nodes  = &GetNode::GetNode_Tag_Name("div","Skill", \$tree);

    # データリスト取得
    if(exists($self->{DataHandlers}{Name}))         {$self->{DataHandlers}{Name}->GetData($e_no, $minieffect_nodes)};
    #if(exists($self->{DataHandlers}{Item}))         {$self->{DataHandlers}{Item}->GetData($e_no, $$item_nodes[1], $self->{CommonDatas})};
    #if(exists($self->{DataHandlers}{Skill}))        {$self->{DataHandlers}{Skill}->GetData($i, $$skill_nodes[0], $self->{DataHandlers}{SkillList}, $self->{DataHandlers}{GemList})};
    #if(exists($self->{DataHandlers}{Status}))       {$self->{DataHandlers}{Status}->GetData($i, $$pcdata_nodes[0], $bounty_nodes)};
    #if(exists($self->{DataHandlers}{Profile}))      {$self->{DataHandlers}{Profile}->GetData($i, $$profile_nodes[0])};
    #if(exists($self->{DataHandlers}{Purpose}))      {$self->{DataHandlers}{Purpose}->GetData($i, $$pcdata_nodes[0])};
    #if(exists($self->{DataHandlers}{NextBattle}))   {$self->{DataHandlers}{NextBattle}->GetData($i, $subtitle_nodes, $self->{DataHandlers}{EnemyList})};
    #if(exists($self->{DataHandlers}{BattleResult})) {$self->{DataHandlers}{BattleResult}->GetData($i, $subtitle_nodes, $self->{DataHandlers}{EnemyList})};
    #if(exists($self->{DataHandlers}{Equip}))        {$self->{DataHandlers}{Equip}->GetData($i, $$profile_nodes[0], $subtitle_nodes)};
    #if(exists($self->{DataHandlers}{SkillUse}))     {$self->{DataHandlers}{SkillUse}->GetData($i, $$profile_nodes[0], $use_skill_nodes, $self->{DataHandlers}{SkillList})};

    $tree = $tree->delete;
}
#-----------------------------------#
#       該当ファイル数を取得
#-----------------------------------#
#    引数｜ディレクトリ名
#    　　　ファイル接頭辞
##-----------------------------------#
sub GetFileNo{
    my $directory   = shift;
    my $prefix    = shift;

    #ファイル名リストを取得
    my @fileList = grep { -f } glob("$directory/$prefix*.html");

    my $max= 0;
    foreach(@fileList){
        $_ =~ /$prefix(\d+).html/;
        if($max < $1) {$max = $1;}
    }
    return $max
}

#-----------------------------------#
#    出力
#-----------------------------------#
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Output();
    }
    return;
}

1;
