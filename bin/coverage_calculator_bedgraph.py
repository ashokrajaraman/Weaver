import sys

total_len = 0
total_cov = 0


with open(sys.argv[1]) as bedfile:
    for line in bedfile:
        data = [x for x in line.strip().split('\t')[1:]]
        #if 'G' in data[0]:
        #    continue
        curr_len = abs(int(data[1])-int(data[0]))
        curr_cov = abs(float(data[-1]))
        total_cov += curr_len*curr_cov
        total_len += curr_len

print(total_cov/total_len)
