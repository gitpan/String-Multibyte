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

my $utf8 = String::Multibyte->new('UTF8',1);

{
  my $v;
  my $NG = 0;
  for(
	"漢字テスト",
	"abc",
	"ｱｲｳｴｵ",
	"ﾊﾟｰﾙ=Perl",
	"\001\002\003\000\n",
	"",
	" ",
	'　',
  ){ $NG++ unless $utf8->islegal($_) }

  for(
	"それもそうだ\xFF\xFF",
	"どうにもこうにも\x81\x39",
	"\x91\x00",
	"これは\xFFどうかな",
  ){ $NG++ unless ! $utf8->islegal($_) }

  print ! $NG
  && $utf8->islegal("あ", "P", "", "ｶﾝｼﾞ test")
  && ! $utf8->islegal("日本","さkanji","\xA0","PERL")
	? "ok" : "not ok", " 2\n";
}

print 0 == $utf8->length("")
  &&  3 == $utf8->length("abc")
  &&  5 == $utf8->length("ｱｲｳｴｵ")
  && 10 == $utf8->length("あかさたなはまやらわ")
  &&  9 == $utf8->length('AIUEO日本漢字')
  ? "ok" : "not ok", " 3\n";

print $utf8->mkrange("") eq ""
  &&  $utf8->mkrange('-+\-XYZ-') eq "-+-XYZ-"
  &&  $utf8->mkrange("A-D") eq "ABCD"
  &&  $utf8->mkrange("ぁ-う") eq "ぁあぃいぅう"
  &&  $utf8->mkrange("0-9０-９") eq "0123456789０１２３４５６７８９"
  &&  $utf8->mkrange("-0") eq "-0"
  &&  $utf8->mkrange("0-9") eq "0123456789"
  &&  $utf8->mkrange("0-9",1) eq "0123456789"
  &&  $utf8->mkrange("9-0",1) eq "9876543210"
  &&  $utf8->mkrange("0-9-5",1) eq "01234567898765"
  &&  $utf8->mkrange("0-9-5-7",1) eq "0123456789876567"
  &&  $utf8->mkrange('表-') eq '表-'
  &&  $utf8->mkrange('ab-') eq 'ab-'
  ? "ok" : "not ok", " 4\n";

{
  my $str = '+0.1231425126-*12346';
  my $zen = '＋０．１２3１４２５１２6-＊１２３4６';
  my $sub = '12';
  my $sbz = '１２';
  my($pos,$si, $bi);

  my $n = 1;
  my $NG;
  $NG = 0;
  for $pos (-10..18){
    $si = index($str,$sub,$pos);
    $bi = $utf8->index($zen,$sbz,$pos);
    $NG++ if $si != $bi;
  }
  print !$NG ? "ok" : "not ok", " 5\n";

  $NG = 0;
  for $pos (-10..16){
    $si = rindex($str,$sub,$pos);
    $bi = $utf8->rindex($zen,$sbz,$pos);
    $NG++ if $si != $bi;
  }
  print !$NG ? "ok" : "not ok", " 6\n";
}

{
  my($str,$ref);
  $ref = '字漢本日ｵｴｳｲｱOEUIAoeuiaおえういあ';
  $str = 'あいうえおaiueoAIUEOｱｲｳｴｵ日本漢字';
  print $ref eq $utf8->strrev($str)
    && $utf8->strspn ("+0.12345*12", "+-.0123456789") == 8
    && $utf8->strcspn("Perlは面白い。", "赤青黄白黒") == 6
    ? "ok" : "not ok", " 7\n";
}

{
  my $str = "なんといおうか";
print
 $utf8->strtr(\$str,"あいうえお", "アイウエオ")." ".$str eq "3 なんとイオウか"
 && $utf8->strtr('おかかうめぼし　ちちとはは', 'ぁ-ん', '', 's')
	eq 'おかうめぼし　ちとは'
 && $utf8->strtr("条件演算子の使いすぎは見苦しい", 'ぁ-ん', '＃', 'cs')
	eq '＃の＃いすぎは＃しい'
 && $utf8->strtr("90 - 32 = 58", "0-9", "A-J") eq "JA - DC = FI"
 && $utf8->strtr("90 - 32 = 58", "0-9", "A-J", "R") eq "JA - 32 = 58"
  ? "ok" : "not ok", " 8\n";
}
{
  my $digit_tr = $utf8->trclosure(
    "1234567890-",
    "一二三四五六七八九〇－"
  );

  my $frstr1 = "TEL：0124-45-6789\n";
  my $tostr1 = "TEL：〇一二四－四五－六七八九\n";
  my $frstr2 = "FAX：0124-51-5368\n";
  my $tostr2 = "FAX：〇一二四－五一－五三六八\n";

  my $restr1 = &$digit_tr($frstr1);
  my $restr2 = &$digit_tr($frstr2);

  print $tostr1 eq $restr1 && $tostr2 eq $restr2
    ? "ok" : "not ok", " 9\n";
}

{
  my $printZ2H = $utf8->trclosure(
    '０-９Ａ-Ｚａ-ｚ　＝＋－？！＃＄％＆＠＊＜＞（）［］｛｝',
    '0-9A-Za-z =+\-?!#$%&@*<>()[]{}',
  );
  my $NG;
  my $str = '01234567';
  my $zen = '0１２３456７';
  my($i,$j);

  $NG = 0;
  for $i (-10..10){
    next if 5.004 > $] && $i < -8;
    local $^W = 0;
    my $s = substr($str,$i);
    my $t = $utf8->substr($zen,$i);
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
      my $t = $utf8->substr($zen,$i,$j);
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
    ${ $utf8->substr(\$t,$i) } = "ＲＥ";
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
      ${ $utf8->substr(\$t,$i,$j) } = "ＲＥ";
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
      my $mbcs = $utf8->substr($t,$i,$j,"ＯＫ");
      ++$NG unless $s eq &$printZ2H($t) && $core eq &$printZ2H($mbcs);
    }
  }
  print ! $NG ? "ok" : "not ok", " 14\n";
}

{
  my $NG;

  my $digitH = $utf8->mkrange('0-9');
  my $digitZ = $utf8->mkrange('０-９');
  my $lowerH = $utf8->mkrange('a-z');
  my $lowerZ = $utf8->mkrange('ａ-ｚ');
  my $upperH = $utf8->mkrange('A-Z');
  my $upperZ = $utf8->mkrange('Ａ-Ｚ');
  my $alphaH = $utf8->mkrange('A-Za-z');
  my $alphaZ = $utf8->mkrange('Ａ-Ｚａ-ｚ');
  my $alnumH = $utf8->mkrange('0-9A-Za-z');
  my $alnumZ = $utf8->mkrange('０-９Ａ-Ｚａ-ｚ');

  my $digitZ2H = $utf8->trclosure($digitZ, $digitH);
  my $upperZ2H = $utf8->trclosure($upperZ, $upperH);
  my $lowerZ2H = $utf8->trclosure($lowerZ, $lowerH);
  my $alphaZ2H = $utf8->trclosure($alphaZ, $alphaH);
  my $alnumZ2H = $utf8->trclosure($alnumZ, $alnumH);

  my $digitH2Z = $utf8->trclosure($digitH, $digitZ);
  my $upperH2Z = $utf8->trclosure($upperH, $upperZ);
  my $lowerH2Z = $utf8->trclosure($lowerH, $lowerZ);
  my $alphaH2Z = $utf8->trclosure($alphaH, $alphaZ);
  my $alnumH2Z = $utf8->trclosure($alnumH, $alnumZ);

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
  $c = $utf8->strtr(\$a,'a-cd','15-7','R');
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
        $mcnt = $utf8->strtr(\$mstr, $uc[$i], $lc[$j], $mod[$m]);
        ++$NG unless $cstr eq $mstr && $ccnt == $mcnt;
      }
    }
    print ! $NG ? "ok" : "not ok", " ", $m+23, "\n"; 
  }
}

{
  my $printZ2H = $utf8->trclosure(
    '０-９Ａ-Ｚａ-ｚ　／＝＋－．，：；？！＃＄％＆＠＊＜＞（）［］｛｝',
    '0-9A-Za-z /=+\-.,:;?!#$%&@*<>()[]{}',
  );

  my $str = '  This  is   a  TEST =@ ';
  my $zen = '　 Tｈiｓ　 is　 　a  ＴＥST　＝@ ';

  my($n, $NG);

# splitchar in scalar context
  $NG = 0;
  for $n (-1..20){
    my $core = @{[ split(//, $str, $n) ]};
    my $mbcs = $utf8->strsplit('',$zen,$n);
    ++$NG unless $core == $mbcs;
  }
  print !$NG ? "ok" : "not ok", " 31\n";

# splitchar in list context
  $NG = 0;
  for $n (-1..20){
    my $core = join ':', split //, $str, $n;
    my $mbcs = join ':', $utf8->strsplit('',$zen,$n);
    ++$NG unless $core eq &$printZ2H($mbcs);
  }
  print !$NG ? "ok" : "not ok", " 32\n";

# split / / in list context
  $NG = 0;
  for $n (-1..5){
    my $core = join ':', split(/ /, $str, $n);
    my $mbcs = join ':', $utf8->strsplit(' ',$str,$n);
    ++$NG unless $core eq &$printZ2H($mbcs);
  }
  print !$NG ? "ok" : "not ok", " 33\n";
}
