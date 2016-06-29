# @title Uliska Scanner Architecture

Architecture overview
=====================


This document outlines basic architectural principles of Uliska
scanner.

Commands and output
-------------------

Main principle is simple: take list of commands, execute and save
result in easy to produce and easy to parse format. Preferably output
format should be some kind of structured data format (data
serialization).

### Output format - YAML

- YAML is easy to produce: prepend lines of STDOUT with several
  spaces;

- it is easy to parse: almost any programming language has parser for YAML;

- as a bonus it's human readable.

### Command lists

Command lists in Uliska are plain text files with one command per
line, with some additional sugar related to command aliases. 

Aliasing gives an ability to have similar output data structure
across different varieties of UNIX systems.

Components
==========

Main scanner components are:

- main script `uliska.pl`

- Perl module `./lib/Uliska.pm`

- additional Perl module(s)s `./lib/*` (currently only one module
  included - YAML);

- command lists sub-directory `./cfg/**/*.cfg`

- modules-'workers' in `./cfg/**/*.pm`

Perl modules for Uliska scanner
-------------------------------
<iframe src="pod_index_short.html" width="100%" border="0" height="200" style="border:0;"></iframe>
[See in separate window](pod_index.html)

### Command lists vs Perl modules

Perl modules provide minimal logical glue, while main workhorse is
list of shell commands. 

### Directory structure


All scripts and command lists in Uliska are organized into
hierarchical structure of sub-directories (name-space) reflecting
scanned systems properties (kernel name and versions, distribution
name, hardware vendor, etc).


Execution work-flow
====================

Top level files and directories
-------------------------------


Uliska execution starts from calling reading and executing command
list from ./cfg/generic.cfg file. This file contains commands,
supposed to be present in all supported variants and dialects of
UNIX. After this step Uliska must be able to find at least kernel name
and version of OS it is being run on. 

At the end of execution uliska.pl tries: 

- read and execute commands from files `cfg/<kernel>.cfg`,
  `cfg/<kernel>/<major>.cfg`, `cfg/<kernel>/<major>/<minor>.cfg`;

- and to load additional modules `lib/Uliska/<kernel>.pm`,
  `lib/Uliska/<kernel>/<major>.pm`,
  `lib/Uliska/<kernel>/<major>/<minor>.pm` and execute them;
  
  where

  - `<kernel>` - is OS kernel name as returned by uname -s (Linux,
    SunOS), case sensitive;

  - `<major>` and `<minor>` - are kernel release numbers, returned by
    uname -r.

Specific commands and modules
-----------------------------

Each loadable module should have subroutine named `run()`. It is
executed after module load has succeeded.

## OS specific modules and commands

All modules are built in a similar way:

- module performs some commands to detect specific information about
  OS and/or host ;

- module load additional modules based on discovered data;

- execute modules by running modules' subroutine run().

For more information see [Extending](file.ExtendingScanner.html) file.


## Requirements

Current requirements for Uliska.pm are: strict, warnings, and
YAML. First two should not be a problem on any reasonable Perl
installation, as for last one -- YAML -- please be sure to include
YAML module with Uliska, if it is missing on target hosts.
  
YAML::Old from CPAN http://search.cpan.org/~ingy/YAML-Old-0.81/
included to make Uliska package self-contained. It can be replaced
with any existing Perl YAML dumper.

 LocalWords:  Uliska YAML uliska uname SunOS
