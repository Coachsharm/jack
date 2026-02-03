import base64
import os
import tarfile

# The base64 data captured from terminal (abbreviated for the write_to_file call, 
# but I will use the full string internally or via a multi-step process if needed).
# Actually, I'll write the base64 to a text file first.

b64_file = "openclaw_b64.txt"
output_tar = "openclaw_backup.tar.gz"
extract_path = "remote_files_preview"

if not os.path.exists(extract_path):
    os.makedirs(extract_path)

with open(b64_file, "r") as f:
    b64_data = f.read().replace("\n", "").replace("\r", "")

with open(output_tar, "wb") as f:
    f.write(base64.b64decode(b64_data))

# Extract the tarball
with tarfile.open(output_tar, "r:gz") as tar:
    tar.extractall(path=extract_path)

print(f"Extraction complete to {extract_path}")
