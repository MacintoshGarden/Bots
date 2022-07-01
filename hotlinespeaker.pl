#!/usr/bin/perl -w
# Filename : hotlinespeaker.pl
# Bot that receives msg's from IRClistener bot and posts them to Hotline chat

use warnings;
use strict;

use Socket;
use POE;
use IO::File;
use Net::Hotline::Client;
use YAML::XS 'LoadFile';
use Encode 'from_to';
use utf8;

my $nick;
my $server;
my $login;
my $password;
my $icon;
my $bot;

MAIN: {

    Load_Config();
    Create_Bot();
    Create_Socket();
    Recieve_Message();

    exit;

}

sub Load_Config {

    my $config = LoadFile('config.yaml')->{hotline}->{speaker};
    $nick = $config->{nick};
    $server = $config->{server};
    $login = $config->{login};
    $password = $config->{password};
    $icon = $config->{icon};

    return;

}

sub Create_Bot {

    # Create and connect Hotline bot
    $bot = new Net::Hotline::Client;
    $bot->connect($server);

    # Login Hotline bot
    $bot->login(Login => $login,
    Password => $password,
    Nickname => $nick,
    Icon     => $icon);

    return;

}

 sub Create_Socket {

    # Initialize socket connection to IRC Bot
    my $socketport = shift || 7890;
    my $proto = getprotobyname('tcp');
    my $socketserver = "localhost";  # Host IP running the server

    # create a socket, make it reusable
    socket(SOCKET, PF_INET, SOCK_STREAM, $proto)
    or die "Can't open socket $!\n";
    setsockopt(SOCKET, SOL_SOCKET, SO_REUSEADDR, 1)
    or die "Can't set socket option to SO_REUSEADDR $!\n";

    # bind to a port, then listen
    bind( SOCKET, pack_sockaddr_in($socketport, inet_aton($socketserver)))
    or die "Can't bind to port $socketport! \n";

    listen(SOCKET, 5) or die "listen: $!";
    print "SERVER started on port $socketport\n";

    return;

}

sub Recieve_Message {

    # Receive a msg and post to Hotline chat
    my $client_addr;

    while ($client_addr = accept(NEW_SOCKET, SOCKET)) {
        my $name = gethostbyaddr($client_addr, AF_INET );
        my $line;

        while ($line = <NEW_SOCKET>) {
	from_to($line, "utf-8", "MacRoman");
            $bot->chat($line);
        }
    }

    return;

}


