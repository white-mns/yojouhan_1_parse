#/usr/bin/perl
#===================================================================
#    データベースへのアップロード
#-------------------------------------------------------------------
#        (C) 2016 @white_mns
#===================================================================

# モジュール呼び出し    ---------------#
require "./source/Upload.pm";
require "./source/lib/time.pm";

# パッケージの使用宣言    ---------------#
use strict;
use warnings;
require LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;

# 変数の初期化    ---------------#
use ConstData_Upload;        #定数呼び出し

my $timeChecker = TimeChecker->new();

# 実行部    ---------------------------#
$timeChecker->CheckTime("start  \t");

&Main;

$timeChecker->CheckTime("end    \t");
$timeChecker->OutputTime();
$timeChecker = undef;




# 宣言部    ---------------------------#

sub Main {
    my $result_no = $ARGV[0];
    my $generate_no = $ARGV[1];
    my $upload = Upload->new();

    if(!defined($result_no) || !defined($generate_no)){
        print "error:empty result_no or generate_no";
        return;
    }

    $upload->DBConnect();
    
    if(ConstData::EXE_DATA){
        if(ConstData::EXE_DATA_UNIT_TYPE)    {
		    $upload->DeleteAll("unit_type_lists");
            $upload->Upload("./output/data/unit_type.csv", 'unit_type_lists');
        }
        if(ConstData::EXE_DATA_UNIT_ORIG_NAME)    {
		    $upload->DeleteAll("unit_orig_name_lists");
            $upload->Upload("./output/data/unit_orig_name.csv", 'unit_orig_name_lists');
        }
        if(ConstData::EXE_DATA_FUKA)    {
		    $upload->DeleteAll("fuka_lists");
            $upload->Upload("./output/data/fuka.csv", 'fuka_lists');
        }
        if(ConstData::EXE_DATA_ELEMENTAL)    {
		    $upload->DeleteAll("elemental_lists");
            $upload->Upload("./output/data/elemental.csv", 'elemental_lists');
        }
        if(ConstData::EXE_DATA_REGALIA)    {
		    $upload->DeleteAll("regalia_lists");
            $upload->Upload("./output/data/regalia.csv", 'regalia_lists');
        }
        if(ConstData::EXE_DATA_CASTLE_CONDITION)    {
		    $upload->DeleteAll("castle_condition_lists");
            $upload->Upload("./output/data/castle_condition.csv", 'castle_condition_lists');
        }
        if(ConstData::EXE_DATA_FRAME_TYPE)    {
		    $upload->DeleteAll("frame_type_lists");
            $upload->Upload("./output/data/frame_type.csv", 'frame_type_lists');
        }
        if(ConstData::EXE_DATA_ADD_EFFECT)    {
		    $upload->DeleteAll("add_effect_lists");
            $upload->Upload("./output/data/add_effect.csv", 'add_effect_lists');
        }
    }
    if(ConstData::EXE_CHARA){
        if(ConstData::EXE_CHARA_NAME)    {
            $upload->DeleteSameResult('names', $result_no, $generate_no);
            $upload->Upload("./output/chara/name_" . $result_no . "_" . $generate_no . ".csv", 'names');
        }
        if(ConstData::EXE_CHARA_ITEM)    {
            $upload->DeleteSameResult('items', $result_no, $generate_no);
            $upload->Upload("./output/chara/item_" . $result_no . "_" . $generate_no . ".csv", 'items');
        }
        if(ConstData::EXE_CHARA_STATUS)    {
            $upload->DeleteSameResult('statuses', $result_no, $generate_no);
            $upload->Upload("./output/chara/status_" . $result_no . "_" . $generate_no . ".csv", 'statuses');
        }
        if(ConstData::EXE_CHARA_FORTRESS_DATA)    {
            $upload->DeleteSameResult('fortress_data', $result_no, $generate_no);
            $upload->Upload("./output/chara/fortress_data_" . $result_no . "_" . $generate_no . ".csv", 'fortress_data');
        }
        if(ConstData::EXE_CHARA_FORTRESS_GUARD)    {
            $upload->DeleteSameResult('fortress_guards', $result_no, $generate_no);
            $upload->Upload("./output/chara/fortress_guard_" . $result_no . "_" . $generate_no . ".csv", 'fortress_guards');
        }
        if(ConstData::EXE_CHARA_CASTLE_CONDITION_TEXT)    {
            $upload->DeleteSameResult('castle_condition_texts', $result_no, $generate_no);
            $upload->Upload("./output/chara/castle_condition_text_" . $result_no . "_" . $generate_no . ".csv", 'castle_condition_texts');
        }
        if(ConstData::EXE_CHARA_CASTLE_STRUCTURE)    {
            $upload->DeleteSameResult('castle_structures', $result_no, $generate_no);
            $upload->Upload("./output/chara/castle_structure_" . $result_no . "_" . $generate_no . ".csv", 'castle_structures');
        }
        if(ConstData::EXE_CHARA_CASTLE_STRUCTURE_MAJOR_TYPE_NUM)    {
            $upload->DeleteSameResult('castle_structure_major_type_nums', $result_no, $generate_no);
            $upload->Upload("./output/chara/castle_structure_major_type_num_" . $result_no . "_" . $generate_no . ".csv", 'castle_structure_major_type_nums');
        }
        if(ConstData::EXE_CHARA_PAYOFF)    {
            $upload->DeleteSameResult('payoffs', $result_no, $generate_no);
            $upload->Upload("./output/chara/payoff_" . $result_no . "_" . $generate_no . ".csv", 'payoffs');
        }
    }
    if(ConstData::EXE_CHARALIST){
        if(ConstData::EXE_CHARALIST_NEXT_BATTLE)    {
            $upload->DeleteSameResult('next_battles', $result_no, $generate_no);
            $upload->Upload("./output/charalist/next_battle_" . $result_no . "_" . $generate_no . ".csv", 'next_battles');
        }
    }
    if(ConstData::EXE_MARKET)    {
        $upload->DeleteSameResult('markets', $result_no, $generate_no);
        $upload->Upload("./output/market/catalog_" . $result_no . "_" . $generate_no . ".csv", 'markets');
    }
    if(ConstData::EXE_NEW){
        if(ConstData::EXE_NEW_FUKA)    {
            $upload->DeleteSameResult('new_fukas', $result_no, $generate_no);
            $upload->Upload("./output/new/fuka_" . $result_no . ".csv", 'new_fukas');
        }
    }
    print "result_no:$result_no,generate_no:$generate_no\n";
    return;
}

#-----------------------------------#
#
#    更新回の指定
#
#-----------------------------------#
sub ResultNum{
    my $num = $ARGV[0];
    
    unless(defined($num)){
        
        while(1){
            print "input result number...\n";
            
            chomp(my $in = <STDIN> );
            
            if($in =~ /^[0-9]+$/){
            }else{
                print "error : input unexpected data\n";
                die;
            }
            $in+=0;
            
            if($in >= 0){
                $num = $in;
                return $num;
            }
        }
    }
    return $num;
}
