#===================================================================
#        お城構成取得パッケージ
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
package CastleStructure;

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
                "frame_type",
                "i_no",
    );

    $self->{Datas}{CastleStructure}  = $data;
    $self->{Datas}{CastleStructure}->Init(\@headerList);
    
    #出力ファイル設定
    $self->{Datas}{CastleStructure}->SetOutputName( "./output/chara/castle_structure_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,お城構成ノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $e_no = shift;
    my $machine_data_node  = shift;
    my $item_caption_node = shift;
    
    $self->{ENo} = $e_no;
    $self->{IgnoreIno} = {};

    $self->GetCastleStructureData($machine_data_node, $item_caption_node);
    
    return;
}
#-----------------------------------#
#    お城構成データ取得
#------------------------------------
#    引数｜お城構成ノード
#          デフォルトリスト題名ノード
#-----------------------------------#
sub GetCastleStructureData{
    my $self = shift;
    my $machine_data_node  = shift;
    my $item_caption_node = shift;

    my $tr_nodes = &GetNode::GetNode_Tag("tr", \$machine_data_node);
    foreach my $tr_node (@$tr_nodes){
        my ($frame_type, $i_no) = (0, 0, 0);
        
        my $th_nodes = &GetNode::GetNode_Tag("th", \$tr_node);
        my $td_nodes = &GetNode::GetNode_Tag("td", \$tr_node);
        my $th_text  = $$th_nodes[1]->as_text;
        my $td_text  = $$td_nodes[0]->as_text;
        
        $td_text =~ /(.+)【(.+)】/;
        my $item_name = $1;
        my $frame_type_text = $2;

        my $unit_type  = ($th_text) ? $self->{CommonDatas}{UnitType}->GetOrAddId($th_text) : 0;
        $frame_type = ($frame_type_text) ? $self->{CommonDatas}{FrameType}->GetOrAddId($frame_type_text) : 0;
        $i_no = $self->GuessItemNo($unit_type, $item_name, $item_caption_node);

        my @datas=($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $frame_type, $i_no);
        $self->{Datas}{CastleStructure}->AddData(join(ConstData::SPLIT, @datas));
    }

    return;
}

#-----------------------------------#
#    名前と種別からアイテムNoを推測して取得
#------------------------------------
#    引数｜デフォルトリスト題名ノード
#-----------------------------------#
sub GuessItemNo{
    my $self          = shift;
    my $src_unit_type = shift;
    my $src_item_name = shift;
    my $item_caption_node = shift;


    my $tr_nodes = &GetNode::GetNode_Tag("tr", \$item_caption_node->parent->right);
    foreach my $tr_node (@$tr_nodes){
        my $th_nodes = &GetNode::GetNode_Tag("th", \$tr_node);
        my $td_nodes = &GetNode::GetNode_Tag("td", \$tr_node);
        my $i_no     = $$th_nodes[0]->as_text;

        if(exists($self->{IgnoreIno}{$i_no})) {next;} # 既にお城構成に判定したアイテムNoは除外

        my $td0_text = $$td_nodes[0]->as_text;
        if($td0_text eq "---" || $td0_text =~ /素材/){next;}
        if($td0_text !~ /(.+):.+/){next;}
        my $dst_unit_type = $self->{CommonDatas}{UnitType}->GetOrAddId($1);
        
        my @td1_children = $$td_nodes[1]->content_list;
        my $dst_item_name = $td1_children[0];
        $dst_item_name =~ s/ \[$//;
        
        if($src_unit_type == $dst_unit_type && $src_item_name eq $dst_item_name){
            $self->{IgnoreIno}{$i_no} = 1;
            return $i_no;
        }
    }
    return -1;
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
