extends Node3D

# Change these to match the exact dimensions printed by your R script!
const GRID_WIDTH = 120   # X (Longitude points)
const GRID_HEIGHT = 80   # Z (Latitude points)
const LAYER_COUNT = 6    # Y (Pressure levels)

func _ready():
	var file_path = "res://cloud_ice_data.bin"
	
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var buffer = file.get_buffer(file.get_length())
		
		# Create the 3D Texture
		var texture_3d = ImageTexture3D.new()
		var images: Array[Image] = []
		
		# Calculate how many bytes make up a single 2D layer 
		# (Width * Height * 4 bytes because we used 32-bit floats)
		var layer_bytes_size = GRID_WIDTH * GRID_HEIGHT * 4
		
		for i in range(LAYER_COUNT):
			var start_byte = i * layer_bytes_size
			var layer_data = buffer.slice(start_byte, start_byte + layer_bytes_size)
			
			# Create a 2D image layer using format RF (Red channel, Float)
			var img = Image.create_from_data(GRID_WIDTH, GRID_HEIGHT, false, Image.FORMAT_RF, layer_data)
			images.append(img)
		
		# Initialize the 3D texture with our layout
		texture_3d.create(Image.FORMAT_RF, GRID_WIDTH, GRID_HEIGHT, LAYER_COUNT, false, images)
		
		# Apply it to your Volumetric/Isosurface Shader material
		var mesh_instance = $MeshInstance3D
		var material = mesh_instance.get_active_material(0)
		if material:
			material.set_shader_parameter("climate_volume_tex", texture_3d)
			print("3D Climate Texture loaded successfully!")
	else:
		push_error("Could not find the binary data file.")
