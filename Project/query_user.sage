import math, random
import sage.all
import numpy as np
from sympy import mod_inverse
import socket
import json
import pickle
import time

def isPrimeTrialDiv(num):
    # Returns True if num is a prime number, otherwise False.
    # Uses the trial division algorithm for testing primality.

    # All numbers less than 2 are not prime:
    if num < 2:
        return False

    # See if num is divisible by any number up to the square root of num:
    for i in range(2, int(math.sqrt(num)) + 1):
        if num % i == 0:
            return False
    return True


def primeSieve(sieveSize):
    # Returns a list of prime numbers calculated using the Sieve of Eratosthenes algorithm.

    sieve = [True] * sieveSize
    sieve[0] = False # Zero and one are not prime numbers.
    sieve[1] = False

    # Create the sieve:
    for i in range(2, int(math.sqrt(sieveSize)) + 1):
        pointer = i * 2
        while pointer < sieveSize:
            sieve[pointer] = False
            pointer += i

    # Compile the list of primes:
    primes = []
    for i in range(sieveSize):
        if sieve[i] == True:
            primes.append(i)

    return primes

def rabinMiller(num):
    # Returns True if num is a prime number.
    if num % 2 == 0 or num < 2:
        return False # Rabin-Miller doesn't work on even integers.
    if num == 3:
        return True
    s = num - 1
    t = 0
    while s % 2 == 0:
        # Keep halving s until it is odd (and use t
        # to count how many times we halve s):
        s = s // 2
        t += 1
    for trials in range(5): # Try to falsify num's primality 5 times.
        a = random.randrange(2, num - 1)
        v = pow(a, s, num)
        if v != 1: # This test does not apply if v is 1.
            i = 0
            while v != (num - 1):
                if i == t - 1:
                    return False
                else:
                    i = i + 1
                    v = (v ** 2) % num
    return True

# Most of the time we can quickly determine if num is not prime
# by dividing by the first few dozen prime numbers. This is quicker
# than rabinMiller() but does not detect all composites.
LOW_PRIMES = primeSieve(100)

def isPrime(num):
    # Return True if num is a prime number. This function does a quicker
    # prime number check before calling rabinMiller().
    if num < 2:
        return False # 0, 1, and negative numbers are not prime.
    # See if any of the low prime numbers can divide num:
    for prime in LOW_PRIMES:
        if num == prime:
            return True
        if num % prime == 0:
            return False
    # If all else fails, call rabinMiller() to determine if num is prime:
    return rabinMiller(num)

def generateLargePrime(keysize=1024):
    # Return a random prime number that is keysize bits in size:
    while True:
        num = random.randrange(2**(keysize-1), 2**(keysize))
        if isPrime(num):
            return num
#function to find L(x-1/n)
def L_(x,n):
    L = (x-1)/n
    return L
    
def repeated_squaring(base, exponent, modulus):
    result = 1
    binary_exponent = bin(exponent)[2:]
    for bit in reversed(binary_exponent):
        if bit == '1':
            result = (result * base) % modulus
        base = (base * base) % modulus

    return result
ready0 = True
#implementation of paillier Encryption starts here
while ready0:

    ready = True
    while(ready):
        p = generateLargePrime()
        q = generateLargePrime()
        if sage.all.gcd(p*q,(p-1)*(q-1)) ==1:
            ready = False


    n = p*q
    g = sage.all.randint(1, n**2)
    lamda = sage.all.lcm(p-1,q-1)

    x = repeated_squaring(g,lamda,n**2)
    x = L_(x,n)
    try:
        
        mu = mod_inverse(x,n)
        ready0 = False
    except:
        print("Processing..")
query_point = np.random.uniform(1, 11, size=50)
integers = query_point.astype(int)
coordinates_str = ' '.join(map(str, integers))
coordinates_list = coordinates_str.split()
r = sage.all.randint(1,n)
Encrypted_list = []
#data encryption process
for i in range(50):

    c1 = repeated_squaring(g,int(coordinates_list[i]),n**2)
    c2 = repeated_squaring(r,n,n**2)
    c = (c1*c2) % n**2
    Encrypted_list.append(c)

c = socket.socket()
c.connect(('localhost',9998))
#this delimiter is used to convert list to string and viceverse
delimiter = '|'
#data sending
while True: 
    data_to_send = str(n) + delimiter + str(g)
    c.send(bytes(data_to_send,'utf-8'))
    data = pickle.dumps(Encrypted_list)
    c.send(data)
    break

received_data = ""
#receiving data
while True:
    data_chunk = c.recv(1024000000).decode()  # Receive data in chunks of 1024 bytes
    if not data_chunk:
        break  

    received_data += data_chunk  
    

c.close()

#Initialising list to use later
A = []
Q = []
# Split the string using the delimiter "|"
data_list = received_data.split("|")
#converting data to int
ln = len(data_list)
for i in range(ln-1):
    A.append(int(data_list[i]))
    
#decrypting the elements in A
ln_of_A = len(A)
for i in range(ln_of_A):
    Q.append(L_(repeated_squaring(A[i],lamda,n**2),n)*mu %n)
ln_of_Q = len(Q)

f = socket.socket()

while True:
    try:
        f.connect(('localhost', 9935))
        break  # Connection successful, exit the loop
    except ConnectionRefusedError:
        print("Connection refused. Retrying in 1 second...")
        time.sleep(2)  # Wait for 1 second before retrying

print("Connected to server.")

delimiter = '|'
data = ""
#converting list to string to send 
for i in range(ln_of_Q): 
    if i == ln_of_Q - 1 :
        data += str(Q[i])
    else:
        data += str(Q[i]) + delimiter

data = data.encode('utf-8')  # Convert data to bytes
total_sent = 0
data_size = len(data)
#sending data
while total_sent < data_size:
    sent_bytes = f.send(data[total_sent:])
    total_sent += sent_bytes


f.close()
f = socket.socket()

while True:
    try:
        f.connect(('localhost', 9936))
        break  # Connection successful, exit the loop
    except ConnectionRefusedError:
        print("Connection refused. Retrying in 1 second...")
        time.sleep(2)  # Wait for 1 second before retrying

print("Connected to server.")
indices = pickle.loads(f.recv(9999999))
print(indices)
f.close()
