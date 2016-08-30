class FruitSupplier
	attr_reader :fruit_sources_name,:fruit_list
	def initialize(fruit_sources_name,supplier_hash)
		@fruit_list =[]
		@supplier_hash = supplier_hash
		@fruit_sources_name = fruit_sources_name
		store_fruit
	end

	def store_fruit
		@supplier_hash.keys.each_with_index do |item,index|
			fruit_obj = Fruit.new(item,@supplier_hash[item]['stock'])
			@fruit_list.push(fruit_obj)
		end
	end

	def add_new_fruit(fruit_obj)
		@fruit_list.push(fruit_obj)
	end
end

