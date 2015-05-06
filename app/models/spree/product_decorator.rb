Spree::Product.class_eval do
  scope :for_backup, -> {
    preload(:master => :prices).
    where("#{quoted_table_name}.available_on <= ?", Time.now)
  }
  FIELDS_FOR_BACKUP = ['sku', 'name', 'price', 'weight', 'description', 'slug']
end
