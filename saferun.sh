#!/bin/bash

progname=$0

function usage() {
    echo "usage: $progname [--force] -- program [args]"
    echo "    program   the program or command to run"
    echo "    [args]    any args that program requires"
}

function git_unstaged {
    $(git diff-index --quiet --cached HEAD)
}

function git_untracked_ignored {
    $(git ls-files --others)
}

function git_untracked_unignored {
    $(git ls-files --exclude-standard --others)
}

if [ $# -lt 1 ]
then
    usage
    exit 1
fi

# process flags and get commands to run
FORCE=0
while [[ $# -gt 1 ]]
do
    key=$1
    case $key in
        -f|--force)
        FORCE=1
        ;;
        --)
        shift
        break
        ;;
        *)
            if [[ ${key:0:2} == "--" ]]
            then
                echo -e "\e[31mskipping unknown flag:\e[0m $1"
            else
                break
            fi
        ;;
    esac
shift
done

# check if there are uncommitted files in local git repo


echo "force: $FORCE"
echo "$@"


#eval "$@"
