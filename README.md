# SOC-Homomorphic_Encryption_for_k-NN-_on_the_cloud
# Project

This project is an implementation of [paper](https://www.sciencedirect.com/science/article/abs/pii/S0743731515002105)

## How to run

If sage is not installed, [look_here](https://doc.sagemath.org/html/en/installation/index.html)

### Files
There are four files data_gen.py, cloud_server.sage, data_owner.sage, query_user.sage
### Commands  to be run (in the same order)


```bash
python3 data_gen.py > database.txt
```
```bash
sage data_owner.sage
```
```bash
sage cloud_server.sage
```
```bash
sage query_user.sage
```
### Output model and inputs to be given
The cloud server will ask for "k" the number of nearest indices to be sent to query_user and the latter will print this indices.
### Common errors 
Socket Already in use a common error that occurs while running data_owner.sage or cloud_server.sage.Simply change the Socket numbers in the required codes.
Sometimes data_owner.sage shows another error due to other sockets running and unusal transer of data, kindly restart the running process again.
### Regarding query list input
In the code of query_user.sage, I've generated random numbers in range [0,10], if you want to give it as input, please, open quer_user.py and go to 136 and 137 line of the code and replace the lines with "integers = [1,5,..(50 elements)]" try to keep the elements in range [1,10] for better results.
