package String::Multibyte::EUC;
#
#  EUC
#  
#  the character order:
#  (\x00 .. \x7E, \xA1\xA1 .. \xFE\xFE)
#

+{
    charset  => 'EUC',
    regexp   => '(?:[\x00-\x7F]|[\xA1-\xFE][\xA1-\xFE])',
    nextchar =>
 sub {
  my $ch = shift;
  my $len = length $ch;
  if($len < 1 || 2 < $len){
    return undef;
  }
  elsif($len == 1){
    return $ch eq "\x7F" ? "\xA1\xA1" :
           chr(ord($ch)+1);
  }
  else {
    my($c,$d) = unpack('CC',$ch);
    return $ch eq "\xFE\xFE" ? undef :
           $d == 0xFE ? chr($c+1)."\xA1" :
           chr($c).chr($d+1);
  }
 },
    cmpchar => sub {
	length($_[0]) <=> length($_[1]) || $_[0] cmp $_[1];
    },
};
