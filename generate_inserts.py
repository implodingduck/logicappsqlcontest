import random 

for i in range(100):
    print(f'INSERT INTO multiplication (multiplier, multiplicand) VALUES ({random.randint(1,100)}, {random.randint(1,100)});')