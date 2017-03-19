#!/bin/bash


file_type_list="cpp h"
file_path="."

#-f:文件名或者目录名  -t: 文件类型
#如果不传入参数，默认目录为当前目录，默认转换文件类型为.h .cpp
#example:covert_to_utf8 -f . -t "cpp h"
while getopts "t:f:" arg #选项后面的冒号表示该选项需要参数
do
    case $arg in
        f)
            echo "f's arg:$OPTARG"
            file_path=$OPTARG
            ;;
        t)
            echo "t's arg:$OPTARG" 
            file_type_list=$OPTARG
            ;;
        ?)
            echo "unkonw argument"
            exit 1
            ;;
    esac
done

echo "file_type=" $file_type_list "file_path=" $file_path 


#如果是普通文件或者目录才进行查找、转换，其他情况，不转换
if [  -f $file_path  -o  -d $file_path  ];
then
    echo "Begin to Convert $file_path from GBK to UTF-8...."
else
    echo " $file isn't a file or directory,can't convert! "
    exit;
fi


#找到普通文件，然后转换这些文件
all_file=`find $file_path -type f`;

for file in $all_file;
do
    file_type=${file##*.} 
    #echo $file $file_type;
    if [[ "$file_type_list" != *"$file_type"* ]];
    then
        echo "$file_type not in $file_type_list"
        continue;
    fi
    
    file_encoding=`file $file | cut -d " " f1`
    #GBK
    if [ $file_encoding == "ISO-8859" ];
    then
        original_encoding="gbk"
    #ASCII or UTF-8
    elif [ $file_encoding == "ASCII" -o $file_encoding == "UTF-8" ];
    then
        echo "$file encoding $file_encoding is ok, not need convert"
        continue;
    #未定义的编码
    else
        echo "$file error encoding $file_encoding, can't convert"
        continue;
    fi
    iconv -f $original_encoding -t utf-8 $file > $file"_tmp"
    #判断是否转换成功
    if [ $? != 0 ];
    then
        echo "covert $file failed!"
        continue;
    fi
    mv $file"_tmp" $file
    echo "convrt $file success!"
done

echo "All file convert done!"
