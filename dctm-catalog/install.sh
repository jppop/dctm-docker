#!/bin/bash

SOURCE=./distrib
# the root folder of the dctm-docker project
TARGET=..

echo "Copying BAM bundle"
cp $SOURCE/documentum/bam/2.1/bam-server.war $TARGET/dctm-bam/bundles/

echo "Copying BPS bundle"
cp $SOURCE/documentum/bps/2.1/bps.war $TARGET/dctm-bps/bundles/

echo "Copying Content Server bundle"
cp $SOURCE/documentum/content-server/7.1/Content_Server_7.1_linux64_oracle.tar $TARGET/dctm-base/bundles/
cp $SOURCE/documentum/content-server/7.1/CS_7.1.0090/*.* $TARGET/dctm-base/bundles/patch/

echo "Copying Repository bundle"
cp -r $SOURCE/documentum/content-server/7.1/dars $TARGET/dctm-cs/bundles/dars
cp $SOURCE/documentum/process-engine/2.1/Process_Engine_linux.tar $TARGET/dctm-cs/bundles/
cp $SOURCE/oracle/11.2/*.* $TARGET/dctm-cs/bundles/

echo "Copying DA bundle"
cp $SOURCE/documentum/da/7.1/da.war $TARGET/dctm-da/bundles/

echo "Copying Thumbnail Server bundle"
cp $SOURCE/documentum/thumbnail-server/7.1/Thumbnail_Server_7.1_linux.tar $TARGET/dctm-ts/bundles/

echo "Copying xCP Designer bundle"
cp $SOURCE/documentum/xcp-designer/2.1.11/xCPDesigner_linux64_2.1.tar $TARGET/dctm-xcpdesigner/bundles/

echo "Copying xMS Agent bundle"
cp $SOURCE/documentum/xms-agent/1.1.13/xms-agent-1.1-P13.zip $TARGET/dctm-xmsagent/bundles/

echo "Copying xMS tools bundle"
cp $SOURCE/documentum/xms-tools/1.2/xms-tools-1.2.zip $TARGET/dctm-xmstools/bundles/

if [  -d $TARGET/dctm-xpression ]; then
	echo "Copying xPression bundle"
	cp $SOURCE/oracle/11.2/*.* $TARGET/dctm-xpression/bundles/
	cp $SOURCE/documentum/content-server/7.1/dfc-jars.7.1.tar $TARGET/dctm-xpression/bundles/
	cp $SOURCE/documentum/xPression/4.5.SP1/XP45SP1_B13_xPression_Server_Installer.zip $TARGET/dctm-xpression/bundles/
	cp $SOURCE/documentum/xPression/4.5.SP1/XP45SP1_P10_xPression_Server_Patch_Installer_64_Linux.zip $TARGET/dctm-xpression/bundles/
	cp $SOURCE/documentum/xPression/4.5.SP1/xPRS_EE4.5.1_P10.ear $TARGET/dctm-xpression/bundles/
	cp $SOURCE/documentum/xPression/4.5.SP1/XP45SP1_B13_cr_scripts.zip $TARGET/dctm-xpression/bundles/
	cp -r $SOURCE/documentum/xPression/4.5.SP1/CRUpgrade $TARGET/dctm-xpression/bundles/
fi
