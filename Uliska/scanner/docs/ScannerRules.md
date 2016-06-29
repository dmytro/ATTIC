
Syntax of the configuration file(s)
-----------------------------------

Each configuration file is simply a list of UNIX commands to be
executed by script: 1 command per line. 

Usual #-comments can be used in the file, empty lines are ignored.

Command aliases

Special type of comment when comment added at the end of the command
line is used as a command alias, i.e. instead of full command alias is
used as a key in output YAML file. 

Example of command with an alias:

cat /etc/rc.conf.local # hostconfig

To store content of a file in YAM output, simply use cat command as in
the example above.

Rules for configuration files naming (namespace).
-------------------------------------------------

This will be revised as development goes.

At the top of the configuration directory:

* generic.cfg - Generic commands existing in all UNIX'es. Starting
point of the script - OS type and release is detected (uname) and used
in later parts.

* <OS>.cfg - OS by the type of OS (in many cases by type of kernel), given
by +uname -s+ (kernel_name) output (Linux.cfg, SunOS.cfg, Darwin.cfg,
OpenBSD.cfg, FreeBSD.cfg)

Depending on the OS and distribution other commands should go into
directories organized into tree structure:

 Linux/RedHat.cfg
 Linux/Debian.cfg

etc.

