#!/opt/perl/bin/perl

use 5.028;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

@ARGV = "input" unless @ARGV;
# @ARGV = "example-1";

my $STEPS = @ARGV && $ARGV [0] =~ /example/ ? 10 : 1000;

use List::Util qw [sum];

my $px = 0;
my $py = $px + 1;
my $pz = $py + 1;
my $vx = $pz + 1;
my $vy = $vx + 1;
my $vz = $vy + 1;

my @moons;

while (<>) {
    my $moon;
    /x\s*=\s*(-?[0-9]+)/ and $$moon [$px] = $1;
    /y\s*=\s*(-?[0-9]+)/ and $$moon [$py] = $1;
    /z\s*=\s*(-?[0-9]+)/ and $$moon [$pz] = $1;
    $$moon [$_] = 0 for $vx .. $vz;
    push @moons => $moon;
}

sub step {
    foreach my $moon1 (@moons) {
        foreach my $moon2 (@moons) {
            $$moon1 [$_ + 3] -= $$moon1 [$_] <=> $$moon2 [$_] for $px .. $pz;
        }
    }
    foreach my $moon (@moons) {
        $$moon [$_] += $$moon [$_ + 3]                        for $px .. $pz;
    }
}

sub energy {
    sum map {sum (map {abs} @$_ [$px .. $pz]) *
             sum (map {abs} @$_ [$vx .. $vz])} @moons;
}

sub show {
    foreach my $moon (@moons) {
        printf "x=%3d y=%3d z=%3d; vx=%3d vy=%3d vz=%3d\n", @$moon;
    }
    print "\n";
}

step for 1 .. $STEPS;
say "Solution 1: ", energy;


__END__
