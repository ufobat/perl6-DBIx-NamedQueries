use v6.c;

use Test;

plan 1;

use-ok 'DBIx::NamedQueries::Handles';
my $handes = DBIx::NamedQueries::Handles.new();

isa-ok($handes, 'DBIx::NamedQueries::Handles', 'Instance isa DBIx::NamedQueries::Handles');

diag('TODO: add tests');
