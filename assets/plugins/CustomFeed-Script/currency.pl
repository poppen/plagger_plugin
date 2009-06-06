#!/usr/bin/env perl

use strict;
use warnings;
use Finance::Currency::Convert::WebserviceX;
use DateTime;
use YAML;

sub err_msg {
    return "Usage: currency.pl from_currency to_currency [from_currency to_currency] ...\n";
}

my @currencies = @ARGV
    or die err_msg();

my $num_of_currency = @currencies;
die err_msg() unless $num_of_currency % 2 == 0;

my $output = {
    title => "Current Currency Rates",
    entry => [],
};

my $cc = Finance::Currency::Convert::WebserviceX->new;

while (@currencies) {
    my $from_currency = uc( shift(@currencies) );
    my $to_currency = uc( shift(@currencies) );

    my $dt = DateTime->now( time_zone => 'Asia/Tokyo' );

    my $result = $cc->convert(1, $from_currency, $to_currency);

    push @{$output->{entry}}, {
        title => "Currency Rates: $from_currency/$to_currency",
        date  => $dt->iso8601(),
        body => $result
    };
}

print YAML::Dump $output;
