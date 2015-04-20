Deface::Override.new(
  :virtual_path => "spree/admin/shared/sub_menu/_product",
  :name => "batch_products_admin_product_sub_tabs",
  :insert_bottom => "[data-hook='admin_product_sub_tabs'], #admin_product_sub_tabs[data-hook]",
  :text => "<%= tab(:product_datasheets, :label => :batch_updates) %>",
  :disabled => false
)
