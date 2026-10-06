#!/bin/sh

jffs2_cfg_path="/netis"

# 获取目录部分
dir="${1%/*}"
# 获取文件名部分
file="${1##*/}"

if [ "$dir" = "$file" ]; then
	dir="."
fi

cd $jffs2_cfg_path
if [ "$dir" != "" ] && [ ! -d "$dir" ]; then
	mkdir -p $dir
fi
cp /var/$dir/$file $dir/$file.tmp
rm $dir/$file -f
mv $dir/$file.tmp $dir/$file
