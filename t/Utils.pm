package t::Utils;

use warnings;
use strict;

use Test::More;

require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = (
    @Test::More::EXPORT,
    qw/does_ok/,
);

sub does_ok {
    my ($obj, $role, $ver) = @_;
    my $B = Test::More->builder;

    my $does = eval { $obj->DOES($role) };
    $B->is_eq($does, $ver, "$obj DOES $role ($ver)")
        or $B->diag("\$\@: $@");
}

1;

