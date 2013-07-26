require 'kgr/data/image'
require 'kgr/data/segmentation'
require 'kgr/data/segmentation-box'
require 'kgr/word-segmentator'

module KGR
	module WordSegmentator
		class Default
			def save(filename)
				# stub
			end

			def self.load(filename)
				# stub
				self.new
			end

			# Returns Segmentation
			def segment(image)
				#result = []
				result = WordSegmentator.segment_into_continuous_parts(image)
				segmentation = Data::Segmentation.new(image, result)

				# result << Data::SegmentationBox.new(image, image.width / 2, image.height / 2, image.width / 4, image.height / 4)

				# This is how you join two boxes.
#				if segmentation.boxes.count > 1
#					segmentation = segmentation.merge_boxes(segmentation.boxes[0], segmentation.boxes[1])
#				end

				# This is how you split a box.
#				if segmentation.boxes.count >= 1
#					box = segmentation.boxes.first
#					segmentation = segmentation.split_box_along_relative_x(box, box.width / 2)
#				end

				# This is how you forget a box.
#				if segmentation.boxes.count >= 1
#					segmentation = segmentation.remove_box(segmentation.boxes.first)
#				end

				segmentation
			end

			def self.prepare_data(source_dir, target_file)
				data = {}
				i = 1

				Dir["#{source_dir}/*"].each do |sample_dir|
					image = Data::Image.load(File.join(sample_dir, "data.png"))
					segmented = Data::Image.load(File.join(sample_dir, "divided.png"))

					# TODO: this is simplified over here...

					segm = KGR::Data::Segmentation.new(image, KGR::WordSegmentator.load_segmentation_from_sample(image, segmented))

					data[i] = [ segm ]

					i += 1
				end

				dataset = Data::IntegerRawDataset.new(data)
				dataset.save(target_file)
			end

			def train(data_file)
				segmentations = []

				dataset = Data::IntegerRawDataset.load(data_file, KGR::Data::Segmentation)
				dataset.keys.each do |key|
					segmentations << dataset[key].first
				end

				puts "loaded #{segmentations.count} segmentations for training"

				total_delta = 0

				segmentations.each do |segmentation|
					mine = segment(segmentation.image)
					total_delta += mine.difference(segmentation)
				end
				puts "total delta = #{total_delta}"
			end
		end
	end
end
