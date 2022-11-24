-- Overclock the CPU to 160Mhz
node.setcpufreq(node.CPU160MHZ)

-- Check if exist configuration file
print("Booting up ESP8266...")
print("20sea061 P.G.A.S Pinnagoda EA3050 final project")

button_pin = 6
led_pin = 5    
gpio.mode(button_pin, gpio.INT, gpio.PULLUP)
gpio.mode(led_pin, gpio.OUTPUT)   


net_tag = 0;            --to have extendable networks

net_retry = 50              --Number of retries
net_retry_timeout = 2000    --delay between retries in ms

monitor_time = 150000       --monitor time in ms
channel_time = 5000         --channel sweep time in ms


serial_info = "[000]"
serial_err  = "[-00]"


if file.open("credentials.lua") then
    print("crednetial file found")
    dofile("credentials.lua")
    print("saved SSID :-",SSID)
    print("saved Password :-",PASS)
    print("saved mqtt :-",MQTT)
    dofile("crowdIni.lua")
    dofile("reset_conf.lua")

else
    print("running on station mode for get credentials")
    dofile("wifimanager.lua")
    dofile("reset_conf.lua")
end







