import numpy as np

# Step 1: Define the dimension of the point
d = 50
for i in range(10000):
# Step 2: Generate a random d-dimensional point with coordinates in the range [-10, 10]
    
    random_point = np.random.uniform(-10, 11, size=d)
    
    integers = random_point.astype(int)
    coordinates_str = ','.join(map(str, integers))
    print(coordinates_str)




