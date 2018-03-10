#===================================================================
#        固有名詞管理パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use ConstData;
use HTML::TreeBuilder;
use source::lib::GetNode;

require "./source/lib/IO.pm";
require "./source/lib/time.pm";
require "./source/lib/NumCode.pm";

require "./source/data/StoreProperName.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package ProperName;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class        = shift;
  my %datas        = ();
  my %dataHandlers = ();
  my %methods      = ();

  bless {
    Datas         => \%datas,
    DataHandlers  => \%dataHandlers,
    Methods       => \%methods,
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;
    $self->{ResultNo0} = sprintf("%03d", $self->{ResultNo});

    #インスタンス作成
    if(ConstData::EXE_TSV_UNITDATA)  {$self->{DataHandlers}{UnitData} = UnitData->new();}
    $self->{DataHandlers}{UnitType}        = StoreProperName->new();
    $self->{DataHandlers}{UnitOrigName}    = StoreProperName->new();
    $self->{DataHandlers}{Fuka}            = StoreProperName->new();
    $self->{DataHandlers}{Elemental}       = StoreProperName->new();
    $self->{DataHandlers}{Regalia}         = StoreProperName->new();
    $self->{DataHandlers}{CastleCondition} = StoreProperName->new();
    $self->{DataHandlers}{FrameType}       = StoreProperName->new();
    $self->{DataHandlers}{AddEffect}       = StoreProperName->new();
    $self->{DataHandlers}{MeganeType}      = StoreProperName->new();

    #他パッケージへの引き渡し用インスタンス
    $self->{CommonDatas}{UnitType}        = $self->{DataHandlers}{UnitType};
    $self->{CommonDatas}{UnitOrigName}    = $self->{DataHandlers}{UnitOrigName};
    $self->{CommonDatas}{Fuka}            = $self->{DataHandlers}{Fuka};
    $self->{CommonDatas}{Elemental}       = $self->{DataHandlers}{Elemental};
    $self->{CommonDatas}{Regalia}         = $self->{DataHandlers}{Regalia};
    $self->{CommonDatas}{CastleCondition} = $self->{DataHandlers}{CastleCondition};
    $self->{CommonDatas}{FrameType}       = $self->{DataHandlers}{FrameType};
    $self->{CommonDatas}{AddEffect}       = $self->{DataHandlers}{AddEffect};
    $self->{CommonDatas}{MeganeType}      = $self->{DataHandlers}{MeganeType};

    my $header_list = "";
    my $output_file = "";

    $header_list = [
                "type_id",
                "name",
    ];
    $output_file = "./output/data/". "unit_type" . ".csv";
    $self->{DataHandlers}{UnitType}->Init($header_list, $output_file," ");

    $header_list = [
                "orig_name_id",
                "name",
    ];
    $output_file = "./output/data/". "unit_orig_name" . ".csv";
    $self->{DataHandlers}{UnitOrigName}->Init($header_list, $output_file, "素材");

    $header_list = [
                "fuka_id",
                "name",
    ];
    $output_file = "./output/data/". "fuka" . ".csv";
    $self->{DataHandlers}{Fuka}->Init($header_list, $output_file, " ");

    $header_list = [
                "elemental_id",
                "name",
    ];
    $output_file = "./output/data/". "elemental" . ".csv";
    $self->{DataHandlers}{Elemental}->Init($header_list, $output_file, " ");

    $header_list = [
                "regalia_id",
                "name",
    ];
    $output_file = "./output/data/". "regalia" . ".csv";
    $self->{DataHandlers}{Regalia}->Init($header_list, $output_file, " ");

    $header_list = [
                "castle_condition_id",
                "name",
    ];
    $output_file = "./output/data/". "castle_condition" . ".csv";
    $self->{DataHandlers}{CastleCondition}->Init($header_list, $output_file, " ");

    $header_list = [
                "frame_type_id",
                "name",
    ];
    $output_file = "./output/data/". "frame_type" . ".csv";
    $self->{DataHandlers}{FrameType}->Init($header_list, $output_file, " ");

    $header_list = [
                "add_effect_id",
                "name",
    ];
    $output_file = "./output/data/". "add_effect" . ".csv";
    $self->{DataHandlers}{AddEffect}->Init($header_list, $output_file, " ");

    $header_list = [
                "megane_type_id",
                "name",
    ];
    $output_file = "./output/data/". "megane_type" . ".csv";
    $self->{DataHandlers}{MeganeType}->Init($header_list, $output_file, " ");
    
    return;
}

#-----------------------------------#
#   このパッケージでデータ解析はしない
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self        = shift;
    return ;
}

#-----------------------------------#
#    出力
#-----------------------------------#
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Output();
    }
    return;
}

1;
