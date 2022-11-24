--Author:Hasith Perera (hasith@fos.cmb.ac.lk)

--Change the wifi ssid and the password 
--If you need static ip addressing you can add them by uncommenting the following lines
print("logmqtt start")
print("mqtt server = ",mqtt_server)
print("node id:-",node.chipid())
ch = 1;

try_times = net_retry ;
data = {}
data_sig = {}

gpio.mode(led_pin,gpio.OUTPUT)

net_state = tmr.create()
restart_delay = tmr.create()


net_state:register(net_retry_timeout, tmr.ALARM_AUTO, function() 
    print("net state on")
    if net_retry <0 then
        node.restart()
    end
    
    if wifi.sta.getip()==nil then
        net_retry = net_retry - 1;
        print('.')
    else
        print(wifi.sta.getip());
        print("mqtt trsmition is on")
        -- MQTT functions for transmission
        m = mqtt.Client("ahe"..node.chipid(), 120);
        m:connect(mqtt_server, 1883, false, function(client)
        print(serial_info.."connected")
              
        --client:publish("crowdtrace/"..node.chipid().."/alive",try_times -net_retry, 0, 0)
        for mac, rssi in pairs(data_sig) do 
            
            json_data='{"node":"'..node.chipid()..'","mac":"'..mac..'","rssi":"'..rssi..'","packets":"'..data[mac]..'","net_tag":"'..net_tag..'"}'
            --json_data='{'..node.chipid()..','..mac..','..rssi..','..data[mac]..','..net_tag..'}'
            print(client.publish)
            print(serial_info..json_data)
            print(json_data)
            client:publish("crowdtrace/"..node.chipid().."/data",json_data , 0, 0)  
        end
           print(serial_info)
           net_state:stop()
           restart_delay:start();
        end,function(client,reason) print(serial_err..reason) end);
        
    end
end);

restart_delay:register(2000, tmr.ALARM_AUTO, function() 
    node.restart()
    end)

--Onboard LED will be kept turned on until restared
init_conn = tmr.create();
init_conn:register(monitor_time, tmr.ALARM_SINGLE, function()
    --print("chanel connect ekata awa")
    --print(serial_head.."Net_conn");
    wifi.monitor.stop();
    change_ch:stop();


    net_state:start();
    wifi.setmode(wifi.STATION);
    wifi.sta.config(station_cfg);
    gpio.write(led_pin,gpio.LOW);
end)

--Channel scan interval is set to 0.5 s
-- onboard LED will blink during detection

j=1;
change_ch = tmr.create()
change_ch:register(channel_time, tmr.ALARM_AUTO, function() 
    --print("ch:"..ch);
    print(ch)
    ch = ch +1;
    if ch == 16 then
        ch=1;
    end
    wifi.monitor.channel(ch);
    if j==1 then
        j=0;
        gpio.write(led_pin,gpio.HIGH);
    else
        j=1;
        gpio.write(led_pin,gpio.LOW);
    end
end)


--main program start
-- https://en.wikipedia.org/wiki/802.11_Frame_Types


change_ch:start()
init_conn:start()
wifi.monitor.start(13,0x40,function(p)end)
wifi.monitor.start(13,0x40,function(pkt)
    --print (pkt.dstmac_hex.." rssi:"..pkt.rssi)
    data_sig[pkt.dstmac_hex] = pkt.rssi;
    if data[pkt.dstmac_hex]== nil then
        data[pkt.dstmac_hex]=1;
        

    else
        data[pkt.dstmac_hex]=1+data[pkt.dstmac_hex];
        -- take the average of the signal level(will give the average location)
        data_sig[pkt.dstmac_hex] = (pkt.rssi + data_sig[pkt.dstmac_hex])/2;
    end
end)

--reboot_delay = tmr.create()
--reboot_delay:register(1000, tmr.ALARM_AUTO, function()  end)
--reboot_delay:register(1000, tmr.ALARM_AUTO, function()  end)
