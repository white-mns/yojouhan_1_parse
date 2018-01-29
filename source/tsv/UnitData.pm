#===================================================================
#        UnitData.tsv取得パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package UnitData;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  my %datas = ();
  
  bless {
        Datas        => \%datas,
        Output       => "",
        ResultNo    => "",
        GenerateNo  => "",
        ENo          => "",

  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;
    
    #初期化
    my $item = StoreData->new();
    my @headerList = (
                "result_no",
                "generate_no",
                "e_no",
                "i_no",
                "unit_type",
                "orig_name",
                "name",
                "strength",
                "fuka1",
                "fuka2",
                "guard_elemental",
                "stock",
                "value",
    );

    $self->{Datas}{Item}  = $item;
    $self->{Datas}{Item}->Init(\@headerList);
    
    #出力ファイル設定
    $self->{Datas}{Item}->SetOutputName( "./output/chara/item_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜ファイル名
#          コモンデータアドレス記録ハッシュ
#-----------------------------------#
sub GetData{
    my $self         = shift;
    my $file_name    = shift;
    
    my $content   = &IO::FileRead ( $file_name );
    my @file_data = split(/\n/, $content);
    shift(@file_data); # ヘッダ行削除
    
    foreach my  $data_set(@file_data){
        my $data = [];
        @$data   = split(ConstData::SPLIT, $data_set);
        
        if(scalar(@$data) < 1 || !$$data[0] || !$$data[2]){ next;}
        
        $self->{CommonDatas}{UnitType}->GetOrAddId($$data[2]);
        if($$data[28]){ $self->{CommonDatas}{UnitOrigName}->SetId($$data[28], $$data[36]);}

        $self->GetUnitData($data);
    } 
    
    return;
}

#-----------------------------------#
#    アイテムデータ取得
#------------------------------------
#    引数｜tsvデータ一行を分割した配列
#          コモンデータアドレス記録ハッシュ
#-----------------------------------#
sub GetUnitData{
    my $self         = shift;
    my $data         = shift;

    my $e_no = int($$data[0] / 31);
    my $i_no = $$data[0] % 31;
    
    my $type = ($$data[2]) ? $self->{CommonDatas}{UnitType}->GetOrAddId($$data[2]) : 0;
    my $orig_name = ($$data[28]) ? $$data[28] : 0;
    my $name = $$data[1];
    my $strength = $$data[21];
    my $fuka1 = ($$data[30]) ? $self->{CommonDatas}{Fuka}->GetOrAddId($$data[30]) : 0;
    my $fuka2 = ($$data[31]) ? $self->{CommonDatas}{Fuka}->GetOrAddId($$data[31]) : 0;
    my $guard_elemental = ($$data[11]) ? $self->{CommonDatas}{Elemental}->GetOrAddId($$data[11]) : 0;
    my $stock = ($$data[16]) ? $$data[16] : 0;
    my $value = ($$data[7]) ? $$data[7] : 0;
    
    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $e_no, $i_no, $type, $orig_name, $name, $strength, $fuka1, $fuka2, $guard_elemental, $stock, $value);
    $self->{Datas}{Item}->AddData(join(ConstData::SPLIT, @datas));
    
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
