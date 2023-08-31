#!/usr/bin/perl -w
# Filename : hotlinelistener.pl
# Bot that watches Hotline chat and sends messages to IRCspeaker bot
# Idiotic changes made by Theo Knez for Macintosh Garden & System 7 Today

use warnings;
use strict;

use Socket;
use Net::Hotline::Client;
use YAML::XS 'LoadFile';
use YAML::XS 'DumpFile';
use YAML::XS 'Dump';
use Encode 'from_to';
use utf8;

my $nick;
my $server;
my $login;
my $password;
my $icon;
my $safenick;
my $socketpaddr;
my $bot;

MAIN: {

    Load_Config();
    $socketpaddr = Prepare_Socket();
    Create_Bot();

    exit;

}

sub Load_Config {

    my $config = LoadFile('config.yaml');
    $nick = $config->{hotline}->{listener}->{nick};
    $server = $config->{hotline}->{listener}->{server};
    $login = $config->{hotline}->{listener}->{login};
    $password = $config->{hotline}->{listener}->{password};
    $icon = $config->{hotline}->{listener}->{icon};
    $safenick = $config->{ignoreNick};

    return;

}

sub Prepare_Socket {

    my $socketremote = shift || 'localhost';
    my $socketport = shift || 7891;
    my $socketiaddr = inet_aton($socketremote) or die "Unable to resolve hostname : $socketremote";
    my $socketpaddr2 = sockaddr_in($socketport, $socketiaddr);    #socket address structure
    return $socketpaddr2;

}

sub Create_Bot {

    $bot = new Net::Hotline::Client;
    $bot->connect($server);
    Set_Handlers($bot);
    $bot->login(Login => $login,
    Password => $password,
    Nickname => $nick,
    Icon     => $icon);
    $bot->run();

    return;

}

sub Set_Handlers {

    my($bot) = @_;
    $bot->chat_handler(\&Chat_Handler);
    $bot->msg_handler(\&Msg_Handler);

    return;

}

sub Is_Safe {

    my($who) = @_;
    my $safe = 1;

    foreach ( @{ $safenick } ) {
        if ($who eq $_)
        {
            $safe = 0
        }
    }

    return $safe;
}

sub Chat_Handler {

    my($bot, $msg_ref) = @_;
    my($who, $message) = split /:  /, $$msg_ref, 2;
    $who =~ s/^[^\pL]+//;

	if(Is_Safe($who)) {
	Send_to_IRC($bot, "$who: $message");	
	}
    }

sub Send_to_IRC {

    my($bot, $msg) = @_;

    my $proto = getprotobyname('tcp');    #get the tcp protocol
    my($sock);
    socket($sock, AF_INET, SOCK_STREAM, $proto) or die $!;
    connect($sock , $socketpaddr) or die "connect failed : $!";

    from_to($msg, "MacRoman", "latin1");
    send($sock , "$msg" , 0);
    close($sock);

    return;
}
