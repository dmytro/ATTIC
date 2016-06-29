# @title Adding and Extending Uliska Scanners

# Extending Uliska Scanner

Main uliska.pl script only initializes and executes commands at the
top level, based on OS kernel name, kernel major and minor versions.

Rest is delegated to modules deeper in the `cfg` and `lib/Uliska`
sub-trees.

Uliska can be extended to cover more OS'es -- making the name-space
tree 'wider', or going 'deeper' in the name-space tree covering more
specific details of the distribution or environment.

## Adding new OS (going wider)

At the top level of the scanner tree add files accordingly to kernel
name and versions of UNIX system. For HP-UX 11i additional files
should be something like:

    lib/Uliska/HP-UX.pm
    lib/Uliska/HP-UX/11.pm
    cfg/HP-UX.cfg
    cfg/HP-UX/11.cfg

Top level files are similar to the ones describe in the following
section.

## Adding new sub-trees (going deeper)

System specific scans are based on loading and executing nested list
of commands and Perl modules. For example, for Linux sub-trees of .cfg
and .pm files can be following:

    ./cfg/Linux.cfg
    ./cfg/Linux/Debian.cfg
    ./cfg/Linux/Debian/5.cfg
    ./cfg/Linux/Debian/5/4.cfg
    ./cfg/Linux/Debian/5/5.cfg
    ./cfg/Linux/Debian/6.cfg
    ./cfg/Linux/RedHat/5.cfg
    ./cfg/Linux/RedHat/5/4.cfg
    ./cfg/Linux/RedHat/5/5.cfg
    ./cfg/Linux/RedHat/6.cfg
    
    ./lib/Uliska.pm
    ./lib/Uliska/Linux.pm
    ./lib/Uliska/Linux/Debian.pm
    ./lib/Uliska/Linux/Debian/5.pm
    ./lib/Uliska/Linux/Debian/5/4.pm
    ./lib/Uliska/Linux/Debian/6.pm
    ./lib/Uliska/Linux/RedHat.pm
    ./lib/Uliska/Linux/RedHat/5.pm
    ./lib/Uliska/Linux/RedHat/5/1.pm
    ./lib/Uliska/Linux/RedHat/5/2.pm
    ./lib/Uliska/Linux/RedHat/5/3.pm
    ./lib/Uliska/Linux/RedHat/5/4.pm
    ./lib/Uliska/Linux/RedHat/5/5.pm
    ./lib/Uliska/Linux/RedHat/6.pm

Modules are loaded and executed on demand. I.e. for RedHat Linux 5.4
modules will be tried and loaded in the following order:

````
   ./lib/Uliska/Linux.pm
   ./lib/Uliska/Linux/RedHat.pm
   ./lib/Uliska/Linux/RedHat/5.pm
   ./lib/Uliska/Linux/RedHat/5/4.pm
````


Accordingly lists of commands will be executed from files in the
similar order:

````
    ./cfg/Linux.cfg
    ./cfg/Linux/RedHat.cfg
    ./cfg/Linux/RedHat/5.cfg
    ./cfg/Linux/RedHat/5/4.cfg
````

All these files are not required to exist. In both cases (modules and
commands) files are loaded only if they present, if file is not
present this is logged to output file under __WARNINGS__ branch (see
LOGGING (TODO)).


Additional granularity can be added based on DNS or NIS domain-names,
hostnames, hardware types, etc.

### Adding your own modules

This example is based on Linux.pm module. In this module we can detect
Linux distribution name, execute commands and load modules specific
for the distribution.

- detect your distribution:

````perl
    $distro = 'RedHat' if -f '/etc/redhat-release';
    $distro = 'Debian' if -f '/etc/debian_version';
````

- add files in cfg directory and execute commands

  This will execute commands from files Uliska/Linux/RedHat.cfg or
  Uliska/Linux/Debian.cfg:
  
````perl
     main::executeList(main::read_commands("Linux/$distro"));
````

- initialize and execute more nested modules

  This will try to load and execute module Uliska::Linux::RedHat or
  Uliska::Linux::Debian. Module will be executed only if load is
  successful:

    my $module = Uliska->init("Linux/$result->{distro}");
    $module->run() if defined $module;

Nesting modules can go arbitrary number of levels deep.


### Example

Full text of module Linux.pm

    use strict;
    
    package Uliska::Linux;
    
    
    sub new {
      my $self = shift;
      return $self;
    }
    
    sub run  {
      my $result = \%main::result;
      $result->{'distro'} = &detect_distro();
      main::executeList(main::read_commands("Linux/".$result->{distro}));
    
      Uliska->init("Linux/$result->{distro}")->run();
    };
    
    sub detect_distro {
      return 'RedHat' if -f '/etc/redhat-release';
      return 'Debian' if -f '/etc/debian_version';
      'unknown';
    }
    1;
    
