#!/usr/bin/perl -w
#Ultra ultimate Minecraft: BE server query

use strict;
use warnings;

use IO::Socket::INET;

print "\n";

$| = 1;
my ($socket, $data, $redata, $bool, $result, @query, $query, @plugins, $plugins);

$socket = new IO::Socket::INET (
    PeerAddr   => 'some.ip.here:port',
    Proto      => 'udp'
) or die "Error in Socket Creation: $!\n";

$data = "\xFE\xFD" . chr(9) . pack("c*", 0x01, 0x02, 0x03, 0x04) . ""; #■²      ☺☻♥♦
$socket->send($data);

$bool = 1;

while($bool) {
    $socket->recv($redata, 65535);
    $redata = substr($redata, 5, 9);
    $bool = 0;
}

sub replace {
  my ($from, $to, $string) = @_;
  $string =~ s/$from/$to/ig;
  return $string;
}

$data = "\xFE\xFD" . chr(0) . pack("c*", 0x01, 0x02, 0x03, 0x04) . pack("N", $redata) . pack("c*", 0x00, 0x00, 0x00, 0x00); #■² ☺☻♥♦;Ü╔
$socket->send($data);

$bool = 1;

while($bool) {
    $socket->recv($redata, 65535);
    $redata = substr($redata, 5);
    $bool = 0;
}

$result = substr($redata, 11);
@query = split /\x00\x00\x01player_\x00\x00/, $result;

#print \@query;
if($query[1] eq "\x00") {
    print "Player: Null\n";
} else {
    print "Player: " . join(", ", split("\0", $query[1])) . "\n";
}

@query = split /\x00/, $query[0];
my $last = 0;
my $count = 0;

foreach my $val (@query) {
    if($last eq 0) {
        $last = $val;
    } else {
        if($count == 11) { @plugins = split /: /, $val; }
        if($count == 11) {
            if(!$plugins[1] eq "") {
                print "$last (" . scalar(split("; ", $plugins[1])) . "): " . join(", ", split("; ", $plugins[1])) . "\n"; #I don't know why i do this? Bruh
                print "Software: $plugins[0]\n";
            } else {
                print "Software: Vanilla\n";
            }
        } else {
            print "$last: $val\n";
        }
        $last = 0;
    }
    ++$count;
}

sleep(1);
$socket->close();
