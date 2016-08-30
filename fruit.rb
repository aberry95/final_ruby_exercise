class Fruit
	attr_reader :fruit_name,:stock,:fruit_sources

	def initialize(fruit_name,stock)
		@fruit_name = fruit_name
		@stock = stock 
	end

	def remove_stock(input_stock)
		if input_stock <= @stock
			@stock = @stock - input_stock
		end
	end

	def change_stock(input_stock)
		@stock = input_stock
	end
end