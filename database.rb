
require './app'
require './fruit_supplier'

module FruitDatabase

	def load_database
		begin
			@stock = YAML.load_file("stock.yml")
			@info = @stock['fruits']
			@info.keys.each do |item|
				@fruit_hash = @info[item]
				fruit_obj = FruitSupplier.new(item,@fruit_hash)
				add(fruit_obj)
			end
		rescue
			print `clear`
			puts "yaml file has errors or could not be located".cyan
			puts "Do you want to add stock manually?(y or n)".cyan
			input = gets.chomp.downcase
			case input
			when "y"
				print `clear`
				Shop.register_fruit
			when "n"
				puts "Goodbye"
				exit
			end
		end
	end

	def add_info_to_yaml
		File.open("stock.yml", "w") do |file|
			file.write("fruits:\n")
			@list.each do |item|
				file.write("\s#{item.fruit_sources_name.split.map(&:capitalize)*' '}:\n")
				item.fruit_list.each do |item2|
					file.write("\s\s#{item2.fruit_name.downcase}:\n")
					file.write("\s\s\sstock: #{item2.stock}\n")
				end
			end
		end
	end

end
