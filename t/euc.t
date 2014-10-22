
BEGIN { $| = 1; print "1..11\n"; }
END {print "not ok 1\n" unless $loaded;}

use String::Multibyte;
$^W = 1;
$loaded = 1;
print "ok 1\n";

#####

$mb = String::Multibyte->new('EUC',1);

$NG = 0;
for ("�����ƥ���", "abc", "\001\002\003\000\n", "", " ", '��') {
    $NG++ unless $mb->islegal($_);
}
print !$NG ? "ok" : "not ok", " 2\n";

$NG = 0;
for ("����⤽����\xFF\xFF", "�ɤ��ˤ⤳���ˤ�\x81\x39", "\xA1\x21",
    "����������", "�ʎߎ���=Perl", "\x91\x00", "�����\xFF�ɤ�����") {
    $NG++ unless ! $mb->islegal($_);
}
print !$NG ? "ok" : "not ok", " 3\n";

print $mb->islegal("��", "P", "", "����test")
  && ! $mb->islegal("����","��kanji","\xA0","PERL")
    ? "ok" : "not ok", " 4\n";

print 0 eq $mb->length("")
  &&  3 eq $mb->length("abc")
  &&  4 eq $mb->length("abc\n")
  &&  5 eq $mb->length("����������")
  && 10 eq $mb->length("���������ʤϤޤ���")
  && 14 eq $mb->length("����������\n\n�Ϥޤ���\n\n")
  &&  9 eq $mb->length('AIUEO���ܴ���')
  ? "ok" : "not ok", " 5\n";

print $mb->mkrange("��-��") eq "������������"
  &&  $mb->mkrange("0-9��-��") eq "0123456789��������������������"
  &&  $mb->mkrange('ɽ-') eq 'ɽ-'
    ? "ok" : "not ok", " 6\n";

$ref = '�������� OEUIAoeuia����������';
$str = '����������aiueoAIUEO ���ܴ���';

print $ref eq $mb->strrev($str)
    ? "ok" : "not ok", " 7\n";

print $mb->strspn("XZ\0Z\0Y", "\0X\0YZ") == 6
   && $mb->strcspn("Perl�����򤤡�", "XY\0r") == 2
   && $mb->strspn("+0.12345*12", "+-.0123456789") == 8
   && $mb->strcspn("Perl�����򤤡�", "���Ĳ����") == 6
   && $mb->strspn("", "123") == 0
   && $mb->strcspn("", "123") == 0
   && $mb->strspn("����������", "") == 0
   && $mb->strcspn("����������", "") == 5
   && $mb->strspn("", "") == 0
   && $mb->strcspn("", "") == 0
 ? "ok" : "not ok", " 8\n";

$str = "�ʤ�Ȥ�������";
print $mb->strtr(\$str,"����������", "����������") == 3
    && $str eq "�ʤ�ȥ�������"
  ? "ok" : "not ok", " 9\n";

print $mb->strtr('����������ܤ��������ȤϤ�', '��-��', '', 's')
	eq '��������ܤ������Ȥ�'
   && $mb->strtr("���黻�ҤλȤ������ϸ��줷��", '��-��', '��', 'cs')
	eq '���Ρ��������ϡ�����'
   && $mb->strtr("90 - 32 = 58", "0-9", "A-J") eq "JA - DC = FI"
   && $mb->strtr("90 - 32 = 58", "0-9", "A-J", "R") eq "JA - 32 = 58"
    ? "ok" : "not ok", " 10\n";

$digit_tr = $mb->trclosure("1234567890-", "���󻰻͸�ϻ��Ȭ�塻��");

$frstr1 = "TEL��0124-45-6789\n";
$tostr1 = "TEL��������͡ݻ͸ޡ�ϻ��Ȭ��\n";
$frstr2 = "FAX��0124-51-5368\n";
$tostr2 = "FAX��������͡ݸް�ݸ޻�ϻȬ\n";

$restr1 = &$digit_tr($frstr1);
$restr2 = &$digit_tr($frstr2);

print $tostr1 eq $restr1 && $tostr2 eq $restr2
    ? "ok" : "not ok", " 11\n";

1;
__END__
