# TO-SQLHTTP-Server
An AutoHotkey scrip - SQLite api / HTTP Server front end for a TO Database generated from toutils/todbmanger:
  
  todbmanager - https://github.com/toutils/todbmanager

#######################################################


* You need to install AHKsock in AHK Lib:
  
    1.) AHKsock - https://github.com/jleb/AHKsock


* You need to install these in the A_ScriptDir:
 
    1.) sqlite-dll-{arch-version}.zip - https://sqlite.org/download.html
 
    2.) Class_SQLiteDB - https://github.com/AHK-just-me/Class_SQLiteDB
 
    3.) AHKhttp - https://github.com/zhamlin/AHKhttp


* Edit the SQLHTTP.ahk file.

    1.) Change the DBLoc line to the location of your to.db database file:

        DBLoc := "C:\TO_DB\todbmanager-0.3\to.db" ; Change to match the location name of your database as needed

* Run the SQLHTTP.ahk script. If you change nothing else in the SQLHTTP.ahk file, your api server will be at:

        http://127.0.0.1:8000/api/multi-attrs.php?ids={requesterid},{requesterid}

####
There is an addional SQLTables.ahk script to list all the names of the SQLite tables in to.db
