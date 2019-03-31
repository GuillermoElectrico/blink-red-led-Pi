#!/bin/bash
## Script para monitorizar entrada digital Raspberry Pi (recomendable https://github.com/zhaolei/WiringOP) y ejecutar o matar proceso dependiendo de su estado.
# Indicar con un led estado del script dependiendo del parpadeo para informar estado.

SERVICE=read_energy_meter.py

## Usado el GPIO6, Pin 31, se puede usar cualquier otro
Boton=6 

## Usado el GPIO26, Pin 37, se puede usar cualquier otro
Led=26


## Configurar entrada GPIO 
if [ ! -e /sys/class/gpio/gpio$Boton ]; then
	echo "$Boton" > /sys/class/gpio/export
fi
echo "in" > /sys/class/gpio/gpio$Boton/direction

## Configurar Salida GPIO (Led status externo) 
if [ ! -e /sys/class/gpio/gpio$Led ]; then
	echo "$Led" > /sys/class/gpio/export
fi
echo "out" > /sys/class/gpio/gpio$Led/direction

while :
do
	a=$(cat /sys/class/gpio/gpio$Boton/value)    
	result=$(ps ax|grep -v grep|grep $SERVICE)
#	echo ${#result}
#	echo $a
	#comprobamos si está en ejecución el script
	if [ ${#result} != 0 ] 
	then
		# si está en ejecución y está activado el interruptor, es decir, puesto a 0v la entrada
		if [ "$a" = 0 ];
		then
			#matar script (en este caso un script de python)
			pkill -f $SERVICE
			#esperamos a que cierre
			sleep 1
		else
			# Si no, indicamos con parpadeo lento que está todo OK
			# cada 10 segundos probamos si sigue bien
			for i in `seq 1 5`
			do
				#encendemos led 
				echo 1 > /sys/class/gpio/gpio$Led/value
				#esperamos 1 segundo
				sleep 1
				#apagamos led 
				echo 0 > /sys/class/gpio/gpio$Led/value
				sleep 1
				#esperamos 1 segundo
			done
		fi
	else
		# si no está en ejecución el programa y esta desactivado el interuptor, es decir a 3.3V con una resistencia de 10K
		if [ "$a" = 1 ];
		then
			#inicar script (en este caso un script de python)
			/home/pi/energy-meter-logger/$SERVICE --interval 60 > /var/log/energy_meter.log &
			# esperamos a que cargue
			sleep 1
		else
			# Si no, indicamos con parpadeo rápido que no está funcionando
			# cada 10 segundos probamos si ha vuelto o hay que revivirlo
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
		fi
	fi
done
