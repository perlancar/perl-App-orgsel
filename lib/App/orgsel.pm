package App::orgsel;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use App::CSelUtils;
use Scalar::Util qw(refaddr);

our %SPEC;

$SPEC{orgsel} = {
    v => 1.1,
    summary => 'Select Org document elements using CSel (CSS-selector-like) syntax',
    args => {
        %App::CSelUtils::foosel_common_args,
        %App::CSelUtils::foosel_tree_action_args,
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
    @matches = grep { refaddr($_) ne refaddr($doc) } @matches
        unless @matches <= 1;

    App::CSelUtils::do_actions_on_nodes(
        nodes   => \@matches,
        actions => $args{actions},
    );
}

1;
#ABSTRACT:

=head1 SYNOPSIS
