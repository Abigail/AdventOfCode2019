package Intcode;

use 5.026;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';

use Hash::Util qw [fieldhash];

fieldhash my %program;
fieldhash my %original;
fieldhash my %pc;

my $ADD            =  1;
my $MULTIPLY       =  2;
my $INPUT          =  3;
my $OUTPUT         =  4;
my $HALT           = 99;

my $FROM_PC        = -1;

my $MODE_POSITION  =  0;
my $MODE_IMMEDIATE =  1;
my $MODE_DIRECT    =  2;

#
# Create a new interpreter
#
sub new ($class) {
    bless \do {my $var} => $class;
}

#
# Initialize the interpreter with a program.
#
sub init ($self, @program) {
    $original {$self} = [@program];
    $self;
}


sub mode ($command, $count) {
    int ($command / (10 ** ($count + 1))) % 10;
}

sub run ($self, %options) {
    $self -> init_pc;
    $program {$self} = [@{$original {$self}}];
    if ($options {init}) {
        foreach my $position (keys %{$options {init}}) {
            my $value = $options {init} {$position};
            $program {$self} [$position] = $value;
        }
    }
    while (1) {
        my $command = $self -> fetch ($FROM_PC, $MODE_DIRECT);

        my $opcode = $command % 100;

        if ($opcode == $HALT) {
            return;
        }
        elsif ($opcode == $ADD || $opcode == $MULTIPLY) {
            my $left  = $self -> fetch ($FROM_PC, mode $command, 1);
            my $right = $self -> fetch ($FROM_PC, mode $command, 2);
            my $new   = $opcode == $ADD ? $left + $right
                                        : $left * $right;

            $self -> save ($FROM_PC, $new, mode $command, 3);
        }
        elsif ($opcode == $INPUT) {
            my $callback = $options {input};
            die "No callback provided" unless
                   $callback && ref ($callback) eq "CODE";
            my $value = $callback -> ();
            $self -> save ($FROM_PC, $value, mode $command, 1);
        }
        elsif ($opcode == $OUTPUT) {
            my $callback = $options {output};
            die "No callback provided" unless
                   $callback && ref ($callback) eq "CODE";
            my $value = $self -> fetch ($FROM_PC, mode $command, 1);
            $callback -> ($value);
        }
        else {
            ...
        }
    }
    $self;
}

#
# Return the PC
#
sub pc ($self) {
    $pc {$self}
}

sub inc_pc ($self) {
    $pc {$self} ++;
    $self;
}

sub init_pc ($self) {
    $pc {$self} = 0;
    $self;
}



#
# Given a position, return whatever is stored at that location.
#
sub fetch ($self, $position, $mode = $MODE_DIRECT) {
    if ($position == $MODE_IMMEDIATE) {
        return $position;
    }
    if ($position == $FROM_PC) {
        $position = $self -> pc;
        $self -> inc_pc;
    }
    if ($mode == $MODE_POSITION) {
        $position = $program {$self} [$position];
    }
    $program {$self} [$position];
}

#
# Store a value at the given position.
#
sub save ($self, $position, $value, $mode) {
    if ($position == $MODE_IMMEDIATE) {
        ...
    }
    if ($position == $FROM_PC) {
        $position = $self -> pc;
        $self -> inc_pc;
    }
    if ($mode == $MODE_POSITION) {
        $position = $program {$self} [$position];
    }
    $program {$self} [$position] = $value;
    $self;
}



1;


__END__
