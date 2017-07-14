# Movable Type (r) (C) 2001-2017 Six Apart, Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package MT::ArchiveType::ContentTypeCategoryDaily;

use strict;
use base
    qw( MT::ArchiveType::CategoryDaily MT::ArchiveType::ContentTypeCategory MT::ArchiveType::ContentTypeDaily );

use MT::Util qw( remove_html encode_html );

sub name {
    return 'ContentType-Category-Daily';
}

sub archive_label {
    return MT->translate("CONTENTTYPE-CATEGORY-DAILY_ADV");
}

sub template_params {
    return { archive_class => "contenttype-category-daily-archive" };
}

sub archive_file {
    my $obj = shift;
    my ( $ctx, %param ) = @_;
}

sub archive_title {
}

1;

