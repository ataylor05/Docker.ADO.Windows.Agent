[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$source = "$env:JDK_URL"
$destination = "C:\jdk.exe"
$client = new-object System.Net.WebClient
$cookie = "oraclelicense=accept-securebackup-cookie"
$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie)
$client.downloadFile($source, $destination)
cmd /c start /wait c:\jdk.exe /s
cd "C:\Program Files\Java"
cd jdk-*
$d = pwd
setx /M PATH "$d\bin;$env:Path"
setx /M JAVA_HOME "$d"
Remove-Item -Path C:\jdk.exe -Force
