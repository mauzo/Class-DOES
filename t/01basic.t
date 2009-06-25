#!/usr/bin/perl

use warnings;
use strict;

use t::Utils;
my $T;

{
    package t::Class;
}

{
    package t::Base;

    our @ISA = qw/t::Class/;

    use Class::DOES 
        "Some::Role"        => "1.00",
        "Some::Other::Role" => "2.01";
}

{
    package t::OtherBase;

    use Class::DOES "Third::Role" => "4.56";
}

{
    package t::SI;

    our @ISA = qw/t::Base/;
}

{
    package t::MI;

    our @ISA = qw/t::Base t::OtherBase/;
}

{
    package t::Diamond;

    our @ISA = qw/t::SI t::MI/;
}

my %obj = map +($_ => bless [], $_),
    qw/t::Base t::OtherBase t::SI t::MI t::Diamond/;

BEGIN { $T += 5 * 2 }

for (keys %obj) {
    ok eval { $_->can("DOES") },        "$_ can DOES";
    ok eval { $obj{$_}->can("DOES") },  "$_ object can DOES";
}

BEGIN { $T += 5 * 4 }

for ("t::Base", $obj{"t::Base"}, "t::SI", $obj{"t::SI"}) {
    does_ok $_, "t::Base",              1;
    does_ok $_, "t::Class",             1;
    does_ok $_, "UNIVERSAL",            1;
    does_ok $_, "Some::Role",           "1.00";
    does_ok $_, "Some::Other::Role",    "2.01";
}

BEGIN { $T += 2 }

does_ok "t::SI", "t::SI",           1;
does_ok $obj{"t::SI"}, "t::SI",     1;

BEGIN { $T += 8 * 4 }

for ("t::MI", $obj{"t::MI"}, "t::Diamond", $obj{"t::Diamond"}) {
    does_ok $_, "t::MI",                1;
    does_ok $_, "t::Base",              1;
    does_ok $_, "t::Class",             1;
    does_ok $_, "t::OtherBase",         1;
    does_ok $_, "UNIVERSAL",            1;
    does_ok $_, "Some::Role",           "1.00";
    does_ok $_, "Some::Other::Role",    "2.01";
    does_ok $_, "Third::Role",          "4.56";
}

BEGIN { plan tests => $T }
