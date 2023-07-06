#!/bin/bash

#项目名称
objectName="Safe\ Wickers"
#获取Pods-${objectName}/
cd "${PWD}/Pods"
pwd
cd "Target Support Files/"
pwd
cd "Pods-Safe Wickers"
pwd
#修改
sed -i '' '44s/source="$(readlink "${source}")"/source="$(readlink -f "${source}")"/' Pods-Safe\ Wickers-frameworks.sh

#对修改后的文件进行验证
sed -n '44p' Pods-Safe\ Wickers-frameworks.sh

#将44行内容赋值给一个变量,判断是否含有 "-f" 字符串,有就打印"修改成功",没有就打印"修改失败"
if [[ $(sed -n '44p' Pods-Safe\ Wickers-frameworks.sh) =~ "-f" ]]; then
    echo "修改成功"
else
    echo "修改失败"
fi
