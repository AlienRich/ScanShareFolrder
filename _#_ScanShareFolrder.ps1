###	清查share資料夾全部權限

$computer=Get-Content .\_@_Serverlist.txt 
$OutFile = ".\ShareFolderList.csv" 

foreach ($comp in $computer){ 
$shares=Get-WmiObject -Class win32_share -ComputerName $comp | Where-Object {(@('Remote Admin','Default share','Remote IPC','預設共用','遠端 IPC','遠端管理') -notcontains $_.Description)} 
$paths=$shares | Select path,Name 

foreach($path in $paths) { 
$fpath = $path.path.Replace(':\','$\') 
$SName = $path.name 
$RootPath = "\\" + $comp + "\" + $fpath 

Get-childitem $RootPath -Recurse -Depth 3| where{$_.psiscontainer} | 	####	Depth 3 等於三層子目錄
Get-Acl | % { 
$path = $_.Path 
$_.Access | % { 
New-Object PSObject -Property @{ 
Folder = $path.Replace("Microsoft.PowerShell.Core\FileSystem::","")
Access = $_.FileSystemRights 
User = $_.IdentityReference 
Control = $_.AccessControlType 
Computer = $comp 
SName = $SName 
} 
} 
} | select-object -Property Computer, SName, Folder, User, Control, Access | export-csv $OutFile -force -NoTypeInformation -encoding default -Append 
} 
}