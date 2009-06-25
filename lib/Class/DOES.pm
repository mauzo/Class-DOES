package Class::DOES;

use warnings;
use strict;

use Scalar::Util qw/blessed/;

our $VERSION = "1.00";

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
    my (undef, @roles) = @_;
    my $pkg = caller;

    no strict "refs";

    %{"$pkg\::DOES"} = @roles;
    *{"$pkg\::DOES"} = sub {
        my ($obj, $role) = @_;

        my $class = blessed $obj;
        defined $class or $class = $obj;

        my %mro;
        # yes, this is a list.
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

