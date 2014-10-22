
BEGIN { $| = 1; print "1..12\n"; }
END {print "not ok 1\n" unless $loaded;}
use String::Multibyte;
$^W = 1;
$loaded = 1;
print "ok 1\n";

$mb = String::Multibyte->new('ShiftJIS',1);

$NG = 0;
for ("�����e�X�g", "abc", "�����", "�߰�=Perl",
	"\001\002\003\000\n", "", " ", '�@') {
    $NG++ unless $mb->islegal($_);
}
print !$NG ? "ok" : "not ok", " 2\n";

for ("�����������\xFF\xFF", "�ǂ��ɂ������ɂ�\x81\x39",
	"\x91\x00", "�����\xFF�ǂ�����") {
    $NG++ unless ! $mb->islegal($_);
}
print !$NG ? "ok" : "not ok", " 3\n";

print $mb->islegal("��", "P", "", "�ݼ� test")
    && ! $mb->islegal("���{","��kanji","\xA0","PERL")
  ? "ok" : "not ok", " 4\n";

print 0 eq $mb->length("")
  &&  3 eq $mb->length("abc")
  &&  4 eq $mb->length("abc\n")
  &&  5 eq $mb->length("�����")
  &&  4 eq $mb->length("�߰�")
  && 12 eq $mb->length("�޷޸޹޺޳�")
  && 10 eq $mb->length("���������Ȃ͂܂���")
  && 14 eq $mb->length("����������\n\n�͂܂���\n\n")
  &&  9 eq $mb->length('AIUEO���{����')
  ? "ok" : "not ok", " 5\n";

print $mb->mkrange("��-��") eq "������������"
   && $mb->mkrange("0-9�O-�X") eq "0123456789�O�P�Q�R�S�T�U�V�W�X"
   && $mb->mkrange('�\-') eq '�\-'
  ? "ok" : "not ok", " 6\n";

$ref = '�����{�������OEUIAoeuia����������';
$str = '����������aiueoAIUEO��������{����';

print $ref eq $mb->strrev($str)
  ? "ok" : "not ok", " 7\n";

print $mb->strspn("XZ\0Z\0Yz", "\0X\0YZ") == 6
   && $mb->strcspn("Perl�͖ʔ����B", "XY\0r") == 2
   && $mb->strspn("+0.12345*12", "+-.0123456789") == 8
   && $mb->strcspn("Perl�͖ʔ����B", "�Ԑ�����") == 6
   && $mb->strspn("", "123") == 0
   && $mb->strcspn("", "123") == 0
   && $mb->strspn("����������", "") == 0
   && $mb->strcspn("����������", "") == 5
   && $mb->strspn("���������", "����������") == 9
   && $mb->strcspn("��ɺ����", "�޷޸޹޺�") == 0
   && $mb->strspn("", "") == 0
   && $mb->strcspn("", "") == 0
 ? "ok" : "not ok", " 8\n";

$str = "�Ȃ�Ƃ�������";
print 3 eq $mb->strtr(\$str,"����������", "�A�C�E�G�I")
    && $str eq "�Ȃ�ƃC�I�E��"
    && $mb->strtr('���������߂ڂ��@�����Ƃ͂�', '��-��', '', 's')
	eq '�������߂ڂ��@���Ƃ�'
    && $mb->strtr("�������Z�q�̎g�������͌��ꂵ��", '��-��', '��', 'cs')
	eq '���́��������́�����'
    ? "ok" : "not ok", " 9\n";

print 1
    && $mb->strtr("90 - 32 = 58", "0-9", "A-J") eq "JA - DC = FI"
    && $mb->strtr("90 - 32 = 58", "0-9", "A-J", "R") eq "JA - 32 = 58"
    ? "ok" : "not ok", " 10\n";

$digit_tr = $mb->trclosure(
    "1234567890-", "���O�l�ܘZ������Z�|");

$frstr1 = "TEL�F0124-45-6789\n";
$tostr1 = "TEL�F�Z���l�|�l�܁|�Z������\n";
$frstr2 = "FAX�F0124-51-5368\n";
$tostr2 = "FAX�F�Z���l�|�܈�|�܎O�Z��\n";

$restr1 = &$digit_tr($frstr1);
$restr2 = &$digit_tr($frstr2);

print $tostr1 eq $restr1 && $tostr2 eq $restr2
    ? "ok" : "not ok", " 11\n";

$str = "\x00\x00\x30\x00\x00\x42\x00\x00\x30\x00\x42\x00";
print $] < 5.004 || 1
    && $mb->index($str, "\x00\x30\x00\x42\x00") == 7
    && $mb->index($str, "\x00\x30\x00\x00\x00") == -1
    && $mb->index($str, "\x00\x00\x30\x00") == 0
    && $mb->index($str, "\x00\x30\x00") == 1
    && $mb->rindex($str, "\x00\x30\x00\x42\x00") == 7
    && $mb->rindex($str, "\x00\x30\x00\x00\x00") == -1
    && $mb->rindex($str, "\x00\x00\x30\x00") == 6
    && $mb->rindex($str, "\x00\x30\x00") == 7
    ? "ok" : "not ok", " 12\n";


1;
__END__
