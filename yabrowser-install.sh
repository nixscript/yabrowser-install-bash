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
echo "Last version package is: $yb"
rm -rf $i
if [ ! -e "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver" ]
then
	touch "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver"
fi

oyb=`cat "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver"`
if [[ $yb == $oyb ]]
then
	echo "No updates for Yandex Browser Beta."
	exit 1
else
	loyb=${#oyb}
	if [[ $loyb -eq 0 ]]
	then
		echo "Yabrowser not installed or You not have run this script."
		echo "No information about version of browser."
	fi
	echo "Do You want to install new version? [Y/n]"
	read -n 1 n
	if [[ $n == "y" || $n == "Y" || ! $n ]]
	then
		echo
		echo "Start to install."
		urpmi "$addr/$yb"
		echo $yb > "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver"
		echo "Browser installed."
	else
		echo
		echo "Installation cancelled."
		echo "Do You want to install package $yb later? [Y/n]"
		read -n 1 $v
		if [[ $v == "y" || $v == "Y" || ! $n ]]
		then
			echo
			echo "In next running this script ask You to install new version."
			exit 0
		else
			echo
			echo $yb > "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver"
			echo "Current version instaal cancelled. In next time, will be updated if version is next."
			exit 0
		fi
		exit 1
	fi
fi

echo "Install libffmpeg"

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
echo "Downloding last version: ${r[$ll]}"
exit
wget "$URL${r[$ll]}"
echo "Extract..."
7z x "${r[$ll]}"
tar -xf data.tar
echo "Save previous version in to /opt/yandex/browser-beta/lib/libffmpeg.so.old"
sudo mv /opt/yandex/browser-beta/lib/libffmpeg.so /opt/yandex/browser-beta/lib/libffmpeg.so.old
echo "Copy libffmpeg.so in /opt/yandex/browser-beta/lib/libffmpeg.so.ubuntu"
sudo cp usr/lib/chromium-browser/libffmpeg.so /opt/yandex/browser-beta/lib/libffmpeg.so.ubuntu
echo "Create symlink..."
sudo ln -s /opt/yandex/browser-beta/lib/libffmpeg.so.ubuntu /opt/yandex/browser-beta/lib/libffmpeg.so
echo "Remove temporary files."
rm -rf usr index.html "${r[$ll]}" data.tar
echo "Finished."
exit 0
