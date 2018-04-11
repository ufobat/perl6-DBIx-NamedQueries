use v6.c;

use Test;

plan 4;

use-ok 'DBIx::NamedQueries::Handles';
use-ok 'DBIx::NamedQueries::Handle::DBIish';

subtest {
    plan 1;

    isa-ok(
        DBIx::NamedQueries::Handle::DBIish.new,
        'DBIx::NamedQueries::Handle::DBIish',
        'Instance isa DBIx::NamedQueries::Handle::DBIish'
    );
};

subtest {
    plan 1;

    isa-ok(
        DBIx::NamedQueries::Handles.new,
        'DBIx::NamedQueries::Handles',
        'Instance isa DBIx::NamedQueries::Handles'
    );
};