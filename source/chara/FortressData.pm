#===================================================================
#        城塞データ取得パッケージ(まだ実装してません)
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
                "name",
                "nickname",
    );

    $self->{Datas}{FortressData}  = $data;
    $self->{Datas}{FortressData}->Init(\@headerList);
    
    #出力ファイル設定
    $self->{Datas}{FortressData}->SetOutputName( "./output/chara/fortress_data_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,城塞データノード
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
#    城塞データ取得
#------------------------------------
#    引数｜城塞データノード
#-----------------------------------#
sub GetNameData{
    my $self  = shift;
    my $minieffect_nodes  = shift;

    my $name = $$minieffect_nodes[0]->right->as_text;

    my $nickname = $$minieffect_nodes[1]->right;
    $nickname =~ s/^　//;
    $nickname =~ s/\s$//;

    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $name, $nickname);
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
