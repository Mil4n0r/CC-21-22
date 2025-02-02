# -*- cperl -*-

use Test::More;
use Git;
use Term::ANSIColor qw(:constants);
use JSON;

use v5.14; # For say

my $student_repo = Git->repository ( Directory => '.' );
my @repo_files = $student_repo->command("ls-files");

doing( "Hito 0");
for my $f (qw( .gitignore README.md LICENSE ) ) {
  ok grep( $f, @repo_files ), "Fichero $f presente";
}
done_testing();


# ------------------------------- Subs -----------------------------------
sub doing {
  my $what = shift;
  diag "\n\t✔ Comprobando $what\n";
}

sub check {
  return BOLD.GREEN ."✔ ".RESET.join(" ",@_);
}

sub fail_x {
  return BOLD.MAGENTA."✘".RESET.join(" ",@_);
}

sub travis_status {
  my $README = shift;
  my ($build_status) = ($README =~ /Build Status..([^\)]+)\)/);
  my $status_svg = `curl -L -s $build_status`;
  return $status_svg =~ /passing/?"Passing":"Fail";
}

sub check_ip {
  my $ip = shift;
  if ( $ip ) {
    diag "\n\t".check( "Detectada dirección de despliegue $ip" )."\n";
  } else {
    diag "\n\t".fail_x( "Problemas detectando dirección de despliegue" )."\n";
  }
  my $pinger = Net::Ping->new();
  $pinger->port_number(22); # Puerto ssh
  isnt($pinger->ping($ip), 0, "$ip es alcanzable");
}

sub objetivos_actualizados {
  my $repo = shift;
  my $objective_file = shift;
  my $date = $repo->command('log', '-1', '--date=relative', '--', "$objective_file");
  my ($hace,$unidad)= $date =~ /Date:.+?(\d+)\s+(\w+)/;
  if ( $unidad =~ /(semana|week|minut)/ ) {
    return "";
  } elsif ( $unidad =~ /ho/ ) {
    return ($hace > 1 )?"":"Objetivos actualizados demasiado recientemente";
  } elsif ( $unidad =~ /d\w+/ ){
    return ($hace < 7)?"":"Los objetivos no han sido actualizados en la semana anterior";
  }

}
