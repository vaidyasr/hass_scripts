HOST='192.168.1.114'
USER='hass'
PASS='1234'

/usr/bin/mosquitto_sub -h "$HOST" -u "$USER" -P "$PASS" -t "pi4/cmd" | while read -r line; do
case $line in
  *)
    $line
    ;;
esac
done
