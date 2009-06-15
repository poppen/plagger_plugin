#!/usr/bin/env perl

use strict;
use warnings;
use Finance::Currency::Convert::WebserviceX;
use DateTime::Format::Mail;
use YAML;

sub err_msg {
    return "Usage: currency.pl from_iso_currency_code to_iso_currency_code [from_iso_currency_code to_iso_currency_code] ...\n";
}

my @currencies = @ARGV
    or die err_msg();

my $num_of_currency = @currencies;
die err_msg() unless $num_of_currency % 2 == 0;

my $output = {
    title => "Current Currency Rates",
    entry => [],
};

my $df = DateTime::Format::Mail->new;
my $cc = Finance::Currency::Convert::WebserviceX->new;

while (@currencies) {
    my $from_currency = uc( shift(@currencies) );
    my $to_currency = uc( shift(@currencies) );

    my $result = $cc->convert(1, $from_currency, $to_currency);
    my $dt = $df->parse_datetime( $cc->{'response'}->header('Date') );

    push @{$output->{entry}}, {
        title => "Currency Rates: $from_currency/$to_currency",
        date  => $dt->iso8601(),
        body => $result
    };
}

print YAML::Dump $output;
