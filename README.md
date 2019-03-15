# TO-SQLHTTP-Server
TOSQLHTTP.ahk - An AutoHotkey script with an SQLite HTTP Server.


* Provides HTTP access to the stats Table for a to.db from toutils/todbmanger:


      todbmanager - https://github.com/toutils/todbmanager

* Mimics the output from:

      https://turkopticon.ucsd.edu/api/multi-attrs.php?ids=requesterid


################################################################


Installation:


* Download AHKsock from https://github.com/jleb/AHKsock
      Unzip AHKsock.ahk into the AHK Standard Library or the AHK User Library - Documents\AutoHotkey\Lib:
      

* Download AHKhttp from https://github.com/zhamlin/AHKhttp
      Unzip the following files into the TOSQLHTTP.ahk script directory:
            AHKhttp.ahk
            logo.png
            mime.types
              

 * Download Class_SQLiteDB from https://github.com/AHK-just-me/Class_SQLiteDB
      Unzip Class_SQLiteDB.ahk into the TOSQLHTTP.ahk script directory
 
 
 * Download Precompiled Binaries for Windows: sqlite-dll-{arch-version}.zip from https://sqlite.org/download.html
      Unzip sqlite3.dll into the TOSQLHTTP.ahk script directory
 
      
* Edit the TOSQLHTTP.ahk file and change the DBLoc to the location of your to.db database file:

        DBLoc := "C:\TO_DB\todbmanager-0.3\to.db" ; Change to match the location name of your database as needed


* Run the TOSQLHTTP.ahk script and the HTTP server will be located at URL:

        http://127.0.0.1:8000/api/multi-attrs.php?ids=requesterid


################################################################


TOSQLTables.ahk - A script to display the names of the SQL tables in a to.db

* Edit the TOSQLTables.ahk file and change the DBLoc to the location of your to.db database file:

        DBLoc := "C:\TO_DB\todbmanager-0.3\to.db" ; Change to match the location name of your database as needed


################################################################
