<list-table>
  <thead data-is="list-table-header"></thead>
  <tbody if={ store.isLoading }>
    <tr>
      <td colspan={ store.columns.length + 1 }>
        { trans('Loading...') }
      </td>
    </tr>
  </tbody>
  <tbody data-is="list-table-body" if={ !store.isLoading && store.objects }>
  </tbody>

  <script>
    this.mixin('listTop')
  </script>
</list-table>

<list-table-header>
  <tr>
    <th>
      <input type="checkbox"
        checked={ store.checkedAllRowsOnPage }
        onchange={ toggleAllRowsOnPage } />
    </th>
    <th each={ store.columns }
      if={ checked }
      data-id={ id }
      class={
        primary: primary,
        sortable: sortable,
        sorted: parent.store.sortBy == id
      }
    >
      <a href="javascript:void(0)"
        if={ sortable }
        onclick={ toggleSortColumn }
      >
        { label }
      </a>
      <virtual if={ !sortable }>{ label }</virtual>
      <span class="caret caret-reverse"
        if={ sortable && (
          parent.store.sortBy != id
          || parent.store.sortOrder == 'ascend'
        ) }>
      </span>
      <span class="caret"
        if={ sortable && (
          parent.store.sortBy != id
          || parent.store.sortOrder == 'descend'
        ) }>
      </span>
    </th>
  </tr>

  <script>
    this.mixin('listTop')

    toggleAllRowsOnPage(e) {
      this.store.trigger('toggle_all_rows_on_page')
    }

    toggleSortColumn(e) {
      const columnId = e.currentTarget.parentElement.dataset.id
      this.store.trigger('toggle_sort_column', columnId)
    }
  </script>
</list-table-header>

<list-table-body>
  <tr if={ store.objects.length == 0 }>
    <td colspan={ store.columns.length + 1 }>
      { trans('No [_1] could be found.', listTop.opts.zeroStateLabel) }
    </td>
  </tr>
  <tr style="background-color: #ffffff;"
    if={ store.pageMax > 1 && store.checkedAllRowsOnPage && !store.checkedAllRows }
  >
    <td colspan={ store.objects.length + 1 }>
      <a href="javascript:void(0);" onclick={ checkAllRows }>
        { trans('Select all [_1] items', store.count) }
      </a>
    </td>
  </tr>
  <tr class="success" if={ store.pageMax > 1 && store.checkedAllRows }>
    <td colspan={ store.objects.length + 1 }>
      { trans('All [_1] items are selected', store.count) }
    </td>
  </tr>
  <tr data-is="list-table-row"
    each={ obj, index in store.objects }
    onclick={ parent.toggleRow }
    class={ obj.checked ? 'warning' : '' }
    data-index={ index }
    checked={ obj.checked }
    object={ obj.object }
  >
  </tr>

  <script>
    this.mixin('listTop')

    toggleRow(e) {
      if (e.target.tagName == 'A') {
        return false
      }
      this.store.trigger('toggle_row', e.currentTarget.dataset.index)
    }

    checkAllRows(e) {
      this.store.trigger('check_all_rows')
    }
  </script>
</list-table-body>

<list-table-row>
  <td>
    <input type="checkbox"
      name="id"
      value={ opts.object[0] }
      checked={ opts.checked }>
  </td>
  <td data-is="list-table-column"
    each={ content, index in opts.object }
    if={ index > 0 }
    class={ (parent.store.columns[0].id == 'id' && !parent.store.columns[0].checked)
      ? parent.store.columns[index+1].id
      : parent.store.columns[index].id
    }
    content={ content }>
  </td>

  <script>
    this.mixin('listTop')
  </script>
</list-table-row>

<list-table-column>
  <virtual></virtual>

  <script>
    this.root.innerHTML = opts.content
  </script>
</list-table-column>