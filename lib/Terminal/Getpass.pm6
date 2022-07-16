use v6.c;
unit module Terminal::Getpass:ver<0.0.10>;

sub getpass(Str $prompt = "Password: ", IO::Handle $stream = $*ERR --> Str) is export {
    if $*DISTRO.is-win {
        win-getpass($prompt);
    } else {
        unix-getpass($prompt, $stream);
    }
}

my sub unix-getpass(Str $prompt!, IO::Handle $stream! --> Str) {
    use Term::termios;
    use experimental :pack;

    my $old := Term::termios.new(fd => 1).getattr;
    my $new := Term::termios.new(fd => 1).getattr;

    $new.makeraw;
    $new.unset_lflags(<ECHO>);
    $new.setattr(:DRAIN);
    
    $stream.print: $prompt;
    my Str $phrase = "";
    loop {
        my $c = buf8.new;
        $c.append($*IN.read(1)) until try $c.decode('utf-8');
        last if $c.decode("utf-8") ~~ /\n/;
        if $c.unpack("C*") == 3 {
            $old.setattr(:DRAIN);
            exit 128 + SIGINT;
        } elsif $c.unpack("C*") == 127 {
	    $phrase .= chop;
	    next;
        }
        $phrase ~= $c.decode("utf-8");
    }
    $old.setattr(:DRAIN);
    $stream.say: "";
    $phrase;
}

my sub win-getpass(Str $prompt!, IO::Handle $stream? --> Str) {
    use NativeCall;

    my sub _getch returns uint8 is native('msvcrt') { * }
    my sub _putch(uint8) is native('msvcrt') { * }

    _putch($_.ord) for $prompt.comb;
    my Str $phrase = "";

    loop {
        my Int $c = _getch;

        last if so $c == any("\r".ord, "\n".ord);
        exit 0 if $c == 3;
        if $c == "\b".ord {
            $phrase .= chop;
        } else {
            $phrase ~= $c.chr;
        }
    }
    _putch("\r".ord);
    _putch("\n".ord);
    $phrase;
}

=begin pod

=head1 NAME

Terminal::Getpass - A getpass implementation for Raku

=head1 SYNOPSIS

  use Terminal::Getpass;
  
  my $password = getpass;
  say $password;

=head1 DESCRIPTION

Terminal::Getpass is a getpass implementation for Raku.

=head2 METHODS

=head3 getpass

Defined as:

       sub getpass(Str $prompt = "Password: ", IO::Handle $stream = $*ERR --> Str) is export

Reads password from a command line secretly and returns the text.

=head1 AUTHOR

Itsuki Toyota <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Itsuki Toyota

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
