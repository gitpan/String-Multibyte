package String::Multibyte::Bytes;
# bytes

+{
    charset  => 'bytes',
    regexp   => '[\x00-\xFF]',
    nextchar => sub {
		  my $c = ord shift;
		  $c == 0xFF ? undef : chr(1+$c);
		},
    cmpchar => sub { $_[0] cmp $_[1] },
};
