Catalog - Software used to build the images
===========

When you build an image that need packages from Documentum or Oracle, the packages must be placed in the subdirectory `bundles`.

You may choose any solution to distribute the packages (shared network drive, fp, http file server, ...).

I choose the simpliest: the packages are stored on my local disk and I have a script to copy them to the right place.

The catalog layout:
![catalog 1](https://raw.githubusercontent.com/jppop/dctm-docker/master/image/catalog-part1.png)
![catalog 1](https://raw.githubusercontent.com/jppop/dctm-docker/master/image/catalog-part2.png)

And the script `install.sh`:
```bash
SOURCE=./distrib
# the root folder of the dctm-docker project
TARGET=..

echo "Copying BAM bundle"
cp $SOURCE/documentum/bam/2.1/bam-server.war $TARGET/dctm-bam/bundles/

echo "Copying BPS bundle"
cp $SOURCE/documentum/bps/2.1/bps.war $TARGET/dctm-bps/bundles/

...
```
