import random

def easy_instance(limit=5):
    
    random.seed()
    m = abs(int(limit * random.gauss(0, 0.5))) + limit
    n = abs(int(limit * random.gauss(0, 0.5))) + limit

    drawer_number = random.randint(0, int(min(m, n)/2))
    drawers = []

    for i in range(drawer_number):
        pos = place_drawers(m, n, drawers)
        if pos is not None:
            drawers.append(pos)

    box_number = random.randint(1, int(drawer_number+limit/2))
    boxes = []

    for i in range(box_number):
        pos = place_boxes(m, n, boxes, drawers)
        boxes.append(pos)

    return (m,n,boxes, drawers)

def place_boxes(m, n, placed_boxes, placed_drawers):

    box_x = random.randint(0, m-1)
    box_y = random.randint(0, n-1)

    while check_overlappings(box_x, box_y, placed_boxes, placed_drawers):
        box_x = random.randint(0, m-1)
        box_y = random.randint(0, n-1)
    
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

    
def main():
    print(easy_instance())

if __name__ == '__main__':
    main()