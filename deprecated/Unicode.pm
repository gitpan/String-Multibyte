package String::Multibyte::Unicode;
#
#  Unicode
#

require 5.006; # maybe 5.007

+{
    charset  => 'Unicode',
    regexp   => '(?s:.)',
    nextchar => sub { pack 'U', 1 + unpack('U', $_[0]) },
    cmpchar  => sub { $_[0] cmp $_[1] },
};
