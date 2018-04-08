use v6.c;

use DBIish;
use DBIx::NamedQueries::Handles;

class DBIx::NamedQueries::Handle::DBIish does DBIx::NamedQueries::Handle {

    multi method connect( Str:D $driver, Str:D $database ) {
        return DBIish.connect( $driver, :database( $driver ) );
    }
}
