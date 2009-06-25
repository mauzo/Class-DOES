#!/usr/bin/perl

use warnings;
use strict;

use t::Utils;
my $T;

{
    package t::Base;
    use Class::DOES "Role::A" => 1;
}

{
    package t::Left;
    our @ISA = "t::Base";
    use Class::DOES "Role::B" => 2;
}

{
    package t::Right;
    our @ISA = "t::Base";
    use Class::DOES "Role::C" => 3;
}

{
    package t::Diamond;
    our @ISA = qw/t::Left t::Right/;
    use Class::DOES "Role::D" => 4;
}

my $obj = bless [], "t::Diamond";

BEGIN { $T += 9 * 2 }

for ("t::Diamond", $obj) {
    does_ok $_, "t::Diamond",   1;
    does_ok $_, "t::Right",     1;
    does_ok $_, "t::Left",      1;
    does_ok $_, "t::Base",      1;
    does_ok $_, "UNIVERSAL",    1;

    does_ok $_, "Role::A",      1;
    does_ok $_, "Role::B",      2;
    does_ok $_, "Role::C",      3;
    does_ok $_, "Role::D",      4;
}

{
    package t::NR::Base;
}

{
    package t::NR::Left;
    our @ISA = "t::NR::Base";
}

{
    package t::NR::Right;
    our @ISA = "t::NR::Base";
    use Class::DOES "Role::E" => 5;
}

{
    package t::NR::Diamond;
    our @ISA = qw/t::NR::Left t::NR::Right/;
}

my $nr = bless [], "t::NR::Diamond";

BEGIN { $T += 6 * 2 }

for ("t::NR::Diamond", $nr) {
    does_ok $_, "t::NR::Diamond",   1;
    does_ok $_, "t::NR::Left",      1;
    does_ok $_, "t::NR::Right",     1;
    does_ok $_, "t::NR::Base",      1;
    does_ok $_, "UNIVERSAL",        1;

    does_ok $_, "Role::E",          5;
}

BEGIN { plan tests => $T }
