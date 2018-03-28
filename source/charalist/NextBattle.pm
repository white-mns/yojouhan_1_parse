#===================================================================
#        PC名、愛称取得パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package NextBattle;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  
  bless {
        Datas => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "block_no",
                "e_no",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/charalist/next_battle_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,名前データノード
#-----------------------------------#
sub GetData{
    my $self     = shift;
    my $hr_nodes = shift;

    $self->GetNextBattleData($hr_nodes);
    
    return;
}
#-----------------------------------#
#    次回の組み合わせデータ取得
#------------------------------------
#    引数｜名前データノード
#-----------------------------------#
sub GetNextBattleData{
    my $self     = shift;
    my $hr_nodes = shift;

    foreach my $hr_node (@$hr_nodes){

        if($hr_node->as_text !~ /第(\d+)ブロック/){ next;}

        my $block_no =$1;
        my @right_nodes = $hr_node->right;
        my $table_node = $right_nodes[2];

        my $a_nodes = &GetNode::GetNode_Tag("a", \$table_node);

        foreach my $a_node (@$a_nodes){
            my $link_text = $a_node->attr("href");

            if($link_text !~ /RESULT\/c(\d{4})\.html/){ next;}
            my $e_no = $1+0;
            my @datas=($self->{ResultNo}, $self->{GenerateNo},  $block_no, $e_no);
            $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, @datas));

        }
    }

    return;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
