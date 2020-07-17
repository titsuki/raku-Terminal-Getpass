[![Build Status](https://travis-ci.org/titsuki/raku-Terminal-Getpass.svg?branch=master)](https://travis-ci.org/titsuki/raku-Terminal-Getpass)

NAME
====

Terminal::Getpass - A getpass implementation for Raku

SYNOPSIS
========

    use Terminal::Getpass;

    my $password = getpass;
    say $password;

DESCRIPTION
===========

Terminal::Getpass is a getpass implementation for Raku.

METHODS
-------

### getpass

Defined as:

    sub getpass(Str $prompt = "Password: ", IO::Handle $stream = $*ERR --> Str) is export

Reads password from a command line secretly and returns the text.

AUTHOR
======

Itsuki Toyota <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Itsuki Toyota

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

