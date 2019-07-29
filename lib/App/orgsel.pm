package App::orgsel;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use App::CSelUtils;

our %SPEC;

$SPEC{orgsel} = {
    v => 1.1,
    summary => 'Select Org document elements using CSel (CSS-selector-like) syntax',
    args => {
        %App::CSelUtils::foosel_args_common,
    },
};
sub orgsel {
     App::CSelUtils::foosel(
        @_,

        code_read_tree => sub {
            require Org::Parser;
            my $args = shift;

            my $parser = Org::Parser->new;
            my $doc;
            if ($args->{file} eq '-') {
                binmode STDIN, ":utf8";
                $doc = $parser->parse(join "", <>);
            } else {
                local $ENV{PERL_ORG_PARSER_CACHE} = $ENV{PERL_ORG_PARSER_CACHE} // 1;
                $doc = $parser->parse_file($args->{file});
            }
        },

        csel_opts => {class_prefixes=>["Org::Element"]},

        code_transform_node_actions => sub {
            my $args = shift;

            for my $action (@{$args->{node_actions}}) {
                if ($action eq 'dump') {
                    $action = 'dump:as_string';
                }
            }
        },
    );
}

1;
#ABSTRACT:

=head1 SYNOPSIS
