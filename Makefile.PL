use ExtUtils::MakeMaker;

BEGIN { require 5.006001 }

WriteMakefile(
    NAME            => "Class-DOES",
    VERSION_FROM    => "lib/Class/DOES.pm",
    PREREQ_PM       => { 
        "Scalar::Util"  => "1.00",
        "Test::More"    => "0.45",
    },
    ( $ExtUtils::MakeMaker::VERSION < 6.11 ? () :
        AUTHOR          => "Ben Morrow <ben\@morrow.me.uk>",
        ABSTRACT_FROM   => "lib/Class/DOES.pm",
        LICENSE         => "perl",
    ),
    ( $ExtUtils::MakeMaker::VERSION < 6.48 ? () :
        MIN_PERL_VERSION => "5.006001",
        META_MERGE => {
            resources => {
                bugtracker  => "http://rt.cpan.org/NoAuth/Bugs.html?Dist=Class-DOES",
                repository  => "http://github.com/mauzo/Class-DOES",
            },
        },
    ),
);
