# Info
These files build the Windows Azure Devops build agent.  

## Manual building
This project is intended for Azure Devops Pipelines to build the Docker image, however it could be built manually.  If doing a manual build, you would need to replaced the PAT token in the Dockerfile with a valid token to connect to ADO.<br>
<pre>
git clone https://github.com/ataylor05/Docker.ADO.Build.Agents.git
cd Docker.ADO.Build.Agents\Windows
docker build -t ado-windows-agent:1.0 Dockerfile-2016
</pre>

# Docker in Docker
The Docker process on the Kubernetes hosts are being shared with the agent pods so that the pods are able to use the Docker engine.  This is done via the Kubernetes deloyment manifest by sharing a named pipe.  It's possible to also share the named pipe via Docker.  **Sharing named pipes does not work in Windows Server 2016**.<br>
<pre>
docker run -d --restart always -v \\.\pipe\docker_engine:\\.\pipe\docker_engine ado-windows-agent:1.0
</pre>

## Docker CLI for Windows
The Docker CLI needs to be deployed into the container in order to interact with the Docker engine via the named pipe.  At the time of this writing there is not an installation package for the Docker CLI on Windows.  The Docker Desktop app will fail due to its dependency on Hyper-V.  The solution to this problem that I have come up with is to compile a Windows binary from the Docker CLI github page.  The docker-windows-amd64.exe is a compiled version of the Docker CLI from this [GitHub Repo](https://github.com/docker/cli)<br>
**Requires Linux make program**<br>
<pre>
git clone https://github.com/docker/cli.git
cd cli
make -f docker.Makefile binary-windows
</pre>

## Docker on Windows Server 2016
Installing Docker
<pre>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name Docker -ProviderName DockerMsftProvider -Force
Restart-Computer -Force
</pre><br><br>

Configure Docker daemon
<pre>
C:\ProgramData\Docker\config\deamon.json

{
    "dns": [],
    "data-root": "",
    "debug": true,
    "hosts": ["tcp://0.0.0.0:2375", "npipe://"],
    "group": "Users"
}
</pre><br><br>

Restart service
<pre>
Restart-Service -Name "Docker Engine"
</pre><br><br>

Set proxy on 2375
<pre>
netsh interface portproxy add v4tov4 listenport=2375 connectaddress=127.0.0.1 connectport=2375 listenaddress=<HOST_IP> protocol=tcp
</pre>

## Running containers locally
<pre>
docker container run -d --restart always ado-windows-agent:1.0
</pre>

## Running services in Swarm mode
<pre>
docker stack deploy --compose-file docker-compose.yaml --with-registry-auth AdoAgent
</pre>
