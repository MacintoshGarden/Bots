# Hotline to IRC bridge

The Hotline to IRC bridge is based on hotline-irc-bridge found here: https://gitlab.com/hlborg/hotline-irc-bridge.
Our modifications add support for UTF-8 to MacRoman and MacRoman to UTF-8 encoding as well as support for "another bot" to be able to bridge to Discord and other chat systems in an easier and more aestatically pleasing way. Some bugs have been fixed as well.

## Perl Module Dependencies & Installation

- Bot::BasicBot
- Net::Hotline::Client
- YAML::XS
- Socket
- IO::Filename
- utf8
- POE
- IPC::System::Simple

The easiest way to install the Hotline to IRC bridge is through cpanminus, since it manages all the nestled dependencies for you.

Install cpanminus:
```
  cpan App::cpanminus
```

Once cpanminus is installed, install the Hotline to IRC bridge dependencies:
```
  cpanm Bot::BasicBot Net::Hotline::Client YAML::XS Socket IO::Filename utf8 POE IPC::System::Simple
```


## Hotline to IRC bridge configuration file

The configuration file is pretty straight forward. Remember to define your "BridgeBotNick" to whatever you have set your Matterbridge IRC nick to be, otherwise you might end up with an endless message loop with the bots sending messages back and forth.


## Matterbridge configuration file
Matterbridge is used to bridge IRC to Discord, which effectively brings Hotline to Discord (and Discord to Hotline).
The configuration file found in this repository is what we use for our implementation.

The Discord side of the bridge is configured using this guide:
https://github.com/42wim/matterbridge/wiki/Section-Discord-(basic)

Sensitive data have been removed and placeholder text have been added in it's place.
