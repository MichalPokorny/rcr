require 'rcr/data/image'
require 'rcr/data/dataset'

module RCR
	module LetterClassifier
		def self.load_inputs(source_dir)
			data_by_letter = {}

			Dir["#{source_dir}/*"].each do |sample_dir|
				desc = YAML.load_file(File.join(sample_dir, "data.yml"))

				# Create list of letter codes contained in the file.
				letters = []
				desc["segments"].each do |segment|
					letters += (segment["first"]..segment["last"]).to_a
				end

				image = Data::Image.load(File.join(sample_dir, "data.png"))

				data = image.crop_by_columns(letters.count, desc["cell_height"])

				# Make it so that the data is indexed by letter.
				data.each_index do |index|
					letter = letters[index]
					images = data[index]

					data_by_letter[letter] ||= []
					data_by_letter[letter] += data[index]

					# Automatic mutations:
					# 0.times { |mutation|
					# 	data_by_letter[letter] += images.map { |img|
					# 		image_to_net_input(img.mutate)
					# 	}
					# }
				end
			end

			RCR::Data::Dataset.new(data_by_letter)
		end
	end
end
