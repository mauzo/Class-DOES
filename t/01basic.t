#!/usr/bin/perl

use warnings;
use strict;

use Test::More;
my $T;

{
    package t::Class;
}

{
    package t::Base;

    our @ISA = qw/t::Class/;

    use Class::DOES qw/Some::Role Some::Other::Role/;
}

{
    package t::OtherBase;

    use Class::DOES qw/Third::Role/;
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

use Data::Dumper;
diag Dumper \%INC;
diag Dumper \@DynaLoader::dl_modules;

my @classes = qw/t::Base t::OtherBase t::SI t::MI t::Diamond/;
my %obj = map +($_ => bless [], $_), @classes;

sub does_ok {
    my ($obj, $role) = @_;
    my $B = Test::More->builder;

    $B->ok(scalar eval { $obj->DOES($role) }, "$obj DOES $role")
        or $B->diag("\$\@: $@");
}

BEGIN { $T += 5 * 2 }

for (@classes) {
    ok eval { $_->can("DOES") },        "$_ can DOES";
    ok eval { $obj{$_}->can("DOES") },  "$_ object can DOES";
}

BEGIN { $T += 5 * 4 }

for ("t::Base", $obj{"t::Base"}, "t::SI", $obj{"t::SI"}) {
    does_ok $_, "t::Base";
    does_ok $_, "t::Class";
    does_ok $_, "UNIVERSAL";
    does_ok $_, "Some::Role";
    does_ok $_, "Some::Other::Role";
}

BEGIN { $T += 2 }

does_ok "t::SI", "t::SI";
does_ok $obj{"t::SI"}, "t::SI";

BEGIN { $T += 8 * 2 }

for ("t::MI", $obj{"t::MI"}) {
    does_ok $_, "t::MI";
    does_ok $_, "t::Base";
    does_ok $_, "t::Class";
    does_ok $_, "t::OtherBase";
    does_ok $_, "UNIVERSAL";
    does_ok $_, "Some::Role";
    does_ok $_, "Some::Other::Role";
    does_ok $_, "Third::Role";
}

BEGIN { plan tests => $T }
