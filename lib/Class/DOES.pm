package Class::DOES;

use warnings;
use strict;

use Scalar::Util qw/blessed/;

our $VERSION = "1.00";

use subs "get_mro";

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

    @{"$pkg\::DOES"} = @roles;
    *{"$pkg\::DOES"} = sub {
        my ($obj, $role) = @_;

        warn "before blessed:" . $obj->isa($role);

        my $class = blessed $obj || $obj;

        warn "before get_mro:" . $obj->isa($role);
        
        for (get_mro $class) {
            warn "trying $_ for $class";
            if (grep $_ eq $role, @{"$_\::DOES"}) {
                return 1;
            }
        }

        warn "trying $obj->isa($role)";
        my $rv = $obj->isa($role);
        warn "GOT: $rv";
        return $rv;
    };
}

1;

