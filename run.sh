#!/bin/bash

if [ -f /boot/firmware/PPPwn/config.sh ]; then
source /boot/firmware/PPPwn/config.sh
fi
if [ -z $PYPWN ]; then PYPWN=false; fi
if [ $PYPWN = true ] ; then
sudo bash /boot/firmware/PPPwn/runpy.sh
exit 0
fi
if [ -f /boot/firmware/PPPwn/pconfig.sh ]; then
source /boot/firmware/PPPwn/pconfig.sh
fi
if [ -z $INTERFACE ]; then INTERFACE="eth0"; fi
if [ -z $FIRMWAREVERSION ]; then FIRMWAREVERSION="11.00"; fi
if [ -z $SHUTDOWN ]; then SHUTDOWN=true; fi
if [ -z $USBETHERNET ]; then USBETHERNET=false; fi
if [ -z $PPPOECONN ]; then PPPOECONN=false; fi
if [ -z $VMUSB ]; then VMUSB=false; fi
if [ -z $DTLINK ]; then DTLINK=false; fi
if [ -z $PPDBG ]; then PPDBG=false; fi
if [ -z $TIMEOUT ]; then TIMEOUT="5m"; fi
if [ -z $RESTMODE ]; then RESTMODE=false; fi
if [ -z $LEDACT ]; then LEDACT="normal"; fi
if [ -z $XFWAP ]; then XFWAP="1"; fi
if [ -z $XFGD ]; then XFGD="4"; fi
if [ -z $XFBS ]; then XFBS="0"; fi
if [ -z $XFNWB ]; then XFNWB=false; fi
if [ $XFNWB = true ] ; then
XFNW="--no-wait-padi"
else
XFNW=""
fi
PITYP=$(tr -d '\0' </proc/device-tree/model) 
if [[ $PITYP == *"Raspberry Pi 2"* ]] ;then
coproc read -t 15 && wait "$!" || true
CPPBIN="pppwn7"
VMUSB=false
elif [[ $PITYP == *"Raspberry Pi 3"* ]] ;then
coproc read -t 10 && wait "$!" || true
CPPBIN="pppwn64"
VMUSB=false
elif [[ $PITYP == *"Raspberry Pi 4"* ]] ;then
coproc read -t 5 && wait "$!" || true
CPPBIN="pppwn64"
elif [[ $PITYP == *"Raspberry Pi 5"* ]] ;then
coproc read -t 5 && wait "$!" || true
CPPBIN="pppwn64"
elif [[ $PITYP == *"Raspberry Pi Zero 2"* ]] ;then
coproc read -t 8 && wait "$!" || true
CPPBIN="pppwn64"
VMUSB=false
elif [[ $PITYP == *"Raspberry Pi Zero"* ]] ;then
coproc read -t 10 && wait "$!" || true
CPPBIN="pppwn11"
VMUSB=false
elif [[ $PITYP == *"Raspberry Pi"* ]] ;then
coproc read -t 15 && wait "$!" || true
CPPBIN="pppwn11"
VMUSB=false
else
coproc read -t 5 && wait "$!" || true
CPPBIN="pppwn64"
VMUSB=false
fi
arch=$(getconf LONG_BIT)
if [ $arch -eq 32 ] && [ $CPPBIN = "pppwn64" ] && [[ ! $PITYP == *"Raspberry Pi 4"* ]] && [[ ! $PITYP == *"Raspberry Pi 5"* ]] ; then
CPPBIN="pppwn7"
fi
PLED=""
ALED=""
if [[ $LEDACT == "status" ]] || [[ $LEDACT == "off" ]] ;then
   if [ -f /sys/class/leds/PWR/trigger ] && [ -f /sys/class/leds/ACT/trigger ]  ; then
      PLED="/sys/class/leds/PWR/trigger"
      ALED="/sys/class/leds/ACT/trigger"
      echo none | sudo tee $PLED >/dev/null
      echo none | sudo tee $ALED >/dev/null
   elif [ -f /sys/class/leds/user-led1/trigger ] && [ -f /sys/class/leds/user-led2/trigger ]  ; then
      PLED="/sys/class/leds/user-led1/trigger"
      ALED="/sys/class/leds/user-led2/trigger"
      echo none | sudo tee $PLED >/dev/null
      echo none | sudo tee $ALED >/dev/null
   else
      LEDACT="normal"
   fi
fi
echo -e "\n\n\033[36m _____  _____  _____                               
|  __ \\|  __ \\|  __ \\                    _     _   
| |__) | |__) | |__) |_      ___ __    _| |_ _| |_ 
|  ___/|  ___/|  ___/\\ \\ /\\ / / '_ \\  |_   _|_   _|
| |    | |    | |     \\ V  V /| | | |   |_|   |_|  
|_|    |_|    |_|      \\_/\\_/ |_| |_|\033[0m
\nhttps://github.com/TheOfficialFloW/PPPwn\nhttps://github.com/xfangfang/PPPwn_cpp\033[0m\n\n" | sudo tee /dev/tty1
sudo systemctl stop pppoe
sudo systemctl stop dtlink
if [ $USBETHERNET = true ] ; then
	echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/unbind >/dev/null
	coproc read -t 1 && wait "$!" || true
	echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/bind >/dev/null
	coproc read -t 4 && wait "$!" || true
	sudo ip link set $INTERFACE up
   else	
	sudo ip link set $INTERFACE down
	coproc read -t 5 && wait "$!" || true
	sudo ip link set $INTERFACE up
fi
MENSAGEM="\033c\033[96m ____  ____   ___  _  _   __    ___  ____  ____   __  
(  _ \/ ___) / _ \( \/ ) / _\  / __)(  __)(    \ /  \ 
 ) __/\___ \(__  (/ \/ \/    \( (__  ) _)  ) D ((  O )
(__)  (____/  (__/\_)(_/\_/\_/ \___)(____)(____/ \__/ 
\nhttps://github.com/ps4macedo\033[0m\n\n\033[95m$PITYP\033[92m\n\nFirmware:\033[93m $FIRMWAREVERSION\033[92m\n\nInterface:\033[93m $INTERFACE\033[0m\n\n\033[92mPPPwn:\033[93m C++ $CPPBIN \033[0m"
if [ $VMUSB = true ] ; then
 sudo rmmod g_mass_storage
  FOUND=0
  readarray -t rdirarr  < <(sudo ls /media/pwndrives)
  for rdir in "${rdirarr[@]}"; do
    readarray -t pdirarr  < <(sudo ls /media/pwndrives/${rdir})
    for pdir in "${pdirarr[@]}"; do
       if [[ ${pdir,,}  == "payloads" ]] ; then 
	     FOUND=1
	     UDEV='/dev/'${rdir}
	     break
      fi
    done
      if [ "$FOUND" -ne 0 ]; then
        break
      fi
  done  
  if [[ ! -z $UDEV ]] ;then
    sudo modprobe g_mass_storage file=$UDEV stall=0 ro=0 removable=1
  fi
  MENSAGEM="$MENSAGEM\n\n\033[92mUSB Drive:\033[93m Habilitado\033[0m"
fi
if [ $PPPOECONN = true ] ; then
   MENSAGEM="$MENSAGEM\n\n\033[92mInternet Access:\033[93m Habilitado\033[0m"
else   
   MENSAGEM="$MENSAGEM\n\n\033[92mInternet Access:\033[93m Desabilatado\033[0m"
fi
if [ -f /boot/firmware/PPPwn/pwn.log ]; then
   sudo rm -f /boot/firmware/PPPwn/pwn.log
fi
if [[ $LEDACT == "status" ]] ;then
   echo timer | sudo tee $PLED >/dev/null
fi
if [[ ! $(ethtool $INTERFACE) == *"Link detected: yes"* ]]; then
   MENSAGEM="$MENSAGEM\n\n\033[93mAguardando link... \033[0m"
   while [[ ! $(ethtool $INTERFACE) == *"Link detected: yes"* ]]
   do
      coproc read -t 2 && wait "$!" || true
   done
   MENSAGEM="$MENSAGEM\033[92mLink encontrado\033[0m\n"
fi
if [ $RESTMODE = true ] ; then
sudo pppoe-server -I $INTERFACE -T 60 -N 1 -C PPPWN -S PPPWN -L 192.168.2.1 -R 192.168.2.2 
coproc read -t 2 && wait "$!" || true
while [[ $(sudo nmap -p 3232 192.168.2.2 | grep '3232/tcp' | cut -f2 -d' ') == "" ]]
do
    coproc read -t 2 && wait "$!" || true
done
coproc read -t 5 && wait "$!" || true
GHT=$(sudo nmap -p 3232 192.168.2.2 | grep '3232/tcp' | cut -f2 -d' ')
if [[ $GHT == *"open"* ]] ; then
echo -e "\n\033[95mGoldhen found aborting pppwn\033[0m\n" | sudo tee /dev/tty1
if [[ $LEDACT == "status" ]] ;then
	echo none | sudo tee $PLED >/dev/null
	echo default-on | sudo tee $ALED >/dev/null
fi
sudo killall pppoe-server
if [ $PPPOECONN = true ] ; then
	sudo systemctl start pppoe
	if [ $DTLINK = true ] ; then
		sudo systemctl start dtlink
	fi
else
	if [ $SHUTDOWN = true ] ; then
		coproc read -t 5 && wait "$!" || true
		sudo poweroff
	else
		if [ $DTLINK = true ] ; then
			sudo systemctl start dtlink
		else
			sudo ip link set $INTERFACE down
		fi
	fi
fi
exit 0
else
echo -e "\n\033[95mGoldhen não encontrado, iniciando pppwn\033[0m\n" | sudo tee /dev/tty1
sudo killall pppoe-server
if [ $USBETHERNET = true ] ; then
	echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/unbind >/dev/null
	coproc read -t 1 && wait "$!" || true
	echo '1-1' | sudo tee /sys/bus/usb/drivers/usb/bind >/dev/null
	coproc read -t 4 && wait "$!" || true
	sudo ip link set $INTERFACE up
   else	
	sudo ip link set $INTERFACE down
	coproc read -t 5 && wait "$!" || true
	sudo ip link set $INTERFACE up
fi
fi
fi
PIIP=$(hostname -I) || true
if [ "$PIIP" ]; then
   MENSAGEM="$MENSAGEM\n\033[92mIP: \033[96m $PIIP\033[0m"
fi

MENSAGEM="$MENSAGEM\n\n\n\n\033[37m\033[44m\033[1mPronto para desbloquear o console \033[0m"
echo -e "$MENSAGEM" | sudo tee /dev/tty1
echo -e "\n\033[93mVamos para a tentativa \033[1m\033[96m1...\n\033[0m" | sudo tee /dev/tty1

attempt=2
while [ true ]
do
if [[ $LEDACT == "status" ]] ;then
	echo heartbeat | sudo tee $PLED >/dev/null
	echo timer | sudo tee $ALED >/dev/null
fi
if [ -f /boot/firmware/PPPwn/config.sh ]; then
 if  grep -Fxq "PPDBG=true" /boot/firmware/PPPwn/config.sh ; then
   PPDBG=true
   else
   PPDBG=false
 fi
fi
while read -r stdo ; 
do 
 if [ $PPDBG = true ] ; then
	echo -e $stdo | sudo tee /dev/tty1 | sudo tee /dev/pts/* | sudo tee -a /boot/firmware/PPPwn/pwn.log
 fi
 if [[ $stdo  == "[+] Done!" ]] ; then
	echo -e "\n\n\n\033[92mDESBLOQUEADO!!!\033[0m\n" | sudo tee /dev/tty1
	if [[ $LEDACT == "status" ]] ;then
		echo none | sudo tee $PLED >/dev/null
		echo default-on | sudo tee $ALED >/dev/null
	fi
	if [ $PPPOECONN = true ] ; then
		sudo systemctl start pppoe
		if [ $DTLINK = true ] ; then
			sudo systemctl start dtlink
		fi
	else
		if [ $SHUTDOWN = true ] ; then
			coproc read -t 5 && wait "$!" || true
			echo -e "\033c" | sudo tee /dev/tty1
			sudo poweroff
		else
			if [ $DTLINK = true ] ; then
				sudo systemctl start dtlink
			else
				sudo ip link set $INTERFACE down
			fi
        fi
	fi
	exit 0
 
 elif [[ $stdo == "[+] STAGE "* ]]; then
	stage_number="${stdo:4:7}"
	echo -e -n "\033[92m$stage_number - \033[0m" | sudo tee /dev/tty1
 
 elif [[ $stdo  == *"Scanning for corrupted object...failed"* ]] ; then

 	echo -e "\033[91mFALHA!\033[0m" | sudo tee /dev/tty1
 	echo -e "$MENSAGEM" | sudo tee /dev/tty1
 	echo -e "\033[93m\n\nVamos para a tentativa \033[1m\033[96m$attempt...\033[0m\n" | sudo tee /dev/tty1
	((attempt++))
	
 elif [[ $stdo  == *"Unsupported firmware version"* ]] ; then
 	echo -e "\033[31m\nVersão de firmware não suportada\033[0m\n" | sudo tee /dev/tty1
	if [[ $LEDACT == "status" ]] ;then
	 	echo none | sudo tee $ALED >/dev/null
	 	echo default-on | sudo tee $PLED >/dev/null
	fi
 	exit 1
 elif [[ $stdo  == *"Cannot find interface with name of"* ]] ; then
 	echo -e "\033[31m\nInterface $INTERFACE não encontrada\033[0m\n" | sudo tee /dev/tty1
	
	if [[ $LEDACT == "status" ]] ;then
	 	echo none | sudo tee $ALED >/dev/null
	 	echo default-on | sudo tee $PLED >/dev/null
	fi
 	exit 1
 fi
done < <(timeout $TIMEOUT sudo /boot/firmware/PPPwn/$CPPBIN --interface "$INTERFACE" --fw "${FIRMWAREVERSION//.}" --wait-after-pin $XFWAP --groom-delay $XFGD --buffer-size $XFBS $XFNW)
if [[ $LEDACT == "status" ]] ;then
 	echo none | sudo tee $ALED >/dev/null
 	echo default-on | sudo tee $PLED >/dev/null
fi
sudo ip link set $INTERFACE down
coproc read -t 3 && wait "$!" || true
sudo ip link set $INTERFACE up
done