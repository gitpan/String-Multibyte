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

my $sjis = String::Multibyte->new('ShiftJIS',1);

{
  my $v;
  my $NG = 0;
  for(
	"Š¿šƒeƒXƒg",
	"abc",
	"±²³´µ",
	"Êß°Ù=Perl",
	"\001\002\003\000\n",
	"",
	" ",
	'@',
  ){ $NG++ unless $sjis->islegal($_) }

  for(
	"‚»‚ê‚à‚»‚¤‚¾\xFF\xFF",
	"‚Ç‚¤‚É‚à‚±‚¤‚É‚à\x81\x39",
	"\x91\x00",
	"‚±‚ê‚Í\xFF‚Ç‚¤‚©‚È",
  ){ $NG++ unless ! $sjis->islegal($_) }

  print ! $NG
  && $sjis->islegal("‚ ", "P", "", "¶İ¼Ş test")
  && ! $sjis->islegal("“ú–{","‚³kanji","\xA0","PERL")
	? "ok" : "not ok", " 2\n";
}

print 0 == $sjis->length("")
  &&  3 == $sjis->length("abc")
  &&  5 == $sjis->length("±²³´µ")
  && 10 == $sjis->length("‚ ‚©‚³‚½‚È‚Í‚Ü‚â‚ç‚í")
  &&  9 == $sjis->length('AIUEO“ú–{Š¿š')
  ? "ok" : "not ok", " 3\n";

print $sjis->mkrange("") eq ""
  &&  $sjis->mkrange('-+\-XYZ-') eq "-+-XYZ-"
  &&  $sjis->mkrange("A-D") eq "ABCD"
  &&  $sjis->mkrange("‚Ÿ-‚¤") eq "‚Ÿ‚ ‚¡‚¢‚£‚¤"
  &&  $sjis->mkrange("0-9‚O-‚X") eq "0123456789‚O‚P‚Q‚R‚S‚T‚U‚V‚W‚X"
  &&  $sjis->mkrange("-0") eq "-0"
  &&  $sjis->mkrange("0-9") eq "0123456789"
  &&  $sjis->mkrange("0-9",1) eq "0123456789"
  &&  $sjis->mkrange("9-0",1) eq "9876543210"
  &&  $sjis->mkrange("0-9-5",1) eq "01234567898765"
  &&  $sjis->mkrange("0-9-5-7",1) eq "0123456789876567"
  &&  $sjis->mkrange('•\-') eq '•\-'
  &&  $sjis->mkrange('ab-') eq 'ab-'
  ? "ok" : "not ok", " 4\n";

{
  my $str = '+0.1231425126-*12346';
  my $zen = '{‚OD‚P‚Q3‚P‚S‚Q‚T‚P‚Q6-–‚P‚Q‚R4‚U';
  my $sub = '12';
  my $sbz = '‚P‚Q';
  my($pos,$si, $bi);

  my $n = 1;
  my $NG;
  $NG = 0;
  for $pos (-10..18){
    $si = index($str,$sub,$pos);
    $bi = $sjis->index($zen,$sbz,$pos);
    $NG++ if $si != $bi;
  }
  print !$NG ? "ok" : "not ok", " 5\n";

  $NG = 0;
  for $pos (-10..16){
    $si = rindex($str,$sub,$pos);
    $bi = $sjis->rindex($zen,$sbz,$pos);
    $NG++ if $si != $bi;
  }
  print !$NG ? "ok" : "not ok", " 6\n";
}

{
  my($str,$ref);
  $ref = 'šŠ¿–{“úµ´³²±OEUIAoeuia‚¨‚¦‚¤‚¢‚ ';
  $str = '‚ ‚¢‚¤‚¦‚¨aiueoAIUEO±²³´µ“ú–{Š¿š';
  print $ref eq $sjis->strrev($str)
    && $sjis->strspn ("+0.12345*12", "+-.0123456789") == 8
    && $sjis->strcspn("Perl‚Í–Ê”’‚¢B", "ÔÂ‰©”’•") == 6
    ? "ok" : "not ok", " 7\n";
}

{
  my $str = "‚È‚ñ‚Æ‚¢‚¨‚¤‚©";
print
 $sjis->strtr(\$str,"‚ ‚¢‚¤‚¦‚¨", "ƒAƒCƒEƒGƒI")." ".$str eq "3 ‚È‚ñ‚ÆƒCƒIƒE‚©"
 && $sjis->strtr('‚¨‚©‚©‚¤‚ß‚Ú‚µ@‚¿‚¿‚Æ‚Í‚Í', '‚Ÿ-‚ñ', '', 's')
	eq '‚¨‚©‚¤‚ß‚Ú‚µ@‚¿‚Æ‚Í'
 && $sjis->strtr("ğŒ‰‰Zq‚Ìg‚¢‚·‚¬‚ÍŒ©‹ê‚µ‚¢", '‚Ÿ-‚ñ', '”', 'cs')
	eq '”‚Ì”‚¢‚·‚¬‚Í”‚µ‚¢'
 && $sjis->strtr("90 - 32 = 58", "0-9", "A-J") eq "JA - DC = FI"
 && $sjis->strtr("90 - 32 = 58", "0-9", "A-J", "R") eq "JA - 32 = 58"
  ? "ok" : "not ok", " 8\n";
}
{
  my $digit_tr = $sjis->trclosure(
    "1234567890-",
    "ˆê“ñOlŒÜ˜Zµ”ª‹ãZ|"
  );

  my $frstr1 = "TELF0124-45-6789\n";
  my $tostr1 = "TELFZˆê“ñl|lŒÜ|˜Zµ”ª‹ã\n";
  my $frstr2 = "FAXF0124-51-5368\n";
  my $tostr2 = "FAXFZˆê“ñl|ŒÜˆê|ŒÜO˜Z”ª\n";

  my $restr1 = &$digit_tr($frstr1);
  my $restr2 = &$digit_tr($frstr2);

  print $tostr1 eq $restr1 && $tostr2 eq $restr2
    ? "ok" : "not ok", " 9\n";
}

{
  my $printZ2H = $sjis->trclosure(
    '‚O-‚X‚`-‚y‚-‚š@{|HI”“•—–ƒ„ijmnop',
    '0-9A-Za-z =+\-?!#$%&@*<>()[]{}',
  );
  my $NG;
  my $str = '01234567';
  my $zen = '0‚P‚Q‚R456‚V';
  my($i,$j);

  $NG = 0;
  for $i (-10..10){
    next if 5.004 > $] && $i < -8;
    local $^W = 0;
    my $s = substr($str,$i);
    my $t = $sjis->substr($zen,$i);
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
      my $t = $sjis->substr($zen,$i,$j);
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
    ${ $sjis->substr(\$t,$i) } = "‚q‚d";
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
      ${ $sjis->substr(\$t,$i,$j) } = "‚q‚d";
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
      my $mbcs = $sjis->substr($t,$i,$j,"‚n‚j");
      ++$NG unless $s eq &$printZ2H($t) && $core eq &$printZ2H($mbcs);
    }
  }
  print ! $NG ? "ok" : "not ok", " 14\n";
}

{
  my $NG;

  my $digitH = $sjis->mkrange('0-9');
  my $digitZ = $sjis->mkrange('‚O-‚X');
  my $lowerH = $sjis->mkrange('a-z');
  my $lowerZ = $sjis->mkrange('‚-‚š');
  my $upperH = $sjis->mkrange('A-Z');
  my $upperZ = $sjis->mkrange('‚`-‚y');
  my $alphaH = $sjis->mkrange('A-Za-z');
  my $alphaZ = $sjis->mkrange('‚`-‚y‚-‚š');
  my $alnumH = $sjis->mkrange('0-9A-Za-z');
  my $alnumZ = $sjis->mkrange('‚O-‚X‚`-‚y‚-‚š');

  my $digitZ2H = $sjis->trclosure($digitZ, $digitH);
  my $upperZ2H = $sjis->trclosure($upperZ, $upperH);
  my $lowerZ2H = $sjis->trclosure($lowerZ, $lowerH);
  my $alphaZ2H = $sjis->trclosure($alphaZ, $alphaH);
  my $alnumZ2H = $sjis->trclosure($alnumZ, $alnumH);

  my $digitH2Z = $sjis->trclosure($digitH, $digitZ);
  my $upperH2Z = $sjis->trclosure($upperH, $upperZ);
  my $lowerH2Z = $sjis->trclosure($lowerH, $lowerZ);
  my $alphaH2Z = $sjis->trclosure($alphaH, $alphaZ);
  my $alnumH2Z = $sjis->trclosure($alnumH, $alnumZ);

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
  $c = $sjis->strtr(\$a,'a-cd','15-7','R');
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
        $mcnt = $sjis->strtr(\$mstr, $uc[$i], $lc[$j], $mod[$m]);
        ++$NG unless $cstr eq $mstr && $ccnt == $mcnt;
      }
    }
    print ! $NG ? "ok" : "not ok", " ", $m+23, "\n"; 
  }
}

{
  my $printZ2H = $sjis->trclosure(
    '‚O-‚X‚`-‚y‚-‚š@^{|DCFGHI”“•—–ƒ„ijmnop',
    '0-9A-Za-z /=+\-.,:;?!#$%&@*<>()[]{}',
  );

  my $str = '  This  is   a  TEST =@ ';
  my $zen = '@ T‚ˆi‚“@ is@ @a  ‚s‚dST@@ ';

  my($n, $NG);

# splitchar in scalar context
  $NG = 0;
  for $n (-1..20){
    my $core = @{[ split(//, $str, $n) ]};
    my $mbcs = $sjis->strsplit('',$zen,$n);
    ++$NG unless $core == $mbcs;
  }
  print !$NG ? "ok" : "not ok", " 31\n";

# splitchar in list context
  $NG = 0;
  for $n (-1..20){
    my $core = join ':', split //, $str, $n;
    my $mbcs = join ':', $sjis->strsplit('',$zen,$n);
    ++$NG unless $core eq &$printZ2H($mbcs);
  }
  print !$NG ? "ok" : "not ok", " 32\n";

# split / / in list context
  $NG = 0;
  for $n (-1..5){
    my $core = join ':', split(/ /, $str, $n);
    my $mbcs = join ':', $sjis->strsplit(' ',$str,$n);
    ++$NG unless $core eq &$printZ2H($mbcs);
  }
  print !$NG ? "ok" : "not ok", " 33\n";
}
