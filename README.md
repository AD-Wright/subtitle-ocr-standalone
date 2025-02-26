# Subtitle Converter
A commandline standalone application to convert `VobSub` to `SRT`.

This standalone application is powered by [subtile-ocr](https://github.com/gwen-lg/subtile-ocr) which uses `Tesseract Open Source OCR Engine` and written in rust.

## Languages supported
For now only English. You are welcome to add `Tesseract` datafiles for the languages you want.

## Use
Like all AppImages, you need to have `fuse` installed from your Linux distro.
```
./SubtitleConverter-x86_64.AppImage <YOUR_MKV_FILE>
```
This will create an `.srt` subtitle for you with the same name of your `.mkv` input at the same directory that this program runs!