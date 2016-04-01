package App::orgsel;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

$SPEC{orgsel} = {
    v => 1.1,
    summary => 'Select Org document elements using CSel (CSS-like) syntax',
    args => {
        expr => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
        file => {
            schema => 'str*',
            pos => 1,
            default => '-',
        },
    },
};
sub orgsel {
    require Data::Csel;
    require Org::Parser;

    my %args = @_;

    # parse first so we can bail early on error without having to read the input
    my $expr = $args{expr};
    Data::CSel::parse_csel($expr)
          or return [400, "Invalid CSel expression '$expr'"];

    my $parser = Org::Parser->new;

    my $doc;
    if ($args{file} eq '-') {
        binmode STDIN, ":utf8";
        $doc = $parser->parse(join "", <>);
    } else {
        local $ENV{PERL_ORG_PARSER_CACHE} = $ENV{PERL_ORG_PARSER_CACHE} // 1;
        $doc = $parser->parse_file($args{file});
    }

    my @matches = Data::CSel::csel($expr);
    [200, "OK", [map {$_->as_string} @matches]];
}

1;
#ABSTRACT:

=head1 SYNOPSIS
