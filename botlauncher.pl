#!/usr/bin/perl -w
# Filename : botlauncher.pl
# Launcher for bots that watches Hotline chat and sends messages to IRC

use warnings;
use strict;
use IPC::System::Simple qw(system);

MAIN:
{
    system("perl hotlinelistener.pl &");
    system("perl ircspeaker.pl &");
    system("sleep 3");
    system("perl irclistener.pl &");
    system("perl hotlinespeaker.pl &");
}
