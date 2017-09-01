#!/usr/bin/perl
# $Id: 01-serialize.t 1100 2007-12-12 01:48:53Z hachi $
use strict;
use warnings;
use lib 't/lib', 'extlib', 'lib', '../lib', '../extlib';
use Test::More tests => 73;
use_ok 'MT::Serialize';
use MT;
use MT::Test;

my @TESTS = (
    { },
    { foo => undef },
    { '' => 'bar' },
    { foo => '' },
    { foo => 0 },
    { foo => 'bar' },
    { foo => 'bar', baz => 'quux' },
);

for my $meth (qw( Storable MT )) {
    my $ser = MT::Serialize->new($meth);
    isa_ok($ser, 'MT::Serialize', "with $meth");
    for my $hash (@TESTS) {
        my $res = $ser->serialize(\$hash);
        ok($res, 'serialize');
        my $thawed = $ser->unserialize($res);
        ok($thawed, 'unserialize');
        is(ref($thawed), 'REF', 'REF');
        my $hash2 = $$thawed;
        is(ref($hash2), 'HASH', 'HASH');
        for my $key (sort keys %$hash) {
            is($hash->{$key}, $hash2->{$key}, "'$key' values");
        }
    }
}
