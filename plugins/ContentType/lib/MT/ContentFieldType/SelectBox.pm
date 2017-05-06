package MT::ContentFieldType::SelectBox;
use strict;
use warnings;

use MT;
use MT::ContentField;
use MT::ContentFieldType::Common qw( get_cd_ids_by_inner_join );

sub terms {
    my $prop = shift;
    my ( $args, $base_terms, $base_args, $opts ) = @_;

    my $val       = $args->{value};
    my $data_type = $prop->{data_type};

    my $join_terms = { "value_${data_type}" => $val };
    my $cd_ids = get_cd_ids_by_inner_join( $prop, $join_terms, undef, @_ );

    if ( $args->{option} && $args->{option} eq 'is_not_selected' ) {
        $cd_ids ? { id => { not => $cd_ids } } : ();
    }
    else {
        { id => $cd_ids };
    }
}

sub filter_tmpl {
    return <<'__TMPL__';
<mt:setvarblock name="select_options">
<select class="<mt:var name="type">-option">
  <option value="is_selected"><__trans phrase="is selected" escape="js"></option>
  <option value="is_not_selected"><__trans phrase="is not selected" escape="js"></option>
</select>
</mt:setvarblock>
<__trans phrase="In [_1] column, [_2] [_3]"
         params="<mt:var name="label" escape="js">%%
                 <select class="<mt:var name="type">-value">
                 <mt:loop name="single_select_options">
                   <option value="<mt:var name="value">"><mt:var name="label" encode_html="1" encode_js="1" encode_html="1" ></option>
                 </mt:loop>
                 </select>%%<mt:var name="select_options">">
__TMPL__
}

sub field_html {
    my ( $app, $id, $value ) = @_;
    $value = '' unless defined $value;

    my %values;
    if ( ref $value eq 'ARRAY' ) {
        %values = map { $_ => 1 } @$value;
    }
    else {
        $values{$value} = 1;
    }

    my $content_field = MT::ContentField->load($id);

    my $options = $content_field->options->{options} || '';
    my $options_delimiter
        = quotemeta(
        $app->registry('content_field_types')->{select_box}{options_delimiter}
            || ',' );
    my @options = split $options_delimiter, $options;

    my $html
        = '<select name="content-field-'
        . $id
        . '" id="content-field-'
        . $id
        . '" class="select"';
    $html .= ' multiple style="min-width: 5em; min-height: 5em;"'
        if $content_field->options->{multiple};
    $html .= '>';

    foreach my $option (@options) {
        $html .= '<option value="' . $option . '"';
        $html .= ' selected="selected"'
            if $values{$option};
        $html .= '>' . $option . '</option>';
    }
    $html .= '</select>';

    return $html;
}

sub single_select_options {
    my $prop = shift;
    my $app = shift || MT->app;

    my $content_field_id = $prop->{content_field_id};
    my $content_field    = MT::ContentField->load($content_field_id);
    my $options_delimiter
        = quotemeta(
        $app->registry('content_field_types')->{select_box}{options_delimiter}
            || ',' );
    my @options = split $options_delimiter,
        $content_field->options->{options} || '';

    [ map { +{ label => $_, value => $_ } } @options ];
}

sub data_getter {
    my ( $app, $id ) = @_;
    my @options       = $app->param("content-field-${id}");
    my $content_field = MT::ContentField->load($id);

    if ( $content_field->options->{multiple} ) {
        \@options;
    }
    else {
        @options ? $options[0] : undef;
    }
}

1;
