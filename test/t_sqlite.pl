#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use v5.10;
use Smart::Comments;

my $dbh = DBI->connect('dbi:SQLite:/Users/apple/py/mysite/db.sqlite3', '', '');

# prepare 的sql语句只能是一条，不可以是多条sql语句用;连接
my $sth = $dbh->prepare('select count(*) from itao_img; insert into itao_img values (NULL, ?);');
for my $test ( 'a'..'z' ) {
    $sth->execute($test);
    my @tables = $sth->fetchrow_array;
    ### @tables
}

