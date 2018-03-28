#===================================================================
#        戦闘ページ解析パッケージ
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

require "./source/battle/MultipleBuying.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package Battle;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;

  bless {
    Datas         => {},
    DataHandlers  => {},
    Methods       => {},
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
    if(ConstData::EXE_BATTLE_MULTIPLE_BUYING) { $self->{DataHandlers}{MultipleBuying} = MultipleBuying->new();}

    #初期化処理
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Init($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas});
    }
    
    return;
}

#-----------------------------------#
#    圧縮結果から詳細データファイルを抽出
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self        = shift;

    print "read battle files...\n";

    my $start = 1;
    my $end   = 0;
    my $directory = './data/utf/' . $self->{ResultNo0};
    $directory .= ($self->{GenerateNo} == 0) ? '' :  '_' . $self->{GenerateNo};
    $directory .= '/RESULT';
    if(ConstData::EXE_ALLRESULT){
        #結果全解析
        my @file_list = grep { -f } glob("$directory/battle*.html");
        my $i = 0;
        foreach my $file_adr (@file_list){
            $i++;
            if($i % 10 == 0){print $i . "\n"};

            $file_adr =~ /battle(.*?)\.html/;
            my $file_name = $1;
            my $battle_no = $file_name+0;
            
            $self->ParsePage($directory  . "/battle" . $file_name . ".html", $battle_no);
        }
    }else{
        #指定範囲解析
        $start = ConstData::FLAGMENT_START;
        $end   = ConstData::FLAGMENT_END;
        print "$start to $end\n";

        for(my $i=$start; $i<=$end; $i++){
            if($i % 10 == 0){print $i . "\n"};
            my $i0 = sprintf("%d", $i);
            $self->ParsePage($directory  . "/battle" . $i0 . ".html",$i);
        }
    }

    
    return ;
}
#-----------------------------------#
#       ファイルを解析
#-----------------------------------#
#    引数｜ファイル名
#    　　　ENo
#    　　　FNo
##-----------------------------------#
sub ParsePage{
    my $self        = shift;
    my $file_name   = shift;
    my $battle_no   = shift;

    #結果の読み込み
    my $content = "";
    $content = &IO::FileRead($file_name);

    if(!$content){ return;}

    $content = &NumCode::EncodeEscape($content);
        
    #スクレイピング準備
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);

    my $messe_waku_table_nodes = &GetNode::GetNode_Tag_Class("table","messe_waku", \$tree);
    my $shop_size_div_nodes    = &GetNode::GetNode_Tag_Class("div","shop_size", \$tree);
    my $messe_span_nodes       = &GetNode::GetNode_Tag_Class("span","messe", \$tree);

    # データリスト取得
    if(exists($self->{DataHandlers}{MultipleBuying}))  {$self->{DataHandlers}{MultipleBuying}->GetData($battle_no, $shop_size_div_nodes)};
    if(exists($self->{CommonDatas}{Megane}))           {$self->{CommonDatas}{Megane}->GetBattleMessageData($self->{CommonDatas}{PageType}{battle}, $battle_no, $messe_waku_table_nodes,$messe_span_nodes)};

    $tree = $tree->delete;
}

#-----------------------------------#
#       該当ファイル数を取得
#-----------------------------------#
#    引数｜ディレクトリ名
#    　　　ファイル接頭辞
##-----------------------------------#
sub GetFileNo{
    my $directory   = shift;
    my $prefix    = shift;

    #ファイル名リストを取得
    my @fileList = grep { -f } glob("$directory/$prefix*.html");

    my $max= 0;
    foreach(@fileList){
        $_ =~ /$prefix(\d+).html/;
        if($max < $1) {$max = $1;}
    }
    return $max
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
