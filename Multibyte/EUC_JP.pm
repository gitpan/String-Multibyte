package String::Multibyte::EUC_JP;
#
#  EUC-JP
#
#  the character order:
#  (\x00 .. \x7E,			# X 0201 and X 0211 CL
#   \x8E\xA1 .. \x8E\xDF,		# X 0201 kana
#   \xA1\xA1 .. \xFE\xFE,		# X 0208
#   \x8F\xA1\xA1 .. \x8F\xFE\xFE)	# X 0212 and X 0213 2nd plane
#

+{
    charset  => 'EUC-JP',
    regexp   => '(?:[\x00-\x7F]|[\xA1-\xFE][\xA1-\xFE]|' .
		'\x8E[\xA1-\xDF]|\x8F[\xA1-\xFE][\xA1-\xFE])',
    nextchar =>
 sub {
  my $ch = shift;
  my $len = length $ch;
  if($len < 1 || 3 < $len){ return }
  elsif($len == 1){
    return $ch eq "\x7F" ? "\x8E\xA1" : chr(ord($ch)+1);
  }
  elsif($len == 2){
    my($c,$d) = unpack('CC',$ch);
    return $ch eq "\x8E\xDF" ? "\xA1\xA1" :
           $ch eq "\xFE\xFE" ? "\x8F\xA1\xA1" :
           $d == 0xFE ? chr($c+1)."\xA1" :
           chr($c).chr($d+1);
  }
  else {
    return if 0x8F != ord $ch;
    my($c,$d) = (unpack('CCC',$ch))[1,2];
    return $ch eq "\x8F\xFE\xFE" ? undef :
           $d == 0xFE ? "\x8F".chr($c+1)."\xA1" :
           "\x8F".chr($c).chr($d+1);
  }
 },
    cmpchar => sub {
	length($_[0]) <=> length($_[1]) || $_[0] cmp $_[1];
    },
};
