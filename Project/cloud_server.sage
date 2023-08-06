#importing all dependencies
import socket
import numpy as np
import pickle
from fractions import Fraction
#function to find n smallest numbers
def find_indices_of_n_smallest(lst, n):
    if not lst or n <= 0:
        return []

    # Create a list of tuples containing the value and index for each element in the input list
    indexed_lst = [(value, index) for index, value in enumerate(lst)]

    # Sort the indexed list based on the value (ascending order)
    indexed_lst.sort(key=lambda x: x[0])

    # Extract the indices of the n smallest elements from the sorted indexed list
    n_smallest_indices = [index for value, index in indexed_lst[:n]]

    return n_smallest_indices
#creating a socket
r = socket.socket()
print('Socket created')
r.bind(('localhost', 9941))
r.listen()
print('Waiting for connection')
demiliter = '|'
#used to convert a list to a string by appending it between two elements
while True:
    d, addr = r.accept()
    print("Connected with", addr)
    received_data = ""
    #Receiving data 
    while True:
        data_chunk = d.recv(999999).decode()  # Receive data in chunks of 1024 bytes
        if not data_chunk:
            break  

        received_data += data_chunk  
    break
d.close()
#splitting the dqta into a list of strings by removing the delimiter
data_list = received_data.split("|")
ln = len(data_list)
lnr = ln / 10000  
#converting string elements to integers 
P = [[0.0 for _ in range(int(lnr))] for _ in range(ln // int(lnr))]  # Use int() to convert lnr to integer
#converting int to Fraction to ease the calculation
for i in range(ln):
    P[int(i / lnr)][int(i % lnr)] = Fraction(data_list[i])

 
#creating another socket to receive data   
z = socket.socket()
print('Socket created')
z.bind(('localhost', 9935))
z.listen()
print('Waiting for connection')
while True:
    f, addr = z.accept()
    print("Connected with", addr)
    received_data1 = ""

    while True:
        data_chunk = f.recv(999999).decode()  # Receive data in chunks of 1024 bytes
        if not data_chunk:
            break  

        received_data1 += data_chunk  
    break
# Split the string using the delimiter "|"
data_list = received_data1.split("|")
l = len(data_list)
for i in range(l):
    data_list[i] = Fraction(data_list[i])
#the data received is q_ (A_q decrypted)
G = []
h = 0
for i in range(10000):
    if i != 0 :
        G.append(h)
        h = 0
    for j in range(l):
        h += (P[i][j])*(data_list[j])
#this is the input for the number of nearest neighbours to be output
k = int(input("Enter k (no of nearest neighbours required): "))
query_index = find_indices_of_n_smallest(G, k)

f.close()
z = socket.socket()
print('Socket created')
z.bind(('localhost', 9936))
z.listen()
print('Waiting for connection')
while True:
    f, addr = z.accept()
    print("Connected with", addr)
    data = pickle.dumps(query_index)
    f.send(data)
    break
f.close()


