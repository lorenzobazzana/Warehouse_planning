import json
import os
import random
import sys

######
#---- Code for generating a valid random instance, with no overlappings
#---- Satisfiability is not guaranteed
#---- Instance difficulty is defined arbitrarily, based on the size of the warehouse and the number of boxes and drawers
######

def easy_instance(limit=5):
    
    random.seed()
    m = limit - random.randint(-1, 1) 
    n = limit - random.randint(-1, 1)
    time = 10

    drawer_number = random.randint(0, 1)
    drawers = []

    for i in range(drawer_number):
        pos = place_drawers(m, n, drawers)
        if pos is not None:
            drawers.append(pos)

    box_number = random.randint(1, int(drawer_number+limit/2))
    box_number = min(box_number, 3)
    boxes = []

    for i in range(box_number):
        pos = place_boxes(m, n, boxes, drawers)
        boxes.append(pos)

    return (m,n,time, boxes, drawers)

def medium_instance(limit=8):
    
    random.seed()
    m = limit - random.randint(0, 1) 
    n = limit - random.randint(0, 1)
    time = 10

    drawer_number = random.randint(1, 3)
    drawers = []

    for i in range(drawer_number):
        pos = place_drawers(m, n, drawers)
        if pos is not None:
            drawers.append(pos)

    box_number = random.randint(1, int(drawer_number+limit/2))
    box_number = min(box_number, 3)
    boxes = []

    for i in range(box_number):
        pos = place_boxes(m, n, boxes, drawers)
        boxes.append(pos)

    return (m,n,time, boxes, drawers)

def hard_instance(limit=9):
    
    random.seed()
    m = abs(int(limit * random.gauss(0.5, 0.5))) + int(limit/2)
    n = abs(int(limit * random.gauss(0.5, 0.5))) + int(limit/2)
    time = 15

    m = min(m, limit)
    n = min(n, limit)

    drawer_number = random.randint(3, int(min(m, n)/2+2))
    drawers = []

    for i in range(drawer_number):
        pos = place_drawers(m, n, drawers)
        if pos is not None:
            drawers.append(pos)

    box_number = random.randint(2, int(drawer_number+limit/2)+1)
    boxes = []

    for i in range(box_number):
        pos = place_boxes(m, n, boxes, drawers)
        boxes.append(pos)

    return (m, n, time, boxes, drawers)

# Tries to place a box in a position (x,y), 0<=x<m-1 and 0<=y<=n-1
# No position is returned if all attempts result in an overlapping
def place_boxes(m, n, placed_boxes, placed_drawers):

    box_x = random.randint(1, m-1)
    box_y = random.randint(1, n-1)

    while check_overlappings(box_x, box_y, placed_boxes, placed_drawers):
        box_x = random.randint(1, m-1)
        box_y = random.randint(1, n-1)
    
    return (box_x, box_y)

# Tries to place a drawer in a position (x,y), 0<=x<m-1 and 0<=y<=n-1
# No position is returned if all attempts result in an overlapping
def place_drawers(m, n, placed_drawers, attempts = 5):

    drawer_x = random.randint(0, m-2)
    drawer_y = random.randint(0, n-2)

    # When placing boxes we need to check more possible overlapping positions
    while (check_overlappings(drawer_x, drawer_y, None, placed_drawers) or
           check_overlappings(drawer_x+1, drawer_y, None, placed_drawers) or
           check_overlappings(drawer_x, drawer_y+1, None, placed_drawers) or 
           check_overlappings(drawer_x+1, drawer_y+1, None, placed_drawers)) and attempts > 0:
        drawer_x = random.randint(0, m-2)
        drawer_y = random.randint(0, n-2)
        attempts -= 1
    
    if attempts == 0:
        return None
    
    return (drawer_x, drawer_y)

# Checks whether a box in position (x,y) overlaps with another box or a drawer
def check_overlappings(x, y, boxes, drawers):
    
    res = []

    # Filter boxes that do not overlap
    if boxes is not None:
        res += list(filter(lambda el: el[0] == x and el[1] == y, boxes))

    # Expand all drawers positions and filter all drawers that do not overlap
    if drawers is not None:
        occupied_cells = drawers.copy()
        occupied_cells += list(map(lambda el: (el[0]+1, el[1]), drawers))
        occupied_cells += list(map(lambda el: (el[0], el[1]+1), drawers))
        occupied_cells += list(map(lambda el: (el[0]+1, el[1]+1), drawers))
        res += list(filter(lambda el: el[0] == x and el[1] == y, occupied_cells))

    # If res is not empty there are overlappings
    return res != []


# Saves an instance in the specified path, using the specified filename
# It creates an ASP (.lp), a MiniZinc data (.dzn) and a JSON file

def save_instance(instance, name, path):

    m, n, time, boxes, drawers = instance

    if not os.path.exists(path):
        os.makedirs(path)

    file_name = os.path.join(path, name)

    with open(file_name+'.lp', 'w') as lp:
        
        lp.write(f'#const m={m}.\n')
        lp.write(f'#const n={n}.\n')
        lp.write(f'#const maxtime={time}.\n')
        
        for i, box in zip(range(len(boxes)), boxes):
            lp.write(f'box({i+1},{box[0]},{box[1]}).\n')

        for drawer in drawers:
            lp.write(f'drawer({drawer[0]},{drawer[1]}).\n')

        lp.close()

    with open(file_name+'.dzn', 'w') as mzn:

        mzn.write(f'm={m};\n')
        mzn.write(f'n={n};\n')
        mzn.write(f'maxtime={time};\n')
        mzn.write(f'boxNumber = {len(boxes)};\n')
        mzn.write(f'drawerNumber = {len(drawers)};\n')

        for i, box in zip(range(len(boxes)), boxes):
            mzn.write(
                f'constraint boxes[{i+1}, 0, 0] = {box[0]} /\ boxes[{i+1}, 0, 1] = {box[1]};\n'
            )

        drawer_array = ''
        if len(drawers) > 0:
            drawer_array += '|'
            for drawer in drawers:
                drawer_array += str(drawer[0]) + ',' + str(drawer[1]) + '|'

        mzn.write(
            f'drawers = array2d(1..drawerNumber, 0..1, [{drawer_array}]);\n'
        )
    
        mzn.close()

    json_dict = {
        'm': m,
        'n': n,
        'maxtime': time,
        'boxes': boxes,
        'drawers': drawers
    }
    with open(file_name+'.json', 'w') as json_file:
        json.dump(json_dict, json_file)


# Main function takes as parameters the difficulty of the instance to generate and the base filename to be created
# If -p is specified, the following parameter is treated as the destination path
def main():

    help_msg = 'Usage: python3 generate_instances.py (easy|medium|hard) filename [-p path]' 
    if len(sys.argv) <= 2:
        print(help_msg)
        return 1
    
    filename = sys.argv[2]
    path = sys.argv[4] if '-p' in sys.argv else '.'

    if 'easy' in sys.argv:
        ins = easy_instance()
    elif 'medium' in sys.argv:
        ins = medium_instance()
    elif 'hard' in sys.argv:
        ins = hard_instance()
    else:
        print(help_msg)
        return 1
    
    save_instance(ins, filename, path)

    return 0

if __name__ == '__main__':
    main()