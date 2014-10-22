
BEGIN { $| = 1; print "1..11\n"; }
END {print "not ok 1\n" unless $loaded;}
use String::Multibyte;
$^W = 1;
$loaded = 1;
print "ok 1\n";

$mb = String::Multibyte->new('ShiftJIS',1);

#####

my $L82 = '(?:\x82[\x40-\xfc])';
my $L83 = '(?:\x83[\x40-\xfc])';

"�`�a�b�A�C�E�G�I" =~ /($L82+)($L83+)/;

print "�`�a�b" eq $1 && "�A�C�E�G�I" eq $2
  ? "ok" : "not ok", " 2\n";

print $mb->length($1) == 3
   && $mb->length($2) == 5
  ? "ok" : "not ok", " 3\n";

print $mb->strrev($1) eq "�b�a�`"
   && $mb->strrev($2) eq "�I�G�E�C�A"
  ? "ok" : "not ok", " 4\n";

print "�a�b" eq $mb->substr($1,1,2)
   && "�E�G�I" eq $mb->substr($2,-3)
  ? "ok" : "not ok", " 5\n";

print "ABC" eq $mb->strtr($1,'�`-�y','A-Z')
   && "�A�C�E�G�I" eq $mb->strtr($2,'�`-�y','A-Z')
  ? "ok" : "not ok", " 6\n";

print "�`�a�b" eq $mb->strtr($1,'�A-��','��-��')
   && "����������" eq $mb->strtr($2,'�A-��','��-��')
  ? "ok" : "not ok", " 7\n";

print "�`�a�b" eq $1 && "�A�C�E�G�I" eq $2
  ? "ok" : "not ok", " 8\n";

my $str = "�`�a�b�A�C�E�G�I�������w�x�y�n�q�t�w�z";

$str =~ s/($L82+)($L83+)/
    $mb->strtr($1,'�`-�y','A-Z') . $mb->strtr($2,'�A-��','��-��')
/ge;

print $str eq "ABC����������������XYZ�͂Ђӂւ�"
  ? "ok" : "not ok", " 9\n";

$str =~ s/($L82+)/$mb->strrev($mb->substr($1,1,3))/ge;

print $str eq "ABC������������XYZ�ւӂ�"
  ? "ok" : "not ok", " 10\n";

$str =~ s/($L82+)/$mb->length($1)/ge;

print $str eq "ABC3������XYZ3"
  ? "ok" : "not ok", " 11\n";

1;
__END__
