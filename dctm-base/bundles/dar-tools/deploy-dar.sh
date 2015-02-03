#/bin/bash

[ -z "$TMP" ] && TMP=/tmp
[ -z "$COMPOSER_HOME" ] && COMPOSER_HOME=$DM_HOME/install/composer/ComposerHeadless
#COMPOSER_HOME=/applis/dg4d/documentum4/product/6.7/install/composer/ComposerHeadless

traceOn=0
traceFile=/tmp/`basename $0`$$
traceRedirect='> /dev/null'
[ $traceOn = 1 ] && traceRedirect='>> $traceFile'

usage() {
	echo `basename $0`: ERROR: $* 1>&2
	cat 2>&1 <<EOF
usage: `basename $0` -d dar_path -r repository [-u username -p password] [-i input_file) [-l logfile] [-t]
where
-d dar_path	is the dar pathname to be installed
-r repository is the target repository
-u username	is the name used to perform the installation. Default is the current system logged in user.
-p password	is the password. Default is blank.
-t		enables trace messages
EOF
	exit 1
}

exitOnError() {
# display an error message ($1) and exit with a return code ($2)
	echo `basename $0`: ERROR: $1 1>&2
	exit $2
}

trace() {
if [ $traceOn = 1 ] ; then
	echo $* >> $traceFile
fi
}
getAbsolutePath() {
pathname=$1
  wdsave=`pwd`
  cd `dirname $pathname`
  absolute_path=`pwd`/`basename $pathname`
  cd $wdsave
  echo $absolute_path
}

scriptdir=`dirname $0`
buildfile=`getAbsolutePath $scriptdir/deploy.xml`
noparamfile=`getAbsolutePath $scriptdir/no.installparam`

trace "Start date: `date`"

#d
dar_path=
#r
repository=
#u
username=
#p
password=
#i
input_file=$noparamfile
#l
logfile=
#f
locale_folder=
dfc_trace=0

while getopts "d:r:u:p:i:l:f:t" opt;
do
	case $opt in
		d) dar_path="$OPTARG" ;;
		r) repository="$OPTARG" ;;
		u) username="$OPTARG" ;;
		p) password="$OPTARG" ;;
		l) logfile="$OPTARG" ;;
		i) input_file="$OPTARG" ;;
		f) locale_folder="$OPTARG" ;;
		t) dfc_trace=1 ;;
		*) usage ;;
	esac
done

# check arguments
[ -z "$dar_path" ] && usage "dar path is mandatory"
[ -z "$repository" ] && usage "repository is mandatory"
[ -z "$input_file" ] && usage "input file is mandatory"

if [ "$username" == "" ]; then
	username=`whoami`
	password=" "
else
	[ -z "$password" ] && usage "password is mandatory"
fi

dar_name=`basename $dar_path`
log_timestamp=$(date +%Y%m%d%H%M)
if [ "$logfile" == "" ]; then
	logfile="$DM_HOME/install/install-$dar_name-$log_timestamp.log"	
fi

trace "dar_path = "$dar_path" - repository = "$repository" - username = "$username" - logfile = "$logfile"."

DATA_DIR=`mktemp -d`
trace "working dir: $DATA_DIR"
# get absolute path to the dar file
absolute_dar=`getAbsolutePath $dar_path`
absolute_inputfile=`getAbsolutePath $input_file`

[ -z "$LOGDIR" ] && LOGDIR=/tmp/dctm-trace
[ -d "$LOGDIR" ] && rm -rf $LOGDIR
mkdir -p "$LOGDIR"

TRACEOPTS="-DLOGDIR=$LOGDIR -Dlog4j.configuration=${scriptdir}/log4j-deploy-dar.properties"
OPTS="-Demc.preferences.logTraceMessages=false -Demc.preferences.logDebugMessages=false -Ddfc.properties.file=${DOCUMENTUM_SHARED}/config/dfc.properties"

if [ $dfc_trace = 1 ]; then
   
  cat > ${scriptdir}/dfc-debug.properties << EOF
#include ${DOCUMENTUM_SHARED}/config/dfc.properties
dfc.tracing.enable=true
#dfc.tracing.date="dd MM yyyy HH:mm:ss"
dfc.tracing.verbose=true
dfc.tracing.max_stack_depth=0
dfc.tracing.include_rpcs=true
dfc.tracing.mode=compact
dfc.tracing.dir=$LOGDIR/logs/trace
EOF
  OPTS="-Demc.preferences.logTraceMessages=true -Demc.preferences.logDebugMessages=true -Ddfc.properties.file=${scriptdir}/dfc-debug.properties"
fi
trace $JAVA_HOME/bin/java $TRACEOPTS $OPTS -Ddar=$absolute_dar -Dlogpath="$logfile" -Ddocbase=$repository -Duser="$username" -Ddomain= -Dpassword=xxxx -Dinput_file="$absolute_inputfile" -Dlocale_folder="$locale_folder" -cp $COMPOSER_HOME/startup.jar org.eclipse.core.launcher.Main -data $DATA_DIR -application org.eclipse.ant.core.antRunner -buildfile "$buildfile"
$JAVA_HOME/bin/java -Xmx1024m -XX:MaxPermSize=256m $TRACEOPTS $OPTS -Ddar=$absolute_dar -Dlogpath="$logfile" -Ddocbase=$repository -Duser="$username" -Ddomain= -Dpassword="$password" -Dinput_file="$absolute_inputfile" -Dlocale_folder="$locale_folder" -cp $COMPOSER_HOME/startup.jar org.eclipse.core.launcher.Main -data $DATA_DIR -application org.eclipse.ant.core.antRunner -buildfile "$buildfile"

rm -rf $DATA_DIR
echo "Done. Please check logfile: $logfile"
trace "End date: `date`"
