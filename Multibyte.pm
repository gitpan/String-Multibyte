package String::Multibyte;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use Carp;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw();

$VERSION = '0.03';

my $PACKAGE = 'String::Multibyte'; # __PACKAGE__

my $Msg_malfo  = $PACKAGE ." malformed %s character";
my $Msg_undef  = $PACKAGE ." undefined %s";
my $Msg_panic  = $PACKAGE ." panic in %s";
my $Msg_revrs  = $PACKAGE ." reverse in %s";
my $Msg_outstr = $PACKAGE ." substr outside of string";
my $Msg_lastc  = $PACKAGE ." reach the last char before end of char range";

(my $Path = $INC{'String/Multibyte.pm'}) =~ s/\.pm$//;

#==========
# new
#
sub new {
  my $class   = shift;
  my $charset = shift;
  my $verbose = shift;
  my $pm = "$Path/$charset.pm";
  my $self = do($pm) or croak "not exist $pm";
  if($verbose){ $self->{verbose} = $verbose }
  if(!defined $self->{charset}){ $self->{charset} = $charset }
  return bless $self, $class;
}

#==========
# islegal
#
sub islegal {
  my $obj = shift;
  my $re  = $obj->{regexp} or croak sprintf $Msg_undef, "regexp";
  !grep !/^$re*$/, @_;
}

#==========
# length
#
sub length {
  my $obj = shift;
  my $str = shift;
  my $re  = $obj->{regexp} or croak sprintf $Msg_undef, "regexp";
  if($obj->{verbose} && $str !~ /^$re*$/){
    carp sprintf $Msg_malfo, $obj->{charset};
  }
  scalar( $str =~ s/$re//g );
}

#==========
# strrev
#
sub strrev {
  my $obj = shift;
  my $str = shift;
  my $re  = $obj->{regexp} or croak sprintf $Msg_undef, "regexp";
  if($obj->{verbose} && $str !~ /^$re*$/){
    carp sprintf $Msg_malfo, $obj->{charset};
  }
  join '', reverse $str =~ /$re/g;
}

#==========
# index
#
sub index{
  my $obj = shift;
  my $re  = $obj->{regexp} or croak sprintf $Msg_undef, "regexp";
  my($str,$sub,$pos) = @_;
  if($obj->{verbose} &&( $str !~ /^$re*$/ || $sub !~ /^$re*$/) ){
    carp sprintf $Msg_malfo, $obj->{charset};
  }
  my $pat = quotemeta $sub;
  $pos = 0 if $pos < 0;
  if($pos){
    ${ $obj->substr(\$str,$pos) } =~ /^($re*?)$pat/;
    my $head = $1;
    defined $head ? $pos + $obj->length($head) : -1;
  } else {
    $str =~ /^($re*?)$pat/;
    my $head = $1;
    defined $head ? $obj->length($head) : -1;
  }
}

#==========
# rindex
#
sub rindex{
  my $obj = shift;
  my $re  = $obj->{regexp} or croak sprintf $Msg_undef, "regexp";
  my($str,$sub,$pos) = @_;
  if($obj->{verbose} &&( $str !~ /^$re*$/ || $sub !~ /^$re*$/) ){
    carp sprintf $Msg_malfo, $obj->{charset};
  }
  my $pat = quotemeta $sub;
  return -1 if $pos < 0;
  (defined $pos
	? ${ $obj->substr(\$str, 0, $pos + $obj->length($sub)) }
	: $str) =~ /^($re*)$pat/;
  my $head = $1;
  defined $head ? $obj->length($head) : -1;
}

#==========
# strspn
#
sub strspn{
  my $obj = shift;
  my $re  = $obj->{regexp} or croak sprintf $Msg_undef, "regexp";
  my($str, $lst, %lst, $pos);
  ($str, $lst) = @_;
  if($obj->{verbose} && ( $str !~ /^$re*$/ || $lst !~ /^$re*$/) ){
    carp sprintf $Msg_malfo, $obj->{charset};
  }
  $pos = 0;
  @lst{ $lst=~ /$re/g } = ();
  while($str =~ /($re)/g){
    last if ! exists $lst{$1};
    $pos++;
  }
  return $pos;
}

#==========
# strcspn
#
sub strcspn{
  my $obj = shift;
  my $re  = $obj->{regexp} or croak sprintf $Msg_undef, "regexp";
  my($str, $lst, %lst, $pos);
  ($str, $lst) = @_;
  if($obj->{verbose} && ( $str !~ /^$re*$/ || $lst !~ /^$re*$/) ){
    carp sprintf $Msg_malfo, $obj->{charset};
  }
  $pos = 0;
  @lst{ $lst=~ /$re/g } = ();
  while($str =~ /($re)/g){
    last if exists $lst{$1};
    $pos++;
  }
  return $pos;
}

#==========
# substr
# 
sub substr{
  my $obj = shift;
  my $re  = $obj->{regexp} or croak sprintf $Msg_undef, "regexp";
  my(@chars, $slen, $ini, $fin, $except);
  my($str, $off, $len, $rep) = @_;
  if($obj->{verbose} && (ref $str ? $$str : $str) !~ /^$re*$/){
    carp sprintf $Msg_malfo, $obj->{charset};
  }
  $slen = @chars = (ref $str ? $$str : $str) =~ /$re/g;
  $except = 1 if $slen < $off;
  if(@_ == 2){$len = $slen - $off;}
  else {
    $except = 1 if $off + $slen < 0 && $len + $slen < 0;
    $except = 1 if 0 <= $len && $off + $len + $slen < 0;
  }
  if($except){ if(@_ > 3){croak $Msg_outstr} else {return} }
  $ini = $off < 0 ? $slen + $off : $off;
  $fin = $len < 0 ? $slen + $len : $ini + $len;
  $ini = 0     if $ini < 0;
  $fin = $ini  if $ini > $fin;
  $ini = $slen if $slen < $ini;
  $fin = $slen if $slen < $fin;

  if(@_ > 3){
    if($obj->{verbose} && $rep !~ /^$re*$/){
      carp sprintf $Msg_malfo, $obj->{charset};
    }
    $_[0] = join '', @chars[0..$ini-1],$rep,@chars[$fin..@chars-1]
  }
  return ref $str
    ? \ CORE::substr($$str,
              CORE::length(join '', @chars[0..$ini-1]),
              CORE::length(join '', @chars[$ini..$fin-1])
      )
    : join '', @chars[$ini..$fin-1]
}

#==========
# mkrange
#
sub mkrange {
  my($s, @retv, $range);
  my $obj = shift;
  my $re  = $obj->{regexp} or croak sprintf $Msg_undef, "regexp";
  my($str,$rev) = @_;
  if($obj->{verbose} && $str !~ /^$re*$/){
    carp sprintf $Msg_malfo, $obj->{charset};
  }
  if(!defined $obj->{nextchar}){
    return wantarray ? $str =~ /$re/g : $str;
  }
  $str =~ s/^-/\\-/;
  $range = 0;
  foreach $s ($str =~ /\G(?:\\\\|\\-|$re)/g){
    if($range){
      if   ($s eq '\\-') {$s = '-'}
      elsif($s eq '\\\\'){$s = '\\'}
      my $p = @retv ? pop(@retv) :
		croak(sprintf $Msg_panic, "mkrange: Parse exception");
      push @retv, $obj->__expand($p, $s, $rev);
      $range = 0;
    }
    else {
      if($s eq '-'){$range = 1}
      elsif($s eq '\\-') {push @retv, '-' }
      elsif($s eq '\\\\'){push @retv, '\\'}
      else		 {push @retv, $s }
    }
  }
  push @retv, '-' if $range;
  wantarray ? @retv : @retv ? join('', @retv) : '';
}

sub __expand {
  my $obj = shift;
  my($fr,$to,$rev) = @_;

  if(defined $obj->{cmpchar} &&
    &{ $obj->{cmpchar} }($fr,$to) > 0)
    { if($rev){($fr,$to) = ($to,$fr)} else { return } }
  else {$rev = 0}

  my $c = $fr;
  my @retv;
  while(1){
    push @retv, $c;
    last if $c eq $to;
    $c = &{ $obj->{nextchar} }($c);
    croak $Msg_lastc if !defined $c;
  }
  return $rev ? reverse(@retv) : @retv;
}

#==========
# strtr
#
my %Cache;

sub strtr {
  my $obj = shift;
  my $re  = $obj->{regexp} or croak sprintf $Msg_undef, "regexp";
  my $str = shift;
  if($obj->{verbose} && $str !~ /^$re*$/){
    carp sprintf $Msg_malfo, $obj->{charset};
  }
  my $coderef;
  if(defined $_[2] && $_[2] =~ /o/){
    $coderef = ($Cache{ $obj->{charset} }
	{ $_[0] }{ $_[1] }{ defined $_[2] ? $_[2] : ''}
	||= $obj->trclosure(@_) );
  }
  else {
    $coderef = $obj->trclosure(@_);
  }
  &$coderef($str);
}

#============
# trclosure
#
sub trclosure {
  my(@fr, @to, $r, $R, $c, $d, $s, $v, $i, %hash);
  my $obj = shift;
  my $re  = $obj->{regexp} or croak sprintf $Msg_undef, "regexp";
  my($fr, $to, $mod) = @_;

  my $msg = sprintf $Msg_malfo, $obj->{charset};
  if($obj->{verbose} && ($fr !~ /^$re*$/ || $to !~ /^$re*$/) ){ carp $msg }
  $r = defined $mod && $mod =~ /r/;
  $R = defined $mod && $mod =~ /R/;
  $v = $obj->{verbose};

  $fr = scalar $obj->mkrange($fr, $r) unless $R;
  @fr = $fr =~ /\G$re/g;
  $to = scalar $obj->mkrange($to, $r) unless $R;
  @to = $to =~ /\G$re/g;

  $c = defined $mod && $mod =~ /c/;
  $d = defined $mod && $mod =~ /d/;
  $s = defined $mod && $mod =~ /s/;
  $mod = $s * 4 + $d * 2 + $c;

  for($i = 0; $i < @fr; $i++){
    next if exists $hash{ $fr[$i] };
    $hash{ $fr[$i] } =
    @to ? defined $to[$i] ? $to[$i] : $d ? '' : $to[-1]
        : $d && !$c ? '' : $fr[$i];
  }
  return
    $mod == 3 || $mod == 7 ?
      sub { # $c: true, $d: true, $s: true/false, $mod: 3 or 7
        my $str = shift;
        if($v && (ref $str ? $$str : $str) !~ /^$re*$/){ carp $msg }
        my $cnt = 0;
        (ref $str ? $$str : $str) =~ s{($re)}{
          exists $hash{$1} ? $1 : (++$cnt, '');
        }ge;
        return ref $str ? $cnt : $str;
      } :
    $mod == 5 ?
      sub { # $c: true, $d: false, $s: true, $mod: 5
        my $str = shift;
        if($v && (ref $str ? $$str : $str) !~ /^$re*$/){ carp $msg }
        my $cnt = 0;
        my $pre = '';
        my $now;
        (ref $str ? $$str : $str) =~ s{($re)}{
          exists $hash{$1} ? ($pre = '', $1) : (++$cnt, 
            $now = @to ? $to[-1] : $1, 
            $now eq $pre ? '' : ($pre = $now) 
          );
        }ge;
        ref $str ? $cnt : $str;
      } :
    $mod == 4 || $mod == 6 ?
      sub { # $c: false, $d: true/false, $s: true, $mod: 4 or 6
        my $str = shift;
        if($v && (ref $str ? $$str : $str) !~ /^$re*$/){ carp $msg }
        my $cnt = 0;
        my $pre = '';
        (ref $str ? $$str : $str) =~ s{($re)}{
          exists $hash{$1} ? (++$cnt, 
             $hash{$1} eq '' || $hash{$1} eq $pre ? '' : ($pre = $hash{$1})
          ) : ($pre = '', $1);
        }ge;
        ref $str ? $cnt : $str;
      } :
    $mod == 1 ?
      sub { # $c: true, $d: false, $s: false, $mod: 1
        my $str = shift;
        if($v && (ref $str ? $$str : $str) !~ /^$re*$/){ carp $msg }
        my $cnt = 0;
        (ref $str ? $$str : $str) =~ s{($re)}{
          exists $hash{$1} ? $1 : (++$cnt, @to) ? $to[-1] : $1;
        }ge;
        ref $str ? $cnt : $str;
      } :
    $mod == 0 || $mod == 2 ?
      sub { # $c: false, $d: true/false, $s: false, $mod:  0 or 2
        my $str = shift;
        if($v && (ref $str ? $$str : $str) !~ /^$re*$/){ carp $msg }
        my $cnt = 0;
        (ref $str ? $$str : $str) =~ s{($re)}{
          exists $hash{$1} ? (++$cnt, $hash{$1}) : $1;
        }ge;
        ref $str ? $cnt : $str;
      } : sub { croak sprintf $Msg_panic, "trclosure! Invalid Closure!" }
}

#============
# strsplit
#
sub strsplit{
  my $obj = shift;
  my $re  = $obj->{regexp} or croak sprintf $Msg_undef, "regexp";
  my $pat = quotemeta shift;
  my $str = shift;
  my $lim = shift || 0;
  if($obj->{verbose} && $str !~ /^$re*$/){
    carp sprintf $Msg_malfo, $obj->{charset};
  }
  if('' eq $pat && $lim <= 0){
    return wantarray
      ? ($str =~ /$re/g, $lim < 0 ? '' : ())
      : ($lim < 0) + $obj->length($str)
  }
  if($lim == 1){
    return wantarray ? ($str) : 1 ;
  }
  my($for, $cnt, @ret);
  $for = '' eq $pat ? "($re)" : "^($re*?)";
  while($str =~ /$for$pat/){
    push @ret, $1;
    $str =~ s/$for$pat//;
    $cnt++;
    last if ! CORE::length $str;
    last if $lim > 1 && $cnt >= $lim - 1;
  }
  push @ret, $str if $str ne '' || $lim < 0 || $cnt < $lim;
  if($lim == 0){pop @ret while defined $ret[-1] && $ret[-1] eq ''}
  @ret;
}

1;
__END__

=head1 NAME

String::Multibyte - Perl module to manipulate multibyte character strings

=head1 SYNOPSIS

  use String::Multibyte;

  $utf8 = String::Multibyte->new('UTF8');
  $utf8_len = $utf8->length($utf8_str);

=head1 DESCRIPTION

This module provides some functions which emulate
the corresponding C<CORE> functions
to manipulate multiple-byte character strings.

=head2 Definition of Multibyte Charsets

The definition files are sited under the C</String/Multibyte> directory.

The definition file must return a hashref, whose keys should
include C<('charset', 'regexp', 'nextchar', 'cmpchar' )>.

The value for the key C<'charset'>, is a string of the charset name.
Omission of the C<'charset'> matters very little.

The value for the key C<'regexp'>, REQUIRED, is a regexp
matching one character of the concerned charset.
If the C<'regexp'> is omitted, calling any method is croaked.

The value for the key C<'nextchar'> must be a coderef
that returns the next character to the specified character.
If the C<'nextchar'> coderef is omitted, C<mkrange> and C<strtr>
functions don't understand hyphen metacharacter for character ranges.

The value for the key C<'cmpchar'> must be a coderef
that compares the specified two characters.
If the C<'cmpchar'> coderef is omitted, C<mkrange> and C<strtr>
functions don't understand reverse character ranges.

=head2 Constructor

=over 4

=item C<$mbcs = String::Multibyte-E<gt>new(CHARSET)>

=item C<$mbcs = String::Multibyte-E<gt>new(CHARSET, VERBOSE)>

C<CHARSET> is the charset name; exactly speaking,
the file name of the definition file (without the suffix C<.pm>).

returns the instance to tell methods in which charset
the specified strings should be handled.

  e.g.
    $sjis = String::Multibyte->new('ShiftJIS');
    $substr = $sjis->substr('あいうえお',2,2); # 'うえ'
      # 'あいうえお' should be encoded in Shift_JIS.

If true value is specified as C<VERBOSE>,
the called method (excepting C<islegal>) will check its arguments
and carps if any of them is not legally encoded
in the concerned charset.

Otherwise such a check won't be carried out
(saves a bit of time, but unsafe, though you can use
the C<islegal> method if necessary).

=back

=head2 Check Whether the String is Legal

=over 4

=item C<$mbcs-E<gt>islegal(LIST)>

Returns a boolean indicating whether all the strings in arguments
are legally encoded in the concerned charset.

=back

=head2 Length

=over 4

=item C<$mbcs-E<gt>length(STRING)>

Returns the length in characters of the specified string.

=back

=head2 Reverse

=over 4

=item C<$mbcs-E<gt>strrev(STRING)>

Returns a reversed string.

=back

=head2 Search

=over 4

=item C<$mbcs-E<gt>index(STRING, SUBSTR)>

=item C<$mbcs-E<gt>index(STRING, SUBSTR, POSITION)>

Returns the position of the first occurrence
of C<SUBSTR> in C<STRING> at or after C<POSITION>.
If C<POSITION> is omitted, starts searching 
from the beginning of the string. 

If the substring is not found, returns -1. 

=item C<$mbcs-E<gt>rindex(STRING, SUBSTR)>

=item C<$mbcs-E<gt>rindex(STRING, SUBSTR, POSITION)>

Returns the position of the last occurrence 
of C<SUBSTR> in C<STRING> at or after C<POSITION>.
If C<POSITION> is specified, returns the last 
occurrence at or before that position. 

If the substring is not found, returns -1. 

=item C<$mbcs-E<gt>strspn(STRING, SEARCHLIST)>

Returns returns the position of the first occurrence of 
any character not contained in the search list.

  $mbcs->strspn("+0.12345*12", "+-.0123456789");
  # returns 8. 

If the specified string does not contain any character
in the search list, returns 0.

The string consists of characters in the search list, 
the returned value equals the length of the string.

=item C<$mbcs-E<gt>strcspn(STRING, SEARCHLIST)>

Returns returns the position of the first occurrence of 
any character contained in the search list.

  $mbcs->strcspn("Perlは面白い。", "赤青黄白黒");
  # returns 6. 

If the specified string does not contain any character
in the search list,
the returned value equals the length of the string.

=back

=head2 Substring

=over 4

=item C<$mbcs-E<gt>substr(STRING or SCALAR REF, OFFSET)>

=item C<$mbcs-E<gt>substr(STRING or SCALAR REF, OFFSET, LENGTH)>

=item C<$mbcs-E<gt>substr(SCALAR, OFFSET, LENGTH, REPLACEMENT)>

It works like C<CORE::substr>, but
using character semantics of multibyte charset encoding.

If the C<REPLACEMENT> as the fourth argument is specified, replaces
parts of the C<SCALAR> and returns what was there before.

You can utilize the lvalue reference,
returned if a reference of scalar variable is used as the first argument.

    ${ $mbcs->substr(\$str,$off,$len) } = $replace;

        works like

    CORE::substr($str,$off,$len) = $replace;

The returned lvalue is not multibyte character-oriented but byte-oriented,
then successive assignment may lead to odd results.

    $str = "0123456789";
    $lval  = $sjis->substr(\$str,3,1);
    $$lval = "あい";
    $$lval = "a";
    # $str is NOT "012aい456789", but an illegal string "012a\xA0い456789".

=back

=head2 Split

=over 4

=item C<$mbcs-E<gt>strsplit(SEPARATOR, STRING)>

=item C<$mbcs-E<gt>strsplit(SEPARATOR, STRING, LIMIT)>

This function emulates C<CORE::split>, but splits on the C<SEPARATOR> string,
not by a pattern.

If not in list context, only return the number of fields found,
but does not split into the C<@_> array.

  $sjis->strsplit('／', 'Perl／駱駝／Camel');
  # ('Perl', '駱駝', 'Camel')

If empty string is specified as C<SEPARATOR>, splits the specified string
into characters.

  $bytes->strsplit('', 'This is perl.', 7);
  # ('T', 'h', 'i', 's', ' ', 'i',  's perl.')

=back

=head2 Character Range

=over 4

=item C<$mbcs-E<gt>mkrange(EXPR, EXPR)>

Returns the character list (not in list context, as a concatenated string)
gained by parsing the specified character range.

The result depends on the the character order for the concerned charset.
About the character order for each charset, see its definition file.

If the character order is undefined in the definition file,
returns an identical string with the specified string.

A character range is specified with a HYPHEN-MINUS, C<'-'>. The backslashed 
combinations C<'\-'> and C<'\\'> are used instead of the characters
C<'-'> and C<'\'>, respectively. The hyphen at the beginning or 
end of the range is also evaluated as the hyphen itself.

For example, C<$mbcs-E<gt>mkrange('+\-0-9A-F')> returns
C<('+', '-', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
'A', 'B', 'C', 'D', 'E', 'F')>
and C<scalar $mbcs-E<gt>mkrange('A-P')> returns C<'ABCDEFGHIJKLMNOP'>.

If true value is specified as the second argument,
reverse character ranges such as C<'9-0'>, C<'Z-A'> are allowed.

  $bytes = String::Multibyte->new('Bytes');
  $bytes->mkrange('p-e-r-l', 1); # ponmlkjihgfefghijklmnopqrqponml

=back

=head2 Transliteration

=over 4

=item C<$mbcs-E<gt>strtr(STRING or SCALAR REF, SEARCHLIST, REPLACEMENTLIST)>

=item C<$mbcs-E<gt>strtr(STRING or SCALAR REF, SEARCHLIST, REPLACEMENTLIST, MODIFIER)>

Transliterates all occurrences of the characters found in the search list
with the corresponding character in the replacement list. 

If a reference of scalar variable is specified as the first argument,
returns the number of characters replaced or deleted;
otherwise, returns the transliterated string and
the specified string is unaffected.

  $str = "なんといおうか";
  print $mbcs->strtr(\$str,"あいうえお", "アイウエオ"), "  ", $str;
  # output: 3  なんとイオウか

  $str = "後門の狼。";
  print $mbcs->strtr($str,"後狼。", "前虎、"), $str;
  # output: 前門の虎、後門の狼。

B<SEARCHLIST and REPLACEMENTLIST>

Character ranges such as C<"ぁ-お"> (internally utilizing C<mkrange()>)
are supported.

If the C<REPLACEMENTLIST> is empty (specified as C<''>, not C<undef>,
because the use of uninitialized value causes warning under -w option),
the C<SEARCHLIST> is replicated. 

If the replacement list is shorter than the search list,
the final character in the replacement list
is replicated till it is long enough
(but differently works when the 'd' modifier is used).

  $mbcs->strtr(\$str, 'ぁ-んァ-ヶｦ-ﾟ', '#');
    # replaces all Kana letters by '#'. 

B<MODIFIER>

    c   Complement the SEARCHLIST.
    d   Delete found but unreplaced characters.
    s   Squash duplicate replaced characters.
    R   No use of character ranges.
    r   Allows to use reverse character ranges.
    o   Caches the conversion table internally.

  $mbcs->strtr(\$str, 'ぁ-んァ-ヶｦ-ﾟ', '');
    # counts all Kana letters in $str. 

  $mbcs->$onlykana = strtr($str, 'ぁ-んァ-ヶｦ-ﾟ', '', 'cd');
    # deletes all characters except Kana. 

  $mbcs->strtr(\$str, " \x81\x40\n\r\t\f", '', 'd');
    # deletes all whitespace characters including full-width space

  $mbcs->strtr("おかかうめぼし　ちちとはは", 'ぁ-ん', '', 's');
    # output: おかうめぼし　ちとは

  $mbcs->strtr("条件演算子の使いすぎは見苦しい", 'ぁ-ん', '＃', 'cs');
    # output: ＃の＃いすぎは＃しい

If C<'R'> modifier is specified, C<'-'> is not evaluated as a meta character
but hyphen itself like in C<tr'''>. Compare:

  $mbcs->strtr("90 - 32 = 58", "0-9", "A-J");
    # output: "JA - DC = FI"

  $mbcs->strtr("90 - 32 = 58", "0-9", "A-J", "R");
    # output: "JA - 32 = 58"
    # cf. ($str = "90 - 32 = 58") =~ tr'0-9'A-J';
    # '0' to 'A', '-' to '-', and '9' to 'J'.

If C<'r'> modifier is specified, reverse character ranges are allowed. e.g.

   $mbcs->strtr($str, "0-9", "9-0", "r")

     is identical to

   $mbcs->strtr($str, "0123456789", "9876543210")

B<Caching the conversion table>

If C<'o'> modifier is specified, the conversion table is cached internally.
e.g.

  foreach(@hiragana_strings){
    print $mbcs->strtr($_, 'ぁ-ん', 'ァ-ン', 'o');
  }
  # katakana strings are printed

will be almost as efficient as this:

  $hiragana_to_katakana = $mbcs->trclosure('ぁ-ん', 'ァ-ン');

  foreach(@hiragana_strings){
    print &$hiragana_to_katakana($_);
  }

You can use whichever you like.

Without C<'o'>,

  foreach(@hiragana_strings){
    print $mbcs->strtr($_, 'ぁ-ん', 'ァ-ン');
  }

will be very slow since the conversion table is made
whenever the function is called.

=back

=head2 Generation of the Closure to Transliterate

=over 4

=item C<$mbcs-E<gt>trclosure(SEARCHLIST, REPLACEMENTLIST)>

=item C<$mbcs-E<gt>trclosure(SEARCHLIST, REPLACEMENTLIST, MODIFIER)>

Returns a closure to transliterate the specified string.
The return value is an only code reference, not blessed object.
By use of this code ref, you can save yourself time
as you need not specify arguments every time.

  my $digit_tr = $mbcs->trclosure("1234567890-", "一二三四五六七八九〇－");
  print &$digit_tr ("TEL ：0124-45-6789\n"); # ok to perl 5.003
  print $digit_tr->("FAX ：0124-51-5368\n"); # perl 5.004 or better

  # output:
  # TEL ：〇一二四－四五－六七八九
  # FAX ：〇一二四－五一－五三六八

The functionality of the closure made by C<trclosure()> is equivalent 
to that of C<strtr()>. Frankly speaking, the C<strtr()> calls
C<trclosure()> internally and uses the returned closure.

=back

=head1 BUGS

This modules supposes C<$[> is always equal to 0, never 1. 

The functions provided by this library use B<many> regexp operations.
Therefore, C<$1> etc. values may be changed or discarded unexpectedly.
I suggest you save it in a certain variable 
before call of the function.

=head1 AUTHOR

Tomoyuki SADAHIRO

  bqw10602@nifty.com
  http://homepage1.nifty.com/nomenclator/perl/

  Copyright(C) 2001, SADAHIRO Tomoyuki. Japan. All rights reserved.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1).

=cut
