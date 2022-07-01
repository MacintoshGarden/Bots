#!/usr/bin/perl -w
# Filename : botlauncher.pl
# Bot that watches Hotline chat and sends messages to IRC Borgbot

use warnings;
use strict;
use IPC::System::Simple qw(system);

MAIN:
{
    system("perl hotlinespeaker.pl &");
    system("perl hotlinelistener.pl &");
    system("perl ircspeaker.pl &");
    system("perl irclistener.pl &");
}
