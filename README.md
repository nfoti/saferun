
saferun
=======

A git-repo-aware `bash` script that will not allow a script/program/command to
be run if the git repo in the current directory is dirty. The script is meant
to be used to control running experiments so that the current state of the
experiment must be recorded in git (though this can be overridden for
convenience).
