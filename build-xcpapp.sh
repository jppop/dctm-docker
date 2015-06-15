#!/bin/bash

cat <<EOF > ~/.netrc
machine use.steria.com
login jfrancon
password Sopra34=JP2
EOF

set -e

SOURCE_URL=https://use.steria.com/gitroot/backoffpi/xcp-project.git
#BRANCH=rc-beta-1
BRANCH=develop

BUILD_HOME=${XCPDESIGNER_WORKSPACE}/build
[ -d "${BUILD_HOME}" ] || mkdir -p ${BUILD_HOME}

# get sources
cd ${BUILD_HOME}
echo "** Getting sources from ${SOURCE_URL}"
git clone ${SOURCE_URL} -b ${BRANCH}
cd xcp-project
git status

for p in BO_CORE BODM
do
	mkdir $p/content
	mkdir -p $p/gen/main/java
	mkdir -p $p/gen/main/resources
done

set +e
echo "** Importing BO_CORE into xCP Designer workspace"
cd BO_CORE
mvn xcp-import-project:run
mvn install
cd ..

echo "** Packaging BODM project"
cd BODM
mvn xcp-import-project:run
mvn install
cd ..
set -e

echo "** Importing BO_CORE into xCP Designer workspace"
cd BO_CORE
mvn xcp-import-project:run
mvn install
cd ..

echo "** Packaging BODM project"
cd BODM
mvn xcp-import-project:run
mvn install

exec  bash
