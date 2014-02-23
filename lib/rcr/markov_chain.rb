module RCR
	class MarkovChain
		def initialize(depth, dict = {})
			@depth, @dict = depth, dict
		end

		attr_reader :depth
		attr_reader :dict

		def train(data)
			@dict = {}
			((@depth)...data.length).each do |i|
				context = data[(i - @depth)...i]
				cont = data[i]
				@dict[context] ||= {}
				@dict[context][cont] ||= 0
				@dict[context][cont] += 1
			end

			@dict.keys.each do |key|
				sum = @dict[key].values.inject(&:+)
				@dict[key].keys.each do |key2|
					@dict[key][key2] = @dict[key][key2].to_f / sum
				end
			end
		end

		def score(context, continuation)
			context = context.last(@depth)
			raise ArgumentError if context.length != @depth

			return nil unless @dict.key?(context)
			@dict[context][continuation]
		end

		MARSHAL_ID = self.name
		include Marshal

		def save_internal(filename)
			File.open filename, "w" do |file|
				YAML.dump({
					dict: @dict, depth: @depth
				}, file)
			end
		end

		def self.load_internal(filename)
			hash = YAML.load_file(filename)
			self.new(hash[:depth], hash[:dict])
		end
	end
end
