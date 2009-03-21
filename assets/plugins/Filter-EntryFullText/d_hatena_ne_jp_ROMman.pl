sub handle_force {
    my($self, $args) = @_;
    $args->{entry}->link =~ qr!^http://d\.hatena\.ne\.jp/ROMman/!;
}

sub extract {
    my($self, $args) = @_;

    if ($args->{entry}->link =~ m!#(.*)$!) {
        my $name = $1;
        my $match =
            qq!<h3><a href=".*?" name="$name">.*?</h3>(.*?)<p>\x{3000}</p>!;

        if ( $args->{content} =~ /$match/s ){
            my $body = $1;
            return "<div>$body</div>";
        }
    }
    return;
}
