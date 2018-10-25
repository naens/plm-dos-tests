#!/bin/sh

function runcmd()
{
    local cmd="$1"
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy dosbox \
		-conf dosbox.cnf \
		-c "mount c $(pwd)" \
		-c "c:" \
		-c "$cmd > tmp.\$\$\$" \
		-c "exit" > /dev/null &
    child_pid=$!
    echo $child_pid
}

tmpfile='tmp.$$$'
function cleanup()
{
    for f in $(find . \
        ! -path './.git*' \
        ! -path './troff/*' \
        ! -path './docs/*' \
        ! -path './disk/*' \
        ! -name Makefile \
        ! -name TODO )
    do
        fn=$(echo "$f" | tr [:upper:] [:lower:])
        if [ ! "$f" = "$fn" -a ! "$f" = "Makefile" ]
        then
            mv "$f" "$fn"
        fi
    done

    if [ -f "$tmpfile" ]
    then
        msg=$(cat "$tmpfile")
        echo "$msg"
        local err=$(echo "$msg" | grep -i error | grep -iv "no errors")
        if [ -n "$err" ]
        then
            result=2
        fi
        rm "$tmpfile"
    fi
}

path="$1"
shift
tail="$@"

dir=$(dirname "$path")

path2=$(echo $path | tr '/' '\\')

start=$(date '+%Y-%m-%d %H:%M:%S')

cmd="asm86 $path2"
child_pid=$(runcmd "$cmd")

unset lst
result=0
while [ -z "$lst" ]
do
    lst=$(find "$dir" -newermt "$start" | grep -i lst)
    sleep 0.2
done
sleep 0.1
kill $child_pid

if [ -f "$tmpfile" ]
then
    if [ $(wc -c "$tmpfile") -eq 0 ]
    then
        msg=$(tail -n 1 "$lst")
        echo "$msg"
        local err=$(echo "$msg" | grep -i error | grep -iv "no errors")
        if [ -n "$err" ]
        then
            result=1
        fi
    fi
fi

grep '\*\*\* [A-Z]' $lst

cleanup

exit $result
