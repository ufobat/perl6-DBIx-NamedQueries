use v6.c;

use DBIish;

class DBIx::NamedQueries { 

    has Str   $.divider = '/';
    has Str   $.namespace;
    has Hash  $.handle;
    has Array $.handles = [];

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

    method !handle_first () {
        self.connect() if (!$.handles.elems);
        return $.handles[0];
    }

    method !handle_last () {
        self.connect() if (!$.handles.elems);
        return $.handles[$.handles.end]; 
    }

    method !handle_with (Str:D $name) {
        #TODO run through handles and with this one with name $name
    }

    method !param_filler( Hash:D $given_params, Array:D $fields) {
        return [] if !$given_params.elems;
        my @params;
        for @($fields) -> $field {
            push @params, %($given_params){$field<name>};
        }
        return @params;
    }

    multi method read(Str:D $context){ return self.read($context, {}); }
    multi method read(Str:D $context, Hash:D $params){
        my %query_from_string = self!query_from_string('Read'~ $.divider ~ $context, $params);
        my $sth    = self!handle_first.prepare( %query_from_string.<statement> );
        my $execute_params = self!param_filler($params, %query_from_string<fields>);
        $sth.execute( self!param_filler($params, %query_from_string<fields>) );
        return $sth.allrows(:array-of-hash);
    }
    
    multi method write(Str:D $context){ return self.write($context, {}); }
    multi method write(Str:D $context, Hash:D $params){
        my %from_string = self!query_from_string('Write'~ $.divider ~ $context, $params);
        my $sth = self!handle_first.prepare(%from_string.<statement>);
        return $sth.execute( map { %($params){$_} }, @(%from_string<fields>) );
    }

    method create(Str:D $context){
        return self!handle_first.do(self!query_from_string($context).create.{'statement'});
    }

    method connect () {
        $.handles.push(DBIish.connect($.handle<driver>, :database($.handle<database>)));
    }

}

role DBIx::NamedQueries::Read {
    method select( %params ) { ... }
    method list(   %params ) { ... }
    method find(   %params ) { ... }
}

role DBIx::NamedQueries::Write{
    method create( %params ) { ... }
    method alter(  %params ) { ... }
    method insert( %params ) { ... }
    method update( %params ) { ... }
}

=begin pod

=head1 NAME

App::Football - Contains methods for football program

=head1 SYNOPSIS

Declare your query class

=begin code

    use DBIx::NamedQueries;

    class MyApp::Your::Queries::Read::User does DBIx::NamedQueries::Read {

        method select( %params ) { 
            return {
                fields => [
                    { name => 'description' },
                ],
                statement => q@
                    SELECT
                        *
                    FROM
                        users
                    WHERE 1
                        @ ~  ( %params<description>:exists ?? q@AND description = ?@ !! q@
                    @ )
                ,
            };
        }
        method list( %params ) {  }
        method find( %params ) {  }
    }

=end code

Usinf the nq object

=begin code

    my $named_queries = DBIx::NamedQueries.new(
        divider   => '|',
        namespace => 'MyApp::Your::Queries',
        handle    => {
            driver => 'SQLite',
            database => 'test.sqlite3',
        }
    );

    
    $named_queries.read: 'user|select', {
        description  => 'Developer',
    }

=end code

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head1 METHODS

=head2 read

=head2 write

=head1 AUTHOR

Mario Zieschang, C<< <mziescha at cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2017 Mario Zieschang

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=end pod
