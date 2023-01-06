
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


--this new function for avoid pushbutton debounce and when button press once device will restart
function checkState()
    print("check state ekata awa")
    tmr.delay(3000000)
    btValue=gpio.read(button_pin)
    print("bt value = ", btValue)

    if btValue==0
    then
        print("bt pressed going to pin_cb")
        pin_cb()
    else
        print("button not pressed")
        node.restart()
    end
    
end

gpio.write(led_pin, value)

-- register a button event
-- that means, what's registered here is executed upon button event "up"
--gpio.trig(button_pin, "up", pin_cb)
gpio.trig(button_pin, "down", checkState)


