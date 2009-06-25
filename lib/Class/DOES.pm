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
    my (undef, @roles) = @_;
    my $pkg = caller;

    my $meth;
    $meth = $pkg->can("DOES")
        and $meth != \&DOES
        and $meth != (UNIVERSAL->can("DOES") || 0)
        and warnif "$pkg has inherited an incompatible ->DOES";

    $meth = $pkg->can("isa")
        and $meth != UNIVERSAL->can("isa")
        and warnif "$pkg doesn't use \@ISA for inheritance";

    my %does = map +($_, 1), @roles;

    no strict "refs";

    *{"$pkg\::DOES"} = \%does;
    *{"$pkg\::DOES"} = \&DOES;
}

sub DOES {
    my ($obj, $role) = @_;

    my $class = blessed $obj;
    defined $class or $class = $obj;

    my %mro;
    # Yes, this is a list. Shut up with your 'better written as
    # $mro{}' nonsense.
    @mro{ (), get_mro $class } = ();
    for (keys %mro) {
        no strict "refs";
        if (exists ${"$_\::DOES"}{$role}) {
            my $rv = ${"$_\::DOES"}{$role};
            unless ($rv) {
                warnif "\$$class\::DOES{$role} is false, returning 1";
                return 1;
            }
            return $rv;
        }
    }

    return $obj->isa($role);
}
1;

