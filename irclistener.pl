#!/usr/bin/perl -w
# Filename : irclistener.pl
# Bot that watches IRC chat and sends messages to Hotlinespeaker bot.

use warnings;
use strict;

package IRCWatcher;
use POE;
use base qw( Bot::BasicBot );
use Socket;
use YAML::XS 'LoadFile';
use YAML::XS 'DumpFile';
use Encode 'encode';
use utf8;

my $nick;
my $server;
my $port;
my $password;
my $channel;
my $safenick;
my $bridgenick;
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
    $nick = $config->{irc}->{listener}->{nick};
    $server = $config->{irc}->{listener}->{server};
    $port = $config->{irc}->{listener}->{port};
    $password = $config->{irc}->{listener}->{password};
    $channel = $config->{irc}->{listener}->{channel};
    $safenick = $config->{ignoreNick};
    $bridgenick = $config->{BridgeBotNick}[0];

    return;

}

sub Prepare_Socket {

    my $remote = shift || 'localhost';
    my $socketport = shift || 7890;
    my $iaddr = inet_aton($remote) or die "Unable to resolve hostname : $remote";
    my $paddr = sockaddr_in($socketport, $iaddr);    #socket address structure

    return $paddr;

}

sub Create_Bot {

    my $bot = IRCWatcher->new(
        nick => $nick,
        server => $server,
        channels => $channel,
        password => $password,
        port => $port,
        SSL => 0,
        no_run => 1,
    );

    # Run the IRC Bot
    $bot->run();

    # Start the main event loop
    $poe_kernel->run();

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

# Do this if chat appears in IRC
sub said {

    my $self = shift;
    my $message = shift;

    # Prepare msg
    my $body = $message->{body}; # Get message of user
    my $who = $message->{who}; # Get nick of user
    my $msg;

    	if ($who eq $bridgenick) {
	$msg = $body; # Compose msg without brigde nick bot name
	}
	else {
	$msg = $who.": ".$body; # Compose msg
	}

	if(Is_Safe($who))
	{
	Send_to_Hotline($msg);
	}

    return;

}

sub Send_to_Hotline {

    my($msg) = @_;

    #Initialize host and port of hotline bot socket connection
    my $proto = getprotobyname('tcp');    #get the tcp protocol
    my($sock);
    socket($sock, AF_INET, SOCK_STREAM, $proto) or die $!;

    connect($sock , $socketpaddr) or die "connect failed : $!";

    my $encmsg = encode('utf-8', $msg);
    send($sock , "$encmsg" , 0);

    close($sock);

    return;

}
