
value = gpio.HIGH
-- Function toggles LED state
function toggleLED ()
   if value == gpio.LOW
   then
        value = gpio.HIGH
   else
       value = gpio.LOW
   end

    gpio.write(led_pin, value)
end

-- define a callback function named "pin_cb", short for "pin callback"
function pin_cb()
    print("Reset config button pressed. Removing credentials file and rebooting the device. ")
    toggleLED()
    file.remove("credentials.lua")
    node.restart()
end


gpio.write(led_pin, value)

-- register a button event
-- that means, what's registered here is executed upon button event "up"
gpio.trig(button_pin, "up", pin_cb)
