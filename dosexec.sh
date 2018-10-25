#!/bin/sh

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
        if [ ! "$f" = "$fn" -a ! "$f" = "Makefile" -a ! "$f" = "LICENSE" ]
        then
            mv "$f" "$fn"
        fi
    done

    if [ -f "$tmpfile" ]
    then
        cat "$tmpfile"
        rm "$tmpfile"
    fi
}

function runcmd()
{
    cmd="$1"
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy dosbox \
		-conf dosbox.cnf \
		-c "mount c $(pwd)" \
		-c "c:" \
		-c "$cmd > tmp.\$\$\$" \
		-c "exit" > /dev/null
}
cmd="$@"
cmd2=$(echo "$cmd" | tr '/' '\\')

runcmd "$cmd2"
cleanup
