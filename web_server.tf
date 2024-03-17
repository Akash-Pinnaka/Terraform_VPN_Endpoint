# 8. Create the server instances
resource "aws_instance" "web-server-instance" {
  ami                    = var.ami_windows
  instance_type          = var.instance_type_windows
  availability_zone      = var.availability_zone
  subnet_id              = aws_subnet.Public-VPC-01.id
  vpc_security_group_ids = [aws_security_group.webserver_SG.id]
  key_name               = aws_key_pair.key-pair.key_name
  get_password_data      = true

  user_data = <<-EOT
              <powershell>
              $interfaces = Get-NetAdapter
              foreach ($interface in $interfaces) { $interface | Set-DnsClientServerAddress -ServerAddresses ("$($interface | Get-DnsClientServerAddress | Select-Object -ExpandProperty ServerAddresses)", "8.8.8.8") }
              # Request elevated privileges
              if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
              Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
              exit
              }
              
              # Install Chocolatey (package manager for Windows)
              Set-ExecutionPolicy Bypass -Scope Process -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

              # Install Node.js using Chocolatey
              choco install -y nodejs

              # Create a directory for the Express.js app
              mkdir C:\app
              cd C:\app

              # Create a simple Express.js server
              Add-Content -Path 'C:\app\server.js' -Value @"
              const express = require('express');
              const app = express();

              app.get('/', (req, res) => {
                res.send('Hello, Express.js!');
              });

              app.listen(${var.expressJS_port}, () => {
                console.log('Server is running on port ${var.expressJS_port}');
              });
              "@

              # Install Express.js dependency
              npm install express
              
              # Create a new inbound firewall rule to allow traffic on port 3000
              New-NetFirewallRule -DisplayName "Allow Port ${var.expressJS_port}" -Direction Inbound -LocalPort ${var.expressJS_port} -Protocol TCP -Action Allow
              
              # Run the Express.js server
              node server.js
              </powershell>
              EOT

  tags = {
    Name = "Windows-server-${random_pet.Random_pet[1].id}"
  }
}
