use v6.c;

use DBIx::NamedQueries::Handles;

class DBIx::NamedQueries { 

    has Str   $.divider = '/';
    has Str   $.namespace;
    has Hash  $.handle;
    has DBIx::NamedQueries::Handles $.handles = DBIx::NamedQueries::Handles.new();

    method !object_from_string(Str:D $s_package){
        require ::($s_package);
        return ::($s_package).new;
    }

    method !query_from_string(Str:D $context, Hash:D $hr_params){
        my @splitted_context = split $!divider, $context;
        my $s_sub = pop @splitted_context;
        my $obj_query = self!object_from_string(
            $.namespace ~ '::' ~ join '::', map { $_.tc }, @splitted_context
        );
        return $obj_query."$s_sub"($hr_params);
    }
    
    method !param_filler( Hash:D $given_params, Array:D $fields) {
        return [] if !$given_params.elems;
        my @params;
        for @($fields) -> $field {
            push @params, %($given_params){$field<name>};
        }
        return @params;
    }

    method !handle_rw () {
        my $handle_rw = self.handles.read_write();
        return $handle_rw if $handle_rw;
        $.handles.add_read_write( $.handle<driver>, $.handle<database> );
        return self.handles.read_write();
    }

    method !handle_ro () {
        my $handle_ro = self.handles.maybe_read_only();
        return $handle_ro if $handle_ro;
        $.handles.add_read_only( $.handle<driver>, $.handle<database> );
        return self.handles.maybe_read_only(); 
    }

    multi method read(Str:D $context){ return self.read($context, {}); }
    multi method read(Str:D $context, Hash:D $params){
        my %from_string = self!query_from_string('Read'~ $.divider ~ $context, $params);
        my $sth    = self!handle_ro.prepare( %from_string.<statement> );
        %from_string<fields>:exists ?? $sth.execute( self!param_filler($params, @(%from_string<fields>)) ) !! $sth.execute();
        return $sth.allrows(:array-of-hash);
    }

    multi method write(Str:D $context){ return self.write($context, {}); }
    multi method write(Str:D $context, Hash:D $params){
        my %from_string = self!query_from_string('Write'~ $.divider ~ $context, $params);
        my $handle = self!handle_rw;
        my $sth = self!handle_rw.prepare(%from_string.<statement>);

        if %from_string<fields>:exists {
            my @fields = @(%from_string<fields>);
            return $sth.execute( map { %($params){$_} }, @fields );
        }
        return $sth.execute();
    }

    method find (Str:D $context, Hash:D $params) {
        return self.read: $context ~ self.divider ~ 'find', $params;
    }

    method list (Str:D $context, Hash:D $params) {
        return self.read: $context ~ self.divider ~ 'list', $params;
    }

    method select (Str:D $context, Hash:D $params) {
        return self.read: $context ~ self.divider ~ 'select', $params;
    }

    method alter (Str:D $context, Hash:D $params) {
        return self.write: $context ~ self.divider ~ 'alter', $params;
    }

    method create (Str:D $context) {
        return self.write: $context ~ self.divider ~ 'create';
    }

    method insert (Str:D $context, Hash:D $params) {
        return self.write: $context ~ self.divider ~ 'insert', $params;
    }

    method update (Str:D $context, Hash:D $params) {
        return self.write: $context ~ self.divider ~ 'update', $params;
    }
}

role DBIx::NamedQueries::Read {
    method find(   %params ) { ... }
    method list(   %params ) { ... }
    method select( %params ) { ... }
}

role DBIx::NamedQueries::Write{
    method alter(  %params ) { ... }
    method create( %params ) { ... }
    method insert( %params ) { ... }
    method update( %params ) { ... }
}
