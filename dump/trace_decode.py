# Python code to decode trace packets

# # Using readlines() 
# file1 = open('trace_dump.txt', 'r') 
# Lines = file1.readlines() 

# count = 0
# # Strips the newline character 
# for line in Lines: 
# 	print(line.strip()) 

# [ TID (4bit)| XXXXxx (15bit) | WR | RD | DEPTH (3bit) | WR_PTR (2bit) | WR_PTR_NEXT (2bit)  | RD_PTR (2bit) | RD_PTR_NEXT (2bit) ] 

import binascii

f = open("trace_dump.txt", "r")
f_csv= open("trace_decoded.csv","w")
f_csv.write("TID"+"," +"Flit_Hashed"+","+ "WR"+","+"RD"+","+" DEPTH"+","+ "WR_PTR"+","+" WR_PTR_NEXT" + ","+" RD_PTR"+ ","+" RD_PTR_NEXT"+ "\n")
#print(f.readline())
TID = ""
Flit_Hashed = ""
WR = ""
RD = ""
DEPTH = ""
WR_PTR = ""
WR_PTR_NEXT = ""
RD_PTR = ""
RD_PTR_NEXT = ""
for x in f:
    #print (x)
    # if (x_prew!=x):
	if (x[0]!='/'):
	# if (x[0:3]=='0001'):
		TID="flit-Wr"
		Flit_Hashed=x[4:18]
		WR =x[19]
		RD=x[20]
		DEPTH = x[21:23]
		WR_PTR = x[24:25]
		WR_PTR_NEXT = x[26:27]
		RD_PTR = x[28:29]
		RD_PTR_NEXT = x[30:31]
	# if (x[0:3]=='0010'):
	# 	TID="flit-RD"
	# 	Flit_Hashed=x[4:18]
	# 	WR =x[19]
	# 	RD=x[20]
	# 	DEPTH = x[21:23]
	# 	WR_PTR = x[24:25]
	# 	WR_PTR_NEXT = x[26:27]
	# 	RD_PTR = x[28:29]
	# 	RD_PTR_NEXT = x[30:31]
		# print ("src : ", (src_addr))
		# print ("dst : ", (dst_addr))
		# print ("Header")
	# 	Type = "Header"
	# 	Source = str(int(src_addr,2))
	# 	Destination = str(int(dst_addr,2))
	# 	Destination_port = str(int(dst_prt,2))
	# 	Data = ""
	# 	if (Ww!="xxxx"):
	# 		Weight = str(int(Ww,2))
	# 	else:
	# 		Weight = Ww
	# elif (x[1]=='1'):
	# 	packet = x[4:]
	# 	n = int(packet, 2)
	# 	# print ((str(binascii.unhexlify('%x' % n)))[2:-1])
	# 	# print ("Tail")
	# 	Type = "Tail"
	# 	Data = (str(binascii.unhexlify('%x' % n)))[2:-1]
	# else:
	# 	packet = x[4:]
	# 	n = int(packet, 2)
	# 	# print ((str(binascii.unhexlify('%x' % n)))[2:-1])
	# 	Type = "Data"
	# 	Data = (str(binascii.unhexlify('%x' % n)))[2:-1]

	f_csv.write(TID+","+ Flit_Hashed+","+ WR+","+RD+","+DEPTH+","+ WR_PTR+","+ WR_PTR_NEXT+","+ RD_PTR+","+ RD_PTR_NEXT+"\n")
    # x_prew=x
    # if (x[0]!='/' and x[4]!='x'):
    #     packet = x[4:]
    #     n = int(packet, 2)
    #     print ((str(binascii.unhexlify('%x' % n)))[2:-1])
print ("Conversion done, saved to 'trace_decode.csv' file")