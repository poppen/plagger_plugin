use Plagger::Util qw( decode_content );

sub handle {
    my($self, $args) = @_;
    return $args->{entry}->link =~ m|http://www\.technobahn\.com/news/\d+|;
}

sub extract {
    my($self, $args) = @_;
    my $content;

    if (my ($url) =
        $args->{content} =~ m|<form name="myFORM" action="([^"]*)"|) {
        my $ua = Plagger::UserAgent->new;
        my $res = $ua->post($url, { continue => 'y' });
        return if $res->is_error;
        $content = decode_content($res->content);
    } else {
        $content = $args->{content};
    }

    if ($content =~ m|<td bgcolor="#ffffff" height="10%" valign=top>(.*?)</td></tr><tr><td><img src=".*?/images/clear.gif" width=620 height=10>|ms) {
        return $1;
    }
    return;
}
