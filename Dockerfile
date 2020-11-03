# escape=`
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019

ENV AZP_URL=https://dev.azure.com/allan05
ENV AZP_WORK=c:\azp\_work
ENV AZP_POOL=aks-windows

ENV ADO_AGENT_URL=https://vstsagentpackage.azureedge.net/agent/2.172.2/vsts-agent-win-x64-2.172.2.zip
ENV ANT_URL=http://mirrors.advancedhosters.com/apache//ant/binaries/apache-ant-1.10.8-bin.zip
ENV AZ_COPY_URL=https://aka.ms/downloadazcopy-v10-windows
ENV CLOUD_FOUNDRY_CLI_URL=https://packages.cloudfoundry.org/stable?release=windows64-exe&source=github
ENV CMAKE_URL=https://github.com/Kitware/CMake/releases/download/v3.18.1/cmake-3.18.1-win64-x64.msi
ENV CURL_URL=https://curl.haxx.se/windows/dl-7.71.1/curl-7.71.1-win64-mingw.zip
ENV GCLOUD_SDK_URL=https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe
ENV GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.28.0.windows.1/Git-2.28.0-64-bit.exe
ENV GO_URL=https://golang.org/dl/go1.14.6.windows-amd64.msi
ENV GRADLE_URL=https://services.gradle.org/distributions/gradle-6.5.1-all.zip
ENV HELM3_URL=https://get.helm.sh/helm-v3.2.4-windows-amd64.zip
ENV JDK_URL=https://download.oracle.com/otn-pub/java/jdk/14.0.2+12/205943a0976c4ed48cb16f1043c5c647/jdk-14.0.2_windows-x64_bin.exe
ENV JQ_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe
ENV KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/windows/amd64/kubectl.exe
ENV MAVEN_URL=https://mirror.olnevhost.net/pub/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.zip
ENV MYSQL_URL=https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell-8.0.21-windows-x86-64bit.zip
ENV NODEJS_URL=https://nodejs.org/dist/v12.18.3/node-v12.18.3-x64.msi
ENV PACKER_URL=https://releases.hashicorp.com/packer/1.6.1/packer_1.6.1_windows_amd64.zip
ENV PYTHON3_URL=https://www.python.org/ftp/python/3.8.5/python-3.8.5.exe
ENV RUBY_URL=https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.1-1/rubyinstaller-2.7.1-1-x64.exe
ENV SALESFORCE_CLI_URL=https://developer.salesforce.com/media/salesforce-cli/sfdx-windows-amd64.exe
ENV TERRAFORM_URL=https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_windows_amd64.zip
ENV VAULT_URL=https://releases.hashicorp.com/vault/1.5.0/vault_1.5.0_windows_amd64.zip

SHELL ["powershell", "-Command", "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue';"]

RUN mkdir C:\azp; `
    mkdir C:\bin; `
    mkdir C:\TEMP

# ADO Agent
RUN Invoke-WebRequest -Uri $env:ADO_AGENT_URL -OutFile C:\azp\vsts-agent-win.zip; `
    Expand-Archive -Path C:\azp\vsts-agent-win.zip -DestinationPath C:\azp\agent; `
    Remove-Item -Path C:\azp\vsts-agent-win.zip -Force

# Ant
RUN Invoke-WebRequest -Uri $env:ANT_URL -OutFile C:\TEMP\ant.zip; `
    Expand-Archive -Path C:\TEMP\ant.zip -DestinationPath C:\; `
    cd C:\apache-ant-*; `
    $d = pwd; `
    cd /; `
    Rename-Item -Path $d -NewName C:\ant
    
# AzCopy
RUN Invoke-WebRequest $env:AZ_COPY_URL -OutFile C:\TEMP\azcopyv10.zip; `
    Expand-Archive -Path C:\TEMP\azcopyv10.zip -DestinationPath C:\TEMP; `
    cd C:\TEMP\azcopy*; `
    cp azcopy.exe c:\bin

# Azure CLI
RUN Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile C:\TEMP\AzureCLI.msi; `
    Start-Process msiexec.exe -Wait -ArgumentList '/I C:\TEMP\AzureCLI.msi /quiet'

# Cloud Foundry CLI
RUN Invoke-WebRequest -Uri $env:CLOUD_FOUNDRY_CLI_URL -OutFile C:\TEMP\cf_cli.zip; `
    Expand-Archive -Path C:\TEMP\cf_cli.zip -DestinationPath C:\bin

# Cmake
RUN Invoke-WebRequest -Uri $env:CMAKE_URL -OutFile C:\TEMP\cmake.msi; `
    Start-Process -FilePath C:\TEMP\cmake.msi -Wait

# Curl
RUN Invoke-WebRequest -Uri $env:CURL_URL -OutFile C:\TEMP\curl.zip; `
    Expand-Archive -Path C:\TEMP\curl.zip -DestinationPath C:\; `
    cd C:\curl-*; `
    $d = pwd; `
    cd /; `
    Rename-Item -Path $d -NewName C:\curl

# Docker
RUN Install-PackageProvider -Name NuGet -Force; `
    Install-Module -Name DockerMsftProvider -Repository PSGallery -Force; `
    Install-Package -Name docker -ProviderName DockerMsftProvider -Force

# Dotnet Core
RUN Invoke-WebRequest -Uri https://dot.net/v1/dotnet-install.ps1 -OutFile C:\TEMP\dotnet-install.ps1; `
    C:\TEMP\dotnet-install.ps1 -Channel Current -Runtime dotnet
   
# GCloud SDK
RUN Invoke-WebRequest -Uri $env:GCLOUD_SDK_URL -OutFile C:\Temp\GoogleCloudSDKInstaller.exe; `
    cmd /c start /wait C:\Temp\GoogleCloudSDKInstaller.exe /S

# Git
RUN Invoke-WebRequest -Uri $env:GIT_URL -OutFile C:\TEMP\git.exe; `
    Start-Process -FilePath C:\TEMP\git.exe -ArgumentList "/SILENT" -Wait

# Go
RUN Invoke-WebRequest -Uri $env:GO_URL -OutFile C:\TEMP\go.msi; `
    Start-Process -FilePath C:\TEMP\go.msi -ArgumentList "/quiet" -Wait

# Gradle
RUN Invoke-WebRequest -Uri $env:GRADLE_URL -OutFile C:\TEMP\gradle.zip; `
    Expand-Archive -Path C:\TEMP\gradle.zip -DestinationPath C:\; `
    cd C:\gradle-*; `
    $d = pwd; `
    cd /; `
    Rename-Item -Path $d -NewName C:\gradle

# Helm 3
RUN Invoke-WebRequest -Uri $env:HELM3_URL -OutFile C:\TEMP\helm3.zip; `
    Expand-Archive -Path C:\TEMP\helm3.zip -DestinationPath C:\TEMP; `
    cd C:\TEMP\windows-amd64; `
    mv helm.exe C:\bin

# Java Development Kit
COPY jdk.ps1 C:\TEMP\jdk.ps1
RUN C:\TEMP\jdk.ps1

# Jq
RUN Invoke-WebRequest -Uri $env:JQ_URL -OutFile C:\bin\jq.exe

# Kubectl
RUN Invoke-WebRequest -Uri $env:KUBECTL_URL -OutFile C:\bin\kubectl.exe

# Maven
RUN Invoke-WebRequest -Uri $env:MAVEN_URL -OutFile C:\TEMP\maven.zip; `
    Expand-Archive -Path C:\TEMP\maven.zip -DestinationPath C:\; `
    cd C:\apache-maven-*; `
    $d = pwd; `
    cd /; `
    Rename-Item -Path $d -NewName C:\maven
 
# MySQL Shell
RUN Invoke-WebRequest -Uri $env:MYSQL_URL -OutFile C:\TEMP\mysql-shell.zip; `
    Expand-Archive -Path C:\TEMP\mysql-shell.zip -DestinationPath C:\; `
    cd mysql-shell-*; `
    $d = pwd; `
    cd /; `
    Rename-Item -Path $d -NewName C:\mysql-shell

# Node Js
RUN Invoke-WebRequest -Uri $env:NODEJS_URL -OutFile C:\TEMP\node.msi; `
    Start-Process msiexec.exe -Wait -ArgumentList '/I C:\TEMP\node.msi /qn'

# Packer
RUN Invoke-WebRequest -Uri $env:PACKER_URL -OutFile C:\TEMP\packer.zip; `
    Expand-Archive -Path C:\TEMP\packer.zip -DestinationPath C:\bin

# Python 3
RUN Invoke-WebRequest -Uri $env:PYTHON3_URL -OutFile C:\TEMP\python3.exe; `
    cmd /c start /wait C:\TEMP\python3.exe /quiet TargetDir=C:\Python36-x64 Include_exe=1 Include_pip=1 Include_lib=1 Include_test=1; `
    C:\Python36-x64\Scripts\pip install requests kubernetes numpy pandas pyyaml

# Ruby
RUN Invoke-WebRequest -Uri $env:RUBY_URL -OutFile C:\TEMP\ruby.exe; `
    cmd /c start /wait C:\TEMP\ruby.exe /tasks="assocfiles,modpath" /silent"

# Salesforce CLI
RUN Invoke-WebRequest -Uri $env:SALESFORCE_CLI_URL -OutFile C:\TEMP\sf_cli.exe; `
    Start-Process -FilePath C:\Temp\sf_cli.exe -ArgumentList "/S" -Wait

# Telnet
RUN dism /online /Enable-Feature /FeatureName:TelnetClient

# Terraform
RUN Invoke-WebRequest -Uri $env:TERRAFORM_URL -OutFile C:\TEMP\terraform.zip; `
    Expand-Archive -Path C:\TEMP\terraform.zip -DestinationPath c:\bin

# Vault
RUN Invoke-WebRequest -Uri $env:VAULT_URL -OutFile C:\TEMP\vault.zip; `
    Expand-Archive -Path C:\TEMP\vault.zip -DestinationPath c:\bin

# Visual Studio 2019 Build Tools
SHELL ["cmd", "/S", "/C"]
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe
RUN C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --installPath C:\BuildTools `
    --add Microsoft.VisualStudio.Workload.AzureBuildTools `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
    --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
    --remove Microsoft.VisualStudio.Component.Windows81SDK `
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

RUN rmdir /Q /S C:\TEMP

WORKDIR C:\azp

RUN echo #{ado-pat}# > C:\azp\token

COPY start.ps1 C:\azp\start.ps1

RUN setx /M PATH "C:\bin;C:\ant\bin;C:\gradle\bin;C:\maven\bin;C:\mysql-shell\bin;C:\Program Files\CMake\bin;C:\curl\bin;C:\Python36-x64;C:\Python36-x64\Scripts;%PATH%"
RUN setx /M ANT_HOME "C:\ant"
RUN setx /M GRADLE_HOME "C:\gradle"
RUN setx /M MAVEN_HOME "C:\maven"

ENTRYPOINT C:\BuildTools\Common7\Tools\VsDevCmd.bat && powershell.exe -ExecutionPolicy Bypass C:\azp\start.ps1
