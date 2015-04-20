require 'spree_core'
require 'spree_backend'
require 'spree_batch_products/engine'
require 'roo'

# To support roo versions before 1.12.0
unless defined?(Roo::CSV)
  class Roo::CSV < Roo::Csv
  end
end