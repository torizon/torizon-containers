#!/usr/bin/env python3
import os, glob, time
import numpy as np
from PIL import Image

import tflite_runtime.interpreter as tfl


def find_vx_delegate():
    for p in (
        os.getenv("VX_DELEGATE", "/usr/lib/libvx_delegate.so"),
        "/usr/lib/libvx_delegate.so.2",
        "/usr/lib/libvx_delegate.so.1",
    ):
        if os.path.exists(p):
            return p
    return None


def preprocess(path, size, dtype):
    img = Image.open(path).convert("RGB")
    w, h = img.size
    s = max(w, h)
    canvas = Image.new("RGB", (s, s))
    canvas.paste(img, ((s - w) // 2, (s - h) // 2))
    canvas = canvas.resize((size, size))
    x = np.asarray(canvas, dtype=dtype)
    return np.expand_dims(x, 0)


def main():
    root = os.getenv("APP_ROOT", "/app")
    data_dir = os.getenv("DATA_DIR", f"{root}/cats_and_dogs_filtered/validation")
    model = os.getenv("MODEL", f"{root}/mobilenet_v1_1.0_224_quant.tflite")
    labels_fn = os.getenv("LABELS", f"{root}/labels_mobilenet_quant_v1_224.txt")
    limit = int(os.getenv("LIMIT", "0"))

    files = sorted(glob.glob(f"{data_dir}/dogs/*.jpg")) + sorted(
        glob.glob(f"{data_dir}/cats/*.jpg")
    )
    if limit > 0:
        files = files[:limit]
    if not files:
        raise SystemExit(f"no images under {data_dir}")

    labels = [l.strip() for l in open(labels_fn, "r", encoding="utf-8") if l.strip()]

    delegates = []
    vx = find_vx_delegate()
    if vx:
        try:
            delegates.append(tfl.load_delegate(vx))
        except Exception:
            delegates = []

    itp = (
        tfl.Interpreter(model_path=model, experimental_delegates=delegates)
        if delegates
        else tfl.Interpreter(model_path=model)
    )
    itp.allocate_tensors()

    in0 = itp.get_input_details()[0]
    out0 = itp.get_output_details()[0]
    size = int(in0["shape"][1])
    dtype = in0["dtype"]

    times = []
    for i, p in enumerate(files):
        itp.set_tensor(in0["index"], preprocess(p, size, dtype))
        t1 = time.time()
        itp.invoke()
        t2 = time.time()
        y = itp.get_tensor(out0["index"])[0]
        top = int(np.argmax(y))
        print(
            f"{p}: {labels[top] if top < len(labels) else top} ({t2-t1:.4f}s)",
            flush=True,
        )
        if i != 0:
            times.append(t2 - t1)

    if times:
        a = np.array(times, dtype=np.float64)
        m = float(a.mean())
        print("\nImages processed:", len(a))
        print("Mean inference time:", m)
        print("Images/s:", (1.0 / m) if m > 0 else 0.0)
        print("Std deviation:", float(a.std()))


if __name__ == "__main__":
    main()
