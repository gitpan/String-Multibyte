
BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}
use String::Multibyte;
$^W = 1;
$loaded = 1;
print "ok 1\n";

#####

$bytes = String::Multibyte->new('Bytes',1);

$NG = 0;

for ("漢字テスト", "abc", "ｱｲｳｴｵ", "ﾊﾟｰﾙ=Perl", "\001\002\003\000\n",
	"", " ", '　', "それもそうだ\xFF\xFF",
	"どうにもこうにも\x81\x39", "\x91\x00", "これは\xFFどうかな") {
    $NG++ unless $bytes->islegal($_);
}

print ! $NG
   && $bytes->islegal("あ", "P", "", "ｶﾝｼﾞ test")
   && $bytes->islegal("日本","さkanji","\xA0","PERL")
	? "ok" : "not ok", " 2\n";

print 0 == $bytes->length("")
  &&  3 == $bytes->length("abc")
  &&  5 == $bytes->length("ｱｲｳｴｵ")
  && 20 == $bytes->length("あかさたなはまやらわ")
  && 13 == $bytes->length('AIUEO日本漢字')
  ? "ok" : "not ok", " 3\n";

print $bytes->mkrange("ぁ-う") eq "う"
   && $bytes->mkrange("ぁ-う", 1)
	eq 'ぁ'.pack('C*', reverse 0x83..0x9E).'う'
   && $bytes->mkrange("0-9０-９")
	eq '0123456789０'.pack('C*', 0x50..0x81).'９'
   && $bytes->mkrange('表-') eq "\x95-"
  ? "ok" : "not ok", " 4\n";

$ref = 'ｵｴｳｲｱOEUIAoeuia';
$str = 'aiueoAIUEOｱｲｳｴｵ';
print $ref eq $bytes->strrev($str)
    ? "ok" : "not ok", " 5\n";

print $bytes->strspn("XZ\0Z\0Y", "\0X\0YZ") == 6
   && $bytes->strcspn("Perl5.6", "0123456789") == 4
   && $bytes->strspn ("+0.12345*12", "+-.0123456789") == 8
   && $bytes->strspn("", "123") == 0
   && $bytes->strcspn("", "123") == 0
   && $bytes->strspn("AIUEO", "") == 0
   && $bytes->strcspn("AIUEO", "") == 5
   && $bytes->strspn("", "") == 0
   && $bytes->strcspn("", "") == 0
 ? "ok" : "not ok", " 6\n";

print $bytes->strtr("90 - 32 = 58", "0-9", "A-J")
	eq "JA - DC = FI"
   && $bytes->strtr("90 - 32 = 58", "0-9", "A-J", "R")
	eq "JA - 32 = 58"
    ? "ok" : "not ok", " 7\n";

$digit_tr = $bytes->trclosure("1234567890-", "ABCDEFGHIJ=");

$frstr1 = "TEL：0124-45-6789\n";
$tostr1 = "TEL：JABD=DE=FGHI\n";
$frstr2 = "FAX：0124-51-5368\n";
$tostr2 = "FAX：JABD=EA=ECFH\n";

$restr1 = &$digit_tr($frstr1);
$restr2 = &$digit_tr($frstr2);

print $tostr1 eq $restr1 && $tostr2 eq $restr2
    ? "ok" : "not ok", " 8\n";

1;
__END__

