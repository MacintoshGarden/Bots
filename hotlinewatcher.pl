#!/usr/bin/perl -w
# Filename : hotlinewatcher.pl
# Bot that watches Hotline chat and sends messages to IRC Borgbot

use warnings;
use strict;

use Socket;
use Net::Hotline::Client;
use YAML::XS 'LoadFile';
use utf8;
use Data::Dumper;

sub Chat_Handler;

my $nick;
my $server;
my $login;
my $password;
my $icon;
my $safenick;

my $socketremote = shift || 'localhost';
my $socketport = shift || 7891;
my $socketserver = "localhost"; # HOST IP running the server

my $socketiaddr = inet_aton($socketremote) or die "Unable to resolve hostname : $socketremote";
my $socketpaddr = sockaddr_in($socketport, $socketiaddr);    #socket address structure

MAIN:
{
    Load_Config();

    my $bot;

    $bot = new Net::Hotline::Client;
    $bot->connect($server);

    Set_Handlers($bot);

    $bot->login(Login => $login,
    Password => $password,
    Nickname => $nick,
    Icon     => $icon);

    $bot->run();
}

sub Load_Config
{
    my $config = LoadFile('config.yaml');

    $nick = $config->{hotline}->{listener}->{nick};
    $server = $config->{hotline}->{listener}->{server};
    $login = $config->{hotline}->{listener}->{login};
    $password = $config->{hotline}->{listener}->{password};
    $icon = $config->{hotline}->{listener}->{icon};

    $safenick = $config->{ignoreNick};
}

sub Set_Handlers
{
    my($bot) = shift;

    $bot->chat_handler(\&Chat_Handler);
    $bot->msg_handler(\&Msg_Handler);
    $bot->join_handler(\&Join_Handler);
    $bot->leave_handler(\&Leave_Handler);
    $bot->nick_handler(\&Nick_Handler);
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

sub Chat_Handler
{
    my($bot, $msg_ref) = @_;
    my($who, $message) = split /:  /, $$msg_ref, 2;
    $who =~ s/^[^\pL]+//;

    if($message eq "userlist")
    {
        Refresh_Userlist($bot);
    }
    elsif(Is_Safe($who))
    {
        Send_to_IRC($bot, "$who: $message");
        return;
    }
}

sub Refresh_Userlist
{
    my($bot) = @_;
    my $userlist = $bot->get_userlist();
    print Dumper($userlist);

}


sub Join_Handler
{
  my($bot, $user) = @_;

  my($nick) = $user->nick();
  my($socket) = $user->socket();

  Send_to_IRC($bot, "** $nick has joined Hotline **");
}

sub Leave_Handler
{
  my($bot, $user) = @_;

  my($nick) = $user->nick();
  my($socket) = $user->socket();

  Send_to_IRC($bot, "** $nick has left Hotline **");
}

sub Nick_Handler
{
    my($bot, $user, $old_nick, $new_nick) = @_;
    Send_to_IRC($bot, "** $old_nick changed his name to $new_nick **");
}

sub Send_to_IRC
{
    my($bot, $msg) = @_;

    my $proto = getprotobyname('tcp');    #get the tcp protocol
    my($sock);
    socket($sock, AF_INET, SOCK_STREAM, $proto) or die $!;

    connect($sock , $socketpaddr) or die "connect failed : $!";

    send($sock , "$msg" , 0);

    close($sock);
    return;
}
