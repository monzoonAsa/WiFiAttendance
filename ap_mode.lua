savedSSID=0
savedPw=0
-- put module in AP mode
wifi.setmode(wifi.SOFTAP)
print("ESP8266 mode is: " .. wifi.getmode())

-- Set the SSID of the module in AP mode and access password
cfg={}
cfg.ssid="ESP_" .. node.chipid()
cfg.pwd="passw0rd"
print("Chip ID: " .. node.chipid())
print("ESP8266 SSID is: " .. cfg.ssid .. " and PASSWORD is: " .. cfg.pwd)

-- Now you should see an SSID wireless router named ESP_STATION when you scan 
--   for available WIFI networks
-- Lets connect to the module from a computer of mobile device. So, 
--   find the SSID and connect using the password selected
wifi.ap.config(cfg)
ap_mac = wifi.ap.getmac()
print("AP MAC: " .. ap_mac)


--tObj=tmr.create() ---timer object create by me


-- create a server on port 80 and wait for a connection, when a connection 
--   is coming in function c will be executed
sv = net.createServer(net.TCP, 30) -- 30s timeou
function urldecode (str)  --url decode function
   str = string.gsub (str, "+", " ")
   str = string.gsub (str, "%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)
   return str
end



function receiver(sck, data)
  --print("test1")
  -- wait until SSID comes back and parse the SSID and the password
  data = urldecode(data)
  --print(data)
  --print("test2")
  ssid_start,ssid_end=string.find(data,"SSID=")
  print(ssid_start,ssid_end)
  if ssid_start and ssid_end then
    password_start, password_end =string.find(data,"PASSWORD=")
    print(password_start, password_end)
    if password_start and password_end then
      mqtt_start, mqtt_end =string.find(data,"MQTTAddress=")
      print(mqtt_start, mqtt_end)
      if mqtt_start and mqtt_end then
        http_start, http_end = string.find(data,"HTTP/1.1")
        print(http_start, http_end)
            if http_start and http_end then

        
                ssid=string.sub(data,ssid_end+1, password_start-2)
                password=string.sub(data,password_end+1, mqtt_start-2)
                mqttAddress=string.sub(data,mqtt_end+1, http_start-1)

                --print("ESP8266 connecting to SSID: "..ssid.." with PASSWORD: "..password.. " and mqtt address : "..mqttAddress)
                if ssid and password then
                -- close the server and set the module to STATION mode
                --create credential file
                savedSSID=ssid
                savedPw=password
                savedMqtt=mqttAddress

                file.open("credentials.lua","w+")
                --temp = ssid
                temp = "SSID =\""..ssid.."\""
                file.writeline(temp)
                --temp =password
                temp = "PASS =\""..password.."\""
                file.writeline(temp)

                --temp = mqtt
                temp="MQTT =\""..mqttAddress.."\""
                file.writeline(temp)
                
                file.flush()
                temp = nil
                file.close()
                print("credentials saved successfully server is going to close")
          
                sv:close()
                print("saved ssid:-",savedSSID )
                print("saved pw:-",savedPw )
                node.restart() 
         
            end

          
        end
      end
    end
  end
  
  -- this is the webpage form presented to be configured
  local title = "20SEA061- EA3050_Final Project"
  local subtitle = "Configure Device Wifi credential </h2><p>Use the following form to connect this Device on your Wifi network"

  local response = {"HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/html\r\n\r\n"}
  response[#response + 1] = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\"><head>" 
  response[#response + 1] = "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\"><title>" .. title .. "</title></head><body><div><h1><a>" .. title .. "</a></h1>" 
  response[#response + 1] = "<form method=\"get\" action=\"/?SSID=\"><div>"
  response[#response + 1] = "<h2>" .. subtitle .. "</p></div>"
  response[#response + 1] = "<ul ><li><label> SSID </label><div><input name=\"SSID\" type=\"text\" maxlength=\"255\" value=\"\"/>" 
  response[#response + 1] = "</div> </li><li><label> Password </label><div><input name=\"PASSWORD\" type=\"text\" maxlength=\"255\" value=\"\"/> </div> "
  response[#response + 1] = "<li><label> MQTT Address </label><div><input name=\"MQTTAddress\" type=\"text\" maxlength=\"255\" value=\"\"/>" 
  response[#response + 1] = "</li><input type=\"submit\" value=\"Save\" /></ul></form>"

  response[#response + 1] =  "The module MAC address is: " .. ap_mac


  -- sends and removes the first element from the 'response' table
  local function send(localSocket)
    if #response > 0 then
      localSocket:send(table.remove(response, 1))
    else
      localSocket:close()
      response = nil
    end
  end

  -- triggers the send() function again once the first chunk of data was sent
  sck:on("sent", send)
  send(sck)
end

if sv then
    print("Server Created.")
    sv:listen(80, function(conn) -- listen on port 80
    print("Receiving connection on port 80.")
    conn:on("receive", receiver)
  end)
else
  print("ERR: Server was not created.")
end
