#!/bin/bash

cat <<EOF > ~/.netrc
machine use.steria.com
login pic_inpi
password pic_inpi753951
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
git clone --depth 1 ${SOURCE_URL} -b ${BRANCH}
cd xcp-project
git status

for p in BO_CORE BODM
do
	mkdir -p $p/content $p/gen/main/java $p/gen/main/resources
done

echo "** Importing projects"
mvn xcp-import-project:run -pl '!.'

echo "** Packaging BODM project"
mvn install -pl '!.'

exec  bash
