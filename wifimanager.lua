-- check if file credentials.lua exists on device
if file.open("credentials.lua") then
  print("credential file found...")
  file.close()
  

  

else
  -- file don't exists, runnning on ap mode
  print("Credentials file not found, going into AP mode")
  dofile("ap_mode.lua")
end
