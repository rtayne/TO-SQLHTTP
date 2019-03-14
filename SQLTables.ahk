#NoEnv
#SingleInstance force
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1

db := new SQLiteDB
DBLoc := "C:\TOdb\todbmanager-0.3\to.db" ; Change to match the name of your database as needed
DBAccess := "R" ; Open db Readonly
db.OpenDB(DBLoc, DBAccess)

TableLookup := "select name from sqlite_master where type='table';" ; This will produce a list of all tables in the Database
DB.GetTable(TableLookup, Result)
loop % Result.RowCount
{
I := a_index ; Set the row value for each row loop
     loop % Result.ColumnCount
          {
          msgbox % "Table Name: " . Result.Rows[I, a_index] ; show the name of each table in the database
          }
}
db.CloseDB()

exitApp

#Include %A_ScriptDir%\Class_SQLiteDB.ahk
