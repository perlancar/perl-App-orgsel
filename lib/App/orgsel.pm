package App::orgsel;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Scalar::Util qw(refaddr);

our %SPEC;

$SPEC{orgsel} = {
    v => 1.1,
    summary => 'Select Org document elements using CSel (CSS-selector-like) syntax',
    args => {
        expr => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
        file => {
            schema => 'str*',
            'x.schema.entity' => 'filename',
            pos => 1,
            default => '-',
        },
        match_action => {
            schema => 'str*',
            default => 'print-as-string',
            cmdline_aliases => {
                count => { is_flag => 1, code => sub { $_[0]{match_action} = 'count' } },
                # dump
            },
        },
    },
};
sub orgsel {
    my %args = @_;

    # parse first so we can bail early on error without having to read the input
    require Data::CSel;
    my $expr = $args{expr};
    Data::CSel::parse_csel($expr)
          or return [400, "Invalid CSel expression '$expr'"];

    require Org::Parser;
    my $parser = Org::Parser->new;

    my $doc;
    if ($args{file} eq '-') {
        binmode STDIN, ":utf8";
        $doc = $parser->parse(join "", <>);
    } else {
        local $ENV{PERL_ORG_PARSER_CACHE} = $ENV{PERL_ORG_PARSER_CACHE} // 1;
        $doc = $parser->parse_file($args{file});
    }

    my @matches = Data::CSel::csel(
        {class_prefixes=>["Org::Element"]}, $expr, $doc);

    # skip root node itself
    @matches = grep { refaddr($_) ne refaddr($doc) } @matches;

    if ($args{match_action} eq 'count') {
        [200, "OK", ~~@matches];
    } else {
        [200, "OK", [map {$_->as_string} @matches]];
    }
}

1;
#ABSTRACT:

=head1 SYNOPSIS
