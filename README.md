# TO-SQLHTTP-Server
An api for reading stats table from to.db

http://127.0.0.1:8000/api/multi-attrs.php?ids=?{requesterid}

Need to install AHKsock in AHK Lib:
  
  AHKsock - https://github.com/jleb/AHKsock


Need to install the following in A_ScriptDir:
 
 1.) sqlite-dll-{arch-version}.zip - https://sqlite.org/download.html
 
 2.) Class_SQLiteDB - https://github.com/AHK-just-me/Class_SQLiteDB
 
 3.) AHKhttp - https://github.com/zhamlin/AHKhttp


Edit the SQLHTTP.ahk file.

  Change the line to the location name of your to.db database file:

DBLoc := "C:\TO_DB\todbmanager-0.3\to.db" ; Change to match the location name of your database as needed

Run the SQLHTTP.ahk script. If you change nothing else in the SQLHTTP.ahk file, your api server will be at:

http://127.0.0.1:8000/api/multi-attrs.php?ids={requesterid},{requesterid}

