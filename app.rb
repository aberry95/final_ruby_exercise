require 'yaml'
require 'io/console'
require 'colorize'
require 'date'
require './fruit'
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
			@date = @stock['Date']
		rescue
			print `clear`
			puts "database has errors or could not be located".cyan
			puts "Do you want to add stock manually?(y or n)".cyan
			input = gets.chomp.downcase
			case input
			when "y"
				print `clear`
				register_fruit
			when "n"
				puts "Goodbye"
				exit
			end
		end
	end

	def add_info_to_database
		File.open("stock.yml", "w") do |file|
			file.write("fruits:\n")
			@list.each do |item|
				file.write("\s#{item.fruit_sources_name.split.map(&:capitalize)*' '}:\n")
				item.fruit_list.each do |item2|
					file.write("\s\s#{item2.fruit_name.downcase}:\n")
					file.write("\s\s\sstock: #{item2.stock}\n")
				end
			end
			file.write("Date:\s#{@date}")
		end
	end
end



class Shop
	include FruitDatabase

	def initialize
		@list =[]
		@count = 0
	end

	def user_input
		input = gets.chomp.downcase
		case input
		when "a"
			print `clear`
			register_fruit
		when "b"
			print `clear`
			list_fruit
			puts "What is the name of the fruit you want to buy?:".cyan
			buy_a_fruit
		when "c"
			print `clear`
			admin_check
		when "d"
			print `clear`
			check_stock
		when "x"
			add_info_to_database
			puts "Goodbye! :)"
			exit
		else
			puts "Input incorrect, try again"
			user_input
		end
	end


	def print_menu
		print `clear`
		puts "---------------------".green
		puts "|                   |".green
		puts "|  ALEX'S EMPORIUM  |".green
		puts "|                   |".green
		puts "---------------------".green
		puts
		puts "Choose an Operation:"
		puts "a.) Register a fruit"
		puts "b.) Buy a fruit"
		puts "c.) Update a fruit stock"
		puts "d.) Check fruit stocks"
		puts
		puts "x.) Exit".red
		puts
		puts "Select an option(a b c d or x):".cyan
		user_input
	end
	

	def register_fruit
		list_fruit
		check = true
		puts "Enter a fruit name"
		fruit_name = gets.chomp.downcase
		@list.each do |item|
			item.fruit_list.each do |item2|
				if fruit_name == item2.fruit_name 
					puts "We already have that in stock, try again"
					check = false
					register_fruit
				end
			end
		end
		if check == true
			second_check = false
			puts "Enter a fruit supplier"
			source = gets.chomp.capitalize
			puts "Enter the stock"
			stock = gets.chomp.to_i
			@list.each do |item|
				if source == item.fruit_sources_name 
					fruit_obj = Fruit.new(fruit_name,stock)
					item.add_new_fruit(fruit_obj)
					second_check = true
				end
			end
			if second_check == false	
				fruit_hash = {"#{fruit_name}" => {"stock" => "#{stock}"}}
				fruit_obj = FruitSupplier.new(source,fruit_hash)
				add(fruit_obj)
			end
			puts "Do you want to add another?".cyan
			while(true)
				input = gets.chomp.downcase
				case input 
				when "y"
					print `clear`
					register_fruit
					break
				when "n"
					print_menu
					break
				end
				puts "incorrect(y or n)"
			end
		end
	end

	def list_fruit
		puts "Fruit".cyan
		@list.each do |item|
			item.fruit_list.each do |item2| 
				if item2.stock.to_i < 10 && item2.stock.to_i > 0
					puts "#{item2.fruit_name.capitalize}".yellow
				elsif item2.stock.to_i == 0
					puts "#{item2.fruit_name.capitalize}".red
				else 
					puts "#{item2.fruit_name.capitalize}"
				end
			end
		end
		puts
	end

	def buy_a_fruit
		input = gets.chomp
		proceed = false 
		@list.each do |pre_item|
			pre_item.fruit_list.each do |item|
				if input == item.fruit_name 
					if item.stock.to_i > 1 
						puts "There are #{item.stock} #{item.fruit_name}s left, how many do you want?".cyan
						input = gets.chomp.to_i
						item.remove_stock(input)
						puts "Purchase Complete".blue
						return_to_menu
					elsif item.stock == 1 
						puts "There is one left, do you want it? (y)".cyan
						awnser = gets.chomp.downcase
						if awnser == "y"
							item.remove_stock(1)
							puts "Purchase Complete".blue
							return_to_menu
						elsif awnser == "n" 
							puts "Okay then"
							return_to_menu 
						end
					else
						puts "Sorry, there are no #{item.fruit_name}s left, choose another item".cyan
						buy_a_fruit
					end
					proceed = true
				end	
			end
		end
		if proceed == false
			print `clear`
			list_fruit
			puts "We dont stock that particular fruit, try again".cyan
			buy_a_fruit
		end
	end

	def admin_check
		print `clear`
		if @count <= 3
			print"Username: "
			username = gets.chomp
			print"Password: "
			password = STDIN.noecho(&:gets).chomp
			if username == "admin" && password == "password"
				print`clear`
				@count = 0
				list_fruit
				puts "What fruit do you want to update stock?".cyan
				update_fruit
			else
				print`clear`
				puts "Incorrect".red
				@count+=1
				admin_check
			end
		else
			puts "You've failed 3 times, you can't change the stock".cyan
		end
	end

	def update_fruit
		proceed = false
		fruit = gets.chomp.capitalize
		@list.each do |pre_item|
			pre_item.fruit_list.each do |item|
				if fruit == item.fruit_name.capitalize 
					puts "There are #{item.stock} #{item.fruit_name}s in stock, what do you want to change it to?".cyan
					value = gets.chomp.to_i
					item.change_stock(value)
					proceed = true
					puts "There are now #{item.stock} #{item.fruit_name}s in stock".cyan
				end	
			end	
		end 
		if proceed == false
			puts "fruit is not in stock or does not exist, try again".cyan
			update_fruit
		else
			@date = Time.now.strftime("%d/%m/%Y %H:%M")
			puts "Do you want to edit another fruits stock?(y or n)".cyan
			while(true)
				input = gets.chomp.downcase
				if input == "y"
					print `clear`
					list_fruit
					puts "What fruit do you want to update stock?".cyan
					update_fruit
					break
				elsif input == "n"
					return_to_menu
					break
				else
					puts "Input invalid, try again(y or n)".red
				end
			end
		end
	end

	def check_stock
		
		@list.each do |item|
			puts "#{item.fruit_sources_name}".cyan
			item.fruit_list.each do |item2|
				print "Fruit: #{item2.fruit_name.capitalize}\tStock: "
				if item2.stock.to_i <10 && item2.stock > 0
					print "#{item2.stock}\n".yellow
				elsif item2.stock.to_i == 0
					print "#{item2.stock}\n".red
				else
					print "#{item2.stock}\n"
				end
			end
		end
		puts
		puts "Last Updated: #{@date}".green
		puts
		return_to_menu
	end

	def return_to_menu
		puts "Do you want to go back to the menu (y or n):"
		answer = gets.chomp.downcase
		case answer
		when "y"
			print_menu
		when "n"
			add_info_to_database
			puts`clear`
			puts "Goodbye! :)"
			exit
		else
			puts "Please enter the right response"
		end
	end

	def add(fruit_obj)
		@list.push(fruit_obj)
	end

end


shop = Shop.new
shop.load_database
shop.print_menu