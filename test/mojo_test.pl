#!/usr/bin/env perl

use Mojo::Base -strict;
use Mojo::IOLoop;

my $loop = Mojo::IOLoop->singleton;

my $now = 1;
my $timeout = 3;
$loop->recurring( 1 => sub {
  print $now++ . "\n";
  boom() unless $timeout--;
});

$loop->timer( 2 => sub { 
  print "Event resets. No boom yet\n";
  $timeout = 3;
});

$loop->start;

sub boom { 
  print "Boom!\n";
  $loop->stop;
}

