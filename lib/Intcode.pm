package Intcode;

use 5.026;

use strict;
use warnings;
no  warnings 'syntax';

use experimental 'signatures';

use Hash::Util qw [fieldhash];

fieldhash my %program;
fieldhash my %original;

my $ADD      =  1;
my $MULTIPLY =  2;
my $HALT     = 99;

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

#
# Run the program.
#
sub run ($self, %options) {
    my $pc = 0;
    $program {$self} = [@{$original {$self}}];
    if ($options {init}) {
        foreach my $position (keys %{$options {init}}) {
            my $value = $options {init} {$position};
            $self -> save ($position, $value);
        }
    }
    while (1) {
        my ($opcode, @args) = @{$program {$self}} [$pc .. $pc + 3];
        if ($opcode == $HALT) {
            return;
        }
        elsif ($opcode == $ADD || $opcode == $MULTIPLY) {
            my $left  = $self -> fetch ($args [0]);
            my $right = $self -> fetch ($args [1]);
            my $new   = $opcode == $ADD ? $left + $right
                                        : $left * $right;
            $self -> save ($args [2], $new);
        }
        else {
            ...
        }
        $pc += 4;
    }
    $self;
}


#
# Given a position, return whatever is stored at that location.
#
sub fetch ($self, $position) {
    $program {$self} [$position];
}

#
# Store a value at the given position.
#
sub save ($self, $position, $value) {
    $program {$self} [$position] = $value;
    $self;
}


1;

__END__
