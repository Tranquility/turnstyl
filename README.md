# Turnstyl

[![Build Status](https://travis-ci.org/Tranquility/turnstyl.png)](https://travis-ci.org/Tranquility/turnstyl)

Commandline utility for managing ssh access. At the moment turnstyl uses the github API to add the github users' public keys to your ```~/.ssh/authorized_keys``` file. It does this for each of the users listed in your ```.turnstylrc``` file. It won't overwrite your existing file. If an ```~/.ssh/authorized_keys``` file already exists it asks you whether you want to overwrite it or backup the old one.

## Installation

    $ gem install turnstyl

## Usage

The turnstyl command expects a config file in your home folder named
".turnstyl-config" in which you list the github users that are allowed
to access your system.

    userlist = [ "githubuser1", "githubuser2", "...", "githubuser99" ]


## Future

- multiple host support
- support for non-github services
