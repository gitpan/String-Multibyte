package String::Multibyte::Bytes;
# bytes

+{
    charset  => 'bytes',
    regexp   => $] >= 5.006 ? '\C' : '[\x00-\xFF]',
    nextchar =>
        sub {
          my $c = unpack('C', shift);
          $c == 0xFF ? undef : pack('C', 1+$c);
        },
    cmpchar => sub { $_[0] cmp $_[1] },
};
