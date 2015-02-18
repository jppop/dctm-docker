dctm-docker - Documentum xCP running in containers
===========

The goal of this project is to have Documentum xCP running in [Docker (https://www.docker.com/)](http://) Containers, manly for a development purpose.

**Credits**  

Andrey Panfilov have done (may be as the first one) a [similar work](http://blog.documentum.pro/2014/08/09/docker-and-documentum-part-ii/). His work helps me a lot. 

**Disclaimers**  

Do not use (yet) this in production.

EMC, Documentum, the Documentum logos, Documentum and all other Documentum product and service names and logos are either service marks, trademarks, or registered trademarks of Documentum, a division of EMC Corporation.  

# Images
My first intention was to to create an image per components: 1 for the connection broker, 1 for the Content Server, JMS, BAM, etc.. Well, it's not possible :
- If the broker does not run on the same server as the content server, XMS Agent will fail to deploy applications (trying to connect to the cs, on port 1489).
- JMS will fail to connect if it doesn't run close to the CS.

So, I have created these images:
- oracle-xe : Oracle XE Database Server
- dctm-base: a base image holding the content server software.
- dctm-cs: the content server
- dctm-broker: a connection broker used to translate IP addresses (see below)
- dctm-xmsagent: the XMS Agent.
- dctm-xplore: the search server.
- dctm-bam, dctm-bps, dctm-ts: BAM, BPS and Thumbnail servers
- dctm-apphost: the application server.
- dctm-cis: CIS (comming soon)
- dctm-cts: CTS Server. Not yet. It could be possible ([see this post](https://community.emc.com/docs/DOC-37165)).

# The build

You will need a GIT client and Docker. And the software provided by Documentum (I can't include them with the sources). And a host with 16GB RAM.

The first thing to do, it's to clone the GIT repository:  
```
# git clone https://github.com/jppop/dctm-docker.git && cd dctm-docker
```
Then you need to add the software to the sources. See how to at the end of this document.  
Then, build all the images:
```bash
# ./build.sh
```

> You need to build all images only once. If you don't want each developer build himself the images, you could use docker export/import commands.  
> I choose to build all images on a Virtual Machine. Once built, I clone the VM and use the clone as a template.


# The run

After several minutes, all the Docker images are built. You get ready to start the containers.  

## The repository

### Repository Server
First, start Oracle and Content Server:  
```bash
# docker run -dP --name dbora -h dbora oracle-xe  
# docker run -dP -p 1489:1489 -p 49000:49000 --name dctm-cs -h dctm-cs --link dbora:dbora dctm-cs [--repo-name aname]  
```
The dctm-cs container install the Connection Broker (aka docbroker), the repository (name: devbox, unless you specify another name with the 'repository-name' option), and the JMS.  

> If you change the default repository name, you must then pass it to all the containers when they are created (docker run).  

For example: `docker run -dP -p 8010:8080 --name bps -h bps --link dctm-cs:dctm-cs`**`-e REPOSITORY_NAME=myrepo`** dctm-bps `

Wait for the end of the installation (about 45 minutes):  
```bash
# docker logs -f dctm-cs
```
You will see the logs of the setup program, then after few minutes, the log of the repository server.  
If you are not confident:
```
# docker exec -it dctm-cs bash
dctm-cs# cd $DM_HOME/install
dctm-cs# tail -f logs/install.log
dctm-cs# exit
```
### Translator Broker
Docker create a sub network and put all containers in this network. All containers are reachable through the host (Docker will redirect the request to the container, see Docker documentation for more information).  
This will not work with the docbroker. When a client request the connection information of a repository, the docbroker send it back the private IP address it knows, which the remote client cannot reach (see an [old post](http://www.bluefishgroup.com/2002/network-address-translation-for-docbrokers/) about this).  
So, we need a second docker to translate the private address into an 'outside' address (actually the host where Docker runs).  
It's done with:
```
# docker run -d -p 1589:1489 --name extbroker -h extbroker \
   --link dctm-cs:dctm-cs -e HOST_IP=<the host ip addr> dctm-broker
```
The container installs a docbroker performing IP translations (from the IP of dctm-cs to the IP of the host). It configure dynamically the content server by adding a new projection target.

Now, you can configure all you client (ie, dqMan or a Java DFC client) with the second docbroker information (dfc.properties):
```
dfc.docbroker.host[0]=<host ip>
dfc.docbroker.port[0]=1589
dfc.globalregistry.repository=devbox
dfc.globalregistry.username=dm_bof_registry
dfc.globalregistry.password=AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv}
```

## xCP Components

All remaining components are similary started:
```
# docker run -dP --name xplore -h xplore --link dctm-cs:dctm-cs dctm-xplore  
# docker run -dP -it --name da -p 7002:8080 --link dctm-cs:dctm-cs dctm-da  
# docker run -dP -p 8000:8080 --name bam -h bam --link dctm-cs:dctm-cs --link dbora:dbora dctm-bam  
# docker run -dP -p 8010:8080 --name bps -h bps --link dctm-cs:dctm-cs dctm-bps  
# docker run -dP -p 8020:8080 --name ts -h ts --link dctm-cs:dctm-cs dctm-ts dctm-ts  
# docker run -dP -p 8040:8080 --name apphost -h apphost --link dctm-cs:dctm-cs dctm-apphost  
# docker run -dP -p 7000:8080 --name xms -h xms --link dctm-cs:dctm-cs --link bam:bam --link xplore:xplore --link apphost:apphost dctm-xmsagent  
```
#### About Documentum Administrator.

You can run DA as a server (alway running) or as a service on demand:
```
# docker run --rm -it --name da -p 7002:8080 --link dctm-cs:dctm-cs dctm-da  
```

## XSM Agent

The hardest part of the job (at less, for me, I have spent several hours to get XMS running).  
Check the server it's started:
```
# docker logs -f xms
```
Wait for the message "INFO: server started in 3 hours!". I'm kidding. Not 3 hours, but on my laptop (a Macbook PRO, 16GB RAM, 500 GB SSD), the server starts in 10 minutes. On a VM hosted by an ESX Server, about 2-3 mn. So, don't use my laptop ;). 

### Initial configuration

All the xCP services must be configured (so, you will get you xCP application deployed by the XMS agent).  
Launch:
```
# docker run -it --rm --name xms-tools -h xms-tools --link xms:xms -e XMSINIT=true dctm-xmstools
```
The container set the default password (admin/adminPass1) and load some configuration files. Especially, the environment template **DockerFull-Template**. It's the template, you will use to create an environment.

### Final touch
You need now to create the environment and enter all the host name where the xCP components reside. Sorry, you have to do it manually. I swear, I've tried to script this, but I have failed. XMS Agent is too complicated for me.  
So, log into XMS agent : [http://docker-box:7000/xms-agent](http://devbox:7000/xms-agent) (sign in with admin/adminPass1) and play with it.  
1. Create a new environment based on the the template DockerFull-Template.  
2. Complete the service definitions:  
  - The default credentials are` admin/adminPass1`. Used in all components except for the repository : `dmadmin/dmadmin`.
  - use the containers DNS names (not the IP addresses). The DNS name is the one given with the '-h' option with the docker run command.
  - use the containers DNS names (not the IP addresses). The DNS name is the one given with the '-h' option with then docker run command.
  - The port used for all Tomcat based application is 8080.
  - The SearchService use the default ports (9200 & 9300)
3. Synchronize the environment once you finished to enter all the parameters. DO NOT VALIDATE the environnment (a bug in XMS). The synchronization may be long (5 mn). The environnment must be in the state Provisionned when the synchronization terminates.

You should have this environment:
![xms env](https://github.com/jppop/dctm-docker/image/xms-env.png)

Voilà! You, lucky dev. guy, you are ready to deploy your first application. Use xCP Designer or xms tools:
```
# docker run -it --rm --name xms-tools -h xms-tools --link xms:xms -v /Users/jfrancon:/shared dctm-xmstools bash
xmstools # cd bin
xmstools # ./xms -u admin -P adminPass1 -f /shared/my-deploy.script
xmstools # exit
```
See the XMS documention about how to deploy an application.

# Starting, Stopping, Monitoring
You are now in the Docker world. Starting a service is done with `docker start <container>`. Stopping it with `docker stop <container>`.

So, start the whole environment:
```
# docker start dbora dctm-cs extbroker
# docker start bam xplore xms bps da
```
Stop them in the reverse order:
```
# docker stop bam xplore xms bps da
# docker stop extbroker dctm-cs dbora
```
I'sure you will find how to daemonize the containers.

Use `docker logs` to access the log files. Open a shell: `docker exec -it <container> bash`.

Enjoy!

# Next

Thing I planned to do:
- [ ] Back up / restore script using a container (and the volume sharing of docker)
- [ ] A xCP designer box (including maven, svn or git and xms tools) to automate the build.
- [ ] CIS image.
- [ ] CTS image (maybe)

# ISSUES

### DM_DOCBROKER_E_ID_ALREADY_REGISTERED  
If you run a new dctm-cs container using a broker already used (ie, a previously content server has already registered a repo to the connection broker), you will probably run into an issue. Prefer running again the broker too (and dbora):  
```bash
docker stop dctm-cs broker dbora  
docker rm dctm-cs broker dbora  
# start new fresh containers...
```
### XMS Agent and 'standalone' Docbroker
It seems that xms agent does not support a connection broker not running on the same server than the content server. Why ?

# MISC.
### Documentum distribution software
**./dctm-bam/bundles:**  
```
bam-server.war
```
**./dctm-base/bundles/patch:**  
```
CS_7.1.0090.0213_linux_ora.tar.gz
patch.bin
```
**./dctm-base/bundles:**  
```
Content_Server_7.1_linux64_oracle.tar
```
**./dctm-base/bundles/dars:**  
```
BPM.dar
CTSActivity.dar
CTSAspects.dar
CollaborationServices.dar
DcsAttachment.dar
Forms.dar
ImageServices.dar
Rich_Media_Services.dar
TCMReferenceProject.dar
Transformation.dar
xCP_Viewer_Services.dar
xcp.dar
```
**./dctm-bps/bundles:**  
```
bps.war
```
**./dctm-cs/bundles:**  
```
Process_Engine_linux.tar
oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm
oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm
oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm
```
**./dctm-da/bundles:**  
```
da.war
```
**./dctm-ts/bundles:**  
```
Thumbnail_Server_7.1_linux.tar
```
**./dctm-xmsagent/bundles:**
```
xms-agent-1.1-P13.zip
```
**./dctm-xmstools/bundles:**  
```
xms-tools-1.2.zip
```
**./dctm-xplore/bundles:**  
```
xPlore_1.4_linux-x64.tar
```

