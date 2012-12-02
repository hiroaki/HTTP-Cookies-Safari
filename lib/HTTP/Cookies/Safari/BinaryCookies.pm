# This file includes 3 packages

use strict;
use warnings;

#-------------------------------------------------------------------------------
package HTTP::Cookies::Safari::BinaryCookies::BinaryString;
use vars qw($VERSION);
$VERSION = '0.01';

sub new {
    my $class   = shift;
    my $self    = shift || {};
    bless  $self, (ref $class || $class);
    return $self;
}

sub buffer {
    my $self    = shift;
    return @_ ? $self->{buffer} = shift : $self->{buffer};
}

sub current {
    my $self    = shift;
    return @_ ? $self->{current} = shift : $self->{current};
}

sub read {
    my $self    = shift;
    my $size    = shift;
    my $offset  = shift || 0;

    my $p = ($self->current || 0) + $offset;
    my $chunk = substr $self->buffer, $p, $size;
    $self->current($p + $size);
    $chunk;
}

sub seek {
    my $self    = shift;
    my $pos     = shift;
    $self->current($pos);
    $self;
}

sub read_int_little_endian {
    my $self    = shift;
    (unpack 'V', $self->read(4))[0];
}

sub read_double_little_endian {
    my $self    = shift;
    # TODO - FIXME: the template 'd' depends on architecture
    (unpack 'd', $self->read(8))[0];
}

sub read_bytes {
    my $self    = shift;
    $self->read($_[0]);
}

sub _builder {
    my $self    = shift;
    my $offset  = shift || 0;

    $self->seek($offset - 4);
    my $value = '';
    my $v = $self->read(1);
    while( (unpack('c', $v))[0] != 0 ){
        $value = $value . $v;
        $v = $self->read(1);
    }
    $value;
};

#-------------------------------------------------------------------------------
package HTTP::Cookies::Safari::BinaryCookies::BinaryFile;
use vars qw($VERSION);
$VERSION = '0.01';

use IO::File;
use base  qw(IO::File);
use Fcntl qw(SEEK_SET);

sub new {
    my $class   = shift;
    my $self    = $class->SUPER::new(@_);
    $self->binmode;
    $self->seek(0, SEEK_SET);
    return $self;
}

sub read_int_big_endian {
    my $self    = shift;
    my $buf     = undef;
    $self->read($buf, 4);
    (unpack 'N', $buf)[0];
}

sub read_bytes {
    my $self    = shift;
    my $size    = shift;
    my $buf     = undef;
    $self->read($buf, $size);
    $buf;
}


#-------------------------------------------------------------------------------
package HTTP::Cookies::Safari::BinaryCookies;
use vars qw($VERSION);
$VERSION = '0.01';

use base qw(HTTP::Cookies);
use vars qw($DEBUG);
$DEBUG = 0;

sub _dp {
    $DEBUG and print STDERR (@_ ? $_[0] : ''), "\n";
}

sub _is_secure {
    my $class   = shift;
    my $flag    = shift || 0;
    $flag == 1 or $flag == 5 ? 1 : 0;
}

sub _is_http_only {
    my $class   = shift;
    my $flag    = shift || 0;
    $flag == 4 or $flag == 5 ? 1 : 0;
}

sub load {
    my $self = shift;
    my $file = shift || $self->file;

    my $handle = HTTP::Cookies::Safari::BinaryCookies::BinaryFile->new($file) 
        or die "Couldn't open $file: $!";

    my $magic = $handle->read_bytes(4);
    if( ! defined $magic or $magic ne 'cook' ){
        warn 'File is not a Cookies.binarycookies';
        return;
    }
    
    my $num_pages = $handle->read_int_big_endian;
    _dp("num_pages: $num_pages");

    my @page_sizes  = map { $handle->read_int_big_endian } (1..$num_pages);
    my @pages       = map { $handle->read_bytes($_) } @page_sizes;
    
    $handle->close;

    for my $page ( @pages ){
        my $page_io = HTTP::Cookies::Safari::BinaryCookies::BinaryString->new({ buffer => $page });
    
        $page_io->read(4);
    
        my $num_cookies = $page_io->read_int_little_endian;
        _dp("num_cookies: $num_cookies");
    
        my @cookie_offsets = map { $page_io->read_int_little_endian } (1..$num_cookies);
        
        $page_io->read_bytes(4);

        my $cookie = '';
        for my $offset ( @cookie_offsets ){
            $page_io->seek($offset);
            _dp("offset: $offset");
            
            my $cookiesize = $page_io->read_int_little_endian;
            _dp("cookiesize: $cookiesize");
            
            my $cookie_io = HTTP::Cookies::Safari::BinaryCookies::BinaryString->new({
                                buffer => $page_io->read($cookiesize),
                                });
            
            $cookie_io->read_bytes(4);
    
            my $flags = $cookie_io->read_int_little_endian;
            _dp("flags: $flags");
            my $secure      = $self->_is_secure($flags);
            my $http_only   = $self->_is_http_only($flags);
            
            $cookie_io->read_bytes(4);
            
            my $urloffset   = $cookie_io->read_int_little_endian;
            my $nameoffset  = $cookie_io->read_int_little_endian;
            my $pathoffset  = $cookie_io->read_int_little_endian;
            my $valueoffset = $cookie_io->read_int_little_endian;
            my $endofcookie = $cookie_io->read_bytes(8);

            my $expires = $cookie_io->read_double_little_endian + 978307200;
            _dp("expires: $expires");
    
            my $url = $cookie_io->_builder($urloffset);
            _dp("url: $url");
    
            my $name = $cookie_io->_builder($nameoffset);
            _dp("name: $name");
    
            my $path = $cookie_io->_builder($pathoffset);
            _dp("path: $path");
    
            my $value = $cookie_io->_builder($valueoffset);
            _dp("value: $value");

            $self->set_cookie(
                undef,          # version
                $name,          # key
                $value,         # value
                $path,          # path
                $url,           # domain
                undef,          # port
                0,              # path_spec
                $secure,        # secure
                $expires - time,# max age
                0,              # discard
                );
            _dp("Cookie: $name=$value; domain=$url; path=$path; expires=$expires;@{[ $secure ? ' secure' :'' ]}");
        }
    }

    return 1;
}

sub save {
    die "HTTP::Cookies::Safari::BinaryCookies::save() is not implemented yet";
}


1;
__END__

=pod

=head1 NAME

HTTP::Cookies::Safari::BinaryCookies - load and save Cookies.binarycookies for HTTP::Cookies

=head1 SYNOPSIS

    use HTTP::Cookies::Safari 1.16;

    my $cookie_jar = HTTP::Cookies::Safari->new;
    $cookie_jar->load("$ENV{HOME}/Library/Cookies/Cookies.binarycookies");

    # or 

    use HTTP::Cookies::Safari::BinaryCookies;

    my $cookie_jar = HTTP::Cookies::Safari::BinaryCookies->new;
    $cookie_jar->load("$ENV{HOME}/Library/Cookies/Cookies.binarycookies");

=head1 DESCRIPTION

Safari also uses "Cookies.binarycookies" instead of "Cookies.plist".

IMPORTANT - The save() method is not implemented yet!

=head1 REFERENCE

This module was written using this article as a reference:

L<http://www.securitylearn.net/2012/10/27/cookies-binarycookies-reader/>

=head1 SEE ALSO

L<HTTP::Cookies>

L<HTTP::Cookies::Safari>

=head1 AUTHOR

WATANABE Hiroaki <hwat@mac.com>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
