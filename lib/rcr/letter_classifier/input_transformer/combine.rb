require 'rcr/marshal'
require 'rcr/data/neural_net_input'

module RCR
	module LetterClassifier
		module InputTransformer
			class Combine
				def initialize(extractors)
					@extractors = extractors
				end

				def output_size
					@extractors.map(&:output_size).inject(&:+)
				end

				def transform(image)
					Data::NeuralNetInput.concat(@extractors.map { |e| e.transform(image) })
				end

				MARSHAL_ID = self.name
				include Marshal

				def save_internal(filename)
					File.open filename, "w" do |file|
						YAML.dump({
							count: @extractors.size
						}, file)
					end

					@extractors.each.with_index do |extractor, index|
						extractor.save("#{filename}-#{index}")
					end
				end

				def self.load_internal(filename)
					extractors = []
					(0...YAML.load_file(filename)[:count]).each do |i|
						extractors << Marshal.load("#{filename}-#{i}")
					end
					self.new(extractors)
				end
			end
		end
	end
end
