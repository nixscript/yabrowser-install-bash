#!/bin/bash

# Скрипт проверяет наличие обновлений браузера Яндекс, и устанавливает их.

addr="http://repo.yandex.ru/yandex-browser/rpm/beta/x86_64"
i="index.html"
wget -O $i "$addr/"
y=`cat "$i" | grep "x86_64.rpm"`
s=`expr index "$y" "\""`
Y=${y:$s}
e=`expr index "$Y" "\""`
e=`expr $e - 1`
yb="${Y:0:$e}"
echo "Пакет последней версии: $yb"
rm -rf $i
if [ ! -e "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver" ]
then
	touch "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver"
fi

oyb=`cat "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver"`
if [[ $yb == $oyb ]]
then
	echo "Нет обновлений для Yandex Browser Beta."
	exit 1
else
	loyb=${#oyb}
	if [[ $loyb -eq 0 ]]
	then
		echo "Либо Яндекс браузер не установлен, либо Вы не пользовались скриптом."
		echo "Нет информации об установленной версии браузера."
	fi
	echo "Хотите установить новую версию? [Y/n]"
	read -n 1 n
	if [[ $n == "y" || $n == "Y" || ! $n ]]
	then
		echo
		echo "Приступаем к установке."
		urpmi "$addr/$yb"
		echo $yb > "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver"
		echo "Установка браузера завершена."
	else
		echo
		echo "Установка отменена."
		echo "Хотите установить позже пакет $yb ? [Y/n]"
		read -n 1 $v
		if [[ $v == "y" || $v == "Y" || ! $n ]]
		then
			echo
			echo "При следующем запуске скрипта Вам будет предложено установить"
			echo "актуальную версию браузера."
			exit 0
		else
			echo
			echo $yb > "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver"
			echo "Установка текущей версии отменена. При следующем запуске, обновление будет"
			echo "предложено только если версия пакета будет новее текущего."
			exit 0
		fi
		exit 1
	fi
fi

echo "Установка библиотеки libffmpeg"

URL="http://archive.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/"
wget $URL
d=0
declare -a r
t=`cat index.html | grep "chromium-codecs-ffmpeg-extra_"`
for LINE in $t
do
	l=`expr "$LINE" : '.*chromium-codecs-ffmpeg-extra_'`
	l=`expr $l - 29`
	s=`expr "${LINE:$l}" : '.*amd64.deb'`
	sr="${LINE:$l:$s}"
	sl=${#sr}
	if [[ $sl -gt 0 ]]
	then
		r[$d]="$sr"
		d=`expr $d + 1`
	fi
done
echo "b=$d"
ll=`expr $d - 2`
echo "Скачиваем последнюю версию: ${r[$ll]}"
exit
wget "$URL${r[$ll]}"
echo "Распаковываем..."
7z x "${r[$ll]}"
tar -xf data.tar
echo "Сохраняем предыдущую версию библиотеки в /opt/yandex/browser-beta/lib/libffmpeg.so.old"
sudo mv /opt/yandex/browser-beta/lib/libffmpeg.so /opt/yandex/browser-beta/lib/libffmpeg.so.old
echo "Копируем libffmpeg.so в /opt/yandex/browser-beta/lib/libffmpeg.so.ubuntu"
sudo cp usr/lib/chromium-browser/libffmpeg.so /opt/yandex/browser-beta/lib/libffmpeg.so.ubuntu
echo "Создаем ссылку..."
sudo ln -s /opt/yandex/browser-beta/lib/libffmpeg.so.ubuntu /opt/yandex/browser-beta/lib/libffmpeg.so
echo "Удаляем временные файлы."
rm -rf usr index.html "${r[$ll]}" data.tar
echo "Установка завершена."
exit 0
