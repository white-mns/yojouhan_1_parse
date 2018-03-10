#===================================================================
#        眼鏡ｸｲｯ管理パッケージ
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
package Megane;

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
    $self->{needsCountRehiru_character}  = 1;
    $self->{TotalMeganeData} = {};
    $self->{AccMeganeData}   = {};

    #インスタンス作成
    $self->{Datas}{Megane}      = StoreData->new();
    $self->{Datas}{TotalMegane} = StoreData->new();
    $self->{Datas}{AccMegane}   = StoreData->new();

    #他パッケージへの引き渡し用インスタンス
    $self->{CommonDatas}{Megane}        = $self;
    $self->{CommonDatas}{PageType}      = {
                                            "chara" => 1,
                                            "battle" => 2,
                                            "list" => 3,
                                            "catalog" => 4,
                                        };

    my $header_list = "";
    my $output_file = "";

    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "page_type",
                "page_no",
                "megane_type_id",
                "megane_count",
    ];

    $self->{Datas}{Megane}->Init($header_list);
    $self->{Datas}{Megane}->SetOutputName( "./output/megane/megane_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "megane_type_id",
                "megane_count",
    ];

    $self->{Datas}{TotalMegane}->Init($header_list);
    $self->{Datas}{TotalMegane}->SetOutputName( "./output/megane/total_megane_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    
    $self->{Datas}{AccMegane}->Init($header_list);
    $self->{Datas}{AccMegane}->SetOutputName( "./output/megane/acc_megane_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );

    $self->ReadLastData();

    return;
}

#-----------------------------------#
#    既存累積データを読み込む
#-----------------------------------#
sub ReadLastData(){
    my $self      = shift;

    my $file_name = "";
    # 前回結果の確定版ファイルを探索
    for (my $i=5; $i>=0; $i--){
        $file_name = "./output/megane/acc_megane_" . ($self->{ResultNo} - 1) . "_" . $i . ".csv" ;
        if(-f $file_name) {last;}
    }
    
    my $content = &IO::FileRead ( $file_name );
    
    my @file_data = split(/\n/, $content);
    shift (@file_data);
    
    foreach my  $data_set(@file_data){
        my $data = []; 
        @$data   = split(ConstData::SPLIT, $data_set);
        
        $self->{AccMeganeData}{$$data[2]}{$$data[3]} = $$data[4];
    }

    return;
}

#-----------------------------------#
#   共通処理用の空関数
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self        = shift;
    return ;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,名前データノード
#-----------------------------------#
sub GetMessageData{
    my $self = shift;
    my $page_type  = shift;
    my $page_no  = shift;
    my $link_nodes = shift;
    
    $self->{MeganeData} = {};

    foreach my $link_node (@$link_nodes){
        my $link_text = $link_node->as_text;
        if ($link_text !~ /ENo\.(\d+)からのメッセージ/) {next;}
        my $e_no = $1;

        my @right_contents = $link_node->right;

        foreach my $right_content (@right_contents) {
            if($right_content !~ /HASH/) {next;}
            if($right_content->tag eq "a") {last;}
            if($right_content->tag eq "table") {
                $self->GetMesseWakuData($e_no, $right_content);
            }
            if($right_content->tag eq "span") {
                $self->GetMesseSpanData($e_no, $right_content);
            
            }
        }
    }
    
    foreach my $e_no( keys %{ $self->{MeganeData} } ) {
        foreach my $megane_type_id( keys %{ $self->{MeganeData}{$e_no} } ) {
            my @datas=($self->{ResultNo}, $self->{GenerateNo}, $e_no, $page_type, $page_no, $megane_type_id, $self->{MeganeData}{$e_no}{$megane_type_id});
            $self->{Datas}{Megane}->AddData(join(ConstData::SPLIT, @datas));
        }
    }

    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜メッセ枠データノード
#-----------------------------------#
sub GetRehiruData{
    my $self = shift;
    my $messe_waku_table_nodes = shift;
    
    if (!$self->{needsCountRehiru_character}) {return;} #二人目以降のPCページではレヒル主任のｸｲｯは判定しない

    my $isExistRehiru = 0;
    $self->{MeganeData} = {};
    foreach my $messe_waku_table_node (@$messe_waku_table_nodes){

        if($self->isSpeakerRehiru($messe_waku_table_node)){
            $self->GetMesseWakuData(10001, $messe_waku_table_node);
            $self->{needsCountRehiru_character} = 0; #二人目以降のPCページではレヒル主任のｸｲｯは判定しない
        }else{
            $self->GetMesseWakuData(10000, $messe_waku_table_node);
        }
    }
        
    
    return;
}
#-----------------------------------#
#    離しているのがレヒル主任かどうか取得
#------------------------------------
#    引数｜名前データノード
#-----------------------------------#
sub isSpeakerRehiru{
    my $self  = shift;
    my $messe_waku_table_node  = shift;

    my $td_nodes   = &GetNode::GetNode_Tag("td", \$messe_waku_table_node);
    my @td_children = $$td_nodes[0]->content_list();
    my $speaker = shift(@td_children);
    
    return ($speaker =~ /レヒル/) ? 1 : 0;
}

#-----------------------------------#
#    眼鏡データ取得
#------------------------------------
#    引数｜ENo、メッセージテーブルノード
#-----------------------------------#
sub GetMesseWakuData{
    my $self      = shift;
    my $e_no      = shift;
    my $messe_waku_table_node  = shift;

    my $td_nodes   = &GetNode::GetNode_Tag("td", \$messe_waku_table_node);
    my @td_children = $$td_nodes[0]->content_list();
    my $speaker = shift(@td_children);
    
    foreach my $text (@td_children){
        my $megane_list = [];

        # 事前に半角括弧を全角に変換しておく
        #   ※正規表現の[（\(]では、何故かｸｲｯとﾊﾟﾘｰﾝが途中で切れてヒットするため
        $text =~ s/\(/（/g;
        $text =~ s/\)/）/g;

        @$megane_list = $text =~ /（(.*?眼鏡.*?)）/g;
        foreach my $megane_text (@$megane_list){
            my $megane_id = $self->{CommonDatas}{MeganeType}->GetOrAddId($megane_text);
            $self->{MeganeData}{$e_no}{$megane_id} += 1;
            $self->{TotalMeganeData}{$e_no}{$megane_id} += 1;
            $self->{AccMeganeData}{$e_no}{$megane_id} += 1;
        }   
    }

    return;
}
#-----------------------------------#
#    眼鏡データ取得
#------------------------------------
#    引数｜ENo、メッセージspanノード
#-----------------------------------#
sub GetMesseSpanData{
    my $self      = shift;
    my $e_no      = shift;
    my $messe_span_node  = shift;
    my @span_children = $messe_span_node->content_list();

    foreach my $text (@span_children){
        my $megane_list = [];

        # 事前に半角括弧を全角に変換しておく
        #   ※正規表現の[（\(]では、何故かｸｲｯとﾊﾟﾘｰﾝが途中で切れてヒットするため
        $text =~ s/\(/（/g;
        $text =~ s/\)/）/g;

        @$megane_list = $text =~ /（(.*?眼鏡.*?)）/g;
        foreach my $megane_text (@$megane_list){
            my $megane_id = $self->{CommonDatas}{MeganeType}->GetOrAddId($megane_text);
            $self->{MeganeData}{$e_no}{$megane_id} += 1;
            $self->{TotalMeganeData}{$e_no}{$megane_id} += 1;
            $self->{AccMeganeData}{$e_no}{$megane_id} += 1;
            
        }   
    }

    return;
}

sub OutputTotalMeganeData(){
    my $self = shift;

    foreach my $e_no( keys %{ $self->{TotalMeganeData} } ) {
        foreach my $megane_type( keys %{ $self->{TotalMeganeData}{$e_no} } ) {
            my @add_data = ($self->{ResultNo}, $self->{GenerateNo}, $e_no, $megane_type, $self->{TotalMeganeData}{$e_no}{$megane_type});
            $self->{Datas}{TotalMegane}->AddData(join(ConstData::SPLIT, @add_data));
        }
    }
}

sub OutputAccMeganeData(){
    my $self = shift;

    foreach my $e_no( keys %{ $self->{AccMeganeData} } ) {
        foreach my $megane_type( keys %{ $self->{AccMeganeData}{$e_no} } ) {
            my @add_data = ($self->{ResultNo}, $self->{GenerateNo}, $e_no, $megane_type, $self->{AccMeganeData}{$e_no}{$megane_type});
            $self->{Datas}{AccMegane}->AddData(join(ConstData::SPLIT, @add_data));
        }
    }
}

#-----------------------------------#
#    出力
#-----------------------------------#
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;

    $self->OutputTotalMeganeData();
    $self->OutputAccMeganeData();

    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}

1;
