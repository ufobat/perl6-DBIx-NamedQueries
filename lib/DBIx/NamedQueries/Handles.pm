use v6.c;

# TODO
# set timezone
# set encoding


role DBIx::NamedQueries::Handle {
    has Str $!driver;
    has Str $!database;

    multi method connect( Str:D $driver, Str:D $database ) {...}
}

class DBIx::NamedQueries::Handles {
    has Array $!read_only = [];
    has Array $!read_write = [];

    method add_read_only(Str:D $type, Str:D $driver, Str:D $database) {
        my $package = 'DBIx::NamedQueries::Handle::' ~ $type;
        require ::($package);
        $!read_only.push( ::($package).new().connect( $driver, $database ));
    }

    method add_read_write(Str:D $type, Str:D $driver, Str:D $database) {
        my $package = 'DBIx::NamedQueries::Handle::' ~ $type;
        require ::($package);
        $!read_write.push( ::($package).new().connect( $driver, $database ));
    }

    method maybe_read_only()  {
        return $!read_only[0] if so $!read_only.elems;
        return self.read_write();
    }

    method read_write() {
        return $!read_write[0] if so $!read_write.elems;
    }
}
