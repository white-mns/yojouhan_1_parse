#===================================================================
#        ステータス取得パッケージ
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
package Status;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  my %datas = ();
  
  bless {
        Datas        => \%datas,
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    my $result_num = shift;
    my $generate_num = shift;
    

    $self->{ResultNo}   = $result_num;
    $self->{GenerateNo} = $generate_num;
    
    #初期化
    my $data = StoreData->new();
    my @headerList = (
                "result_no",
                "generate_no",
                "e_no",
                "acc_profit",
                "rp",
                "repute",
                "charm",
                "tact",
                "smile",
                "elegance",
                "knowledge",
                "perseverance",
                "funds",
                "exp",
    );

    $self->{Datas}{Data}  = $data;
    $self->{Datas}{Data}->Init(\@headerList);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/status_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,ステータスデータノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $e_no  = shift;
    my $status_nodes = shift;
    
    $self->{ENo} = $e_no;

    $self->GetStatusData($status_nodes);
    
    return;
}
#-----------------------------------#
#    ステータスデータ取得
#------------------------------------
#    引数｜ステータスデータノード
#-----------------------------------#
sub GetStatusData{
    my $self  = shift;
    my $status_node  = shift;

    my ($acc_profit, $rp,$repute, $charm, $tact, $smile, $elegance, $knowledge, $perseverance, $funds, $exp) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    my $th_nodes = &GetNode::GetNode_Tag("th", \$status_node);

    foreach my $th_node (@$th_nodes){
        if($th_node->as_text eq "累積粗利"){
            $acc_profit = $th_node->right->as_text;

        }elsif($th_node->as_text eq "RP"){
            $rp = $th_node->right->as_text;

        }elsif($th_node->as_text eq "あなたの評判"){
            $repute = $th_node->right->as_text;

        }elsif($th_node->as_text eq "魅力"){
            $charm = $th_node->right->as_text;

        }elsif($th_node->as_text eq "機転"){
            $tact = $th_node->right->as_text;

        }elsif($th_node->as_text eq "笑顔"){
            $smile = $th_node->right->as_text;

        }elsif($th_node->as_text eq "気品"){
            $elegance = $th_node->right->as_text;

        }elsif($th_node->as_text eq "知識"){
            $knowledge = $th_node->right->as_text;

        }elsif($th_node->as_text eq "忍耐"){
            $perseverance = $th_node->right->as_text;

        }elsif($th_node->as_text eq "所持資金"){
            $funds = $th_node->right->as_text;

        }elsif($th_node->as_text eq "経験値"){
            $exp = $th_node->right->as_text;

        }
    }
    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $acc_profit, $rp,$repute, $charm, $tact, $smile, $elegance, $knowledge, $perseverance, $funds, $exp);
    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, @datas));

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
