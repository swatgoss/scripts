# QEMU RAW to VHDX Converter GUI

A lightweight, optimized PowerShell Graphical User Interface (GUI) for `qemu-img`. This tool simplifies the process of converting RAW, IMG, and DD disk images into VHDX format (dynamic or fixed) for use with Hyper-V or Windows native mounting. 

Perfect for converting physical disk backups created with tools like [Win32 Disk Imager](https://win32diskimager.org/) or [HDD Raw Copy Tool](https://hddguru.com/software/HDD-Raw-Copy-Tool/) or ddrescue.

![RAW to VHDX Converter Screenshot](qemu-img-GUI.png)

## Features

* **No Installation Required:** A standalone PowerShell script. It even includes a button to automatically download the required `qemu-img` binary if you don't have it.
* **Performance Optimized:** Uses modern `qemu-img` arguments (`-W -m 16`) by default to maximize conversion speed (out-of-order writing and multi-threading).
* **Live Metrics:** Features a real-time progress bar, command preview, and estimated input file read speeds (MB/s).
* **Batching Friendly:** Set an output folder once, and the destination path will auto-fill for every new source file you select.

## How to Use

1. Download or clone this repository.
2. Double-click the provided `.bat` file to launch the GUI without encountering PowerShell security policy restrictions.
    * *Alternatively, right-click `qemu-img-gui.ps1` and select "Run with PowerShell".*
3. If the status says `[X] qemu-img missing`, click the **Download qemu-img** button to automatically fetch and extract the necessary tools.
4. Select your **Source File** (`.raw`, `.img`, `.dd`).
5. Choose your **Output Folder** or let it default to the source directory.
6. Click **Start Conversion**.

## Requirements

* Windows 10 / 11
* PowerShell 5.1+ (Built into Windows)
