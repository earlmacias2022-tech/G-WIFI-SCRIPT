#!/bin/sh

jffs2_cfg_path="/netis"

# 获取目录部分
dir="${1%/*}"
# 获取文件名部分
file="${1##*/}"

cd $jffs2_cfg_path
if [ -d "$dir" ];then
	cd $dir
fi

# tmp文件存在，表示之前保存未完成,重新使用tmp文件覆盖当前文件
if [ -f $file.tmp ];then
	rm $file
	mv $file.tmp $file
fi

cp $file /var/$dir