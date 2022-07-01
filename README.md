# Hotline to IRC bridge

The Hotline to IRC bridge is based on hotline-irc-bridge that can be found here: https://gitlab.com/hlborg/hotline-irc-bridge.
Support to encode chats from MacRoman to UTF-8 has been added so non-english characters display like they should on IRC and Discord, otherwise it's more or less the same code as the project it's based on.

# Perl Module Dependencies for Hotline to IRC bridge

- Bot::BasicBot
- Net::Hotline::Client
- YAML::XS
- Socket
- IO::Filename
- utf8
- POE
- IPC::System::Simple

# Commands

- **!userlist** results in the userlist from Hotline or IRC being posted to main chat

# Matterbridge configuration file
Matterbridge is used to bridge IRC to Discord, which effectively brings Hotline to Discord.
The configuration file found in this repository is what we use for our implementation.

Sensitive data have been removed and placeholder text have been added in it's place.