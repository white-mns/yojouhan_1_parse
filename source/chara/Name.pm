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
package Name;

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
                "name",
                "nickname",
    );

    $self->{Datas}{Data}  = $data;
    $self->{Datas}{Data}->Init(\@headerList);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/name_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,名前データノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $e_no  = shift;
    my $minieffect_nodes = shift;
    
    $self->{ENo} = $e_no;

    $self->GetNameData($minieffect_nodes);
    
    return;
}
#-----------------------------------#
#    名前データ取得
#------------------------------------
#    引数｜名前データノード
#-----------------------------------#
sub GetNameData{
    my $self  = shift;
    my $minieffect_nodes  = shift;

    my $name = $$minieffect_nodes[0]->right->as_text;

    my $nickname = $$minieffect_nodes[1]->right;
    $nickname =~ s/^　//;
    $nickname =~ s/\s$//;

    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $name, $nickname);
    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, @datas));

    # 戦闘ページでの眼鏡ｸｲｯ発言者判定用に、共通変数へ愛称とEnoの対応を記録
    $self->{CommonDatas}{NickName}{$nickname} = $self->{ENo};

    return;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    
    # 眼鏡ｸｲｯ一覧のためにNPC、判別不能時の名前データを追加する
    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, 10000, "判別不能", "判別不能")));
    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, 10001, "レヒル主任", "レヒル主任")));

    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
