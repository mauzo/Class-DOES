#!/usr/bin/perl

use warnings;
use strict;

use Test::More;
use Class::DOES;

my $T;

my @warns;
$SIG{__WARN__} = sub { push @warns, $_[0] };

my $PKG = "TestAAAA";

sub doimport {
    my $args = join ",", map qq{"\Q$_\E"}, @_;
    my $B = Test::More->builder;

    @warns = ();
    eval qq{
        package t::NW::$PKG;
        no warnings "Class::DOES";
        Class::DOES->import($args);
    };
    $B->ok(!@warns, "warnings can be disabled")
        or $B->diag(join "\n", @warns);

    @warns = ();
    eval qq{
        package t::$PKG;
        Class::DOES->import($args);
    };
}

sub inherit {
    no strict "refs";
    @{"t\::$PKG\::ISA"} = @_;
    @{"t\::NW\::$PKG\::ISA"} = @_;
}

sub got_warns {
    my ($warns, $name) = @_;
    my $B = Test::More->builder;
    $B->is_num(scalar @warns, $warns, $name)
        or $B->diag(join "\n", @warns);
}

BEGIN { $T += 4 }

doimport;
got_warns 0,                            "empty import doesn't warn";

doimport "Foo::Bar" => 1;
got_warns 0,                            "correct import doesn't warn";

BEGIN { $T += 11 }

$PKG++;
doimport "Foo::Bar" => 0;
got_warns 1,                            "false value warns";
like $warns[0], qr/False value.*->DOES\(Foo::Bar\)/,
                                        "...correctly";
is "t::$PKG"->DOES("Foo::Bar"), 1,      "value adjusted"; 

$PKG++;
doimport qw/Foo::Bar/;
got_warns 2,                            "odd import list warns";
like $warns[0], qr/Odd number of.*forget to include/s,
                                        "...correctly";
like $warns[1], qr/False value/,        "...correctly";

$PKG++;
doimport qw/Foo::Bar Bar::Baz/;
got_warns 1,                            "version-like-pkg warns";
like $warns[0], 
    qr/'Bar::Baz' for ->DOES\(Foo::Bar\) looks like.*forget/s,
                                        "...correctly";

BEGIN { $T += 8 }

{
    package t::Does;
    sub DOES { 1 }
}

$PKG++;
inherit "t::Does";
doimport;
got_warns 1,                            "bad ->DOES warns";
like $warns[0], qr/t::$PKG.*incompatible ->DOES/,
                                        "...correctly";

{
    package t::MyDoes;
    use Class::DOES;
}

$PKG++;
inherit "t::MyDoes";
doimport;
got_warns 0,                            "my ->DOES doesn't warn";

{
    package t::Isa;
    sub isa { 1 }
}

$PKG++;
inherit "t::Isa";
doimport;
got_warns 1,                            "bad ->isa warns";
like $warns[0], qr/t::$PKG doesn't use \@ISA/,
                                        "...correctly";


BEGIN { plan tests => $T }
