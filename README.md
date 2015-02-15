dctm-docker
===========

Documentum running in containers

**ALPHA RELEASE**

# REMINDERS:

```bash
docker run -dP --name dbora -h dbora oracle-xe  
docker run -dP --name broker -h broker dctm-broker  
docker run -dP --name dctm-cs -h dctm-cs --link dbora:dbora --link broker:broker dctm-cs  
docker run -d --name jms --link broker:broker -h dctm-jms dctm-jms 
docker run -dP -it --name xplore -h xplore --link broker:broker dctm-xplore    
docker run --rm -it --name da -p 8888:8080 --link broker:broker --link dctm-cs:dctm-cs dctm-da  
docker run -dP -p 8000:8080 --name bam -h bam --link broker:broker --link dbora:dbora dctm-bam  
docker run -dP -p 8040:8080 --name bps -h bps --link broker:broker dctm-bps  
docker run -dP -p 7000:8080 --name xms -h xms --link broker:broker --link dctm-cs:dctm-cs --link dbora:dbora --link bam:bam --link xplore:xplore dctm-xmsagent  

```

# ISSUES

### DM_DOCBROKER_E_ID_ALREADY_REGISTERED  
If you run a new dctm-cs container using a broker already used (ie, a previously content server has already registered a repo to the connection broker), you will probably run into an issue. Prefer running again the broker too (and dbora):  
```bash
docker stop dctm-cs broker dbora  
docker rm dctm-cs broker dbora  
# start new fresh containers...
```
