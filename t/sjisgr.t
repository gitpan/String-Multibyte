
BEGIN { $| = 1; print "1..13\n"; }
END {print "not ok 1\n" unless $loaded;}
use String::Multibyte;
$^W = 1;
$loaded = 1;
print "ok 1\n";

$mb = String::Multibyte->new({
	charset => 'sjis_grapheme',
	regexp => '[\xB3\xB6-\xC4]\xDE|[\xCA-\xCE][\xDE\xDF]|' .
	    '[\x00-\x7F\xA1-\xDF]|[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]',
    }, 1);

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
  &&  3 eq $mb->length("�߰�")
  &&  6 eq $mb->length("�޷޸޹޺޳�")
  && 10 eq $mb->length("���������Ȃ͂܂���")
  && 14 eq $mb->length("����������\n\n�͂܂���\n\n")
  &&  9 eq $mb->length('AIUEO���{����')
  ? "ok" : "not ok", " 5\n";

$ref = '�����{�������OEUIAoeuia����������';
$str = '����������aiueoAIUEO��������{����';

print $ref eq $mb->strrev($str)
  ? "ok" : "not ok", " 6\n";

$ref = '�߰ق��g���ı���ϼ��';
$str = '�����޿��Ă��g��ٰ��';

print $ref eq $mb->strrev($str)
  ? "ok" : "not ok", " 7\n";

print $mb->strspn ("XZ\0Z\0Y", "\0X\0YZ") == 6
   && $mb->strcspn("Perl�͖ʔ����B", "XY\0r") == 2
   && $mb->strspn ("+0.12345*12", "+-.0123456789") == 8
   && $mb->strcspn("Perl�͖ʔ����B", "�Ԑ�����") == 6
   && $mb->strspn ("", "123") == 0
   && $mb->strcspn("", "123") == 0
   && $mb->strspn ("����������", "") == 0
   && $mb->strcspn("����������", "") == 5
   && $mb->strspn ("���������", "����������") == 2
   && $mb->strcspn("��ɺ����", "�޷޸޹޺�") == 3
   && $mb->strspn ("���������", "�����") == 0
   && $mb->strcspn("���������", "�����") == 2
   && $mb->strspn ("��ɺ����", "�����") == 1
   && $mb->strcspn("��ɺ����", "�����") == 0
   && $mb->strspn ("", "") == 0
   && $mb->strcspn("", "") == 0
 ? "ok" : "not ok", " 8\n";

$str = "�Ȃ�Ƃ�������";
print 3 eq $mb->strtr(\$str,"����������", "�A�C�E�G�I")
    && $str eq "�Ȃ�ƃC�I�E��"
    ? "ok" : "not ok", " 9\n";

$digit_tr = $mb->trclosure(
    "1234567890-", "���O�l�ܘZ������Z�|");

$frstr1 = "TEL�F0124-45-6789\n";
$tostr1 = "TEL�F�Z���l�|�l�܁|�Z������\n";
$frstr2 = "FAX�F0124-51-5368\n";
$tostr2 = "FAX�F�Z���l�|�܈�|�܎O�Z��\n";

$restr1 = &$digit_tr($frstr1);
$restr2 = &$digit_tr($frstr2);

print $tostr1 eq $restr1 && $tostr2 eq $restr2
    ? "ok" : "not ok", " 10\n";

print $mb->index("", "") == 0
   && $mb->index("", "a") == -1
   && $mb->index(" ", "") == 0
   && $mb->index(" ", "", 1) == 1
   && $mb->index("", " ", 1) == -1
   && $mb->index(" ", "a", -1) == -1
   && $mb->index("\x81\x81\x40\x81\x40", "\x81\x40") == 2
   && $mb->index("�Ĥ���", "���") == 3
   && $mb->index("�Ĥ��", "���") == -1
   && $mb->index("�Ĥ���", "��") == 0
   && $mb->index("��ޤ��", "��") == 3
   && $mb->index("Ŷ�ޤŶ�", "Ŷ�") == 4
   && $mb->index("Ŷ�ޤŶ�", "Ŷ��") == 0
    ? "ok" : "not ok", " 11\n";

print $mb->rindex("", "") == 0
   && $mb->rindex("", "a") == -1
   && $mb->rindex(" ", "") == 1
   && $mb->rindex(" ", "", 1) == 1
   && $mb->rindex("", " ", 1) == -1
   && $mb->rindex(" ", "a", -1) == -1
   && $mb->rindex("\x81\x81\x40\x81\x40", "\x81\x40") == 2
   && $mb->rindex("�Ĥ���", "���") == 3
   && $mb->rindex("�Ĥ��", "���") == -1
   && $mb->rindex("�Ĥ���", "��") == 0
   && $mb->rindex("��ޤ��", "��") == 3
   && $mb->rindex("Ŷ�ޤŶ�", "Ŷ�") == 4
   && $mb->rindex("Ŷ�ޤŶ�", "Ŷ��") == 0
    ? "ok" : "not ok", " 12\n";

print "�޶޶޶޶�:�޶޶޶�:�޶޶�" eq
	join(':', $mb->strsplit("�", "�޶޶޶޶޶�޶޶޶޶�޶޶�"))
   && "�޶޶޶޶޶�޶޶޶޶�޶޶�" eq
	join(':', $mb->strsplit("�", "�޶޶޶޶޶�޶޶޶޶�޶޶�", 1))
   && "�޶޶޶޶�:�޶޶޶޶�޶޶�" eq
	join(':', $mb->strsplit("�", "�޶޶޶޶޶�޶޶޶޶�޶޶�", 2))
   && "�޶޶޶޶�:�޶޶޶�:�޶޶�" eq
	join(':', $mb->strsplit("�", "�޶޶޶޶޶�޶޶޶޶�޶޶�", 3))
   && "�޶޶�:�޶�:�޶޶�" eq
	join(':', $mb->strsplit("�޶޶", "�޶޶޶޶޶�޶޶޶޶�޶޶�"))
   && "�޶޶�::��:�޶�" eq
	join(':', $mb->strsplit("�޶޶", "�޶޶޶޶޶�޶޶�޶޶޶�޶�"))
   && "�޶�:�޶޶:�޶�" eq
	join(':', $mb->strsplit("�޶޶޶", "�޶޶޶޶޶�޶޶�޶޶޶�޶�"))
    ? "ok" : "not ok", " 13\n";

1;
__END__

