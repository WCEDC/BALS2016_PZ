# 执行 makepz.pl 即可
# 注释部分

PZ 文件的注释部分，和台站的实际情况不冲突即可，试验结果是不冲突，sac 就不报错，而且确实做了去卷积

因为不清楚物理意义，所以不确定如下注释信息是否关键：
````
    * INPUT UNIT        : M
    * OUTPUT UNIT       : COUNTS
    * INSTTYPE          : JCZ-1H/VBB Seismometer
    * INSTGAIN          : 1.668130e+03 (M/S)
    * COMMENT           : N/A
    * SENSITIVITY       : 1.049800e+09 (M/S)
    * A0                : 2.420600e+20
````
# 零点部分：

sensor 的 Complex zeroes 再加一行 0.0 0.0

# 极点部分：

sensor 的 Complex poles

# constant

constant = sensor的A0 × sensor的stage0里面的sensitivity × dataloggerr的stage0里面的sensitivity
