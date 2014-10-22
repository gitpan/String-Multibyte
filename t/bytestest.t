# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..27\n"; }
END {print "not ok 1\n" unless $loaded;}
use String::Multibyte;
$^W = 1;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my $bytes = String::Multibyte->new('Bytes',1);

{
  my $v;
  my $NG = 0;
  for(
	"�����e�X�g",
	"abc",
	"�����",
	"�߰�=Perl",
	"\001\002\003\000\n",
	"",
	" ",
	'�@',
	"�����������\xFF\xFF",
	"�ǂ��ɂ������ɂ�\x81\x39",
	"\x91\x00",
	"�����\xFF�ǂ�����",
  ){ $NG++ unless $bytes->islegal($_) }

  print ! $NG
  && $bytes->islegal("��", "P", "", "�ݼ� test")
  && $bytes->islegal("���{","��kanji","\xA0","PERL")
	? "ok" : "not ok", " 2\n";
}

print 0 == $bytes->length("")
  &&  3 == $bytes->length("abc")
  &&  5 == $bytes->length("�����")
  && 20 == $bytes->length("���������Ȃ͂܂���")
  && 13 == $bytes->length('AIUEO���{����')
  ? "ok" : "not ok", " 3\n";

print $bytes->mkrange("") eq ""
  &&  $bytes->mkrange('-+\-XYZ-') eq "-+-XYZ-"
  &&  $bytes->mkrange("A-D") eq "ABCD"
  &&  $bytes->mkrange("-0") eq "-0"
  &&  $bytes->mkrange("0-9") eq "0123456789"
  &&  $bytes->mkrange("0-9",1) eq "0123456789"
  &&  $bytes->mkrange("9-0",1) eq "9876543210"
  &&  $bytes->mkrange("0-9-5",1) eq "01234567898765"
  &&  $bytes->mkrange("0-9-5-7",1) eq "0123456789876567"
  &&  $bytes->mkrange('A\-') eq 'A-'
  &&  $bytes->mkrange('ab-') eq 'ab-'
  ? "ok" : "not ok", " 4\n";

{
  my $str = '+0.1231425126-*12346';
  my $sub = '12';
  my($pos,$si, $bi);

  my $n = 1;
  my $NG;
  $NG = 0;
  for $pos (-10..18){
    $si = index($str,$sub,$pos);
    $bi = $bytes->index($str,$sub,$pos);
    $NG++ if $si != $bi;
  }
  print !$NG ? "ok" : "not ok", " 5\n";

  $NG = 0;
  for $pos (-10..16){
    $si = rindex($str,$sub,$pos);
    $bi = $bytes->rindex($str,$sub,$pos);
    $NG++ if $si != $bi;
  }
  print !$NG ? "ok" : "not ok", " 6\n";
}

{
  my($str,$ref);
  $ref = '�����OEUIAoeuia';
  $str = 'aiueoAIUEO�����';
  print $ref eq $bytes->strrev($str)
    && $bytes->strspn ("+0.12345*12", "+-.0123456789") == 8
    && $bytes->strcspn("Perl5.6", "0123456789") == 4
    ? "ok" : "not ok", " 7\n";
}

{
  print $bytes->strtr("90 - 32 = 58", "0-9", "A-J") eq "JA - DC = FI"
     && $bytes->strtr("90 - 32 = 58", "0-9", "A-J", "R") eq "JA - 32 = 58"
    ? "ok" : "not ok", " 8\n";
}
{
  my $digit_tr = $bytes->trclosure(
    "1234567890-",
    "ABCDEFGHIJ="
  );

  my $frstr1 = "TEL�F0124-45-6789\n";
  my $tostr1 = "TEL�FJABD=DE=FGHI\n";
  my $frstr2 = "FAX�F0124-51-5368\n";
  my $tostr2 = "FAX�FJABD=EA=ECFH\n";

  my $restr1 = &$digit_tr($frstr1);
  my $restr2 = &$digit_tr($frstr2);

  print $tostr1 eq $restr1 && $tostr2 eq $restr2
    ? "ok" : "not ok", " 9\n";
}

{
  my $NG;
  my $str = '01234567';
  my($i,$j);

  $NG = 0;
  for $i (-10..10){
    next if 5.004 > $] && $i < -8;
    local $^W = 0;
    my $s = substr($str,$i);
    my $t = $bytes->substr($str,$i);
    for($s,$t){$_ = 'undef' if ! defined $_;}
    ++$NG unless $s eq $t;
  }
  print ! $NG ? "ok" : "not ok", " 10\n";

  $NG = 0;
  for $i (-10..10){
    next if 5.004 > $] && $i < -8;
    for $j (undef,-10..10){
      local $^W = 0;
      my $s = substr($str,$i,$j);
      my $t = $bytes->substr($str,$i,$j);
      for($s,$t){$_ = 'undef' if ! defined $_;}
      ++$NG unless $s eq $t;
    }
  }
  print ! $NG ? "ok" : "not ok", " 11\n";

  $NG = 0;
  for $i (-8..8){
    local $^W = 0;
    my $s = $str; 
    my $t = $str;
    substr($s,$i) = "RE";
    ${ $bytes->substr(\$t,$i) } = "RE";
    ++$NG unless $s eq $t;
  }
  print ! $NG ? "ok" : "not ok", " 12\n";

  $NG = 0;
  for $i (-8..8){
    for $j (undef,-10..10){
      local $^W = 0;
      my $s = $str; 
      my $t = $str;
      substr($s,$i,$j) = "RE";
      ${ $bytes->substr(\$t,$i,$j) } = "RE";
      ++$NG unless $s eq $t;
    }
  }
  print ! $NG ? "ok" : "not ok", " 13\n";

  $NG = 0;
  for $i (-8..8){
    last if 5.005 > $];
    for $j (-10..10){
      local $^W = 0;
      my $s = $str; 
      my $t = $str;
      my $core;
      eval '$core = substr($s,$i,$j,"OK")';
      my $mbcs = $bytes->substr($t,$i,$j,"OK");
      ++$NG unless $s eq $t && $core eq $mbcs;
    }
  }
  print ! $NG ? "ok" : "not ok", " 14\n";
}

{
  my $NG;

  my $lower = $bytes->mkrange('a-z');
  my $upper = $bytes->mkrange('A-Z');
  my $digit = $bytes->mkrange('0-9');

  my $toupper = $bytes->trclosure($lower, $upper);
  my $tolower = $bytes->trclosure($upper, $lower);

  my($r,$tr);
  for $r ($upper, $digit){
    for $tr ($toupper){
      ++$NG unless $r eq &$tr($r);
    }
  }
  for $r ($lower, $digit){
    for $tr ($tolower){
      ++$NG unless $r eq &$tr($r);
    }
  }
  print !$NG
     && $upper eq &$toupper($lower)
     && $lower eq &$tolower($upper)
      ? "ok" : "not ok", " 15\n";
}

{
  my($a,$b,$c,$d);

  $a = $b = "abcdefg-123456789";
  $c = $bytes->strtr(\$a,'a-cd','15-7','R');
  $d = $b =~ tr'a-cd'15-7';
  print $a eq $b && $c == $d ? "ok" : "not ok", " 16\n";

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
        $mcnt = $bytes->strtr(\$mstr, $uc[$i], $lc[$j], $mod[$m]);
        ++$NG unless $cstr eq $mstr && $ccnt == $mcnt;
      }
    }
    print ! $NG ? "ok" : "not ok", " ", $m+17, "\n"; 
  }
}

{
  my $str = '  This  is   a  TEST =@ ';
  my($n, $NG);

# splitchar in scalar context
  $NG = 0;
  for $n (-1..20){
    my $core = @{[ split(//, $str, $n) ]};
    my $mbcs = $bytes->strsplit('',$str,$n);
    ++$NG unless $core == $mbcs;
  }
  print !$NG ? "ok" : "not ok", " 25\n";

# splitchar in list context
  $NG = 0;
  for $n (-1..20){
    my $core = join ':', split //, $str, $n;
    my $mbcs = join ':', $bytes->strsplit('',$str,$n);
    ++$NG unless $core eq $mbcs;
  }
  print !$NG ? "ok" : "not ok", " 26\n";

# split / / in list context
  $NG = 0;
  for $n (-1..5){
    my $core = join ':', split(/ /, $str, $n);
    my $mbcs = join ':', $bytes->strsplit(' ',$str,$n);
    ++$NG unless $core eq $mbcs;
  }
  print !$NG ? "ok" : "not ok", " 27\n";
}
