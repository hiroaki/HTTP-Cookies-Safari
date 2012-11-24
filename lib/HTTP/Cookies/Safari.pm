package HTTP::Cookies::Safari;
use strict;

use base qw(HTTP::Cookies);
use vars qw($VERSION);
$VERSION = '1.15_01';

use vars qw($IMPLEMENT);

sub _implement {
    my $self = shift;
    unless( $IMPLEMENT ){
        my $file = shift || $self->{'file'} || return;
        my $module;
        if( $self->_magic($file) eq 'cook' ){
            $module = 'HTTP::Cookies::Safari::BinaryCookies';
        }else{
            $module = 'HTTP::Cookies::Safari::Plist';
        }
        $IMPLEMENT = $module;
        $module =~ s!::!/!g;
        eval { require "$module.pm" };
    }
    $IMPLEMENT;
}

sub _magic {
    my $self = shift;
    my $buf  = undef;
    open  F, $_[0] or return '';
    read  F, $buf, 4;
    close F;
    return $buf;
}

sub load {
    my ($self, $file) = @_;
    $file ||= $self->{'file'} || return;
    my $impl = $self->_implement($file);
    if( ref $self ne $impl ){
        bless $self, $impl;
    }
    $self->load($file);
}

sub save {
    my ($self, $file) = @_;
    $file ||= $self->{'file'} || return;
    my $impl = $self->_implement($file);
    if( ref $self ne $impl ){
        bless $self, $impl;
    }
    $self->save($file);
}

1;
__END__

=pod

=head1 NAME

HTTP::Cookies::Safari - Cookie storage and management for Safari

=head1 SYNOPSIS

    use HTTP::Cookies::Safari;

    my $cookie_jar = HTTP::Cookies::Safari->new;
    $cookie_jar->load( $cookie_file );

=head1 DESCRIPTION

This package overrides the C<load()> and C<save()> methods of
C<HTTP::Cookies> so it can work with Safari cookie files.

There are two formats in cookie of Safari.
Old one is "Cookies.plist" and another is new "Cookies.binarycookies".
This module recognizes format implicitly.

Please see each implementations for details.

=head1 SEE ALSO

L<HTTP::Cookies>

L<HTTP::Cookies::Safari::BinaryCookies>

L<HTTP::Cookies::Safari::Plist>

=head1 AUTHOR

WATANABE Hiroaki <hwat@mac.com>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
