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

my $ejis = String::Multibyte->new('EUC_JP',1);

{
  my $v;
  my $NG = 0;
  for(
	"�����ƥ���",
	"abc",
	"����������",
	"�ʎߎ���=Perl",
	"\001\002\003\000\n",
	"",
	" ",
	'��',
  ){ $NG++ unless $ejis->islegal($_) }

  for(
	"����⤽����\xFF\xFF",
	"�ɤ��ˤ⤳���ˤ�\x81\x39",
	"\x91\x00",
	"�����\xFF�ɤ�����",
  ){ $NG++ unless ! $ejis->islegal($_) }

  print ! $NG
  && $ejis->islegal("��", "P", "", "���ݎ��� test")
  && ! $ejis->islegal("����","��kanji","\xA0","PERL")
	? "ok" : "not ok", " 2\n";
}

print 0 == $ejis->length("")
  &&  3 == $ejis->length("abc")
  &&  5 == $ejis->length("����������")
  && 10 == $ejis->length("���������ʤϤޤ���")
  &&  9 == $ejis->length('AIUEO���ܴ���')
  ? "ok" : "not ok", " 3\n";

print $ejis->mkrange("") eq ""
  &&  $ejis->mkrange('-+\-XYZ-') eq "-+-XYZ-"
  &&  $ejis->mkrange("A-D") eq "ABCD"
  &&  $ejis->mkrange("��-��") eq "������������"
  &&  $ejis->mkrange("0-9��-��") eq "0123456789��������������������"
  &&  $ejis->mkrange("-0") eq "-0"
  &&  $ejis->mkrange("0-9") eq "0123456789"
  &&  $ejis->mkrange("0-9",1) eq "0123456789"
  &&  $ejis->mkrange("9-0",1) eq "9876543210"
  &&  $ejis->mkrange("0-9-5",1) eq "01234567898765"
  &&  $ejis->mkrange("0-9-5-7",1) eq "0123456789876567"
  &&  $ejis->mkrange('ɽ-') eq 'ɽ-'
  &&  $ejis->mkrange('ab-') eq 'ab-'
  ? "ok" : "not ok", " 4\n";

{
  my $str = '+0.1231425126-*12346';
  my $zen = '�ܣ�������3������������6-��������4��';
  my $sub = '12';
  my $sbz = '����';
  my($pos,$si, $bi);

  my $n = 1;
  my $NG;
  $NG = 0;
  for $pos (-10..18){
    $si = index($str,$sub,$pos);
    $bi = $ejis->index($zen,$sbz,$pos);
    $NG++ if $si != $bi;
  }
  print !$NG ? "ok" : "not ok", " 5\n";

  $NG = 0;
  for $pos (-10..16){
    $si = rindex($str,$sub,$pos);
    $bi = $ejis->rindex($zen,$sbz,$pos);
    $NG++ if $si != $bi;
  }
  print !$NG ? "ok" : "not ok", " 6\n";
}

{
  my($str,$ref);
  $ref = '������������������OEUIAoeuia����������';
  $str = '����������aiueoAIUEO�������������ܴ���';
  print $ref eq $ejis->strrev($str)
    && $ejis->strspn ("+0.12345*12", "+-.0123456789") == 8
    && $ejis->strcspn("Perl�����򤤡�", "���Ĳ����") == 6
    ? "ok" : "not ok", " 7\n";
}

{
  my $str = "�ʤ�Ȥ�������";
print
 $ejis->strtr(\$str,"����������", "����������")." ".$str eq "3 �ʤ�ȥ�������"
 && $ejis->strtr('����������ܤ��������ȤϤ�', '��-��', '', 's')
	eq '��������ܤ������Ȥ�'
 && $ejis->strtr("���黻�ҤλȤ������ϸ��줷��", '��-��', '��', 'cs')
	eq '���Ρ��������ϡ�����'
 && $ejis->strtr("90 - 32 = 58", "0-9", "A-J") eq "JA - DC = FI"
 && $ejis->strtr("90 - 32 = 58", "0-9", "A-J", "R") eq "JA - 32 = 58"
  ? "ok" : "not ok", " 8\n";
}
{
  my $digit_tr = $ejis->trclosure(
    "1234567890-",
    "���󻰻͸�ϻ��Ȭ�塻��"
  );

  my $frstr1 = "TEL��0124-45-6789\n";
  my $tostr1 = "TEL��������͡ݻ͸ޡ�ϻ��Ȭ��\n";
  my $frstr2 = "FAX��0124-51-5368\n";
  my $tostr2 = "FAX��������͡ݸް�ݸ޻�ϻȬ\n";

  my $restr1 = &$digit_tr($frstr1);
  my $restr2 = &$digit_tr($frstr2);

  print $tostr1 eq $restr1 && $tostr2 eq $restr2
    ? "ok" : "not ok", " 9\n";
}

{
  my $printZ2H = $ejis->trclosure(
    '��-����-�ڣ�-������ܡݡ����������������ʡˡΡϡС�',
    '0-9A-Za-z =+\-?!#$%&@*<>()[]{}',
  );
  my $NG;
  my $str = '01234567';
  my $zen = '0������456��';
  my($i,$j);

  $NG = 0;
  for $i (-10..10){
    next if 5.004 > $] && $i < -8;
    local $^W = 0;
    my $s = substr($str,$i);
    my $t = $ejis->substr($zen,$i);
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
      my $t = $ejis->substr($zen,$i,$j);
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
    ${ $ejis->substr(\$t,$i) } = "�ң�";
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
      ${ $ejis->substr(\$t,$i,$j) } = "�ң�";
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
      my $mbcs = $ejis->substr($t,$i,$j,"�ϣ�");
      ++$NG unless $s eq &$printZ2H($t) && $core eq &$printZ2H($mbcs);
    }
  }
  print ! $NG ? "ok" : "not ok", " 14\n";
}

{
  my $NG;

  my $digitH = $ejis->mkrange('0-9');
  my $digitZ = $ejis->mkrange('��-��');
  my $lowerH = $ejis->mkrange('a-z');
  my $lowerZ = $ejis->mkrange('��-��');
  my $upperH = $ejis->mkrange('A-Z');
  my $upperZ = $ejis->mkrange('��-��');
  my $alphaH = $ejis->mkrange('A-Za-z');
  my $alphaZ = $ejis->mkrange('��-�ڣ�-��');
  my $alnumH = $ejis->mkrange('0-9A-Za-z');
  my $alnumZ = $ejis->mkrange('��-����-�ڣ�-��');

  my $digitZ2H = $ejis->trclosure($digitZ, $digitH);
  my $upperZ2H = $ejis->trclosure($upperZ, $upperH);
  my $lowerZ2H = $ejis->trclosure($lowerZ, $lowerH);
  my $alphaZ2H = $ejis->trclosure($alphaZ, $alphaH);
  my $alnumZ2H = $ejis->trclosure($alnumZ, $alnumH);

  my $digitH2Z = $ejis->trclosure($digitH, $digitZ);
  my $upperH2Z = $ejis->trclosure($upperH, $upperZ);
  my $lowerH2Z = $ejis->trclosure($lowerH, $lowerZ);
  my $alphaH2Z = $ejis->trclosure($alphaH, $alphaZ);
  my $alnumH2Z = $ejis->trclosure($alnumH, $alnumZ);

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
  $c = $ejis->strtr(\$a,'a-cd','15-7','R');
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
        $mcnt = $ejis->strtr(\$mstr, $uc[$i], $lc[$j], $mod[$m]);
        ++$NG unless $cstr eq $mstr && $ccnt == $mcnt;
      }
    }
    print ! $NG ? "ok" : "not ok", " ", $m+23, "\n"; 
  }
}

{
  my $printZ2H = $ejis->trclosure(
    '��-����-�ڣ�-��������ܡݡ������������������������ʡˡΡϡС�',
    '0-9A-Za-z /=+\-.,:;?!#$%&@*<>()[]{}',
  );

  my $str = '  This  is   a  TEST =@ ';
  my $zen = '�� T��i�� is�� ��a  �ԣ�ST����@ ';

  my($n, $NG);

# splitchar in scalar context
  $NG = 0;
  for $n (-1..20){
    my $core = @{[ split(//, $str, $n) ]};
    my $mbcs = $ejis->strsplit('',$zen,$n);
    ++$NG unless $core == $mbcs;
  }
  print !$NG ? "ok" : "not ok", " 31\n";

# splitchar in list context
  $NG = 0;
  for $n (-1..20){
    my $core = join ':', split //, $str, $n;
    my $mbcs = join ':', $ejis->strsplit('',$zen,$n);
    ++$NG unless $core eq &$printZ2H($mbcs);
  }
  print !$NG ? "ok" : "not ok", " 32\n";

# split / / in list context
  $NG = 0;
  for $n (-1..5){
    my $core = join ':', split(/ /, $str, $n);
    my $mbcs = join ':', $ejis->strsplit(' ',$str,$n);
    ++$NG unless $core eq &$printZ2H($mbcs);
  }
  print !$NG ? "ok" : "not ok", " 33\n";
}
