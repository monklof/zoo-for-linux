#! /bin/bash -
# 
# redis-rps.sh -- calculate the RPS(Requests Per Second)/QPS of redis(localhost)
# 
# Usage:
#      redis_rps.sh [-t time] [cmd]
# Options:
#      -t: 刷新的时间（seconds），默认 2s
#      cmd: redis获取状态信息的命令，默认 ./redis-cli

REDIS_CMD='redis-cli info'
TIME=2

usage(){
    echo "Usage: $PROGRAM [-t time] [cmd]"
}
usage_and_exit(){
    usage
    exit $1
}

error() {
    echo "$@" 1>&2
    usage_and_exit 1
}

warning() {
    echo "$@" 1>&2
}

total_commands_processed(){
    total=`$REDIS_CMD | sed -n 's/total_commands_processed:\([0-9][0-9]*\)/\1/p' | tr -d "\r"`
    # check if redis-info call is succeeded
    if [ $? -eq 0 ] && [ -n $total ]
    then
        printf "$total"
        return 0
    else
        return 1
    fi
}

validate(){
    code="$1"
    str="$2"
    if [ $code -eq 0 ] && [ -n $str ]
    then
        return 0
    else
        return 1
    fi
}

while [ $# -gt 0 ]
do
    case $1 in
    -t | --time )
        shift
        TIME="$1"
        ;;
    -h | --help)
        usage_and_exit 0
        ;;
    -*)
        error "Unrecognized option: $1"
        ;;
    *)
        break
        ;;
    esac
    shift
done

if [ $# -gt 1 ]
then
    usage_and_exit 0
elif [ $# = 1 ]
then
    REDIS_CMD="$1"
fi


last_check_time=`date +%s`
last_check_value=`total_commands_processed`

if ! validate $? $last_check_value
then
    error "get commands failed: $REDIS_CMD"
fi

while true
do
    sleep $TIME
    check_datetime=`date "+%D %T"`
    check_time=`date +%s`
    check_value=`total_commands_processed`
    if ! validate $? $check_value
    then
        warning "get commands failed: $REDIS_CMD"
        continue
    fi
    rps=$(( ($check_value-$last_check_value)/($check_time-$last_check_time) ))
    printf '(time processedcmds rps) (%s %s %s)\n' "$check_datetime" "$check_value" "$rps"
    last_check_time="$check_time"
    last_check_value="$check_value"
done

