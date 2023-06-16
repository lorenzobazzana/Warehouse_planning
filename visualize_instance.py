import json
import sys

######
# Code for instance visualization, using some basic ASCII characters
######

def print_instance(instance):
    m = instance['m']
    n = instance['n']
    boxes = instance['boxes']
    drawers = instance['drawers']

    print(f'm={m}')
    print(f'n={n}')
    print(f'boxes:{boxes}')
    print(f'drawers:{drawers}')

    print('   +', end='')
    for j in range(m):
        print('--', end='')
    print('+')

    for i in range(n-1, -1, -1):
        
        print(f'{i:<3d}|', end='')
        
        for j in range(m):
            print(object_on_cell(j, i, boxes, drawers), end='')
        
        if i == n-1:
            print(' ')
        else: 
            print('|')


    print('   +', end='')
    for j in range(m):
        print('--', end='')
    print('+')

    print('    ', end='')
    for j in range(m):
        print(f'{j} ', end='')
    
    print()


def object_on_cell(x, y, boxes, drawers):
    
    box = list(filter(lambda el: el[0] == x and el[1] == y, boxes))
    drawer = list(filter(lambda el: el[0] == x and el[1] == y or el[0] == x-1 and el[1] == y or el[0] == x and el[1] == y-1 or el[0] == x-1 and el[1] == y-1, drawers))
    
    if box != []:
        return 'oo'
    elif drawer != []:
        return 'xx'
    else:
        return '  '


def main():

    try: 
        # Input file must be in JSON format
        file = sys.argv[1]
        f = open(file)
        instance = json.load(f)
    except:
        print("Error in opening file!")
        return 1
    
    print_instance(instance)
    f.close()

if __name__ == '__main__':
    main()
