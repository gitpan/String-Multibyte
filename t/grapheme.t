
BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
use String::Multibyte;
$^W = 1;
$loaded = 1;
print "ok 1\n";

$dgc = $] < 5.008 ? undef : String::Multibyte->new('Grapheme');

print ! $dgc ||
    pack('U*', 0x300, 0, 0x0D, 0x41, 0x300, 0x301, 0x3042,
	0xD, 0xA, 0xAC00, 0x11A8) eq $dgc->strrev(
    pack('U*', 0xAC00, 0x11A8, 0xD, 0xA, 0x3042, 0x41, 0x300,
	0x301, 0xD, 0, 0x300))
    ? "ok" : "not ok", " 2\n";

print ! $dgc ||
    7 == $dgc->length(pack('U*', 0xAC00, 0x11A8, 0xD, 0xA, 0x3042,
	0x41, 0x300, 0x301, 0xD, 0, 0x300))
    ? "ok" : "not ok", " 3\n";

1;
__END__
