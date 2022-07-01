#!/usr/bin/perl -w
# Filename : hotlinelistener.pl
# Bot that watches Hotline chat and sends messages to IRCspeaker bot

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
    $bot->join_handler(\&Join_Handler);
    $bot->leave_handler(\&Leave_Handler);
    $bot->nick_handler(\&Nick_Handler);

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

    if($message eq "userlist")
    {
        Refresh_Userlist($bot);
    }
    elsif(Is_Safe($who))
    {
        if($message eq "!userlist") {
            Get_Userlist($bot, $who);
        }
        else {
            Send_to_IRC($bot, "$who: $message");
        }
    }

sub Refresh_Userlist
{
    my($bot) = @_;
    my $userlist = $bot->get_userlist();
    print Dumper($userlist);

}

    return;
}


sub Join_Handler {

    my($bot, $user) = @_;
    my($nick) = $user->nick();
    my($socket) = $user->socket();
#    Send_to_IRC($bot, "** $nick has joined Hotline **");
    Write_Userlist($bot);

    return;
}

sub Leave_Handler {

    my($bot, $user) = @_;
    my($nick) = $user->nick();
    my($socket) = $user->socket();
#    Send_to_IRC($bot, "** $nick has left Hotline **");
    Write_Userlist($bot);

    return;
}

sub Nick_Handler {

    my($bot, $user, $old_nick, $new_nick) = @_;
#    Send_to_IRC($bot, 0, "** $old_nick changed his name to $new_nick **");
    Write_Userlist($bot);

    return;
}

sub Send_to_IRC {

    my($bot, $msg) = @_;

    my $proto = getprotobyname('tcp');    #get the tcp protocol
    my($sock);
    socket($sock, AF_INET, SOCK_STREAM, $proto) or die $!;
    connect($sock , $socketpaddr) or die "connect failed : $!";

#    my $encmsg = encode("utf-8", $msg);
    from_to($msg, "macroman", "latin1");
    send($sock , "$msg" , 0);
    close($sock);

    return;
}

sub Write_Userlist {

    my($bot) = @_;

    $bot->req_userlist();
    my %userlist = %{$bot->userlist()};
    my $nickname;
    my $userlist;

    for(keys %userlist){
        $nickname = $userlist { $_ }->{ NICK };
        if(Is_Safe($nickname))
            {
                push @$userlist, $nickname;
            }
    }

    DumpFile( "hl_userlist.yaml", $userlist );

    return;
}

sub Get_Userlist {
    my ($self, $who) = @_;
    my $userlist = LoadFile('irc_userlist.yaml');
    my $msg = "IRC Userlist: ";

    for my $user (@{$userlist}) {
        $msg = $msg . $user . ", ";
    }

    $self->chat(substr($msg, 0, -2));

    return;
}
