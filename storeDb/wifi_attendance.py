##mqtt server data log to sqlite DB file by P.G.A.S Pinnagoda EA3050 Final project
print("20sea061 P.G.A.S Pinnagoda EA 3050 final project")
print("WiFi attendance system")
import csv
import json
import sqlite3
from pathlib import Path
import paho.mqtt.client as mqtt
from datetime import datetime

# MQTT Settings 
now = datetime.now()
currentDateAndTime = now.strftime("%d%m%Y %H:%M:%S")
print("current date and time is ",currentDateAndTime)
print("#################")
MQTT_Broker = "phys.cmb.ac.lk"
MQTT_Port = 1883
Keep_Alive_Interval = 45
MQTT_Topic = "crowdtrace/#"
DB_Name =currentDateAndTime+".db"
print("Saved data base name :-",DB_Name)

###########################
###########################


#####################
#####################


#Subscribe to all Sensors at Base Topic
def on_connect(mosq, obj,flags, rc):
	print("on connect")
	mqttc.subscribe(MQTT_Topic)
#Save Data into DB Table
def on_message(mosq, obj, msg):
	print("mqtt data recived")
	data=str(msg.payload.decode("utf-8"))
	print(data)
	try:
		crowdtraceDataHandler(data)
	except:
		pass
		
		
def on_subscribe(mosq, obj, mid, granted_qos):
 	print("on subscribe")
 	print("Subscription done to MQTT server waiting for data recived....")
 	pass
 	
#database manage class

class DatabaseManager():
	def __init__(self):
		
		self.conn = sqlite3.connect(DB_Name)
		self.conn.execute('pragma foreign_keys = on')
		self.conn.commit()
		self.cur = self.conn.cursor()
		
		
	def add_del_update_db_record(self, sql_query, args=()):
		self.cur.execute(sql_query, args)
		self.conn.commit()
		return

	def __del__(self):
		self.cur.close()
		self.conn.close()	
	
########################################
# Function to save data to DB Table
def crowdtraceDataHandler(jsonData):
	#Parse Data 
	json_Dict = json.loads(jsonData)
	
	node = json_Dict['node']
	macAddress = json_Dict['mac']
	rssi = json_Dict['rssi']
	packets = json_Dict['packets']
	net_tag = json_Dict['net_tag']
 
	##VALIDATE DATA BEFORE WRITE WTH USER DEFINED TABLE
	#print("validation ekata awa")
	
	
	conn = sqlite3.connect(DB_Name)
	curs = conn.cursor()
	print(macAddress)

	curs.execute("SELECT * FROM peopleData")
		
	datanew= curs.fetchall()
	#print(datanew)
	
	for row in datanew:
		#print(row[2])
		if row[2] == macAddress:
			#print("address equal")
				#Push into DB Table
			try:
				dbObj = DatabaseManager()
				dbObj.add_del_update_db_record("insert into attendanceData (mac,name,indexNo) values (?,?,?)",[macAddress,row[1],row[3]])
				del dbObj
				print ("Inserted crowdtrace Data into Database.")
				print ("")
			except:
				print("data set alredy in database")
				pass	
			
		

		
	#print(newdata)
	curs.close()
	conn.close()
	
	
	
		
	

		
########################################

# SQLite DB Name

# SQLite DB Table Schema
#change the table only get mac and name and index no
TableSchema="""
	
	 create table attendanceData(
  	 id integer primary key autoincrement,
  	 mac text unique,
  	 name text,
  	 indexNo text

  
	);

	""" 

#ton get all data written in database just delete unique in mac on TableSchama
#in here unique constant use for not duplicating data on database
#main program start here------------->>>>>>


	
################################################

	
#create db table
# SQLite DB Name
conn = sqlite3.connect(DB_Name)
curs = conn.cursor()
curs.executescript(TableSchema)
	
	
curs.close()
conn.close()
	
###############################################
#import csv file data to new table
#table to save user define peoples data from csv file
TablePeopleData="""
	 drop table if exists peopleData ;
	 create table peopleData(
	 id integer primary key autoincrement,
  	 name text,
  	 mac text,
  	 indexNo text
  	 
	);

	"""	
conn = sqlite3.connect(DB_Name)
curs = conn.cursor()
curs.executescript(TablePeopleData)	
print("tabel create done")
file = open("peoples data.csv")
print("fle open done")
content = csv.reader(file)
insertRecords="insert into peopleData (name,mac,indexNo) values( ?,?,?)"
curs.executemany(insertRecords, content)
print("csv data saved")
conn.commit()
curs.close()
conn.close()
	
################################################

##start listen mqtt data ------------->

mqttc=mqtt.Client()
# Assign event callbacks
mqttc.on_message = on_message
mqttc.on_connect = on_connect
mqttc.on_subscribe = on_subscribe

# Connect
mqttc.connect(MQTT_Broker, int(MQTT_Port), int(Keep_Alive_Interval))


########################################



mqttc.loop_forever()

