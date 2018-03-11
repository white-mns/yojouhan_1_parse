#===================================================================
#        多重購入回数取得パッケージ
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
package MultipleBuying;

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
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;

    $self->{CommonDatas}{NickName} = {};
    
    #初期化
    my $data = StoreData->new();
    my @headerList = (
                "result_no",
                "generate_no",
                "e_no",
                "battle_no",
                "multiple_buying",
                "buy_type",
                "buy_num",
    );

    $self->{Datas}{Data}  = $data;
    $self->{Datas}{Data}->Init(\@headerList);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/battle/multiple_buying_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,名前データノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $battle_no  = shift;
    my $shop_size_div_nodes = shift;
    
    $self->{BattleNo} = $battle_no;

    $self->GetMultipleBuyingData($shop_size_div_nodes);
    
    return;
}
#-----------------------------------#
#    多重購入データ取得
#------------------------------------
#    引数｜名前データノード
#-----------------------------------#
sub GetMultipleBuyingData{
    my $self  = shift;
    my $shop_size_div_nodes  = shift;

    foreach my $shop_size_div_node (@$shop_size_div_nodes){
        my $e_no = 0;
        my $multiple_buying = -1;
        my @shop_size_children = $shop_size_div_node->content_list();

        foreach my $shop_size_child (@shop_size_children){
            # Enoデータの取得
            if($shop_size_child =~ /HASH/ && $shop_size_child->tag eq "span") { 
                my $span_title = $shop_size_child->attr("title");
                if( $span_title && $span_title =~ /Eno(\d+)-/) {$e_no = $1};
            }

            # 多重購入判定数の取得
            if($shop_size_child =~ /\[多重購入\+(\d+)\]/) {
                $multiple_buying = $1;
            }

            # 販売数の取得
            if($shop_size_child =~ /を(\d+)個販売/) {
                my $buy_num = $1;
                my $buy_type = $self->{CommonDatas}{BuyType}->GetOrAddId("商品");
    
                if($e_no > 0 && $multiple_buying >= 0){
                    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $e_no, $self->{BattleNo}, $multiple_buying, $buy_type, $buy_num);
                    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, @datas));
                }
                last;
            }
    
            # サービス回数の取得
            if($shop_size_child =~ /に(\d+)回/) {
                my $buy_num = $1;
                my $buy_type = $self->{CommonDatas}{BuyType}->GetOrAddId("サービス");
    
                if($e_no > 0 && $multiple_buying >= 0){
                    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $e_no, $self->{BattleNo}, $multiple_buying, $buy_type, $buy_num);
                    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, @datas));
                }
                last;
            }
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
