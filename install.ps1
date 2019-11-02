
Write-Output "Removing previous erlang versions..."
Get-ChildItem -Path 'C:\Program Files\erl*\Uninstall.exe' | %{ Start-Process -Wait -NoNewWindow -FilePath $_ -ArgumentList '/S' }

Write-Output "Creating erlang cookie..."
[System.IO.File]::WriteAllText("C:\Users\appveyor\.erlang.cookie", "rabbitmq", [System.Text.Encoding]::ASCII)
[System.IO.File]::WriteAllText("C:\Windows\System32\config\systemprofile\.erlang.cookie", "rabbitmq", [System.Text.Encoding]::ASCII)

Write-Output "Installing RabbitMQ..."
choco install rabbitmq -y --version=$env:RABBITMQ_VERSION
refreshenv

Invoke-WebRequest "https://raw.githubusercontent.com/pika/pika/master/testdata/wait-epmd.ps1" -OutFile "wait-epmd.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/pika/pika/master/testdata/wait-rabbitmq.ps1" -OutFile "wait-rabbitmq.ps1"

$env:erlang_erts_version=$env:ERTS_VERSION
$env:rabbitmq_version=$env:RABBITMQ_VERSION

Write-Output "Waiting for EPMD..."
.\wait-epmd.ps1
Write0Output "Waiting for RabbitMQ..."
.\wait-rabbitmq.ps1

Write-Output ""

