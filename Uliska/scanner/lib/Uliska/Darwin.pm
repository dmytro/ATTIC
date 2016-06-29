use strict;

=head1 NAME

scanner/lib/Uliska/Darwin.pm - Perl module for Uliska inventory
scanner for Darwin OS (AKA MacOSX)


=head1 SYNOPSIS

  use Uliska::Darwin;
  my $os = Uliska->init("Darwin");
  $os->run() if defined $os;

=head1 DESCRIPTION

This is top-level OS module for Darwin OS (MacOSX).

Is is called and executed from C<uliska.pl> script. Together with this
module other modules can be called:

- Uliska::Darwin::<version_minor>
- Uliska::Darwin::<version_major>

Module executes commands from cfg/generic_bsd.cfg

=cut

package Uliska::Darwin;
sub new { my $self = shift; return $self }
sub run { main::executeList(main::read_commands('generic_bsd')) }

1;
