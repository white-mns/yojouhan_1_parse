#!/bin/bash
# for  Analyrze Seven Seas Result

cd `dirname $0`

RESULT_NO=`printf "%03d" $1`
GENERATE_NO=$2

if [ $GENERATE_NO -eq 0 ]; then
    ZIP_NAME=${RESULT_NO}
else
    ZIP_NAME=${RESULT_NO}_$GENERATE_NO
fi

#本家に圧縮結果がアップロードされる定期ゲーはwgetでダウンロードする
#wget -O data/orig/result${RESULT_NO}_$GENERATE_NO.zip http://www.sssloxia.jp/result${RESULT_NO}.zip  

# 元ファイルを変換し圧縮
if [ -f ./data/utf/${ZIP_NAME}.zip ]; then
    
    cd ./data/utf

    echo "unzip orig..."
    unzip -q ./${ZIP_NAME}.zip
    
    cd ../../

fi

perl ./GetData.pl $1 $2
perl ./UploadParent.pl $1 $2

# UTFファイルを圧縮
if [ -d ./data/utf/${ZIP_NAME} ]; then
    
    cd ./data/utf/

    echo "rm utf..."
    rm  -r ${ZIP_NAME}
        
    cd ../../

fi

