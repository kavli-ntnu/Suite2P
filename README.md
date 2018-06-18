# KAVLI Suite2p

Forked from [Suite2p: fast, accurate and complete two-photon pipeline](https://github.com/cortex-lab/Suite2P) on 05.04.2018. Added [OASIS](https://github.com/zhoupc/OASIS_matlab) on same date. 
Algorithmic details in [http://biorxiv.org/content/early/2016/06/30/061507](http://biorxiv.org/content/early/2016/06/30/061507).
For **README** at time of fork check [README_Original](README_Original.md).

### Changes
Made independent of the original "forced" folder structure (Mouse/Date/) to be able to call .tif folders directly. If ``mouse_name`` does not exist in make_db, process with non-prefixed folder structure. 
**Careful!** Assumes now that the experiments all have the same number of green and red channels (within one data folder). 

**To do**: (1) Test 1-channel analysis, (2) red cell extraction and (3) normal suite2p folder structure.