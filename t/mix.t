# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..5\n"; }
END {print "not ok 1\n" unless $loaded;}

use String::Multibyte;

my $sjis = String::Multibyte->new('ShiftJIS',1);
my $euc  = String::Multibyte->new('EUC',1);
my $utf8 = String::Multibyte->new('UTF8',1);

$^W = 1;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

print $sjis->islegal("\x81\x40\xAD\x40")
   && $euc ->islegal("\xA1\xA1\x20\xBD\xBD")
   && $utf8->islegal("\xC2\xA0\xEF\xBD\xBF\x60")
  ? "ok" : "not ok", " 2\n";

print $sjis->length("\x81\x40\xAD\x40") == 3
   && $euc ->length("\xA1\xA1\x20\xBD\xBD") == 3
   && $utf8->length("\xC2\xA0\xEF\xBD\xBF\x60") == 3
  ? "ok" : "not ok", " 3\n";

print $sjis->substr("\x81\x40\xAD\x40", 1) eq "\xAD\x40"
   && $euc ->substr("\xA1\xA1\x20\xBD\xBD",2) eq "\xBD\xBD"
   && $utf8->substr("\xC2\xA0\xEF\xBD\xBF\x60",1,1) eq "\xEF\xBD\xBF"
  ? "ok" : "not ok", " 4\n";

print $sjis->strrev("\x81\x40\xAD\x40") eq "\x40\xAD\x81\x40"
   && $euc ->strrev("\xBD\xBE\x20\xA1\xA1") eq "\xA1\xA1\x20\xBD\xBE"
   && $utf8->strrev("\xC2\xA0\xEF\xBD\xBF\x60") eq "\x60\xEF\xBD\xBF\xC2\xA0"
  ? "ok" : "not ok", " 5\n";

