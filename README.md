dctm-docker
===========

Documentum running in containers

**ALPHA RELEASE**

# REMINDERS:

```bash
docker run -dP --name dbora -h dbora oracle-xe  
docker run -dP --name dctm-cs -h dctm-cs --link dbora:dbora dctm-cs  
docker run -dP -it --name xplore -h xplore --link dctm-cs:dctm-cs dctm-xplore    
docker run --rm -it --name da -p 7002:8080 --link dctm-cs:dctm-cs dctm-da  
docker run -dP -p 8000:8080 --name bam -h bam --link dctm-cs:dctm-cs --link dbora:dbora dctm-bam  
docker run -dP -p 8010:8080 --name bps -h bps --link dctm-cs:dctm-cs dctm-bps  
docker run -dP -p 8020:8080 --name ts -h ts --link dctm-cs:dctm-cs dctm-ts dctm-ts  
docker run -dP -p 8040:8080 --name apphost -h apphost --link dctm-cs:dctm-cs dctm-apphost  
docker run -dP -p 7000:8080 --name xms -h xms --link dctm-cs:dctm-cs --link bam:bam --link xplore:xplore --link apphost:apphost dctm-xmsagent  

```

# ISSUES

### DM_DOCBROKER_E_ID_ALREADY_REGISTERED  
If you run a new dctm-cs container using a broker already used (ie, a previously content server has already registered a repo to the connection broker), you will probably run into an issue. Prefer running again the broker too (and dbora):  
```bash
docker stop dctm-cs broker dbora  
docker rm dctm-cs broker dbora  
# start new fresh containers...
```
