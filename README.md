# Hotline to IRC bridge

The Hotline to IRC bridge is based on hotline-irc-bridge found here: https://gitlab.com/hlborg/hotline-irc-bridge.
Support to encode chats from MacRoman to UTF-8 has been added so non-english characters display like they should on IRC and Discord, otherwise it's more or less the same code as the project it's based on.

# Perl Module Dependencies & Installation

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

# Hotline to IRC bridge configuration file

The configuration file is pretty straight forward. Remember to define your "BridgeBotNick" to whatever you have set your Matterbridge IRC nick to be, otherwise you might end up with an endless message loop with the bots sending messages back and forth.

# Matterbridge configuration file
Matterbridge is used to bridge IRC to Discord, which effectively brings Hotline to Discord (and Discord to Hotline).
The configuration file found in this repository is what we use for our implementation.

The Discord side of the bridge is configured using this guide:
https://github.com/42wim/matterbridge/wiki/Section-Discord-(basic)

Sensitive data have been removed and placeholder text have been added in it's place.
