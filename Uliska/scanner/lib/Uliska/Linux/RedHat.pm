use strict;

=head1 NAME

scanner/lib/Uliska/Linux/RedHat.pm - Perl module for Uliska inventory
scanner for RedHat (or CentOS) Linux

=head1 SYNOPSIS

  use Uliska::Linux::RedHat;
  Uliska->init("Linux/RedHat")->run();


=head1 DESCRIPTION

    - Called from Uliska::Linux;
    - Detects major and minor versions of RedHat OS;
    - Executes commands from lists: cfg/Linux/RedHat/<major> and
      cfg/Linux/RedHat/<major>/<minor>.

=head1 FUNCTIONS

=head2 detect_version

Returns RedHat distribution version as hash with keys: 'major' and
'minor'.

=cut

package Uliska::Linux::RedHat;


sub new { my $self = shift; return $self }

sub run  {
  my $result = \%main::result;
  $result->{'distro_version'} = &detect_version();

  main::executeList(main::read_commands("Linux/RedHat/$result->{distro_version}->{major}"));
  main::executeList(main::read_commands("Linux/RedHat/$result->{distro_version}->{major}/$result->{distro_version}->{minor}"))

};

sub detect_version {
  open(my $fh, '<', '/etc/redhat-release') or die $!;
  my $rel = <$fh>;
  if ($rel =~ /\s(\d+)\.(\d+)\s/) {
    return {
            major => $1,
            minor => $2
           };
  }
  undef;
}
1;
