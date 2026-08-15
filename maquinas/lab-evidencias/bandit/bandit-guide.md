# OverTheWire — Bandit Walkthrough (Levels 0–19)

**Autor: Juan David Rangel**

Complete walkthrough of the first 20 Bandit levels. Each section shows the goal, the command(s) used, the terminal output, an explanation, and the password for the next level.

**Connection basics**

```bash
ssh -p 2220 bandit<N>@bandit.labs.overthewire.org
```

On Windows with PuTTY:

```powershell
plink.exe -ssh -P 2220 -pw <PASSWORD> -hostkey "SHA256:C2ihUBV7ihnV1wUXRb4RrEcLfXC5CXlhmAAM/urerLY" -batch bandit<N>@bandit.labs.overthewire.org "<command>"
```

---

## Level 0 — First contact

**Goal:** log in and read the file `readme` in the home directory (password for `bandit0` is `bandit0`).

**Command**

```bash
cat readme
```

**Output**

```
Congratulations on your first steps into the bandit game!!
Please make sure you have read the rules at https://overthewire.org/rules/
If you are following a course, workshop, walkthrough or other educational activity,
please inform the instructor about the rules as well and encourage them to
contribute to the OverTheWire community so we can keep these games free!

The password you are looking for is: 6y2kwnwK6grgvwvpvLaa2T1cpFEKOhNR
```

**Explanation:** `cat` prints the content of a file to standard output. The home directory contains a single file named `readme` with the password for level 1.

**Password for bandit1:** `6y2kwnwK6grgvwvpvLaa2T1cpFEKOhNR`

---

## Level 1 — The file named `-`

**Goal:** read a file whose name is a single dash (`-`).

**Command**

```bash
cat ./-
```

**Output**

```
PK8fYLZg2hnHSz83plBL1iEPKdD3QToB
```

**Explanation:** A lone `-` is special to many tools: it means *standard input*. `cat -` would just wait for keyboard input. Prefixing the path with `./` forces `cat` to treat it as a real file in the current directory.

**Password for bandit2:** `PK8fYLZg2hnHSz83plBL1iEPKdD3QToB`

---

## Level 2 — Filename with spaces

**Goal:** read a file whose name contains spaces and starts with `--`.

**Command**

```bash
ls -la
cat -- '--spaces in this filename--'
```

**Output**

```
total 24
-rw-r-----   1 bandit3 bandit2   33 Jun 24 14:59 --spaces in this filename--
drwxr-xr-x   2 root    root    4096 Jun 24 14:59 .
drwxr-xr-x 150 root    root    4096 Jun 24 15:02 ..
-rw-r--r--   1 root    root     220 Feb 13 12:16 .bash_logout
-rw-r--r--   1 root    root    3851 Jun 24 14:50 .bashrc
-rw-r--r--   1 root    root     807 Feb 13 12:16 .profile
7ZZ2LFrykP2zEyvBl4m3clcL7tGYJPME
```

**Explanation:** Quotes group the spaces into a single argument. Because the name begins with `--`, `cat` would interpret it as an option flag; the `--` separator tells `cat` that everything after it is a file name, not an option.

**Password for bandit3:** `7ZZ2LFrykP2zEyvBl4m3clcL7tGYJPME`

---

## Level 3 — Hidden file

**Goal:** find and read a hidden file inside `inhere/`.

**Command**

```bash
ls -la inhere/
cat inhere/...Hiding-From-You
```

**Output**

```
total 12
drwxr-xr-x 2 root    root    4096 Jun 24 14:59 .
drwxr-xr-x 3 root    root    4096 Jun 24 14:59 ..
-rw-r----- 1 bandit4 bandit3   33 Jun 24 14:59 ...Hiding-From-You
xzTXq1rDJQVVAzdv5cHq1TQytTWufAMq
```

**Explanation:** Files starting with `.` are hidden from plain `ls`. The `-a` flag shows all files, including hidden ones. The file is named `...Hiding-From-You` (three dots), inside the `inhere` directory.

**Password for bandit4:** `xzTXq1rDJQVVAzdv5cHq1TQytTWufAMq`

---

## Level 4 — Human-readable file

**Goal:** find the only human-readable file among ten in `inhere/`.

**Command**

```bash
file inhere/*
cat inhere/-file07
```

**Output**

```
inhere/-file00: data
inhere/-file01: data
inhere/-file02: OpenPGP Secret Key
inhere/-file03: data
inhere/-file04: data
inhere/-file05: data
inhere/-file06: Non-ISO extended-ASCII text, with NEL line terminators
inhere/-file07: ASCII text
inhere/-file08: data
inhere/-file09: data
6C7h9GD8M6ai5nr7wo1RonrzFjj9yIrG
```

**Explanation:** `file` identifies the type of each file by inspecting its content (magic bytes), not its extension. `-file07` is the only one reported as plain `ASCII text`, so it is the one holding the password.

**Password for bandit5:** `6C7h9GD8M6ai5nr7wo1RonrzFjj9yIrG`

---

## Level 5 — Find by properties

**Goal:** locate a file that is 1033 bytes, is not executable, and sits somewhere under `inhere/`.

**Command**

```bash
find inhere/ -type f -size 1033c ! -executable
cat inhere/maybehere07/.file2
```

**Output**

```
inhere/maybehere07/.file2
pXa26xhMWaC2SvDotA4r9EgZkulOeSBW
```

**Explanation:** `find` walks the directory tree matching criteria: `-type f` (regular files), `-size 1033c` (exactly 1033 bytes, `c` = bytes), `! -executable` (negation of the executable bit). The only match is a hidden file deep inside the tree.

**Password for bandit6:** `pXa26xhMWaC2SvDotA4r9EgZkulOeSBW`

---

## Level 6 — Find anywhere

**Goal:** find a file owned by user `bandit7` and group `bandit6`, 33 bytes, anywhere on the system.

**Command**

```bash
F=$(find / -type f -user bandit7 -group bandit6 -size 33c 2>/dev/null)
echo "RUTA: $F"
cat $F
```

**Output**

```
RUTA: /var/lib/dpkg/info/bandit7.password
Bmnnvf82KzQlfxgAI2d1zYbr1u9pr3E3
```

**Explanation:** The search starts at `/` (whole filesystem). `-user` and `-group` filter by ownership. Permission errors for directories we cannot read are silenced with `2>/dev/null`. The password lives in a Debian package metadata file.

**Password for bandit7:** `Bmnnvf82KzQlfxgAI2d1zYbr1u9pr3E3`

---

## Level 7 — grep

**Goal:** find the line in `data.txt` next to the word `millionth`.

**Command**

```bash
grep millionth data.txt
```

**Output**

```
millionth	VR1ljMayciFxbnUokuQmJFw6QC9VKtub
```

**Explanation:** `grep` prints every line of `data.txt` that contains the pattern `millionth`. The password is the second field of that line.

**Password for bandit8:** `VR1ljMayciFxbnUokuQmJFw6QC9VKtub`

---

## Level 8 — The unique line

**Goal:** find the only line in `data.txt` that appears exactly once (all others are repeated).

**Command**

```bash
sort data.txt | uniq -u
```

**Output**

```
EjmOSvuAu7sGAHqHVcBDPirRe9T03kxl
```

**Explanation:** `sort` puts identical lines together; `uniq -u` prints only lines that occur once. The pipe (`|`) feeds the output of one command into the input of the next.

**Password for bandit9:** `EjmOSvuAu7sGAHqHVcBDPirRe9T03kxl`

---

## Level 9 — Strings

**Goal:** find the password inside a binary file.

**Command**

```bash
strings data.txt | grep '=='
```

**Output**

```
========== the
[==p+
========== password
Y========== is
========== B0s2khmbT9u0geKuOoVGW3JZKhndE3BG
```

**Explanation:** `strings` extracts printable character sequences from binary data. Piping through `grep '=='` keeps only the lines that look like password markers.

**Password for bandit10:** `B0s2khmbT9u0geKuOoVGW3JZKhndE3BG`

---

## Level 10 — base64

**Goal:** decode the file content.

**Command**

```bash
base64 -d data.txt
```

**Output**

```
The password is pYfOY6HwUsDj5rL9UvyhU7MCmv8vN5Ro
```

**Explanation:** `base64 -d` decodes base64-encoded data back to plain text. The file contains an encoded sentence with the password.

**Password for bandit11:** `pYfOY6HwUsDj5rL9UvyhU7MCmv8vN5Ro`

---

## Level 11 — ROT13

**Goal:** decode a Caesar cipher that shifts letters by 13 positions.

**Command**

```bash
tr 'A-Za-z' 'N-ZA-Mn-za-m' < data.txt
```

**Output**

```
The password is GROozWPO8QyN0mGrjUkID0WCYkZiQxrN
```

**Explanation:** `tr` translates characters from the first set to the second. `N-ZA-M` is `N O P ... Z A B C ... M`, i.e., every letter shifted 13 forward, which is exactly ROT13. Since ROT13 is applied twice it returns to the original, decoding and encoding use the same command.

**Password for bandit12:** `GROozWPO8QyN0mGrjUkID0WCYkZiQxrN`

---

## Level 12 — Compression chain

**Goal:** recover the password from a hex dump that, when reversed, reveals a file compressed repeatedly with different tools.

**Commands**

```bash
xxd -r data.txt > f0
file f0
gzip -dc f0 > f1
bzip2 -dc f1 > f2
gzip -dc f2 > f3
tar xf f3
tar xf data5.bin
bzip2 -dc data6.bin > f4
tar xf f4
gzip -dc data8.bin > f5
cat f5
```

**Output**

```
f0: gzip compressed data, was "data2.bin", ...
f1: bzip2 compressed data, block size = 900k
f2: gzip compressed data, was "data4.bin", ...
f3: POSIX tar archive (GNU)
data5.bin: POSIX tar archive (GNU)
data6.bin: bzip2 compressed data, block size = 900k
f4: POSIX tar archive (GNU)
== data5.bin: POSIX tar archive (GNU)
== data6.bin: bzip2 compressed data, block size = 900k
== data8.bin: gzip compressed data, was "data9.bin", ...
f5: ASCII text
The password is qQYQiHOBPR8zR61qxYqX45quvihF2uzk
```

**Explanation:** `xxd -r` reverses a hex dump into binary. Then a loop of `file` + decompress is needed: `gzip -dc` (d = decompress, c = stdout), `bzip2 -dc`, and `tar xf` (extract file). Each `file` call tells which tool comes next. The chain is: hex → gzip → bzip2 → gzip → tar → tar → bzip2 → tar → gzip → ASCII.

**Password for bandit13:** `qQYQiHOBPR8zR61qxYqX45quvihF2uzk`

---

## Level 13 — SSH private key

**Goal:** use the private key `sshkey.private` to log in as `bandit14` and read its password.

**Commands**

```bash
ls -la sshkey.private
# copy the key to your machine, then from local:
ssh -i sshkey.private -p 2220 bandit14@bandit.labs.overthewire.org
cat /etc/bandit_pass/bandit14
```

**Output**

```
-rw-r----- 1 bandit14 bandit13 2602 Jun 24 14:58 sshkey.private
...
backend: gibson-1
aaWecNkG4FhxJQxz07uiwzVP6bJiYS65
```

**Explanation:** The file is an SSH private key owned by `bandit14`. `ssh -i` selects that key instead of a password. The key must have restrictive permissions (0600/0640) or OpenSSH refuses to use it. Note: connecting to `localhost` from inside the game server is blocked; use the key from your own machine against the game host.

**Password for bandit14:** `aaWecNkG4FhxJQxz07uiwzVP6bJiYS65`

---

## Level 14 — Netcat

**Goal:** send the current password to a service listening on port `30000` of localhost.

**Command**

```bash
echo 'aaWecNkG4FhxJQxz07uiwzVP6bJiYS65' | nc localhost 30000
```

**Output**

```
Correct!
pbLYuZtTg4MgaqfJx8jbA9gKKGqM68A7
```

**Explanation:** `nc` (netcat) opens a raw TCP connection to `localhost:30000`. `echo` pipes the password into the connection, and the service replies with the next password.

**Password for bandit15:** `pbLYuZtTg4MgaqfJx8jbA9gKKGqM68A7`

---

## Level 15 — SSL/TLS service

**Goal:** send the password to the TLS-protected service on port `30001`.

**Command**

```bash
echo 'pbLYuZtTg4MgaqfJx8jbA9gKKGqM68A7' | openssl s_client -connect localhost:30001 -quiet
```

**Output**

```
Correct!
kS0Hf0u5HiXFwKMKFqXvPdOTNGGa0X8V
```

**Explanation:** `openssl s_client` is an SSL/TLS test client. `-quiet` suppresses the certificate chatter. The plaintext password goes through the encrypted channel and the service answers with the next password.

**Password for bandit16:** `kS0Hf0u5HiXFwKMKFqXvPdOTNGGa0X8V`

---

## Level 16 — Port scan + TLS

**Goal:** find the SSL service among ports `31000`–`32000` that, given the password, returns the next level's private key.

**Commands**

```bash
nmap -p 31000-32000 localhost
# for each open port:
echo '<password>' | openssl s_client -connect localhost:<PORT> -quiet
```

**Output**

```
PORT      STATE SERVICE
31046/tcp open  unknown
31518/tcp open  unknown
31691/tcp open  unknown
31790/tcp open  unknown
31960/tcp open  unknown

--- PORT 31790
Correct!
-----BEGIN OPENSSH PRIVATE KEY-----
...
```

**Explanation:** `nmap -p` scans the port range and reveals five open ports. Most are either not TLS or just echo. Port `31790` answers `Correct!` and returns an OpenSSH private key for `bandit17` — same technique as Level 13 to retrieve the password.

**Password for bandit17:** `pWXMAZoxGC8JmDMfmT5MGEsobMM3vnj2`

---

## Level 17 — diff

**Goal:** find the only line that changed between `passwords.old` and `passwords.new`.

**Command**

```bash
diff passwords.old passwords.new
```

**Output**

```
42c42
< qOg5pVOjPx9x9VccyYBADiT4xxyoUB8D
---
> OQxXZjELndr90zuhOTDYBEomI0SZITXI
```

**Explanation:** `diff` shows the differences line by line. `42c42` means line 42 changed; `<` is the old content, `>` is the new content. The password is the line present only in `passwords.new`.

**Password for bandit18:** `OQxXZjELndr90zuhOTDYBEomI0SZITXI`

---

## Level 18 — Logged out immediately

**Goal:** read `readme` even though the shell logs you out right after login.

**Command**

```bash
# non-interactive: pass the command directly to ssh
ssh -p 2220 bandit18@bandit.labs.overthewire.org "cat readme"
```

**Output**

```
KpsOfPkcP7i1FlIExk2QEjyt6dw8dxZI
```

**Explanation:** The account's shell is configured to print a logout message and exit immediately, so an interactive session closes at once. By passing the command as an argument to `ssh`, the remote command runs before the shell can exit.

**Password for bandit19:** `KpsOfPkcP7i1FlIExk2QEjyt6dw8dxZI`

---

## Level 19 — setuid binary

**Goal:** run a setuid binary that executes commands as `bandit20`.

**Commands**

```bash
ls -la
file bandit20-do
./bandit20-do cat /etc/bandit_pass/bandit20
```

**Output**

```
-rwsr-x---   1 bandit20 bandit19 14880 Jun 24 14:58 bandit20-do
bandit20-do: setuid ELF 32-bit LSB executable, Intel i386, ...
4pIjcunZ0fK2vmp3IwfG8Vf7VhxD6pOA
```

**Explanation:** The `s` in `-rwsr-x---` means *setuid*: the binary runs with the effective user ID of its owner (`bandit20`) regardless of who invokes it. `bandit20-do` executes whatever command it receives as `bandit20`, so asking it to `cat` the password file for `bandit20` works.

**Password for bandit20:** `4pIjcunZ0fK2vmp3IwfG8Vf7VhxD6pOA`

---

## Summary of passwords

| Level | Password for next level |
| --- | --- |
| 0 | `6y2kwnwK6grgvwvpvLaa2T1cpFEKOhNR` |
| 1 | `PK8fYLZg2hnHSz83plBL1iEPKdD3QToB` |
| 2 | `7ZZ2LFrykP2zEyvBl4m3clcL7tGYJPME` |
| 3 | `xzTXq1rDJQVVAzdv5cHq1TQytTWufAMq` |
| 4 | `6C7h9GD8M6ai5nr7wo1RonrzFjj9yIrG` |
| 5 | `pXa26xhMWaC2SvDotA4r9EgZkulOeSBW` |
| 6 | `Bmnnvf82KzQlfxgAI2d1zYbr1u9pr3E3` |
| 7 | `VR1ljMayciFxbnUokuQmJFw6QC9VKtub` |
| 8 | `EjmOSvuAu7sGAHqHVcBDPirRe9T03kxl` |
| 9 | `B0s2khmbT9u0geKuOoVGW3JZKhndE3BG` |
| 10 | `pYfOY6HwUsDj5rL9UvyhU7MCmv8vN5Ro` |
| 11 | `GROozWPO8QyN0mGrjUkID0WCYkZiQxrN` |
| 12 | `qQYQiHOBPR8zR61qxYqX45quvihF2uzk` |
| 13 | `aaWecNkG4FhxJQxz07uiwzVP6bJiYS65` |
| 14 | `pbLYuZtTg4MgaqfJx8jbA9gKKGqM68A7` |
| 15 | `kS0Hf0u5HiXFwKMKFqXvPdOTNGGa0X8V` |
| 16 | `pWXMAZoxGC8JmDMfmT5MGEsobMM3vnj2` |
| 17 | `OQxXZjELndr90zuhOTDYBEomI0SZITXI` |
| 18 | `KpsOfPkcP7i1FlIExk2QEjyt6dw8dxZI` |
| 19 | `4pIjcunZ0fK2vmp3IwfG8Vf7VhxD6pOA` |
