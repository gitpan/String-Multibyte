# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..33\n"; }
END {print "not ok 1\n" unless $loaded;}
use String::Multibyte;
$^W = 1;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my $euc = String::Multibyte->new('EUC',1);

{
  my $v;
  my $NG = 0;
  for(
	"´Á»ú¥Æ¥¹¥È",
	"abc",
	"\001\002\003\000\n",
	"",
	" ",
	'¡¡',
  ){ $NG++ unless $euc->islegal($_) }

  for(
	"¤½¤ì¤â¤½¤¦¤À\xFF\xFF",
	"¤É¤¦¤Ë¤â¤³¤¦¤Ë¤â\x81\x39",
	"Ž±Ž²Ž³Ž´Žµ",
	"ŽÊŽßŽ°ŽÙ=Perl",
	"\x91\x00",
	"¤³¤ì¤Ï\xFF¤É¤¦¤«¤Ê",
  ){ $NG++ unless ! $euc->islegal($_) }

  print ! $NG
  && $euc->islegal("¤¢", "P", "", "´Á»útest")
  && ! $euc->islegal("ÆüËÜ","¤µkanji","\xA0","PERL")
	? "ok" : "not ok", " 2\n";
}

print 0 == $euc->length("")
  &&  3 == $euc->length("abc")
  && 10 == $euc->length("¤¢¤«¤µ¤¿¤Ê¤Ï¤Þ¤ä¤é¤ï")
  &&  9 == $euc->length('AIUEOÆüËÜ´Á»ú')
  ? "ok" : "not ok", " 3\n";

print $euc->mkrange("") eq ""
  &&  $euc->mkrange('-+\-XYZ-') eq "-+-XYZ-"
  &&  $euc->mkrange("A-D") eq "ABCD"
  &&  $euc->mkrange("¤¡-¤¦") eq "¤¡¤¢¤£¤¤¤¥¤¦"
  &&  $euc->mkrange("0-9£°-£¹") eq "0123456789£°£±£²£³£´£µ£¶£·£¸£¹"
  &&  $euc->mkrange("-0") eq "-0"
  &&  $euc->mkrange("0-9") eq "0123456789"
  &&  $euc->mkrange("0-9",1) eq "0123456789"
  &&  $euc->mkrange("9-0",1) eq "9876543210"
  &&  $euc->mkrange("0-9-5",1) eq "01234567898765"
  &&  $euc->mkrange("0-9-5-7",1) eq "0123456789876567"
  &&  $euc->mkrange('É½-') eq 'É½-'
  &&  $euc->mkrange('ab-') eq 'ab-'
  ? "ok" : "not ok", " 4\n";

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
    $bi = $euc->index($zen,$sbz,$pos);
    $NG++ if $si != $bi;
  }
  print !$NG ? "ok" : "not ok", " 5\n";

  $NG = 0;
  for $pos (-10..16){
    $si = rindex($str,$sub,$pos);
    $bi = $euc->rindex($zen,$sbz,$pos);
    $NG++ if $si != $bi;
  }
  print !$NG ? "ok" : "not ok", " 6\n";
}

{
  my($str,$ref);
  $ref = '»ú´ÁËÜÆüOEUIAoeuia¤ª¤¨¤¦¤¤¤¢';
  $str = '¤¢¤¤¤¦¤¨¤ªaiueoAIUEOÆüËÜ´Á»ú';
  print $ref eq $euc->strrev($str)
    && $euc->strspn ("+0.12345*12", "+-.0123456789") == 8
    && $euc->strcspn("Perl¤ÏÌÌÇò¤¤¡£", "ÀÖÀÄ²«Çò¹õ") == 6
    ? "ok" : "not ok", " 7\n";
}

{
  my $str = "¤Ê¤ó¤È¤¤¤ª¤¦¤«";
print
 $euc->strtr(\$str,"¤¢¤¤¤¦¤¨¤ª", "¥¢¥¤¥¦¥¨¥ª")." ".$str eq "3 ¤Ê¤ó¤È¥¤¥ª¥¦¤«"
 && $euc->strtr('¤ª¤«¤«¤¦¤á¤Ü¤·¡¡¤Á¤Á¤È¤Ï¤Ï', '¤¡-¤ó', '', 's')
	eq '¤ª¤«¤¦¤á¤Ü¤·¡¡¤Á¤È¤Ï'
 && $euc->strtr("¾ò·ï±é»»»Ò¤Î»È¤¤¤¹¤®¤Ï¸«¶ì¤·¤¤", '¤¡-¤ó', '¡ô', 'cs')
	eq '¡ô¤Î¡ô¤¤¤¹¤®¤Ï¡ô¤·¤¤'
 && $euc->strtr("90 - 32 = 58", "0-9", "A-J") eq "JA - DC = FI"
 && $euc->strtr("90 - 32 = 58", "0-9", "A-J", "R") eq "JA - 32 = 58"
  ? "ok" : "not ok", " 8\n";
}
{
  my $digit_tr = $euc->trclosure(
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
    ? "ok" : "not ok", " 9\n";
}

{
  my $printZ2H = $euc->trclosure(
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
    my $t = $euc->substr($zen,$i);
    for($s,$t){$_ = 'undef' if ! defined $_;}
    ++$NG unless $s eq &$printZ2H($t);
  }
  print ! $NG ? "ok" : "not ok", " 10\n";

  $NG = 0;
  for $i (-10..10){
    next if 5.004 > $] && $i < -8;
    for $j (undef,-10..10){
      local $^W = 0;
      my $s = substr($str,$i,$j);
      my $t = $euc->substr($zen,$i,$j);
      for($s,$t){$_ = 'undef' if ! defined $_;}
      ++$NG unless $s eq &$printZ2H($t);
    }
  }
  print ! $NG ? "ok" : "not ok", " 11\n";

  $NG = 0;
  for $i (-8..8){
    local $^W = 0;
    my $s = $str; 
    my $t = $zen;
    substr($s,$i) = "RE";
    ${ $euc->substr(\$t,$i) } = "£Ò£Å";
    ++$NG unless $s eq &$printZ2H($t);
  }
  print ! $NG ? "ok" : "not ok", " 12\n";

  $NG = 0;
  for $i (-8..8){
    for $j (undef,-10..10){
      local $^W = 0;
      my $s = $str; 
      my $t = $zen;
      substr($s,$i,$j) = "RE";
      ${ $euc->substr(\$t,$i,$j) } = "£Ò£Å";
      ++$NG unless $s eq &$printZ2H($t);
    }
  }
  print ! $NG ? "ok" : "not ok", " 13\n";

  $NG = 0;
  for $i (-8..8){
    last if 5.005 > $];
    for $j (-10..10){
      local $^W = 0;
      my $s = $str; 
      my $t = $zen;
      my $core;
      eval '$core = substr($s,$i,$j,"OK")';
      my $mbcs = $euc->substr($t,$i,$j,"£Ï£Ë");
      ++$NG unless $s eq &$printZ2H($t) && $core eq &$printZ2H($mbcs);
    }
  }
  print ! $NG ? "ok" : "not ok", " 14\n";
}

{
  my $NG;

  my $digitH = $euc->mkrange('0-9');
  my $digitZ = $euc->mkrange('£°-£¹');
  my $lowerH = $euc->mkrange('a-z');
  my $lowerZ = $euc->mkrange('£á-£ú');
  my $upperH = $euc->mkrange('A-Z');
  my $upperZ = $euc->mkrange('£Á-£Ú');
  my $alphaH = $euc->mkrange('A-Za-z');
  my $alphaZ = $euc->mkrange('£Á-£Ú£á-£ú');
  my $alnumH = $euc->mkrange('0-9A-Za-z');
  my $alnumZ = $euc->mkrange('£°-£¹£Á-£Ú£á-£ú');

  my $digitZ2H = $euc->trclosure($digitZ, $digitH);
  my $upperZ2H = $euc->trclosure($upperZ, $upperH);
  my $lowerZ2H = $euc->trclosure($lowerZ, $lowerH);
  my $alphaZ2H = $euc->trclosure($alphaZ, $alphaH);
  my $alnumZ2H = $euc->trclosure($alnumZ, $alnumH);

  my $digitH2Z = $euc->trclosure($digitH, $digitZ);
  my $upperH2Z = $euc->trclosure($upperH, $upperZ);
  my $lowerH2Z = $euc->trclosure($lowerH, $lowerZ);
  my $alphaH2Z = $euc->trclosure($alphaH, $alphaZ);
  my $alnumH2Z = $euc->trclosure($alnumH, $alnumZ);

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
  print !$NG ? "ok" : "not ok", " 15\n";

  print $digitZ eq &$digitH2Z($digitH)
     && $digitH eq &$upperH2Z($digitH)
     && $digitH eq &$lowerH2Z($digitH)
     && $digitH eq &$alphaH2Z($digitH)
     && $digitZ eq &$alnumH2Z($digitH)
      ? "ok" : "not ok", " 16\n";
  print $upperH eq &$digitH2Z($upperH)
     && $upperZ eq &$upperH2Z($upperH)
     && $upperH eq &$lowerH2Z($upperH)
     && $upperZ eq &$alphaH2Z($upperH)
     && $upperZ eq &$alnumH2Z($upperH)
      ? "ok" : "not ok", " 17\n";
  print $lowerH eq &$digitH2Z($lowerH)
     && $lowerH eq &$upperH2Z($lowerH)
     && $lowerZ eq &$lowerH2Z($lowerH)
     && $lowerZ eq &$alphaH2Z($lowerH)
     && $lowerZ eq &$alnumH2Z($lowerH)
      ? "ok" : "not ok", " 18\n";
  print $digitH eq &$digitZ2H($digitZ)
     && $digitZ eq &$upperZ2H($digitZ)
     && $digitZ eq &$lowerZ2H($digitZ)
     && $digitZ eq &$alphaZ2H($digitZ)
     && $digitH eq &$alnumZ2H($digitZ)
      ? "ok" : "not ok", " 19\n";
  print $upperZ eq &$digitZ2H($upperZ)
     && $upperH eq &$upperZ2H($upperZ)
     && $upperZ eq &$lowerZ2H($upperZ)
     && $upperH eq &$alphaZ2H($upperZ)
     && $upperH eq &$alnumZ2H($upperZ)
      ? "ok" : "not ok", " 20\n";
  print $lowerZ eq &$digitZ2H($lowerZ)
     && $lowerZ eq &$upperZ2H($lowerZ)
     && $lowerH eq &$lowerZ2H($lowerZ)
     && $lowerH eq &$alphaZ2H($lowerZ)
     && $lowerH eq &$alnumZ2H($lowerZ)
      ? "ok" : "not ok", " 21\n";
}

{
  my($a,$b,$c,$d);

  $a = $b = "abcdefg-123456789";
  $c = $euc->strtr(\$a,'a-cd','15-7','R');
  $d = $b =~ tr'a-cd'15-7';
  print $a eq $b && $c == $d ? "ok" : "not ok", " 22\n";

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
        $mcnt = $euc->strtr(\$mstr, $uc[$i], $lc[$j], $mod[$m]);
        ++$NG unless $cstr eq $mstr && $ccnt == $mcnt;
      }
    }
    print ! $NG ? "ok" : "not ok", " ", $m+23, "\n"; 
  }
}

{
  my $printZ2H = $euc->trclosure(
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
    my $mbcs = $euc->strsplit('',$zen,$n);
    ++$NG unless $core == $mbcs;
  }
  print !$NG ? "ok" : "not ok", " 31\n";

# splitchar in list context
  $NG = 0;
  for $n (-1..20){
    my $core = join ':', split //, $str, $n;
    my $mbcs = join ':', $euc->strsplit('',$zen,$n);
    ++$NG unless $core eq &$printZ2H($mbcs);
  }
  print !$NG ? "ok" : "not ok", " 32\n";

# split / / in list context
  $NG = 0;
  for $n (-1..5){
    my $core = join ':', split(/ /, $str, $n);
    my $mbcs = join ':', $euc->strsplit(' ',$str,$n);
    ++$NG unless $core eq &$printZ2H($mbcs);
  }
  print !$NG ? "ok" : "not ok", " 33\n";
}
