# Movable Type (r) (C) 2001-2017 Six Apart, Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package MT::ArchiveType::ContentTypeYearly;

use strict;
use base qw( MT::ArchiveType::ContentTypeDate MT::ArchiveType::Yearly );

use MT::Util qw( start_end_year );

sub name {
    return 'ContentTypeYearly';
}

sub archive_label {
    return MT->translate("CONTENTTYPE-YEARLY_ADV");
}

sub default_archive_templates {
    return [
        {   label           => MT->translate('yyyy/index.html'),
            template        => '%y/%i',
            default         => 1,
            required_fields => { date_and_time => 1 }
        }
    ];
}

sub archive_group_iter {
    my $obj = shift;
    my ( $ctx, $args ) = @_;
    my $blog = $ctx->stash('blog');
    my $iter;
    my $sort_order
        = ( $args->{sort_order} || '' ) eq 'ascend' ? 'ascend' : 'descend';
    my $order = ( $sort_order eq 'ascend' ) ? 'asc' : 'desc';

    my $map = $ctx->stash('template_map');
    my $dt_field_id = defined $map && $map ? $map->dt_field_id : '';
    require MT::ContentData;
    require MT::ContentFieldIndex;
    $iter = MT::ContentData->count_group_by(
        {   blog_id => $blog->id,
            status  => MT::Entry::RELEASE()
        },
        {   group => ["extract(year from cf_idx_value_datetime) AS year"],
            $args->{lastn} ? ( limit => $args->{lastn} ) : (),
            sort => [
                {   column => "extract(year from cf_idx_value_datetime)",
                    desc   => $order
                }
            ],
            join => MT::ContentFieldIndex->join_on(
                'content_data_id',
                { content_field_id => $dt_field_id },
            ),
        }
    ) or return $ctx->error("Couldn't get yearly archive list");

    return sub {
        while ( my @row = $iter->() ) {
            my $date = sprintf( "%04d%02d%02d000000", $row[1], 1, 1 );
            my ( $start, $end ) = start_end_year($date);
            return ( $row[0], year => $row[1], start => $start, end => $end );
        }
        undef;
    };
}

sub archive_group_contents {
    my $obj = shift;
    my ( $ctx, %param ) = @_;
    my $ts
        = $param{year}
        ? sprintf( "%04d%02d%02d000000", $param{year}, 1, 1 )
        : undef;
    my $limit = $param{limit};
    $obj->dated_group_contents( $ctx, 'Yearly', $ts, $limit );
}

*date_range    = \&MT::ArchiveType::Yearly::date_range;
*archive_file  = \&MT::ArchiveType::Yearly::archive_file;
*archive_title = \&MT::ArchiveType::Yearly::archive_title;

1;
