#===================================================================
#        CatalogData.tsv取得パッケージ
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
package CatalogData;

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
                "market_no",
                "unit_type",
                "orig_name",
                "name",
                "value",
                "attack",
                "biattack",
                "grand",
                "guard_elemental",
                "guard_value",
                "forecast",
                "caution",
                "continuance",
                "enthusiasm",
                "goodwill",
                "charge",
                "tokushu",
                "fuka1",
                "fuka2",
                "strength",
                "e_no",
    );

    $self->{Datas}{Item}  = $item;
    $self->{Datas}{Item}->Init(\@headerList);
    
    #出力ファイル設定
    $self->{Datas}{Item}->SetOutputName( "./output/market/catalog_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
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
    pop(@file_data); # フッタ行削除
    
    foreach my  $data_set(@file_data){
        my $data = [];
        @$data   = split(ConstData::SPLIT, $data_set);
        
        if(scalar(@$data) < 1 || !$$data[0] || !$$data[2]){ next;}

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

    my ($market_no, $unit_type, $orig_name, $name, $value, $attack, $biattack, $grand, $guard_elemental, $guard_value, $forecast, $caution, $continuance, $enthusiasm, $goodwill, $charge, $tokushu, $fuka1, $fuka2, $strength, $e_no)
       = (0,0,0,"",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    
    if ($$data[2] eq "特殊購入") {return;}

    $market_no = $$data[0];
    $unit_type = ($$data[2]) ? $self->{CommonDatas}{UnitType}->GetOrAddId($$data[2]) : 0;
    $orig_name = ($$data[28]) ? $$data[28] : 0;
    $name = $$data[1];
    $value = $$data[7];
    $attack = $$data[3];
    $biattack = $$data[4];
    $grand = $$data[5];
    $guard_elemental = ($$data[11]) ? $self->{CommonDatas}{Elemental}->GetOrAddId($$data[11]) : 0;
    $guard_value = $$data[12];
    $forecast = $$data[15];
    $caution = $$data[8];
    $continuance = $$data[10];
    $enthusiasm = $$data[13];
    $goodwill = $$data[14];
    $charge = $$data[34];
    $tokushu = ($$data[18]) ? $self->{CommonDatas}{AddEffect}->GetOrAddId($$data[18]) : 0;
    $fuka1 = ($$data[30]) ? $self->{CommonDatas}{Fuka}->GetOrAddId($$data[30]) : 0;
    $fuka2 = ($$data[31]) ? $self->{CommonDatas}{Fuka}->GetOrAddId($$data[31]) : 0;
    $strength = $$data[21];
    $e_no = $$data[32];
    
    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $market_no, $unit_type, $orig_name, $name, $value, $attack, $biattack, $grand, $guard_elemental, $guard_value, $forecast, $caution, $continuance, $enthusiasm, $goodwill, $charge, $tokushu, $fuka1, $fuka2, $strength, $e_no);
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
