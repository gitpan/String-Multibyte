package String::Multibyte::Unicode;

require 5.007; # maybe 5.008
use vars qw($VERSION);
$VERSION = '1.01';

+{
    charset  => 'Unicode',
    regexp   => '(?s:.)',
    nextchar => sub { pack 'U', 1 + unpack('U', $_[0]) },
    cmpchar  => sub { $_[0] cmp $_[1] },
};

__END__

=head1 NAME

String::Multibyte::Unicode - internally used by String::Multibyte
for Unicode (Perl internal format)

=head1 SYNOPSIS

    use String::Multibyte;

    $unicode = String::Multibyte->new('Unicode');
    $unicode_length = $uni->length($unicode_string);

=head1 DESCRIPTION

C<String::Multibyte::Unicode> is used for manipulation of strings
in Perl internal format for Unicode.

=head1 BUGS

Surrogates, C<0xD800..0xDFFF>, and other non-characters may be included
in a character range, but may be ignored, warned, or croaked,
by the C<CORE::> unicode support.

=head1 SEE ALSO

L<String::Multibyte>

=cut

