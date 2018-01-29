#===================================================================
#        キャラリスト解析パッケージ
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

require "./source/charalist/NextBattle.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package CharacterList;

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
    if(ConstData::EXE_CHARALIST_NEXT_BATTLE) { $self->{DataHandlers}{NextBattle} = NextBattle->new();}

    #初期化処理
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Init($self->{ResultNo},$self->{GenerateNo}, $self->{CommonDatas});
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

    print "read files...\n";

    my $directory = './data/utf/' . $self->{ResultNo0};
    $directory .= ($self->{GenerateNo} == 0) ? '' :  '_' . $self->{GenerateNo};
                
    $self->ParsePage($directory  . "/list.html");
    
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

    #結果の読み込み
    my $content = "";
    $content = &IO::FileRead($file_name);

    if(!$content){ return;}

    $content = &NumCode::EncodeEscape($content);
        
    #スクレイピング準備
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);

    my $hr_nodes     = &GetNode::GetNode_Tag("h2", \$tree);

    # データリスト取得
    if(exists($self->{DataHandlers}{NextBattle})) {$self->{DataHandlers}{NextBattle}->GetData($hr_nodes)};

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
