station_cfg={}
station_cfg.ssid="Home-3"
station_cfg.pwd="ta9cuaq8-1"

wifi.setmode(wifi.STATION,false)

wifi.sta.config(station_cfg)

net_state = tmr.create()
net_state:register(2000, tmr.ALARM_AUTO, function() 
if wifi.sta.getip()==nil then
print('.')
wifi.sta.config(station_cfg);
else
print(wifi.sta.getip());
end
end);

m = mqtt.Client("ahe"..node.chipid(), 120);
m:connect("192.168.1.10", 1883, false, function(client)
  print("connected")
   client:publish("/topic", "hello", 0, 0, function(client) print("sent") end)
end,
function(client, reason)
  print("failed reason: " .. reason)
end)