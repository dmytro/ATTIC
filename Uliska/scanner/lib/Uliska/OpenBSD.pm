use strict;

=head1 NAME

scanner/lib/Uliska/OpenBSD.pm - Perl module for Uliska inventory
scanner for OpenBSD


=head1 SYNOPSIS

  use Uliska::OpenBSD;
  my $os = Uliska->init("OpenBSD");
  $os->run() if defined $os;

=head1 DESCRIPTION

This is top-level OS module for OpenBSD.

Is is called and executed from C<uliska.pl> script. Together with this
module other modules are/can be called:

  - Uliska::OpenBSD::<version_minor>
  - Uliska::OpenBSD::<version_major>

Module executes commands from cfg/generic_bsd.cfg

=cut

package Uliska::OpenBSD;

sub new { my $self = shift; return $self }
sub run { main::executeList(main::read_commands('generic_bsd')) }
1;
