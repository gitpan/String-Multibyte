package String::Multibyte::UTF8;
#
#  UTF-8, U+0000 to U+10FFFF.
#  (high and low surrogate areas are contained)
#

+{
    charset  => 'UTF-8',
    regexp   =>
   '(?:[\x00-\x7F]|[\xC2-\xDF][\x80-\xBF]|'
 . '\xE0[\xA0-\xBF][\x80-\xBF]|'
 . '[\xE1-\xEF][\x80-\xBF][\x80-\xBF]|'
 . '\xF0[\x90-\xBF][\x80-\xBF][\x80-\xBF]|'
 . '[\xF1-\xF3][\x80-\xBF][\x80-\xBF][\x80-\xBF]|'
 . '\xF4[\x80-\x8F][\x80-\xBF][\x80-\xBF])',

    nextchar =>
 sub {
  my $ch = shift;
  my $len = length $ch;
  if($len < 1 || 4 < $len){
    return undef;
  }
  elsif($len == 1){
    return $ch eq "\x7F" ? "\xC2\x80" :
           chr(ord($ch)+1);
  }
  elsif($len == 2){
    my($c,$d) = unpack('CC',$ch);
    return $ch eq "\xDF\xBF" ? "\xE0\xA0\x80" :
           $d == 0xBF ? chr($c+1)."\x80" :
           chr($c).chr($d+1);
  }
  elsif($len == 3){
    my($c,$d,$e) = unpack('CCC',$ch);
    return $ch eq "\xEF\xBF\xBF" ? "\xF0\x90\x80\x80" :
           $d == 0xBF && $e == 0xBF ? chr($c+1)."\x80\x80" :
           $e == 0xBF ? chr($c).chr($d+1)."\x80" :
           chr($c).chr($d).chr($e+1);
  }
  else {
    my($c,$d,$e,$f) = unpack('CCCC',$ch);
    return $ch eq "\xF4\x8F\xBF\xBF" ? undef :
           $d == 0xBF && $e == 0xBF && $f == 0xBF ? chr($c+1)."\x80\x80\x80" :
           $e == 0xBF && $f == 0xBF ? chr($c).chr($d+1)."\x80\x80" :
           $f == 0xBF ? chr($c).chr($d).chr($e+1)."\x80" :
           chr($c).chr($d).chr($e).chr($f+1);
  }
 },
    cmpchar => sub {
	length($_[0]) <=> length($_[1]) || $_[0] cmp $_[1];
    },
};
