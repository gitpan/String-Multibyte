package String::Multibyte::Bytes;
# bytes

+{
    charset  => 'bytes',
    regexp   => $] >= 5.006 ? '\C' : '[\x00-\xFF]',
    nextchar => $] >= 5.006
      ? sub {
          my $c = unpack('C', shift);
          $c == 0xFF ? undef : pack('C', 1+$c);
        }
      : sub {
          my $c = ord shift;
          $c == 0xFF ? undef : chr(1+$c);
        },
    cmpchar => sub { $_[0] cmp $_[1] },
};
