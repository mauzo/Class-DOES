package Class::DOES;

use 5.006;

use strict;
use warnings;
use warnings::register;

use Scalar::Util qw/blessed/;

our $VERSION = "1.00";

sub warnif {
    if (warnings::enabled()) {
        warnings::warn($_[0]);
    }
}

sub get_mro;
sub get_mro {
    my ($class) = @_;

    defined &mro::get_linear_isa
        and return @{ mro::get_linear_isa($class) };

    no strict "refs";
    my @mro = $class;
    for (@{"$class\::ISA"}) {
        push @mro, get_mro $_;
    }
    return @mro;
}

sub import {
    my $pkg = caller;

    # there is an extra argument on the start
    @_ % 2 or warnif 
        "Odd number of arguments passed to Class::DOES.\n" .
        "Did you forget to include the versions?";

    my %does;
    {
        no warnings;
        (undef, %does) = @_;
    }
    for (keys %does) {
        $does{$_} or warnif "False value provided for ->DOES($_)";

        $does{$_} =~ /^(?:\w+::)+\w+$/ and warnif 
            "'$does{$_}' for ->DOES($_) looks like a package.\n" .
            "Did you forget to include the versions?";
    }

    no strict "refs";

    *{"$pkg\::DOES"} = \%does;
    *{"$pkg\::DOES"} = sub {
        my ($obj, $role) = @_;

        my $class = blessed $obj;
        defined $class or $class = $obj;

        my %mro;
        # Yes, this is a list. Shut up with your 'better written as
        # $mro{}' nonsense.
        @mro{ (), get_mro $class } = ();
        for (keys %mro) {
            if (my $rv = ${"$_\::DOES"}{$role}) {
                return $rv;
            }
        }

        return $obj->isa($role);
    };
}

1;

