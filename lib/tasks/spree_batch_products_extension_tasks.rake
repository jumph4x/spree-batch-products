namespace :spree_batch_products do
  task :create_backup, [:fields_for_backup, :filename] => :environment do |task, args|
    require 'csv'

    filename = if args[:filename].present?
      args[:filename]
    else
      "pricing-backup-#{Time.now.strftime('%m-%d-%Y')}.csv"
    end

    puts "\n" * 2
    puts "Preparing to dump #{filename} into #{Rails.root}"
    puts "\n" *2

    cr = "\r" # move cursor to beginning of line
    clear = "\e[0K"
    reset = cr + clear# reset lines

    counter = 0
    total = Spree::Product.for_backup.count

    puts "#{total} products total are about to be processed."
    total = total/100.0

    headings = if args[:fields_for_backup].present?
      args[:fields_for_backup].split('/')
    else
      Spree::Product::FIELDS_FOR_BACKUP
    end

    CSV.open("#{Rails.root}/#{filename}", "w") do |csv|
      csv << headings

      Spree::Product.for_backup.find_in_batches(:batch_size => 50) do |products|

        products.each do |product|
          counter += 1

          values = headings.map do |attr|
            product.send(attr).to_s
          end

          csv << values

          percentage = (counter/total).round(2)
          print "#{reset}#{percentage}%"
          $stdout.flush
          sleep 0 # yield to OS and other processes, important for production
        end
      end
    end

    puts "\n" * 2
    puts "And done."
  end
end
