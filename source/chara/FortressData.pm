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
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;
    
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
   
    $data = StoreData->new();
    @headerList = (
                "result_no",
                "generate_no",
                "e_no",
                "condition_text",
    );

    $self->{Datas}{CastleConditionTextData}  = $data;
    $self->{Datas}{CastleConditionTextData}->Init(\@headerList);



    #出力ファイル設定
    $self->{Datas}{FortressData}->SetOutputName( "./output/chara/fortress_data_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{FortressGuardData}->SetOutputName( "./output/chara/fortress_guard_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{CastleConditionTextData}->SetOutputName( "./output/chara/castle_condition_text_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
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
    
    $self->{ENo} = $e_no;

    $self->GetFortressData($spec_data_node);
    $self->GetFortressGuardData($spec_data_node);
    $self->GetCastleConditionData($spec_data_node);
    
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
            my @children = $th_node->right->content_list();
            my $text = $children[0];
            $regalia = ($text && $text ne " ") ? $self->{CommonDatas}{Regalia}->GetOrAddId($text) : 0;

        }
    }

    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $grand, $caution, $continuance, $enthusiasm, $goodwill, $forecast, $stock, $high_grade, $mob, $drink, $regalia);
    $self->{Datas}{FortressData}->AddData(join(ConstData::SPLIT, @datas));

    return;
}

#-----------------------------------#
#    属性防御データ取得
#------------------------------------
#    引数｜城塞データノード
#-----------------------------------#
sub GetFortressGuardData{
    my $self           = shift;
    my $spec_data_node = shift;

    my ($pysics, $electric_shock, $cold, $flame, $saint_devil) = (0, 0, 0, 0, 0);

    my $th_nodes = &GetNode::GetNode_Tag("th", \$spec_data_node);

    foreach my $th_node (@$th_nodes){
        if($th_node->as_text eq "物理防御"){
            my $text = $th_node->right->as_text;
            $pysics = ($text && $text ne " ") ? $text : 0;

        }elsif($th_node->as_text eq "電撃防御"){
            my $text = $th_node->right->as_text;
            $electric_shock = ($text && $text ne " ") ? $text : 0;

        }elsif($th_node->as_text eq "冷気防御"){
            my $text = $th_node->right->as_text;
            $cold = ($text && $text ne " ") ? $text : 0;

        }elsif($th_node->as_text eq "火炎防御"){
            my $text = $th_node->right->as_text;
            $flame = ($text && $text ne " ") ? $text : 0;

        }elsif($th_node->as_text eq "聖魔防御"){
            my $text = $th_node->right->as_text;
            $saint_devil = ($text && $text ne " ") ? $text : 0;

        }
    }

    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $pysics, $electric_shock, $cold, $flame, $saint_devil);
    $self->{Datas}{FortressGuardData}->AddData(join(ConstData::SPLIT, @datas));

    return;
}

#-----------------------------------#
#    城状況データ取得
#------------------------------------
#    引数｜城塞データノード
#-----------------------------------#
sub GetCastleConditionData{
    my $self           = shift;
    my $spec_data_node = shift;

    my ($condition, $condition_text) = (0, "");

    my $th_nodes = &GetNode::GetNode_Tag("th", \$spec_data_node);

    foreach my $th_node (@$th_nodes){
        if($th_node->as_text eq "城状況"){
            foreach my $child ($th_node->right->content_list){
                my $text = ($child =~ /HASH/) ? $child->as_text : $child;
                
                if(!($text && $text ne " ")){ next;}
                if($text =~ /付加発動/)     { last;}
                $self->{CommonDatas}{CastleCondition}->GetOrAddId($text);
                $condition_text .= ($text && $text ne " ") ? "$text," : "";
            }

        }
    }
    chop($condition_text);
    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $condition_text);
    $self->{Datas}{CastleConditionTextData}->AddData(join(ConstData::SPLIT, @datas));

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
