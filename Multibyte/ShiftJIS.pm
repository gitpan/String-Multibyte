package String::Multibyte::ShiftJIS;
#
#  Shift_JIS
#
#  the character order:
#  (\x00 .. \x7E, \xA1 .. \xDF, \x81\x40 .. \x9F\xFC, \xE0\x40 .. \xFC\xFC)
#

+{
    charset  => 'Shift_JIS',
    regexp   => '(?:[\x00-\x7F\xA1-\xDF]|' .
		'[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC])',
    nextchar =>
 sub {
  my $ch = shift;
  my $len = length $ch;
  if($len < 1 || 2 < $len){
    return undef;
  }
  elsif($len == 1){
    return $ch eq "\x7F" ? "\xA1" :
           $ch eq "\xDF" ? "\x81\x40" :
           chr(ord($ch)+1);
  }
  else {
    my($c,$d) = unpack('CC',$ch);
    return $ch eq "\x9F\xFC" ? "\xE0\x40" :
           $ch eq "\xFC\xFC" ?  undef :
           $d == 0xFC ? chr($c+1)."\x40" :
           $d == 0x7E ? chr($c)  ."\x80" :
           chr($c).chr($d+1);
  }
 },
    cmpchar => sub {
	length($_[0]) <=> length($_[1]) || $_[0] cmp $_[1];
    },
};
