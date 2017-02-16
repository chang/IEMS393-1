"""
Flight Assignment Heuristic
Project 2
Darren, Eric, Jonathan, Katie
"""
import pandas as pd

def is_feasible_connection(flight1, flight2, fleet, flight_data):
    """
    takes two flight ids and a potential fleet and returns True if:
    1. flight1's destination connects with flight2's origin
    2. the time gap between flight1 and flight2 is less than the plane's turn time
    3. ??? block time??
    4. ??? minimum time ???
    """
    TURNTIME = 30/(60*24)
    flight1_dest = flight_data[flight_data['flight'] == flight1].reset_index().at[0, 'dest']
    flight2_orig = flight_data[flight_data['flight'] == flight2].reset_index().at[0, 'origin']
    
    flight1_arrtime = flight_data[flight_data['flight'] == flight1].reset_index().at[0, 'arr_time']
    flight2_deptime = flight_data[flight_data['flight'] == flight2].reset_index().at[0, 'dep_time']
    time_diff = flight2_deptime - flight1_arrtime

    # consider adding a max turn time as well, to avoid too much waiting on the ground
    return (flight1_dest == flight2_orig) and (time_diff >= TURNTIME)


def get_turntime(flight1, flight2, flight_data):
    """
    takes two flight ids and a potential fleet and returns turntime
    """
    flight1_arrtime = flight_data[flight_data['flight'] == flight1].reset_index().at[0, 'arr_time']
    flight2_deptime = flight_data[flight_data['flight'] == flight2].reset_index().at[0, 'dep_time']
    time_diff = flight2_deptime - flight1_arrtime
    return time_diff


def get_fleet_order(info):
	"""
	takes a single flight as a dataframe row,
	returns a list of 5 fleet choices ordered ascending by profitability
	"""
	info = info.loc[:, 'a':'e'].stack().reset_index(level=0, drop=True)
	fleet_order = list(info.sort_values().index)
	return fleet_order


def create_tail_numbers():
	"""returns list of unique tail numbers for the 5 fleets"""
	tail_numbers =  \
		['a' + str(i) for i in range(101)] +  \
		['b' + str(i) for i in range(57)] +  \
		['c' + str(i) for i in range(97)] +  \
		['d' + str(i) for i in range(78)] +  \
		['e' + str(i) for i in range(117)]
	return tail_numbers

def read_ampl_data():
	"""
	returns adjusted flight list and results list
	"""
	pass


def assign_flights():
	"""
	Flight Scheduling Heuristic
	a big issue with starting with a tail number and assigning flights until it is full is that
	the algorithm will assign a flights to a tail until it's full, even if another fleet is a lot more profitable
	better to iterate through the flights and find the best tail for it with the following condition:
		if there is a feasible tail number with a flight already, assign the flight to this tail number
		if there is not a feasible tail number but there are available tail numbers, open a new plane
		if there is not a feasible tail nor are there any tail numbers in thes best fleet, go to the next best fleet

	an improvement could be to sort flights by mean or max profitability, so they are filled optimally first
	"""
	flight_data = pd.read_csv("data/final_flight_data_truncated.csv")
	flight_data.loc[:,['a', 'b', 'c', 'd', 'e']] = flight_data.loc[:,['a', 'b', 'c', 'd', 'e']].apply(pd.to_numeric)
	flight_list = list(flight_data['flight'])
	assignments = dict((key, []) for key in create_tail_numbers())

	nflights = len(flight_list)
	count_assigned = 0
	profit = 0
	turn_times = []

	while flight_list:
		flight = flight_list.pop()
		info = flight_data[flight_data['flight'] == flight]
		fleet_order = get_fleet_order(info)
		is_assigned = False

		best_fleet = fleet_order.pop()

		while not is_assigned:
			for tail_number in assignments.keys():
				if tail_number.startswith(best_fleet):
					connecting_flight = assignments[tail_number] and  \
										is_feasible_connection(flight1=assignments[tail_number][-1], 
															   flight2=flight, 
															   fleet=best_fleet, 
															   flight_data=flight_data)

					# assign the plane to the flight if it is a viable connecting flight or it's an empty plane
					if connecting_flight or not assignments[tail_number]:
						if connecting_flight:
							turn_times.append(get_turntime(flight1=assignments[tail_number][-1], flight2=flight, flight_data=flight_data))
						assignments[tail_number].append(flight)
						profit += info.reset_index().at[0, best_fleet]
						print(profit)						
						is_assigned = True
						count_assigned += 1
						break

			# raise an error if gone through all fleets, otherwise move to next best fleet
			if not is_assigned and not fleet_order:
				print("RAN OUT OF FEASIBLE FLIGHTS")
				return (assignments, turn_times, profit)
				raise ValueError("There are no more feasible tail numbers.")
			elif not is_assigned:
				best_fleet = fleet_order.pop()

		if count_assigned % 10 == 0:
			print("Assigned", str(count_assigned), "of", str(nflights), "flights")

	return (assignments, turn_times, profit)


if __name__ == "__main__":
	(t, turn_times, profit) = assign_flights()

	# write flight assignments to tab delimited file
	out = open("flight_assignments.txt", "w")
	out_turntimes = open("turntimes.txt", "w")
	out_profit = open("profit.txt", "w")

	for tail in t.keys():
		out.write(tail)
		for flight in t[tail]:
			out.write("\t" + str(flight))
		out.write("\n")

	for time in turn_times:
		out_turntimes.write(str(time) + "\n")

	out_profit.write(str(profit))

