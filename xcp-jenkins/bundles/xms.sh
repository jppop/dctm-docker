#! /bin/sh

usage() {
    echo `basename $0`: ERROR: $* 1>&2
    cat 2>&1 <<EOF
usage: `basename $0` [--username username] [--passwd password] [--input-file file]
EOF
    exit 1
}

die() {
# display an error message ($1) and exit with a return code ($2)
  echo `basename $0`: ERROR: $1 1>&2
  exit $2
}

OPTS=`getopt -o u:p:f: -l username:,password:,input-file: -- "$@"`
if [ $? != 0 ]
then
    exit 1
fi

eval set -- "$OPTS"

# default values
username= passwd= inputfile=
while true ; do
    case "$1" in
        --username|-u) username=$2; shift 2;;
        --password|-p) passwd=$2; shift 2;;
        --input-file|-f) inputfile=$2; shift 2;;
        --) shift; break;;
    esac
done

useropt=
[ -z "$username" ] || useropt="-Dxms.username=${username}"
pwdopt=
[ -z "$passwd" ] || pwdopt="-Dxms.password=${passwd}"
fileopt=
[ -z "$inputfile" ] || fileopt="-Dxms.input.file=${inputfile}"

[ -z "$inputfile" -o -f "$inputfile" ] || die "Script file not found: $inputfile" 2

export XMS_OPTS='-Xmx1024m -XX:MaxPermSize=128m'
export XMS_TOOLS_HOME=${PWD%/*}
LIB_PATH=$XMS_TOOLS_HOME/lib
CONFIG_PATH=$XMS_TOOLS_HOME/config
CLASSPATH="$CONFIG_PATH:$CONFIG_PATH/system:$LIB_PATH/*:$LIB_PATH/axis/*:$LIB_PATH/commons/*:$LIB_PATH/hyperic/*:$LIB_PATH/jaxb/*:$LIB_PATH/jsr303/*:$LIB_PATH/spring/*:$LIB_PATH/vcloud/*:$LIB_PATH/velocity/*:$LIB_PATH/vix/*:$LIB_PATH/xdb/*:$LIB_PATH/recipes/dfc/*:$LIB_PATH/xms-services/*:$LIB_PATH/xms-cli/*:$LIB_PATH/xms-core/*"

LOGS_FOLDER=$XMS_TOOLS_HOME/logs
if [ ! -d $LOGS_FOLDER ]; then
	mkdir $LOGS_FOLDER && echo $LOGS_FOLDER has been created
fi
if [ "$JAVA_HOME" = "" ]; then
       echo JAVA_HOME is not set
else
       $JAVA_HOME/bin/java -version >$XMS_TOOLS_HOME/logs/java_version 2>&1
       if `grep -q "1.7" $XMS_TOOLS_HOME/logs/java_version 1>/dev/null 2>&1`
       then
               if [ "$xms_mode" = "" ]; then
                       xms_mode=server
               fi
               $JAVA_HOME/bin/java $XMS_OPTS -classpath $CLASSPATH $xms_input_file \
                   -Dxms.tools.home=$XMS_TOOLS_HOME -Djna.library.path=$LIB_PATH/vix/linux64 \
                   -Dxms.mode=$xms_mode \
                   $useropt $pwdopt $fileopt \
                   com.documentum.xms.cli.XmsConsole
       else
               echo "JAVA_HOME should point to java 1.7"
       fi
fi
