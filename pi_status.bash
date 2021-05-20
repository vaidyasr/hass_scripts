#!/bin/bash
HOST='192.168.1.114'
USER='hass'
PASS='1234'
sleep_time=30
MQTT_COMMAND="/usr/bin/mosquitto_pub -h "$HOST" -t"
AUTODISCOVERY_PREFIX="homeassistant"
DEVICE_TYPE=sensor
PREFIX="$AUTODISCOVERY_PREFIX/$DEVICE_TYPE"
STAT_T="homeassistant/sensor/pi4/state"

while true
do
$MQTT_COMMAND "$PREFIX/pi4_usb1_disk/config" -m '{"name":"Pi4 USB1 Disk Usage","stat_t":"'"$STAT_T"'","unit_of_meas":"%","val_tpl":"{{value_json.usb1_disk_usage}}","ic":"mdi:harddisk","uniq_id":"pi4_usb1_disk","dev":{"ids":["Pi4"],"name":"Raspberry Pi 4","mdl":"Pi 4 Model B","sw":"Debian GNU/Linux 9 (stretch)","mf":"raspberry Pi Foundation"}}'
$MQTT_COMMAND "$PREFIX/pi4_usb1_temp/config" -m '{"name":"Pi4 USB1 Disk Temperature","stat_t":"'"$STAT_T"'","unit_of_meas":"°C","val_tpl":"{{value_json.usb1_disk_temp}}","ic":"mdi:thermometer","uniq_id":"pi4_usb1_temp","dev":{"ids":["Pi4"]}}'
$MQTT_COMMAND "$PREFIX/pi4_usb2_temp/config" -m '{"name":"Pi4 USB2 Disk Temperature","stat_t":"'"$STAT_T"'","unit_of_meas":"°C","val_tpl":"{{value_json.usb2_disk_temp}}","ic":"mdi:thermometer","uniq_id":"pi4_usb2_temp","dev":{"ids":["Pi4"]}}'
$MQTT_COMMAND "$PREFIX/pi4_usb2_disk/config" -m '{"name":"Pi4 USB2 Disk Usage","stat_t":"'"$STAT_T"'","unit_of_meas":"%","val_tpl":"{{value_json.usb2_disk_usage}}","ic":"mdi:harddisk","uniq_id":"pi4_usb2_disk","dev":{"ids":["Pi4"]}}'
$MQTT_COMMAND "$PREFIX/pi4_usb3_disk/config" -m '{"name":"Pi4 USB3 Disk Usage","stat_t":"'"$STAT_T"'","unit_of_meas":"%","val_tpl":"{{value_json.usb3_disk_usage}}","ic":"mdi:harddisk","uniq_id":"pi4_usb3_disk","dev":{"ids":["Pi4"]}}'
$MQTT_COMMAND "$PREFIX/pi4_temp/config" -m '{"name":"Pi4 Temperature","stat_t":"'"$STAT_T"'","unit_of_meas":"°C","val_tpl":"{{value_json.cpu_temp}}","ic":"mdi:thermometer","uniq_id":"pi4_temp","dev":{"ids":["Pi4"]}}'
$MQTT_COMMAND "$PREFIX/pi4_voltage/config" -m '{"name":"Pi4 Voltage","stat_t":"'"$STAT_T"'","unit_of_meas":"V","val_tpl":"{{value_json.pi4_voltage}}","ic":"mdi:flash","uniq_id":"pi4_voltage","dev":{"ids":["Pi4"]}}'
$MQTT_COMMAND "$PREFIX/pi4_network_speed/config" -m '{"name":"Pi4 Network Speed","stat_t":"'"$STAT_T"'","unit_of_meas":"Mbps","val_tpl":"{{value_json.pi4_network_speed}}","ic":"mdi:wifi","uniq_id":"pi4_network_speed","dev":{"ids":["Pi4"]}}'
$MQTT_COMMAND "$PREFIX/pi4_status/config" -m '{"name":"Pi4 Status","stat_t":"'"$STAT_T"'","val_tpl":"{{value_json.pi4_status}}","ic":"mdi:eye-outline","uniq_id":"pi4_status","dev":{"ids":["Pi4"]}}'

cpu_temp=`vcgencmd measure_temp|cut -d'=' -f2|sed "s|'C||g"`
pi4_voltage=`vcgencmd measure_volts core|cut -d'=' -f2|sed "s|V||g"`
pi4_status=`/share/scripts/check_throttle`
usb1_disk_temp=`drv=$(mount |grep /Download| cut -c1-8);files=$(lsof|grep /Download/|wc -l);if [ $files -ne 0 ];then smartctl -a $drv| awk '{if ($2 == "Temperature_Celsius") print $10}';else echo 0;fi`
usb2_disk_temp=`drv=$(mount |grep /Media| cut -c1-8);files=$(lsof|grep /Media/|wc -l);if [ $files -ne 0 ];then smartctl -a $drv -d sat -n standby| awk '{if ($2 == "Temperature_Celsius") print $10}';else echo 0;fi`
usb1_disk_usage=`df /share/Download| tail -1 |awk '{print $5}'|sed 's|%||g'`
usb2_disk_usage=`df /share/Media| tail -1 |awk '{print $5}'|sed 's|%||g'`
usb3_disk_usage=`df /share/Data| tail -1 |awk '{print $5}'|sed 's|%||g'`
network_speed=`ethtool eth0 | grep -i speed| cut -d':' -f2|sed 's|Mb/s||g'|sed 's| ||g'`
if [ "$usb1_disk_usage" = "" ];then
	usb1_disk_usage=0
fi
if [ "$usb1_disk_temp" = "" ];then
	usb1_disk_temp=0
fi
$MQTT_COMMAND "$PREFIX/pi4/state" -m '{"usb1_disk_usage": '"$usb1_disk_usage"',"usb2_disk_usage":'"$usb2_disk_usage"',"usb3_disk_usage":'"$usb3_disk_usage"',"usb1_disk_temp":'"$usb1_disk_temp"',"usb2_disk_temp":'"$usb2_disk_temp"',"cpu_temp":'"$cpu_temp"',"pi4_network_speed":'"$network_speed"',"pi4_voltage":'"$pi4_voltage"',"pi4_status":'\""$pi4_status"\"',"camera_backup_status":'\""$camera_backup_status"\"',"front_camera_backup_status":'\""$front_camera_backup_status"\"',"rear_camera_backup_status":'\""$rear_camera_backup_status"\"',"hall_camera_backup_status":'\""$hall_camera_backup_status"\"',"parking_camera_backup_status":'\""$parking_camera_backup_status"\"'}'
sleep $sleep_time

done
