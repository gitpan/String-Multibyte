package String::Multibyte::Grapheme;

require 5.008;
use vars qw($VERSION);
$VERSION = '1.02';

our $CRLF    = qr/(?:\cM\cJ)/;
our $Control = qr/[\p{Zl}\p{Zp}\p{Cc}\p{Cf}]/;
our $Any     = qr/./s;
our $Extend  = qr/[\p{Mn}\p{Me}\p{OtherGraphemeExtend}]/;

our $HangL   = qr/[\x{1100}-\x{115F}]/; # Hangul Jamo Leading Consonant
our $HangV   = qr/[\x{1160}-\x{11A2}]/; # Hangul Jamo Vowel
our $HangT   = qr/[\x{11A8}-\x{11F9}]/; # Hangul Jamo Trailing Consonant
our $HangS   = qr/[\x{AC00}-\x{D7A3}]/; # Hangul Syllable
our $cHangLV = join '', map sprintf("\\x{%04X}", 0xAC00+28*$_), 0..19*21-1;
our $HangLV  = qr/[$cHangLV]/;          # Hangul Syllable LV
our $HangLVT = qr/(?!$HangLV)$HangS/;   # Hangul Syllable LVT
our $Hangul  = qr/(?:$HangL*(?:$HangLV$HangV*|$HangV+|$HangLVT)$HangT*
        | $HangL+ | $HangT+ )/x;
our $Grapheme = qr/(?:$CRLF|$Control|(?:$Hangul|$Any)$Extend*)/;

+{
    charset => 'Default Grapheme Cluster',
    regexp  => $Grapheme,
 };

__END__

=head1 NAME

String::Multibyte::Grapheme - internally used by String::Multibyte
for Default Grapheme Clusters in Unicode

=head1 SYNOPSIS

    use String::Multibyte;

    $gra = String::Multibyte->new('Grapheme');
    $gra_length = $gra->length($unicode_string);

=head1 DESCRIPTION

C<String::Multibyte::Grapheme> is used for graphemewise manipulation
of strings in Perl's internal format for Unicode.

=head1 CAVEAT

This module requires Perl 5.8.0 or later.

Grapheme ranges (no, no longer character ranges) are not supported.

This module is based on the version 3
of Draft Unicode Technical Report #29 (DUTR #29).
Specification of the report may be changed in future.

=head1 SEE ALSO

L<String::Multibyte>

L<http://www.unicode.org/reports/tr29>

=cut
