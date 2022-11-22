--Author:Hasith Perera (hasith@fos.cmb.ac.lk)

--Change the wifi ssid and the password 
--If you need static ip addressing you can add them by uncommenting the following lines

--wifi.sta.setip({
--  ip = "10.21.11.110",
--  netmask = "255.255.248.0",
--  gateway = "10.21.15.254"
--})

--station_cfg={}
--station_cfg.ssid="Home-3"
--station_cfg.pwd="ta9cuaq8-1"


ch = 1;
try_times = 0;

data = {}
gpio.mode(4,gpio.OUTPUT)

--Onboard LED will be kept turned on until restared
init_conn = tmr.create();
init_conn:register(60000, tmr.ALARM_SINGLE, function()
    print("[cmd]crowdtrace");
    wifi.monitor.stop();
    
--    wifi.setmode(wifi.STATION,false);
--    wifi.sta.config(station_cfg);
    change_ch:stop();
    senddata()
    gpio.write(4,gpio.LOW);
end)


--Channel scan interval is set to 0.5 s
-- onboard LED will blink during detection

j=1;
change_ch = tmr.create()
change_ch:register(1000, tmr.ALARM_AUTO, function() 
    --print("ch:"..ch);
    ch = ch +1;
    if ch == 16 then
        ch=1;
    end
    wifi.monitor.channel(ch);
    if j==1 then
        j=0;
        gpio.write(4,gpio.HIGH);
    else
        j=1;
        gpio.write(4,gpio.LOW);
    end
end)


--main program start


change_ch:start()
--init_conn:start()
wifi.monitor.start(13,0x40,function(p)end)
wifi.monitor.start(13,0x40,function(pkt)
    print (pkt.dstmac_hex..","..pkt.rssi..","..pkt.bssid_hex..","..pkt.channel..","..pkt.ie_ssid)
--    if data[pkt.dstmac_hex]== nil then
--        data[pkt.dstmac_hex]=1;
--    else
--        data[pkt.dstmac_hex]=1+data[pkt.dstmac_hex];
--    end
end)

--reboot_delay = tmr.create()
--reboot_delay:register(1000, tmr.ALARM_AUTO, function()  end)

-- MQTT functions for transmission
function senddata()
    --m = mqtt.Client("ahe"..node.chipid(), 120);

    --change mosquitto server ip
    --m:connect("192.168.1.6", 1883, false, function(client)
    --client:publish("crowdtrace/alive",node.chipid(), 0, 0)  
     for mac, n in pairs(data) do 
            print("[data],"..mac..","..n)
            --client:publish("crowdtrace/"..node.chipid(), mac..","..n, 0, 0)  
     end
    init_conn:unregister();
    node.restart()
end







