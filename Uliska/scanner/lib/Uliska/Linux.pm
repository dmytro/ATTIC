use strict;

=head1 NAME

scanner/lib/Uliska/Linux.pm - Perl module for Uliska inventory scanner
for Linux

TODO

=head1 SYNOPSIS

  use Uliska::Linux;
  my $os = Uliska->init("Linux");
  $os->run() if defined $os;

=head1 DESCRIPTION

Linux module implements Linux support for Uliska. It is top-level
Uliska OS module.

Is is called and executed from C<uliska.pl> script. Together with this
module other modules are/can be called:

  - Uliska::Linux::<version_minor>
  - Uliska::Linux::<version_major>


Module executes commands from cfg/Linux.cfg

Module performs additional functions:

  - detects Linux distribution (i.e. RedHat, Debian etc)
  - loads and executes corrsponding module (Linux::Redhat, Linux::Debian)

Additional modules are responsible for loading distribution-specific
libraries and executing lists of distribution-specific commands.

=cut

package Uliska::Linux;

sub new {
  my $self = shift;
  return $self;
}

sub run  {
  my $result = \%main::result;
  $result->{'distro'} = &detect_distro();
  main::executeList(main::read_commands("Linux/".$result->{distro}));

  my $module = Uliska->init("Linux/$result->{distro}");
  $module->run() if defined $module;
};

sub detect_distro {
  return 'RedHat' if -f '/etc/redhat-release';
  return 'Debian' if -f '/etc/debian_version';
  'unknown';
}
1;
