#!/bin/bash

## Servicio o script a monitorizar si se está ejecutando
SERVICE=read_nrflite_pi.py

## Usado el GPIO26, Pin 37, se puede usar cualquier otro
Led=26

if [ ! -e /sys/class/gpio/gpio$Led ]; then
	echo "$Led" > /sys/class/gpio/export
fi

echo "out" > /sys/class/gpio/gpio$Led/direction

while :
do
	result=$(ps ax|grep -v grep|grep $SERVICE)
#	echo ${#result}
	if [ ${#result} != 0 ] 
	then
		# Indicamos con parpadeo lento que está todo OK
		# cada 10 segundos probamos si sigue bien
		for i in `seq 1 5`
		do
			#encendemos led 
			echo 1 > //sys/class/gpio/gpio$Led/value
			#esperamos 1 segundo
			sleep 1
			#apagamos led 
			echo 0 > /sys/class/gpio/gpio$Led/value
			sleep 1
			#esperamos 1 segundo
		done
	else
		# Indicamos con parpadeo rápido que no está funcionando
		# cada 10 segundos probamos si ha vuelto
		for i in `seq 1 75`
		do
		#encendemos led 
			echo 1 > /sys/class/gpio/gpio$Led/value
			#esperamos 10ms
			sleep 0.1
			#apagamos led 
			echo 0 > /sys/class/gpio/gpio$Led/value
			sleep 0.1
			#esperamos 10 ms
		done
		#iniciar script (en este caso un script de python)
		/root/nrf24-Logger-Pi/$SERVICE > /var/log/nrf24_logger.log &
		# esperamos a que cargue
		sleep 1
	fi
done

#En caso de salir forzosamente del bucle
#apagamos led 
echo 0 > /sys/class/gpio/gpio$Led/value