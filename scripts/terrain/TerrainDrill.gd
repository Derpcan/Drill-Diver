# TerrainDrill.gd
extends TileMapLayer
class_name Terrain
# essentially an APi for the drill mechanic to query terrain tiles
# dirt (hardness of 0) normal drill insta deletes
# rock (hardness of 1) only superdrill can delete
# unbreakable (hardness of 2) doesn't get broken

# each tile had this custom data
# drillable: Boolean value
# hardness: integer of 0 1 or 2

# public methods
# is_drillable(cell) Boolean
# hardness_at(cell) integer
# drill_normal(cell) Boolean .. deletes dirt (0); if deleted, true
# drill_super_one(cell) Boolean .. deletes dirt/rock (0 or 1); if deleted, true
# world_to_cell(world_point) Vector2i
# forward_cells(origin_world, dir, count=2) Array[Vector2i]

# collision updates; automatic when calling erase_cell()

# emit the first signal upon any tile being broken
# emit the second upon front tile being not drillable
signal tile_broken(cell: Vector2i, hardness: int)
signal hit_solid(cell: Vector2i)

# helpers to get info about tiles
func tiledata_at(cell: Vector2i) -> TileData:
	return get_cell_tile_data(cell)

# based on custom data find if a tile is drillable
func is_drillable(cell: Vector2i) -> bool:
	var td := tiledata_at(cell)
	return td != null and bool(td.get_custom_data("drillable"))

# get tile hardness at a cell
func hardness_at(cell: Vector2i) -> int:
	var td := tiledata_at(cell)
	return 2 if td == null else int(td.get_custom_data("hardness"))
	
# delete tile actions
# drill_nromal: given a dirt tile, instantly erases tile, returns true if tile deleted
func drill_normal(cell: Vector2i) -> bool:
	if not is_drillable(cell): return false
	if hardness_at(cell) != 0: return false
	erase_cell(cell)
	emit_signal("tile_broken", cell, 0)
	return true

# drill_super_one: given a drillable tile, erawes one tile with super drill press
func drill_super_one(cell: Vector2i) -> bool:
	if not is_drillable(cell): return false
	var h := hardness_at(cell)
	# dirt/rock only
	if h > 1: return false
	erase_cell(cell)
	emit_signal("tile_broken", cell, h)
	return true

# more helpers for point and coordinate stuff
# world_to_cell: converts a given world point into a cell coordinate
# makes it easy to query tiles to ask by cell
func world_to_cell(world_point: Vector2) -> Vector2i:
	return local_to_map(to_local(world_point))

# forward_cells: given a world space origin and a direction, return the next count cell coords straight ahead
# drilling needs to know what is directly ahead of it
# samples cells in drill direction to quickly check
func forward_cells(origin_world: Vector2, dir: Vector2, count := 2) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if dir == Vector2.ZERO:
		return out
	# normalize direction, compute a step size equal to tile width, sample first point half a tile in front (the nose)
	var n := dir.normalized()
	var step_px := float(tile_set.tile_size.x) if tile_set and tile_set.tile_size.x > 0 else 16.0
	var nose := step_px * 0.5
	# convert each probe point to a cell and return the list
	for i in count:
		var p := origin_world + n * (nose + float(i) * step_px)
		out.append(world_to_cell(p))
	return out
