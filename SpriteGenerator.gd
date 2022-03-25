extends Node

#     0 = Empty
#    -1 = Always solid
#     1 = Randomly chosen Empty/Body
#     2 = Randomly chosen Solid/Body (cockpit)
var space := [
	[0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 1, 1],
	[0, 0, 0, 0, 0, 1,-1],
	[0, 0, 0, 0, 1, 1,-1],
	[0, 0, 0, 0, 1, 1,-1],
	[0, 0, 0, 1, 1, 1,-1],
	[0, 0, 1, 1, 1, 2, 2],
	[0, 0, 1, 1, 1, 2, 2],
	[0, 0, 1, 1, 1, 2, 2],
	[0, 0, 1, 1, 1, 1,-1],
	[0, 0, 0, 0, 1, 1, 1],
	[0, 0, 0, 0, 0, 0, 0]
]

var noise: bool = true
var rand_color: bool = true
var body_color: Color = Color.WHITE
var empty_color: Color = Color.TRANSPARENT
var border_color: Color = Color.BLACK


func _ready():
	var arr = generate(space)
	var mask_img = mask_to_image(space, 8)
	var img = matrix_to_image(arr, 8)
	img = mirror_img(img)
	mask_img = mirror_img(mask_img)
	img.save_png("user://space_sprite.png")
	mask_img.save_png("user://space_mask.png")


func generate(mask: Array) -> Array:
	var w = mask[0].size()
	var h = mask.size()
	var _mask = mask.duplicate(true)

	# Generate body
	for x in w:
		for y in h:
			if _mask[y][x] == 1:
				_mask[y][x] = randi() % 2
			elif _mask[y][x] == 2:
				if randf() > 0.5:
					_mask[y][x] = 1
				else:
					_mask[y][x] = -1

	# Generate the edges/border
	for x in w:
		for y in h:
			if _mask[y][x] == 1:
				if x - 1 >= 0 and _mask[y][x - 1] == 0:
					_mask[y][x - 1] = -1
				if x + 1 < w and _mask[y][x + 1] == 0:
					_mask[y][x + 1] = -1
				if y - 1 >= 0 and _mask[y - 1][x] == 0:
					_mask[y - 1][x] = -1
				if y + 1 < h and _mask[y + 1][x] == 0:
					_mask[y + 1][x] = -1
	return _mask


# horizontal mirror image
func mirror_img(im: Image) -> Image:
	var im_mir: Image = Image.new()
	im_mir.create(im.get_width() * 2, im.get_height(), false, Image.FORMAT_RGBA8)
	im_mir.fill(Color.PURPLE)
	im_mir.blit_rect(im, Rect2(Vector2.ZERO, im.get_size()), Vector2(0, 0))
	im.flip_x()
	im_mir.blit_rect(im, Rect2(Vector2.ZERO, im.get_size()), Vector2(im.get_width(), 0))
	return im_mir


# Sprite matrix to Image
func matrix_to_image(matrix: Array, scale: int = 1) -> Image:
	var img: Image = Image.new()
	img.create(matrix[0].size(), matrix.size(), false, Image.FORMAT_RGBA8)

	if rand_color:
		body_color = Color.from_hsv(randf(), 0.6, 0.9)
#		border_color = Color.from_hsv(randf(), 0.6, 0.3)
		border_color = body_color.darkened(0.7)

	for x in range(matrix[0].size()):
		for y in range(matrix.size()):
			match matrix[y][x]:
				# EMPTY
				0:
					img.set_pixel(x, y, Color.TRANSPARENT)
				# BODY
				1:
					if noise:
						img.set_pixel(x, y, body_color.darkened(randf_range(0.0, 0.5)))
					else:
						img.set_pixel(x, y, body_color)
				# BORDER
				-1:
					img.set_pixel(x, y, border_color)

	if scale > 1:
		img.resize(img.get_width() * scale, img.get_height() * scale, Image.INTERPOLATE_NEAREST)
	return img


func mask_to_image(matrix: Array, scale: int = 1) -> Image:
	var img: Image = Image.new()
	img.create(matrix[0].size(), matrix.size(), false, Image.FORMAT_RGBA8)

	for x in range(matrix[0].size()):
		for y in range(matrix.size()):
			match matrix[y][x]:
				0:
					img.set_pixel(x, y, Color.TRANSPARENT)  # 0 = Empty
				1:
					img.set_pixel(x, y, Color.GREEN)  # 1 = Randomly chosen Empty/Body
				2:
					img.set_pixel(x, y, Color.BLUE)  # 2 = Randomly chosen Border/Body
				-1:
					img.set_pixel(x, y, Color.RED)  # -1 = Always solid
	if scale > 1:
		img.resize(img.get_width() * scale, img.get_height() * scale, Image.INTERPOLATE_NEAREST)
	return img
