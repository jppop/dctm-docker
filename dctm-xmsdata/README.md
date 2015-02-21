xMS data container
===========

Each new environment needs to be registered to xMS agent. It's done manually through the xMS admin console.  
I can't figure out how to script the enndpoints settings. So, I have started exploring a new way: build an xms agent image with a prepopulated database (xDB).

It's there that Docker can help us. Drocker provides [Data Volume Container](https://docs.docker.com/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container).

I have create a Docker image containing the xMS data copied after the first registration.  
And now, just create the data container and share it with xms:
```
# docker create --name dctm-xmsdata dctm-xmsdata
# docker run -dP -p 7000:8080 --volumes-from dctm-xmsdata --name xms -h xm \
   --link dctm-cs:dctm-cs --link bam:bam --link xplore:xplore --link apphost:apphost dctm-xmsagent
```

You can notice the option **`--volumes-from dctm-xmsdata`**. It's the way you share volumes with Docker.

So, no more manual task. Except if you changed the repository name. You have to update the xMS environment (edit the Repository service, then the repository endpoint).