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

    	if ($who eq "Discoline") {
	$msg = $body; # Compose msg without Discord bot name
	}
	else {
	$msg = $who.": ".$body; # Compose msg
	}

    Write_Userlist($self);

    if(Is_Safe($who))
    {
        if($body eq "!userlist") {
            Get_Userlist($self, $who);
        }
        else {
            Send_to_Hotline($msg);
        }
    }

    return;

}

sub chanjoin {

    my $self = shift;
    my $message = shift;

    Write_Userlist($self);

    my $who = $message->{who};
    my $msg = "** ".$who." has joined IRC **"; # Compose msg

    Send_to_Hotline($msg);

    return;

}

sub chanpart {

    my $self = shift;
    my $message = shift;

    Write_Userlist($self);

    my $who = $message->{who};
    my $msg = "** ".$who." has left IRC **"; # Compose msg

    Send_to_Hotline($msg);

    return;
}

sub userquit {

    my $self = shift;
    my $message = shift;

    Write_Userlist($self);

    my $who = $message->{who};
    my $msg = "** ".$who." has left IRC **"; # Compose msg


    Send_to_Hotline($msg);

    return;

}

sub nick_change {

    my($self, $old_nick, $new_nick) = @_;

    Write_Userlist($self);

    Send_to_Hotline("** $old_nick changed his name to $new_nick **");

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

sub Get_Userlist {

    my ($self, $who) = @_;
    my $userlist = LoadFile('hl_userlist.yaml');
    my $msg = "Hotline Userlist: ";
    for my $user (@{$userlist}) {
        $msg = $msg . $user . ", ";
    }
    $self->say(channel => $channel, body => substr($msg, 0, -2));

    return;

}

sub Write_Userlist {

    my $self = shift;
    my %userlist = %{$self->channel_data($channel)};
    my $nickname;
    my $userlist;

    for(keys %userlist) {
        if(Is_Safe($_))
        {
            push @$userlist, $_;
        }
    }
    DumpFile( "irc_userlist.yaml", $userlist );

    return;
}
