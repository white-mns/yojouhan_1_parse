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
require "./source/chara/Status.pm";
require "./source/chara/FortressData.pm";
require "./source/chara/CastleStructure.pm";
require "./source/chara/Payoff.pm";

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
    if(ConstData::EXE_CHARA_NAME)             { $self->{DataHandlers}{Name}            = Name->new();}
    if(ConstData::EXE_CHARA_STATUS)           { $self->{DataHandlers}{Status}          = Status->new();}
    if(ConstData::EXE_CHARA_FORTRESS_DATA)    { $self->{DataHandlers}{FortressData}    = FortressData->new();}
    if(ConstData::EXE_CHARA_CASTLE_STRUCTURE) { $self->{DataHandlers}{CastleStructure} = CastleStructure->new();}
    if(ConstData::EXE_CHARA_PAYOFF)           { $self->{DataHandlers}{Payoff}          = Payoff->new();}

    #初期化処理
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Init($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas});
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
    my $directory = './data/utf/' . $self->{ResultNo0};
    $directory .= ($self->{GenerateNo} == 0) ? '' :  '_' . $self->{GenerateNo};
    $directory .= '/RESULT';
    if(ConstData::EXE_ALLRESULT){
        #結果全解析
        my @file_list = grep { -f } glob("$directory/c*.html");
        my $i = 0;
        foreach my $file_adr (@file_list){
            if($file_adr =~ /catalog/) {next};
            $i++;
            if($i % 10 == 0){print $i . "\n"};

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
    my $status_nodes     = &GetNode::GetNode_Tag_Class("table","charadata", \$tree);
    $status_nodes = scalar(@$status_nodes) ? $status_nodes : &GetNode::GetNode_Tag_Class("table","charadata2", \$tree);
    my $spec_data_nodes    = &GetNode::GetNode_Tag_Class("table","specdata", \$tree);
    my $machine_data_nodes = &GetNode::GetNode_Tag_Class("table","machinedata", \$tree);
    my $item_caption_nodes = &GetNode::GetNode_Tag_Id("div","item", \$tree);
    my $nextday_h2_nodes   = &GetNode::GetNode_Tag_Id("h2","nextday", \$tree);

    # データリスト取得
    if(exists($self->{DataHandlers}{Name}))            {$self->{DataHandlers}{Name}->GetData($e_no, $minieffect_nodes)};
    if(exists($self->{DataHandlers}{Status}))          {$self->{DataHandlers}{Status}->GetData($e_no, $$status_nodes[0])};
    if(exists($self->{DataHandlers}{FortressData}))    {$self->{DataHandlers}{FortressData}->GetData($e_no, $$spec_data_nodes[0])};
    if(exists($self->{DataHandlers}{CastleStructure})) {$self->{DataHandlers}{CastleStructure}->GetData($e_no, $$machine_data_nodes[0], $$item_caption_nodes[0])};
    if(exists($self->{DataHandlers}{Payoff}))          {$self->{DataHandlers}{Payoff}->GetData($e_no, $$nextday_h2_nodes[0]->right)};

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
