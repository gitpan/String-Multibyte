
BEGIN { $| = 1; print "1..10\n"; }
END {print "not ok 1\n" unless $loaded;}
use String::Multibyte;
$^W = 1;
$loaded = 1;
print "ok 1\n";

sub asc2str ($$) {
   my($cs, $str) = @_;
   $str =~ s/([\x00-\xFF])/\x00$1/g if $cs eq 'UTF16BE';
   $str =~ s/([\x00-\xFF])/$1\x00/g if $cs eq 'UTF16LE';
   return $str;
}
sub str2asc ($$) {
   my($cs, $str) = @_;
   $str =~ s/\x00([\x00-\xFF])/$1/g if $cs eq 'UTF16BE';
   $str =~ s/([\x00-\xFF])\x00/$1/g if $cs eq 'UTF16LE';
   return $str;
}

#####

for $cs (qw/Bytes EUC EUC_JP ShiftJIS UTF8 UTF16BE UTF16LE Unicode/) {
    print("ok ", ++$loaded, "\n"), next
	if $cs eq 'Unicode' && $] < 5.008;
    $mb = String::Multibyte->new($cs,1);

    $str = asc2str($cs, "hotchpotch");
    $ran = asc2str($cs, "a-z");

    %h = $mb->strtr($str, $ran, '', 'h');

    print "c-2;h-3;o-2;p-1;t-2;" eq join('', map {
	my $s = str2asc($cs, $_); "$s-$h{$_};"
    } sort keys %h) ? "ok" : "not ok", " ", ++$loaded, "\n";
}

# see perlfaq6
$martian  = String::Multibyte->new({
	charset => "martian",
	regexp => '[A-Z][A-Z]|[^A-Z]',
    },1);

%hash = $martian->strtr("PElafSVfdQEdFGcRAaa", "FGaQA", '', 'h');

print 2 == keys %hash
  && $hash{FG} == 1
  && $hash{a} == 3
  ? "ok" : "not ok", " 10\n";

1;
__END__

