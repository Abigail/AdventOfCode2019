#!/opt/perl/bin/perl

use 5.032;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';
use experimental 'lexical_subs';

@ARGV = "input" unless @ARGV;

#
# Read in the data, extract asteroid locations.
#
my $y = 0;
my @asteroids;
while (<>) {
    chomp;
    my @chars = split //;
    foreach my $x (keys @chars) {
        if ($chars [$x] eq "#") {
            push @asteroids => [$x, $y];
        }
    }
    $y ++;
}

#
# Return the angle in radians between two points.
#
sub angle ($x1, $y1, $x2, $y2) {
    atan2 ($x2 - $x1, $y2 - $y1);
}

#
# Return the distance between two points (actually, the square of the distance)
#
sub dist ($x1, $y1, $x2, $y2) {
    ($x2 - $x1) ** 2 + ($y2 - $y1) ** 2
}


#
# For each asteroid, calculate the angle between it and each other asteroid.
# Group them by angle.
#
my %angles;
foreach my $a1 (@asteroids) {
    my $key   = join "," => @$a1;
    foreach my $a2 (@asteroids) {
        next if $a1 == $a2;   # a1 and a2 are references. We can compare them.
        my $angle = angle (@$a1, @$a2);
        push @{$angles {$key} {$angle}} => $a2;
    }
}

my $max = 0;
my $max_key;
foreach my $key (keys %angles) {
    if ($max < keys %{$angles {$key}}) {
        $max = keys %{$angles {$key}};
        $max_key = $key;
    }
}

say "Solution 1: ", $max;

#
# Of the best location, for each angle, sort the asteroids by distance.
# 
my $best = $angles {$max_key};
my ($X, $Y) = split /,/ => $max_key;
foreach my $angle (keys %$best) {
    $$best {$angle} = [sort {dist ($X, $Y, @$a) <=>
                             dist ($X, $Y, @$b)} @{$$best {$angle}}];
}


#
# Shoot asteroids with a rotating beam. The angles are such that
# straight up has the highest angle, and then it goes down till
# we're all the way around. For each angle encountered, remove
# one asteroid. If that was the last asteroid on that angle,
# remove the angle from the set.
#
my $count  =   0;
my $TARGET = 200;
SHOT:
while (keys %$best) {
    my @angles = sort {$b <=> $a} keys %$best;
    foreach my $angle (@angles) {
        my $asteroid = shift @{$$best {$angle}};
        delete $$best {$angle} unless @{$$best {$angle}};
        if (++ $count == $TARGET) {
            say "Solution 2: ", 100 * $$asteroid [0] + $$asteroid [1];
            last SHOT;
        }
    }
}
