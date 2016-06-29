#!/usr/bin/env perl

=head1 NAME

uliska - UNIX/Linux Inventory Scanner

=head1 SYNOPSIS

    uliska.pl

=head1 DESCRIPTION

C<uliska.pl> is Perl script for server/host inventory collection of the
UNIX system. 

Uliska cover different OS's by loading and calling execution of Perl
packages and executing commands for each OS organized into namespace
(OS/architecture/release etc).

C<uliska> gathers data by executing list of UNIX commands and
collecting output into single structured data file. Data file is
YAML-fomratted, but can be changed to other format (JSON or XML)
without loss of functionality.

C<uliska.pl> is part of Uliska (UNIX/Linux Inventory and Configuration
Scanner) project.

=head2 EXECUTION

Script starts from:

  - reading and executing commands from cfg/generic.cfg file

  - detecting OS's kernel name, major and minor version executing list
    of commands from cfg/<os>.cfg, cfg/<os>/<major>.cfg,
    cfg/<os>/<major>/<minor>.cfg

  - loading and giving control to lib/<os>.pm Perl module

=head1 SEE ALSO

  - scanner/ArchitectureOverview.md
  - README.md

=cut

use strict;
use warnings;

BEGIN { chomp(my $dir = `dirname $0`);
        push @INC, "$dir/lib"
};

use Uliska;

read_config;
$ENV{PATH} = $config{path};

executeList(read_commands('generic', 1)); # 1 - requried, die if list
                                          # is not found, in most
                                          # other cases ignore missing
                                          # file
# my ($major,$minor) = split /\./, $result{uname_release};
my ($major,$minor) = ($result{uname_release} =~ /^([\d+])\.([\d+]).*$/);

$result{kernel} = { full => $result{uname_release},
                    name => $result{uname_name},
                    major => $major, minor => $minor
                  };

executeList(read_commands($result{kernel}{name}));
executeList(read_commands($result{kernel}{name}."/".$result{kernel}{major}));
executeList(read_commands($result{kernel}{name}."/".$result{kernel}{major}."/".$result{kernel}{minor}));

my $os = Uliska->init($result{kernel}{name});

# If defined module for this OS run it, otherwise end here

$os->run() if defined $os;

output_result();


=head1 AUTHOR

Dmytro Kovalov dmytro.kovalov\@gmail.com
2012

=cut
