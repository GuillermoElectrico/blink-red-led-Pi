#!/bin/bash
## Script para monitorizar entrada digital Raspberry Pi (recomendable https://github.com/zhaolei/WiringOP) y ejecutar o matar proceso dependiendo de su estado.
# Indicar con un led estado del script dependiendo del parpadeo para informar estado.

SERVICE1=read_energy_meter.py

SERVICE2=read_input_raspberry.py

SERVICE3=mqtt_to_influxdb.py

#SERVICE4=mqtt.py

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

echo "Inicio de ejecución del script - $(date)"

while :
do
	a=$(cat /sys/class/gpio/gpio$Boton/value)    
	result1=$(ps ax|grep -v grep|grep $SERVICE1)
	result2=$(ps ax|grep -v grep|grep $SERVICE2)
	result3=$(ps ax|grep -v grep|grep $SERVICE3)
#	result4=$(ps ax|grep -v grep|grep $SERVICE4)
#	echo ${#result}
#	echo $a
	#comprobamos si está en ejecución el script
	if [ ${#result1} != 0 ] && [ ${#result2} != 0 ] && [ ${#result3} != 0 ] 
	then
		# si está en ejecución y está activado el interruptor, es decir, puesto a 0v la entrada
		if [ "$a" = 0 ];
		then
			date
			#matar script (en este caso un script de python)
			echo "Matar Servicio1 - $(date)"
			pkill -f $SERVICE1
			#esperamos a que cierre
			sleep 1
			echo "Matar Servicio2 - $(date)" 
			pkill -f $SERVICE2
			#esperamos a que cierre
			sleep 1
			echo "Matar Servicio3 - $(date)" 
			pkill -f $SERVICE3
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
			if [ ${#result1} == 0 ]
			then
				date
				#iniciar script Servicio 1 (en este caso un script de python)
				echo "Ejecutar Servicio1 - $(date)"
				/home/pi/energy-meter-logger/read_energy_meter.py --interval 60 > /var/log/energy_meter.log &
				# esperamos a que cargue
				sleep 1
			fi
			
			if [ ${#result2} == 0 ]
			then
				date
				#iniciar script Servicio 2 (en este caso un script de python)
				echo "Ejecutar Servicio2 - $(date)"
				/home/pi/Digital-Inputs-Logger-Pi/read_input_raspberry.py > /var/log/inputs-logger.log &
				# esperamos a que cargue
				sleep 1
			fi
			
			if [ ${#result3} == 0 ]
			then
				date
				#iniciar script Servicio 3 (en este caso un script de python)
				echo "Ejecutar Servicio3 - $(date)"
				/home/pi/mqtt_to_influxdb/mqtt_to_influxdb.py > /var/log/mqtt-logger.log &
				# esperamos a que cargue
				sleep 1
			fi
			
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
