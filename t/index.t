
BEGIN { $| = 1; print "1..33\n"; }
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
    if ($cs eq 'Unicode' && $] < 5.008) {
	print("ok ", ++$loaded, "\n");
	next;
    }
    my $mb = String::Multibyte->new($cs,1);

    my $a = asc2str($cs, 'a');
    my $s = asc2str($cs, ' a');

    my $NG = 0;
    $NG++ unless $mb->index("", ""    )   eq index("", ""    );
    $NG++ unless $mb->index("", "", -1)   eq index("", "", -1);
    $NG++ unless $mb->index("", "",  0)   eq index("", "",  0);
    $NG++ unless $mb->index("", "",  1)   eq index("", "",  1);
    $NG++ unless $mb->index("", "", 10)   eq index("", "", 10);
    $NG++ unless $mb->index("", $a   )   eq index("", "a"   );
    $NG++ unless $mb->index("", $a, -1)  eq index("", "a", -1);
    $NG++ unless $mb->index("", $a,  0)  eq index("", "a",  0);
    $NG++ unless $mb->index("", $a,  1)  eq index("", "a",  1);
    $NG++ unless $mb->index("", $a, 10)  eq index("", "a", 10);
    $NG++ unless $mb->index($s, ""    ) eq index(" a", ""    );
    $NG++ unless $mb->index($s, "", -1) eq index(" a", "", -1);
    $NG++ unless $mb->index($s, "",  0) eq index(" a", "",  0);
    $NG++ unless $mb->index($s, "",  1) eq index(" a", "",  1);
    $NG++ unless $mb->index($s, "",  2) eq index(" a", "",  2);
    $NG++ unless $mb->index($s, "", 10) eq index(" a", "", 10);
    $NG++ unless $mb->index($s, $a   ) eq index(" a", "a"   );
    $NG++ unless $mb->index($s, $a,-1) eq index(" a", "a",-1);
    $NG++ unless $mb->index($s, $a, 0) eq index(" a", "a", 0);
    $NG++ unless $mb->index($s, $a, 1) eq index(" a", "a", 1);
    $NG++ unless $mb->index($s, $a, 2) eq index(" a", "a", 2);
    $NG++ unless $mb->index($s, $a,10) eq index(" a", "a",10);

    print $NG == 0 ? "ok" : "not ok", " ", ++$loaded, "\n";
}

for $cs (qw/Bytes EUC EUC_JP ShiftJIS UTF8 UTF16BE UTF16LE Unicode/) {
    if ($cs eq 'Unicode' && $] < 5.008) {
	print("ok ", ++$loaded, "\n");
	next;
    }

    my $mb = String::Multibyte->new($cs,1);
    my $a = asc2str($cs, 'a');
    my $s = asc2str($cs, ' a');

    my $NG = 0;
    $NG++ unless $mb->rindex("", ""    )   eq rindex("", "");
    $NG++ unless $mb->rindex("", "", -1)   eq rindex("", "", -1);
    $NG++ unless $mb->rindex("", "",  0)   eq rindex("", "",  0);
    $NG++ unless $mb->rindex("", "",  1)   eq rindex("", "",  1);
    $NG++ unless $mb->rindex("", "", 10)   eq rindex("", "", 10);
    $NG++ unless $mb->rindex("", $a    )  eq rindex("", "a"    );
    $NG++ unless $mb->rindex("", $a, -1)  eq rindex("", "a", -1);
    $NG++ unless $mb->rindex("", $a,  0)  eq rindex("", "a",  0);
    $NG++ unless $mb->rindex("", $a,  1)  eq rindex("", "a",  1);
    $NG++ unless $mb->rindex("", $a, 10)  eq rindex("", "a", 10);
    $NG++ unless $mb->rindex($s, ""    ) eq rindex(" a", ""    );
    $NG++ unless $mb->rindex($s, "", -1) eq rindex(" a", "", -1);
    $NG++ unless $mb->rindex($s, "",  0) eq rindex(" a", "",  0);
    $NG++ unless $mb->rindex($s, "",  1) eq rindex(" a", "",  1);
    $NG++ unless $mb->rindex($s, "",  2) eq rindex(" a", "",  2);
    $NG++ unless $mb->rindex($s, "", 10) eq rindex(" a", "", 10);
    $NG++ unless $mb->rindex($s, $a   ) eq rindex(" a", "a"   );
    $NG++ unless $mb->rindex($s, $a,-1) eq rindex(" a", "a",-1);
    $NG++ unless $mb->rindex($s, $a, 0) eq rindex(" a", "a", 0);
    $NG++ unless $mb->rindex($s, $a, 1) eq rindex(" a", "a", 1);
    $NG++ unless $mb->rindex($s, $a, 2) eq rindex(" a", "a", 2);
    $NG++ unless $mb->rindex($s, $a,10) eq rindex(" a", "a",10);

    print $NG == 0 ? "ok" : "not ok", " ", ++$loaded, "\n";
}

@src_char = (0xff0b, 0xff10, 0xff0e, 0xff11, 0xff12, 0x0033, 0xff11, 0xff14, 0xff12, 0xff15, 0xff11, 0xff12, 0x0036, 0x002d, 0xff0a, 0xff11, 0xff12, 0xff13, 0x0034, 0xff16);

%src = (
    Bytes => '+0.1231425126-*12346',
    EUC => pack('H*', 'a1dca3b0a1a5a3b1a3b233a3b1a3b4a3b2a3b5a3b1a3b2362da1f6a3b1a3b2a3b334a3b6'),
    EUC_JP => pack('H*', 'a1dca3b0a1a5a3b1a3b233a3b1a3b4a3b2a3b5a3b1a3b2362da1f6a3b1a3b2a3b334a3b6'),
    ShiftJIS => pack('H*', '817b824f81448250825133825082538251825482508251362d8196825082518252348255'),
    UTF8 => pack('H*', 'efbc8befbc90efbc8eefbc91efbc9233efbc91efbc94efbc92efbc95efbc91efbc92362defbc8aefbc91efbc92efbc9334efbc96'),
    UTF16BE => pack('n*', @src_char),
    UTF16LE => pack('v*', @src_char),
    Unicode => $] < 5.008 ? '' : pack('U*', @src_char),
);
%sub = (
    Bytes => '12',
    EUC => "\xa3\xb1\xa3\xb2",
    EUC_JP => "\xa3\xb1\xa3\xb2",
    ShiftJIS => "\x82\x50\x82\x51",
    UTF8 => "\xef\xbc\x91\xef\xbc\x92",
    UTF16BE => pack('n*', 0xff11, 0xff12),
    UTF16LE => pack('v*', 0xff11, 0xff12),
    Unicode => $] < 5.008 ? '' : pack('U*', 0xff11, 0xff12),
);

for $cs (qw/Bytes EUC EUC_JP ShiftJIS UTF8 UTF16BE UTF16LE Unicode/) {
    if ($cs eq 'Unicode' && $] < 5.008) {
	print("ok ", ++$loaded, "\n");
	print("ok ", ++$loaded, "\n");
	next;
    }

    my $mb = String::Multibyte->new($cs,1);
    my $str = $src{Bytes};
    my $zen = $src{$cs};
    my $sub = $sub{Bytes};
    my $sbz = $sub{$cs};
    my($pos, $si, $bi, $NG);

    $NG = 0;
    for $pos (-10..18) {
	$si = index($str,$sub,$pos);
	$bi = $mb->index($zen,$sbz,$pos);
	$NG++ if $si != $bi;
    }
    print $NG == 0 ? "ok" : "not ok", " ", ++$loaded, "\n";

    $NG = 0;
    for $pos (-10..16){
	$si = rindex($str,$sub,$pos);
	$bi = $mb->rindex($zen,$sbz,$pos);
	$NG++ if $si != $bi;
    }
    print $NG == 0 ? "ok" : "not ok", " ", ++$loaded, "\n";
}

1;
__END__
