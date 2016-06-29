use strict;

=head1 NAME

scanner/lib/Uliska/FreeBSD.pm - Perl module for Uliska inventory
scanner for FreeBSD


=head1 SYNOPSIS

  use Uliska::FreeBSD;
  my $os = Uliska->init("FreeBSD");
  $os->run() if defined $os;

=head1 DESCRIPTION

This is top-level OS module for FreeBSD.

Is is called and executed from C<uliska.pl> script. Together with this
module other modules are/can be called:

  - Uliska::FreeBSD::<version_minor>
  - Uliska::FreeBSD::::<version_major>

Module executes commands from cfg/generic_bsd.cfg

=cut

package Uliska::FreeBSD;

sub new { shift }
sub run { main::executeList(main::read_commands('generic_bsd')) }
1;
