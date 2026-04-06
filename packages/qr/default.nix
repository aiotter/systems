{ writers, python3Packages }:

writers.writePython3Bin "qr" {
  libraries = with python3Packages; [
    pillow
    qrcode
  ];
} (builtins.readFile ./qr.py)
