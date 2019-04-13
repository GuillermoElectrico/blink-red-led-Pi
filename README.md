# Simple blink red led Raspberry Pi

Simple script bash to blink Raspberry Pi onboard led red to heartbeat

### Requirements

#### Hardware

* Raspberry Pi

#### Software

* Raspbian or DietPi

### Installation
* Download from Github 
    ```sh
    $ git clone https://github.com/GuillermoElectrico/blink-red-led-Pi.git
	$ cd blink-red-led-Pi/
	$ sudo chmod +x blink-red-led-Pi.sh

* To run the script at system startup. Add to following lines to the end of /etc/rc.local but before exit:
    ```sh
    # Start Blink Led Heartbeat Raspberry
    /home/--user--/blink-red-led-Pi/blink-red-led-Pi.sh > /var/log/blink_led.log &
    ```
