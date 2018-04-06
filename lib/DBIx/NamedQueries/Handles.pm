use v6.c;

use DBIish;

# TODO
# set timezone
# set encoding

class DBIx::NamedQueries::Handles {
    has Array $!read_only = [];
    has Array $!read_write = [];

    method add_read_only($driver, $database) {
        $!read_only.push( DBIish.connect( $driver, :database( $database ) ) );
    }

    method add_read_write($driver, $database) {
        $!read_write.push( DBIish.connect( $driver, :database( $database ) ) );
    }

    method maybe_read_only()  {
        return $!read_only[0] if so $!read_only.elems;
        return self.read_write();
    }

    method read_write() {
        return $!read_write[0] if so $!read_write.elems;
    }
}
