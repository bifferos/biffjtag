#!/usr/bin/env python3


from ftplib import FTP
from pathlib import Path

exe = Path("./biffjtag")
ftp = FTP("biffjtag")
ftp.login()
ftp.storbinary('STOR biffjtag', exe.open("rb"))
ftp.quit()
