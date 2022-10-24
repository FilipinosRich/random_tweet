import os
import shutil
import sys
import zipfile
torch_dir = '/tmp/torch'
# append the torch_dir to PATH so python can find it
sys.path.append(torch_dir)
if not os.path.exists(torch_dir):
   tempdir = '/tmp/_torch'
   if os.path.exists(tempdir):
       shutil.rmtree(tempdir)
   zipfile.ZipFile('torch.zip', 'r').extractall(tempdir)
   os.rename(tempdir, torch_dir)