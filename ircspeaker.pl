#!/usr/bin/perl -w
# Filename : ircspeaker.pl
# Bot that receives msg's from Hotlinelistener bot and posts them to IRC chat

use warnings;
use strict;

package IRCBorgBot;
use base 'Bot::BasicBot';
use Socket;
use YAML::XS 'LoadFile';
use Encode 'from_to';
use utf8;

my $nick;
my $server;
my $port;
my $password;
my $channel;

MAIN: {

    Load_Config();
    Create_Socket();
    IRCBorgBot->new(nick => $nick, channels => [ $channel ], server => $server, password => $password, port => $port, SSL => 0, )->run;

    exit;

}

sub Load_Config {

    my $config = LoadFile('config.yaml')->{irc}->{speaker};
    $nick = $config->{nick};
    $server = $config->{server};
    $port = $config->{port};
    $password = $config->{password};
    $channel = $config->{channel};

    return;

}

sub Create_Socket {

    # Set up server to get msg's from Hotline bot
    my $IRCport = shift || 7891;
    my $IRCproto = getprotobyname('tcp');
    my $IRCserver = "localhost";  # Host IP running the server

    # create a socket, make it reusable
    socket(SOCKET, PF_INET, SOCK_STREAM, $IRCproto)
    or die "Can't open socket $!\n";
    setsockopt(SOCKET, SOL_SOCKET, SO_REUSEADDR, 1)
    or die "Can't set socket option to SO_REUSEADDR $!\n";

    # bind to a port, then listen
    bind( SOCKET, pack_sockaddr_in($IRCport, inet_aton($IRCserver)))
    or die "Can't bind to port $IRCport! \n";

    listen(SOCKET, 5) or die "listen: $!";
    print "SERVER started on port $IRCport\n";

    return;

}

#### IRC event handlers overload ####
sub connected {

    my $self = shift;
    $self->forkit({ channel => $channel,
        run     => \&receive_message,
        arguments => [ $self ],
    });

    return;

}

sub receive_message {

    my $self = shift;
    while (1) {
        # accepting a connection
        my $client_addr;
        while ($client_addr = accept(NEW_SOCKET, SOCKET)) {

            # receive a message, send to IRC chat, close connection
            my $name = gethostbyaddr($client_addr, AF_INET );
            my $line;
            my $msg;

            while ($line = <NEW_SOCKET>) {
#		from_to($line, "utf-8", "utf-8");
                print("$line\n");
            }
            close NEW_SOCKET;
        }
    }

    return;

}
