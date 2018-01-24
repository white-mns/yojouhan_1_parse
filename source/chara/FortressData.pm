#===================================================================
#        城塞データ取得パッケージ
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
package FortressData;

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
                "grand",
                "caution",
                "continuance",
                "enthusiasm",
                "goodwill",
                "forecast",
                "stock",
                "high_grade",
                "mob",
                "drink",
                "regalia",
    );

    $self->{Datas}{FortressData}  = $data;
    $self->{Datas}{FortressData}->Init(\@headerList);

    $data = StoreData->new();
    @headerList = (
                "result_no",
                "generate_no",
                "e_no",
                "pysics",
                "electric_shock",
                "cold",
                "flame",
                "saint_devil",
    );

    $self->{Datas}{FortressGuardData}  = $data;
    $self->{Datas}{FortressGuardData}->Init(\@headerList);
    
    #出力ファイル設定
    $self->{Datas}{FortressData}->SetOutputName( "./output/chara/fortress_data_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{FortressGuardData}->SetOutputName( "./output/chara/fortress_guard_data_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,城塞データノード
#-----------------------------------#
sub GetData{
    my $self           = shift;
    my $e_no           = shift;
    my $spec_data_node = shift;
    my $common_datas   = shift;
    
    $self->{ENo} = $e_no;

    $self->GetFortressData($spec_data_node, $common_datas);
    
    return;
}

#-----------------------------------#
#    城塞データ取得
#------------------------------------
#    引数｜城塞データノード
#-----------------------------------#
sub GetFortressData{
    my $self           = shift;
    my $spec_data_node = shift;
    my $common_datas   = shift;

    my ($grand, $caution, $continuance, $enthusiasm, $goodwill, $forecast, $stock, $high_grade, $mob, $drink, $regalia) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

    my $th_nodes = &GetNode::GetNode_Tag("th", \$spec_data_node);

    foreach my $th_node (@$th_nodes){
        if($th_node->as_text eq "壮大値"){
            $grand = $th_node->right->as_text;

        }elsif($th_node->as_text eq "警戒値"){
            $caution = $th_node->right->as_text;

        }elsif($th_node->as_text eq "連続値"){
            $continuance = $th_node->right->as_text;

        }elsif($th_node->as_text eq "熱意値"){
            $enthusiasm = $th_node->right->as_text;

        }elsif($th_node->as_text eq "好感値"){
            $goodwill = $th_node->right->as_text;

        }elsif($th_node->as_text eq "予見値"){
            $forecast = $th_node->right->as_text;

        }elsif($th_node->as_text eq "商品在庫"){
            $stock = $th_node->right->as_text;

        }elsif($th_node->as_text eq "店高級度"){
            $high_grade = $th_node->right->as_text;

        }elsif($th_node->as_text eq "モブ売り"){
            $mob = $th_node->right->as_text;

        }elsif($th_node->as_text eq "送品酔い"){
            my $text = $th_node->right->as_text;
            $drink = ($text && $text ne " ") ? $text : 0;

        }elsif($th_node->as_text eq "レガリア"){
            my $text = $th_node->right->as_text;
            $regalia = ($text && $text ne " ") ? $$common_datas{Regalia}->GetOrAddId($text) : 0;

        }
    }

    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $grand, $caution, $continuance, $enthusiasm, $goodwill, $forecast, $stock, $high_grade, $mob, $drink, $regalia);
    $self->{Datas}{FortressData}->AddData(join(ConstData::SPLIT, @datas));

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
