##mqtt server data log to sqlite DB file by P.G.A.S Pinnagoda EA3050 Final project

import csv
import json
import sqlite3
from pathlib import Path
import paho.mqtt.client as mqtt

# MQTT Settings 
MQTT_Broker = "192.168.8.100"
MQTT_Port = 1883
Keep_Alive_Interval = 45
MQTT_Topic = "crowdtrace/#"
DB_Name =  "crowd.db"
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
	crowdtraceDataHandler(data)

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
	#print("qsdsa",json_Dict)
	#if json_Dict!=1 or json_Dict!=2 or json_Dict!=3:
	node = json_Dict['node']
	mac = json_Dict['mac']
	rssi = json_Dict['rssi']
	packets = json_Dict['packets']
	net_tag = json_Dict['net_tag']

		
	
	#Push into DB Table
	try:
		dbObj = DatabaseManager()
		dbObj.add_del_update_db_record("insert into crData (node,mac, rssi, packets, net_tag) values (?,?,?,?,?)",[node, mac, rssi, packets, net_tag])
		del dbObj
		print ("Inserted crowdtrace Data into Database.")
		print ("")
	except:
		print("data set alredy in database")
		pass	
########################################

# SQLite DB Name
DB_Name =  "crowd.db"
# SQLite DB Table Schema
TableSchema="""
	 drop table if exists crData ;
	 create table crData(
  	 id integer primary key autoincrement,
  	 node text,
  	 mac text unique,
  	 rssi text,
  	 packets text,
  	 net_tag text
  
	);

	"""	
#in here unique constant use for not duplicating data on database
#main program start here------------->>>>>>


path_to_file = 'crowd.db' #database file name or path
path = Path(path_to_file)

if path.is_file():# to check DB file exist or not
	print("The databse file exists")
else:
	print("The file {path_to_file} does not exist create new DB file..")
	
################################################

	
#create db table
# SQLite DB Name
	DB_Name =  "crowd.db"
	conn = sqlite3.connect(DB_Name)
	curs = conn.cursor()
	curs.executescript(TableSchema)
	
	
	curs.close()
	conn.close()
	
###############################################
#import csv file data to new table

TablePeopleData="""
	 drop table if exists peopleData ;
	 create table peopleData(
  	 name text,
  	 indexNo text,
  	 mac text unique
  	 
	);

	"""	
conn = sqlite3.connect(DB_Name)
curs = conn.cursor()
curs.executescript(TablePeopleData)	
print("tabel create done")
file = open("test.csv")
print("fle open done")
content = csv.reader(file)
insertRecords="insert into peopleData (name,indexNo,mac) values( ?,?,?)"
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

