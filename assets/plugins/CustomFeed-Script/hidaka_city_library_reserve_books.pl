#!/usr/bin/env perl 
use strict;
use warnings;
use URI;
use WWW::Mechanize;
use Config::Pit;
use Web::Scraper;
use DateTime;
use YAML;
use Data::Dumper;

# get password
my $config = pit_get("www.lib.hidaka.saitama.jp", require => {
        "username" => "your username",
        "password" => "your password"
    });

# access
my $url = "http://www.lib.hidaka.saitama.jp/kensaku/Reserve/Reserve.asp";
my $mech = WWW::Mechanize->new( autocheck => 1 );
my $response = $mech->get( $url );

# login
$mech->submit_form(
    fields => {
        User => $config->{username},
        Password => $config->{password},
        button => 'CmdLogin',
        Dummy1 => 0,
        Dummy2 => 0,
        Dummy3 => 0,
        Dummy4 => 0,
        Mode => 'Login',
        CookieTilcodes=> '',
    },
);

## scrape
my $feed = scraper {
    process '//title', 'title' => 'TEXT';
    process '//table[@class="cntTable"]//tr[position() != 1]',
        'entry[]' => scraper {
            process '//tr/descendant::td[3]/descendant::a/text()', 'title' => 'TEXT';
            process '//tr/descendant::td[3]/descendant::a/text()', 'body' => 'TEXT';
            process '//tr/descendant::td[6]', 'date' => sub {
                return unless ($_->as_text() =~ m!(\d{4})/(\d{2})/(\d{2})!);

                my $dt = DateTime->new( time_zone => 'Asia/Tokyo',
                                        year => $1,
                                        month => $2,
                                        day => $3,
                                      );
                return $dt->iso8601();
            }
        };
}->scrape($mech->content, $mech->uri);

$feed->{link}  = $url;

# output
binmode STDOUT, ":utf8";
print YAML::Dump $feed;
