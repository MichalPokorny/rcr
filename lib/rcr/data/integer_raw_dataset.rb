require 'rcr/logging'

module RCR
	module Data
		class IntegerRawDataset
			include Logging

			def initialize(data = nil)
				@data = data
			end

			def [](key)
				@data[key]
			end

			def keys
				@data.keys
			end

			#def delete(*args)
			#	raise "Deleting data from dataset!!!!!"
			#	@data.delete(*args)
			#end

			# Return a copy with restricted keys.
			def restrict_keys(keys)
				ary = @data.map { |k, v|
					keys.include?(k) ? [k,v] : nil
				}.compact
				self.class.new(Hash[ary])
			end

			def write(io)
				@data.keys.each { |key|
					raise ArgumentError, "Invalid key class: #{key.class}" unless key.is_a? Fixnum
					
					item_count = @data[key].count
					bytes = [key, item_count].pack("qq")
					io.write(bytes)

					@data[key].each { |item|
						raise ArgumentError, "Invalid item class: #{item.class}" unless item.respond_to?(:to_raw_data)
						data = item.to_raw_data
						size = data.size
						bytes = [size].pack("Q")
						io.write(bytes)
						io.write(data)
					}
				}
			end

			def save(filename)
				File.open(filename, "wb") do |file|
					write(file)
				end
			end

			def self.read(io, klass, logging: false)
				with_logging_set(logging) do
					log "Loading integer-raw dataset"
					data = {}

					until io.eof?	
						bytes = io.read(16)
						key, item_count = bytes.unpack("qq")
						log "Key #{key}, #{item_count} items"

						raise "Key #{key} present twice" if data.key?(key)
						data[key] = []

						item_count.times { |i|
							bytes = io.read(8)
							r = bytes.unpack("Q")
							size = r.first
							item = klass.from_raw_data(io.read(size))
							data[key] << item
						}
					end
					
					#puts "==###"
					#data.map { |k, v|
					#	puts "#{k} => [#{v.map(&:to_human_s).join("\n")}]"
					#}
					#puts "==###"

					self.new(data)
				end
			end

			def self.load(filename, klass = RCR::Data::Image, logging: false)
				File.open(filename, "rb") do |file|
					self.read(file, klass, logging: logging)
				end
			end

			def ==(other)
				raise unless other.is_a?(IntegerRawDataset)
				keys == other.keys &&
					keys.all? { |k| self[k] == other[k] }
			end

			def to_human_s
				content = @data.map { |k, v|
					"#{k} => [#{v.map(&:to_human_s).join("\n")}]"
				}.join("\n")
				"#<IntegerRawDataset #{content}>"
			end
		end
	end
end
