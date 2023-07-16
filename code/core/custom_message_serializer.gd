extends "res://addons/godot-rollback-netcode/MessageSerializer.gd"

var input_path_mapping := {
	'/root/Main/ServerPlayer': 1,
	'/root/Main/ClientPlayer': 2,
}

var input_path_mapping_inverse := {}

func _init() -> void:
	for key in input_path_mapping:
		input_path_mapping_inverse[input_path_mapping[key]] = key

enum HeaderFlags{
	HAS_MOVEMENT_VECTOR = 0x01,
	HAS_STRONG_VECTOR = 0x02,
	HAS_SHIELD_ANALOG = 0x04,
	HAS_BUTTONS = 0x08,
}

func serialize_input(all_input: Dictionary) -> PackedByteArray:
	var buffer := StreamPeerBuffer.new()
	buffer.resize(64)
	
	buffer.put_u32(all_input["$"])
	buffer.put_u8(all_input.size() - 1)
	
	for path in all_input:
		if path == "$":
			continue
		buffer.put_u8(input_path_mapping[path])
		
		var header := 0
		
		var input = all_input[path]
		if input.has('movement_vector'):
			header |= HeaderFlags.HAS_MOVEMENT_VECTOR
		
		if input.has('strong_vector'):
			header |= HeaderFlags.HAS_STRONG_VECTOR
		
		if input.has('shield_analog'):
			header |= HeaderFlags.HAS_SHIELD_ANALOG
		
		if input.has("buttons"):
			header |= HeaderFlags.HAS_BUTTONS
		
		buffer.put_u8(header)
		
		if input.has('movement_vector'):
			var movement_vector: Vector2 = input['movement_vector']
			buffer.put_float(movement_vector.x)
			buffer.put_float(movement_vector.y)
			
		if input.has('strong_vector'):
			var strong_vector: Vector2 = input['strong_vector']
			buffer.put_float(strong_vector.x)
			buffer.put_float(strong_vector.y)
			
		if input.has('shield_analog'):
			var shield_analog: float = input['shield_analog']
			buffer.put_float(shield_analog)
			
		if input.has('buttons'):
			buffer.put_u8(input['buttons'])
	
	buffer.resize(buffer.get_position())
	
	return buffer.data_array


func unserialize_input(serialized: PackedByteArray) -> Dictionary:
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	
	var all_input := {}
	
	all_input['$'] = buffer.get_u32()
	
	var input_count = buffer.get_u8()
	
	if input_count == 0:
		return all_input
	
	var path = input_path_mapping_inverse[buffer.get_u8()]
	var input := {}
	
	var header = buffer.get_u8()
	if header & HeaderFlags.HAS_MOVEMENT_VECTOR:
		input["movement_vector"] = Vector2(buffer.get_float(), buffer.get_float())
	
	if header & HeaderFlags.HAS_STRONG_VECTOR:
		input["strong_vector"] = Vector2(buffer.get_float(), buffer.get_float())
		
	if header & HeaderFlags.HAS_SHIELD_ANALOG:
		input["shield_analog"] = buffer.get_float()
		
	if header & HeaderFlags.HAS_BUTTONS:
		input["buttons"] = buffer.get_u8()
	
	all_input[path] = input
	
	return all_input
