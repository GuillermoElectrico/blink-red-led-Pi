#!/bin/bash 

## Usado el GPIO26, Pin 37, se puede usar cualquier otro
Led=26

if [ ! -e /sys/class/gpio/gpio$Led ]; then
	echo "$Led" > /sys/class/gpio/export
fi

echo "out" > /sys/class/gpio/gpio$Led/direction

while : 
do
	#encendemos led 
	echo 1 > /sys/class/gpio/gpio$Led/value
	#esperamos 1 segundo
	sleep 1
	#apagamos led 
	echo 0 > /sys/class/gpio/gpio$Led/value
	#esperamos 1 segundo
	sleep 1
done  #y así hasta el infinito
#En caso de salir forzosamente del bucle
#apagamos led 
echo 0 > /sys/class/gpio/gpio$Led/value

#buena manera de saber si la placa se cuelga en algún momento por exceso de temperatura u otra causa
