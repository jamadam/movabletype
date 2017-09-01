# Movable Type (r) (C) 2001-2017 Six Apart, Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#

package MT::Test::Tag;

use strict;
use warnings;
use MT::Test 'has_php';
use Test::Base -Base;
use IPC::Run3 'run3';

sub run_perl_tests {
    my ( $blog_id, $callback ) = @_;

    run {
        my $block = shift;
    SKIP: {
            skip $block->skip, 1 if $block->skip;

            my $tmpl = MT::Template->new;
            $tmpl->text( $block->template );
            my $ctx = $tmpl->context;

            my $blog = MT::Blog->load( $block->blog_id || $blog_id );
            $ctx->stash( 'blog',          $blog );
            $ctx->stash( 'blog_id',       $blog->id );
            $ctx->stash( 'local_blog_id', $blog->id );
            $ctx->stash( 'builder',       MT::Builder->new );

            $callback->( $ctx, $block ) if $callback;

            my $result = eval { $tmpl->build };
            if ( !$block->expected_error ) {
                $result =~ s/^(\r\n|\r|\n|\s)+|(\r\n|\r|\n|\s)+\z//g
                    if defined $result;
                is( $result, $block->expected, $block->name );
            }
            else {
                $result = $ctx->errstr;
                $result =~ s/^(\r\n|\r|\n|\s)+|(\r\n|\r|\n|\s)+\z//g;
                is( $result, $block->expected_error,
                    $block->name . ' (error)' );
            }
        }
    }
}

sub run_php_tests {
    my ( $blog_id, $callback ) = @_;

SKIP: {
        unless ( has_php() ) {
            skip "Can't find executable file: php", 1 * blocks;
        }

        run {
            my $block = shift;
        SKIP: {
                skip $block->skip, 1 if $block->skip;

                my $template = $block->template;
                my $text     = $block->text || '';
                my $extra    = $callback ? $callback->($block) : '';

                my $php_script = php_test_script( $block->blog_id || $blog_id,
                    $template, $text, $extra );

                run3 [ 'php', '-q' ], \$php_script, \my $php_result, undef,
                    { binmode_stdin => 1 }
                    or die $?;

                $php_result =~ s/^(\r\n|\r|\n|\s)+|(\r\n|\r|\n|\s)+\z//g;

                my $expected = $block->expected;
                $expected =~ s/\\r/\\n/g;
                $expected =~ s/\r/\n/g;

                my $name = $block->name . ' - dynamic';
                is( $php_result, $expected, $name );
            }
        }
    }
}

sub MT::Test::Tag::php_test_script {    # full qualified to avoid Spiffy magic
    my ( $blog_id, $template, $text, $extra ) = @_;
    $text ||= '';

    my $test_script = <<PHP;
<?php
\$MT_HOME   = '@{[ $ENV{MT_HOME} ? $ENV{MT_HOME} : '.' ]}';
\$MT_CONFIG = '@{[ MT->instance->find_config ]}';
\$blog_id   = '$blog_id';
\$tmpl = <<<__TMPL__
$template
__TMPL__
;
\$text = <<<__TMPL__
$text
__TMPL__
;
PHP
    $test_script .= <<'PHP';
include_once($MT_HOME . '/php/mt.php');
include_once($MT_HOME . '/php/lib/MTUtil.php');

$mt = MT::get_instance(1, $MT_CONFIG);
$mt->init_plugins();

$db = $mt->db();
$ctx =& $mt->context();

$ctx->stash('blog_id', $blog_id);
$ctx->stash('local_blog_id', $blog_id);
PHP

    $test_script .= $extra if $extra;

    $test_script .= <<'PHP';
$blog = $db->fetch_blog($blog_id);
$ctx->stash('blog', $blog);

if ($ctx->_compile_source('evaluated template', $tmpl, $_var_compiled)) {
    $ctx->_eval('?>' . $_var_compiled);
} else {
    print('Error compiling template module.');
}

?>
PHP
}

1;
