#!/usr/bin/env python
# -*- coding: utf-8 -*-


"""  
  Created by Krzysztof on 19/06/2017.
  Distributed under the MIT License.
  See the LICENSE file for more information.
"""



from PIL import Image
import json
import os
import sys
import shutil
import random
import argparse
import uuid


# Install exiting the app
import signal
def signal_handler(signal, frame):
    print '\Exit Requested'
    sys.exit(0)
signal.signal(signal.SIGINT, signal_handler)


# Util for logging progress to console
# https://stackoverflow.com/a/3002100/2754158
def log_progress(str):
	sys.stdout.write('\r')
	sys.stdout.write(str)
	sys.stdout.flush()


# Clean up the folder for making new images
def prepare_build_directory(basedir, build_path):
	# Create output directory
	build_dir = os.path.join(basedir, build_path)
	if os.path.isdir(build_dir):
		shutil.rmtree(build_dir)
	
	os.makedirs(build_dir)
	return build_dir


# Count number of frames in given images
def count_frames(images):
	count = 0
	for _, v in images.iteritems():
		count = count + len(v["frames"])
	return count



# Read the json
def read_json(json_path):
	if not os.path.isfile(json_path):
		return None

	with open(json_path) as file:
		data = json.load(file)
		# TODO: validate  format is img_key : { frames = [ {}, {}] }
		return data

	return None



def export_valid_images(images_dir,  
						scale=1,
						filter = None, 
						configureFrame = None):
	
	# Check if dir exist
	if not os.path.isdir(images_dir):
		print "Images directory does not exist, terminating"
		return 0

	# Read the json
	images_info = read_json(os.path.join(images_dir, "images_info.json"))
	if not images_info:
		print "Could not find images_info.json"
		exit(1)

	# Create build directory
	out_dir = prepare_build_directory(images_dir, "build/valid")
	if not os.path.isdir(out_dir):
		print "Output directory does not exist, terminating"
		return 0

	if scale < 1 or scale > 10:
		print "Invalid param, scale must be positive integer between 1-10"
		exit(0)

	shouldScale = scale != 1

	print "Generating valid images from info.."
	print "Images will be saved to {}".format(out_dir)
	print "There is {} frames".format(count_frames(images_info))
	if filter:
		print " - filter is on"
	if configureFrame:
		print " - frame config is on"	
	if shouldScale:
		print " - will scale images by 1/{}".format(scale)



	# Progress reporting
	mini_counter = 0; current_count = 0

	for image_name, image_info in images_info.iteritems():
		# Read the frames from the image info
		selection_frames = image_info["frames"]
		if len(selection_frames) == 0:
			print "Image '{}' has no frames defined" 
			continue

		# Get ful path to the image	
		image_path = os.path.join(images_dir, image_name)
		
		# TODO: lazy load
		image = Image.open(image_path)
		if shouldScale:
			image = image.resize((image.size[0] / scale, image.size[1] / scale), Image.BILINEAR)
		if image == None:
			print "warn: can not create image from '{}'".format(image_name)
			continue

		image_name_no_extension = os.path.basename(image_name)
		count = 0
		for selected_frame in selection_frames:
			# do we want to display?
			if filter and not filter(selected_frame): 
				continue

			# Get frames
			frames = [selected_frame]
			if configureFrame:
				frames = configureFrame(selected_frame)


			# For each frame generate cropped image
			for frame in frames:

				x = frame["x"]; width = frame["width"]
				y = frame["y"]; height = frame["height"]

				if shouldScale:
					x = x / scale; 
					y = y / scale;
					width = width / scale; 
					height = height / scale
			
				# Further validate the frames if it's custom user one
				if (configureFrame):
					x = max(0, x)
					y = max(0, y)
					x = min(x, image.size[0] - width)
					y = min(y, image.size[1] - height)

				
				# Get the part of the image selected in this frame
				cropped_image = image.crop((x, y, x + width, y + height))
	
				# write
				save_name = "{}__{}.jpg".format(os.path.basename(image_name), count)
				cropped_image.save(os.path.join(out_dir, save_name));
				
				count = count + 1
	
				mini_counter = mini_counter + 1

				# Log progress every XX
				if (mini_counter >= 20):
					current_count += mini_counter
					log_progress(" Created {} images.. ".format(current_count))
					mini_counter = 0;

	print "Finished exporting {} valid images".format(current_count)
	print ""
	return current_count


# Generates the backgroudn images of given size
# Taking into account the images info - that is if selection frame intersects the random bg, it's discarted
def export_background_images(images_dir,
							 scale,
							 how_many, 
							 width, 
							 height,
							 filter = None):

	# Utils to Check frame intersections
	def range_overlap(a_min, a_max, b_min, b_max):
		return (a_min <= b_max) and (b_min <= a_max)

	def overlap(f1, f2):
		left1 = f1["x"]; left2 = f2["x"]
		right1 = left1 + f1["width"]; right2 = left2 + f2["width"]
		top1 = f1["y"]; top2 = f2["y"]
		bottom1 = top1 + f1["height"]; bottom2 = top2 + f2["height"]

		return range_overlap(left1, right1, left2, right2) and range_overlap(bottom1, top1, bottom2, top2)

	
	# Check if dir exist
	if not os.path.isdir(images_dir):
		print "Images directory does not exist, terminating"
		return 0

	# Read the json
	images_info = read_json(os.path.join(images_dir, "images_info.json"))
	if not images_info:
		print "Could not find images_info.json"
		exit(1)

	# Create build directory
	out_dir = prepare_build_directory(images_dir, "build/background")
	if not os.path.isdir(out_dir):
		print "Output directory does not exist, terminating"
		return 0

	if scale < 1 or scale > 10:
		print "Invalid param, scale must be positive integer between 1-10"
		exit(0)

	image_names = images_info.keys()
	shouldScale = scale != 1



	print "Will generate {} background images ...".format(how_many)
	print "Images will be saved to {}".format(out_dir)
	print "There is {} frames".format(count_frames(images_info))
	print "Press ctr-c to stop"

	if filter:
		print " - filter is on"
	if shouldScale:
		print " - will scale images by 1/{}".format(scale)


	
	mini_counter = 0; current_count = 0

	while current_count < how_many:

		image_name = random.choice(image_names)
		image_path = os.path.join(images_dir, image_name)
		frames = images_info[image_name]["frames"]

		image =  Image.open(image_path)
		image_size = image.size

		if shouldScale:
			image = image.resize((image.size[0] / scale, image.size[1] / scale), Image.BILINEAR)
		if image == None:
			print "warn: can not create image from '{}'".format(image_name)
			continue

		for _ in range(20):
			
			x = random.randint(0, image_size[0] - width)
			y = random.randint(0, image_size[1] - height)

			test_frame = {"x" : x, "y" : y, "width" : width, "height" : height}

			# do we want to display?
			if filter and not filter(test_frame): 
				continue


			
			#print "image.size = {}".format(image.size)
			
			valid = True
			for frame in frames:
				if overlap(frame, test_frame):
					valid = False

			if not valid : continue

			
			# print "valid, cropping image and saving"
			w = width
			h = height
			if shouldScale:
				x = x / scale; 
				y = y / scale;
				w = width / scale; 
				h = height / scale

			cropped_image = image.crop((x, y, x + w, y + h))

			# write
			save_name = "{}__{}.jpg".format(os.path.basename(image_name), str(uuid.uuid4()))
			cropped_image.save(os.path.join(out_dir, save_name));

			mini_counter = mini_counter + 1

			if (mini_counter >= 50):
				current_count += mini_counter
				log_progress(" Created {} images.. ".format(current_count))
				mini_counter = 0;

	print "Finished exporting {} valid images".format(current_count)
	print ""





if __name__ == '__main__':
	
	# Use Argparse
	parser = argparse.ArgumentParser(description="Extracts selected parts of image into /valid and /background categories")
	parser.add_argument("images_dir", type=str,  help="Path to the images directory.")
	parser.add_argument('--width', required=True, type=int, 	help="Width of frame")
	parser.add_argument('--height', required=True, type=int,   help="Height of frame")
	parser.add_argument('--downscale', type=int, default=1, help="Downscale param")
	args = parser.parse_args()

	
	# Read the params
	images_dir = args.images_dir
	perfect_width = args.width
	perfect_height = args.height
	scale_by = args.downscale


	# Generator for valid frames, it generates multiple offsetted frames from given one
	def configure_valid_frames(frame):
		x = frame["x"]; width = frame["width"]
		y = frame["y"]; height = frame["height"]

		midX = x + width / 2.0
		midY = y + height / 2.0

		x = int(midX - perfect_width/2.0)
		y = int(midY - perfect_height/2.0)

		# Dissortion - take more images from given one, offset each a bit
		result = []
		for dx in [0]: #[-10, 0, 10]:  
			for dy in [0]: #[-5, 0, 5]:
				result.append( {"x" : (x + dx), "y" : (y + dy), "width" : perfect_width, "height" : perfect_height} )

		return result



	# Export valid images
	export_valid_images(images_dir, # images_directory
				        scale_by,   # Scale down X times
				     	None, 		#lambda frame: frame["width"] >= 150 and frame["width"] <= 300,  # What frames should be selected
					    configure_valid_frames) # Generate valid frames from given one



	# Export background images
	# Pick how many bg images should be created
	background_images = 0

	export_background_images(images_dir, 
							scale_by,
							background_images, 
							perfect_width, 
							perfect_height,
							None,  #lambda frame: frame["x"] > 800 and frame["y"] <= 2000 and frame["y"] > 400,  # What frames should be selected
							)

	

	
	

	

	




