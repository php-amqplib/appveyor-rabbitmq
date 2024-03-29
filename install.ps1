Write-Output "Removing previous erlang versions..."
Get-ChildItem -Path 'C:\Program Files\erl*\Uninstall.exe' | %{ Start-Process -Wait -NoNewWindow -FilePath $_ -ArgumentList '/S' }
refreshenv

Write-Output "Creating erlang cookie..."
[System.IO.File]::WriteAllText("C:\Users\appveyor\.erlang.cookie", "rabbitmq", [System.Text.Encoding]::ASCII)
[System.IO.File]::WriteAllText("C:\Windows\System32\config\systemprofile\.erlang.cookie", "rabbitmq", [System.Text.Encoding]::ASCII)

Write-Output "Installing RabbitMQ..."
choco install rabbitmq -y --no-progress --version=$env:RABBITMQ_VERSION --package-parameters='"/NOMANAGEMENT"'
refreshenv
$env:ERLANG_HOME="c:\program files\erl$env:ERLANG_VERSION"

$env:RABBITMQ_BIN="C:\Program Files\RabbitMQ Server\rabbitmq_server-$env:RABBITMQ_VERSION\sbin"

Write-Output "Enable management plugin..."
Start-Process "$env:RABBITMQ_BIN\rabbitmq-plugins.bat" 'enable --online rabbitmq_management' -NoNewWindow -Wait

Invoke-WebRequest "https://raw.githubusercontent.com/pika/pika/master/testdata/wait-epmd.ps1" -OutFile "wait-epmd.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/pika/pika/master/testdata/wait-rabbitmq.ps1" -OutFile "wait-rabbitmq.ps1"

$env:erlang_erts_version="erts-$env:ERLANG_VERSION"
$env:rabbitmq_version=$env:RABBITMQ_VERSION

Write-Output "Waiting for EPMD..."
.\wait-epmd.ps1
Write-Output "Waiting for RabbitMQ..."
.\wait-rabbitmq.ps1

Write-Output "Installed and running."
