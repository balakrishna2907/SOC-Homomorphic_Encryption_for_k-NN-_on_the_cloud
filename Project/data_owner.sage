import random
import numpy as np
import socket
import pickle  
import time  
import copy
#fuction to scramble data in alist based on a mapping
def scramble_with_mapping(original_array, mapping):
    n = len(original_array)
    if n != len(mapping):
        raise ValueError("Size of the original array and mapping should be the same.")
    
    scrambled_array = [0] * n
    
    for i in range(n):
        scrambled_array[mapping[i]] = original_array[i]
    
    return scrambled_array
#function to find magnitude of a vector
def magnitude(vector, d):
    mag = 0
    for i in range(d):
        mag += vector[i] * vector[i]
    return mag
#function that helps encrypting elements
def repeated_squaring(base, exponent, modulus):
    result = 1
    binary_exponent = bin(exponent)[2:]
    for bit in reversed(binary_exponent):
        if bit == '1':
            result = (result * base) % modulus
        base = (base * base) % modulus

    return result
d = 50
c_ = random.randint(1, 10)
e = random.randint(1, 10)
n = d + c_ + e + 1
bol = True
#finding a random matrix with non zero determinant
while bol:
    M = np.random.randint(0,5, size=(n, n))
    if np.linalg.det(M) != 0:
        bol = False
        break
M_inv = np.linalg.inv(M)
S_ = np.random.uniform(1, 5, size=(1, d + 1)).astype(float)  
t_ = np.random.uniform(1, 5, size=(1, c_)).astype(float)
S0 = np.round(S_, decimals=2)
t0 = np.round(t_, decimals=2)  
R_ = np.random.uniform(1, 5, size=(1, c_)).astype(float)
R0 = np.round(R_, decimals=2)
 
S = []
t = []
R = []
for i in range(d+1):
    S.append(S0[0,i])
for i in range(c_):
    t.append(t0[0,i]) 
for i in range(c_):
    R.append(R0[0,i])
for i in range(10000):
    vi_ = np.random.uniform(0, 5, size=(1, e)).astype(float)  # Convert vi elements to float
    v0 = np.round(vi_, decimals=2) 
    vi = []
    for j in range(e):
        vi.append(v0[0,j])
#until here lists are converted from 2d-1d and converted to float
    
file_path = "database.txt"
#reading the contents of file
with open(file_path, 'r') as file:
    p = []  # Initialize the list for p
    for i, line in enumerate(file, start=0):
        coordinates_str = line.strip()
        p_key = f"p{i}"
        globals()[p_key] = coordinates_str
        p.append(list(map(float, coordinates_str.split(','))))  # Convert coordinates to float and append to p
P = []
P_ = []

mapping = []
#finding scrampled P
for i in range(10000):
    h0 = []
    P_i = []
    P__i = []
    for j in range(d):
        h0_ = S[j] - 2 * p[i][j]
        h0.append(h0_)
    h1 = [int(S[d]) + magnitude(p[i], d)]
    h2 = list(t)
    h3 = list(vi)
    h4 = []  # Create an empty list h4
    h4.extend(h0)  # Add elements of h0 to h4
    h4.extend(h1)  # Add elements of h1 to h4
    h4.extend(h2)  # Add elements of h2 to h4
    h4.extend(h3)  # Add elements of h3 to h4
    
    P_i.extend(h4)  
    P.append(P_i)
    if i == 0:
        for k in range(n):
            mapping.append(k)

        random.shuffle(mapping)
        
    P__i.extend(scramble_with_mapping(P[i], mapping))
    P_.append(P__i)
    P_[i] = np.array(P_[i])  
    P_[i] = np.dot(P_[i], M_inv)  
#the scrambled P is ready as P_
s = socket.socket()
print('Socket Created')
s.bind(('localhost', 9998))
s.listen()
print('Waiting for connection')
delimiter = '|'


while True:
    c, addr = s.accept()
    print("Connected with", addr)
    recv_data = c.recv(80000).decode()
    n_str, g_str = recv_data.split(delimiter)

    n_ = int(n_str)
    g = int(g_str)
    # n_ and g are used for encrypting  
    r = random.randint(1,n)
    beta = random.randint(1,10)
    c1 = repeated_squaring(g,0,n_**2)
    c2 = repeated_squaring(r,n_,n_**2)
    E0 = (c1*c2) % n_**2
    
    A = []
    for i in range(n):
        A.append(copy.deepcopy(E0))
    Enc_data = pickle.loads(c.recv(8000000))
    #code snippent for finding A_q
    for i in range(n):
        A[i] = E0
        
        for j in range(n):
            for rs in range(len(mapping)):
                if mapping[rs] == j:
                    t = rs
                    
                    break
            if t < d:
                phi = int(beta*int(M[i][j]))
                A[i] = A[i]*(Enc_data[t]**phi)
                
            elif t == d:
                phi = int(beta*int(M[i][j]))
                c1 = repeated_squaring(g,phi,n_**2)
                r = random.randint(1,10)
                c2 = repeated_squaring(r,n_,n_**2)
                Enc_phi = (c1*c2) % n_**2
                A[i] = A[i]*Enc_phi
                
            elif t <= d+c_:
                w = t-d-2
                phi = int(beta*int(M[i][j])*R[w])
                c1 = repeated_squaring(g,phi,n_**2)
                r = random.randint(1,10)
                c2 = repeated_squaring(r,n_,n_**2)
                Enc_phi = (c1*c2) % n_**2
                A[i] = A[i]*Enc_phi        
        break
    break
#sending A_q
data = ""
for i in range(n):
    if i == n-1:
        data += str(A[i])
    data += str(A[i]) + delimiter
data = data.encode('utf-8')  # Convert data to bytes
total_sent = 0
data_size = len(data)

while total_sent < data_size:
    sent_bytes = c.send(data[total_sent:])
    total_sent += sent_bytes


c.close() 
     
d = socket.socket()
d.connect(('localhost',9941))
#sending P_ to cloud server
while True:
    data = ""
    for i in range(10000):
        for j in range(n):
            if i == 10000-1 and j == n-1:
                data += str(P_[i][j])
            else:
                data += str(P_[i][j]) + delimiter
    data = data.encode('utf-8')  # Convert data to bytes
    total_sent = 0
    data_size = len(data)

    while total_sent < data_size:
        sent_bytes = d.send(data[total_sent:])
        total_sent += sent_bytes

        break
    break
d.close()
