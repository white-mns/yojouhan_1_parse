#===================================================================
#        精算結果取得パッケージ
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
package Payoff;

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
                "e_no",
                "mob",
                "payoff",
                "attack",
                "support",
                "defense",
                "defeat",
                "special",
                "selling",
                "income",
                "spending",
                "profit",
                "loss",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/payoff_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,名前データノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $e_no = shift;
    my $payoff_node = shift;
    
    $self->{ENo} = $e_no;

    $self->GetPayoffData($payoff_node);
    
    return;
}
#-----------------------------------#
#    名前データ取得
#------------------------------------
#    引数｜名前データノード
#-----------------------------------#
sub GetPayoffData{
    my $self  = shift;
    my $payoff_node  = shift;
    my ($mob, $payoff, $attack, $support, $defense, $destroy, $special, $selling, $income, $spending, $profit, $loss) = (0, 0, 0, 0, 0, 0, 0, 0, 0);

    my @payoff_children = $payoff_node->content_list;

    for (my $i=0;$i < scalar(@payoff_children);$i++){
        my $payoff_child = $payoff_children[$i];

        if($payoff_child =~ /モブ売り/){
            $mob = $payoff_children[$i+1]->as_text;

        }elsif($payoff_child =~ /勇者売上高/){
            $payoff = $payoff_children[$i+1]->as_text;

        }elsif($payoff_child =~ /攻撃戦果補正/){
            my $text = $payoff_children[$i+1]->as_text;
            $text =~ s/(％$|％(MAX)$)//g;
            $attack = $text;

        }elsif($payoff_child =~ /支援戦果補正/){
            my $text = $payoff_children[$i+1]->as_text;
            $text =~ s/(％$|％(MAX)$)//g;
            $support = $text;

        }elsif($payoff_child =~ /防衛戦果補正/){
            my $text = $payoff_children[$i+1]->as_text;
            $text =~ s/(％$|％(MAX)$)//g;
            $defense = $text;

        }elsif($payoff_child =~ /撃破数補正/){
            my $text = $payoff_children[$i+1]->as_text;
            $text =~ s/(％$|％(MAX)$)//g;
            $destroy = $text;

        }elsif($payoff_child =~ /特別補正/){
            my $text = $payoff_children[$i+1]->as_text;
            $text =~ s/(％$|％(MAX)$)//g;
            $special = $text;

        }elsif($payoff_child =~ /販売数補正/){
            my $text = $payoff_children[$i+1]->as_text;
            $text =~ s/(％$|％(MAX)$)//g;
            $selling = $text;

        }elsif($payoff_child =~ /合計現金収入/){
            $income = $payoff_children[$i+1]->as_text;

        }elsif($payoff_child =~ /予算消費/){
            $spending = $payoff_children[$i+1]->as_text;

        }elsif($payoff_child =~ /粗利益/){
            $profit = $payoff_children[$i+1]->as_text;

        }elsif($payoff_child =~ /ロス高/){
            $loss = $payoff_children[$i+1]->as_text;
        }
    }

    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $mob, $payoff, $attack, $support, $defense, $destroy, $special, $selling, $income, $spending, $profit, $loss);
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
