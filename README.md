AANanopore
======

### ![image-20221023143755799](./workflow.png)Description

[AANanopore](https://github.com/LuChenLab/AANanoporeR.git) is an open source R package for the signal processing, feature extraction, and prediction of amino acids nanopore signals. The original input file is .ABF file containing the current value of amino acids nanopore signals collected by Clampex software. In this package, the functions `CurrentPolish`, `LevelIdentify`, `SignalExtract`, `FeatureExtract`, and `Predict` can be used to process and predict the signals.

### Installation  

First, we need to install `devtools`:  

```R
install.packages("devtools")
library(devtools)
```

Then we just call  

```R
install_github("LuChenLab/AANanoporeR")
library(AANanopore)
```

### Examples

##### Step1: Read and polish the raw current signal

First, we need to read and polish the raw current signal from the ABF file using `CurrentPolish` function:

```R
File <- file.path("/File/Path/To/ABF/File")
abf <- CurrentPolish(file = File, TimeStart = 0, TimeEnd = 4.75)
```

##### Step2 (optional): Identify the base line (L0) and blockade signal (L1) of amino acids signals

If the range of L0 (base line) and L1 (blockade signal) of ABF file is unknown, the function `LevelIdentify` can be used to identify:

```R
L01 <- LevelIdentify(object = abf, L0Min = NA, L0Max = NA, L1Min = NA, L1Max = NA)
```

<img src="./inst/LevelIdentify.png" alt="image-20221023150732736" style="zoom: 50%;" />

##### Step3: Extract signal events from original signals

After identify the signal level of ABF file, we can use `SignalExtract` function to extract the signal events:

```R
BUBs <- SignalExtract(object = abf, L0Min = L01$L0Min, L0Max = L01$L0Max, L1Min = L01$L1Min, L1Max = L01$L1Max)
```

Here, the object `BUBs` is a R list with signal events. Extracted signal can be illustrate by function `SigPlot`, the read line indicating the polished value of current signal.

```R
SigPlot(x = sample(BUBs, 1)[[1]])
```

<img src="./inst/SignalPlot.png" alt="image-20221023151808964" style="zoom:50%;" />

##### Ste4: Extract features od signal events for classifier training or amino acid prediction

Then, we can used function `FeatureExtract` to extract the features of each signal event for machine learning.

```
Fi <- FeatureExtract(sample(BUBs, 1)[[1]])
Fi
# X001   X002   X003   X004   X005   X006   X007   X008   X009   X010   X011   X012   X013 
# 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000 
# X014   X015   X016   X017   X018   X019   X020   X021   X022   X023   X024   X025   X026 
# 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000 
# X027   X028   X029   X030   X031   X032   X033   X034   X035   X036   X037   X038   X039 
# 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000 
# X040   X041   X042   X043   X044   X045   X046   X047   X048   X049   X050   X051   X052 
# 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000 
# X053   X054   X055   X056   X057   X058   X059   X060   X061   X062   X063   X064   X065 
# 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000 
# X066   X067   X068   X069   X070   X071   X072   X073   X074   X075   X076   X077   X078 
# 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000 
# X079   X080   X081   X082   X083   X084   X085   X086   X087   X088   X089   X090   X091 
# 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000 
# X092   X093   X094   X095   X096   X097   X098   X099   X100   X101   X102   X103   X104 
# 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000 
# X105   X106   X107   X108   X109   X110   X111   X112   X113   X114   X115   X116   X117 
# 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000 
# X118   X119   X120   X121   X122   X123   X124   X125   X126   X127   X128   X129   X130 
# 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000 
# X131   X132   X133   X134   X135   X136   X137   X138   X139   X140   X141   X142   X143 
# 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000 
# X144   X145   X146   X147   X148   X149   X150   X151   X152   X153   X154   X155   X156 
# 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000 
# X157   X158   X159   X160   X161   X162   X163   X164   X165   X166   X167   X168   X169 
# 0.000  0.000  0.000  0.000  0.029  0.845  1.712  3.048 10.348 23.057 43.546 52.239 30.192 
# X170   X171   X172   X173   X174   X175   X176   X177   X178   X179   X180   X181   X182 
# 11.681  4.548  2.048  1.694  1.479  1.264  0.933  1.996  0.710  0.334  2.114  0.400  0.786 
# X183   X184   X185   X186   X187   X188   X189   X190   X191   X192   X193   X194   X195 
# 1.135  1.495  1.396  0.059  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000 
# X196   X197   X198   X199   X200 
# 0.000  0.000  0.000  0.000  0.000 
# attr(,"AllTime")
# [1] 2.02
# attr(,"DwellTime")
# [1] 2.02
# attr(,"SignalSD")
# [1] 0.005176076
# attr(,"Blockade")
# [1] 0.1619634
```

##### Step5: Predict amino acid

The signal event features of known amino acids can be used to train classifier or used to predict the amino acid type of new signal event. Here, we used our pre-trained random forest classifier to predict the `Fi`.

```
# Load the pre-trained random forest classifier 
data("SmallRF")
model
Predict(x = Fi, model = SmallRF)
#     A   R     N   D   Q   E   G   H   I   L     K   M   F   S     T   W   Y   V
# x   0   0 0.662   0   0   0   0   0   0   0 0.004   0   0   0 0.334   0   0   0
# attr(,"class")
# [1] "matrix" "array"  "votes" 
```

The result indicating that according our random forest classifier this signal event is N, and the probability is 0.662. 


### References
