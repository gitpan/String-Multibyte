# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..36\n"; }
END {print "not ok 1\n" unless $loaded;}
use String::Multibyte;
$^W = 1;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my $mb = String::Multibyte->new('EUC_JP',1);

{
  my $v;
  my $NG = 0;
  for(
	"´Á»ú¥Æ¥¹¥È",
	"abc",
	"Ž±Ž²Ž³Ž´Žµ",
	"ŽÊŽßŽ°ŽÙ=Perl",
	"\001\002\003\000\n",
	"",
	" ",
	'¡¡',
  ){ $NG++ unless $mb->islegal($_) }

  for(
	"¤½¤ì¤â¤½¤¦¤À\xFF\xFF",
	"¤É¤¦¤Ë¤â¤³¤¦¤Ë¤â\x81\x39",
	"\x91\x00",
	"¤³¤ì¤Ï\xFF¤É¤¦¤«¤Ê",
  ){ $NG++ unless ! $mb->islegal($_) }

  print ! $NG
  && $mb->islegal("¤¢", "P", "", "Ž¶ŽÝŽ¼ŽÞ test")
  && ! $mb->islegal("ÆüËÜ","¤µkanji","\xA0","PERL")
	? "ok" : "not ok", " 2\n";
}


print 0 eq $mb->length("")
  &&  3 eq $mb->length("abc")
  &&  4 eq $mb->length("abc\n")
  &&  5 eq $mb->length("Ž±Ž²Ž³Ž´Žµ")
  && 10 eq $mb->length("¤¢¤«¤µ¤¿¤Ê¤Ï¤Þ¤ä¤é¤ï")
  && 14 eq $mb->length("¤¢¤«¤µ¤¿¤Ê\n\n¤Ï¤Þ¤ä¤é¤ï\n\n")
  &&  9 eq $mb->length('AIUEOÆüËÜ´Á»ú')
  ? "ok" : "not ok", " 3\n";

print $mb->mkrange("") eq ""
  &&  $mb->mkrange('-+\-XYZ-') eq "-+-XYZ-"
  &&  $mb->mkrange("A-D") eq "ABCD"
  &&  $mb->mkrange("¤¡-¤¦") eq "¤¡¤¢¤£¤¤¤¥¤¦"
  &&  $mb->mkrange("0-9£°-£¹") eq "0123456789£°£±£²£³£´£µ£¶£·£¸£¹"
  &&  $mb->mkrange("-0") eq "-0"
  &&  $mb->mkrange("0-9") eq "0123456789"
  &&  $mb->mkrange("0-9",1) eq "0123456789"
  &&  $mb->mkrange("9-0",1) eq "9876543210"
  &&  $mb->mkrange("0-9-5",1) eq "01234567898765"
  &&  $mb->mkrange("0-9-5-7",1) eq "0123456789876567"
  &&  $mb->mkrange('É½-') eq 'É½-'
  &&  $mb->mkrange('ab-') eq 'ab-'
  ? "ok" : "not ok", " 4\n";

print $mb->index("", ""    )   eq index("", ""    )
   && $mb->index("", "", -1)   eq index("", "", -1)
   && $mb->index("", "",  0)   eq index("", "",  0)
   && $mb->index("", "",  1)   eq index("", "",  1)
   && $mb->index("", "", 10)   eq index("", "", 10)
   && $mb->index("", "a"   )   eq index("", "a"   )
   && $mb->index("", "a", -1)  eq index("", "a", -1)
   && $mb->index("", "a",  0)  eq index("", "a",  0)
   && $mb->index("", "a",  1)  eq index("", "a",  1)
   && $mb->index("", "a", 10)  eq index("", "a", 10)
   && $mb->index(" a", ""    ) eq index(" a", ""    )
   && $mb->index(" a", "", -1) eq index(" a", "", -1)
   && $mb->index(" a", "",  0) eq index(" a", "",  0)
   && $mb->index(" a", "",  1) eq index(" a", "",  1)
   && $mb->index(" a", "",  2) eq index(" a", "",  2)
   && $mb->index(" a", "", 10) eq index(" a", "", 10)
   && $mb->index(" a", "a"   ) eq index(" a", "a"   )
   && $mb->index(" a", "a",-1) eq index(" a", "a",-1)
   && $mb->index(" a", "a", 0) eq index(" a", "a", 0)
   && $mb->index(" a", "a", 1) eq index(" a", "a", 1)
   && $mb->index(" a", "a", 2) eq index(" a", "a", 2)
   && $mb->index(" a", "a",10) eq index(" a", "a",10)
  ? "ok" : "not ok", " 5\n";

print $mb->rindex("", ""    )   eq rindex("", "")
   && $mb->rindex("", "", -1)   eq rindex("", "", -1)
   && $mb->rindex("", "",  0)   eq rindex("", "",  0)
   && $mb->rindex("", "",  1)   eq rindex("", "",  1)
   && $mb->rindex("", "", 10)   eq rindex("", "", 10)
   && $mb->rindex("", "a"    )  eq rindex("", "a"    )
   && $mb->rindex("", "a", -1)  eq rindex("", "a", -1)
   && $mb->rindex("", "a",  0)  eq rindex("", "a",  0)
   && $mb->rindex("", "a",  1)  eq rindex("", "a",  1)
   && $mb->rindex("", "a", 10)  eq rindex("", "a", 10)
   && $mb->rindex(" a", ""    ) eq rindex(" a", ""    )
   && $mb->rindex(" a", "", -1) eq rindex(" a", "", -1)
   && $mb->rindex(" a", "",  0) eq rindex(" a", "",  0)
   && $mb->rindex(" a", "",  1) eq rindex(" a", "",  1)
   && $mb->rindex(" a", "",  2) eq rindex(" a", "",  2)
   && $mb->rindex(" a", "", 10) eq rindex(" a", "", 10)
   && $mb->rindex(" a", "a"   ) eq rindex(" a", "a"   )
   && $mb->rindex(" a", "a",-1) eq rindex(" a", "a",-1)
   && $mb->rindex(" a", "a", 0) eq rindex(" a", "a", 0)
   && $mb->rindex(" a", "a", 1) eq rindex(" a", "a", 1)
   && $mb->rindex(" a", "a", 2) eq rindex(" a", "a", 2)
   && $mb->rindex(" a", "a",10) eq rindex(" a", "a",10)
  ? "ok" : "not ok", " 6\n";

{
  my $str = '+0.1231425126-*12346';
  my $zen = '¡Ü£°¡¥£±£²3£±£´£²£µ£±£²6-¡ö£±£²£³4£¶';
  my $sub = '12';
  my $sbz = '£±£²';
  my($pos,$si, $bi);

  my $n = 1;
  my $NG;
  $NG = 0;
  for $pos (-10..18){
    $si = index($str,$sub,$pos);
    $bi = $mb->index($zen,$sbz,$pos);
    $NG++ if $si != $bi;
  }
  print !$NG ? "ok" : "not ok", " 7\n";

  $NG = 0;
  for $pos (-10..16){
    $si = rindex($str,$sub,$pos);
    $bi = $mb->rindex($zen,$sbz,$pos);
    $NG++ if $si != $bi;
  }
  print !$NG ? "ok" : "not ok", " 8\n";
}

{
  my($str,$ref);
  $ref = '»ú´ÁËÜÆüŽµŽ´Ž³Ž²Ž±OEUIAoeuia¤ª¤¨¤¦¤¤¤¢';
  $str = '¤¢¤¤¤¦¤¨¤ªaiueoAIUEOŽ±Ž²Ž³Ž´ŽµÆüËÜ´Á»ú';
  print $ref eq $mb->strrev($str)
    && $mb->strspn ("+0.12345*12", "+-.0123456789") == 8
    && $mb->strcspn("Perl¤ÏÌÌÇò¤¤¡£", "ÀÖÀÄ²«Çò¹õ") == 6
    ? "ok" : "not ok", " 9\n";
}

{
  my $str = "¤Ê¤ó¤È¤¤¤ª¤¦¤«";
print
 $mb->strtr(\$str,"¤¢¤¤¤¦¤¨¤ª", "¥¢¥¤¥¦¥¨¥ª")." ".$str eq "3 ¤Ê¤ó¤È¥¤¥ª¥¦¤«"
 && $mb->strtr('¤ª¤«¤«¤¦¤á¤Ü¤·¡¡¤Á¤Á¤È¤Ï¤Ï', '¤¡-¤ó', '', 's')
	eq '¤ª¤«¤¦¤á¤Ü¤·¡¡¤Á¤È¤Ï'
 && $mb->strtr("¾ò·ï±é»»»Ò¤Î»È¤¤¤¹¤®¤Ï¸«¶ì¤·¤¤", '¤¡-¤ó', '¡ô', 'cs')
	eq '¡ô¤Î¡ô¤¤¤¹¤®¤Ï¡ô¤·¤¤'
 && $mb->strtr("90 - 32 = 58", "0-9", "A-J") eq "JA - DC = FI"
 && $mb->strtr("90 - 32 = 58", "0-9", "A-J", "R") eq "JA - 32 = 58"
  ? "ok" : "not ok", " 10\n";
}
{
  my $digit_tr = $mb->trclosure(
    "1234567890-",
    "°ìÆó»°»Í¸ÞÏ»¼·È¬¶å¡»¡Ý"
  );

  my $frstr1 = "TEL¡§0124-45-6789\n";
  my $tostr1 = "TEL¡§¡»°ìÆó»Í¡Ý»Í¸Þ¡ÝÏ»¼·È¬¶å\n";
  my $frstr2 = "FAX¡§0124-51-5368\n";
  my $tostr2 = "FAX¡§¡»°ìÆó»Í¡Ý¸Þ°ì¡Ý¸Þ»°Ï»È¬\n";

  my $restr1 = &$digit_tr($frstr1);
  my $restr2 = &$digit_tr($frstr2);

  print $tostr1 eq $restr1 && $tostr2 eq $restr2
    ? "ok" : "not ok", " 11\n";
}

{
  my $printZ2H = $mb->trclosure(
    '£°-£¹£Á-£Ú£á-£ú¡¡¡á¡Ü¡Ý¡©¡ª¡ô¡ð¡ó¡õ¡÷¡ö¡ã¡ä¡Ê¡Ë¡Î¡Ï¡Ð¡Ñ',
    '0-9A-Za-z =+\-?!#$%&@*<>()[]{}',
  );
  my $NG;
  my $str = '01234567';
  my $zen = '0£±£²£³456£·';
  my($i,$j);

  $NG = 0;
  for $i (-10..10){
    next if 5.004 > $] && $i < -8;
    local $^W = 0;
    my $s = substr($str,$i);
    my $t = $mb->substr($zen,$i);
    for($s,$t){$_ = 'undef' if ! defined $_;}
    ++$NG unless $s eq &$printZ2H($t);
  }
  print ! $NG ? "ok" : "not ok", " 12\n";

  $NG = 0;
  for $i (-10..10){
    next if 5.004 > $] && $i < -8;
    for $j (undef,-10..10){
      local $^W = 0;
      my $s = substr($str,$i,$j);
      my $t = $mb->substr($zen,$i,$j);
      for($s,$t){$_ = 'undef' if ! defined $_;}
      ++$NG unless $s eq &$printZ2H($t);
    }
  }
  print ! $NG ? "ok" : "not ok", " 13\n";

  $NG = 0;
  for $i (-8..8){
    local $^W = 0;
    my $s = $str; 
    my $t = $zen;
    substr($s,$i) = "RE";
    ${ $mb->substr(\$t,$i) } = "£Ò£Å";
    ++$NG unless $s eq &$printZ2H($t);
  }
  print ! $NG ? "ok" : "not ok", " 14\n";

  $NG = 0;
  for $i (-8..8){
    for $j (undef,-10..10){
      local $^W = 0;
      my $s = $str; 
      my $t = $zen;
      substr($s,$i,$j) = "RE";
      ${ $mb->substr(\$t,$i,$j) } = "£Ò£Å";
      ++$NG unless $s eq &$printZ2H($t);
    }
  }
  print ! $NG ? "ok" : "not ok", " 15\n";

  $NG = 0;
  for $i (-8..8){
    last if 5.005 > $];
    for $j (-10..10){
      local $^W = 0;
      my $s = $str; 
      my $t = $zen;
      my $core;
      eval '$core = substr($s,$i,$j,"OK")';
      my $mbcs = $mb->substr($t,$i,$j,"£Ï£Ë");
      ++$NG unless $s eq &$printZ2H($t) && $core eq &$printZ2H($mbcs);
    }
  }
  print ! $NG ? "ok" : "not ok", " 16\n";
}

{
  my $NG;

  my $digitH = $mb->mkrange('0-9');
  my $digitZ = $mb->mkrange('£°-£¹');
  my $lowerH = $mb->mkrange('a-z');
  my $lowerZ = $mb->mkrange('£á-£ú');
  my $upperH = $mb->mkrange('A-Z');
  my $upperZ = $mb->mkrange('£Á-£Ú');
  my $alphaH = $mb->mkrange('A-Za-z');
  my $alphaZ = $mb->mkrange('£Á-£Ú£á-£ú');
  my $alnumH = $mb->mkrange('0-9A-Za-z');
  my $alnumZ = $mb->mkrange('£°-£¹£Á-£Ú£á-£ú');

  my $digitZ2H = $mb->trclosure($digitZ, $digitH);
  my $upperZ2H = $mb->trclosure($upperZ, $upperH);
  my $lowerZ2H = $mb->trclosure($lowerZ, $lowerH);
  my $alphaZ2H = $mb->trclosure($alphaZ, $alphaH);
  my $alnumZ2H = $mb->trclosure($alnumZ, $alnumH);

  my $digitH2Z = $mb->trclosure($digitH, $digitZ);
  my $upperH2Z = $mb->trclosure($upperH, $upperZ);
  my $lowerH2Z = $mb->trclosure($lowerH, $lowerZ);
  my $alphaH2Z = $mb->trclosure($alphaH, $alphaZ);
  my $alnumH2Z = $mb->trclosure($alnumH, $alnumZ);

  my($H,$Z,$tr);
  for $H ($digitH, $lowerH, $upperH){
    for $tr ($digitZ2H, $upperZ2H, $lowerZ2H, $alphaZ2H, $alnumZ2H){
      ++$NG unless $H eq &$tr($H);
    }
  }
  for $Z ($digitZ, $lowerZ, $upperZ){
    for $tr ($digitH2Z, $upperH2Z, $lowerH2Z, $alphaH2Z, $alnumH2Z){
      ++$NG unless $Z eq &$tr($Z);
    }
  }
  print !$NG ? "ok" : "not ok", " 17\n";

  print $digitZ eq &$digitH2Z($digitH)
     && $digitH eq &$upperH2Z($digitH)
     && $digitH eq &$lowerH2Z($digitH)
     && $digitH eq &$alphaH2Z($digitH)
     && $digitZ eq &$alnumH2Z($digitH)
      ? "ok" : "not ok", " 18\n";
  print $upperH eq &$digitH2Z($upperH)
     && $upperZ eq &$upperH2Z($upperH)
     && $upperH eq &$lowerH2Z($upperH)
     && $upperZ eq &$alphaH2Z($upperH)
     && $upperZ eq &$alnumH2Z($upperH)
      ? "ok" : "not ok", " 19\n";
  print $lowerH eq &$digitH2Z($lowerH)
     && $lowerH eq &$upperH2Z($lowerH)
     && $lowerZ eq &$lowerH2Z($lowerH)
     && $lowerZ eq &$alphaH2Z($lowerH)
     && $lowerZ eq &$alnumH2Z($lowerH)
      ? "ok" : "not ok", " 20\n";
  print $digitH eq &$digitZ2H($digitZ)
     && $digitZ eq &$upperZ2H($digitZ)
     && $digitZ eq &$lowerZ2H($digitZ)
     && $digitZ eq &$alphaZ2H($digitZ)
     && $digitH eq &$alnumZ2H($digitZ)
      ? "ok" : "not ok", " 21\n";
  print $upperZ eq &$digitZ2H($upperZ)
     && $upperH eq &$upperZ2H($upperZ)
     && $upperZ eq &$lowerZ2H($upperZ)
     && $upperH eq &$alphaZ2H($upperZ)
     && $upperH eq &$alnumZ2H($upperZ)
      ? "ok" : "not ok", " 22\n";
  print $lowerZ eq &$digitZ2H($lowerZ)
     && $lowerZ eq &$upperZ2H($lowerZ)
     && $lowerH eq &$lowerZ2H($lowerZ)
     && $lowerH eq &$alphaZ2H($lowerZ)
     && $lowerH eq &$alnumZ2H($lowerZ)
      ? "ok" : "not ok", " 23\n";
}

{
  my($a,$b,$c,$d);

  $a = $b = "abcdefg-123456789";
  $c = $mb->strtr(\$a,'a-cd','15-7','R');
  $d = $b =~ tr'a-cd'15-7';
  print $a eq $b && $c == $d ? "ok" : "not ok", " 24\n";

  my @uc = ("", "I", "IA", "AIS", "ASIB","AAA");
  my @lc = ("", "i", "ia", "ais", "asib","aba");
  my @mod = ("", "d", "c", "cd", "s", "sd", "sc", "scd");
  my $str = "THIS IS A PEN. YOU ARE A RABBIT.";
  my($i, $j, $m, $cstr, $mstr, $ccnt, $mcnt);

  for $m(0..$#mod){
    $NG = 0;
    for $i(0..$#uc){
      for $j(0..$#lc){
        $mstr = $cstr = $str;
        $ccnt = eval "\$cstr =~ tr/$uc[$i]/$lc[$j]/$mod[$m];";
        $mcnt = $mb->strtr(\$mstr, $uc[$i], $lc[$j], $mod[$m]);
        ++$NG unless $cstr eq $mstr && $ccnt == $mcnt;
      }
    }
    print ! $NG ? "ok" : "not ok", " ", $m+25, "\n"; 
  }
}

{
  my $printZ2H = $mb->trclosure(
    '£°-£¹£Á-£Ú£á-£ú¡¡¡¿¡á¡Ü¡Ý¡¥¡¤¡§¡¨¡©¡ª¡ô¡ð¡ó¡õ¡÷¡ö¡ã¡ä¡Ê¡Ë¡Î¡Ï¡Ð¡Ñ',
    '0-9A-Za-z /=+\-.,:;?!#$%&@*<>()[]{}',
  );

  my $str = '  This  is   a  TEST =@ ';
  my $zen = '¡¡ T£èi£ó¡¡ is¡¡ ¡¡a  £Ô£ÅST¡¡¡á@ ';

  my($n, $NG);

# splitchar in scalar context
  $NG = 0;
  for $n (-1..20){
    my $core = @{[ split(//, $str, $n) ]};
    my $mbcs = $mb->strsplit('',$zen,$n);
    ++$NG unless $core == $mbcs;
  }
  print !$NG ? "ok" : "not ok", " 33\n";

# splitchar in list context
  $NG = 0;
  for $n (-1..20){
    my $core = join ':', split //, $str, $n;
    my $mbcs = join ':', $mb->strsplit('',$zen,$n);
    ++$NG unless $core eq &$printZ2H($mbcs);
  }
  print !$NG ? "ok" : "not ok", " 34\n";

# split / / in list context
  $NG = 0;
  for $n (-1..5){
    my $core = join ':', split(/ /, $str, $n);
    my $mbcs = join ':', $mb->strsplit(' ',$str,$n);
    ++$NG unless $core eq &$printZ2H($mbcs);
  }
  print !$NG ? "ok" : "not ok", " 35\n";
}

my %h = $mb->strtr("hotchpotch", "a-z", '', 'h');
print "c-2;h-3;o-2;p-1;t-2;" eq join('', map { "$_-$h{$_};" } sort keys %h)
  ? "ok" : "not ok", " 36\n";
