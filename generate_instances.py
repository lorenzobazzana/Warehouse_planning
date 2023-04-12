import json
import os
import random

def easy_instance(limit=5):
    
    random.seed()
    m = limit - random.randint(-1, 1) 
    n = limit - random.randint(-1, 1)

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

    return (m,n,boxes, drawers)

def hard_instance(limit=7):
    
    random.seed()
    m = abs(int(limit * random.gauss(0.5, 0.5))) + int(limit/2)
    n = abs(int(limit * random.gauss(0.5, 0.5))) + int(limit/2)

    m = min(m, 8)
    n = min(n, 8)

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

    return (m,n,boxes, drawers)

def place_boxes(m, n, placed_boxes, placed_drawers):

    box_x = random.randint(1, m-1)
    box_y = random.randint(1, n-1)

    while check_overlappings(box_x, box_y, placed_boxes, placed_drawers):
        box_x = random.randint(1, m-1)
        box_y = random.randint(1, n-1)
    
    return (box_x, box_y)


def place_drawers(m, n, placed_drawers, attempts = 5):

    drawer_x = random.randint(0, m-2)
    drawer_y = random.randint(0, n-2)

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

def check_overlappings(x, y, boxes, drawers):
    
    res = []

    if boxes is not None:
        res += list(filter(lambda el: el[0] == x and el[1] == y, boxes))

    if drawers is not None:
        occupied_cells = drawers.copy()
        occupied_cells += list(map(lambda el: (el[0]+1, el[1]), drawers))
        occupied_cells += list(map(lambda el: (el[0], el[1]+1), drawers))
        occupied_cells += list(map(lambda el: (el[0]+1, el[1]+1), drawers))
        res += list(filter(lambda el: el[0] == x and el[1] == y, occupied_cells))

    return res != []


def save_instance(instance, name, path):

    m, n, boxes, drawers = instance

    if not os.path.exists(path):
        os.makedirs(path)

    file_name = os.path.join(path, name)

    with open(file_name+'.lp', 'w') as lp:
        
        lp.write(f'#const m={m}.\n')
        lp.write(f'#const n={n}.\n')
        
        for i, box in zip(range(len(boxes)), boxes):
            lp.write(f'box({i+1},{box[0]},{box[1]}).\n')

        for drawer in drawers:
            lp.write(f'drawer({drawer[0]},{drawer[1]}).\n')

        lp.close()

    with open(file_name+'.mzn', 'w') as mzn:

        mzn.write(f'm={m};\n')
        mzn.write(f'n={n};\n')
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
        'boxes': boxes,
        'drawers': drawers
    }
    with open(file_name+'.json', 'w') as json_file:
        json.dump(json_dict, json_file)

def main():
    ins = easy_instance()
    save_instance(ins, 'a', 'Instances/Easy')
    ins = hard_instance()
    save_instance(ins, 'a', 'Instances/Medium')

if __name__ == '__main__':
    main()