use v6.c;
use DBIish;

class DBIx::NamedQueries { 

    has Str $.divider = '/';
    has Str $.namespace;
    has Str $.driver;
    has Str $.database;
    has $!dbh;

     method !query_from_string(Str:D $context){
        my $namespace = $.namespace ~ '::' ~ join '::', map { 
                $_.tc eq 'R' ?? 'Read' !! $_.tc eq 'W' ?? 'Write' !! $_.tc
            }, split $!divider, $context;;
        say $namespace;
        require ::($namespace);
        return ::($namespace).new;
    }

    method create(Str:D $context){
        return self.connect.do(self!query_from_string($context).create.{'statement'});
    }

    method insert(Str:D $context, $hr_params){
        my %insert = self!query_from_string($context).insert;
        my $sth = self.connect.prepare(%insert.<statement>);
        my @a_insert = map { %($hr_params){$_} }, @(%insert<fields>);
        return $sth.execute(@a_insert);
    }

    method select(Str:D $context, $hr_params){
        my %select = self!query_from_string($context).select;
        my $sth = self.connect.prepare( %select.<statement> );
        $sth.execute();
        my @rows = $sth.allrows();
        return @rows;
    }

    method connect () {
      return $!dbh if $!dbh;
      $!dbh = DBIish.connect($.driver, :database<$.database>);
      return $!dbh;
    }
}

role DBIx::NamedQueries::Read {
    method select( $hr_params ) { ... }
    method list(   $hr_params ) { ... }
    method find(   $hr_params ) { ... }
}

role DBIx::NamedQueries::Write{
    method create($archive-file, $target-dir) { ... }
    method alter($archive-file) { ... }
    method insert($s_namespace, $hr_params) { ... }
    method update($path) { ... }
}
