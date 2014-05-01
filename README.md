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
* Make sure to have `TWITCH_USER` with your Twitch.tv username and `TWITCH_PW` with your Twitch.tv oauth token set up as environment variables.
* Run `app.b`

To see the top messages and words, run `check.rb`. 
