extends Node2D

@onready var agent1 = $agent1
@onready var agent2 = $agent2
@onready var goal = $Room/hidden/goal
var REF = Vector2.ZERO

var path = []
var agent1_stop = false
var agent2_stop = false
var started = false
func _ready() -> void:
	REF = $reference.position
	
	agent1.REF = REF
	agent2.REF = REF
	
	#Store initial position
	agent1.current = agent1.get_cell()
	agent2.current = agent2.get_cell()
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	if started:
		execute()
	

func execute():
	if agent1.moving or agent2.moving:
		return
	if not agent1_stop:
		var res = search(agent1)
		match res:
			1:
				print("Solution found")
				agent1_stop = true
			0:
				agent1.moving = true
			-1:
				print("Irresoluble")
				agent1_stop = true
				
	if not agent2_stop:
		var res = search(agent2)
		match res:
			1:
				print("Solution found")
				agent2_stop = true
				
			0:
				agent2.moving = true
			-1:
				print("Irresoluble")
				agent2_stop = true
	
func _on_button_pressed() -> void:
	started = true
	
	

				
	#var res2 = search(agent2)
	
	
	
	
func search(agent):
	print("---------------Searching[",agent.name,"]---------------")
	# 1 - Found, the agent has to stop and deactivate collisions  
	# 0 - Not found, moving action
	#-1 - Not found, the agent can´t solve the maze
	#------[A]------#
	#add node to path
	agent.path.append(agent.current)
	print("Added ", agent.current , " to path")
	#Add to visited
	agent.visited_cells.append(agent.current)
	print("Added ", agent.current , " to visited")
	
	#check if is on goal
	if not agent.is_on_goal():
		print("Not on goal")
		
		#Check if there is a path available
		if path.size() == 0:
			print("Not path available")
			#gettin free cells
			var free_cells:Array = agent.get_available_cells()
			print("Free cells: ", free_cells)
			#filtering cells
			return b_scheme(agent, free_cells)
				
		else:
			#Check if has common cells with partner path
			print("Path available")
			print("---AGENT1---")
			print("Path: ", agent1.path)
			print("---AGENT2---")
			print("Path: ", agent2.path)
			if has_common_cells():
				print("Path has common cells")
				
				#Check if the last cell is on the path
				var next_cell = last_cell_on_path(agent.name)
				if next_cell:
					print("Our last cell is on the partners path")
					agent.current = next_cell
					#---------[Time to moving]---------#
					return 0
				else:
					print("Our last cell is not on the partners path")
					print("Removed: ", agent.path.pop_back(), " from path")
					print("Moving to: ", agent.current)
					agent.current = agent.path.pop_back()
					#---------[Time to moving]---------#
					return 0
			else:
				print("Path has not common cells")
				var free_cells:Array = agent.get_available_cells()
				print("Free cells: ", free_cells)
				var path_cell = path_match(free_cells, agent.name)
				print("Path cell: ", path_cell)
				if path_cell:
					print("A cell in the path is nearly. Moving to it.")
					agent.current = path_cell
					#---------[Time to moving]---------#
					return 0
				else:
					return b_scheme(agent, free_cells)
	else:
		path = agent.path
		agent.pending_cells = []
		agent.visited_cells = []
		#---------[Stop]---------#
		return 1
	
func full_filter(free_cells:Array):
	var to_pop:Array = []
	for fc in free_cells:
		var found = false
		for p in agent1.pending_cells:
			if (fc.x == p.x) and (fc.y == p.y):
				to_pop.append(fc)
				found = true
				break
		if found: continue
		for v in agent1.visited_cells:
			if (fc.x == v.x) and (fc.y == v.y):
				to_pop.append(fc)
				found = true
				break
		if found: continue		
		for p in agent2.pending_cells:
			if (fc.x == p.x) and (fc.y == p.y):
				to_pop.append(fc)
				found = true
				break
		if found: continue
		for v in agent2.visited_cells:
			if (fc.x == v.x) and (fc.y == v.y):
				to_pop.append(fc)
				break
	
	for tp in to_pop:
		print("Deleting ", tp, " from ", free_cells)
		free_cells.erase(tp)
	return free_cells
	
func pending_match(free_cells):
	var last_cell = null
	var pendings = agent1.pending_cells.duplicate()
	pendings.reverse()
	for p in pendings:
		for fc in free_cells:
			if (fc.x == p.x) and (fc.y == p.y):
				last_cell = p
				agent1.pending_cells.erase(p)
				return last_cell
				
	pendings = agent2.pending_cells.duplicate()
	pendings.reverse()
	for p in pendings:
		for fc in free_cells:
			if (fc.x == p.x) and (fc.y == p.y):
				last_cell = p
				agent2.pending_cells.erase(p)
				return last_cell
	return last_cell

func path_match(free_cells, agent):
	print("Searching free cells in the path")

	var last_cell = null
	match agent:
		"agent1":
			var aux = agent2.path.duplicate()
			aux.reverse()
			for p in aux:
				if p in free_cells:
					last_cell = p
					return last_cell
		"agent2":
			var aux = agent1.path.duplicate()
			aux.reverse()
			for p in aux:
				if p in free_cells:
					last_cell = p
					return last_cell
	return last_cell
	
func has_common_cells():
	var common_cells = false
	for p1 in agent1.path:
		if p1 in agent2.path:
			common_cells = true
			break
	return common_cells
			
func last_cell_on_path(agent):
	if agent == "agent1":
		if agent1.path[-1] in agent2.path:
			var index = agent2.path.find(agent1.path[-1]) + 1
			return agent2.path[index]
	else:
		if agent2.path[-1] in agent1.path:
			var index = agent1.path.find(agent2.path[-1]) + 1
			return agent1.path[index]
	return null
	
	
func b_scheme(agent, free_cells):
	print("---B_SCHEME---")
	var filtered:Array = full_filter(free_cells)
	#Available cells
	print("---AGENT1---")
	print("Pending: ", agent1.pending_cells)
	print("Visited: ", agent1.visited_cells)
	print("---AGENT2---")
	print("Pending: ", agent2.pending_cells)
	print("Visited: ", agent2.visited_cells)
	print("")
	if filtered.size() != 0:
		print("Available cells: ", filtered)
		#Take first (Depth search)
		agent.current = filtered.pop_front()
		print("Next cell: ", agent.current)
		#Store left ones in pendings list
		for c in filtered:
			agent.pending_cells.append(c)
		print("New pending: ", agent.pending_cells)
		print("Moving")
		#---------[Time to moving]---------#
		return 0
		
	else:
		print("Not available cells")
		
		#The agent has pendings?
		if agent.pending_cells.size() != 0:
			print("Using pending cells")
			#Match free cells with last pending
			var last_pending = agent.pending_cells[-1]
			free_cells = agent.get_available_cells()
			print("Last pending cell: ", last_pending)
			print("Free cells: ", free_cells)
			if last_pending in free_cells:
				print("A pending cell near")
				#Removed from pending
				agent.pending_cells.pop_back()
				agent.current = last_pending
				
				#---------[Time to moving]---------#
				return 0
			else:
				print("No pending cells nearly")
				print("Removing :",agent.path.pop_back(), " from path")
				agent.current = agent.path.pop_back()
				print("Moving to :", agent.current)
				#---------[Time to moving]---------#
				return 0
		else:
			#Check if matches with partner pendings
			var last_cell = pending_match(free_cells)
			if last_cell:
				agent.current = last_cell
				#---------[Time to moving]---------#
				return 0
			else:
				#Check if matches with partner path
				var path_cell = path_match(free_cells, agent.name)
				if path_cell:
					agent.current = path_cell
					#---------[Time to moving]---------#
					return 0
				else:
					print("Sin solución")
					#---------[Stop]---------#
					return -1
	
	
