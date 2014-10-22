
BEGIN { $| = 1; print "1..14\n"; }
END {print "not ok 1\n" unless $loaded;}
use String::Multibyte;
$^W = 1;
$loaded = 1;
print "ok 1\n";

$mb = String::Multibyte->new('ShiftJIS',1);

#####

%hash = $mb->strtr(
    '����������@���͂ɂ��݂���@���݂̂���',
    "��-����-��", "", "h");
$join = join ':', map "$_=>$hash{$_}", sort keys %hash;

print $join eq '��=>2:��=>1:��=>1:��=>1:��=>1:��=>1'
    ? "ok" : "not ok", " 2\n";

$hash = $mb->strtr(
    '����������@���͂ɂ��݂���@���݂̂���',
    "��-����-��", "", "h");
$join = join ':', map "$_=>$$hash{$_}", sort keys %$hash;

print $join eq '��=>2:��=>1:��=>1:��=>1:��=>1:��=>1'
    ? "ok" : "not ok", " 3\n";

%hash = $mb->strtr('���{��̃J�^�J�i', '��-��@-���-�', '', 'h');
$join = join ':', map "$_=>$hash{$_}", sort keys %hash;

print $join eq '��=>1:�J=>2:�^=>1:�i=>1'
    ? "ok" : "not ok", " 4\n";

$str = '���{��̃J�^�J�i';
%hash = $mb->strtr(\$str, '��-��@-��', '�@-����-��', 'h');
$join = join ':', map "$_=>$hash{$_}", sort keys %hash;

print $join eq '��=>1:�J=>2:�^=>1:�i=>1'
    ? "ok" : "not ok", " 5\n";
print $str eq '���{��m��������'
    ? "ok" : "not ok", " 6\n";

$str = '���{��̃J�^�J�i�̖{';
%hash = $mb->strtr(\$str, '��-��@-��', '', 'cdh');
$join = join ':', map "$_=>$hash{$_}", sort keys %hash;

print $join eq '��=>1:��=>1:�{=>2'
    ? "ok" : "not ok", " 7\n";
print $str eq '�̃J�^�J�i��'
    ? "ok" : "not ok", " 8\n";

$str = '���{��̃J�^�J�i�̖{';
%hash = $mb->strtr(\$str, '��-��@-��', '', 'dh');
$join = join ':', map "$_=>$hash{$_}", sort keys %hash;

print $join eq '��=>2:�J=>2:�^=>1:�i=>1'
    ? "ok" : "not ok", " 9\n";
print $str eq '���{��{'
    ? "ok" : "not ok", " 10\n";

$str = '���{��̃J�^�J�i�̖{';
%hash = $mb->strtr(\$str, '��-��@-��', '', 'ch');
$join = join ':', map "$_=>$hash{$_}", sort keys %hash;

print $join eq '��=>1:��=>1:�{=>2'
    ? "ok" : "not ok", " 11\n";
print $str eq '���{��̃J�^�J�i�̖{'
    ? "ok" : "not ok", " 12\n";

$str = '�{���̓��{��̃J�^�J�i�̖{';
%hash = $mb->strtr(\$str, '��-��@-��', '!', 'ch');
$join = join ':', map "$_=>$hash{$_}", sort keys %hash;

print $join eq '��=>1:��=>1:��=>1:�{=>3'
    ? "ok" : "not ok", " 13\n";
print $str eq '!!��!!!�̃J�^�J�i��!'
    ? "ok" : "not ok", " 14\n";

1;
__END__
