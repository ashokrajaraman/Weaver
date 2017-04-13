import sys

total_len = 0
total_cov = 0.


with open(sys.argv[1]) as bedfile:
    for line in bedfile:
        data = line.strip().split('\t')
        #if 'G' in data[0]:
        #    continue
        details  = [x for x in map(float, data[1:])]
        curr_len = abs(int(details[1])-int(details[2]))
        curr_cov = abs(details[-1])
        total_cov += curr_len*curr_cov
        total_len += curr_len

print(total_cov/total_len)
