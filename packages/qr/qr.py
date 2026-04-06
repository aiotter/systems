import argparse
import base64
import io
import itertools
import sys

import qrcode


def parse_args():
    parser = argparse.ArgumentParser(
        description=(
            "Generate a QR code for a URL and output it as "
            "Kitty graphics or PNG."
        )
    )

    output_group = parser.add_mutually_exclusive_group()
    output_group.add_argument(
        "--kitty",
        dest="output",
        action="store_const",
        const="kitty",
        help="render the QR code with Kitty Graphics Protocol",
    )
    output_group.add_argument(
        "--png",
        dest="output",
        action="store_const",
        const="png",
        help="write the QR code as PNG to stdout",
    )

    if sys.stdout.isatty():
        parser.set_defaults(output="kitty")
    else:
        parser.set_defaults(output="png")

    parser.add_argument(
        "content",
        nargs="?",
        help="content to encode in the QR code, or '-' to read from stdin",
    )

    return parser.parse_args()


def write_kitty_graphics(png_data):
    encoded_chunk_size = 4096
    raw_chunk_size = 3 * encoded_chunk_size // 4

    for (i, batch) in enumerate(itertools.batched(png_data, raw_chunk_size)):
        processed_bytes = (i+1) * raw_chunk_size
        more = processed_bytes < len(png_data)
        encoded = base64.standard_b64encode(bytes(batch)).decode("ascii")

        if i == 0:
            attrs = f"a=T,f=100,m={more:d}"
        else:
            attrs = f"m={more:d}"

        sys.stdout.write(f"\x1b_G{attrs};{encoded}\x1b\\")

    sys.stdout.write("\n")
    sys.stdout.flush()


def generate_qr_image(content):
    qr = qrcode.QRCode(
        version=None,
        error_correction=qrcode.ERROR_CORRECT_M,
        box_size=8,
        border=4,
    )
    qr.add_data(content)
    qr.make(fit=True)

    with io.BytesIO() as buffer:
        img = qr.make_image(fill_color="black", back_color="white")
        img.get_image().save(buffer, format="PNG")
        return buffer.getvalue()


def main():
    args = parse_args()

    content = args.content
    if content is None or content == "-":
        content = sys.stdin.read().strip()

    png_data = generate_qr_image(content)

    if args.output == "kitty":
        sys.stdout.write("\n\x1b[1C")  # move cursor
        write_kitty_graphics(png_data)
    elif args.output == "png":
        sys.stdout.buffer.write(png_data)
        sys.stdout.buffer.flush()


main()
