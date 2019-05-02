structure M = BinaryMapFn(
	struct
		type ord_key = int*int
		fun compare (x:int*int, y:int*int) =
				if (#1 x > #1 y) orelse ((#1 x = #1 y) andalso (#2 x > #2 y)) then GREATER
				else if (#1 x < #1 y) orelse ((#1 x = #1 y) andalso (#2 x < #2 y)) then LESS
				else EQUAL
	end
);

fun savethecat txt =
	let
		(* --------------- READ INPUT FILE --------------- *)
		fun read_txt txt =
			let
				val ins = TextIO.openIn txt
				fun getline f =
					let
						val line = TextIO.inputLine f
					in
						if line = NONE then nil
						else explode(substring(valOf(line),0,size (valOf line)-1))::(getline f)
					end;
			in
				getline ins
			end;

		val base_map = read_txt txt
		val N = length base_map
		val M = length (hd base_map)
		(* --------------- READ INPUT FILE --------------- *)

		(* --------------- FILL A TREE WITH THE BASE MAP DATA FOR MORE EFFICIENT SEARCH AND FIND WATERS AND CAT --------------- *)
		fun fill_tree(base_map) =
			let
				fun block_add(l_cnt, c_cnt, block, tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map, (waters, cat)) =
					(M.insert(tree, (l_cnt, c_cnt), {status = block, time = 0, cat_time = 0, cat_prev = (0,0), cat_move = #"N"}),
						if (block = #"W") then ((l_cnt, c_cnt)::waters, cat)
						else if (block = #"A") then (waters, (l_cnt, c_cnt)::cat)
						else (waters, cat))
				fun line_add(_, _, [], (tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map, (waters, cat))) = (tree, (waters, cat))
					| line_add(l_cnt, c_cnt, block::rest, (tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map, (waters, cat))) = line_add(l_cnt, c_cnt+1, rest, block_add(l_cnt, c_cnt, block, tree, (waters, cat)))
				fun base_map_add(_, _, [], (tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map, (waters, cat))) = (tree, (waters, cat))
					| base_map_add(l_cnt, c_cnt, line::rest, (tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map, (waters, cat))) = base_map_add(l_cnt+1, c_cnt, rest, line_add(l_cnt, c_cnt, line, (tree, (waters, cat))))
			in
				base_map_add(0, 0, base_map, (M.empty, ([], [])))
			end;
		val (base_map_tree, (waters, cat)) = fill_tree(base_map)
		(* --------------- FILL A TREE WITH THE BASE MAP DATA FOR MORE EFFICIENT SEARCH AND FIND WATERS AND CAT --------------- *)

		(* --------------- FLOOD FILL STARTING FROM THE COORDINATES IN WATERS --------------- *)
		fun water_flood_fill([], tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map) = tree
			| water_flood_fill(c_water::rest_waters, tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map)=
			let
				val c_value = M.find(tree, c_water)
				val (c_line, c_column) = c_water
				val t_positions = [(c_line-1, c_column), (c_line+1, c_column), (c_line, c_column-1), (c_line, c_column+1)] (*up, down, left, right*)
				val t_values = [M.find(tree, (c_line-1, c_column)), M.find(tree, (c_line+1, c_column)), M.find(tree,(c_line, c_column-1)), M.find(tree, (c_line, c_column+1))]

				fun fill_target(c_value:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} option, t_position:int*int, t_value:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} option, (waters, tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map)) =
					if ((t_value<>NONE) andalso ((#status (valOf(t_value)) = #".") orelse (#status (valOf(t_value)) = #"A") orelse ((#status (valOf(t_value)) = #"W") andalso (#time (valOf(t_value))>(#time (valOf(c_value))+1)))))
					then (waters @ [t_position], M.insert(tree, t_position, {status = #"W", time = #time (valOf(c_value))+1, cat_time = 0, cat_prev = (0,0), cat_move = #"N"}))
					else (waters, tree)

				fun neighbors_fill(c_value, t_position::rest_pos, t_value::rest_val, (waters, tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map)) = neighbors_fill(c_value, rest_pos, rest_val, fill_target(c_value, t_position, t_value, (waters, tree)))
					| neighbors_fill(_, _, _, (waters, tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map)) = (waters, tree)
			in
				water_flood_fill(neighbors_fill(c_value, t_positions, t_values, (rest_waters, tree)))
			end;
		val base_map_tree = water_flood_fill(waters, base_map_tree)
		(* --------------- FLOOD FILL STARTING FROM THE COORDINATES IN WATERS --------------- *)

		(* --------------- FLOOD FILL STARTING FROM THE COORDINATES IN CAT --------------- *)
		fun cat_flood_fill([], tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map, water_max_times:{water_time:int option, water_pos:int*int} list) = (tree, water_max_times)
			| cat_flood_fill(c_cat::rest_pos, tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map, water_max_times:{water_time:int option, water_pos:int*int} list)=
			let
				val c_value = M.find(tree, c_cat)
				val (c_line, c_column) = c_cat
				val t_positions = [(c_line+1, c_column), (c_line, c_column-1), (c_line, c_column+1), (c_line-1, c_column)] (*down, left, right, up*)
			val t_moves = [#"D",#"L",#"R",#"U"]
				val t_values = [M.find(tree, (c_line+1, c_column)), M.find(tree, (c_line, c_column-1)), M.find(tree,(c_line, c_column+1)), M.find(tree, (c_line-1, c_column))]

				fun fill_target(c_cat,c_value:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} option, t_position:int*int, t_value:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} option,c_move, (cats, tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map, water_max_times:{water_time:int option, water_pos:int*int} list)) =
					if (t_value<>NONE andalso ((#status (valOf(t_value))) = #".")) (*safe*)
					then (cats @ [t_position],
								M.insert(tree, t_position, {status = #"C", time = #time (valOf(t_value)), cat_time = (#cat_time (valOf(c_value)))+1, cat_prev = c_cat, cat_move = c_move}),
								if((#water_time (hd water_max_times))<>NONE) then [{water_time = NONE, water_pos = c_cat}, {water_time = NONE, water_pos = t_position}] else {water_time = NONE, water_pos = t_position} :: water_max_times)
					else if (t_value<>NONE andalso (((#status (valOf(t_value)) = #"W") andalso (#time (valOf(t_value))>(#cat_time (valOf(c_value))+1))) orelse ((#status (valOf(t_value)) = #"C") andalso (#cat_time (valOf(t_value))>(#cat_time (valOf(c_value))+1))))) (*not safe*)
					then (cats @ [t_position],
								M.insert(tree, t_position, {status = #"C", time = #time (valOf(t_value)) , cat_time = (#cat_time (valOf(c_value)))+1, cat_prev = c_cat, cat_move = c_move}),
								if(valOf(#water_time (hd water_max_times))<((#time (valOf(t_value))))) then [{water_time = SOME ((#time (valOf(t_value)))), water_pos = t_position}] else {water_time = SOME ((#time (valOf(t_value)))), water_pos = t_position} :: water_max_times)
					else (cats, tree, water_max_times)

				fun neighbors_fill(c_cat,c_value, t_position::rest_pos, t_value::rest_val, c_move::rest_moves,(cats, tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map, water_max_times:{water_time:int option, water_pos:int*int} list)) = 
					neighbors_fill(c_cat,c_value, rest_pos, rest_val, rest_moves, fill_target(c_cat, c_value, t_position, t_value, c_move, (cats, tree, water_max_times)))
					| neighbors_fill(_, _, _, _, _, (cats, tree:{status:char, time:int, cat_time:int, cat_prev:int*int, cat_move:char} M.map, water_max_times:{water_time:int option, water_pos:int*int} list)) = (cats, tree, water_max_times)
			in
				cat_flood_fill(neighbors_fill(c_cat,c_value, t_positions, t_values, t_moves,(rest_pos, tree, water_max_times)))
			end;
		val (base_map_tree, water_max_times) = cat_flood_fill(cat, M.insert(base_map_tree, (hd cat), {status = #"C", time = #time (valOf(M.find(base_map_tree, (hd cat)))), cat_time = 0, cat_prev = (0,0), cat_move = #"N"}), if(waters = []) then [{water_time = SOME 0, water_pos = hd cat}] else [{water_time = SOME 0, water_pos = hd waters}]);
		(* --------------- FLOOD FILL STARTING FROM THE COORDINATES IN CAT --------------- *)

		(* --------------- FIND THE UPPER AND MORE LEFT PLACE FROM THE ONES HAVING THE MAXIMUM TIME FOR THE CAT --------------- *)
		fun find_upper_left([], final_pos) = ([], final_pos)
				| find_upper_left(water_max_time::rest_water_max_times, final_pos:{water_time:int option, water_pos:int*int}) =
				let
					fun is_better_pos(t_pos:int*int, c_pos:int*int) =
						if((#1 t_pos < #1 c_pos) orelse ((#1 t_pos = #1 c_pos) andalso (#2 t_pos < #2 c_pos))) then true
						else false;
				in
					if(is_better_pos(#water_pos water_max_time, #water_pos final_pos)) then find_upper_left(rest_water_max_times, water_max_time)
					else find_upper_left(rest_water_max_times, final_pos)
				end;
		val (_, best) = find_upper_left(tl water_max_times, hd water_max_times)
		(* --------------- FIND THE UPPER AND MORE LEFT PLACE FROM THE ONES HAVING THE MAXIMUM TIME FOR THE CAT --------------- *)

		(* --------------- FIND THE ROUTE FROM THE TREE MAP --------------- *)
		fun find_route(base_map_tree:{cat_move:char, cat_prev:int * int, cat_time:int, status:char, time:int} M.map, check_pos:int * int) = 
			if(#cat_move (valOf(M.find(base_map_tree, check_pos))) = #"N") then "" else find_route(base_map_tree, #cat_prev (valOf(M.find(base_map_tree, check_pos))))^(Char.toString (#cat_move (valOf(M.find(base_map_tree, check_pos)))));
		val route = find_route(base_map_tree, #water_pos best)
		val route = if (route = "") then "stay" else route
		(* --------------- FIND THE ROUTE FROM THE TREE MAP --------------- *)
	in
		(* --------------- PRINT THE RESULT --------------- *)
		if(#water_time best = NONE) then print("infinity\n"^route^"\n") else print((Int.toString ((#time (valOf(M.find(base_map_tree, #water_pos best))))-1))^"\n"^route^"\n")
		(* --------------- PRINT THE RESULT --------------- *)
	end;
