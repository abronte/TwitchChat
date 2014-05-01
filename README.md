TwitchChat
==========

See what the most said things are on twitch.

Requirements
----
* Ruby 1.9.3+
* Twitch.tv account
* Redis or similar server (I used [SSDB] for this)


[SSDB]:http://www.ideawu.com/ssdb/

Setup
----
* Make sure to have `TWITCH_USER` with your Twitch.tv username and `TWITCH_PW` with your Twitch.tv oauth token set up as environment variables. See the [Twitch.tv irc docs] for more information.
* Run `app.b`

[Twitch.tv irc docs]:http://help.twitch.tv/customer/portal/articles/1302780-twitch-irc

To see the top messages and words, run `check.rb`. 

Issues
----
There is an issue of the child processes becoming zombies after they are killed. This doesn't seem to have any impact on performance and are cleaned up when the parent process is killed.
