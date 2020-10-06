# NoCDebug
## Signal Selection and Trigger generation

## NOC properties

4x4 Mesh network with mor1k processors.
![4x4 mesh](https://www.researchgate.net/profile/Dananjayan_Perumal/publication/314160525/figure/fig2/AS:584830785953794@1516445933914/4x4-mesh-topology-of-NoC.png)

## Experiment

All the IPs except Core 10 passes three messeges to Core 10.

## Trace format
### Flit buffer related trace (wr/rd)
Trace format flit buffer (32bit) : [ TID (4bit)| Hashed flit (din/dout) (15bit) | WR | RD | DEPTH (3bit) | WR_PTR (2bit) | WR_PTR_NEXT (2bit)  | RD_PTR (2bit) | RD_PTR_NEXT (2bit) ] 

#### note : removed modules
bus_arbiter, 
sw_alloc_sub2, 
spec_sw_alloc_sub2, 
sw_alloc_sub,
packet_gen,
wrra,
my_one_hot_arbiter_ext_priority