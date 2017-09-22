#!/bin/bash

# Скрипт проверяет наличие обновлений браузера Яндекс, и устанавливает их.

addr="http://repo.yandex.ru/yandex-browser/rpm/beta/x86_64"
i="index.html"
wget -O $i "$addr/"
y=$(grep "x86_64.rpm" < $i)
s="${y#*\"}"
yb="${s%%\"*}"
echo "Пакет последней версии: $yb"
rm -rf $i
if [ ! -e "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver" ]
then
	touch "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver"
fi
yabrowserInstall(){
oyb=$(cat "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver")
if [[ $yb == "$oyb" ]]
then
	echo -e "\\e[32;1mНет обновлений для Yandex Browser Beta.\\e[0m"
	exit 1
else
	loyb=${#oyb}
	if [[ $loyb -eq 0 ]]
	then
		echo -e"\\e[35;1mYabrowser не установлен или скрипт $0 не запускался.\\e[0m"
		echo -e "\\e[35;1mНет информации о версии браузера.\\e[0m"
	fi
	echo -e "\\e[34;1mВы хотите установить новую версию браузера? [Y/n]\\e[0m"
	read -n -r 1 n
	if [[ $n == "y" || $n == "Y" || ! $n ]]
	then
		echo -e "\\n\\e[32;1mНачинаем установку...\\e[0m"
		urpmi "$addr/$yb"
		echo "$yb" > "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver"
		echo -e "\\e[32;1mБраузер установлен.\\e[0m"
	else
		echo -e "\\n\\e[33;1mУстановка отменена.\\e[0m"
		echo -e "\\e[32;1mВы хотите установить пакет $yb позже? [Y/n]\\e[0m"
		read -n -r 1 v
		if [[ $v == "y" || $v == "Y" || ! $n ]]
		then
			echo -e "\\n\\e[32mПри следующем запуске скрипт предложит установку новой версии.\\e[0m"
			exit 0
		else
			echo "$yb" > "$HOME/.config/yandex-browser-beta/yandex-upd.sh.lastver"
			echo -e "\\n\\e[33mУстановка актуальной версии отменена. В следующий раз будет предложено обновление только если выйдет следующая версия.\\e[0m"
			exit 0
		fi
		exit 1
	fi
fi
}

yabrowserInstall

echo -e "\\e[34;1mУстановка libffmpeg\\e[m"

URL="http://archive.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/"
wget $URL
d=0
declare -a r
t=$(grep "chromium-codecs-ffmpeg-extra_" < index.html)
for LINE in $t
do
	pkg="${LINE#*href=\"}"
	sr="${pkg%%\"*}"
	l="chromium-codecs-ffmpeg-extra_"
	sl="${#l}"
	if [[ ${sr:0:$sl} == "$l" ]]
	then
		r[$d]="$sr"
		d=$((d + 1))
	fi
done
#echo "b=$d"
ll=$((d - 2))
echo -e "\\e[32;1mСкачиваем последний пакет: ${r[$ll]}\\e[0m"
wget "$URL${r[$ll]}"
echo -e "\\e[32;1mРаспаковываем...\\e[0m"
7z x "${r[$ll]}"
tar -xf data.tar
echo -e "\\e[34;1mСохраняем предыдущую версию в /opt/yandex/browser-beta/lib/libffmpeg.so.old\\e[0m"
sudo mv /opt/yandex/browser-beta/lib/libffmpeg.so /opt/yandex/browser-beta/lib/libffmpeg.so.old
echo -e "\\e[34;1mКопируем libffmpeg.so в /opt/yandex/browser-beta/lib/libffmpeg.so.ubuntu\\e[0m"
sudo cp usr/lib/chromium-browser/libffmpeg.so /opt/yandex/browser-beta/lib/libffmpeg.so.ubuntu
echo -e "\\e[34;1mСоздаем ссылку...\\e[0m"
sudo ln -s /opt/yandex/browser-beta/lib/libffmpeg.so.ubuntu /opt/yandex/browser-beta/lib/libffmpeg.so
echo -e "\\e[34;1mУдаляем временные файлы...\\e[0m"
rm -rf usr index.html "${r[$ll]}" data.tar
echo -e "\\e[32;1mГотово!\\e[0m"
exit 0
