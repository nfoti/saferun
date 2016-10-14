#!/bin/bash

progname=$0

function usage() {
    echo "usage: $progname [--force] [--yes] -- program [args]"
    echo "    program   the program or command to run"
    echo "    --force   override the git checking and run code anyways"
    echo "    --yes     confirm using --force without being prompted"
    echo "    [args]    any args that program requires"
}

function confirm_force() {
    if [ $FORCE -eq 1 ]
    then
        read -p "are you sure you want to run anyways? [Y/n]: "
        case $(echo $REPLY | tr '[A-Z' '[a-z']) in
            y|yes) echo "yes" ;;
            *) echo "no" ;;
        esac
    fi
}

function srun_print() {
    echo -e "[saferun] $1"
}

# usage check
if [ $# -lt 1 ]
then
    usage
    exit 1
fi

# process flags and get commands to run
FORCE=0
DEFINITELY_FORCE=0
while [[ $# -gt 1 ]]
do
    key=$1
    case $key in
        -f|--force)
        FORCE=1
        ;;
        -y|--yes)
        DEFINITELY_FORCE=1
        ;;
        --)
        shift
        break
        ;;
        *)
            if [[ ${key:0:2} == "--" ]]
            then
                srun_print "\e[31mskipping unknown flag:\e[0m $1"
            else
                break
            fi
        ;;
    esac
shift
done

need_force=0

# git checks in local repo

# check if in git repo
if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" != "true" ]
then
    srun_print "\e[32m!! not in working tree of git repo, running commands\e[0m"
    eval "$@"
fi

# uncommitted files -- do not allow forcing because you already staged the
# files, just commit them!
if [ $(git diff-index --quiet --cached HEAD) ]
then
    srun_print "\e[31m!! staged but uncommitted files found. commit them before running!\e[0m"
    need_force=1
fi

# unstaged files
if test -z $(git diff-files --quiet)
then
    srun_print "\e[31m!! unstaged changes present. stage and commit before running!\e[0m"
    need_force=1
fi

# untracked and unignored files
git ls-files --exclude-standard --others --error-unmatch . >/dev/null 2>&1; ec=$?
if [ "$ec" -eq 0 ]; then
    srun_print "\e[31m!! untracked files found\e[0m"
    need_force=1
elif [ "$ec" -gt 1 ]; then
    srun_print "\e[31m!! git ls-files returned an error"
    exit
fi

if [ $need_force -eq 1 ]
then
    srun_print "\e[31muse --force flag to override and run anyways (could be dangerous)\e[0m"
    if [ $FORCE -eq 1 ]
    then
        if [ $DEFINITELY_FORCE -eq 1 ]
        then
            srun_print "\e[31m!! using --force to override !!\e[0m"
        elif [ "$(confirm_force)" == "no" ]
        then
            exit
        else
            srun_print "\e[31m!! using --force to override !!\e[0m"
        fi
    else
        exit
    fi
fi

# run command that was passed in
eval "$@"
